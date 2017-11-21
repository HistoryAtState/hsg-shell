xquery version "3.0";

module namespace search = "http://history.state.gov/ns/site/hsg/search";

import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace pocom = "http://history.state.gov/ns/site/hsg/pocom-html" at "pocom-html.xqm";
import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace fh = "http://history.state.gov/ns/site/hsg/frus-html" at "frus-html.xqm";
import module namespace functx = "http://www.functx.com";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $search:MAX_HITS_SHOWN := 1000;

(: Maps search categories to publication ids, see $config:PUBLICATIONS :)
declare variable $search:SECTIONS := map {
    "documents": "frus",
    "department": (
        "short-history",
        "people",
        "buildings",
        "views-from-the-embassy",
        map {
            "id": "pocom",
            "query": function($query as xs:string) {
                collection($pocom:PEOPLE-COL)//persName[ft:query(., $query)]
            }
        },
        map {
            "id": "visits",
            "query": function($query as xs:string) {
                collection($config:VISITS_COL)//visit[ft:query(visitor, $query)]
                |
                collection($config:VISITS_COL)//visit[ft:query(description, $query)]
                |
                collection($config:VISITS_COL)//visit[ft:query(from, $query)]
            }
        },
        map {
            "id": "travels",
            "query": function($query as xs:string) {
                (
                collection($config:TRAVELS_COL)//trip[ft:query(name, $query)]
                |
                collection($config:TRAVELS_COL)//trip[ft:query(country, $query)]
                |
                collection($config:TRAVELS_COL)//trip[ft:query(remarks, $query)]
                |
                collection($config:TRAVELS_COL)//trip[ft:query(locale, $query)]
                )/parent::trips
            }
        }
    ),
    "milestones": "milestones",
    "countries": ("countries", "archives"),
    "conferences": "conferences",
    "edu": "education",
    "frus-history": "frus-history-monograph",
    "about": ("hac", "faq")
};

declare variable $search:DISPLAY := map {
    "persName": map {
        "title": function($name) {
            string-join(
                ($name/forename, $name/surname, $name/genName),
                ' '
            )
        },
        "summary": (),
        "href": function($name) {
            "$app/departmenthistory/people/" || $name/ancestor::person/id
        }
    },
    "visit": map {
        "title": function($visit) {
            "Visits By Foreign Leaders: " || string-join($visit/visitor, ", ")
        },
        "summary": (),
        "href": function($visit) {
            "$app/departmenthistory/visits/" || year-from-date($visit/start-date)
        }
    },
    "trips": map {
        "title": function($trips) {
            "Travels: " || string-join($trips/trip[1]/name, ", ")
        },
        "summary": function($trips) {
            let $expanded := util:expand($trips)
            let $trips-with-hits := $expanded//exist:match/ancestor::trip
            let $count := count($trips-with-hits)
            return
                <p>{$count || ' matching trip' || (if ($count gt 1) then 's' else ())}</p>
        },
        "href": function($trips) {
            "$app/departmenthistory/travels/" || $trips/trip[1]/@role || "/" || $trips/trip[1]/@who
        }
    }
};

declare function search:load-sections($node, $model) {
    let $content := map { "sections":
        (
            <section>
                <id>documents</id>
                <label>Historical Documents</label>
            </section>,
            <section>
                <id>department</id>
                <label>Department History</label>
            </section>,
            <section>
                <id>milestones</id>
                <label>Milestones</label>
            </section>,
            <section>
                <id>countries</id>
                <label>Countries</label>
            </section>,
            <section>
                <id>conferences</id>
                <label>Conferences</label>
            </section>,
            <section>
                <id>edu</id>
                <label>Educational Resources</label>
            </section>,
            <section>
                <id>frus-history</id>
                <label>History of the <em>Foreign Relations</em> Series</label>
            </section>,
            <section>
                <id>about</id>
                <label>About (FAQ, Advisory Committee Minutes)</label>
            </section>
        )
    }
    let $html := templates:process($node/*, map:new(($model, $content)))
    return
        $html
};

(: TODO: Replace this "old" function in templates with modularized functions and fix the markup accordingly:
<label> and <input> must not be nested! :)
declare
    %templates:wrap
function search:section-checkbox-value-attribute-and-title($node, $model, $within as xs:string*) {
    let $section-id := $model?section/id
    let $section-label := $model?section/label
    return
        (
            attribute value { $section-id },
            if (exists($within) and string-join($within) != "" and $section-id = $within) then
                attribute checked { "checked" }
            else (),
            <span class="c-indicator">{ $section-label/string() }</span>
        )
};

(: TODO: Apply more plausible condition, needs removing the general trigger name="within" attribute for all checkboxes :)
declare
    %templates:wrap
    %templates:default("scope", "entire_site")
function search:scope-checked($node, $model, $within as xs:string*) {
    if (exists($within) and string-join($within) != "" )
    then ()
    else
        attribute checked { 'checked' }
};

declare function search:load-volumes-within($node, $model, $volume-id as xs:string*) {
    let $content := map { "volumes":
        (
            for $v in $volume-id
            order by $v
            return
                <volume>
                    <id>{$v}</id>
                    <title>{fh:vol-title($v)}</title>
                </volume>
        )
    }
    let $html := templates:process($node/*, map:new(($model, $content)))
    return
        $html
};

declare
    %templates:wrap
function search:volume-checkbox-value-attribute-and-title($node, $model) {
    attribute value { $model?volume/id },
    $model?volume/title/string()
};

declare
    %templates:wrap
function search:select-volumes-link($node, $model, $q as xs:string?, $volume-id as xs:string*) {
    let $query-params :=
        string-join(
            (
                $q ! ("q=" || .),
                $volume-id ! ("volume-id=" || .)
            ),
            '&amp;'
        )
    let $query-string := $query-params ! ("?" || .)
    let $link := element a { attribute href {$node/@href || $query-string}, $node/@* except $node/@href, $node/node() }
    return
        app:fix-this-link($link, $model)
};

declare %private function search:filter-results($out, $in) {

    if (count($out) = $search:MAX_HITS_SHOWN or empty($in)) then
        $out
    else
        let $head := head($in)
        return
            typeswitch($head)
                case element(tei:div) return
                    search:filter-results(($out, $head[@xml:id][not(tei:div/@xml:id)]), tail($in))
                default return
                    search:filter-results(($out, $head), tail($in))
};

declare %private function search:filter($hits) {
    (:  Filter out matches which are in divs without xml:id or have a nested div.
        Limit the result set to MAX_HITS_SHOWN. :)
    let $limited :=
        subsequence(
            subsequence($hits, 1, $search:MAX_HITS_SHOWN * 2)[@xml:id][not(tei:div/@xml:id)]
            |
            subsequence($hits, 1, $search:MAX_HITS_SHOWN)[not(self::tei:div)],
            1, $search:MAX_HITS_SHOWN
        )
    (: Reorder the remaining hits by score :)
    for $hit in $limited
    order by ft:score($hit)
    return
        $hit
};

declare
    %templates:default("start", 1)
    %templates:default("per-page", 10)
    (:
    declare variable $search:SORTBY := 'relevance';
    declare variable $search:SORTORDER := 'descending';
    :)
function search:load-results($node, $model, $q as xs:string, $within as xs:string*,
$volume-id as xs:string*, $start as xs:integer, $per-page as xs:integer?) {
    let $start-time := util:system-time()
    let $hits := search:query-sections($within, $volume-id, $q)
    let $hits := search:filter($hits)
    let $end-time := util:system-time()
    let $ordered-hits :=
        for $hit in $hits
        order by ft:score($hit) descending
        return $hit
    let $hit-count := count($ordered-hits)
    let $window := subsequence($ordered-hits, $start, $per-page)
    let $query-info :=  map {
        "results": $window,
        "query-info": map {
            "q": $q,
            "within": $within,
            (: "volume-id": $volume-id, :)
            "start": $start,
            "end": $start + count($window) - 1,
            "perpage": $per-page,
            "result-count": $hit-count,
            "results-shown": count($hits),
            "query-duration": seconds-from-duration($end-time - $start-time)
        }
    }
    let $html := templates:process($node/*, map:new(($model, $query-info)))
    return
        $html
};

declare %private function search:query-sections($sections as xs:string*, $volume-ids as xs:string*,
    $query as xs:string) {
    if (exists($volume-ids)) then
        let $vols := for $volume-id in $volume-ids return collection($config:FRUS_VOLUMES_COL)/id($volume-id)
        return
            $vols//tei:div[ft:query(., $query)]
    else if (exists($sections) and $sections != "") then
        for $section in $sections
        for $category in $search:SECTIONS?($section)
        return
            search:query-section($category, $query)
    else
        map:for-each($search:SECTIONS, function($section, $categories) {
            for $category in $categories
            return
                search:query-section($category, $query)
        })
};

declare function search:query-section($category, $query as xs:string) {
    typeswitch($category)
        case xs:string return
            collection($config:PUBLICATIONS?($category)?collection)//tei:div[ft:query(., $query)]
        default return
            $category?query($query)
};

declare function search:result-heading($node, $model) {
    let $result := $model?result
    return
        typeswitch ($result)
            case element(tei:div) return
                let $publication-id := $config:PUBLICATION-COLLECTIONS?(util:collection-name($result))
                let $document-id := substring-before(util:document-name($result), '.xml')
                let $section-id := $result/@xml:id
                let $publication-config := map:get($config:PUBLICATIONS, $publication-id)
                let $section-heading :=
                    if ($section-id) then
                        $publication-config?select-section($document-id, $section-id)/tei:head[1] ! functx:remove-elements-deep(., 'note')
                    else
                        $result/tei:head[1] ! functx:remove-elements-deep(., 'note')
                let $document := $publication-config?select-document($document-id)
                let $document-heading := ($document//tei:title[@type='volume'], $document//tei:titleStmt/tei:title[@type = "short"])[1]
                let $result-heading := ($section-heading || ' (' || $document-heading || ')')
                return
                    $result-heading
            default return
                let $display := $search:DISPLAY?(local-name($result))
                return
                    if (exists($display)) then
                        $display?title($result)
                    else
                        "unknown title"
};

declare function search:result-summary($node, $model) {
    let $matches-to-highlight := 10
    let $result := $model?result
    return
        if ($result/@xml:id = 'index') then
            '[Back of book index: too many hits to display]'
        (: see if we've defined a custom function for displaying result summaries :)
        else if (map:contains($search:DISPLAY, local-name($result))) then
            let $summary := $search:DISPLAY?(local-name($result))?summary
            return
                typeswitch ($summary)
                    case function(*) return $summary($result)
                    default return
                        let $trimmed-hit := search:trim-matches(util:expand($result), $matches-to-highlight)
                        return
                            kwic:summarize($trimmed-hit, <config xmlns="" width="60"/>)/*
        else
            let $trimmed-hit := search:trim-matches(util:expand($result), $matches-to-highlight)
            return
                kwic:summarize($trimmed-hit, <config xmlns="" width="60"/>)/*
};

declare function search:result-link($node, $model) {
    let $result := $model?result
    let $href :=
        typeswitch ($result)
            case element(tei:div) return
                let $publication-id := $config:PUBLICATION-COLLECTIONS?(util:collection-name($result))
                let $document-id := substring-before(util:document-name($result), '.xml')
                let $section-id := $result/@xml:id
                return
                    map:get($config:PUBLICATIONS, $publication-id)?html-href($document-id, $section-id)
            default return
                let $display := $search:DISPLAY?(local-name($result))
                return
                    if (exists($display)) then
                        $display?href($result)
                    else
                        "https://history.state.gov"
    (: display URL is currently hardcoded to hsg, TODO use actual server name, url structure, etc. :)
    let $display := 'https://history.state.gov' || substring-after($href, '$app')
    return
        <a href="{$href}">{$display}</a>
};

declare function search:trim-matches($node as element(), $keep as xs:integer) {
    let $matches := $node//exist:match
    return
        if (count($matches) le $keep) then
            $node
        else
            search:milestone-chunk($node/element()[1], subsequence($matches, $keep, 1), $node)
};

declare function search:milestone-chunk(
  $ms1 as element(),
  $ms2 as element(),
  $node as node()*
) as node()*
{
    typeswitch ($node)
        case element() return
            if ($node is $ms1) then
                $node
            else if ( some $n in $node/descendant::* satisfies ($n is $ms1 or $n is $ms2) ) then
                element { node-name($node) }
                    {
                    $node/@*,
                    for $i in $node/node()
                    return
                        search:milestone-chunk($ms1, $ms2, $i)
                    }
            else if ( $node >> $ms1 and $node << $ms2 ) then
                $node
            else ()
        default return
            if ( $node >> $ms1 and $node << $ms2 ) then
                $node
            else ()
};

declare
    %templates:wrap
function search:result-count($node, $model) {
    $model?query-info?result-count
};

declare
    %templates:wrap
function search:message-limited($node as node(), $model as map(*)) {
    if ($model?query-info?result-count > $search:MAX_HITS_SHOWN) then
        " (Display limited to " || $model?query-info?results-shown || " results)"
    else
        ()
};

(:~
 : Display the search result summary
 : @param $node
 : @param $model
 : @return Returns HTML
 :)
declare function search:result-count-summary($node as node(), $model as map(*)) {
    if ($model?query-info?result-count > 0) then
        <p>
            Displaying {search:start($node, $model)} – {search:end($node, $model)}
            of {search:result-count($node, $model)} results {search:message-limited($node, $model)}
            (Results returned in {search:query-duration($node, $model)}s.)
        </p>
    else
        <p>No results were found.</p>
};

declare
    %templates:wrap
function search:query-duration($node, $model) {
    $model?query-info?query-duration
};

declare function search:q($node, $model) {
    $model?query-info?q
};

declare function search:start($node, $model) {
    $model?query-info?start
};

declare function search:end($node, $model) {
    $model?query-info?end
};

declare
    %templates:wrap
function search:select-volumes($node as node(), $model as map(*), $volume-id as xs:string*) {
    for $vol in collection($config:FRUS_VOLUMES_COL)/tei:TEI[.//tei:body/tei:div]
    let $vol-id := substring-before(util:document-name($vol), '.xml')
    order by $vol-id
    return
        <label class="hsg-search-input-label">
            <input type="checkbox" name="volume-id" value="{$vol-id}">
            { if ($vol-id = $volume-id) then attribute checked { "checked"} else () }
            </input>
            <span class="c-indicator">{ fh:vol-title($vol-id) }</span>
        </label>
};

(:~
 : Create a bootstrap pagination element to navigate through the hits.
 :)
declare
    %templates:default('start', 1)
    %templates:default("per-page", 10)
    %templates:default("min-hits", 0)
    %templates:default("max-pages", 10)
function search:paginate($node as node(), $model as map(*), $start as xs:int, $per-page as xs:int, $min-hits as xs:int,
    $max-pages as xs:int, $volume-id as xs:string*) {
    if ($min-hits < 0 or $model?query-info?result-count >= $min-hits) then
        element { node-name($node) } {
            $node/@*,
            let $params :=
                    string-join(
                        (
                            ('&amp;q=' || encode-for-uri($model?query-info?q)),
                            ($model?query-info?within[. ne ''] ! ('within=' || .)),
                            $volume-id ! ("volume-id=" || .),
                            "per-page=" || $per-page
                        ),
                        '&amp;'
                    )
            let $count := xs:integer(ceiling($model?query-info?result-count) div $per-page) + (if ($model?query-info?result-count mod $per-page = 0) then 0 else 1)
            return (
                if ($start = 1) then (
                    <li class="disabled">
                        <a><i class="glyphicon glyphicon-fast-backward"/></a>
                    </li>,
                    <li class="disabled">
                        <a><i class="glyphicon glyphicon-backward"/></a>
                    </li>
                ) else (
                    <li>
                        <a href="?start=1{$params}"><i class="glyphicon glyphicon-fast-backward"/></a>
                    </li>,
                    <li>
                        <a href="?start={max( ($start - $per-page, 1 ) ) }{$params}"><i class="glyphicon glyphicon-backward"/></a>
                    </li>
                ),
                let $startPage := xs:integer(ceiling($start div $per-page))
                let $lowerBound := max(($startPage - ($max-pages idiv 2), 1))
                let $upperBound := min(($lowerBound + $max-pages - 1, $count))
                let $lowerBound := max(($upperBound - $max-pages + 1, 1))
                for $i in $lowerBound to $upperBound
                return
                    if ($i = ceiling($start div $per-page)) then
                        <li class="active"><a href="?start={max( (($i - 1) * $per-page + 1, 1) )}{$params}">{$i}</a></li>
                    else
                        <li><a href="?start={max( (($i - 1) * $per-page + 1, 1)) }{$params}">{$i}</a></li>,
                if ($start + $per-page - 1 < $model?query-info?result-count) then (
                    <li>
                        <a href="?start={$start + $per-page}{$params}"><i class="glyphicon glyphicon-forward"/></a>
                    </li>,
                    <li>
                        <a href="?start={max( (($count - 1) * $per-page + 1, 1))}{$params}"><i class="glyphicon glyphicon-fast-forward"/></a>
                    </li>
                ) else (
                    <li class="disabled">
                        <a><i class="glyphicon glyphicon-forward"/></a>
                    </li>,
                    <li class="disabled">
                        <a><i class="glyphicon glyphicon-fast-forward"/></a>
                    </li>
                )
            )
        }
    else
        ()
};
