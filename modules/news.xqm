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

declare
    %templates:replace
function news:date ($node as node(), $model as map(*) ) {
    (:
        1. retrieve news type from news-model
        2. retrieve date string to display in badge
        3. return
            * element with attr `classname` || --`type` for badge-color =>  `hsg-badge--twitter`
            * date string as node content
    :)
};

declare
    %templates:replace
function news:heading ($node as node(), $model as map(*) )  {
    (: retrieve news title string from news-model :)
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
function news:text ($node as node(), $model as map(*) ) {
    (: retrieve description text from news-model as string :)
};

declare
    %templates:wrap
function news:read-more-link ($node as node(), $model as map(*)) {
    (:
        1. retrieve news type from news-model
        2. retrieve text label for link
        3. retrieve URL depending on type
        4. return
            * attr href with link
            * label string as node content
    :)
};

declare
    %templates:wrap
function news:article-body($node as node(), $model as map(*), $document-id as xs:string) as node()* {
    let $article := $config:PUBLICATIONS?news?select-document($document-id)
    let $article-body := $article/a:entry/a:content/xhtml:div
    return $article-body/node()
};
