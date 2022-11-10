xquery version "3.1";

(:~
 : Template for shared tei features
 :)
module namespace tu="http://history.state.gov/ns/site/hsg/tei-util";

import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace expath="http://expath.org/ns/pkg";

declare function tu:get-next($div as element()) {
    if ($div/self::tei:pb) then
        $div/following::tei:pb[1]
    else if ($div/tei:div[@xml:id]) then
        $div/tei:div[@xml:id][1]
    else
        ($div/following::tei:div[@xml:id] except $div/id($config:IGNORED_DIVS))[1]
};

declare function tu:get-previous($div as element()?) {
    if ($div/self::tei:pb) then
        $div/preceding::tei:pb[1]
    else if (($div/preceding-sibling::tei:div[@xml:id] except $div/id($config:IGNORED_DIVS))[not(tei:div/@type)]) then
        ($div/preceding-sibling::tei:div[@xml:id] except $div/id($config:IGNORED_DIVS))[last()]
    else
        (
            $div/ancestor::tei:div[@type = ('compilation', 'chapter', 'subchapter', 'section', 'part')][tei:div/@type][1],
            ($div/preceding::tei:div[@xml:id] except $div/id($config:IGNORED_DIVS))[1]
        )[1]
};