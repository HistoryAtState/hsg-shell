xquery version "3.0";

module namespace archives = "http://history.state.gov/ns/site/hsg/archives-html";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $archives:ARCHIVES_COL := '/db/apps/wwdai';
declare variable $archives:ARCHIVES_ARTICLES_COL := $archives:ARCHIVES_COL || '/articles';

declare
    %templates:wrap
function archives:dropdown($node as node(), $model as map(*), $country-id as xs:string?) {
    <option value="">Choose one</option>
    ,
    for $c in collection($archives:ARCHIVES_ARTICLES_COL)/tei:TEI
    let $article-id := substring-before(util:document-name($c), '.xml')
    let $selected := if ($article-id = $country-id) then attribute selected {"selected"} else ()
    let $brief-title := $c//tei:title[@type='short']/string()
    order by $article-id
    return
        <option>{ 
            attribute value { "$app/countries/archives/" || $article-id },
            $selected,
            $brief-title
        }</option>
    ,
    <option value="$app/all">... view all</option>
};

declare function archives:list($node, $model) {
    let $titles := collection($archives:ARCHIVES_ARTICLES_COL)//tei:title[@type='short']
    for $letter in distinct-values($titles/substring(upper-case(.), 1, 1))
    order by $letter
    return
        <div>
            <h3>{$letter}</h3>
            <ul>
                {
                for $item in collection($archives:ARCHIVES_ARTICLES_COL)//tei:title[@type='short'][starts-with(., $letter)]
                let $itemid := replace(util:document-name($item), '.xml', '')
                order by $item
                return
                   <li> 
                       <a href="$app/countries/archives/{$itemid}">{$item/string()}</a>
                   </li>
                }
            </ul>
        </div>
};

declare function archives:article-title($node, $model, $country-id as xs:string) {
    let $doc := doc($archives:ARCHIVES_ARTICLES_COL || '/' || $country-id || '.xml')
    let $title := $doc//tei:title[@type='complete']/string()
    return
        $title
};

declare function archives:article($node, $model, $country-id as xs:string) {
    let $doc := doc($archives:ARCHIVES_ARTICLES_COL || '/' || $country-id || '.xml')
    let $text := $doc//tei:body
    return
        pages:process-content($config:odd, $text)
};