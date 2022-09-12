xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-news";

import module namespace t="http://history.state.gov/ns/site/hsg/xqsuite" at "../xqsuite.xqm";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "../app.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "../pages.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "../config.xqm";
import module namespace news = "http://history.state.gov/ns/site/hsg/news" at "../news.xqm";
import module namespace templates="http://exist-db.org/xquery/templates";

declare namespace test="http://exist-db.org/xquery/xqsuite";
declare namespace a="http://www.w3.org/2005/Atom";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

(:
 :  WHEN calling news:article-body()
 :  GIVEN an article ID $article
 :  GIVEN the test news collection      TODO TFJH: work out how best to specify collections to separate test data
 :  THEN return the $expected article body
 :)
declare
    %test:assertEquals('true')
function x:test-news-article-body() {
    let $article := 'twitter-996375936852480000'
    let $node := <div/> (: xqsuite is not great at replicating the templating functions, so this is really just a placeholder :)
    let $model := map{} (: we don't need too much from the model here. :)
    let $actual := news:article-body($node, $model, $article)
    let $expected := (
         <p xmlns="http://www.w3.org/1999/xhtml">Students! Apply now to intern in 2019 at the <a href="https://twitter.com/StateDept">@StateDept</a> Office of the Historian
                        (<a href="https://twitter.com/HistoryAtState">@HistoryAtState</a>)! <a href="https://www.historians.org/news-and-advocacy/calendar/event-detail?eventId=1817">historians.org/news-and-advoc…</a>
            <a href="https://twitter.com/AHAhistorians">@AHAhistorians</a>
            <a href="https://twitter.com/search?q=%23twitterstorians&amp;src=hash">#twitterstorians</a>
         </p>
      )
    return 
        if (deep-equal($actual, $expected))
        then 
            'true' 
        else 
            <result>
                <actual>{$actual}</actual>
                <expected>{$expected}</expected>
            </result>
};