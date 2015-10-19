xquery version "3.0";

module namespace milestones = "http://history.state.gov/ns/site/hsg/milestones-html";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $milestones:MILESTONES_COL := '/db/apps/milestones';
declare variable $milestones:MILESTONES_CHAPTERS_COL := $milestones:MILESTONES_COL || '/chapters';

declare
    %templates:wrap
function milestones:dropdown($node as node(), $model as map(*), $chapter-id as xs:string?) {
    <option value="">Choose one</option>
    ,
    for $c in collection($milestones:MILESTONES_CHAPTERS_COL)/tei:TEI
    let $c-id := substring-before(util:document-name($c), '.xml')
    let $selected := if ($c-id = $chapter-id) then attribute selected {"selected"} else ()
    let $brief-title := $c//tei:title[@type='short']/string()
    order by $c-id
    return
        <option>{ 
            attribute value { "$app/milestones/" || $c-id },
            $selected,
            $brief-title
        }</option>
    ,
    <option value="$app/all">... view all</option>
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
                <ul>
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

declare function milestones:chapter-title($node, $model, $chapter-id as xs:string) {
    let $doc := doc($milestones:MILESTONES_CHAPTERS_COL || '/' || $chapter-id || '.xml')
    let $title := $doc//tei:title[@type='complete']/string()
    return
        $title
};

declare function milestones:chapter-intro($node, $model, $chapter-id as xs:string) {
    let $doc := doc($milestones:MILESTONES_CHAPTERS_COL || '/' || $chapter-id || '.xml')
    let $text := $doc//tei:front
    return
        pages:process-content($config:odd, $text)
};

declare function milestones:article-title($node, $model, $chapter-id as xs:string, $article-id as xs:string) {
    let $doc := doc($milestones:MILESTONES_CHAPTERS_COL || '/' || $chapter-id || '.xml')
    let $title := $doc//tei:title[@type='complete']/string()
    return
        $title
};

declare function milestones:article($node, $model, $chapter-id as xs:string, $article-id as xs:string) {
    let $doc := doc($milestones:MILESTONES_CHAPTERS_COL || '/' || $chapter-id || '.xml')
    let $text := $doc/id($article-id)
    return
        pages:process-content($config:odd, $text)
};