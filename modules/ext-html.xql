xquery version "3.1";

(:~
 : Non-standard extension functions, mainly used for the documentation.
 :)
module namespace pmf="http://history.state.gov/ns/site/hsg/pmf-html";

import module namespace toc="http://history.state.gov/ns/site/hsg/toc" at "toc.xql";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function pmf:list-from-items($config as map(*), $node as element(), $class as xs:string+, $content, $ordered) {
    if ($ordered) then
        <ol class="{$class}">
        {
            $content ! <li>{$config?apply-children($config, $node, .)}</li>
        }</ol>
    else
        <ul class="{$class}">
        {
            $content ! <li>{$config?apply-children($config, $node, .)}</li>
        }
        </ul>
};

declare function pmf:document-list($config as map(*), $node as element(), $class as xs:string+) {
    toc:document-list($config, $node, $class)
};