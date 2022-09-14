xquery version "3.1";

(:
 : Module for handling of atom news entries
 :)
module namespace news = "http://history.state.gov/ns/site/hsg/news";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";

declare namespace a="http://www.w3.org/2005/Atom";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare
    %templates:wrap
    %templates:default("start", 1)
    %templates:default("num", 20)
function news:init-news-list ($node as node()?, $model as map(*), $start as xs:integer, $num as xs:integer) as map(*) {
    let $_ := util:log('news', serialize($model, map{'indent':true(), 'method':'adaptive'}))
    let $news-list := news:sorted($model?collection, $start, $num)
    return map{
        "total":    count($news-list),
        "entries":  $news-list
    }
};


declare function news:sorted ($collection, $start as xs:integer, $num as xs:integer) {
    let $sorted := (
        for $entry in $collection
        let $date := news:get-sort-date($entry)
        order by $date descending
        return $entry
    )
    return subsequence($sorted, $start, $num)
};

declare function news:get-sort-date($entry as document-node(element(a:entry))) {
    xs:dateTime($entry/a:entry/a:updated)
};

declare function news:type($entry as document-node(element(a:entry))) as xs:string? {
    $entry/a:entry/a:category[@scheme="http://history.state.gov/ns/site/hsg/news"]/@term
};

(:
 : Colored badges with date
 : 1. retrieve news type from news-model, e.g. 'twitter', 'tumblr'
 : 2. retrieve date string to display in badge
 : 3. return
 :    * element with attr `classname` || --`type` for badge-color =>  `hsg-badge--twitter`
 :    * date string as node content
 :)
declare
    %templates:replace
function news:date ($node as node(), $model as map(*) ) {
    let $dateTime-attribute := app:format-date-short($raw-date)
    let $entry := $model?entry
    let $type := news:type($entry)
    let $date := news:get-sort-date($entry)
    let $classes := tokenize($node/@class, '\s')
    let $add-class := 
        if ($type ne 'pr') 
        then "hsg-badge--" || $type 
        else "hsg-badge--press"
    return
        element { node-name($node) } {
            $node/@*[not(local-name() = 'class')],
            attribute class {
                string-join(($classes, $add-class), ' ')
            },
            attribute dateTime {
                $dateTime-attribute
            },
            app:format-date-month-short-day-year($date)
        }
};

declare
    %templates:wrap
function news:title($node as node()?, $model as map(*)?) {
    (: allows calling news:title from templating :)
    news:title($model?entry)
};

declare
    %templates:wrap
function news:title ($entry as document-node(element(a:entry)) ) {
   $entry/a:entry/a:title/xhtml:div/node()
};

declare
    %templates:replace
function news:title-link ($node as node(), $model as map(*)) {
    element { node-name($node) } {
        $node/@*[not(local-name() = 'data-template')],
        attribute href {
            let $app-root :=
                try {$app:APP_ROOT}
                catch * {
                (: Assume APP_ROOT is '/exist/apps/hsg-shell'; Needed for xqsuite testing,
                         since there is no context for calls to e.g. request:get-header(). :)
                '/exist/apps/hsg-shell'
                }
            return $app-root || $model?entry/a:entry/a:link[@rel eq 'self']/@href
        },
        news:title($model?entry)
    }
};

declare
    %templates:wrap
function news:summary ($node as node(), $model as map(*) ) {
    $model?entry/a:entry/a:content/xhtml:div/node()
};

declare
    %templates:replace
function news:further-link ($node as node(), $model as map(*)) {
    let $entry := $model?entry
    let $link := ($entry/a:entry/a:link[not(@rel = ('self', 'enclosure'))])[1]
    return
        element { node-name( $node ) } {
            $node/@*[not(local-name() = 'href')],
            $link/@href,
            string($link/@title)
        }
};

(:
 : Initialize News Articles
 : Populate $model with news article data
 :)
declare function news:init-article($node as node()?, $model as map(*), $document-id as xs:string) {
    let $collection := $model?collection
    let $entry as document-node(element(a:entry))? := $collection[.//a:id eq $document-id]
    return map{
        "entry":    $entry
    }
};

declare
    %templates:wrap
function news:article-content($node as node(), $model as map(*)) {
    $model?entry/a:entry/a:content/xhtml:div/node()
};
