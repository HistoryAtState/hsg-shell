xquery version "3.0";

module namespace fh = "http://history.state.gov/ns/site/hsg/frus-html";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace toc="http://history.state.gov/ns/site/hsg/frus-toc-html" at "frus-toc-html.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare
    %templates:wrap
function fh:volumes($node as node(), $model as map(*), $volume as xs:string?) {
    $node/*,
    for $vol in collection($config:FRUS_VOLUMES_COL)/tei:TEI[.//tei:body/tei:div]
    let $vol-id := substring-before(util:document-name($vol), '.xml')
    let $volume-metadata := collection($config:FRUS_METADATA_COL)/volume[@id = $vol-id]
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
function fh:administrations($node as node(), $model as map(*), $volume as xs:string?) {
    $node/*,
    let $published-vols := collection($config:FRUS_METADATA_COL)//volume[publication-status eq 'published']
    let $administrations := distinct-values($published-vols//administration)
    let $code-table-items := doc($config:FRUS_CODE_TABLES_COL || '/administration-code-table.xml')//item[value = $administrations]
    let $choices :=
        for $admins in $code-table-items
        let $adminname := $admins/*:label
        let $admincode := $admins/*:value
        let $selected := if ($admincode = $volume) then attribute selected {"selected"} else ()
        return 
            element option { 
                attribute value { "$app/historicaldocuments/" || $admincode },
                $selected,
                element label {$adminname/string()}
            }
    return $choices
};

(: BEGIN: administration.html :)
declare
    %templates:wrap
function fh:load-administration($node as node(), $model as map(*), $volume as xs:string) {
    let $admin := doc($config:FRUS_CODE_TABLES_COL || '/administration-code-table.xml')//item[value = $volume]
    let $published-vols-in-admin := collection($config:FRUS_METADATA_COL)//volume[administration eq $volume][publication-status eq 'published']
    let $grouping-codes := doc($config:FRUS_CODE_TABLES_COL || '/grouping-code-table.xml')//item
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
function fh:group-info($node as node(), $model as map(*)) {
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
function fh:administration-name($node as node(), $model as map(*)) {
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
function fh:volumes-by-administration-group($node as node(), $model as map(*)) {
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
function fh:volumes-by-administration($node as node(), $model as map(*)) {
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
function fh:volumes-pre-truman($node as node(), $model as map(*)) {
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
function fh:volumes-by-group($node as node(), $model as map(*)) {
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
function fh:series-title($node as node(), $model as map(*)) {
    $model?series-title
};

declare
    %templates:wrap
function fh:series-volumes($node as node(), $model as map(*)) {
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
function fh:volume-title($node as node(), $model as map(*)) {
    $model?title
};

declare
    %templates:wrap
function fh:administration-group-code($node as node(), $model as map(*)) {
    $model?grouping-codes[value = $model?group]/label/string()
};

(: END: administration.html :)

declare
    %templates:wrap
function fh:facets($node as node(), $model as map(*)) {
    map {
        "persons": distinct-values($model?data//tei:persName/@corresp),
        "gloss": distinct-values($model?data//tei:gloss/@target)
    }
};

declare
    %templates:wrap
function fh:view-persons($node as node(), $model as map(*)) {
    fh:get-persons($model?data, $model?persons)
};

declare function fh:get-persons($root as element(), $ids as xs:string*) {
    let $persons := $root/ancestor-or-self::tei:TEI/id("persons")
    for $id in $ids
    let $name := $persons//tei:persName[@xml:id = substring($id, 2)]
    order by $name
    return
        <a href="persons{$id}" class="list-group-item" data-toggle="tooltip" title="{normalize-space(string-join($name/../following-sibling::text()))}">{$name/string()}</a>
};

declare
    %templates:wrap
function fh:view-gloss($node as node(), $model as map(*)) {
    fh:get-gloss($model?data, $model?gloss)
};

declare function fh:get-gloss($root as element(), $ids as xs:string*) {
    let $terms := $root/ancestor-or-self::tei:TEI/id("terms")
    for $id in $ids
    let $term := $terms//tei:term[@xml:id = substring($id, 2)]
    order by $term
    return
        <a href="terms{$id}" class="list-group-item" data-toggle="tooltip" title="{normalize-space(string-join($term/../following-sibling::text()))}">{$term/text()}</a>
};

declare function fh:volume-breadcrumb($node as node(), $model as map(*), $volume as xs:string, $id as xs:string?) {
    let $head := root($model?data)//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'complete']
    return <a href="{if ($id) then '../' else ()}{$volume}">{$node/@*, $head/string()}</a>
};

declare function fh:section-breadcrumb($node as node(), $model as map(*)) {
    let $div := $model?data
    return
        <a href="{$div/@xml:id}">
        { $node/@* }
        { fh:breadcrumb-heading($div) }
        </a>
};

declare function fh:breadcrumb-heading($div as element()) {
    if ($div/@type eq 'document') then
        concat('Document ', $div/@n/string())
    else if ($div instance of element(tei:pb)) then 
        (: The following assumes that the pb is inside a document div. TODO: extend for pbs in front matter, etc.; 
           consider adding a sidebar linking back to document(s) that fall on the pb :)
        (:
        if ($div/ancestor::tei:div[@type eq 'document'][1]/tei:pb[1]/@n eq '1') then 
            concat('Document ', $div/ancestor::tei:div[@type eq 'document'][1]/@n/string(), ', Page ', $div/@n/string())
        else 
        :)
        concat('Page ', $div/@n/string())
    else 
        (: strip footnotes off of chapter titles - an Eisenhower phenomenon :)
        toc:toc-head($div/tei:head)
};

declare function fh:recent-publications($node, $model) {
    let $last-year := xs:string(year-from-date(current-date()) - 1)
    let $volumes := collection($config:FRUS_METADATA_COL)/volume[published-year ge $last-year]
    for $year in distinct-values($volumes/published-year)
    order by $year descending
    return
        <div>
            <h4>{$year}</h4>
            <ol>
                {
                for $volume in $volumes[published-year = $year]
                let $vol-id := $volume/@id
                let $title := substring-after($volume/title[@type eq 'complete']/text(), 'Foreign Relations of the United States, ')
                order by $vol-id
                return 
                    <li><a href="$app/historicaldocuments/{$vol-id}">{$title}</a></li>
                }
            </ol>
        </div>
};