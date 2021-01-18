xquery version "3.1";

(:~
 : Non-standard extension functions, mainly used for the documentation.
 :)
module namespace pmf="http://history.state.gov/ns/site/hsg/pmf-html";

import module namespace toc="http://history.state.gov/ns/site/hsg/frus-toc-html" at "frus-toc-html.xqm";
import module namespace hsg-config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function pmf:passthrough($config as map(*), $node as element(), $class as xs:string+) {
    $node
};

declare function pmf:table-heading($config as map(*), $node as element(), $class as xs:string+, $content) {
    <th class="{$class}">{$config?apply-children($config, $node, $content)}</th>
};

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

(: turn ref/@target into link.
 : TODO:
 : - extend to footnotes, e.g., #d3fn3, frus1948v01p1#d3fn1
 : - extend to persName id references - which should point to the persons div; terms; index references; etc.
 :)
declare function pmf:ref($config as map(*), $node as element(), $class as xs:string+, $content) {
    (: ToDO: Quick fix not sure where the origin is from :)
    let $target := data($node/@target)
    let $href :=
        if (starts-with($target, 'https://s3.amazonaws.com/static.history.state.gov') or starts-with($target, 'https://static.history.state.gov')) then
            $hsg-config:S3_URL || '/' || substring-after($target, 'gov/')

        (: generic: catch http, mailto links :)
        else if (starts-with($target, 'http') or starts-with($target, 'mailto')) then
            $target
        (: FRUS-specific conventions: pointer to a (different) frus volume :)
        else if (starts-with($target, 'frus')) then
            (: pointer to location within that volume :)
            if (contains($target, '#')) then
                toc:href("frus", substring-before($target, '#'), substring-after($target, '#'), ())
            (: pointer to that volume's landing page :)
            else
                toc:href("frus", $target, (), ())
        (: generic: pointer to location within document :)
        else if (starts-with($target, '#')) then
            let $docName := util:collection-name($node)
            let $publication-id := $hsg-config:PUBLICATION-COLLECTIONS?($docName)
            let $document-id := substring-before(util:document-name($node), '.xml')
            return
                toc:href($publication-id, $document-id, substring-after($target, '#'), ())
        else if (starts-with($target, "/")) then
            "$app" || $target
        else
            $target
    let $content := if ($content) then $content/string() else $href
    (: let $content := if ($node/node()) then $config?apply-children($config, $node, .) else $href :)
    return
        <a href="{$href}">{$content}</a>
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
