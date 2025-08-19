xquery version "3.1";

module namespace fh = "http://history.state.gov/ns/site/hsg/frus-html";

import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace toc="http://history.state.gov/ns/site/hsg/frus-toc-html" at "frus-toc-html.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

(: XPath for selecting only full text volumes:

    collection($config:FRUS_COL_VOLUMES)/tei:TEI[.//tei:body/tei:div]
:)

(: BEGIN: administration.html :)
declare
    %templates:wrap
function fh:load-administration($node as node(), $model as map(*), $administration-id as xs:string) {
    let $admin := doc($config:FRUS_COL_CODE_TABLES || '/frus-production.xml')/id($administration-id)
    return
        if(empty($admin)) then
            (
            request:set-attribute("hsg-shell.errcode", 404),
            request:set-attribute("hsg-shell.path", string-join(($administration-id), "/")),
            error(QName("http://history.state.gov/ns/site/hsg", "not-found"), "administration " || $administration-id || " not found")
            )
    else
        let $admin-keywords := collection($config:FRUS_COL_VOLUMES)//tei:keywords[@scheme eq "#frus-administration-coverage"]/tei:term[. eq $administration-id]
        let $vols-in-admin := $admin-keywords/root(.)/tei:TEI
        let $admin-refs := $admin-keywords/@xml:id ! ("#" || .)
        let $admin-production-tracks := $vols-in-admin//tei:keywords[@scheme eq "#frus-production-priority"]/tei:term[@corresp = $admin-refs]
        let $grouping-codes := doc($config:FRUS_COL_CODE_TABLES || '/frus-production.xml')/id("frus-production-tracks")
        let $groupings-in-use :=
            for $g in $admin-production-tracks
            group by $g
            order by index-of($grouping-codes/@xml:id, $g) 
            return $g
        return
            map {
                "admin-id": $administration-id,
                "admin": $admin,
                "vols-in-admin": $vols-in-admin,
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
                <a href="#{$g}-volumes">{$model?grouping-codes/id($g)/tei:catDesc/tei:term/string()}</a>,
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

declare function fh:administration-listing-note($node as node(), $model as map(*)) {
    if ($model?admin-id = ("lincoln", "johnson-a", "grant", "hayes", "garfield", "arthur", "cleveland-22", "harrison", "cleveland-24", "mckinley", "roosevelt-t", "taft", "wilson", "harding", "coolidge", "hoover", "roosevelt-fd", "truman", "kennedy")) then
        templates:process($node/p[@id = "pre-administration-based-subseries-note"], $model)
    else
        ()
        (: templates:process($node/p[@id = "administration-based-subseries-note"], $model) :)
};

declare
function fh:admin-search-href($node as node(), $model as map(*)) {
    let $admin-id := $model?admin-id
    let $president-n := index-of(doc($config:FRUS_COL_CODE_TABLES || "/frus-production.xml")/id("frus-administrations")/tei:category/@xml:id, $admin-id) + 14
    let $president := doc($config:TRAVELS_COL_PRESIDENTS || "/presidents.xml")//president[@n = $president-n]
    let $start := $president/took-office-date
    let $end := $president/left-office-date
    let $href := app:fix-href("$app/search?within=documents&amp;start-date=" || $start || "&amp;end-date=" || $end || "&amp;sort=date-asc")
    return
        element a { attribute href { $href }, templates:process($node/node(), $model) }
};

declare
    %templates:wrap
function fh:administration-name($node as node(), $model as map(*)) {
    $model?admin/tei:catDesc/tei:term/string()
};

declare
    %templates:wrap
function fh:volumes-by-administration-group($node as node(), $model as map(*)) {
    if (count($model?groupings-in-use) gt 1 and $model?admin-id ne "pre-truman") then
        for $vols in $model?vols-in-admin
        let $admin-keywords := $vols//tei:keywords[@scheme eq "#frus-administration-coverage"]/tei:term[. = $model?admin-id]
        let $admin-refs := $admin-keywords/@xml:id ! ("#" || .)
        group by $grouping := $vols//tei:keywords[@scheme eq "#frus-production-priority"]/tei:term[@corresp = $admin-refs]
        order by index-of($model?grouping-codes/tei:category/@xml:id, $grouping)
        return
            (: TODO: bug in templates.xql forces us to call templates:process manually :)
            templates:process($node/node(), map:merge(($model,
                map {
                    "group": $grouping/string(),
                    "volumes": $vols
                }
            ),  map{"duplicates": "use-last"}))
    else
        ()
};

declare
    %templates:wrap
function fh:volumes-by-administration($node as node(), $model as map(*)) {
    if (count($model?groupings-in-use) le 1 and $model?admin-id ne "pre-truman") then
        for $vols in $model?vols-in-admin
        group by $sub-series := normalize-space(string-join(($vols//tei:title[@type='series'], $vols//tei:title[@type='sub-series'])[. ne ""], ", "))
        order by $vols[1]//tei:title[@type='sub-series']/@n
        return
            (: TODO: bug in templates.xql forces us to call templates:process manually :)
            templates:process($node/node(), map:merge(($model,
                map {
                    "series-title": ($sub-series, "Other")[. ne ""][1],
                    "volumes": $vols
                }
            ),  map{"duplicates": "use-last"}))
    else
        ()
};

declare
    %templates:wrap
function fh:volumes-pre-truman($node as node(), $model as map(*)) {
    if ($model?admin-id eq "pre-truman") then
        for $vol in $model?vols-in-admin
        let $vol-id := $vol/@xml:id
        let $voltext := $vol//tei:title[@type eq "complete"]
        order by $vol-id
        return
            templates:process($node/node(), map:merge(($model,
                map {
                    "title": $voltext/string(),
                    "vol-id": $vol-id
                }
            ),  map{"duplicates": "use-last"}))
    else
        ()
};

declare
    %templates:wrap
function fh:volumes-by-group($node as node(), $model as map(*)) {
    for $g-vols in $model?volumes
    group by $sub-series := normalize-space(string-join(($g-vols//tei:title[@type='series'], $g-vols//tei:title[@type='sub-series'])[. ne ""], ", "))
    order by $g-vols[1]//tei:title[@type='sub-series']/@n
    return
        (: TODO: bug in templates.xql forces us to call templates:process manually :)
        templates:process($node/node(), map:merge(($model,
            map {
                "series-title": ($sub-series, "Other")[. ne ""][1],
                "volumes": $g-vols
            }
        ),  map{"duplicates": "use-last"}))
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
    let $title :=
        (: catch outliers like frus1918, which have no volume title or number :)
        if ($vol//tei:title[@type eq "volume"] eq "" and $vol//tei:title[@type eq "volume-number"] eq "") then
            $vol//tei:title[@type eq "sub-series"]
        else
            string-join(
                ($vol//tei:title[@type eq "volume-number"], $vol//tei:title[@type eq "volume"])[. ne ""],
                ', '
            )
    let $vol-id := $vol/@xml:id
    let $publication-status := $vol//tei:revisionDesc/@status
    order by $vol-id
    return
        templates:process($node/node(), map:merge(($model,
            map {
                "title": $title,
                "volume-sub-series": $vol//tei:title[@type eq "sub-series"]/string(),
                "volume-number": $vol//tei:title[@type eq "volume-number"]/string(),
                "volume-title": $vol//tei:title[@type eq "volume"]/string(),
                "vol-id": $vol-id,
                "publication-status": $publication-status/string()
            }
        ),  map{"duplicates": "use-last"}))
};

declare
    %templates:wrap
function fh:volume-title($node as node(), $model as map(*)) {
    $model?title
};

declare
    %templates:wrap
function fh:volume-title-new($node as node(), $model as map(*)) {
    $model?volume-title
};

declare
    %templates:wrap
function fh:volume-number($node as node(), $model as map(*)) {
    $model?volume-number
};

declare
    %templates:wrap
function fh:volume-sub-series($node as node(), $model as map(*)) {
    $model?volume-sub-series
};

declare
    %templates:wrap
function fh:volume-sub-series-and-number($node as node(), $model as map(*)) {
    string-join(($model?volume-sub-series, $model?volume-number)[. ne ""], ", ")
};


declare
    %templates:wrap
function fh:volume-id-value-attribute($node as node(), $model as map(*)) {
    attribute value { $model?document-id }
};


declare
    %templates:wrap
function fh:volume-availability-summary($node as node(), $model as map(*)) {
    let $volume-id := $model?vol-id
    let $full-text := if (fh:exists-volume-full-text($volume-id)) then 'Full Text' else ()
    let $ebook := if (fh:exists-epub($volume-id)) then 'Ebook' else ()
    let $pdf := if (fh:exists-pdf($volume-id)) then 'PDF' else ()
    let $publication-status := $model?publication-status
    let $publication-status-label := doc($config:FRUS_COL_CODE_TABLES || '/frus-production.xml')/id($publication-status)/tei:catDesc/tei:term/string()
    return
        <span class="hsg-status-notice">({
            concat(
                $publication-status-label,
                if ($full-text or $ebook or $pdf) then
                    concat(
                       ' and available in ',
                       string-join(($full-text, $ebook, $pdf), ', ')
                    )
                else
                    ()
            )
        })</span>
};

declare
    %templates:wrap
function fh:administration-group-code($node as node(), $model as map(*)) {
    $model?grouping-codes/id($model?group)/tei:catDesc/tei:term/string()
};

(: END: administration.html :)

declare
    %templates:wrap
function fh:facets($node as node(), $model as map(*)) {
    if ($model?data/@xml:id = "index") then
        ()
    else
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
    let $persName := $persons/id($id)
    let $following := 
        if ($persName/parent::tei:hi) then
            $persName/parent::tei:hi/following-sibling::node() 
        else 
            $persName/following-sibling::node()
    let $persDescription := 
        normalize-space(
            string-join(
                (
                    replace(subsequence($following, 1, 1), '^\s*,?\s+', ''),
                    subsequence($following, 2)
                )
            )
        )
    order by $persName
    return
        <a href="persons{$idref}" tabindex="0" class="list-group-item" data-toggle="tooltip" title="{$persDescription}">{$persName/string()}</a>
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
    let $following := 
        if ($term/parent::tei:hi) then
            $term/parent::tei:hi/following-sibling::node() 
        else 
            $term/following-sibling::node()
    let $termDescription := 
        normalize-space(
            string-join(
                (
                    replace(subsequence($following, 1, 1), '^\s*,?\s+', ''),
                    subsequence($following, 2)
                )
            )
        )
    order by $term
    return
        <a href="terms{$idref}" tabindex="0" class="list-group-item" data-toggle="tooltip" title="{$termDescription}">{$term/string()}</a>
};

declare function fh:volume-breadcrumb($node as node(), $model as map(*), $document-id as xs:string, $section-id as xs:string?) {
    let $title-tei := root($model?data)//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'complete']
    let $title-html := $model?odd($title-tei/node(), ())
    return (
        <a href="{if ($section-id) then '../' else ()}{$document-id}">{$node/@*, $title-html}</a>
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
        concat(
            switch ($div/@type) 
                (: for facsimile pbs, we can reliably determine the parent document :)
                case "facsimile" return 
                    let $next-sibling := $div/following-sibling::element()[1]
                    let $ancestor-div := $div/ancestor::tei:div[1]
                    return
                        if ($next-sibling/self::tei:div/@n) then
                            "Document " || $next-sibling/@n || " Facsimile "
                        else if ($ancestor-div/@n) then
                            "Document " || $ancestor-div/@n || " Facsimile "
                        else
                            "Facsimile "
                default return (), 
            'Page ', 
            $div/@n/string()
        )
    else
        (: strip footnotes off of chapter titles - an Eisenhower phenomenon :)
        toc:toc-head($model, $div/tei:head[1])
};

declare function fh:recent-publications($node, $model) {
    let $last-year := xs:string(year-from-date(current-date()) - 1)
    for $vol in collection($config:FRUS_COL_VOLUMES)//tei:change[@status eq "published" and @when ge $last-year]/root(.)/tei:TEI
    group by $year := max(($vol//tei:change/@when ! substring(., 1, 4)))
    order by $year descending
    return
        <div>
            <h4>{$year}</h4>
            <ol>
                {
                for $v in $vol
                let $vol-id := $v/@id
                let $title := substring-after($v//tei:title[@type eq 'complete']/text(), 'Foreign Relations of the United States, ')
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

declare 
    %templates:wrap
function fh:load-status-of-the-series($node, $model) {
    let $this-year := xs:string(year-from-date(current-date()))
    let $last-year := xs:string(year-from-date(current-date()) - 1)
    let $volumes-published-this-year := collection($config:FRUS_COL_VOLUMES)//tei:change[@status eq "published" and starts-with(@when, $this-year)]/root(.)/tei:TEI
    let $volumes-published-last-year := collection($config:FRUS_COL_VOLUMES)//tei:change[@status eq "published" and starts-with(@when, $last-year)]/root(.)/tei:TEI
    let $publications-anticipated-this-year := collection($config:FRUS_COL_VOLUMES)//tei:change[@status eq "being-cleared" and starts-with(@to, $this-year)]/root(.)/tei:TEI
    let $volumes-with-chapters-outstanding := collection($config:FRUS_COL_VOLUMES)//tei:revisionDesc[@status eq "partially-published"]/root(.)/tei:TEI
    let $volumes-being-cleared := collection($config:FRUS_COL_VOLUMES)//tei:change[@status eq "being-cleared"]/root(.)/tei:TEI
    let $volumes-being-researched := collection($config:FRUS_COL_VOLUMES)//tei:change[@status eq "being-researched"]/root(.)/tei:TEI
    let $volumes-planned := collection($config:FRUS_COL_VOLUMES)//tei:change[@status eq "planned"]/root(.)/tei:TEI
    let $volumes-being-digitized := collection($config:FRUS_COL_VOLUMES)//tei:revisionDesc[@status eq "being-digitized"]/root(.)/tei:TEI
    let $new-model-entries := map {
        "this-year": $this-year,
        "last-year": $last-year,
        "volumes-published-this-year": $volumes-published-this-year,
        "volumes-published-last-year": $volumes-published-last-year,
        "publications-anticipated-this-year": $publications-anticipated-this-year,
        "volumes-with-chapters-outstanding": $volumes-with-chapters-outstanding,
        "volumes-being-cleared": $volumes-being-cleared,
        "volumes-being-researched": $volumes-being-researched,
        "volumes-planned": $volumes-planned,
        "volumes-being-digitized": $volumes-being-digitized
    }
    let $set-attributes := map:for-each($new-model-entries, function ($key, $value) { if (exists($value)) then request:set-attribute("show-" || $key, true()) else () })        
    return
        (: TODO: bug in templates.xql forces us to call templates:process manually :)
        templates:process($node/node(), map:merge(($model, $new-model-entries), map { "duplicates": "use-last" }))
};

declare function fh:volumes-published-this-year($node, $model) {
    fh:list-published-volumes($model?volumes-published-this-year, $model?this-year)
};

declare function fh:volumes-published-last-year($node, $model) {
    fh:list-published-volumes($model?volumes-published-last-year, $model?last-year)
};

declare function fh:publications-anticipated-this-year($node, $model) {
    fh:list-anticipated-volumes($model?publications-anticipated-this-year)
};

declare function fh:volumes-being-cleared($node, $model) {
    fh:list-in-production-volumes($model?volumes-being-cleared)
};

declare function fh:volumes-being-researched($node, $model) {
    fh:list-in-production-volumes($model?volumes-being-researched)
};

declare function fh:volumes-planned($node, $model) {
    fh:list-in-production-volumes($model?volumes-planned)
};

declare function fh:volumes-being-digitized($node, $model) {
    fh:list-in-production-volumes($model?volumes-being-digitized)
};

declare function fh:list-published-volumes($volumes as element(tei:TEI)*, $year as xs:string?) {
    <ol>{
        for $vol in $volumes
        let $vol-id := $vol/@xml:id
        let $vol-title := substring-after($vol//tei:title[@type eq "complete"], "Foreign Relations of the United States, ")
        let $vol-published := $vol//tei:change[@corresp eq "#" || $vol-id]
        let $vol-published-date := fh:published-date-to-english(xs:date($vol-published/@when))
        let $chapters := $vol//tei:change[starts-with(@corresp, "#ch")]
        let $published-chapters := $chapters[@status eq "published"]
        let $not-published-chapters := $chapters[@status ne "published"]
        let $published-chapters-in-year := $published-chapters[starts-with(@when, $year)]
        return
            if (empty($chapters)) then
                <li><a href="$app/historicaldocuments/{$vol-id}">{$vol-title}</a> ({$vol-published-date})</li>
            else
                <li><a href="$app/historicaldocuments/{$vol-id}">{$vol-title}</a>
                    {
                        <ul style="list-style-type: disc">{
                            if (exists($year)) then
                                for $chapter in $published-chapters-in-year
                                let $div-id := substring-after($chapter/@corresp, "#")
                                let $title := $vol/id($div-id)/tei:head
                                let $published-date := fh:published-date-to-english(xs:date($chapter/@when))
                                return
                                    <li style="margin-bottom: 0px"><a href="$app/historicaldocuments/{$vol-id}/{$div-id}">{$title/string()}</a> ({$published-date})</li>
                            else
                                for $chapter in $published-chapters
                                let $div-id := substring-after($chapter/@corresp, "#")
                                let $title := $vol/id($div-id)/tei:head
                                return
                                    <li style="margin-bottom: 0px"><a href="$app/historicaldocuments/{$vol-id}/{$div-id}">{$title/string()}</a></li>
                        }</ul>
                    }
                </li>                
    }</ol>
};


declare function fh:list-anticipated-volumes($volumes) {
    <ol>{
        for $vol in $volumes
        let $vol-id := $vol/@xml:id
        let $vol-title-complete := $vol//tei:title[@type eq 'complete']/normalize-space(.)
        let $vol-title-to-show := 
            if (starts-with($vol-title-complete, 'Foreign Relations of the United States, ')) then
                substring-after($vol-title-complete, 'Foreign Relations of the United States, ')
            else
                $vol-title-complete
        let $chapters := $vol//tei:change[starts-with(@corresp, "#ch")]
        let $chapters-anticipated := $chapters[@status eq "being-cleared" and @to ne ""]
        order by $vol-id
        return
            if (empty($chapters)) then
                <li><a href="$app/historicaldocuments/{$vol-id}">{$vol-title-to-show}</a></li>
            else
                <li><a href="$app/historicaldocuments/{$vol-id}">{$vol-title-to-show}</a>
                    {
                        <ul style="list-style-type: disc">{
                            for $chapter in $chapters-anticipated
                            let $div-id := substring-after($chapter/@corresp, "#")
                            let $title := $vol/id($div-id)/tei:head
                            return
                                <li style="margin-bottom: 0px"><a href="$app/historicaldocuments/{$vol-id}/{$div-id}">{$title/string()}</a></li>
                        }</ul>
                    }
                </li>       
    }</ol>
};

declare function fh:list-in-production-volumes($volumes) {
    <ol>{
        for $vol in $volumes
        let $vol-id := $vol/@xml:id
        let $vol-title-complete := $vol//tei:title[@type eq 'complete']/normalize-space(.)
        let $vol-title-to-show := 
            if (starts-with($vol-title-complete, 'Foreign Relations of the United States, ')) then
                substring-after($vol-title-complete, 'Foreign Relations of the United States, ')
            else
                $vol-title-complete
        let $chapters := $vol//tei:change[starts-with(@corresp, "#ch")]
        let $chapters-anticipated := $chapters[@status eq "being-cleared"]
        order by $vol-id
        return
            if (empty($chapters)) then
                <li><a href="$app/historicaldocuments/{$vol-id}">{$vol-title-to-show}</a></li>
            else
                <li><a href="$app/historicaldocuments/{$vol-id}">{$vol-title-to-show}</a>
                    {
                        <ul style="list-style-type: disc">{
                            for $chapter in $chapters-anticipated
                            let $div-id := substring-after($chapter/@corresp, "#")
                            let $title := $vol/id($div-id)/tei:head
                            return
                                <li style="margin-bottom: 0px"><a href="$app/historicaldocuments/{$vol-id}/{$div-id}">{$title/string()}</a></li>
                        }</ul>
                    }
                </li>       
    }</ol>
};

declare function fh:volumes-with-chapters-outstanding($node, $model) {
    <table class="hsg-table-bordered" style="width: 100%">
        <thead>
            <tr>
                <th>Volume title</th>
                <th>Chapters in Clearance</th>
                <th>Chapters Published</th>
            </tr>
        </thead>
        <tbody>{
            for $vol in $model?volumes-with-chapters-outstanding
            let $vol-id := $vol/@xml:id
            let $vol-title := substring-after($vol//tei:title[@type eq "complete"], "Foreign Relations of the United States, ")
            let $chapters-in-clearance := $vol//tei:change[@status eq "being-cleared"]
            let $chapters-published := $vol//tei:change[@status eq "published"]
            order by $vol-id
            return
                <tr>
                    <td style="vertical-align: top"><a href="$app/historicaldocuments/{$vol-id}">{$vol-title}</a></td>
                    <td style="vertical-align: top">{
                        for $chapter-group in $chapters-in-clearance
                        group by $year := $chapter-group/@from/string()
                        return
                            <div>
                                <u>{$year}</u>
                                <ul>{
                                    for $chapter in $chapter-group
                                    let $div-id := substring-after($chapter/@corresp, "#")
                                    let $div := $vol/id($div-id)
                                    where $div instance of element(tei:div)
                                    return
                                        <li style="margin-bottom: 0px"><a href="$app/historicaldocuments/{$vol-id}/{$div-id}">{$div/tei:head/string()}</a></li>
                                }</ul>
                            </div>
                    }</td>
                    <td style="vertical-align: top">{
                        for $chapter-group in $chapters-published
                        group by $year := substring($chapter-group/@when, 1, 4)
                        return
                            <div>
                                <u>{$year}</u>
                                <ul>{
                                    for $chapter in $chapter-group
                                    let $div-id := substring-after($chapter/@corresp, "#")
                                    let $div := $vol/id($div-id)
                                    where $div instance of element(tei:div)
                                    return
                                        <li style="margin-bottom: 0px"><a href="$app/historicaldocuments/{$vol-id}/{$div-id}">{$div/tei:head/string()}</a></li>
                                }</ul>
                            </div>
                    }</td>
                </tr>
        }</tbody>
    </table>
};

declare function fh:published-date-to-english($date as xs:date) {
    let $english-months := ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')
    let $published-month := $english-months[xs:integer(month-from-date($date))]
    let $published-date := concat($published-month, ' ', day-from-date($date))
    return
        $published-date
};

declare function fh:volumes-with-ebooks() {
    for $hit in collection($config:FRUS_COL_VOLUMES)//tei:relatedItem[@type eq "epub"]
    return
        root($hit)/tei:TEI/@xml:id/string()
};

declare function fh:frus-ebooks-catalog($node, $model) {
    let $vol-ids := fh:volumes-with-ebooks()
    return
        <div id="catalog">
            <p>The following {count($vol-ids) + 1} volumes are currently available:</p>
            {
            for $vol-id in $vol-ids
            order by $vol-id
            return
                (
                <div id="{$vol-id}">
                    <img src="{$config:S3_URL}/frus/{$vol-id}/covers/{$vol-id}-thumb.jpg" style="width: 67px; height: 100px; float: left; padding-right: 10px"/>
                    <a href="$app/historicaldocuments/{$vol-id}">{let $series := fh:vol-title($vol-id, 'series') return if ($series) then (<em>{fh:vol-title($vol-id, 'series')}</em>, ", ") else (), string-join((fh:vol-title($vol-id, 'sub-series'), fh:vol-title($vol-id, 'volume-number'), fh:vol-title($vol-id, 'volume')), ', ')}</a>.
                    <p>Ebook last updated: {fh:ebook-last-updated($vol-id) => app:format-date-month-long-day-year()}</p>
                    <ul class="hsg-ebook-list">
                        <li><a class="hsg-link-button" href="{fh:epub-url($vol-id)}">EPUB ({ try {fh:epub-size($vol-id)} catch * {'problem getting size of ' || $vol-id || '.epub'}})</a></li>
                        <li><a class="hsg-link-button" href="{fh:mobi-url($vol-id)}">Mobi ({ try {fh:mobi-size($vol-id)} catch * {'problem getting size of ' || $vol-id || '.mobi'}})</a></li>
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
    let $s3-base-url := concat($config:S3_URL, '/frus-history')
    let $relatedItems := $book//tei:relatedItem
    let $epub-item := $relatedItems[@type eq "epub"]
    let $mobi-item := $relatedItems[@type eq "mobi"]
    let $pdf-item := $relatedItems[@type eq "pdf"]
    let $epub-url := $epub-item//tei:ref/@target
    let $mobi-url := $mobi-item//tei:ref/@target
    let $pdf-url := $pdf-item//tei:ref/@target
    let $last-updated := $epub-item//tei:date/@when
    let $epub-size := app:bytes-to-readable($epub-item//tei:measure/@quantity)
    let $mobi-size := app:bytes-to-readable($mobi-item//tei:measure/@quantity)
    let $pdf-size := app:bytes-to-readable($pdf-item//tei:measure/@quantity)
    return
        <div id="frus-history">
            <img src="{$s3-base-url}/covers/frus-history-thumb.png" style="width: 67px; height: 100px; float: left; padding-right: 10px"/>
            <a href="$app/historicaldocuments/frus-history">{$book-title}</a>
            <p>Ebook last updated: {format-dateTime(xs:dateTime($last-updated), '[MNn] [D], [Y0001]', 'en', (), 'US')}.</p>
            <ul class="hsg-ebook-list">
                <li><a class="hsg-link-button" href="{$epub-url}">EPUB ({$epub-size})</a></li>
                <li><a class="hsg-link-button" href="{$mobi-url}">Mobi ({$mobi-size})</a></li>
                <li><a class="hsg-link-button" href="{$pdf-url}">PDF ({$pdf-size})</a></li>
            </ul>
        </div>
};

declare function fh:exists-volume($vol-id) {
    exists(collection($config:FRUS_COL_VOLUMES)/tei:TEI[@xml:id eq $vol-id])
};

declare function fh:exists-volume-full-text($vol-id) {
    exists(fh:volume($vol-id)/tei:TEI/tei:text/tei:body/tei:div)
};

declare function fh:exists-epub($vol-id) {
    exists(doc($config:FRUS_COL_VOLUMES || "/" || $vol-id || ".xml")//tei:relatedItem[@corresp eq "#" || $vol-id and @type eq "epub"])
};

declare function fh:exists-mobi($vol-id) {
    exists(doc($config:FRUS_COL_VOLUMES || "/" || $vol-id || ".xml")//tei:relatedItem[@corresp eq "#" || $vol-id and @type eq "mobi"])
};

declare function fh:exists-pdf($vol-id) {
    exists(doc($config:FRUS_COL_VOLUMES || "/" || $vol-id || ".xml")//tei:relatedItem[@corresp eq "#" || $vol-id and @type eq "pdf"])
};

declare function fh:exists-cover-image($vol-id) {
    exists(doc($config:FRUS_COL_VOLUMES || "/" || $vol-id || ".xml")//tei:relatedItem[@corresp eq "#" || $vol-id and @type eq "jpg"])
};

declare function fh:vol-title($vol-id as xs:string, $type as xs:string) {
	fh:volume($vol-id)//tei:title[@type eq $type]/node()
};

declare function fh:vol-title($vol-id as xs:string) {
	fh:vol-title($vol-id, "complete")
};

declare function fh:volume($vol-id as xs:string) {
    doc(concat($config:FRUS_COL_VOLUMES, '/', $vol-id, '.xml'))/tei:TEI
};

declare function fh:ebook-last-updated($vol-id) {
    let $epub := doc($config:FRUS_COL_VOLUMES || "/" || $vol-id || ".xml")//tei:relatedItem[@corresp eq "#" || $vol-id and @type eq "epub"]
    return
        $epub//tei:date/@when
};

declare function fh:epub-size($vol-id) {
    let $epub := doc($config:FRUS_COL_VOLUMES || "/" || $vol-id || ".xml")//tei:relatedItem[@corresp eq "#" || $vol-id and @type eq "epub"]
    let $size := $epub//tei:measure/@quantity
    return
        app:bytes-to-readable($size)
};

declare function fh:mobi-size($vol-id) {
    let $mobi := doc($config:FRUS_COL_VOLUMES || "/" || $vol-id || ".xml")//tei:relatedItem[@corresp eq "#" || $vol-id and @type eq "mobi"]
    let $size := $mobi//tei:measure/@quantity
    return
        app:bytes-to-readable($size)
};

declare function fh:pdf-size($vol-id) {
    fh:pdf-size($vol-id, ())
};

declare function fh:pdf-size($vol-id, $section-id) {
    let $pdf:= 
        if (exists($section-id)) then
            doc($config:FRUS_COL_VOLUMES || "/" || $vol-id || ".xml")//tei:relatedItem[@corresp eq "#" || $section-id and @type eq "pdf"]
        else
            doc($config:FRUS_COL_VOLUMES || "/" || $vol-id || ".xml")//tei:relatedItem[@corresp eq "#" || $vol-id and @type eq "pdf"]
    let $size := $pdf//tei:measure/@quantity
    return
        app:bytes-to-readable($size)
};

declare
    %templates:wrap
function fh:epub-size($node as node(), $model as map(*), $document-id as xs:string) {
    fh:epub-size($document-id)
};

declare
    %templates:wrap
function fh:mobi-size($node as node(), $model as map(*), $document-id as xs:string) {
    fh:mobi-size($document-id)
};

declare
    %templates:wrap
function fh:pdf-size-templating($node as node(), $model as map(*), $document-id as xs:string) {
    fh:pdf-size($document-id)
};

declare
    %templates:wrap
function fh:pdf-size-templating($node as node(), $model as map(*), $document-id as xs:string, $section-id as xs:string?) {
    fh:pdf-size($document-id, $section-id)
};


declare function fh:mobi-url($document-id as xs:string) {
	doc($config:FRUS_COL_VOLUMES || "/" || $document-id || ".xml")//tei:relatedItem[@corresp eq "#" || $document-id and @type eq "mobi"]//tei:ref/@target
};

declare function fh:pdf-url($document-id as xs:string, $section-id as xs:string?) {
    if ($section-id) then
        doc($config:FRUS_COL_VOLUMES || "/" || $document-id || ".xml")//tei:relatedItem[@corresp eq "#" || $section-id and @type eq "pdf"]//tei:ref/@target
    else
        doc($config:FRUS_COL_VOLUMES || "/" || $document-id || ".xml")//tei:relatedItem[@corresp eq "#" || $document-id and @type eq "pdf"]//tei:ref/@target
};

declare function fh:epub-url($document-id as xs:string) {
	doc($config:FRUS_COL_VOLUMES || "/" || $document-id || ".xml")//tei:relatedItem[@corresp eq "#" || $document-id and @type eq "epub"]//tei:ref/@target
};

declare function fh:get-media-types($document-id) {
    (
        "epub"[fh:exists-epub($document-id)],
        "mobi"[fh:exists-mobi($document-id)],
        "pdf"[fh:exists-pdf($document-id)]
    )
};

declare
    %templates:wrap
function fh:if-media-exists($node as node(), $model as map(*), $document-id as xs:string, $section-id as xs:string?, $suffix as xs:string) {
    let $subcol := if ($suffix = ("pdf")) then "pdf" else "ebook"
    return
        if (fh:media-exists($document-id, $section-id, $suffix)) then
            templates:process($node/node(), $model)
        else
            ()
};

declare function fh:media-exists($document-id as xs:string, $section-id as xs:string?, $suffix as xs:string) {
    if (exists($section-id)) then
        exists(doc($config:FRUS_COL_VOLUMES || "/" || $document-id || ".xml")//tei:relatedItem[@corresp eq "#" || $section-id and @type eq $suffix])
    else
        exists(doc($config:FRUS_COL_VOLUMES || "/" || $document-id || ".xml")//tei:relatedItem[@corresp eq "#" || $document-id and @type eq $suffix])
};



declare
    %templates:wrap
function fh:epub-href-attribute($node as node(), $model as map(*), $document-id as xs:string) {
    attribute href { fh:epub-url($document-id) },
    templates:process($node/node(), $model)
};

declare
    %templates:wrap
function fh:mobi-href-attribute($node as node(), $model as map(*), $document-id as xs:string) {
    attribute href { fh:mobi-url($document-id) },
    templates:process($node/node(), $model)
};

declare
    %templates:wrap
function fh:pdf-href-attribute($node as node(), $model as map(*), $document-id as xs:string, $section-id as xs:string?) {
    attribute href { fh:pdf-url($document-id, $section-id) },
    templates:process($node/node(), $model)
};

declare function fh:isbn-link($node as node(), $model as map(*)) {
    let $isbns := root($model?data)//tei:idno[@type = ('isbn-10','isbn-13')]/text()
    return
        if (exists($isbns)) then
            <li class="hsg-list-group-item">
            Search your library for this volume via WorldCat
            {
                for $isbn at $count in $isbns
                return
                    <a href="http://www.worldcat.org/search?q=isbn%3A{$isbn}">[{$count}]</a>
            }
            </li>
        else
            ()
};

declare
    %templates:wrap
function fh:hide-download-if-empty($node as node(), $model as map(*), $document-id as xs:string, $section-id as xs:string?) {
    if (fh:media-exists($document-id, $section-id, "pdf") or fh:media-exists($document-id, $section-id, "epub") or fh:media-exists($document-id, $section-id, "mobi")) then
        templates:process($node/node(), $model)
    else
        attribute style { "display: none" }
};

declare
    %templates:wrap
function fh:hide-tags-if-empty($node as node(), $model as map(*)) {
    if (exists($model?tags)) then
        templates:process($node/node(), $model)
    else
        attribute style { "display: none" }
};

declare
    %templates:wrap
function fh:show-if-tei-document ($node as node(), $model as map(*)) {
    (: searchable volumes must have a tei:text node :)
    if (root($model?data)//tei:body/tei:div) then
        templates:process($node/node(), $model)
    else
        attribute style { "display: none" }
};

(:~
 : Get the publication status of a document
 : @param $document-id The document ID
 : @return Returns the publication-status of a document as a string
 :)
declare function fh:publication-status ($document-id) {
    collection($config:FRUS_COL_VOLUMES)/tei:TEI[@xml:id eq $document-id]//tei:revisionDesc/@status/string()
};

(:~
 : Get the URL of a referenced document
 : @param $document-id The document ID
 : @return Returns the URL of an external link as HTML
 :)
declare function fh:location-url ($document-id) {
    (: commented out until we resolve external links; this data is only in the old bibliography files :)
    (:
    for $external-link in collection($config:FRUS_COL_METADATA)/volume[@id eq $document-id]/external-location
        let $link := $external-link/string()
        return
            if ($link) then
                switch ($external-link/@loc)
                    case "madison" return
                        <a href="{$link}" title="Opens an external link to the University of Wisconsin-Madison" target="_blank">University of Wisconsin-Madison</a>
                    case "worldcat" return
                        <a href="{$link}" title="Opens an external link to WorldCat" target="_blank">WorldCat</a>
                    default return ()
            else()
    :)
    ()
};

(:
 :  Return the URL of the cover of a frus volume (if available)
 :)

declare function fh:cover-uri($id) {
    let $has-cover-image := fh:exists-cover-image($id)
    return if ($has-cover-image) then 
        'https://static.history.state.gov/frus/' || $id || '/covers/' || $id || '.jpg'
    else ()
};

declare function fh:cover-img($img as element(img), $model) {
    let $src := fh:cover-uri($model?document-id)
    return if (exists($src)) then
        element img {
            $img/(@* except @data-template),
            attribute src { $src },
            attribute alt { 'Book Cover of ' || fh:vol-title($model?document-id) => normalize-space() }
        }
    else ()
};

(:~
 :  Render frus volume landing header:
 :  Replace content (except for the document title) with a notice, if the publication-status is "under-declassification".
 :  Show an external link to the referenced document, if the status is "published", but no TEI document is available.
 :  @param $node
 :  @param $model
 :  @return The header of the document as HTML
 :)
declare function fh:render-volume-landing($node as node(), $model as map(*)) {
    let $publication-status := fh:publication-status($model?document-id)
    let $externalLink := fh:location-url($model?document-id)
    let $not-published-status :=
        if ($publication-status = ('published', 'partially-published')) then
            ()
        else
            doc($config:FRUS_COL_CODE_TABLES || '/frus-production.xml')/id($publication-status)/tei:catDesc/tei:term/string()
    let $header :=  pages:header($node, map {
                            "data": <tei:TEI>
                            <tei:teiHeader>
                            <tei:fileDesc>
                            <tei:titleStmt>{ $model?data//tei:title }</tei:titleStmt>
                            </tei:fileDesc>
                            </tei:teiHeader>
                            </tei:TEI>,
                            "publication-id": $model?publication-id,
                            "document-id": $model?document-id,
                            "section-id": $model?section-id,
                            "view": $model?view,
                            "base-path": $model?base-path,
                            "odd": $model?odd
                        })
    return
        if ($not-published-status) then (
            $header,
            <p><strong>Note:</strong> As indicated on the
            <a href="$app/historicaldocuments/status-of-the-series">Status of the Series</a> page,
            the current status of this volume is “{$not-published-status}.”</p>
        )
        else if (root($model?data)//tei:div) then (
            pages:header($node, $model)
        )
            else (
                $header,
                if ($externalLink) then 
                    (
                    <p>This volume is available at the following location{if (count($externalLink) gt 1) then 's' else ()}:</p>
                    ,
                    <ul>{$externalLink ! <li>{.}</li>}</ul>
                    )
                else ()
            )
};

declare function fh:volume-landing-title($node as node(), $model as map(*)) {
    let $title := fh:vol-title($model?document-id) => normalize-space()
    return (
        element { node-name($node) } {
            $node/(@* except @data-template),
            $title
        }
    )
};
