xquery version "3.0";

(:~
 : Template functions to render table of contents.
 :)
module namespace toc="http://history.state.gov/ns/site/hsg/toc";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pmu="http://www.tei-c.org/tei-simple/xquery/util" at "/db/apps/tei-simple/content/util.xql";
import module namespace odd="http://www.tei-c.org/tei-simple/odd2odd" at "/db/apps/tei-simple/content/odd2odd.xql";

declare
    %templates:wrap
function toc:table-of-contents($node as node(), $model as map(*), $volume as xs:string, $heading as xs:boolean?, $highlight as xs:boolean?) {
    toc:toc($model?data, $heading, $highlight)
};

declare function toc:toc($root as node(), $show-heading as xs:boolean?, $highlight as xs:boolean?) {
    <div class="toc-inner">
        { if ($show-heading) then <h2>{toc:volume-title($root, "volume")}</h2> else () }
        <ul>
        {
            toc:toc-passthru(
                $root/ancestor-or-self::tei:TEI/tei:text,
                if ($highlight) then $root/ancestor-or-self::tei:div[@type != "document"][1] else ()
            )
        }</ul>
    </div>
};

declare function toc:toc-passthru($node as item()*, $current as element()?) {
    let $divs := $node//tei:div[empty(ancestor::tei:div) or ancestor::tei:div[1] is $node]
    return
        $divs ! toc:toc-div(., $current)
};

declare function toc:volume-id($node as node()) {
    substring-before(util:document-name($node), '.xml')
};

declare function toc:volume-title($node as node(), $type as xs:string) as text()* {
    $node/ancestor::tei:TEI//tei:title[@type = $type][1]/text()
};

(: handles divs for TOCs :)
declare function toc:toc-div($node as element(tei:div), $current as element()?) {
    let $sections-to-suppress := ('toc')
    return
    (: we only show certain divs :)
    if (not($node/@xml:id = $sections-to-suppress) and not($node/@type = 'document')) then
        <li>
            {
            let $href := attribute href { $node/@xml:id }
            let $highlight := if ($node is $current) then 'highlight' else ()
            return
                <a class="toc-link {$highlight}">
                {
                    $href,
                    toc:toc-head($node/tei:head[1]) 
                }
                </a>
            ,
            
            if ($node/tei:div/@type = 'document') then
                concat(
                    ' (Document',
                    let $child-docs := $node/tei:div[@type = 'document']
                    let $first := $child-docs[1]/@n
                    let $last := $child-docs[last()]/@n
                    return
                        if ($first = $last) then
                            concat(' ', $first)
                        else
                            concat('s ', $first, '-', $last)
                    , ')'
                    )
            else 
                ()
            ,
            if ($node/tei:div/@type = 'document') then ()
            else
                <ul>
                {
                    toc:toc-passthru($node, $current)
                }
                </ul>
            }
        </li>
    else 
        ()
};

declare function toc:remove-nodes-deep($nodes as node()*, $nodes-to-remove as node()*) {
    $nodes ! (
        if (some $rn in $nodes-to-remove satisfies . is $rn) then
            ()
        else
            typeswitch (.)
                case element() return
                    toc:remove-nodes-deep(node(), $nodes-to-remove)
                default return
                    .
    )
};

(: handles heads for TOCs :)
declare function toc:toc-head($node as element(tei:head)) {
    let $head-sans-note := if ($node//tei:note) then toc:remove-nodes-deep($node, $node//tei:note) else $node
    return
        pmu:process(odd:get-compiled($config:odd-source, $config:odd, $config:odd-compiled), $head-sans-note/node(), 
            $config:odd-compiled, "web", "../generated", $config:module-config)
};