xquery version "3.1";

(:
 : Module for handling of atom news entries
 :)
module namespace news = "http://history.state.gov/ns/site/hsg/news";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";

declare namespace a="http://www.w3.org/2005/Atom";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare
    %templates:replace
function news:init-news ($node as node(), $model as map(*)) {
    (: Add metadata to new model
        $title := get news title
        $news := get all sorted-by-date news
        $start := get pagination parameter e.g. start=11

    let $news-model := map:merge((
        $model,
        map {
            'title': $title,
            'total': count($news),
            'news-list': subsequence($news, $start, 20 (:e.g. 20 results per page:))
        }
    ))

    return
        element { node-name($node) } {
            $node,
            $news-model
        }
    :)
};


declare
function news:sorted ($news-list) {
    (:
        sort news by date:
        1. loop through $news-list
        2. order by date descending
        3. return news
    :)
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

    let $type := $model?type
    let $raw-date := $model?date-published
    let $date := app:format-date-month-short-day-year($raw-date)
    return
        element { node-name($node) } {
            $node/@*[not(local-name() = 'class')],
            attribute class {
                string-join(($node/@class/string(), "hsg-badge--" || $type), ' ')
            },
            $date
        }
};

declare
    %templates:wrap
function news:heading ($node as node(), $model as map(*) )  {
   $model?title/string()
};

declare
    %templates:replace
function news:heading-link ($node as node(), $model as map(*)) {
    (:
        1. get URL as string
        2. return element with href attribute containing url
    :)
};

declare
    %templates:wrap
function news:summary ($node as node(), $model as map(*) ) {
    (: retrieve summary from news-model as string :)
};

declare
    %templates:replace
function news:read-more-link ($node as node(), $model as map(*)) {
    let $label := $model?label/string()
    let $url := $model?external-link

    return
        element { node-name( $node ) } {
            $node/@*[not(local-name() = 'href')],
            attribute href { $url },
            $label
        }
};

(:
 : Initialize News Articles
 : Populate $model with news article data
 :)
declare
    %templates:replace
function news:init-article($node as node(), $model as map(*), $document-id as xs:string) {
    let $news := $config:PUBLICATIONS?news?select-document($document-id)
    let $type := substring-before($news/a:entry/a:id/string(), '-')
    let $title := $news/a:entry/a:title/xhtml:div
    let $id := $document-id
    let $external-link := $news/a:entry/a:link[@rel != 'self']/@href
    let $label := $news/a:entry/a:link/@title
    (:let $thumbnail := get thumbnail if available:)
    let $date-published := $news/a:entry/a:published
    let $updated := $news/a:entry/a:updated
    let $content := $news/a:entry/a:content/xhtml:div

    let $news-model := map:merge((
        $model,
        map {
            'news': $news,
            'title': $title,
            'id': $id,
            'type': $type,
            'external-link': $external-link,
            'date-published': $date-published,
            'updated' : $updated,
            'label' : $label,
            'content' : $content
        }
    ))

    return
        element { node-name( $node ) } {
            $node/@*,
            templates:process($node/node(), $news-model)
        }
};

declare
    %templates:wrap
function news:article-content($node as node(), $model as map(*)) {
    $model?content
};
