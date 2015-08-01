xquery version "3.0";

module namespace app="http://history.state.gov/ns/site/hsg/templates";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pmu="http://www.tei-c.org/tei-simple/xquery/util" at "/db/apps/tei-simple/content/util.xql";
import module namespace odd="http://www.tei-c.org/tei-simple/odd2odd" at "/db/apps/tei-simple/content/odd2odd.xql";
import module namespace toc="http://history.state.gov/ns/site/hsg/toc" at "toc.xql";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare
    %templates:wrap
function app:volumes($node as node(), $model as map(*), $volume as xs:string?) {
    $node/*,
    for $vol in collection($config:VOLUMES_PATH)/tei:TEI[.//tei:body/tei:div]
    let $vol-id := substring-before(util:document-name($vol), '.xml')
    let $volume-metadata := collection($config:VOLUME_METADATA)/volume[@id = $vol-id]
    let $volume-title := $volume-metadata/title[@type='volume']
    let $volume-number := $volume-metadata/title[@type='volumenumber']
    let $sub-series-n := $volume-metadata/title[@type='sub-series']/@n
    let $brief-title := 
        if ($volume-number ne '') then 
            string-join(
                (
                $sub-series-n, 
                $volume-number, 
                replace($volume-title, '^The ', '')
                ), 
                ', ')
        else 
            string-join(
                (
                if (matches($sub-series-n, '[^\d–]')) then () else $sub-series-n, 
                replace($volume-title, '^The ', '')
                ), 
                ', ')
    let $selected := if ($vol-id = $volume) then attribute selected {"selected"} else ()
    order by $vol-id
    return
        <option>{ 
            attribute value { "./historicaldocuments/" || $vol-id },
            $selected,
            $brief-title
        }</option>
};

declare
    %templates:wrap
function app:administrations($node as node(), $model as map(*)) {
    $node/*,
    let $published-vols := collection($config:VOLUME_METADATA)//volume[publication-status eq 'published']
    let $administrations := distinct-values($published-vols//administration)
    let $code-table-items := doc('/db/cms/apps/volumes/code-tables/administration-code-table.xml')//item[value = $administrations]
    let $choices :=
        for $admins in $code-table-items
        let $adminname := $admins/*:label
        let $admincode := $admins/*:value
        return 
            element option { 
                attribute value { $admincode },
                element label {$adminname/string()}
            }
    return $choices
};

declare
    %templates:wrap
function app:hide-if-empty($node as node(), $model as map(*), $property as xs:string) {
        if (empty($model($property))) then
            attribute style { "display: none" }
        else
            (),
        templates:process($node/node(), $model)
};

declare
    %templates:wrap
function app:facets($node as node(), $model as map(*)) {
    map {
        "persons": distinct-values($model?data//tei:persName/@corresp),
        "gloss": distinct-values($model?data//tei:gloss/@target)
    }
};

declare
    %templates:wrap
function app:view-persons($node as node(), $model as map(*)) {
    app:get-persons($model?data, $model?persons)
};

declare function app:get-persons($root as element(), $ids as xs:string*) {
    let $persons := $root/ancestor-or-self::tei:TEI/id("persons")
    for $id in $ids
    let $name := $persons//tei:persName[@xml:id = substring($id, 2)]
    order by $name
    return
        <li><a href="persons{$id}" data-toggle="tooltip" title="{normalize-space(string-join($name/../following-sibling::text()))}">{$name/string()}</a></li>
};

declare
    %templates:wrap
function app:view-gloss($node as node(), $model as map(*)) {
    app:get-gloss($model?data, $model?gloss)
};

declare function app:get-gloss($root as element(), $ids as xs:string*) {
    let $terms := $root/ancestor-or-self::tei:TEI/id("terms")
    for $id in $ids
    let $term := $terms//tei:term[@xml:id = substring($id, 2)]
    order by $term
    return
        <li><a href="terms{$id}" data-toggle="tooltip" title="{normalize-space(string-join($term/../following-sibling::text()))}">{$term/text()}</a></li>
};

declare
    %templates:wrap
function app:countries($node as node(), $model as map(*), $country as xs:string?) {
    for $c in ('china', 'england', 'iran')
    let $selected := if ($c = $country) then attribute selected {"selected"} else ()
    let $brief-title := concat(upper-case(substring($c, 1, 1)), substring($c, 2))
    return
        <option>{ 
            attribute value { "./countries/" || $c },
            $selected,
            $brief-title
        }</option>
};

declare function app:uri($node as node(), $model as map(*)) {
    <code>{request:get-attribute("hsg-shell.path")}</code>
};

declare function app:volume-breadcrumb($node as node(), $model as map(*), $volume as xs:string) {
    let $head := root($model?data)//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'complete']
    return <a href="../{$volume}">{$node/@*, $head/string()}</a>
};

declare function app:section-breadcrumb($node as node(), $model as map(*)) {
    let $div := $model?data
    return
        <a href="{$div/@xml:id}">
        { $node/@* }
        { app:breadcrumb-heading($div) }
        </a>
};

declare function app:breadcrumb-heading($div as element(tei:div)) {
    if ($div/@type eq 'document') then
        concat('Document ', $div/@n/string())
    else if (local-name($div) eq 'pb') then 
        if ($div/ancestor::tei:div[@type eq 'document'][1]/tei:pb[1]/@n eq '1') then 
            concat('Document ', $div/ancestor::tei:div[@type eq 'document'][1]/@n/string(), ', Page ', $div/@n/string())
        else 
            concat('Page ', $div/@n/string())
    else 
        (: strip footnotes off of chapter titles - an Eisenhower phenomenon :)
        toc:toc-head($div/tei:head)
};

declare
    %templates:wrap
function app:handle-error($node as node(), $model as map(*), $code as xs:integer?) {
    let $errcode := request:get-attribute("hsg-shell.errcode")
    let $log := console:log("error: " || $errcode || " code: " || $code)
    return
        if ((empty($errcode) and empty($code)) or $code = $errcode) then
            templates:process($node/node(), $model)
        else
            ()
};