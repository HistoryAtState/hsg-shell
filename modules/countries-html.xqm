xquery version "3.1";

module namespace ch = "http://history.state.gov/ns/site/hsg/countries-html";

import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $ch:RDCR_COL := '/db/apps/rdcr';
declare variable $ch:RDCR_ARTICLES_COL := $ch:RDCR_COL || '/articles';
declare variable $ch:RDCR_ISSUES_COL := $ch:RDCR_COL || '/issues';

declare %templates:wrap function ch:load-countries($node as node(), $model as map(*)) {
    let $ordered-articles :=
        for $article in collection($ch:RDCR_ARTICLES_COL)/tei:TEI
        let $title := $article//tei:title[@type='short']
        let $sort-title := 
            if (starts-with($title, "The ")) then
                replace($title, "^(The) (.+?)(\*?)$", "$2, $1$3")
            else
                $title/string()
        order by $sort-title
        return 
            map { 
                "article": $article,
                "sort-title": $sort-title,
                "letter": $sort-title => substring(1, 1) => upper-case(),
                "article-id": $article => util:document-name() => substring-before(".xml")
            }
    let $content := map { "articles": $ordered-articles }
    let $html := templates:process($node/*, map:merge(($model, $content),  map{"duplicates": "use-last"}))
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
    $model?article?sort-title
};

declare function ch:article-href-value-attribute($node as node(), $model as map(*)) {
    attribute value { app:fix-href("$app/countries/" || $model?article?article-id) }
};

(: Original two-column routine borrowed from pocom:chiefs-countries-list() :)
declare function ch:list($node, $model) {
    let $articles := $model?articles
    let $letter-groups := 
        for $article in $articles
        group by $letter := $article?letter
        order by $letter
        return 
            <div>
                <h3>{$letter}</h3>
                <ul>
                    {
                        for $a in $article
                        order by $a?sort-title
                        return
                           <li>
                               <a href="$app/countries/{$a?article-id}">{$a?sort-title}</a>
                           </li>
                    }
                </ul>
            </div>
    let $count := count($letter-groups)
    return
        <div class="row">
            {
                for $letter-group at $n in $letter-groups
                group by $half := if ($n div $count le .5) then 1 else 2
                order by $half
                return
                    <div class="col-md-6">
                        {
                            $letter-group
                        }
                    </div>
            }
        </div>
};

declare
    %templates:wrap
function ch:issues-list($node as node(), $model as map(*), $document-id as xs:string?) {
    for $c in collection($ch:RDCR_ISSUES_COL)/tei:TEI
    let $article-id := substring-before(util:document-name($c), '.xml')
    let $brief-title := $c//tei:title[@type='short']/string()
    order by $brief-title
    return
        <li><a>{
            attribute href { app:fix-href("$app/countries/issues/" || $article-id) },
            $brief-title
        }</a></li>
};


(: Page title :)
declare
    %templates:wrap
function ch:issues-page-title($node as node(), $model as map(*)) {
    concat(root($model?data)//tei:title[@type='short']/string(), ' - Issues - Countries')
};