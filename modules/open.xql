xquery version "3.0";

(:
    "Open goverment" atom feed for latest volumes.
:)

declare namespace open="http://history.state.gov/ns/xquery/open";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";

declare option output:method "xml";

declare variable $application-url := request:get-parameter('xql-application-url', '');


declare function open:frus-latest() {
   let $serialize := util:declare-option('exist:serialize', 'method=xml media-type=text/xml indent=yes')

   let $title := 'Foreign Relations of the United States: Latest Volumes'

   (: Note that RFC 4287 http://tools.ietf.org/html/rfc4287 was used to create these mappings to the Atom standard. :)

   let $n := xs:integer(request:get-parameter('n', '10'))

   (: create a list of all volumes sorted by the publication date :)
   let $volumes :=
      for $revisionDesc in collection($config:FRUS_COL_VOLUMES)//tei:revisionDesc[@status = ("published", "partially-published")]
      let $volume := $revisionDesc/root(.)/tei:TEI
      order by $revisionDesc/tei:change[@corresp eq "#" || $volume/@xml:id]/@when descending
      return $volume

   let $last-n-volumes := subsequence($volumes, 1, $n)

   let $feed-id := 'http://history.state.gov/atom/frus-metadata-v1'

   let $author := 'Office of the Historian, Shared Knowledge Services, Bureau of Administration, United States Department of State'

   let $entries :=
        for $volume in $last-n-volumes
            let $vol-id := string($volume/@xml:id)
            let $volume-title := normalize-space($volume//tei:title[@type="complete"])

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

            let $published-date := $volume//tei:revisionDesc/tei:change[@corresp eq "#" || $vol-id]/@when

        (: Mapping to the "atom:rights" Element
           The following text was taken from http://www.whitehouse.gov/copyright :)

            let $rights := 'Pursuant to federal law, government-produced materials appearing on this site are not copyright protected.'
            
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

            let $editors :=
                concat(
                    if ( count($volume//tei:editor[@role='primary']) gt 1 ) then
                        concat('Editors: ', string-join($volume//tei:editor[@role='primary'], ', '), '. ')
                    else if (count($volume//tei:editor[@role='primary']) eq 1) then
                        concat('Editor: ', $volume//tei:editor[@role='primary'], '. ')
                    else ()
                    ,
                    if ($volume//tei:editor[@role='general']) then
                        concat('General Editor: ', $volume//tei:editor[@role='general']/text())
                    else ()
                    )

            let $entry-created := config:last-modified-from-repo-xml($config:FRUS_COL)()
            let $entry-modified := $config:PUBLICATIONS?frus?document-last-modified($vol-id)

            let $link := concat(substring-before($application-url, '/open'), '/historicaldocuments/', $vol-id)

            order by $published-date descending, $vol-id

            return
                <entry xmlns="http://www.w3.org/2005/Atom">
                    <title>{$volume-title}</title>
                    <id>{$link}</id>
                    <link type="text/html" href="{$link}"/>
                    <author><name>{$author}</name></author>
                    <published>{$entry-created}</published>
                    <updated>{$entry-modified}</updated>
                    <rights>{$rights}</rights>
                    <summary>{
                        normalize-space(
                            concat(
                                'Published ', $published-date, if ($editors) then concat('. ', $editors) else (), '.'
                            )
                        )
                    }</summary>
                </entry>

   return
        <feed xmlns="http://www.w3.org/2005/Atom">
            <title>{$title}</title>
            <subtitle>The {$n} most recently published volumes in the Foreign Relations of the United States series, sorted by year of publication.</subtitle>
            <link href="{concat(substring-before($application-url, '/open'), '/open/frus-latest.xml')}" rel="self" />
            <id>{$feed-id}</id>
            <updated>{config:last-modified-from-repo-xml($config:FRUS_COL)()}</updated>
            <author><name>{$author}</name></author>
            { $entries }
        </feed>
};

declare function open:frus-metadata() {
    let $serialize := util:declare-option('exist:serialize', 'method=xml media-type=text/xml indent=yes')

    let $volumes :=
        for $volume in collection($config:FRUS_COL_VOLUMES)//tei:revisionDesc[@status = ('published', 'partially-published')]/root(.)/tei:TEI
            let $titles := $volume//tei:title[. ne '']
            let $locations := $volume/external-location[. ne ''][./@loc = ('db', 'madison', 'worldcat')]
            let $media := $volume//tei:keywords[@scheme eq "#frus-media-type"]/tei:term/string()
            let $published-year := substring($volume//tei:revisionDesc/tei:change[@corresp eq "#" || $volume/@xml:id]/@when, 1, 4)
            let $coverage := string($volume//tei:publicationStmt/tei:date[@type eq "content-date"])
            let $lengths := $volume/length/span[. ne '']
            order by $volume/@xml:id
            return
                <volume xmlns="http://history.state.gov/ns/1.0" id="{$volume/@xml:id}">
                    {
                    for $title in $titles 
                    return
                        element title { $title/@*, $title/text() },
                    for $location in $locations
                    return
                        if ($location/@loc = ('madison', 'worldcat')) then
                            <external-location loc="{$location/@loc}">{$location/text()}</external-location>
                        else
                            <external-location loc="db">{concat($application-url, '/historicaldocuments/', $location)}</external-location>
                    ,
                    <media>{$media}</media>,
                    <published>{$published-year}</published>,
                    <coverage>{$coverage}</coverage>,
                    if ($lengths) then
                    <length>{
                        for $length in $lengths
                        return
                            element span { $length/@*, $length/text() }
                    }</length>
                    else ()
                    }
                </volume>
    return
        <volumes xmlns="http://history.state.gov/ns/1.0">
            {'
    '}
            {comment {
                concat(
                    'Dump of FRUS Volume Metadata from Volume Manager
    Report Version: 1.0
    Report Last Updated: '
                    ,
                    config:last-modified-from-repo-xml($config:FRUS_COL)()
                    (:
                    ,
                    '
    See http://history.state.gov/open/frus-metadata
    for descriptions of the codes used in this file.'
                    :)
                    )
                }
            }
            { $volumes }
        </volumes>
};

let $publication-config := map{ "publication-id": "frus" }
let $created := app:created($publication-config, ())
let $last-modified := app:last-modified($publication-config, ())
let $not-modified-since := app:modified-since($last-modified, app:safe-parse-if-modified-since-header())

return 
    if ($not-modified-since) then (
        (: if the "If-Modified-Since" header in the client request is later than the
        : last-modified date, then halt further processing of the templates and simply
        : return a 304 response. :)
        response:set-status-code(304),
        app:set-last-modified($last-modified)
    ) else if (request:get-parameter('x-method', ()) eq 'head') then (
        (: When revalidating a cached resource and the "If-Modified-Since" header sent by the client indicates
        : the resource has changed in the meantime, it is just a head request. Do not render the page as the 
        : response body is discarded anyway and just return status code 200. :)
        response:set-status-code(200),
        app:set-last-modified($last-modified)
    ) else (
        (:
        : The HTML is passed in the request from the controller.
        : Run it through the templating system and return the result.
        :)
        (
            switch(request:get-parameter('xql-feed', ''))
                case 'latest' return open:frus-latest()
                case 'metadata' return open:frus-metadata()
                default return <error/>,
            (: only set last-modified if rendering was succesful :)
            app:set-last-modified($last-modified),
            app:set-created($created)
        )
    )