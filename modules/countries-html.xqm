xquery version "3.0";

module namespace ch = "http://history.state.gov/ns/site/hsg/countries-html";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $ch:RDCR_COL := '/db/apps/rdcr';
declare variable $ch:RDCR_ARTICLES_COL := $ch:RDCR_COL || '/articles';

declare %templates:wrap function ch:load-countries($node as node(), $model as map(*)) {
    let $ordered-articles := 
        for $c in collection($ch:RDCR_ARTICLES_COL)/tei:TEI
        order by util:document-name($c)
        return $c
    let $content := map { "articles": $ordered-articles }
    let $html := templates:process($node/*, map:new(($model, $content)))
    return
        $html
};

(: Page title :)
declare
    %templates:wrap
function ch:page-title($node as node(), $model as map(*)) {
    concat(root($model?data)//tei:title[@type='short']/string(), ' - Countries')
};

(: Main heading with complete article title :)
declare
    %templates:wrap
function ch:article-heading($node as node(), $model as map(*)) {
    root($model?data)//tei:title[@type='complete']/string()
};

(: Short article title, used as dropdown label :)
declare
    %templates:wrap
function ch:article-title($node as node(), $model as map(*)) {
    root($model?article)//tei:title[@type='short']/string()
};


declare function ch:article-href-value-attribute($node as node(), $model as map(*)) {
    let $article-id := substring-before(util:document-name($model?article), '.xml')
    return
        attribute value { app:fix-href("$app/countries/" ||  $article-id) }
};

declare
    %templates:wrap
function ch:dropdown($node as node(), $model as map(*), $document-id as xs:string?) {
    <option value="">Choose one</option>
    ,
    for $c in collection($ch:RDCR_ARTICLES_COL)/tei:TEI
    let $article-id := substring-before(util:document-name($c), '.xml')
    let $selected := if ($document-id = $article-id) then attribute selected {"selected"} else ()
    let $brief-title := $c//tei:title[@type='short']/string()
    order by $article-id
    return
        <option>{ 
            attribute value { app:fix-href("$app/countries/" || $article-id) },
            $selected,
            $brief-title
        }</option>
    ,
    <option value="{app:fix-href('$app/countries/all')}">... view all</option>
};

(: TODO: Turn into two-column listing as in pocom:chiefs-countries-list() :)
declare function ch:list($node, $model) {
    let $titles := collection($ch:RDCR_ARTICLES_COL)//tei:title[@type='short']
    for $letter in distinct-values($titles/substring(upper-case(.), 1, 1))
    order by $letter
    return
        <div>
            <h3>{$letter}</h3>
            <ul>
                {
                for $item in collection($ch:RDCR_ARTICLES_COL)//tei:title[@type='short'][starts-with(., $letter)]
                let $itemid := replace(util:document-name($item), '.xml', '')
                order by $item
                return
                   <li> 
                       <a href="$app/countries/{$itemid}">{$item/string()}</a>
                   </li>
                }
            </ul>
        </div>
};
