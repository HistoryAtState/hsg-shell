xquery version "3.1";

(:
 : Module for handling of atom news entries
 :)
module namespace news = "http://history.state.gov/ns/site/hsg/news";

import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace ut="http://history.state.gov/ns/site/hsg/app-util" at "app-util.xqm";

import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";

declare namespace a="http://www.w3.org/2005/Atom";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare
    %templates:wrap
    %templates:default("start", 1)
    %templates:default("per-page", 20)
function news:init-news-list ($node as node()?, $model as map(*), $start as xs:integer, $per-page as xs:integer) as map(*) {
    let $log := util:log('debug', ('news.xqm, serialize model data =>', serialize($model, map{'indent':true(), 'method':'adaptive'})))
    let $news-list := news:sorted($model?collection, $start, $per-page)
    return (
        map {
            "total":    count($model?collection),
            "entries":  $news-list,
            "hits":     $model?collection
        }
    )
};

declare function news:sorted ($collection, $start as xs:integer, $per-page as xs:integer) {
    let $sorted := (
        for $entry in $collection
        let $date := news:get-sort-date($entry)
        order by $date descending
        return $entry
    )
    return subsequence($sorted, $start, $per-page)
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
    let $entry := $model?entry
    let $type := news:type($entry)
    let $date := news:get-sort-date($entry)
    let $dateTime-attribute := app:format-date-short($date)
    let $classes := tokenize($node/@class, '\s')
    let $add-class := "hsg-badge--" || $type
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
    ut:normalize-nodes($entry/a:entry/a:title/xhtml:div/node())
};

declare
    %templates:replace
function news:title-link ($node as node(), $model as map(*)) {
    element { node-name($node) } {
        $node/@*[not(local-name() = 'data-template')],
        attribute href { app:fix-href($model?entry/a:entry/a:link[@rel eq 'self']/@href)},
        news:title($model?entry)
    }
};

declare
    %templates:wrap
function news:summary ($node as node(), $model as map(*) ) {
    let $source := 
        if ($model?entry/a:entry/a:summary/normalize-space(.) ne '')
        then
            $model?entry/a:entry/a:summary/xhtml:div
        else
            $model?entry/a:entry/a:content/xhtml:div
    let $stylesheet-node := doc("/db/apps/hsg-shell/modules/lib/xhtml.xsl")
    let $transformerAttributes := 
        <attributes>
            <attr name="http://saxon.sf.net/feature/initialMode" value="summary"/>
        </attributes>
    let $transformed := transform:transform($source, $stylesheet-node, (), $transformerAttributes,'')
    return app:fix-links($transformed)
};

declare
    %templates:replace
function news:further-link ($node as node(), $model as map(*)) {
    let $entry := $model?entry
    let $link := ($entry/a:entry/a:link[not(@rel = ('self', 'enclosure'))])[1]
    return
        element { node-name( $node ) } {
        
            $node/@*[not(local-name() = ('target', 'href'))],
            if (starts-with($link/@href, '/'))
            then ()
            else attribute target {"_blank"},
            attribute href {app:fix-href($link/@href)},
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
    return 
        if (empty($entry)) then (
            request:set-attribute("hsg-shell.errcode", 404),
            request:set-attribute("hsg-shell.path", "news/" || $document-id),
            error(QName("http://history.state.gov/ns/site/hsg", "not-found"), "publication news document " || $document-id || " not found")
        )
        else
            map{
                "entry":    $entry
            }
};

declare function news:article-content($node as node(), $model as map(*)) {
    let $source := $model?entry/a:entry/a:content/xhtml:div/node()
    let $stylesheet-node := doc("/db/apps/hsg-shell/modules/lib/xhtml.xsl")
    let $transformerAttributes := ()
    let $transformed := transform:transform($source, $stylesheet-node, (), $transformerAttributes,'')
    return (
        element {QName("http://www.w3.org/1999/xhtml", local-name($node))} {
            $node/(@* except @data-template),
            app:fix-links($transformed)
        }
    )
};

(:~
 : Check, if a news article contains a thumbnail
 :)
declare
function news:has-thumbnail ($news) as xs:boolean {
    exists($news/a:entry/a:link[@rel eq 'enclosure'])
};

(:~
 : Render the thumbnail for the news article, if available,
 : keep classnames of the to-be-replaced template node
 :)
declare
    %templates:replace
function news:thumbnail($node as node()?, $model as map(*)) {
    if (news:has-thumbnail($model?entry))
    then (
        let $thumbnail := $model?entry/a:entry/a:link[@rel eq 'enclosure']
        let $src := $thumbnail/@href
        let $alt := $thumbnail/@title
            return (
                element img {
                    $node/@*,
                    attribute src { $src },
                    attribute alt { $alt }
                }
            )
    )
    else ()
};