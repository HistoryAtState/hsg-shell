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
(: To be done: pocom, travels, visits :)
declare variable $search:SECTIONS := map {
    "documents": "frus",
    "department": (
        "short-history",
        "people",
        "buildings",
        (: "views-from-the-embassy", :)
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
                collection($config:TRAVELS_COL)//trip[ft:query(name, $query)]
                |
                collection($config:TRAVELS_COL)//trip[ft:query(country, $query)]
                |
                collection($config:TRAVELS_COL)//trip[ft:query(remarks, $query)]
                |
                collection($config:TRAVELS_COL)//trip[ft:query(locale, $query)]
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
        "link": function($name) {
            let $link := "departmenthistory/people/" || $name/ancestor::person/id
            return
                <a href="$app/{$link}">{$link}</a>
        }
    },
    "visit": map {
        "title": function($visit) {
            "Visits By Foreign Leaders: " || string-join($visit/visitor, ", ")
        },
        "link": function($visit) {
            let $link := "departmenthistory/visits/" || year-from-date($visit/start-date)
            return
                <a href="$app/{$link}">{$link}</a>
        }
    },
    "trip": map {
        "title": function($trip) {
            "Travels: " || string-join($trip/name, ", ")
        },
        "link": function($trip) {
            let $link := "departmenthistory/travels/" || $trip/@role || "/" || $trip/@who
            return
                <a href="$app/{$link}">{$link}</a>
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

declare function search:section-id-value-attribute($node, $model) {
    let $section-id := $model?section/id
    return
        attribute value { $section-id }
};

declare function search:section-label($node, $model) {
    let $section-label := $model?section/label
    return
        <span class="c-indicator">{$section-label/node()}</span>
};

declare function search:within-highlight-attribute($node, $model, $within as xs:string+) {
    let $section-id := $model?section/id
    return
        if ($section-id = $within) then
            attribute checked { 'checked' }
        else
            ()
};

declare function search:plural-if-within-multiple-volumes($node, $model, $within as xs:string*) {
    let $volume-searches := for $w in $within return if (matches($w, '^frus\d')) then $w else ()
    return
        if (count($volume-searches) gt 1) then 's' else ()
};

(: the volume-id parameter(s) are provided by controller.xql's parsing of any provided within parameter(s) :)
declare function search:load-volumes-within($node, $model) {
    let $content := map { "volumes":
        (
            for $volume-id in request:get-parameter('volume-id', ())
            order by $volume-id
            return
                <volume>
                    <id>{$volume-id}</id>
                    <title>{fh:vol-title($volume-id)}</title>
                </volume>
        )
    }
    let $html := templates:process($node/*, map:new(($model, $content)))
    return
        $html
};

declare function search:volume-id-value-attribute($node, $model) {
    let $volume-id := $model?volume/id
    return
        attribute value { $volume-id }
};

declare function search:volume-title($node, $model) {
    let $volume-title := $model?volume/title
    return
        $volume-title/string()
};

declare
    %templates:wrap
function search:select-volumes-link($node, $model) {
    let $volume-ids := request:get-parameter('volume-id', ())
    let $q := request:get-parameter('q', ())
    let $withins := string-join(((if ($q) then 'q=' || $q else ()),
        $volume-ids ! concat('volume-id=', .)), '&amp;')
    let $link := element a { attribute href {$node/@href || '?' || $withins}, $node/@* except $node/@href, $node/node() }
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
    %templates:default("start", 0)
    %templates:default("perpage", 10)
    %templates:default("within", "")
    (:
    declare variable $search:SORTBY := 'relevance';
    declare variable $search:SORTORDER := 'descending';
    :)
function search:load-results($node, $model, $q as xs:string, $within as xs:string*,
$volume-id as xs:string*, $start as xs:integer, $perpage as xs:integer?) {
    let $start-time := util:system-time()
    let $hits :=
        search:query-sections($within, $volume-id, $q)
    let $hits := search:filter($hits)
    let $end-time := util:system-time()
    let $ordered-hits :=
        for $hit in $hits
        order by ft:score($hit) descending
        return $hit
    let $hit-count := count($ordered-hits)
    let $adjusted-start := $start + 1
    let $adjusted-length := $perpage
    let $effective-end := min(($start + $perpage, $hit-count))
    let $window := subsequence($ordered-hits, $adjusted-start, $adjusted-length)
    let $reminder := if ($hit-count mod $perpage > 0) then 1 else 0
    let $page-count := ceiling($hit-count div $perpage) cast as xs:integer + $reminder
    let $max-pages := 10
    let $max-pages-to-either-side := round($max-pages div 2) cast as xs:integer
    let $current-page := floor($effective-end div $perpage) cast as xs:integer
    let $query-info :=  map {
        "results": $window,
        "query-info": map {
            "q": $q,
            "within": $within,
            "start": $adjusted-start,
            "end": $effective-end,
            "perpage": $perpage,
            "result-count": $hit-count,
            "results-shown": count($hits),
            "query-duration": seconds-from-duration($end-time - $start-time),
            "page-count": $page-count,
            "current-page": $current-page
        },
        "pages":
            (
                if ($current-page - $max-pages-to-either-side le 0) then
                    (1 to $current-page - 1)
                else
                    ($current-page - $max-pages-to-either-side) to ($current-page - 1)
                ,
                if ($page-count = 1) then
                    1
                else if ($current-page + $max-pages-to-either-side ge $page-count) then
                    ($current-page to $page-count - 1)
                else
                    $current-page to ($current-page + $max-pages-to-either-side - 1)
            )
    }
    let $html := templates:process($node/*, map:new(($model, $query-info)))
    return
        $html
};

declare %private function search:query-sections($sections as xs:string*, $volumes as xs:string*,
    $query as xs:string) {
    if (exists($volumes)) then
        let $docs := for $v in $volumes return collection($config:FRUS_VOLUMES_COL)/id($v)
        return
            $docs//tei:div[ft:query(., $query)]
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
        else
            let $trimmed-hit := search:trim-matches(util:expand($result), $matches-to-highlight)
            return
                kwic:summarize($trimmed-hit, <config xmlns="" width="60"/>)/*
};

declare function search:result-link($node, $model) {
    let $result := $model?result
    return
        typeswitch ($result)
            case element(tei:div) return
                let $publication-id := $config:PUBLICATION-COLLECTIONS?(util:collection-name($result))
                let $document-id := substring-before(util:document-name($result), '.xml')
                let $section-id := $result/@xml:id
                let $href :=
                    map:get($config:PUBLICATIONS, $publication-id)?html-href($document-id, $section-id)
                (: display URL is currently hardcoded to hsg, TODO use actual server name, url structure, etc. :)
                let $display := 'https://history.state.gov' || substring-after($href, '$app')
                return
                    app:fix-this-link(element a { attribute href { $href }, $node/@* except $node/@href, $display }, $model)
            default return
                let $display := $search:DISPLAY?(local-name($result))
                return
                    if (exists($display)) then
                        $display?link($result)
                    else
                        ""
};

declare function search:trim-matches($node as element(), $keep as xs:integer) {
    let $matches := $node//exist:match
    return
        if (count($matches) le $keep) then
            $node
        else
            search:milestone-chunk($node/node()[1], subsequence($matches, $keep, 1), $node)
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

declare function search:disabled-class-attribute-for-previous($node, $model) {
    if ($model?query-info?start eq 1) then
        attribute class {"disabled"}
    else
        ()
};

declare function search:disabled-class-attribute-for-next($node, $model) {
    if (($model?query-info?current-page + 1) eq $model?pages[last()]) then
        attribute class {"disabled"}
    else
        ()
};

declare function search:active-class-attribute-for-current($node, $model) {
    if ($model?query-info?current-page = $model?page) then
        attribute class {"active"}
    else
        ()
};

declare function search:page-label($node, $model) {
    $model?page
};

declare function search:page-link($node, $model, $volume-id) {
    app:fix-this-link(
        element a {
            attribute href {
                $node/@href ||
                string-join(
                    (
                        ('?q=' || encode-for-uri($model?query-info?q)),
                        ($model?query-info?within[. ne ''] ! ('within=' || .)),
                        $volume-id ! ("volume-id=" || .),
                        (if ($model?page eq 1) then () else 'start=' || (($model?page - 1) * $model?query-info?perpage))
                    ),
                    '&amp;')
            },
            $node/@* except $node/@href,
            $node/node()
        }
        , $model)
};

declare function search:previous-page-link($node, $model, $volume-id) {
    app:fix-this-link(
        element a {
            attribute href {
                $node/@href ||
                string-join(
                    (
                        ('?q=' || encode-for-uri($model?query-info?q)),
                        ($model?query-info?within[. ne ''] ! ('within=' || .)),
                        $volume-id ! ("volume-id=" || .),
                        (if ($model?query-info?current-page eq 1) then () else 'start=' || (($model?query-info?current-page - 2) * $model?query-info?perpage))
                    ),
                    '&amp;')
            },
            $node/@* except $node/@href,
            $node/node()
        }
        , $model)
};

declare function search:next-page-link($node, $model, $volume-id) {
    app:fix-this-link(
        element a {
            attribute href {
                $node/@href ||
                string-join(
                    (
                        ('?q=' || encode-for-uri($model?query-info?q)),
                        ($model?query-info?within[. ne ''] ! ('within=' || .)),
                        $volume-id ! ("volume-id=" || .),
                        (if ($model?query-info?current-page eq 1) then () else 'start=' || ($model?query-info?current-page * $model?query-info?perpage))
                    ),
                    '&amp;')
            },
            $node/@* except $node/@href,
            $node/node()
        }
        , $model)
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
