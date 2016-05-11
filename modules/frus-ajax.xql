xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";
import module namespace fh="http://history.state.gov/ns/site/hsg/frus-html" at "frus-html.xqm";
import module namespace toc="http://history.state.gov/ns/site/hsg/frus-toc-html" at "frus-toc-html.xqm";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";

declare option output:method "json";
declare option output:media-type "application/json";

(:
 : This module is called from Javascript when the user wants to navigate to the next/previous
 : page.
 :)
let $url := request:get-parameter("url", ())
(: remove after beta. brittle url logic here. :)
let $url := if (starts-with($url, '/beta')) then substring-after($url, '/beta') else $url
let $toc := boolean(request:get-parameter("toc", ()))
let $match := analyze-string($url, "^/([^/]+)/([^/]+)/?(.*)$")
let $publication := $match//fn:group[@nr = "1"]/string()
let $volume := $match//fn:group[@nr = "2"]/string()
let $id := $match//fn:group[@nr = "3"]/string()
(: TODO Please add comments describing assumption of the path parsing and mapping onto publication-id/document-id/section-id logic :)
let $publication-id :=
    switch ($publication)
        case 'historicaldocuments' return
            switch ($volume)
                case "frus-history" return "frus-history-monograph"
                default return 'frus'
        case 'about' return $volume
        case 'departmenthistory' return
            switch ($volume)
                case 'buildings' return 'buildings'
                case 'short-history' return 'short-history'
                default return $publication
        default return $publication
let $log := console:log("publication: " || $publication || ", volume: " || $volume)
let $volume := if ($volume) then $volume else $publication-id (: TODO see above - please explain :)
let $xml := pages:load-xml($publication-id, $volume, $id, "div")
return
    if ($xml) then
        let $odd := if ($publication-id) then map:get($config:PUBLICATIONS, $publication-id)?transform else $config:odd-transform-default
        let $prev := pages:get-previous($xml)
        let $next := pages:get-next($xml)
        let $base-path :=
            if (map:contains(map:get($config:PUBLICATIONS, $publication-id), 'base-path')) then
                map:get($config:PUBLICATIONS, $publication-id)?base-path($volume, $id)
            else ()
        let $html :=
            if ($xml instance of element(tei:pb)) then
                let $href := concat('//', $config:S3_DOMAIN, '/frus/', substring-before(util:document-name($xml), '.xml') (:ACK why is this returning blank?!?! root($xml)/tei:TEI/@xml:id:), '/medium/', $xml/@facs, '.png')
                return
                    <div class="content">
                        <img src="{$href}" class="img-responsive img-thumbnail center-block"/>
                    </div>
            else
                pages:process-content($odd, pages:get-content($xml), map { "base-uri": $base-path })
        let $html := app:fix-links($html)
        let $doc := replace($volume, "^.*/([^/]+)$", "$1")
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
            if (fh:media-exists($volume, $id, ".pdf")) then
                fh:pdf-url($volume, $id)
            else
                ()
        let $head :=
            if ($id) then
                if ($xml instance of element(tei:div)) then
                    $xml/tei:head
                else
                    root($xml)//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'complete']
            (: we can't trust pages:load-xml for the purposes of finding a document's title, since it returns the document's first descendant div :)
            (: allow for pages that don't have $config:PUBLICATIONS?select-document defined :)
            else if ($publication-id and map:contains(map:get($config:PUBLICATIONS, $publication-id), 'select-document')) then
                map:get($config:PUBLICATIONS, $publication-id)?select-document($volume)//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'complete']
            (: allow for pages that don't have an entry in $config:PUBLICATIONS at all :)
            else
                ()
        let $title :=
            if ($publication-id) then
                map:get($config:PUBLICATIONS, $publication-id)?title
            else
                ($html//(h1|h2|h3))[1]
        return
            map {
                "doc": $doc,
                "next":
                    if ($next) then
                        $next/@xml:id/string()
                    else (),
                "previous":
                    if ($prev) then
                        $prev/@xml:id/string()
                    else (),
                "title": pages:title($xml/ancestor-or-self::tei:TEI),
                "windowTitle": string-join(($head, $title, "Office of the Historian")[. ne ''], " - "),
                "toc": if ($toc) then toc:toc($model, $xml, true(), true()) else (),
                "tocCurrent": $xml/ancestor-or-self::tei:div[@type != "document"][1]/@xml:id/string(),
                (: "breadcrumbSection": fh:breadcrumb-heading($model, $xml), :)
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
                )
            }
    else
        map { "error": "Not found" }
