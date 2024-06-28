xquery version "3.1";

(:~
 : Non-standard extension functions, mainly used for the documentation.
 :)
module namespace pmf="http://history.state.gov/ns/site/hsg/pmf-fo";

import module namespace print="http://www.tei-c.org/tei-simple/xquery/functions/fo";
import module namespace toc="http://history.state.gov/ns/site/hsg/frus-toc-html" at "frus-toc-html.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace fo="http://www.w3.org/1999/XSL/Format";

declare function pmf:list-from-items($config as map(*), $node as element(), $class as xs:string+, $content, $ordered) {
    if ($content) then
        let $label-length :=
            if ($node/tei:label) then
                max($node/tei:label ! string-length(.))
            else
                1
        return
            <fo:list-block provisional-distance-between-starts="{$label-length}em">
            {
                $content !
                    <fo:list-item>
                        <fo:list-item-label>
                        {
                            if (./preceding-sibling::tei:label) then
                                <fo:block>{$config?apply($config, ./preceding-sibling::tei:label[1])}</fo:block>
                            else
                                if ($ordered) then
                                    <fo:block>{count(./preceding-sibling::tei:item) + 1}.</fo:block>
                                else
                                    <fo:block>&#8226;</fo:block>
                        }
                        </fo:list-item-label>
                        <fo:list-item-body start-indent="body-start()">
                            <fo:block>{$config?apply-children($config, ., $content)}</fo:block>
                        </fo:list-item-body>
                    </fo:list-item>
            }
            </fo:list-block>
    else
        ()
};

(: turn ref/@target into link. TODO extend to footnotes, etc. :)
declare function pmf:ref($config as map(*), $node as element(), $class as xs:string+) {
    let $target := $node/@target
    let $href :=
        if (matches($target, '^http')) then
            $target
        else if (matches($target, '^frus')) then
            if (contains($target, '#')) then
                toc:href(substring-before($target, '#'), substring-after($target, '#'), (), ())
            else
                toc:href($target, (), (), ())
        else
            $target
    return
        <fo:basic-link external-destination="{$href}">
        {$config?apply-children($config, $node, .)}
        </fo:basic-link>
};
