xquery version "3.0";

module namespace search = "http://history.state.gov/ns/site/hsg/search";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace fh = "http://history.state.gov/ns/site/hsg/frus-html" at "frus-html.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

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
        $section-label/node()
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
    let $withins := string-join(((if ($q) then 'q=' || $q else ()), $volume-ids ! concat('within=', .)), '&amp;')
    let $link := element a { attribute href {$node/@href || '?' || $withins}, $node/@* except $node/@href, $node/node() }
    return
        app:fix-this-link($link, $model)
};

declare 
    %templates:default("start", 0)
    %templates:default("perpage", 10)
    %templates:default("within", "")
    (:
    declare variable $search:SORTBY := 'relevance';
    declare variable $search:SORTORDER := 'descending';
    :)
function search:load-results($node, $model, $q as xs:string, $within as xs:string*, $start as xs:integer, $perpage as xs:integer?) {
    let $start-time := util:system-time()
    let $hits := collection($config:PUBLICATIONS?frus?collection)//tei:div[@type='document'][ft:query(., $q)]
    let $end-time := util:system-time()
    let $ordered-hits :=
        for $hit in $hits
        order by ft:score($hit) descending
        return $hit
    let $adjusted-start := $start + 1
    let $adjusted-length := $perpage - 1
    let $hit-count := count($hits)
    let $effective-end := min(($start + $perpage, $hit-count))
    let $window := subsequence($ordered-hits, $adjusted-start, $adjusted-length)
    let $results := map { "results": $window }
    let $page-count := ceiling($hit-count div $perpage) cast as xs:integer
    let $max-pages := 10
    let $max-pages-to-either-side := round($max-pages div 2) cast as xs:integer
    let $current-page := floor($effective-end div $perpage) cast as xs:integer
    let $query-info :=  map { "query-info": 
                            (
                            map { "q": $q },
                            map { "within": $within },
                            map { "start": $adjusted-start },
                            map { "end": $effective-end },
                            map { "perpage": $perpage },
                            map { "result-count": $hit-count },
                            map { "query-duration": seconds-from-duration($end-time - $start-time) },
                            map { "page-count": $page-count },
                            map { "current-page": $current-page }
                            )
                        }
    let $pages := map { "pages": 
                        (
                            if ($current-page - $max-pages-to-either-side le 0) then 
                                (1 to $current-page - 1) 
                            else 
                                ($current-page - $max-pages-to-either-side) to ($current-page - 1)
                            , 
                            if ($current-page + $max-pages-to-either-side ge $page-count) then 
                                ($current-page to $page-count - 1) 
                            else 
                                $current-page to ($current-page + $max-pages-to-either-side - 1) 
                        )
                    }
    let $html := templates:process($node/*, map:new(($model, $results, $query-info, $pages)))
    return
        $html
};

declare 
    %templates:wrap 
function search:result-uri($node, $model) {
    let $result := $model?result
    return
        util:collection-name($result) || '/' || util:document-name($result) || '#' || $result/@xml:id || ' (score: ' || ft:score($result) || ')'
};

declare 
    %templates:wrap 
function search:result-count($node, $model) {
    $model?query-info?result-count
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

declare function search:page-link($node, $model) {
    app:fix-this-link(
        element a { 
            attribute href { 
                $node/@href || 
                string-join(
                    (
                        ('?q=' || encode-for-uri($model?query-info?q)),
                        ($model?query-info?within[. ne ''] ! ('within=' || .)), 
                        (if ($model?page eq 1) then () else 'start=' || (($model?page - 1) * $model?query-info?perpage))
                    ), 
                    '&amp;')
            },
            $node/@* except $node/@href,
            $node/node()
        }
        , $model)
};

declare function search:previous-page-link($node, $model) {
    app:fix-this-link(
        element a { 
            attribute href { 
                $node/@href || 
                string-join(
                    (
                        ('?q=' || encode-for-uri($model?query-info?q)),
                        ($model?query-info?within[. ne ''] ! ('within=' || .)), 
                        (if ($model?query-info?current-page eq 1) then () else 'start=' || (($model?query-info?current-page - 2) * $model?query-info?perpage))
                    ), 
                    '&amp;')
            },
            $node/@* except $node/@href,
            $node/node()
        }
        , $model)
};

declare function search:next-page-link($node, $model) {
    app:fix-this-link(
        element a { 
            attribute href { 
                $node/@href || 
                string-join(
                    (
                        ('?q=' || encode-for-uri($model?query-info?q)),
                        ($model?query-info?within[. ne ''] ! ('within=' || .)), 
                        (if ($model?query-info?current-page eq 1) then () else 'start=' || ($model?query-info?current-page * $model?query-info?perpage))
                    ), 
                    '&amp;')
            },
            $node/@* except $node/@href,
            $node/node()
        }
        , $model)
};