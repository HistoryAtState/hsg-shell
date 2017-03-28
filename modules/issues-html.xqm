xquery version "3.0";

module namespace issues = "http://history.state.gov/ns/site/hsg/issues-html";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $issues:RDCR_COL := '/db/apps/rdcr';
declare variable $issues:RDCR_ISSUES_COL := $issues:RDCR_COL || '/issues';

declare function issues:list($node, $model) {
    let $titles := collection($issues:RDCR_ISSUES_COL)//tei:title[@type='short']
    for $letter in distinct-values($titles/substring(upper-case(.), 1, 1))
    order by $letter
    return
        <div>
            <h3>{$letter}</h3>
            <ul>
                {
                for $item in collection($issues:RDCR_ISSUES_COL)//tei:title[@type='short'][starts-with(., $letter)]
                let $itemid := replace(util:document-name($item), '.xml', '')
                order by $item
                return
                   <li>
                       <a href="$app/countries/issues/{$itemid}">{$item/string()}</a>
                   </li>
                }
            </ul>
        </div>
};

(: Page title for countries/issues/article:)
declare
    %templates:wrap
function issues:issues-pagetitle ($node, $model) {
    concat(root($model?data)//tei:title[@type = 'short']/string(), ' - Issues - Countries')
};

(: Headline for countries/issues/article :)
declare
    %templates:wrap
function issues:issues-title($node, $model) {
    root($model?data)//tei:title[@type = 'complete']/string()
};

