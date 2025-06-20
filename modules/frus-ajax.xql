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
declare function local:set-headers($publication-config as map(*), $document-id as xs:string, $section-id as xs:string?) {
    let $created := app:created($publication-config, $document-id)
    let $last-modified := app:last-modified($publication-config, $document-id)

    let $not-modified-since := app:modified-since($last-modified, app:safe-parse-if-modified-since-header())
    let $status-code := if ($not-modified-since) then (304) else (200)

    return (
        app:set-last-modified($last-modified),
        app:set-created($created),
        response:set-status-code($status-code)
    )
};

declare function local:nav($publication-config as map(*), $element as element()?) {
    if (empty($element)) then (
    ) else if (map:contains($publication-config, 'url-fragment')) then (
        $publication-config?url-fragment($element)
    ) else (
        $element/@xml:id/string()
    )
};

declare function local:render-list-group($xml as element(), $accessor as function(*)) as element()* {
    if ($xml/@type = ('compilation', 'chapter', 'subchapter')) then ()
    else
        let $group = $accessor($xml)
        if (empty($group)) then () else
            <div class="list-group">{ $group }</div>
};

declare function local:persons($xml as element()) {
    fh:get-persons($xml,
        distinct-values($xml//tei:persName/@corresp))
};

declare function local:gloss($xml as element()) {
    fh:get-gloss($xml,
        distinct-values($xml//tei:gloss/@target))
};

declare function local:image($xml) {
    let $pg-id := concat('#', $xml/@xml:id)
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
            <div id="viewer"
              data-doc-id="{ $document-id }" data-facs="{ $xml/@facs }" data-url="{ $tif-graphic-url }"
              data-width="{ $tif-graphic-width }" data-height="{ $tif-graphic-height }">
            </div>
        </section>
    )
};

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
let $url := request:get-parameter("url", ())
let $path-parts := tokenize($url, "/")

let $section-id := $path-parts[3]
let $document-id := ($path-parts[2], $path-parts[1])[1]
let $publication-id :=
    switch ($path-parts[1])
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
                default return $path-parts[1]
        default return $path-parts[1]

let $publication-config := ($config:PUBLICATIONS?($publication-id), map{})[1]


(: Load XML and generate assets :)

let $xml := pages:load-xml($publication-config, $document-id, $section-id, "div")
return
    if (empty($xml)) then (
        map { "error": "Not found" }
    ) else (
        (: Set HTTP Headers - and cut the request short with a 304 status code if possible :)
        local:set-headers($publication-config, $document-id, $section-id),

        (: ... then generate the assets :)
        let $odd := ($publication-config?transform, $config:odd-transform-default)[1]
        let $base-path :=
            if (map:contains($publication-config, 'base-path')) then
                $publication-config?base-path($document-id, $section-id)
            else ()

        let $html :=
            if ($xml instance of element(tei:pb))
            then local:image($xml)
            else pages:process-content($odd, pages:get-content($xml), map { "base-uri": $base-path })

        let $html := app:fix-links($html)
        let $doc := replace($document-id, "^.*/([^/]+)$", "$1")
        let $model := map { "odd": $odd, "data": $xml }

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
            else if (map:contains($publication-config, 'select-document')) then
                $publication-config?select-document($document-id)//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'complete']
            (: allow for pages that don't have an entry in $config:PUBLICATIONS at all :)
            else
                ()
        let $doc-title := pages:title($xml/ancestor-or-self::tei:TEI)
        let $publication-title := (
            $publication-config?title,
            ($html//(h1|h2|h3))[1]
        )[1]
        let $window-title :=
            ($head, $doc-title, $publication-title, "Office of the Historian")[. ne '']
            => string-join(" - ")
            => normalize-space()

        return
            map {
                "doc": $doc,
                "title": $doc-title,
                "windowTitle": $window-title,
                "pdf": $mediaLink,
                "breadcrumbSection": $breadcrumbs,
                "next": local:nav(pages:get-next($xml)),
                "previous": local:nav(pages:get-previous($xml)),
                "toc": if (boolean(request:get-parameter("toc", ()))) then toc:toc($model, $xml, true(), true()) else (),
                "tocCurrent": $xml/ancestor-or-self::tei:div[@type != "document"][1]/@xml:id/string(),
                "persons": local:render-list-group($xml, local:persons#1),
                "gloss": local:render-list-group($xml, local:gloss#1),
                "content": serialize($html, map { "omit-xml-declaration": true(), "indent": false()}),
                "viewer" : if ($xml instance of element(tei:pb)) then "true" else ()
            }
        )
