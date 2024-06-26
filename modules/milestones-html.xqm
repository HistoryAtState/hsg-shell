xquery version "3.0";

module namespace milestones = "http://history.state.gov/ns/site/hsg/milestones-html";

import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $milestones:MILESTONES_COL := '/db/apps/milestones';
declare variable $milestones:MILESTONES_CHAPTERS_COL := $milestones:MILESTONES_COL || '/chapters';

declare %templates:wrap function milestones:load-periods($node as node(), $model as map(*)) {
    let $ordered-articles :=
        for $c in collection($milestones:MILESTONES_CHAPTERS_COL)/tei:TEI
        order by util:document-name($c)
        return $c
    let $content := map { "periods": $ordered-articles }
    let $html := templates:process($node/*, map:merge(($model, $content),  map{"duplicates": "use-last"}))
    return
        $html
};

declare function milestones:period-title($node as node(), $model as map(*)) {
    $model?period//tei:title[@type='short']/string()
};

declare function milestones:period-id($period) {
    substring-before(util:document-name($period), '.xml')
};

declare function milestones:period-href-value-attribute($node as node(), $model as map(*)) {
    let $period-id := milestones:period-id($model?period)
    return
        attribute value { app:fix-href("$app/milestones/" || $period-id) }
};

declare
    %templates:wrap
function milestones:period-link($node as node(), $model as map(*)) {
    <a href="$app/{$model?base-path}/{$model?document-id}">{$model?document-id}</a>
};

declare
    %templates:wrap
function milestones:section-link($node as node(), $model as map(*)) {
    let $title := $model?data/tei:head[1]/string()
    return <a href="$app/{$model?base-path}/{$model?document-id}/{$model?section-id}">{$title}</a>
};

declare
    %templates:wrap
function milestones:dropdown($node as node(), $model as map(*), $document-id as xs:string?) {
    <option value="">Choose one</option>
    ,
    for $c in collection($milestones:MILESTONES_CHAPTERS_COL)/tei:TEI
    let $period-id := substring-before(util:document-name($c), '.xml')
    let $selected := if ($document-id = $period-id) then attribute selected {"selected"} else ()
    let $brief-title := $c//tei:title[@type='short']/string()
    order by $period-id
    return
        <option>{
            attribute value { app:fix-href("$app/milestones/" || $period-id) },
            $selected,
            $brief-title
        }</option>
    ,
    <option value="{app:fix-href('$app/milestones/all')}">... view all</option>
};

declare function milestones:list($node, $model) {
    for $milestone in collection($milestones:MILESTONES_CHAPTERS_COL)//tei:text
        let $docid := replace(util:document-name($milestone), '.xml$', '')
        let $startyear := replace($docid, '^(\d{4})-\d{4}', '$1')
        let $periodheading := $milestone/tei:front/tei:div/tei:head
        let $periodheadingurl := concat("$app/milestones/", $docid)
        order by xs:integer($startyear)
        return
            <div>
                <h3><a href="{$periodheadingurl}">{data($periodheading)}</a></h3>
                <ul class="list-unstyled">
                    {
                    for $item in $milestone/tei:body/tei:div
                    let $title := $item/tei:head
                    let $itemid := $item/@xml:id
                    let $url := concat("$app/milestones/", $docid, '/', $itemid)
                    return
                       <li>
                           <a href="{$url}">{data($title)}</a>
                       </li>
                    }
                </ul>
            </div>
};
