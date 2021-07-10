xquery version "3.1";

module namespace search = "http://history.state.gov/ns/site/hsg/search";

import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace pocom = "http://history.state.gov/ns/site/hsg/pocom-html" at "pocom-html.xqm";
import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace fd="http://history.state.gov/ns/site/hsg/frus-dates" at "frus-dates.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace fh = "http://history.state.gov/ns/site/hsg/frus-html" at "frus-html.xqm";
import module namespace functx = "http://www.functx.com";
(:
import module namespace sort="http://exist-db.org/xquery/sort" at "java:org.exist.xquery.modules.sort.SortModule";
:)
import module namespace cache="http://exist-db.org/xquery/cache" at "java:org.exist.xquery.modules.cache.CacheModule";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace frus="http://history.state.gov/frus/ns/1.0";

declare variable $search:MAX_HITS_SHOWN := 1000;

declare variable $search:ft-query-options := map {
    "default-operator": "and",
    "phrase-slop": 0,
    "leading-wildcard": "no",
    "filter-rewrite": "yes"
};

(: Maps search categories to publication ids, see $config:PUBLICATIONS :)
declare variable $search:SECTIONS := map {
    "documents": "frus",
    "department": (
        "short-history",
        "people",
        "buildings",
        "views-from-the-embassy",
        "pocom",
        "visits",
        "travels"
    ),
    "retired": ("milestones", "education"),
    "countries": ("countries-articles", "archives"),
    "conferences": "conferences",
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
    "body": map {
        "title": function($body) {
            string-join(
                ($body/ancestor::tei:TEI//tei:titleStmt/tei:title)[1],
                ' '
            )
        },
        "summary": (),
        "href": function($body) {
            "$app" || ft:field($body, "hsg-url")
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
    },
    "frus": map {
        "title": function($doc) {
            let $heading := ($doc//tei:head)[1]
            let $heading-string :=
                if ($heading ne '') then
                    normalize-space(string-join($heading//text()[not(./ancestor::tei:note)]))
                else
                    ()
            let $heading-stripped :=
                if (matches($heading-string, ('^' || $doc/@n || '\.'))) then
                    replace($heading-string, '^' || $doc/@n || '\.\s+(.+)$', '$1')
                else if (matches($heading-string, ('^No\. ' || $doc/@n || '[^\d]'))) then
                    replace($heading-string, '^No\. ' || $doc/@n || '(.+)$', '$1')
                else
                    $heading-string
            return
                $heading-stripped
        },
        "summary": function($doc) {
            let $doc-id := $doc/@xml:id
            let $vol-id := root($doc)/tei:TEI/@xml:id
            let $dateline := ($doc//tei:dateline[.//tei:date])[1]
            let $date := ($dateline//tei:date)[1]
            let $date-string := normalize-space(string-join($date//text()[not(./ancestor::tei:note)]))
            let $placeName := ($doc//tei:placeName)[1]
            let $placeName-string := normalize-space(string-join($placeName//text()[not(./ancestor::tei:note)]))
            let $matches-to-highlight := 5

            let $m := ft:highlight-field-matches($doc, 'hsg-fulltext')
            let $kwic :=
                for $hit in subsequence($m//exist:match, 1, $matches-to-highlight) 
                    return kwic:get-summary($m, $hit, <config width="40"/>)/child::*
                
            let $score := ft:score($doc)
            return
                <div>
                    <dl class="dl-horizontal">
                        {
                            if ($doc/@subtype eq "historical-document") then
                                (
                                    <dt>Recorded Date</dt>,<dd>{($date-string, <em>(None)</em>)[. ne ""][1]}</dd>,
                                    <dt>Recorded Location</dt>,<dd>{($placeName-string, <em>(None)</em>)[. ne ""][1]}</dd>,
                                    <dt>Encoded Date</dt>,<dd>{if ($date) then <code>{$date/(@when, @from, @to, @notBefore, @notAfter) ! string-join(serialize(., <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
  <output:method>adaptive</output:method>
</output:serialization-parameters>), " ")}</code> else <em>(None)</em>}</dd>
                                )
                            else
                                ()
                        }
                        <dt>Resource ID</dt><dd>{$vol-id/string()}/{$doc-id/string()}</dd>
                        { if (count($kwic)) then (<dt>Keyword Results</dt>, <dd>{$kwic}</dd>) else () }
                        { if ($score) then (<dt>Keyword Relevance</dt>, <dd>{$score}</dd>) else () }
                    </dl>
                </div>
        },
        "href": function($doc) {
            let $doc-id := $doc/@xml:id
            let $vol-id := root($doc)/tei:TEI/@xml:id
            return
                "https://history.state.gov/historicaldocuments/" || $vol-id || "/" || $doc-id
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
                <id>countries</id>
                <label>Countries</label>
            </section>,
            <section>
                <id>conferences</id>
                <label>Conferences</label>
            </section>,
            <section>
                <id>frus-history</id>
                <label>History of the <em>Foreign Relations</em> Series</label>
            </section>,
            <section>
                <id>about</id>
                <label>About (FAQ, Advisory Committee Minutes)</label>
            </section>,
            <section>
                <id>retired</id>
                <label>Retired Resources (Milestones)</label>
            </section>
        )
    }
    let $html := templates:process($node/*, map:merge(($model, $content)))
    return
        $html
};

(:~
 : Extends the model with name attributes of filter inputs
 : @return The merged map of filter names
~:)
declare
    %templates:wrap
function search:filters($node as node(), $model as map(*), $administration as xs:string*) {
(:  more options could be added to $filters  :)
    let $filters := map {
        "within": $model?query-info?within,
        "within-volumes": $model?query-info?volume-id,
        "administration": $administration
    }
    return
        map:merge(($model, map { "filters": $filters}))
};

(:~
 : Extends the model with the current filter component and the filter name
 : @return The merged map
~:)
declare
    %templates:wrap
function search:component($node as node(), $model as map(*), $component as xs:string, $filter as xs:string) {
    let $new := map {
        "component": $component,
        "filter": $filter
    }
    return map:merge(($model, $new))
};


declare
    %templates:wrap
function search:entire-site-check($node as node(), $model as map(*)) {
    let $within := $model?query-info?within
    return
        if ($within = "entire-site") then
            attribute checked { "checked" }
        else
            ()
};
(:~
 : Generates HTML attributes "value" and "id" for the filter input
 : @return  HTML attributes
~:)
declare
    %templates:wrap
function search:filter-input-attributes($node as node(), $model as map(*)) {
    (:let $c:=console:log($model?component || ' : filter :' || $model?filter ):)
    let $component := $model?component
    let $filter := $model?filter
    let $component-id := $model($component)/id
    return
        (
            attribute value { $component-id },
            attribute id { $component-id },
            if (search:component-checked($node, $model) = "checked") then attribute checked { "" } else ()
        )
};

(:~
 : Generates an HTML <label> attribute "for"
 : @return  HTML
~:)
declare
    %templates:wrap
function search:label($node as node(), $model as map(*)) {
    let $component := $model?component
    let $component-id := $model($component)/id
    let $component-title := $model($component)/title
    return
        (
            attribute for { $component-id },
            if ($component-title) then attribute title { $component-title } else (),
            templates:process($node/*, $model)
        )
};

(:~
 : The node(s) containing the component title (label)
 : @return  Child element and/or text nodes of label
~:)
declare
%templates:replace
function search:label-contents($node as node(), $model as map(*)) {
    let $component := $model?component
    return $model($component)/label/node()
};

declare
    %templates:wrap
function search:component-checked($node as node(), $model as map(*)) {
    let $component := $model?component
    let $filter := $model?filter
(:    let $c:=console:log('bar' || $filter):)
    let $within := $model?filters($filter)
(:    let $c:=console:log($within):)
    let $component-id := $model($component)/id
    return if ($component-id = $within) then "checked" else $within
};

declare
function search:component-hidden($node as node(), $model as map(*), $component as xs:string) {
(:    let $c:=console:log('c ' ||$component)
    let $c:=console:log($model($component))
    return:)
    element {$node/name()} {
        attribute class {
            if (count($model($component)) > 3) then 
                $node/@class || ' hideContent'
            else 
                $node/@class
        },
        $node/@* except $node/@class, templates:process($node/*, $model)
    }
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
    let $html := templates:process($node/*, map:merge(($model, $content)))
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

(: ================= Administrations ================= :)

(:~
 : Load the administrations
 :)
declare function search:load-administrations ($node, $model) {
    let $content := map { "administrations":
        (
            <administration>
                <id>pre-truman</id>
                <label>Pre-Truman Volumes</label>
            </administration>,
            <administration>
                <id>truman</id>
                <label>Truman Administration</label>
            </administration>,
            <administration>
                <id>eisenhower</id>
                <label>Eisenhower Administration</label>
            </administration>,
            <administration>
                <id>kennedy</id>
                <label>Kennedy Administration</label>
            </administration>,
            <administration>
                <id>johnson</id>
                <label>Johnson Administration</label>
            </administration>,
            <administration>
                <id>nixon</id>
                <label>Nixon Administration</label>
            </administration>,
            <administration>
                <id>ford</id>
                <label>Ford Administration</label>
            </administration>,
            <administration>
                <id>carter</id>
                <label>Carter Administration</label>
            </administration>,
            <administration>
                <id>reagan</id>
                <label>Reagan Administration</label>
            </administration>
        )
    }
    let $html := templates:process($node/*, map:merge(($model, $content)))
    return
        $html
};

(: ================= SEARCH RESULTS ================= :)

declare %private function search:filter-results($in) {
    fold-left($in, (), function($result, $node) {
        if (count($result) = $search:MAX_HITS_SHOWN) then
            $result
        else
            ($result, $node[@xml:id][not(tei:div/@xml:id)] | $node[not(self::tei:div)])
    })
};

(:~
 : TODO: (This is a placeholder)
 : Retrieve the number of hits of any filtered query and filter item (== of each input)
 : @param $component The current filter component
 : @param ...
 : @return The number of hits
~:)
(:
declare function search:number-of-filter-hits($component, $item, $hits) {

};
:)

(:~
 : TODO: (This is a placeholder)
 : 1. Apply search:show-number-of-filter-hits() on each filter item (== on each input).
 : 2. Only show hits, when „hits > 0“.
 :
 : Display the number of hits for any filtered query and filter item (with parameters $node, $model, $item, $hits)
 : @return HTML
~:)
declare
    %templates:replace
function search:show-number-of-filter-hits($node, $model) {
    <span class="hsg-badge-number">8</span>
};


(:~
 : TODO: Replace strings in anchors with search:get-sort-by-value()
 : Set cases of sorting options and set a default value
~:)
declare function search:get-sort-by-label($sort-by as xs:string) {
    switch($sort-by)
        case "date-asc" return "Dates (oldest first)"
        case "date-desc" return "Dates (most recent first)"
        default return "Relevance"
};

(:~
 : TODO: Replace Strings in anchors with search:get-sort-by-value()
 : Get the currently selected value of the sorting option
 : @return A string
~:)
declare
    %templates:wrap
function search:sort-by-label($node as node(), $model as map(*)) {
    let $sort-by := $model?query-info?sort-by
    let $label := search:get-sort-by-label($sort-by)
    return
        element { local-name($node) } {
            $node/@*,
            $label
        }
};

declare function search:get-range($start-date as xs:string?, $end-date as xs:string?, $start-time as xs:string?, $end-time as xs:string?) as map(*) {
    let $timezone :=
        (: We want to assume times supplied in a query are US Eastern, unless otherwise specified.
           The UTC offset for US Eastern changes depending on daylight savings time.
           We could use fn:implicit-timezone(), but this depends upon the query context, which is set by the system/environment.
           On the hsg production servers, this function returns +00:00, or UTC.
           So the following is a kludge to determine the UTC offset for US Eastern, sensitive to daylight savings time. :)
        (:functx:duration-from-timezone(fn:format-dateTime(current-dateTime(), "[Z]", (), (), "America/New_York")):)
        (: hard code US Eastern time, since dev/prod servers had different implicit timezones, and this made testing impossible
           better to be 1 hr off than ~5 hrs. :)
        xs:dayTimeDuration("-PT5H")
    let $range-start :=
        if ($start-date ne "") then
             fd:normalize-low($start-date || (if ($start-time ne "") then ("T" || $start-time) else ()), $timezone)
        else
            ()
    let $range-end :=
        if ($end-date ne "") then
            fd:normalize-high($end-date || (if ($end-time ne "") then ("T" || $end-time) else ()), $timezone)
        (: if end-date is omitted, then treat the high end of the start day as the end :)
        else if ($start-date ne "") then
            fd:normalize-high($start-date, $timezone)
        else
            ()
    return
        map { 
            "start": $range-start,
            "end": $range-end
        }
};

declare 
    %templates:default("sort-by", "relevance")
    %templates:default("within", "entire-site")
function search:landing-page($node as node(), $model as map(*), $within as xs:string*, $sort-by as xs:string?) {
    let $query-info :=  map {
        "query-info": map {
            "within": $within,
            "sort-by": $sort-by
        }
    }
    let $html := templates:process($node/*, map:merge(($model, $query-info)))
    return
        $html
};

declare
    %templates:default("start", 1)
    %templates:default("per-page", 10)
    %templates:default("sort-by", "relevance")
function search:load-results($node as node(), $model as map(*), $q as xs:string?, $within as xs:string*, $volume-id as xs:string*, $start as xs:integer, $per-page as xs:integer, $start-date as xs:string?, $end-date as xs:string?, $start-time as xs:string?, $end-time as xs:string?, $sort-by as xs:string?, $order-by as xs:string?) {
    let $query-start-time := util:system-time()
    
    let $q := normalize-space($q)[. ne ""]
    
    let $adjusted-sort-by :=
        (: if no query string is provided, relevance sorting is essentially random, so we'll apply date sorting to results :)
        if (not($q) and $sort-by eq "relevance") then
            "date-asc"
        (: catch unique values from the "order-by" parameter from the old frus-dates search engine :)
        else if ($order-by eq "date") then
            "date-asc"
        (: in the absence of a sort-by parameter, apply relevance sorting :)
        else if (not($sort-by)) then
            "relevance"
        else
            $sort-by
    
    (: the old frus-dates search didn't specify within=documents, so if an old URL is redirected here we'll need to catch these and categorize these as date searches :)
    let $adjusted-section := 
        if (empty($within)) then
            if ($start-date or $volume-id) then
                "documents"
            else
                "entire-site"
        else
            $within

    (: prepare a unique key for the present query, so we can cache the hits to improve the result of subsequent requests for the same query :)
    let $normalized-query-string := 
        string-join(
            let $params := map { "q": $q, "within": $adjusted-section, "volume-id": $volume-id, "start-date": $start-date, "end-date": $end-date, "start-time": $start-time, "end-time": $end-time, "sort-by": $adjusted-sort-by } 
            for $param in map:keys($params)
            let $val := map:get($params, $param) ! normalize-space(.)[. ne ""]
            order by $param
            return
                $param || "=" || string-join(sort($val), ";")
        , "&amp;")
    let $query-id := util:hash($normalized-query-string, "sha1")
    let $cache-name := "hsg-search"
    let $cache-key := "queries"
    let $cache := cache:get($cache-name, $cache-key)
    let $cache := if ($cache instance of map(*)) then $cache else map { "created": current-dateTime(), "purged": current-dateTime(), "queries": map { } }
    
    (: retrieve the hits from the cache, or populate the cache with the hits :)
    let $cached-query := 
    (: if (map:contains($cache?queries, $query-id)) then map:get($cache?queries, $query-id) else  :)
    ()
    let $results :=
        (: if (exists($cached-query)) then
            $cached-query
        else :)
            let $range := search:get-range($start-date, $end-date, $start-time, $end-time)
            let $range-start := $range?start
            let $range-end := $range?end

                let $log := console:log("search:query-section starting")
            let $query-sections-start := util:system-time()
            let $hits := search:query-sections($adjusted-section, $volume-id, $q, $range-start, $range-end)
            let $query-sections-end := util:system-time()
                let $log := console:log("search:query-section finished, found " || count($hits) || " hits in " || $query-sections-end - $query-sections-start)
            
            let $query-sections-duration := console:log("query-sections-duration: " || $query-sections-end - $query-sections-start)
            let $sorted-hits-start := util:system-time()
            let $sorted-hits := search:sort($hits, $adjusted-sort-by)
            let $sorted-hits-end := util:system-time()
            let $sorted-hits-duration := console:log("sorted-hits-duration: " || $sorted-hits-end - $sorted-hits-start)
            let $vol-ids :=  
                map:for-each(ft:facets($hits, "frus-volume-id", ()), function($label, $count) {
                    $label
                })
            let $results := 
                map { 
                    "id": $query-id,
                    "query": $normalized-query-string,
                    "created": current-dateTime(),
                    "hits": $sorted-hits,
                    "results-vol-ids": $vol-ids,
                    "range-start": $range-start,
                    "range-end": $range-end
                }
            let $new-queries := map:put($cache?queries, $query-id, $results)
            let $set-cache := cache:put($cache-name, $cache-key, map { "created": $cache?created, "purged": $cache?purged, "queries": $new-queries })
            return
                $results

    let $hits := $results?hits
    let $results-vol-ids := $results?results-vol-ids
    let $range-start := $results?range-start
    let $range-end := $results?range-end
    
    let $window := subsequence($hits, $start, $per-page)
    let $end := $start + count($window) - 1
    let $hit-count := count($hits)
    let $query-end-time := util:system-time()
    let $query-duration := seconds-from-duration($query-end-time - $query-start-time)
    let $query-info :=  map {
        "results": $window,
        "query-info": map {
            "q": $q,
            "within": $adjusted-section,
            "volume-id": $volume-id,
            "start-date": $start-date,
            "end-date": $end-date,
            "start-time": $start-time,
            "end-time": $end-time,
            "range-start": $range-start,
            "range-end": $range-end,
            "sort-by": $adjusted-sort-by,
            "start": $start,
            "end": $end,
            "perpage": $per-page,
            "results-vol-ids": $results-vol-ids,
            "result-count": $hit-count,
            "query-duration": $query-duration
        }
    }
    (: let $log := console:log($query-info?query-info) :)

    (: purge cache :)
    let $cache-max-age := xs:dayTimeDuration("PT5M")
    let $purge := 
        if (current-dateTime() - $cache?purged gt $cache-max-age) then
            (: until map:remove is fixed, we'll just blow away the cache :)
            cache:clear($cache-name)
            (:
            let $entries-to-purge := $cache?queries?*[?created + $cache-max-age gt current-dateTime()]?id
            let $purged := map:remove($cache?queries, $entries-to-purge)
            let $new := map:merge(($cache?created, map:entry("purged": current-dateTime()), $purged)
            return
                cache:put($cache-name, $cache-key, $new)
            :)
        else
            ()
    
    let $templates-process-start := util:system-time()
    let $html := templates:process($node/*, map:merge(($model, $query-info)))
    let $templates-process-end := util:system-time()
    let $log := console:log("templates-process-duration: ", $templates-process-end - $templates-process-start)
    return
        $html
};

declare function search:sort($hits as element()*, $sort-by as xs:string) {
    switch ($sort-by)
        case "date-asc" return
            for $hit in $hits
            order by ft:field($hit, "hsg-date-min") ascending empty greatest, ft:score($hit) descending
            return
                $hit
        case "date-desc" return
            for $hit in $hits
            order by ft:field($hit, "hsg-date-min") descending empty least, ft:score($hit) descending
            return
                $hit
        default (: case "relevance" :) return
            for $hit in $hits
            order by ft:score($hit) descending
            return
                $hit
};

declare %private function search:query-sections($sections as xs:string*, $volume-ids as xs:string*,
    $query as xs:string?, $range-start as xs:dateTime?, $range-end as xs:dateTime?) {

    let $category := 
        for $section in $sections
            return 
                if (not($section = ("", "entire-site"))) then
                    $section
                else 
                    ()

    let $publication := 
           for $section in $sections
            return 
                if (not($section = ("", "entire-site"))) then
                    for $pub in $search:SECTIONS?($section)
                    return 
                       if ($pub instance of map(*)) then $pub?id else $pub
                else 
                    ()

    let $date-capable := count($category) eq 1 and $category = "documents"

    let $is-date-query := exists($range-start)
    let $is-keyword-query := exists($query)

    let $fulltext-query := if (exists($query)) then 'hsg-fulltext:(' || $query || ') ' else ()

    (: translate date ranges to the form used by Lucene index, cf. frus/volumes.xconf :)
    (: let $range-start := translate($range-start, ':-', '')
    let $range-end := translate($range-end, ':-', '') :)

    (: construct the part of the query that filters by date :)
    let $date-query := if ($is-date-query) then
        '
        hsg-date-min:[' || $range-start || ' TO ' || $range-end || '] 
        AND 
        hsg-date-max:[' || $range-start || ' TO ' || $range-end || '] 
        '
    else 
        ()

(: TODO cover undated documents for frus/date queries :)
         (: let $dated :=
                                    $vols//tei:div[ft:query(., $query-string, $query-options)]
                                let $undated :=
                                    $vols//tei:div[not(@frus:doc-dateTime-min)][ft:query(., $query-string, $query-options)] :)
                               

(: should be else hsg-fulltext:* :)
    let $query-string := if (count(($fulltext-query, $date-query))) then string-join(($fulltext-query, $date-query), ' AND ') else ()

    let $facets := map {
        "facets":
                    map:merge((
                        if (exists($category)) then
                            map { "hsg-category": $category }
                        else
                            ()
                            ,
                        if (exists($publication)) then
                            map { "hsg-publication": $publication }
                        else
                            ()
                        ,
                        if ($date-capable) then
                            (
                                if (exists($volume-ids)) then 
                                    map { "frus-volume-id": $volume-ids }
                                else
                                    (: (),
                                if (exists($type)) then 
                                    map { "frus-type": $type }
                                else
                                    (),
                                if (exists($subtype)) then 
                                    map { "frus-subtype": $subtype }
                                else :)
                                    ()
                            )
                        else
                            ()
                    ))
    }

    let $fields := map {"fields": ("hsg-date-min", "hsg-fulltext")}

    let $query-options := 
        map:merge((
            $search:ft-query-options,
            $fields,
            $facets
        ))

    (: let $foo := serialize($query-options, <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
                                        <output:method>adaptive</output:method>
                                        </output:serialization-parameters>)
    let $log := console:log('query >>> ')
    let $log := console:log($query-string)
    let $log := console:log($foo) :)
        let $log := console:log("search:query-section starting: query: " || $query-string || " range-start: " || $range-start || " range-end: " || $range-end || " category: "  || string-join($category, ' '))

    return
(: 

## SECTTIONS and PUBLICATIONS --- collection // element
    * "documents": 
      - "frus" --- db/apps/frus/volumes
    * "department": 
      - "short-history" --- /db/apps/other-publications/short-history
      - "people" --- /db/apps/other-publications/people 
      - "buildings", --- /db/apps/other-publications/buildings
      - "views-from-the-embassy" --- /db/apps/other-publications/views-from-the-embassy 
      - "pocom", --- /db/apps/pocom/people //persName
      - "visits", --- /db/apps/visits/data //visits
      - "travels" --- db/apps/travels //trips
    * "retired": 
      - "milestones" --- /db/apps/milestones/chapters
      - "education" --- /db/apps/other-publications/education/introductions //body
    * "countries": 
      - "countries" --- /db/apps/rdcr/articles
      - "archives" --- /db/apps/wwdai/articles
    * "conferences": 
      - "conferences" --- /db/apps/conferences/data
    * "frus-history": 
      - "frus-history-monograph" --- db/apps/frus-history/monograph
    * "about": 
      - "hac" --- /db/apps/hac
      - "faq" --- /db/apps/other-publications/faq
 :)

              ( 
                collection("/db/apps/administrative-timeline/timeline")//tei:div[ft:query(., $query-string, $query-options)],
                collection("/db/apps/other-publications/buildings")//tei:div[ft:query(., $query-string, $query-options)],
                collection("/db/apps/other-publications/faq")//tei:div[ft:query(., $query-string, $query-options)],
                collection("/db/apps/other-publications/short-history")//tei:div[ft:query(., $query-string, $query-options)],
                collection("/db/apps/other-publications/views-from-the-embassy")//tei:div[ft:query(., $query-string, $query-options)],
                collection("/db/apps/other-publications/secretary-bios")//tei:div[ft:query(., $query-string, $query-options)],
                collection("/db/apps/conferences/data")//tei:div[ft:query(., $query-string, $query-options)],
                
                collection("/db/apps/other-publications/education/introductions")//tei:body[ft:query(., $query-string, $query-options)],
                collection("/db/apps/other-publications/vietnam-guide")//tei:body[ft:query(., $query-string, $query-options)],

                collection("/db/apps/hac")//tei:div[ft:query(., $query-string, $query-options)],

                collection("/db/apps/frus/volumes")//tei:div[ft:query(., $query-string, $query-options)],
                collection("/db/apps/frus-history/monograph")//tei:div[ft:query(., $query-string, $query-options)],

                collection("/db/apps/rdcr/articles")//tei:body[ft:query(., $query-string, $query-options)],
                collection("/db/apps/wwdai/articles")//tei:body[ft:query(., $query-string, $query-options)],

                collection("/db/apps/pocom/people")//persName[ft:query(., $query-string, $query-options)],

                collection("/db/apps/travels")//trips[ft:query(., $query-string, $query-options)],
                collection("/db/apps/visits/data")//visit[ft:query(., $query-string, $query-options)],
                collection("/db/apps/milestones/chapters")//tei:div[ft:query(., $query-string, $query-options)]
             )
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
                let $document-heading :=
                    if ($document//tei:title[@type='volume']) then
                        string-join(($document//tei:title[@type eq "sub-series"], $document//tei:title[@type eq "volume-number"], $document//tei:title[@type eq "volume"])[. ne ""], ", ")
                    else
                        $document//tei:titleStmt/tei:title[@type = "short"]
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
    let $publication-by-collection := map:contains($config:PUBLICATION-COLLECTIONS, util:collection-name($result))
    let $publication-has-custom-function := if ($publication-by-collection) then map:contains($search:DISPLAY, $config:PUBLICATION-COLLECTIONS?(util:collection-name($result))) else ()
    let $element-name-has-custom-function := map:contains($search:DISPLAY, local-name($result))
(:    let $log := console:log("publication has custom function: " || $publication-has-custom-function || " element name has custom function: " || $element-name-has-custom-function):)
    return
        if ($result/@xml:id = 'index') then
            '[Back of book index: too many hits to display]'
        (: see if we've defined a custom function for this publication to display result summaries :)
        else if ($publication-has-custom-function) then
            let $summary := $search:DISPLAY?($config:PUBLICATION-COLLECTIONS?(util:collection-name($result)))?summary
            return
                $summary($result)
        (: see if we've defined a custom function for this result's element name to display result summaries :)
        else if ($element-name-has-custom-function) then
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

declare function search:result-href-attribute($node, $model) {
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
    return
        attribute href { $href }
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
    format-number($model?query-info?result-count, "#,###")
};

declare
    %templates:wrap
function search:message-limited($node as node(), $model as map(*)) {
    if ($model?query-info?result-count > $search:MAX_HITS_SHOWN) then
        " (display limited to " || format-number($model?query-info?results-shown, "#,###.##") || " results)"
    else
        ()
};

(:~
 : Display the search result summary
 : @param $node
 : @param $model
 : @return Returns HTML
 :)
declare function search:results-summary($node as node(), $model as map(*)) {
    if ($model?query-info?result-count > 0) then
        <p>
            Displaying {search:start($node, $model)}–{search:end($node, $model)}
            of <span class="search-count"  >{search:result-count($node, $model)}</span> results
            {
                string-join((
                    search:keyword-summary($node, $model), 
                    search:scope-summary($node, $model), 
                    search:date-summary($node, $model)
                ), " ")
                || ", " 
                || search:sort-by-summary($node, $model)
            }.
            Search completed in <span class="search-duration">{search:query-duration($node, $model)}</span>s.
        </p>
    else
        <p>No results were found.</p>
};

declare
    %templates:wrap
function search:query-duration($node, $model) {
    $model?query-info?query-duration
};

declare function search:start($node, $model) {
    $model?query-info?start
};

declare function search:end($node, $model) {
    $model?query-info?end
};

declare function search:pluralize($count as xs:integer, $singular-form as xs:string, $plural-form as xs:string) {
    if ($count eq 1) then
        $singular-form
    else 
        $plural-form
};

declare function search:keyword-summary($node, $model) {
    let $q := normalize-space($model?query-info?q)
    return
        if ($q ne "") then
            "for keyword “" || $q || "”"
        else
            ()
};

declare function search:scope-summary($node, $model) {
    let $sections := $model?query-info?within
    let $sections-count := count($sections)
    let $volumes-count := count($model?query-info?volume-id)
    return
        if ($sections = "entire-site" or $sections-count eq 0) then
            "across the entire Office of the Historian website"
        else if ($sections-count gt 0 or $volumes-count gt 0) then
            (
                "within "
                ||
                string-join((
                    if ($sections-count gt 0) then 
                        ($sections-count || " " || search:pluralize($sections-count, "section", "sections")) 
                    else 
                        (),
                    if ($volumes-count gt 0) then 
                        ($volumes-count || " " || search:pluralize($volumes-count, "volume", "volumes"))
                    else 
                        ()
                ), " and ")
            )
        else
            ()
};

declare function search:date-summary($node, $model) {
    let $start := $model?query-info?range-start
    let $end := $model?query-info?range-end
    let $format := format-dateTime(?, "[MNn] [D], [Y] at [h]:[m][P]", "en", (), ())
    return
        if (exists($start) and exists($end)) then
            "between " || $format($start) || " and " || $format($end)
        else
            ()
};

declare function search:sort-by-summary($node, $model) {
    let $sort-by := $model?query-info?sort-by
    let $label := lower-case(search:get-sort-by-label($sort-by))
    return
        "sorted by " || $label
};


declare function search:trim-words($string as xs:string, $number as xs:integer) {
    let $words := tokenize($string, "\s")
    return
        if (count($words) gt $number) then
            string-join((
                string-join(subsequence($words, 1, ceiling($number div 2)), " ")
                , "…"
                , string-join($words[position() ge last() - floor($number div 2) + 1], " ")
            ))
        else
            $string
};

declare
    %templates:wrap
function search:load-volumes($node as node(), $model as map(*)) {
    let $load-volumes-start := util:system-time()
    let $volume-ids := $model?query-info?results-vol-ids
    
    (: let $cache-name := "hsg-search"
    let $cache-key := "volumes-filter"
    let $cache := cache:get($cache-name, $cache-key)
    let $cache := if (exists($cache)) then $cache else map { "created": current-dateTime(), "purged": current-dateTime() }
    let $volumes := if (map:contains($cache, "volumes")) then map:get($cache, "volumes") else () :)

    
        (: if (exists($volumes)) then
            if (exists($volume-ids)) then
                map { "volumes": $volumes[id = $volume-ids] }
            else
                map { "volumes": $volumes }
        else :)
            let $new-volumes := 
                (: full text volumes in the database :)
                (: let $ft-vol-ids := collection($config:FRUS_VOLUMES_COL"/db/apps/frus/volumes")/tei:TEI[.//tei:body/tei:div]/@xml:id :)
                for $vol in collection("/db/apps/frus/bibliography")/volume[@id = $volume-ids]
                let $vol-id := $vol/@id/string()
                let $compact-title := 
                    search:trim-words(normalize-space(string-join($vol/title[@type = ("sub-series", "volume-number", "volume")][. != ''], ", ")), 10)
                let $complete-title := normalize-space($vol/title[@type eq "complete"])
                order by $vol-id
                return
                    <volume>
                        <id>{$vol-id}</id>
                        <label>{$compact-title}</label>
                        <title>{$complete-title}</title>
                    </volume>
            let $new-volumes-entry := map { "volumes": $new-volumes }
            (: let $put := cache:put($cache-name, $cache-key, map:merge(($cache, $new-volumes-entry))) :)
            (: return :)
                (: if (exists($volume-ids)) then
                    map { "volumes": $new-volumes[id = $volume-ids] }
                else :)
                    (: $new-volumes-entry :)
    let $volumes := $new-volumes-entry
    (: purge cache :)
    (: let $cache-max-age := xs:dayTimeDuration("PT10M")
    let $purge := 
        if (current-dateTime() - $cache?purged gt $cache-max-age) then
            cache:clear()
        else
            () :)
    
    let $load-volumes-end := util:system-time()
    let $log := console:log("search:load-volumes: loaded " || count($volumes?*) || " in " || $load-volumes-end - $load-volumes-start)
    let $new := map:merge(($model, $volumes))

    return
        $new
};

declare
    %templates:wrap
function search:volumes($node as node(), $model as map(*)) {
    for $volume in $model?volume
    return
        <li>
            <input class="hsg-search-input" type="checkbox" name="volume-id" id="{ $volume/id/string() }" value="{ $volume/id/string() }">
            </input>
            <label class="hsg-search-input-label truncate" for="{ $volume }">
                <span class="c-indicator">{ $volume/label/string() }</span>
            </label>
        </li>
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
    $max-pages as xs:int) {
    if ($min-hits < 0 or $model?query-info?result-count >= $min-hits) then
        element { node-name($node) } {
            $node/@*,
            let $params :=
                string-join(
                    (
                        $model?query-info?q[. ne ""]          ! ("q=" || encode-for-uri(.)),
                        $model?query-info?within[not(. = ("", "entire-site"))]   ! ('within=' || .),
                        $model?query-info?volume-id[. ne ""]  ! ("volume-id=" || .),
                        $model?query-info?start-date[. ne ""] ! ("start-date=" || .),
                        $model?query-info?end-date[. ne ""]   ! ("end-date=" || .),
                        $model?query-info?start-time[. ne ""] ! ("start-time=" || .),
                        $model?query-info?end-time[. ne ""]   ! ("end-time=" || .),
                        $model?query-info?sort-by[. ne ""]   ! ("sort-by=" || .)
                    ),
                    '&amp;'
                ) ! ("&amp;" || .)
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
