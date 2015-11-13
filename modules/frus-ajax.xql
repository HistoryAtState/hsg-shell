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
let $toc := boolean(request:get-parameter("toc", ()))
let $match := analyze-string($url, "^/([^/]+)/([^/]+)/?(.*)$")
let $publication := $match//fn:group[@nr = "1"]/string()
let $volume := $match//fn:group[@nr = "2"]/string()
let $id := $match//fn:group[@nr = "3"]/string()
let $pub :=
  switch($publication)
    case 'historicaldocuments' return 'frus'
    default return $volume
let $volume := if($volume) then $volume else $pub
let $xml := pages:load-xml($pub, $volume, $id, "div")
return
    if ($xml) then
        let $odd := if ($pub) then map:get($config:PUBLICATIONS, $pub)?odd else $config:odd
        let $parent := $xml/ancestor::tei:div[not(*[1] instance of element(tei:div))][1]
        let $prevDiv := $xml/preceding::tei:div[not(@xml:id = $config:IGNORED_DIVS)][1]
        let $prev := pages:get-previous(
            if ($xml instance of element(tei:pb)) then
                $xml
            else if ($parent and (empty($prevDiv) or $xml/.. >> $prevDiv)) then 
                $xml/.. 
            else $prevDiv
        )
        let $next := pages:get-next($xml)
        let $html := 
            if ($xml instance of element(tei:pb)) then
                let $href := concat('http://static.history.state.gov/frus/', root($xml)/tei:TEI/@xml:id, '/medium/', $xml/@facs, '.png')
                return
                    <div class="content"><img src="{$href}"/></div>
            else
                pages:process-content($odd, pages:get-content($xml), map { "base-uri": $pub || (if ($volume ne $pub) then "/" || $volume else ()) })
        let $html := app:fix-links($html)
        let $doc := replace($volume, "^.*/([^/]+)$", "$1")
        return
            map {
                "doc": $doc,
                "odd": $odd,
                "next": 
                    if ($next) then 
                        $next/@xml:id/string()
                    else (),
                "previous": 
                    if ($prev) then
                        $prev/@xml:id/string()
                    else (),
                "title": pages:title($xml/ancestor-or-self::tei:TEI),
                "toc": if ($toc) then toc:toc($xml, true(), true()) else (),
                "tocCurrent": $xml/ancestor-or-self::tei:div[@type != "document"][1]/@xml:id/string(),
                "breadcrumbSection": fh:breadcrumb-heading($xml),
                "persons": 
                    let $persons := fh:get-persons($xml, distinct-values($xml//tei:persName/@corresp))
                    return
                        if ($persons) then <div class="list-group">{$persons}</div> else (),
                "gloss": 
                    let $gloss := fh:get-gloss($xml, distinct-values($xml//tei:gloss/@target))
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