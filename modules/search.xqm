xquery version "3.0";

module namespace search = "http://history.state.gov/ns/site/hsg/search";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace fh = "http://history.state.gov/ns/site/hsg/frus-html" at "frus-html.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $search:SORTBY := 'relevance';
declare variable $search:SORTORDER := 'descending';
declare variable $search:START := 0;
declare variable $search:PERPAGE := 10;

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

declare function search:load-results($node, $model, $q as xs:string, $within as xs:string*) {
    let $start-time := util:system-time()
    let $hits := collection($config:PUBLICATIONS?frus?collection)//tei:div[@type='document'][ft:query(., $q)]
    let $end-time := util:system-time()
    let $ordered-hits :=
        for $hit in $hits
        order by ft:score($hit) descending
        return $hit
    let $window := subsequence($ordered-hits, 1, $search:PERPAGE)
    let $results := map { "results": $window }
    let $query-info :=  map { "query-info": 
                            (
                            map { "result-count": count($hits) },
                            map { "query-duration": ($end-time - $start-time) }
                            )
                        }
    let $html := templates:process($node/*, map:new(($model, $results, $query-info)))
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