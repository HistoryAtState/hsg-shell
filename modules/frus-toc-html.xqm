xquery version "3.0";

(:~
 : Template functions to render table of contents.
 :)
module namespace toc="http://history.state.gov/ns/site/hsg/frus-toc-html";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

(:import module namespace pmu="http://www.tei-c.org/tei-simple/xquery/util" at "/db/apps/tei-simple/content/util.xql";:)
(:import module namespace odd="http://www.tei-c.org/tei-simple/odd2odd" at "/db/apps/tei-simple/content/odd2odd.xql";:)

declare variable $toc:ENTRIES_PER_PAGE := 30;

declare
    %templates:wrap
function toc:table-of-contents($node as node(), $model as map(*), $document-id as xs:string, $heading as xs:boolean?, $highlight as xs:boolean?) {
    (: check if document is stored in db or just generated TEI :)
    if (util:document-name($model?data)) then
        toc:toc($model, $model?data, $heading, $highlight)
    else
        ()
};

(: suppress attributes on the TOC div :)
declare
    %templates:wrap
function toc:table-of-contents-sidebar($node as node(), $model as map(*), $document-id as xs:string, $heading as xs:boolean?, $highlight as xs:boolean?) {
    let $toc := toc:table-of-contents($node, $model, $document-id, $heading, $highlight)
    let $head := ($toc/h2/node(), 'Table of Contents')[1]
    let $list := toc:prepare-sidebar-toc-list($toc/ul)
    return
        if ($toc) then
                <div class="hsg-panel">
                    <div class="hsg-panel-heading">
                        <h2 class="hsg-sidebar-title">{$head}</h2>
                    </div>
                    {
                        $list
                    }
                </div>
        else ()
};

declare function toc:prepare-sidebar-toc-list($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch ( $node )
            case element( ul ) return <ul class="hsg-list-group">{toc:prepare-sidebar-toc-list($node/node())}</ul>
            case element( li ) return <li class="hsg-list-group-item">{toc:prepare-sidebar-toc-list($node/node())}</li>
            default return $node
};

declare function toc:toc($model as map(*), $root as node()?, $show-heading as xs:boolean?, $highlight as xs:boolean?) {
    if ($root) then
        <div class="toc-inner">
            { if ($show-heading) then <div><h2>{toc:volume-title($root, "volume")}</h2></div> else () }
            <ul>
            {
                toc:toc-passthru(
                    $model,
                    $root/ancestor-or-self::tei:TEI/tei:text,
                    if ($highlight) then $root/ancestor-or-self::tei:div[@type != "document"][1] else ()
                )
            }</ul>
        </div>
    else
        ()
};

declare function toc:toc-inner($model as map(*), $root as node(), $show-heading as xs:boolean?) {
    <div class="toc-inner">
        { if ($show-heading) then <h2>{toc:volume-title($root, "volume")}</h2> else () }
        <ul>{
            toc:toc-passthru($model, $root, ())
        }</ul>
    </div>
};

declare function toc:toc-passthru($model as map(*), $node as item()*, $current as element()?) {
    (: Process immediate descendant divs, excluding nested ones :)
    let $divs := $node//tei:div[@xml:id] except $node//tei:div//tei:div
    let $divs :=
        (: in the sidebar table of contents, limit display to ancestors of the current div :)
        if ($current) then
            $divs intersect ($current/ancestor-or-self::tei:div, $node//tei:div[@xml:id][not(ancestor::tei:div)])
        else
            $divs
(:    let $divs := $node//tei:div[empty(ancestor::tei:div) or ancestor::tei:div[1] is $node]:)
    return
        $divs ! toc:toc-div($model, ., $current)
};

declare function toc:volume-id($node as node()) {
    substring-before(util:document-name($node), '.xml')
};

declare function toc:volume-title($node as node(), $type as xs:string) as text()* {
    $node/ancestor::tei:TEI//tei:title[@type = $type][1]/text()
};

(: handles divs for TOCs :)
declare function toc:toc-div($model as map(*), $node as element(tei:div), $current as element()?) {
    (: we only show certain divs :)
    for $node in $node[@xml:id != 'toc'][@type != 'document']
    let $descendant-docs := $node//tei:div[@type = 'document']
    return
        <li>
        {
            let $href := attribute href { toc:href($node) }
            let $highlight := if ($node is $current) then 'highlight' else ()
            (: .toc-link would trigger an ajax call, so only use this if we're not showing a
                reduced toc :)
            let $tocLink := if ($current) then () else 'toc-link'
            return
                <a class="{string-join(($tocLink, $highlight), ' ')}" id="toc-{$node/@xml:id}">
                {
                    $href,
                    toc:toc-head($model, $node/tei:head[1])
                }
                </a>
            ,

            if ($descendant-docs) then
                let $first := $child-docs[1]/@n
                let $last := $child-docs[last()]/@n
                let $document :=
                    if ($first = $last) then
                        concat(' ', $first)
                    else
                        concat('s ', $first, '-', $last)
                return
                    concat(' (Document', $document, ')')
            else 
                ()
            ,
            if ($node/tei:div/@xml:id) then
                <ul>
                {
                    toc:toc-passthru($model, $node, $current)
                }
                </ul>
            else 
                ()
        }
        </li>
};

(: handles heads for TOCs :)
declare function toc:toc-head($model as map(*), $node as element(tei:head)?) {
    if (empty($node)) then
        ()
    (: Check if we're called via tei-simple pm or templating :)
    else if (exists($model?apply-children)) then
        let $params := map:put($model?parameters, "omit-notes", true())
        return
            $model?apply-children(
                map:merge(($model, $params)),
                $node, $node/node())
    else
        $model?odd($node/node(), map { "omit-notes": true() })
};

(: construct link to a FRUS div :)
declare function toc:href($node as element(tei:div)) {
    let $publication-id := map:get($config:PUBLICATION-COLLECTIONS, util:collection-name($node))
    let $document-id :=
        (: TODO replace substring/util:document-name with root($node)/@xml:id when volumes conform to this :)
        substring-before(util:document-name($node), '.xml')
    let $section-id := $node/@xml:id
    return
        toc:href($publication-id, $document-id, $section-id, ())
};

declare function toc:href($publication-id as xs:string, $document-id as xs:string, $section-id as xs:string*, $fragment as xs:string*) {
        map:get($config:PUBLICATIONS, $publication-id)?html-href($document-id, $section-id)
        ,
        if ($fragment) then concat('#', $fragment) else ()
};

(:~
 : Generate table of contents for divs. Called via tei-simple pm.
 :)
declare function toc:document-list($config as map(*), $node as element(tei:div), $class) {
    let $start := xs:integer(request:get-parameter("start", 1))
    let $headConfig := map:merge(($config, map { "parameters": map:put($config?parameters, "omit-notes", true())}))
    let $head := $node/tei:head[1]
    let $child-documents := $node/tei:div[@type='document']
    let $child-document-count := count($child-documents)
    (: let $child-documents-to-show := $node/tei:div[@type='document'] :)
    let $child-documents-to-show := subsequence($child-documents, $start, $toc:ENTRIES_PER_PAGE)
    let $has-inner-sections := $node/tei:div[@type != 'document']
    return
        <div class="{$class}">
            <h3>{
                $config?apply-children($headConfig, $node, $head/node())
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
                        if ($note) then $config?apply($config, $note/node()) else ()
                    }</p>
                ,
                (: for example of chapter div without no documents but a child paragraph, see frus1952-54v08/comp3
                    for an example of a subchapter div with a table, see frus1945Malta/ch8subch44 :)
                let $child-nodes := $node/node()
                let $first-head := if ($node/tei:head) then index-of($child-nodes, $node/tei:head[1]) else 1
                let $first-div := if ($node/tei:div) then index-of($child-nodes, $node/tei:div[1]) else 1
                let $nodes-to-render := subsequence($child-nodes, $first-head + 1, $first-div - $first-head - 1)
                return
                    if ($nodes-to-render) then $config?apply($config, $nodes-to-render) else ()
                ,
                toc:paginate($child-document-count, $start)
                ,
                for $document in $child-documents-to-show
                let $docnumber := $document/@n
                let $doctitle := $document/tei:head[1]
                let $href := toc:href($document)
                return
                    <div>
                        <hr class="list"/>
                        <h4>
                            <!-- class="section-link" was triggering an extra ajax call -->
                            <a href="{$href}">
                            {
                            	(: show a bracketed document number for volumes that don't use document numbers :)
                            	if (not(starts-with($doctitle, concat($docnumber, '.')))) then
                            		concat('[', $docnumber, '] ')
                            	else
                            		()
                            	,
                            	if ($doctitle) then $config?apply($headConfig, $doctitle/node()) else ()
                            }
                            </a>
                        </h4>
                        {
                            (: some documents have child attachments; only the primary document's information should be shown in the document list :)
                            let $docdateline := ($document//tei:dateline)[1]
                            let $docsummary := ($document//tei:note[@type='summary'])[1]
                            let $docsource := ($document//tei:note[@type='source'])[1]
                            return
                                (
                                    (: the ODD puts datelines in a <div class="tei-dateline"> - right-aligned :)
                                    $docdateline ! $config?apply($config, .),
                                    (: prevent formatting the following as footnotes by descending to the child node :)
                                    $docsummary ! <p class="summary">{$config?apply($config, ./node())}</p>,
                                    $docsource ! <p class="sourcenote">{$config?apply($config, ./node())}</p>
                                )
                        }
                    </div>
                ,
                toc:paginate($child-document-count, $start)
                ,
                if ($has-inner-sections) then
                    (
                    <hr/>
                    ,
                    <div>
                        <h4>Contents</h4>
                        <div style="padding-left: 1em">
                            <div class="toc-inner">
                                <ul>{ toc:toc-inner($config, $node, false()) }</ul>
                            </div>
                        </div>
                    </div>
                    )
                else ()
        }
        </div>
};

declare function toc:paginate($child-document-count as xs:int, $start as xs:int) {
    if ($child-document-count > $toc:ENTRIES_PER_PAGE) then
        <ul class="pagination">
            <li class="{if ($start <= $toc:ENTRIES_PER_PAGE) then 'disabled' else ()}">
                <a href="?start={if ($start > 1) then $start - $toc:ENTRIES_PER_PAGE else 1}">
                    <i class="glyphicon glyphicon-backward"/>
                </a>
            </li>
        {
            for $page in 0 to ($child-document-count idiv $toc:ENTRIES_PER_PAGE -
                (if ($child-document-count mod $toc:ENTRIES_PER_PAGE = 0) then 1 else 0))
            return
                <li class="{if ($start idiv $toc:ENTRIES_PER_PAGE = $page) then 'active' else ()}">
                    <a href="?start={$page * $toc:ENTRIES_PER_PAGE + 1}">{$page + 1}</a>
                </li>
        }
            <li class="{if ($start + $toc:ENTRIES_PER_PAGE > $child-document-count) then 'disabled' else ()}">
                <a href="?start={if ($start + $toc:ENTRIES_PER_PAGE < $child-document-count) then $start + $toc:ENTRIES_PER_PAGE else $start}">
                    <i class="glyphicon glyphicon-forward"/>
                </a>
            </li>
        </ul>
    else
        ()
};
