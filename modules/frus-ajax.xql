xquery version "3.1";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";
import module namespace fh="http://history.state.gov/ns/site/hsg/frus-html" at "frus-html.xqm";
import module namespace toc="http://history.state.gov/ns/site/hsg/frus-toc-html" at "frus-toc-html.xqm";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace functx = "http://www.functx.com";

declare option output:method "json";
declare option output:media-type "application/json";

(:
 : This module is called from Javascript when the user wants to navigate to the next/previous
 : page.
 :)

(:~
 : Look up the created and last modified dates of a resource, set the appropriate HTTP response headers,
 : and, if appropriate, issue a 304 Not Modified status code.
 :)
declare function local:set-headers($publication-id as xs:string, $document-id as xs:string, $section-id as xs:string?) {
    let $created := pages:created($publication-id, $document-id, $section-id)
    let $last-modified := 
        pages:last-modified($publication-id, $document-id, $section-id)
        (: For the purpose of comparing the resource's last modified date with the If-Modified-Since
         : header supplied by the client, we must truncate any milliseconds from the last modified date.
         : This is because HTTP-date is only specific to the second.
         : @see https://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1 :)
        => format-dateTime("[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01][Z]")
        => xs:dateTime()
    let $if-modified-since := try { request:get-attribute("if-modified-since") => parse-ietf-date() } catch * { () }
    let $should-return-304 := 
        if (exists($last-modified) and exists($if-modified-since)) then
            $if-modified-since ge $last-modified
        else
            ()
    return
        (
            app:set-created($created),
            app:set-last-modified($last-modified),
            if ($should-return-304) then
                response:set-status-code(304)
            else
                ()
        )
};

let $url := request:get-parameter("url", ())
let $toc := boolean(request:get-parameter("toc", ()))
let $match := analyze-string($url, "^/([^/]+)/([^/]+)/?(.*)$")
let $url-slug-1 := $match//fn:group[@nr = "1"]/string()
let $url-slug-2 := $match//fn:group[@nr = "2"]/string()
let $url-slug-3 := $match//fn:group[@nr = "3"]/string()

(: First, map the URL slugs onto the required parameters for looking up the requested XML source:
 : publication-id, document-id, and section-id.
 :
 : For example:
 : 
 : - /historicaldocuments/frus1969-76v18/d1      -> frus, frus1969-76v18, d1
 : - /historicaldocuments/frus-history/chapter-2 -> frus-history-monograph, frus-history-monograph, chapter-2
 : - /departmenthistory/buildings/intro          -> buildings, buildings, intro
 : - /about/hac/August-2021                      -> hac, hac, August-2021
 :)

let $section-id := $url-slug-3
let $document-id := 
    if ($url-slug-2) then 
        $url-slug-2 
    else 
        $url-slug-1
let $publication-id :=
    switch ($url-slug-1)
        case 'historicaldocuments' return
            switch ($document-id)
                case "frus-history" return "frus-history-monograph"
                default return 'frus'
        case 'about' return $document-id
        case 'departmenthistory' return
            switch ($document-id)
                case 'buildings' return 'buildings'
                case 'short-history' return 'short-history'
                case 'timeline' return 'timeline'
                default return $url-slug-1
        default return $url-slug-1

(: Load XML and generate assets :)

let $xml := pages:load-xml($publication-id, $document-id, $section-id, "div")
return
    if ($xml) then
        (
        
        (: Set HTTP Headers - and cut the request short with a 304 status code if possible :)
        
        local:set-headers($publication-id, $document-id, $section-id),

        (: ... then generate the assets :)
        
        let $odd := if ($publication-id) then map:get($config:PUBLICATIONS, $publication-id)?transform else $config:odd-transform-default
        let $prev := pages:get-previous($xml)
        let $next := pages:get-next($xml)
        let $base-path :=
            if (map:contains(map:get($config:PUBLICATIONS, $publication-id), 'base-path')) then
                map:get($config:PUBLICATIONS, $publication-id)?base-path($document-id, $section-id)
            else ()

        let $html :=
            if ($xml instance of element(tei:pb))
            then (
                let $pg-id :=  concat('#', $xml/@xml:id)
                let $tif-graphic := $xml/ancestor::tei:TEI//tei:surface[@start=string($pg-id)]//tei:graphic[@mimeType="image/tiff"]
                let $tif-graphic-height := $tif-graphic/@height => substring-before("px")
                let $tif-graphic-width := $tif-graphic/@width => substring-before("px")
                let $tif-graphic-url := $tif-graphic/@url
                let $src := concat('https://', $config:S3_DOMAIN, '/frus/', $document-id, '/medium/', $xml/@facs, '.png')
                return (
                    <noscript>
                        <div class="content">
                            <img src="{ $src }" class="img-responsive img-thumbnail center-block"/>
                        </div>
                    </noscript>
                    ,
                    <section class="osd-wrapper content">
                        <div id="viewer" data-doc-id="{ $document-id }" data-facs="{ $xml/@facs }" data-url="{ $tif-graphic-url }" data-width="{ $tif-graphic-width }" data-height="{ $tif-graphic-height }"></div>
                    </section>
                )
            )
            else
                pages:process-content($odd, pages:get-content($xml), map { "base-uri": $base-path })
        let $html := app:fix-links($html)
        let $doc := replace($document-id, "^.*/([^/]+)$", "$1")
        let $model := map {
            "odd": $odd,
            "data": $xml
        }
        let $breadcrumbs :=
            if ($publication-id = "frus") then
                <li class="section-breadcrumb">{fh:section-breadcrumb(<n/>, $model)}</li>
            else
                pages:deep-section-breadcrumbs(<n/>, $model, true())
        let $mediaLink :=
            if (fh:media-exists($document-id, $section-id, ".pdf")) then
                fh:pdf-url($document-id, $section-id)
            else
                ()
        let $head :=
            if ($section-id) then
                if ($xml instance of element(tei:div)) then
                    $xml/tei:head[1] ! functx:remove-elements-deep(., 'note')
                else
                    root($xml)//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'complete']
            (: we can't trust pages:load-xml for the purposes of finding a document's title, since it returns the document's first descendant div :)
            (: allow for pages that don't have $config:PUBLICATIONS?select-document defined :)
            else if ($publication-id and map:contains(map:get($config:PUBLICATIONS, $publication-id), 'select-document')) then
                map:get($config:PUBLICATIONS, $publication-id)?select-document($document-id)//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'complete']
            (: allow for pages that don't have an entry in $config:PUBLICATIONS at all :)
            else
                ()
        let $publication-title :=
            if ($publication-id) then
                map:get($config:PUBLICATIONS, $publication-id)?title
            else
                ($html//(h1|h2|h3))[1]
        let $doc-title := pages:title($xml/ancestor-or-self::tei:TEI)
        let $viewer :=
            if ($xml instance of element(tei:pb))
            then ('true')
            else ()

        return
            map {
                "doc": $doc,
                "next":
                    if ($next and map:contains(map:get($config:PUBLICATIONS, $publication-id), 'url-fragment')) then
                        map:get($config:PUBLICATIONS, $publication-id)?url-fragment($next)
                    else if ($next) then
                        $next/@xml:id/string()
                    else (),
                "previous":
                    if ($prev and map:contains(map:get($config:PUBLICATIONS, $publication-id), 'url-fragment')) then
                        map:get($config:PUBLICATIONS, $publication-id)?url-fragment($prev)
                    else if ($prev) then
                        $prev/@xml:id/string()
                    else (),
                "title": $doc-title,
                "windowTitle": normalize-space(string-join(($head, $doc-title, $publication-title, "Office of the Historian")[. ne ''], " - ")),
                "toc": if ($toc) then toc:toc($model, $xml, true(), true()) else (),
                "tocCurrent": $xml/ancestor-or-self::tei:div[@type != "document"][1]/@xml:id/string(),
                "breadcrumbSection": $breadcrumbs,
                "persons":
                    let $persons :=
                        if ($xml/@type=('compilation', 'chapter', 'subchapter')) then
                            ()
                        else
                            fh:get-persons($xml, distinct-values($xml//tei:persName/@corresp))
                    return
                        if ($persons) then <div class="list-group">{$persons}</div> else (),
                "pdf": $mediaLink,
                "gloss":
                    let $gloss :=
                        if ($xml/@type=('compilation', 'chapter', 'subchapter')) then
                            ()
                        else
                            fh:get-gloss($xml, distinct-values($xml//tei:gloss/@target))
                    return
                        if ($gloss) then <div class="list-group">{$gloss}</div> else (),
                "content": serialize($html,
                    <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
                      <output:omit-xml-declaration value="yes"/>
                      <output:indent>no</output:indent>
                    </output:serialization-parameters>
                ),
                "viewer" : $viewer
            }
        )
    else
        map { "error": "Not found" }
