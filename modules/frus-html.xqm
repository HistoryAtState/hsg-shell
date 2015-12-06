xquery version "3.0";

module namespace fh = "http://history.state.gov/ns/site/hsg/frus-html";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace toc="http://history.state.gov/ns/site/hsg/frus-toc-html" at "frus-toc-html.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare
    %templates:wrap
function fh:volumes($node as node(), $model as map(*), $volume as xs:string?) {
    $node/*,
    for $vol in collection($config:FRUS_VOLUMES_COL)/tei:TEI[.//tei:body/tei:div]
    let $vol-id := substring-before(util:document-name($vol), '.xml')
    let $volume-metadata := $config:FRUS_METADATA/volume[@id = $vol-id]
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
            attribute value { "$app/historicaldocuments/" || $vol-id },
            $selected,
            $brief-title
        }</option>
};

declare
    %templates:wrap
function fh:administrations($node as node(), $model as map(*), $administration-id as xs:string?) {
    $node/*,
    let $published-vols := collection($config:FRUS_METADATA_COL)//volume[publication-status eq 'published']
    let $administrations := distinct-values($published-vols//administration)
    let $code-table-items := doc($config:FRUS_CODE_TABLES_COL || '/administration-code-table.xml')//item[value = $administrations]
    let $choices :=
        for $admins in $code-table-items
        let $adminname := $admins/*:label
        let $admincode := $admins/*:value
        let $selected := if ($admincode = $administration-id) then attribute selected {"selected"} else ()
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
function fh:load-administration($node as node(), $model as map(*), $administration-id as xs:string) {
    let $admin := doc($config:FRUS_CODE_TABLES_COL || '/administration-code-table.xml')//item[value = $administration-id]
    return
        if(empty($admin)) then
            (
            request:set-attribute("hsg-shell.errcode", 404),
            request:set-attribute("hsg-shell.path", string-join(($administration-id), "/")),
            error(QName("http://history.state.gov/ns/site/hsg", "not-found"), "administration " || $administration-id || " not found")
            )
    else
        let $published-vols-in-admin := collection($config:FRUS_METADATA_COL)//volume[administration eq $administration-id][publication-status eq 'published']
        let $grouping-codes := doc($config:FRUS_CODE_TABLES_COL || '/grouping-code-table.xml')//item
        let $groupings-in-use := 
            for $g in distinct-values($published-vols-in-admin/grouping[@administration/tokenize(., '\s+') = $administration-id]) order by index-of($grouping-codes/value, $g) return $g
        return
            map {
                "admin-id": $administration-id,
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
        "persons": 
            if ($model?data/@type=('compilation', 'chapter', 'subchapter')) then
                ()
            else
                distinct-values($model?data//tei:persName/@corresp),
        "gloss": 
            if ($model?data/@type=('compilation', 'chapter', 'subchapter')) then
                ()
            else
                distinct-values($model?data//tei:gloss/@target)
    }
};

declare
    %templates:wrap
function fh:view-persons($node as node(), $model as map(*)) {
    fh:get-persons($model?data, $model?persons)
};

declare function fh:get-persons($root as element(), $ids as xs:string*) {
    let $persons := $root/ancestor-or-self::tei:TEI/id("persons")
    for $idref in $ids
    let $id := substring($idref, 2)
    let $name := $persons/id($id)
(:    let $name := $persons//tei:persName[@xml:id = $id]:)
    order by $name
    return
        <a href="persons{$idref}" class="list-group-item" data-toggle="tooltip" title="{normalize-space(string-join($name/..//text()))}">{$name/string()}</a>
};

declare
    %templates:wrap
function fh:view-gloss($node as node(), $model as map(*)) {
    fh:get-gloss($model?data, $model?gloss)
};

declare function fh:get-gloss($root as element(), $ids as xs:string*) {
    let $terms := $root/ancestor-or-self::tei:TEI/id("terms")
    for $idref in $ids
    let $id := substring($idref, 2)
    let $term := $terms/id($id)
(:    let $term := $terms//tei:term[@xml:id = $id]:)
    order by $term
    return
        <a href="terms{$idref}" class="list-group-item" data-toggle="tooltip" title="{normalize-space(string-join($term/../following-sibling::text()))}">{$term/text()}</a>
};

declare function fh:volume-breadcrumb($node as node(), $model as map(*), $document-id as xs:string, $section-id as xs:string?) {
    let $head := root($model?data)//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'complete']
    return (
        <a href="{if ($section-id) then '../' else ()}{$document-id}">{$node/@*, $head/string()}</a>
    )
};

declare
    %templates:wrap
function fh:page-title($node as node(), $model as map(*)) {
    let $head := root($model?data)//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'complete']
    return
        $head/string()
};

declare function fh:section-breadcrumb($node as node(), $model as map(*)) {
    let $div := $model?data
    return
        <a href="{$div/@xml:id}">
        { $node/@* }
        { fh:breadcrumb-heading($model, $div) }
        </a>
};

declare function fh:breadcrumb-heading($model as map(*), $div as element()) {
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
        toc:toc-head($model, $div/tei:head)
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

declare function fh:current-year($node, $model) {
    year-from-date(current-date())
};

declare function fh:last-year($node, $model) {
    year-from-date(current-date()) - 1
};

declare function fh:next-year($node, $model) {
    year-from-date(current-date()) + 1
};

declare function fh:volumes-published-this-year($node, $model) {
    let $this-year := xs:string(year-from-date(current-date()))
    let $volumes := collection($config:FRUS_METADATA_COL)/volume[published-year ge $this-year]
    return
        fh:list-published-volumes($volumes)
};

declare function fh:volumes-published-this-year-count($node, $model) {
    let $this-year := xs:string(year-from-date(current-date()))
    let $volumes := collection($config:FRUS_METADATA_COL)/volume[published-year ge $this-year]
    return
        count($volumes)
};

declare function fh:volumes-published-last-year($node, $model) {
    let $last-year := xs:string(year-from-date(current-date()) - 1)
    let $volumes := collection($config:FRUS_METADATA_COL)/volume[published-year ge $last-year]
    return
        fh:list-published-volumes($volumes)
};

declare function fh:volumes-published-last-year-count($node, $model) {
    let $last-year := xs:string(year-from-date(current-date()) - 1)
    let $volumes := collection($config:FRUS_METADATA_COL)/volume[published-year ge $last-year]
    return
        count($volumes)
};

declare function fh:volumes-planned-for-publication-this-year($node, $model) {
    let $this-year := xs:string(year-from-date(current-date()))
    let $vols-planned-for-publication := collection($config:FRUS_METADATA_COL)/volume[publication-status ne 'published']
    let $vols-planned-for-publication-this-year := $vols-planned-for-publication[public-target-publication-year eq $this-year]
    return
        fh:list-planned-volumes($vols-planned-for-publication-this-year)
};

declare function fh:volumes-planned-for-publication-this-year-count($node, $model) {
    let $this-year := xs:string(year-from-date(current-date()))
    let $vols-planned-for-publication := collection($config:FRUS_METADATA_COL)/volume[publication-status ne 'published']
    let $vols-planned-for-publication-this-year := $vols-planned-for-publication[public-target-publication-year eq $this-year]
    return
        count($vols-planned-for-publication-this-year)
};

declare function fh:volumes-planned-next-year-beyond-in-production($node, $model) {
    let $this-year := xs:string(year-from-date(current-date()))
    let $vols-planned-next-year-beyond := collection($config:FRUS_METADATA_COL)/volume[public-target-publication-year ne xs:string($this-year)]
    let $vols-planned-next-year-beyond-in-production := $vols-planned-next-year-beyond[publication-status eq 'in-production']
    return
        fh:list-planned-volumes($vols-planned-next-year-beyond-in-production)
};

declare function fh:volumes-planned-next-year-beyond-in-production-count($node, $model) {
    let $this-year := xs:string(year-from-date(current-date()))
    let $vols-planned-next-year-beyond := collection($config:FRUS_METADATA_COL)/volume[public-target-publication-year ne xs:string($this-year)]
    let $vols-planned-next-year-beyond-in-production := $vols-planned-next-year-beyond[publication-status eq 'in-production']
    return
        count($vols-planned-next-year-beyond-in-production)
};

declare function fh:volumes-planned-next-year-beyond-under-declassification($node, $model) {
    let $this-year := xs:string(year-from-date(current-date()))
    let $vols-planned-next-year-beyond := collection($config:FRUS_METADATA_COL)/volume[public-target-publication-year ne xs:string($this-year)]
    let $vols-planned-next-year-beyond-under-declassification := $vols-planned-next-year-beyond[publication-status eq 'under-declassification']
    return
        fh:list-planned-volumes($vols-planned-next-year-beyond-under-declassification)
};

declare function fh:volumes-planned-next-year-beyond-under-declassification-count($node, $model) {
    let $this-year := xs:string(year-from-date(current-date()))
    let $vols-planned-next-year-beyond := collection($config:FRUS_METADATA_COL)/volume[public-target-publication-year ne xs:string($this-year)]
    let $vols-planned-next-year-beyond-under-declassification := $vols-planned-next-year-beyond[publication-status eq 'under-declassification']
    return
        count($vols-planned-next-year-beyond-under-declassification)
};

declare function fh:volumes-planned-next-year-beyond-being-researched-or-prepared($node, $model) {
    let $this-year := xs:string(year-from-date(current-date()))
    let $vols-planned-next-year-beyond := collection($config:FRUS_METADATA_COL)/volume[public-target-publication-year ne xs:string($this-year)]
    let $vols-planned-next-year-beyond-being-researched-or-prepared := $vols-planned-next-year-beyond[publication-status eq 'being-researched-or-prepared']
    return
        fh:list-planned-volumes($vols-planned-next-year-beyond-being-researched-or-prepared)
};

declare function fh:volumes-planned-next-year-beyond-being-researched-or-prepared-count($node, $model) {
    let $this-year := xs:string(year-from-date(current-date()))
    let $vols-planned-next-year-beyond := collection($config:FRUS_METADATA_COL)/volume[public-target-publication-year ne xs:string($this-year)]
    let $vols-planned-next-year-beyond-being-researched-or-prepared := $vols-planned-next-year-beyond[publication-status eq 'being-researched-or-prepared']
    return
        count($vols-planned-next-year-beyond-being-researched-or-prepared)
};

declare function fh:volumes-planned-next-year-beyond-being-planned-research-not-yet-begun($node, $model) {
    let $this-year := xs:string(year-from-date(current-date()))
    let $vols-planned-next-year-beyond := collection($config:FRUS_METADATA_COL)/volume[public-target-publication-year ne xs:string($this-year)]
    let $vols-planned-next-year-beyond-being-planned-research-not-yet-begun := $vols-planned-next-year-beyond[publication-status eq 'being-planned-research-not-yet-begun']
    return
        fh:list-planned-volumes($vols-planned-next-year-beyond-being-planned-research-not-yet-begun)
};

declare function fh:volumes-planned-next-year-beyond-being-planned-research-not-yet-begun-count($node, $model) {
    let $this-year := xs:string(year-from-date(current-date()))
    let $vols-planned-next-year-beyond := collection($config:FRUS_METADATA_COL)/volume[public-target-publication-year ne xs:string($this-year)]
    let $vols-planned-next-year-beyond-being-planned-research-not-yet-begun := $vols-planned-next-year-beyond[publication-status eq 'being-planned-research-not-yet-begun']
    return
        count($vols-planned-next-year-beyond-being-planned-research-not-yet-begun)
};

declare function fh:list-published-volumes($volumes) {
    <ol>{
        for $vol in $volumes
        let $vol-id := $vol/@id/string()
        let $vol-title := substring-after($vol/title[@type eq 'complete']/text(), 'Foreign Relations of the United States, ')
        let $published-date-raw := xs:date($vol/published-date)
        let $published-date := fh:published-date-to-english($published-date-raw)
        order by $published-date-raw
        return
            <li><a href="$app/historicaldocuments/{$vol-id}">{$vol-title}</a> ({$published-date})</li>
    }</ol>
};

declare function fh:list-planned-volumes($volumes) {
    <ol>{
        for $vol in $volumes
        let $vol-id := $vol/@id/string()
        let $vol-title := substring-after($vol/title[@type eq 'complete']/text(), 'Foreign Relations of the United States, ')
        order by $vol-id
        return
            <li>{$vol-title}</li>
    }</ol>
};

declare function fh:published-date-to-english($date as xs:date) {
    let $english-months := ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')
    let $published-month := $english-months[xs:integer(month-from-date($date))]
    let $published-date := concat($published-month, ' ', day-from-date($date))
    return 
        $published-date
};

declare function fh:volumes-with-ebooks() {
    for $hit in collection($config:HSG_S3_CACHE_COL || 'frus')//filename[ends-with(., '.epub')]
    return
        substring-before($hit, '.epub')
};

declare function fh:frus-ebooks-catalog($node, $model) {
    let $vol-ids := fh:volumes-with-ebooks()
    return
        <div xmlns="http://www.w3.org/1999/xhtml" id="catalog">
            <p>The following {count($vol-ids)} volumes are currently available:</p>
            {
            for $vol-id in $vol-ids
            order by $vol-id
            return
                (
                <div id="{$vol-id}">
                    <img src="http://static.history.state.gov/frus/{$vol-id}/covers/{$vol-id}-thumb.jpg" style="width: 67px; height: 100px; float: left; padding-right: 10px"/>
                    <a href="/historicaldocuments/{$vol-id}"><em>{fh:vol-title($vol-id, 'series')}</em>, {string-join((fh:vol-title($vol-id, 'subseries'), fh:vol-title($vol-id, 'volumenumber'), fh:vol-title($vol-id, 'volume')), ', ')}</a>. 
                        <br/>
                        Ebook last updated: {xsl:format-dateTime(xs:dateTime(fh:ebook-last-updated($vol-id)), 'MMMM D, YYYY')}. 
                        <ul class="buttons" style="text-align: right">
                            <li><a href="{fh:epub-url($vol-id)}">EPUB ({ try {fh:epub-size($vol-id)} catch * {'problem getting size of ' || $vol-id || '.epub'}})</a></li>
                            <li><a href="{fh:mobi-url($vol-id)}">Mobi ({ try {fh:mobi-size($vol-id)} catch * {'problem getting size of ' || $vol-id || '.mobi'}})</a></li>
                        </ul>
                </div>
                ,
                <hr class="space"/>
                )
            ,
            fh:frus-history-ebook-entry($model)
            ,
            <hr class="space"/>
            }
        </div>
};

declare function fh:frus-history-ebook-entry($model as map(*)) {
    let $book := doc('/db/apps/frus-history/monograph/frus-history.xml')
    let $book-title := pages:process-content($model?odd, $book//tei:title[@type='complete'])
    let $preview-edition := if ($book//tei:sourceDesc/tei:p[1] = 'Preview Edition') then ' (Preview Edition)' else ()
    let $vol-id := 'frus-history'
    let $s3-resources-col := concat($config:HSG_S3_CACHE_COL, $vol-id)
    let $s3-base-url := concat('http://static.history.state.gov/', $vol-id)
    let $epub-filename := concat($vol-id, '.epub')
    let $mobi-filename := concat($vol-id, '.mobi')
    let $pdf-filename := concat($vol-id, '.pdf')
    let $epub-url := concat($s3-base-url, '/ebooks/', $epub-filename)
    let $mobi-url := concat($s3-base-url, '/ebooks/', $mobi-filename)
    let $pdf-url := concat($s3-base-url, '/ebooks/', $pdf-filename)
    let $epub-resource := (doc(concat($s3-resources-col, '/ebooks/resources.xml'))//filename[. = $epub-filename]/parent::resource)[1]
    let $mobi-resource := (doc(concat($s3-resources-col, '/ebooks/resources.xml'))//filename[. = $mobi-filename]/parent::resource)[1]
    let $pdf-resource := (doc(concat($s3-resources-col, '/ebooks/resources.xml'))//filename[. = $pdf-filename]/parent::resource)[1]
    let $last-updated := $epub-resource/last-modified/string()
    let $epub-size := try { app:bytes-to-readable($epub-resource//size) } catch * {'problem getting size of ' || $epub-filename}
    let $mobi-size := try { app:bytes-to-readable($mobi-resource//size) } catch * {'problem getting size of ' || $mobi-filename}
    let $pdf-size := try { app:bytes-to-readable($pdf-resource//size) } catch * {'problem getting size of ' || $pdf-filename}
    return
        <div id="frus-history" xmlns="http://www.w3.org/1999/xhtml">
            <img src="{$s3-base-url}/covers/{$vol-id}-thumb.png" style="width: 67px; height: 100px; float: left; padding-right: 10px"/>
            <a href="/historicaldocuments/{$vol-id}">{$book-title}{$preview-edition}</a>.
                <br/>
                Ebook last updated: {xsl:format-dateTime(xs:dateTime($last-updated), 'MMMM D, YYYY')}. 
                <ul class="buttons" style="text-align: right">
                    <li><a href="{$epub-url}">EPUB ({$epub-size})</a></li>
                    <li><a href="{$mobi-url}">Mobi ({$mobi-size})</a></li>
                    <li><a href="{$mobi-url}">PDF ({$pdf-size})</a></li>
                </ul>
        </div>
};

declare function fh:exists-volume($vol-id) {
    exists(collection($config:FRUS_METADATA_COL)/volume[@id eq $vol-id])
};

declare function fh:exists-volume-in-db($vol-id) {
    exists(fh:volume($vol-id))
};

declare function fh:vol-title($vol-id as xs:string, $type as xs:string) {
	if (fh:exists-volume-in-db($vol-id)) then 
	    fh:volume($vol-id)//tei:title[@type = $type][1]/text()
    else 
        collection($config:FRUS_METADATA_COL)/volume[@id eq $vol-id]/title[@type eq $type]/text()
};

declare function fh:vol-title($vol-id as xs:string) {
	if (fh:exists-volume-in-db($vol-id)) then 
	    fh:volume($vol-id)//tei:title[@type = 'complete']/text()
    else 
        collection($config:FRUS_METADATA_COL)/volume[@id eq $vol-id]/title[@type eq 'complete']/text()
};

declare function fh:volume($vol-id as xs:string) {
    doc(concat($config:FRUS_VOLUMES_COL, '/', $vol-id, '.xml'))
};

declare function fh:ebook-last-updated($vol-id) {
    let $epub-filename := concat($vol-id, '.epub')
    let $epub := (doc(concat($config:HSG_S3_CACHE_COL, 'frus/', $vol-id, '/ebook/resources.xml'))//filename[ends-with(., '.epub')]/parent::resource)[1]
    return
        $epub/last-modified/string()
};

declare function fh:epub-size($vol-id) {
    let $epub := (doc(concat($config:HSG_S3_CACHE_COL, 'frus/', $vol-id, '/ebook/resources.xml'))//filename[ends-with(., '.epub')]/parent::resource)[1]
    let $size := $epub//size
    return
        app:bytes-to-readable($size)
};

declare function fh:mobi-size($vol-id) {
    let $mobi := (doc(concat($config:HSG_S3_CACHE_COL, 'frus/', $vol-id, '/ebook/resources.xml'))//filename[ends-with(., '.mobi')]/parent::resource)[1]
    let $size := $mobi//size
    return
        app:bytes-to-readable($size)
};

declare function fh:mobi-url($vol-id) {
	concat('//', $config:S3_DOMAIN, '/frus/', $vol-id, '/ebook/', $vol-id, '.mobi')
};

declare function fh:epub-url($vol-id) {
	concat('//', $config:S3_DOMAIN, '/frus/', $vol-id, '/ebook/', $vol-id, '.epub')
};