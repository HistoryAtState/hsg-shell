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
function app:administrations($node as node(), $model as map(*), $volume as xs:string?) {
    $node/*,
    let $published-vols := collection($config:VOLUME_METADATA)//volume[publication-status eq 'published']
    let $administrations := distinct-values($published-vols//administration)
    let $code-table-items := doc('/db/cms/apps/volumes/code-tables/administration-code-table.xml')//item[value = $administrations]
    let $choices :=
        for $admins in $code-table-items
        let $adminname := $admins/*:label
        let $admincode := $admins/*:value
        let $selected := if ($admincode = $volume) then attribute selected {"selected"} else ()
        return 
            element option { 
                attribute value { "./historicaldocuments/" || $admincode },
                $selected,
                element label {$adminname/string()}
            }
    return $choices
};

(: BEGIN: administration.html :)
declare
    %templates:wrap
function app:load-administration($node as node(), $model as map(*), $volume as xs:string) {
    let $admin := doc('/db/cms/apps/volumes/code-tables/administration-code-table.xml')//item[value = $volume]
    let $published-vols-in-admin := collection('/db/cms/apps/volumes/data')//volume[administration eq $volume][publication-status eq 'published']
    let $grouping-codes := doc('/db/cms/apps/volumes/code-tables/grouping-code-table.xml')//item
    let $groupings-in-use := 
        for $g in distinct-values($published-vols-in-admin/grouping[@administration/tokenize(., '\s+') = $volume]) order by index-of($grouping-codes/value, $g) return $g
    return
        map {
            "admin-id": $volume,
            "admin": $admin,
            "published-vols": $published-vols-in-admin,
            "grouping-codes": $grouping-codes,
            "groupings-in-use": $groupings-in-use
        }
};

declare
    %templates:wrap
function app:group-info($node as node(), $model as map(*)) {
    if (count($model?groupings-in-use) gt 1) then
        <p>Volumes are grouped into {
            for $g at $n in $model?groupings-in-use 
            return (
                <a href="#{$g}-volumes">{$model?grouping-codes[value=$g]/label/string()}</a>,
                if ($n lt count($model?groupings-in-use)) then 
                    concat(
                        if (count($model?groupings-in-use) gt 2) then ', ' else (),
                        if ($n = count($model?groupings-in-use) - 1) then ' and ' else ()
                    )
                else ()
            )
        } categories.</p>
    else()
};

declare
    %templates:wrap
function app:administration-name($node as node(), $model as map(*)) {
    switch ($model?admin-id)
        case "pre-truman" return
            "Foreign Relations volumes covering the " || $model?admin/label/text() || " Period"
        case "nixon-ford" return
            'Nixon-Ford Administrations' 
        default return
            concat($model?admin/label, ' Administration')
};

declare
    %templates:wrap
function app:volumes-by-administration-group($node as node(), $model as map(*)) {
    if (count($model?groupings-in-use) gt 1 and $model?admin-id ne "pre-truman") then
        for $vols in $model?published-vols
        group by $grouping := $vols/grouping[@administration/tokenize(., '\s+') = $model?admin-id]
        order by index-of($model?grouping-codes/value, $grouping)
        return
            (: TODO: bug in templates.xql forces us to call templates:process manually :)
            templates:process($node/node(), map:new(($model,
                map {
                    "group": $grouping/string(),
                    "volumes": $vols
                }
            )))
    else
        ()
};

declare
    %templates:wrap
function app:volumes-by-administration($node as node(), $model as map(*)) {
    if (count($model?groupings-in-use) le 1 and $model?admin-id ne "pre-truman") then
        for $vols in $model?published-vols
        group by $subseries := $vols/title[@type='sub-series']
        order by $subseries/@n
        return
            (: TODO: bug in templates.xql forces us to call templates:process manually :)
            templates:process($node/node(), map:new(($model,
                map {
                    "series-title": $vols[1]/title[@type='sub-series']/string(),
                    "volumes": $vols
                }
            )))
    else
        ()
};

declare
    %templates:wrap
function app:volumes-pre-truman($node as node(), $model as map(*)) {
    if ($model?admin-id eq "pre-truman") then
        for $vol in $model?published-vols
        let $vol-id := $vol/@id
        let $voltext := $vol/title[@type="complete"]
        return
            templates:process($node/node(), map:new(($model,
                map {
                    "title": $voltext/string(),
                    "vol-id": $vol-id
                }
            )))
    else
        ()
};

declare
    %templates:wrap
function app:volumes-by-group($node as node(), $model as map(*)) {
    for $g-vols in $model?volumes
    group by $subseries := $g-vols/title[@type='sub-series']
    order by $subseries/@n
    return
        (: TODO: bug in templates.xql forces us to call templates:process manually :)
        templates:process($node/node(), map:new(($model,
            map {
                "series-title": $g-vols[1]/title[@type='sub-series']/string(),
                "volumes": $g-vols
            }
        )))
};

declare
    %templates:wrap
function app:series-title($node as node(), $model as map(*)) {
    $model?series-title
};

declare
    %templates:wrap
function app:series-volumes($node as node(), $model as map(*)) {
    for $vol in $model?volumes
    let $title := string-join(for $title in ($vol/title[@type='volume'], $vol/title[@type='volumenumber'])[. ne ''] return $title, ', ')
    let $vol-id := $vol/@id
    order by $vol-id
    return
        templates:process($node/node(), map:new(($model,
            map {
                "title": $title,
                "vol-id": $vol-id
            }
        )))
};

declare
    %templates:wrap
function app:volume-title($node as node(), $model as map(*)) {
    $model?title
};

declare
    %templates:wrap
function app:administration-group-code($node as node(), $model as map(*)) {
    $model?grouping-codes[value = $model?group]/label/string()
};

(: END: administration.html :)

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
        <a href="persons{$id}" class="list-group-item" data-toggle="tooltip" title="{normalize-space(string-join($name/../following-sibling::text()))}">{$name/string()}</a>
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
        <a href="terms{$id}" class="list-group-item" data-toggle="tooltip" title="{normalize-space(string-join($term/../following-sibling::text()))}">{$term/text()}</a>
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

declare function app:breadcrumb-heading($div as element()) {
    if ($div/@type eq 'document') then
        concat('Document ', $div/@n/string())
    else if ($div instance of element(tei:pb)) then 
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

declare function app:parse-params($node as node(), $model as map(*)) {
    element { node-name($node) } {
        for $attr in $node/@*
        return
            if (matches($attr, "\$\{[^\}]+\}")) then
                attribute { node-name($attr) } {
                    string-join(
                        let $parsed := analyze-string($attr, "\$\{([^\}]+?)(?:\:([^\}]+))?\}")
                        for $token in $parsed/node()
                        return
                            typeswitch($token)
                                case element(fn:non-match) return $token/string()
                                case element(fn:match) return
                                    let $paramName := $token/fn:group[1]
                                    let $default := $token/fn:group[2]
                                    return
                                        (request:get-parameter($paramName, $default), $model?($paramName))[1]
                                default return $token
                    )
                }
            else
                $attr,
        templates:process($node/node(), $model)
    }
};