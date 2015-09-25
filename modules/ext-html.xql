xquery version "3.1";

(:~
 : Non-standard extension functions, mainly used for the documentation.
 :)
module namespace pmf="http://history.state.gov/ns/site/hsg/pmf-html";

import module namespace toc="http://history.state.gov/ns/site/hsg/frus-toc-html" at "frus-toc-html.xqm";

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

(: turn ref/@target into link. TODO extend to footnotes, e.g., #d3fn3, frus1948v01p1#d3fn1, etc. :)
declare function pmf:ref($config as map(*), $node as element(), $class as xs:string+) {
    let $target := $node/@target
    let $href :=
        if (matches($target, '^http')) then
            $target
        else if (matches($target, '^frus')) then
            if (contains($target, '#')) then
                toc:href(substring-before($target, '#'), substring-after($target, '#'), ())
            else
                toc:href($target, (), ())
        else if (starts-with($target, '#')) then
            toc:href(substring-before(util:document-name($node), '.xml'), substring-after($target, '#'), ())
        else
            $target
    return
        <a href="{$href}">{$config?apply-children($config, $node, .)}</a>
};

declare function pmf:note($config as map(*), $node as element(), $class as xs:string+, $content, $place, $label) {
    switch ($place)
        case "margin" return
            if ($label) then (
                <span class="margin-note-ref">{$label}</span>,
                <span class="margin-note">
                    <span class="n">{$label/string()}) </span>{ $config?apply-children($config, $node, $content) }
                </span>
            ) else
                <span class="margin-note">
                { $config?apply-children($config, $node, $content) }
                </span>
        default return
            let $id := translate(util:node-id($node), "-", "_")
            let $nr :=
                if ($label) then
                    $label
                else
                    count($node/preceding::tei:note) + 1
            return (
                <span id="fnref:{$id}">
                    <a class="note" rel="footnote" href="#fn:{$id}">
                    { $nr }
                    </a>
                </span>,
                <li class="footnote" id="fn:{$id}" value="{$nr}">
                    <span class="fn-content">
                        {$config?apply-children($config, $node, $content/node())}
                    </span>
                    <a class="fn-back" href="#fnref:{$id}">↩</a>
                </li>
            )
};