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

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace frus="http://history.state.gov/frus/ns/1.0";

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
    "retired": ("milestones", "education"),
    "countries": ("countries", "archives"),
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
                    $heading//text()[not(./ancestor::tei:note)]
                        => string-join()
                        => normalize-space()
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
            let $date-string := $date//text()[not(./ancestor::tei:note)] => string-join() => normalize-space()
            let $placeName := ($doc//tei:placeName)[1]
            let $placeName-string := $placeName//text()[not(./ancestor::tei:note)] => string-join() => normalize-space()
            let $matches-to-highlight := 5
            let $trimmed-hit := search:trim-matches(util:expand($doc), $matches-to-highlight)
            let $has-matches := $trimmed-hit//exist:match
            let $kwic := if ($has-matches) then kwic:summarize($trimmed-hit, <config xmlns="" width="60"/>)/* else ()
            let $score := ft:score($doc)
            return
                <div>
                    <dl class="dl-horizontal">
                        {
                            if ($doc/@subtype eq "historical-document") then
                                (
                                    <dt>Recorded Date</dt>,<dd>{($date-string, <em>(None)</em>)[. ne ""][1]}</dd>,
                                    <dt>Recorded Location</dt>,<dd>{($placeName-string, <em>(None)</em>)[. ne ""][1]}</dd>,
                                    <dt>Encoded Date</dt>,<dd>{if ($date) then <code>{serialize(element date {$date/@*})}</code> else <em>(None)</em>}</dd>
                                )
                            else
                                ()
                        }
                        <dt>Resource ID</dt><dd>{$vol-id/string()}/{$doc-id/string()}</dd>
                        { if ($has-matches) then (<dt>Keyword Results</dt>, <dd>{$kwic}</dd>) else () }
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
    let $html := templates:process($node/*, map:new(($model, $content)))
    return
        $html
};

(:~
 : Extends the model with name attributes of filter inputs
 : @return The merged map of filter names
~:)
declare
    %templates:wrap
function search:filters($node as node(), $model as map(*), $within as xs:string*, $administration as xs:string*, $volume-id as xs:string*) {
(:  more options could be added to $filters  :)
    let $filters := map {
        "within": $within,
        "within-volumes": $volume-id,
        "administration": $administration
    }
    return
        map:new(($model, map {'filters': $filters}))
};

(:~
 : Extends the model with the current filter component and the filter name
 : @return The merged map
~:)
declare
    %templates:wrap
function search:component($node as node(), $model as map(*), $component as xs:string, $filter as xs:string) {
    let $new := map {
        'component': $component,
        'filter': $filter
    }
    return map:new(($model, $new))
};


declare
    %templates:wrap
function search:entire-site-check($node as node(), $model as map(*), $within as xs:string*) {
    if (not(exists($within)) or $within='entire_site') then
        attribute checked {'checked'}
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
    let $c:=console:log($model?component || ' : filter :' || $model?filter )
    
    let $component := $model?component
    let $filter := $model?filter

    let $component-id := $model($component)/id

    return
        (
            attribute value { $component-id },
            attribute id { $component-id },
            if(search:component-checked($node, $model)='checked') then attribute checked {''} else ()
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
    return
        attribute for { $component-id },
        templates:process($node/*, $model)
};

(:~
 : The node(s) containing the component title (label)
 : @return  Child element and/or text nodes of label
~:)
declare
%templates:replace
function search:label-contents($node as node(), $model as map(*)) {
    let $component := $model?component
    return $model($component)/label/string()
};

declare
    %templates:wrap
function search:component-checked($node as node(), $model as map(*)) {
    let $component := $model?component
    let $filter := $model?filter
    let $c:=console:log('bar' || $filter)
    let $within := $model?filters($filter)
    let $c:=console:log($within)
    let $component-id := $model($component)/id
    return if ($component-id = $within) then 'checked' else $within
};

declare
function search:component-hidden($node as node(), $model as map(*), $component as xs:string) {
    let $c:=console:log('c ' ||$component)
    let $c:=console:log($model($component))
    return
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

(: ================= Administrations ================= :)

(:~
 : Load the administrations
 :)
declare function search:load-administrations ($node, $model) {
    let $content := map { "administrations":
        (
            <administration>
                <id>pre_truman</id>
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
    let $html := templates:process($node/*, map:new(($model, $content)))
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
 : TODO: Replace strings in anchors with search:set-sort-by-value()
 : Set cases of sorting options and set a default value
~:)
declare function search:set-sort-by-value($sort-by as xs:string) {
    switch($sort-by)
        case "date_asc" return "Dates (oldest first)"
        case "date_desc" return "Dates (most recent first)"
        default return "Relevance"
};

(:~
 : TODO: Replace Strings in anchors with search:set-sort-by-value()
 : Get the currently selected value of the sorting option
 : @return A string
~:)
declare
    %templates:wrap
    %templates:default("sort-by", "")
function search:sort-by-value($node as node(), $model as map(*), $sort-by as xs:string) {
    let $value := search:set-sort-by-value($sort-by)
    return
        element { local-name($node) } {
            $node/@*,
            $value
        }
};

declare
    %templates:default("start", 1)
    %templates:default("per-page", 10)
    %templates:default("sort-by", "relevance")
function search:load-results($node as node(), $model as map(*), $query as xs:string*, $within as xs:string*,
$volume-id as xs:string*, $start as xs:integer, $per-page as xs:integer?, $start-date as xs:string?, $end-date as xs:string?, $start-time as xs:string?, $end-time as xs:string?, $sort-by as xs:string?) {
    let $query-start-time := util:system-time()
    let $hits := search:query-sections($within, $volume-id, $query, $start-date, $end-date, $start-time, $end-time)
    let $hit-count := count($hits)
    let $hits := search:sort($sort-by, $query, $hits) => search:filter-results()
    let $query-end-time := util:system-time()
    let $window := subsequence($hits, $start, $per-page)
    let $log := console:log("search:load-results has a window of " || count($window) || " hits")
    let $query-info :=  map {
        "results": $window,
        "query-info": map {
            "q": $query,
            "within": $within,
            "start-date": $start-date,
            "end-date": $end-date,
            "start-time": $start-time,
            "end-time": $end-time,
            "sort-by": $sort-by,
            "volume-id": $volume-id,
            "results-doc-ids": $hits/root()/tei:TEI/@xml:id/string(),
            "start": $start,
            "end": $start + count($window) - 1,
            "perpage": $per-page,
            "result-count": $hit-count,
            "results-shown": count($hits),
            "query-duration": seconds-from-duration($query-end-time - $query-start-time)
        }
    }
    let $html := templates:process($node/*, map:new(($model, $query-info)))
    return
        $html
};

declare function search:sort($sort-by as xs:string, $query as xs:string*, $hits as element()*) {
    let $adjusted-sort-by :=
        (: if no query string is provided, relevance sorting is essentially random, so we'll fall back on date sorting :)
        if (string-length($query) eq 0) then
            if ($sort-by eq "date_desc") then $sort-by else "date_asc"
        else
            $sort-by
    return
        switch ($adjusted-sort-by)
            case "date_asc" return
                let $dated := $hits[@frus:doc-dateTime-min]
                let $undated := $hits except $dated
                return
                    (
                        for $hit in $dated
                        order by $hit/@frus:doc-dateTime-min
                        return
                            $hit
                        ,
                        for $hit in $undated
                        order by ft:score($hit) descending
                        return
                            $hit
                    )
            case "date_desc" return
                let $dated := $hits[@frus:doc-dateTime-min]
                let $undated := $hits except $dated
                return
                    (
                        for $hit in $dated
                        order by $hit/@frus:doc-dateTime-min descending
                        return
                            $hit
                        ,
                        for $hit in $undated
                        order by ft:score($hit) descending
                        return
                            $hit
                    )
            default (: case "relevance" :) return
                for $hit in $hits
                order by ft:score($hit) descending
                return
                    $hit
};


declare %private function search:query-sections($sections as xs:string*, $volume-ids as xs:string*,
    $query as xs:string, $start-date as xs:string?, $end-date as xs:string?, $start-time as xs:string?, $end-time as xs:string?) {
    if (exists($sections) and not($sections = ("", "entire_site"))) then
        for $section in $sections
        for $category in $search:SECTIONS?($section)
        return
            search:query-section($category, $volume-ids, $query, $start-date, $end-date, $start-time, $end-time)
    else
        map:for-each(
            $search:SECTIONS,
            function($section, $categories) {
                for $category in $categories
                return
                    search:query-section($category, $volume-ids, $query, $start-date, $end-date, $start-time, $end-time)
            }
        )
};

declare function search:query-section($category, $volume-ids as xs:string*, $query as xs:string*, $start-date as xs:string?, $end-date as xs:string?, $start-time as xs:string?, $end-time as xs:string?) {
    let $log := console:log($start-date || ' -- ' || $end-date || ' : ' || (if ($category instance of map(*)) then $category?id else $category) || ' -- ' || $query)
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
             ($start-date || (if ($start-time ne "") then ("T" || $start-time) else ()))
                => fd:normalize-low($timezone)
        else
            ()
    let $range-end :=
        if ($end-date ne "") then
            ($end-date || (if ($end-time ne "") then ("T" || $end-time) else ()))
                => fd:normalize-high($timezone)
        (: if end-date is omitted, then treat the high end of the start day as the end :)
        else if ($start-date ne "") then
            $start-date
                => fd:normalize-high($timezone)
        else
            ()
    let $log := console:log("range-start: " || $range-start || " range-end: " || $range-end)
    let $is-date-query := exists($range-start) and exists($range-end)
    let $is-keyword-query := string-length($query) gt 0
    return
    typeswitch($category)
        case xs:string return
            switch ($category)
                case "frus" return
                    (console:log('frus search'),
                    let $vols :=
                        if (exists($volume-ids)) then
                            for $volume-id in $volume-ids
                            return
                                collection($config:FRUS_VOLUMES_COL)/id($volume-id)
                        else
                                collection($config:FRUS_VOLUMES_COL)
                    let $hits :=
                        if ($is-date-query and $is-keyword-query) then
                            (console:log('query ' || $query),
                            (: dates + keyword  :)
                            $vols//tei:div[ft:query(., $query)]
                                [@frus:doc-dateTime-min ge $range-start and @frus:doc-dateTime-max le $range-end]
                            )
                        else if ($is-date-query) then
                            (: dates  :)
                            (console:log('no query, just dates ' || count($vols)),
                            $vols//tei:div[@frus:doc-dateTime-min ge $range-start and @frus:doc-dateTime-max le $range-end]
                            )
                        else if ($is-keyword-query) then
                            (: keyword  :)
                            $vols//tei:div[ft:query(., $query)]
                        else
                            (: no parameters provided :)
                            ()
                    return
                        (console:log(count($hits) || " hits"),
                        $hits
                        )
                    )
                default return
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
                let $document-heading :=
                    if ($document//tei:title[@type='volume']) then
                        ($document//tei:title[@type eq "sub-series"], $document//tei:title[@type eq "volume-number"], $document//tei:title[@type eq "volume"])[. ne ""]
                        => string-join(", ")
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
    $model?query-info?result-count
};

declare
    %templates:wrap
function search:message-limited($node as node(), $model as map(*)) {
    if ($model?query-info?result-count > $search:MAX_HITS_SHOWN) then
        " (display limited to " || $model?query-info?results-shown || " results)"
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
            of {search:result-count($node, $model)} results {search:message-limited($node, $model)}.
            Results returned in {search:query-duration($node, $model)}s.
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

declare function search:trim-words($string as xs:string, $number as xs:integer) {
    let $words := tokenize($string, "\s")
    return
        if (count($words) gt $number) then
            (
                subsequence($words, 1, ceiling($number div 2)) => string-join(" ")
                , "…"
                , $words[position() ge last() - floor($number div 2) + 1] => string-join(" ")
            )
            => string-join()
        else
            $string
};

declare
    %templates:wrap
function search:load-volumes($node as node(), $model as map(*), $volume-id as xs:string*) {
    let $frus-volume-ids := $model?query-info?results-doc-ids
    let $volume-ids :=
        if (exists($frus-volume-ids)) then
            $frus-volume-ids
        else
            (: full text volumes in the database :)
            collection($config:FRUS_VOLUMES_COL)/tei:TEI[.//tei:body/tei:div]/@xml:id
    let $vols := collection("/db/apps/frus/bibliography")/volume[@id = $volume-ids]

    let $volumes :=
        map { "volumes":
        (
    for $vol in $vols
        let $vol-id := $vol/@id
        let $title := $vol/title[@type = ("sub-series", "volume-number", "volume")]
        let $title :=
            string-join($title[. != ''], ", ")
            => normalize-space()
            => search:trim-words(10)
    order by $vol-id

    return <volume><id>{$vol-id/string()}</id><label>{$title}</label></volume>
        )}

    let $new := map:new(($model, $volumes))

 let $c:=console:log($new?volumes)
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
    $max-pages as xs:int, $sort-by as xs:string?) {
    if ($min-hits < 0 or $model?query-info?result-count >= $min-hits) then
        element { node-name($node) } {
            $node/@*,
            let $params :=
                string-join(
                    (
                        $model?query-info?q[. ne ""]          ! ("q=" || encode-for-uri(.)),
                        $model?query-info?within[not(. = ("", "entire_site"))]   ! ('within=' || .),
                        $model?query-info?volume-id[. ne ""]  ! ("volume-id=" || .),
                        $model?query-info?start-date[. ne ""] ! ("start_date=" || .),
                        $model?query-info?end-date[. ne ""]   ! ("end_date=" || .),
                        $model?query-info?start-time[. ne ""] ! ("start_time=" || .),
                        $model?query-info?end-time[. ne ""]   ! ("end_time=" || .),
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
