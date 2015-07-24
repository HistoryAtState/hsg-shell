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

declare function toc:toc-inner($root as node(), $show-heading as xs:boolean?) {
    <div class="toc-inner">
        { if ($show-heading) then <h2>{toc:volume-title($root, "volume")}</h2> else () }
        <ul>{
            toc:toc-passthru($root, ())
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
            let $href := attribute href { toc:href($node) }
            let $highlight := if ($node is $current) then 'highlight' else ()
            return
                <a class="{string-join(('toc-link', $highlight), ' ')}">
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
                    element {local-name(.)} {toc:remove-nodes-deep(./node(), $nodes-to-remove)}
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

(: construct link to a FRUS div :)
declare function toc:href($node as element(tei:div)) {
    let $volume := 
        (: TODO replace substring/util:document-name with root($node)/@xml:id when volumes conform to this :)
        substring-before(util:document-name($node), '.xml')
    let $id := $node/@xml:id
    return
        toc:href($volume, $id, ())
};

declare function toc:href($volume as xs:string, $id as xs:string*, $fragment as xs:string*) {
    concat(
        string-join(
            (
                (: use method from pages:app-root for the following 2 items :)
                request:get-context-path(),
                substring-after($config:app-root, "/db/"),
                (: hard code section url fragment :)
                'historicaldocuments',
                $volume,
                $id
            )
            ,
            '/')
        ,
        if ($fragment) then concat('#', $fragment) else ()
    )
};

declare function toc:document-list($config as map(*), $node as element(tei:div), $class) {
    let $head := $node/tei:head[1]
    let $head-sans-notes := toc:remove-nodes-deep($head, $head//tei:note)
    let $child-documents-to-show := $node/tei:div[@type='document']
    let $has-inner-sections := $node/tei:div[@type != 'document']
    return
        <div class="{$class}">
            <h3>{
                $config?apply-children($config, $node, $head-sans-notes)
                ,
                for $note in $head//tei:note
                return
                    <sup>{$note/@n/string()}</sup>
            }</h3>
            {
                for $note in $head//tei:note
                return
                    <p>{
                        if ($note/@n) then 
                            <sup>{concat($note/@n, '. ')}</sup> 
                        else 
                            ()
                        ,
                        if ($note) then $config?apply($config, $note) else ()
                    }</p>
            ,
            (: for example of chapter div without no documents but a child paragraph, see frus1952-54v08/comp3
                for an example of a subchapter div with a table, see frus1945Malta/ch8subch44 :)
            let $child-nodes := $node/node()
            let $first-head := index-of($child-nodes, $node/tei:head[1])
            let $first-div := index-of($child-nodes, $node/tei:div[1])
            let $nodes-to-render := subsequence($child-nodes, $first-head + 1, $first-div - $first-head - 1)
            return
                if ($nodes-to-render) then $config?apply($config, $nodes-to-render) else ()
            ,
            for $document in $child-documents-to-show
            let $docnumber := $document/@n
            let $docid := $document/@xml:id
            let $doctitle := $document/tei:head[1]
            let $doctitle-sans-note := toc:remove-nodes-deep($doctitle, $doctitle//tei:note)
            let $docsource := $document//tei:note[@type='source'][1]
            let $docdateline := subsequence($document//tei:dateline, 1, 1)
            let $docsummary := $document//tei:note[@type='summary']
            let $href := toc:href($document)
            return
                (
                <hr class="list"/>,
                <h4><a href="{$href}">{
                	(: show a bracketed document number for volumes that don't use document numbers :)
                	if (not(starts-with($document/tei:head, concat($docnumber, '.')))) then 
                		concat('[', $docnumber, '] ') 
                	else 
                		concat($docnumber, '. ')
                	, 
                	if ($doctitle-sans-note) then $config?apply($config, $doctitle-sans-note) else ()
                }</a></h4>,
                if ($docdateline) then <p class="dateline">{$config?apply($config, $docdateline)}</p> else (),
                if ($docsummary) then <p>{$config?apply($config, $docsummary)}</p> else (),
                if ($docsource) then <p class="sourcenote">{$config?apply($config, $docsource)}</p> else ()
                )
            ,
            if ($has-inner-sections) then
                (
                <hr/>
                ,
                <div>
                    <h4>Contents</h4>
                    <div style="padding-left: 1em">{toc:toc-inner($node, false())}</div>
                </div>
                )
            else ()
            }
        </div>
};