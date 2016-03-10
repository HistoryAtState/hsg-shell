xquery version "3.0";

(: 
    "Open goverment" atom feed for latest volumes.
:)

declare namespace open="http://history.state.gov/ns/xquery/open";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";

declare option output:method "xml";

declare function open:frus-latest() {
   let $serialize := util:declare-option('exist:serialize', 'method=xml media-type=text/xml indent=yes')

   let $title := 'Foreign Relations of the United States: Latest Volumes'
   
   (: Note that RFC 4287 http://tools.ietf.org/html/rfc4287 was used to create these mappings to the Atom standard. :)
   
   let $application-url := request:get-parameter('xql-application-url', '..')
   
   let $n := xs:integer(request:get-parameter('n', '10'))
   
   (: create a list of all volumes sorted by the publication date :)
   let $volumes :=
      for $volume in collection($config:FRUS_METADATA_COL)/volume[publication-status eq 'published']
      order by $volume/published-year descending
      return $volume
   
   let $last-n-volumes := subsequence($volumes, 1, $n)
   
   let $feed-id := 'http://history.state.us/atom/frus-metadata-v1'
   
   let $author := 'Office of the Historian, Bureau of Public Affairs, United States Department of State'
   
   let $entries := 
        for $volume in $last-n-volumes
            let $id := string($volume/@id)
            let $volume-title := normalize-space($volume/title[@type="complete"]/text())
                        
        (: Mapping to the atom:author Element
        atom:feed elements MUST contain one or more atom:author elements
        
        http://tools.ietf.org/html/rfc4287#section-4.2.1
        
        The "atom:author" element is a Person construct that indicates the
           author of the entry or feed.
           
           TODO - should the editors be part of the author field?
           <editor role="primary"/>
        :)
        
                        
        (: Mapping to the atom:published Element
            from http://tools.ietf.org/html/rfc4287#section-4.2.9
              4.2.9. The 
              The "atom:published" element is a Date construct indicating an
              instant in time associated with an event early in the life cycle of
              the entry.
        :)
        
            let $published-date := if ($volume/published-date ne '') then $volume/published-date/text() else $volume/published-year/text()
        
        (: Mapping to the "atom:rights" Element
           The following text was taken from http://www.whitehouse.gov/copyright :)
           
            let $rights := 'Pursuant to federal law, government-produced materials appearing on this site are not copyright protected.'
            let $coverage := $volume/coverage/text()
            let $from := $volume/coverage[@type='from']/text()
            let $file := concat($application-url, (:$style:web-path-to-app,:) '/data/', $id, '.xml')
                        
        (: Mapping to the  The "atom:summary" Element
           http://tools.ietf.org/html/rfc4287#section-4.2.13
        
           The "atom:summary" element is a Text construct that conveys a short
           summary, abstract, or excerpt of an entry.
        
           atomSummary = element atom:summary { atomTextConstruct }
        
           It is not advisable for the atom:summary element to duplicate
           atom:title or atom:content because Atom Processors might assume there
           is a useful summary when there is none.
           
           Note that we have decided to keep the summary plain-text because this text is used
           as hover text in many systems.
           
           We have also decided to use only the first TEI paragraph.
           
           Note that if you use multiple paragraphs you might want to use the following:
           
           let $summary := normalize-space(string-join($volume/summary/tei:p/text(), ' '))
        :)
        
            let $summary := data($volume/summary/tei:p[1])
            
            let $editors := 
                concat(
                    if ( count($volume/editor[@role='primary']) gt 1 ) then
                        concat('Editors: ', string-join($volume/editor[@role='primary'], ', '), '. ')
                    else if (count($volume/editor[@role='primary']) eq 1) then
                        concat('Editor: ', $volume/editor[@role='primary'], '. ')
                    else ()
                    ,
                    if ($volume/editor[@role='general']) then
                        concat('General Editor: ', $volume/editor[@role='general']/text())
                    else ()
                    )
            
            let $entry-created := $volume/created-datetime/text()
            let $entry-modified := $volume/modified-datetime/text()
            
            order by $published-date descending, $volume/@id
            
            return
                <entry xmlns="http://www.w3.org/2005/Atom">
                    <title>{$volume-title}</title>
                    <id>{$id}</id>
                    <link type="text/html" href="{concat($application-url, '/historicaldocuments/', $id)}"/>
                    {(: <link type="text/xml" href="{$file}"/> :) ()}
                    <author><name>{$author}</name></author>
                    <published>{$entry-created}</published>
                    <updated>{$entry-modified}</updated>
                    <rights>{$rights}</rights>
                    <summary>{
                        normalize-space(
                            concat(
                                $summary, ' (Published ', $published-date, if ($editors) then concat('. ', $editors) else (), '.)'
                            )
                        )
                    }</summary>
                </entry>
   
   return
        <feed xmlns="http://www.w3.org/2005/Atom">
            <title>{$title}</title>
            <subtitle>The {$n} most recently published volumes in the Foreign Relations of the United States series, sorted by year of publication.</subtitle>
            <link href="{concat($application-url, '/open/frus-latest.xml')}" rel="self" />
            <id>{$feed-id}</id>
            <updated>{
                let $dates :=
                    for $volume in xmldb:get-child-resources($config:FRUS_METADATA_COL)
                    return xmldb:last-modified($config:FRUS_METADATA_COL, $volume)
                return max($dates)
            }</updated>
            <author><name>{$author}</name></author>
            { $entries }
        </feed>
};

declare function open:frus-metadata() {
    <metadata/>
};

switch(request:get-parameter('xql-feed', ''))
case 'latest' return open:frus-latest()
case 'metadata' return open:frus-metadata()
default return <error/>