xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xql";
import module namespace toc="http://history.state.gov/ns/site/hsg/toc" at "toc.xql";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xql";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";

declare option output:method "json";
declare option output:media-type "application/json";

(: 
 : This module is called from Javascript when the user wants to navigate to the next/previous
 : page.
 :)
let $url := request:get-parameter("url", ())
let $toc := boolean(request:get-parameter("toc", ()))
let $match := analyze-string($url, "^/([^/]+)/?(.*)$")
let $volume := $match//fn:group[@nr = "1"]/string()
let $id := $match//fn:group[@nr = "2"]/string()
let $xml := pages:load-xml("div", $id, $volume)
return
    if ($xml) then
        let $parent := $xml/ancestor::tei:div[not(*[1] instance of element(tei:div))][1]
        let $prevDiv := $xml/preceding::tei:div[1]
        let $prev := pages:get-previous(if ($parent and (empty($prevDiv) or $xml/.. >> $prevDiv)) then $xml/.. else $prevDiv)
        let $next := pages:get-next($xml)
        let $html := pages:process-content($config:odd, pages:get-content($xml))
        let $doc := replace($volume, "^.*/([^/]+)$", "$1")
        return
            map {
                "doc": $doc,
                "odd": $config:odd,
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
                "persons": <ul>{app:get-persons($xml, distinct-values($xml//tei:persName/@corresp))}</ul>,
                "gloss": <ul>{app:get-gloss($xml, distinct-values($xml//tei:gloss/@target))}</ul>,
                "content": $html
            }
    else
        map { "error": "Not found" }