xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-news";

import module namespace t="http://history.state.gov/ns/site/hsg/xqsuite" at "../xqsuite.xqm";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "../app.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "../pages.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "../config.xqm";
import module namespace news = "http://history.state.gov/ns/site/hsg/news" at "../news.xqm";
import module namespace ut="http://history.state.gov/ns/site/hsg/app-util" at "../app-util.xqm";
import module namespace templates="http://exist-db.org/xquery/templates";

declare namespace test="http://exist-db.org/xquery/xqsuite";
declare namespace a="http://www.w3.org/2005/Atom";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare boundary-space preserve;

declare variable $x:test_col := collection('/db/apps/hsg-shell/tests/data/news');

(:
 :  WHEN calling news:init-news-list()
 :  GIVEN a collection in $model?collection
 :  GIVEN a position to start from, $start
 :  GIVEN a number of entries to return, $num
 :  THEN return a map with ?entries as $num atom entries from $model?collection
 :  AND ?total as the integer total of entries in $model?collection 
 :)

declare
    %test:assertEquals(54)
function x:test-init-news-list-total(){
    let $model := map{
            "collection": $x:test_col
        }
    let $actual := news:init-news-list((), $model, 1, 5)
    return $actual?total
};

declare
    %test:assertEquals(
        "press-release-frus1981-88v11",
        "carousel-112"
    )
function x:test-init-news-list-articles(){
    let $model := map{
            "collection": $x:test_col
        }
    let $actual := news:init-news-list((), $model, 2, 2)
    let $entries := $actual?entries
    return $entries ! /a:entry/a:id/text()
};

(:
 :  WHEN calling news:sorted()
 :  GIVEN a sequence of atom entries $entries
 :  GIVEN a $start position in the sequence
 :  GIVEN a number of entries to return, $num
 :  THEN return the entries corresponding to those between the $start
 :  and $end position in the sequence inclusive, where the sequence
 :  has been sorted by date descending.
 :)

declare
    %test:assertEquals(
        "carousel-112",
        "press-release-frus1981-88v04",
        "carousel-111"
    )
function x:test-news-sorted(){
    let $entries := $x:test_col
    let $actual := news:sorted($entries, 3, 3)
    return $actual ! /a:entry/a:id/text()
};

(:
 :  WHEN calling news:type()
 :  GIVEN an atom $entry
 :  THEN return the type of the entry
 :)

declare
    %test:assertEquals("press")
function x:test-news-type(){
    let $entry := doc('/db/apps/hsg-shell/tests/data/news/press/press-release-frus1977-80v11p1.xml')
    return news:type($entry)
};

(:
 :  WHEN calling news:get-sort-date()
 :  GIVEN a supplied atom entry with an updated date
 :  THEN return the updated date as a dateTime
 :)

declare
    %test:assertEquals('true')
function x:test-news-get-sort-date() {
    let $entry := doc('/db/apps/hsg-shell/tests/data/news/carousel/carousel-22.xml')
    let $expected := xs:dateTime('2011-09-29T13:42:00.000-04:00')
    let $actual := news:get-sort-date($entry)
    return if ($expected eq $actual) then 'true' else <result><actual>{$actual}</actual><expected>{$expected}</expected></result>
};

(:
 :  WHEN calling news:init-article()
 :  GIVEN a $document-id and
 :  GIVEN a collection $model?collection
 :  THEN return a map with the atom entry corresponding to $document-id in $collection
 :)

declare
    %test:assertEquals('tumblr-121854126473')
function x:test-news-init-article() {
    let $model := map{
        "collection":   $x:test_col
    }
    let $document-id := "tumblr-121854126473"
    let $actual := news:init-article((), $model, $document-id)
    return $actual?entry/a:entry/a:id/text()
};

(:
 :  WHEN calling news:date
 :  GIVEN a $model map with an atom entry ?entry with $type[not .= 'pr'] and $sort-date
 :  GIVEN a span $node
 :  THEN add the string ("hsg-badge--" || $type) to $node/@class
 :  AND replace the contents of $node with app:format-date-month-short-day-year($sort-date)
 :)

declare
    %test:assertEquals('true')
function x:test-news-date(){
    let $node :=
        <span class="foo bar"/>
    let $model := map{
        "collection": $x:test_col,
        "entry": doc('/db/apps/hsg-shell/tests/data/news/carousel/carousel-22.xml')
    }
    let $expected := 
        <span class="foo bar hsg-badge--carousel" dateTime="2011-09-29">Sep 29, 2011</span>
    let $actual := news:date($node, $model)
    return if (deep-equal($expected, $actual)) then 'true' else <result><actual>{$actual}</actual><expected>{$expected}</expected></result>
};

(:
 :  WHEN calling news:date
 :  GIVEN a $model map with an atom entry ?entry with $type[ .= 'pr'] and $sort-date
 :  GIVEN a span $node
 :  THEN add the string ("hsg-badge--press") to $node/@class
 :  AND replace the contents of $node with app:format-date-month-short-day-year($sort-date)
 :)

declare
    %test:assertEquals('true')
function x:test-news-date-press(){
    let $node :=
        <span class="foo bar"/>
    let $model := map{
        "collection": $x:test_col,
        "entry": doc('/db/apps/hsg-shell/tests/data/news/press/press-release-frus1969-76ve15p2Ed2.xml')
    }
    let $expected := 
        <span class="foo bar hsg-badge--press" dateTime="2021-02-12">Feb 12, 2021</span>
    let $actual := news:date($node, $model)
    return if (deep-equal($expected, $actual)) then 'true' else <result><actual>{$actual}</actual><expected>{$expected}</expected></result>
};

(:
 :  WHEN calling news:title
 :  GIVEN a $entry
 :  RETURN the title nodes from the entry
 :)

declare
    %test:assertEquals('true')
function x:test-news-title() {
    let $entry := doc('/db/apps/hsg-shell/tests/data/news/carousel/carousel-111.xml')
    let $expected := 
        <div xmlns="http://www.w3.org/1999/xhtml">Now Available: <em>Foreign Relations of the United States</em>, 1969–1976, Volume
            E–15, Part 2, Documents on Western Europe, 1973–1976, Second, Revised Edition</div>
    let $actual := <div xmlns="http://www.w3.org/1999/xhtml">{
        news:title($entry)
    }</div>
    return if (deep-equal($expected, $actual)) then 'true' else <result><actual>{$actual}</actual><expected>{$expected}</expected></result>
};

(:
 :  WHEN calling news:title-link
 :  GIVEN a $model?entry
 :  GIVEN a <a/> $node
 :  RETURN the <a/> node with preserved @*
 :  AND @href corresponding to $model?entry/a:entry/a:link[@rel eq 'self']/@href
 :  AND content corresponding to news:title($node, $model)
 :  AND remove $node/@data-template
 :)

declare
    %test:assertEquals('true')
function x:test-news-title-link(){
    let $node := <a class="hsg-news__more" target="_blank" data-template="news:read-more-link"/>
    let $entry := doc('/db/apps/hsg-shell/tests/data/news/carousel/carousel-26.xml')
    let $model := map{
        "entry":    $entry 
    }
    let $expected := <a class="hsg-news__more" target="_blank" href="/exist/apps/hsg-shell/news/carousel-26">{news:title($entry)}</a>
  let $actual := news:title-link($node, $model)
    return  if (deep-equal($expected, $actual)) then 'true' else <result><actual>{$actual}</actual><expected>{$expected}</expected></result>
};

(:
 :  WHEN calling news:further-link
 :  GIVEN a $model?entry with one 'further' type of $link
 :      (//a:link[not(@rel = ('self', 'enclosure'))])
 :  GIVEN a $node/a template hyperlink
 :  THEN return a hyperlink with @href set to $link/$href
 :  AND set the text content to $link/@title (if present)
 :  AND set the text content to 'Visit Resource' (if not)
 :  AND preserve any other attributes from $node/a
 :)

declare
    %test:assertEquals('true')
function x:test-news-further-link(){
    let $node := <a class="hsg-news__more" target="_blank"/>
    let $entry := doc('/db/apps/hsg-shell/tests/data/news/twitter/twitter-996046266021896194.xml')
    let $model := map{
        "entry":    $entry
    }
    let $expected := <a class="hsg-news__more" target="_blank" href="https://twitter.com/HistoryAtState/status/996046266021896194">View Twitter Post</a>
    let $actual := news:further-link($node, $model)
    return  if (deep-equal($expected, $actual)) then 'true' else <result><actual>{$actual}</actual><expected>{$expected}</expected></result>
};

(:
 :  WHEN calling news:summary
 :  GIVEN an atom entry as $model?entry
 :  GIVEN that entry has an non-empty summary
 :  THEN generate a summary from a:entry/a:summary/xhtml:div/node()
 :)

declare
    %test:pending('No test data yet')
function x:test-news-summary-summary(){};

(:
 :  WHEN calling news:summary
 :  GIVEN an atom entry as $model?entry
 :  GIVEN that entry has no non-empty summary
 :  THEN generate a summary from a:entry/a:content/xhtml:div/node()
 :)

declare
    %test:assertEquals('true')
function x:test-news-summary-no-summary(){
    let $node := <div xmlns="http://www.w3.org/1999/xhtml"/>
    let $entry := doc('/db/apps/hsg-shell/tests/data/news/twitter/twitter-996046266021896194.xml')
    let $model := map{
        "entry":    $entry
    }
    let $expected.raw as element(xhtml:div) := 
        <div xmlns="http://www.w3.org/1999/xhtml" xml:space="preserve"> On June 19, 2009, Secretary of State Clinton announced that same-sex partners of <a  href="https://twitter.com/StateDept">@StateDept</a> employees would be entitled to the benefits and allowances extended to family members. <a href="https://history.state.gov/departmenthistory/timeline/2000-2009">history.state.gov/departmenthist…</a> <a href="https://twitter.com/search?q=%23twitterstorians&amp;src=hash">#twitterstorians</a> </div>
    let $expected := $expected.raw/node() => ut:normalize-nodes()
    let $actual := news:summary($node, $model) => ut:normalize-nodes()
    return  if (deep-equal($expected, $actual)) then 'true' else <result><actual>{$actual}</actual><expected>{$expected}</expected></result>
};

(:
 :  WHEN calling news:article-content
 :  GIVEN an atom entry as $model?entry
 :  THEN generate content from a:entry/a:content/xhtml:div/node()
 :)

declare
    %test:assertEquals('true')
function x:test-news-article-content(){
    let $node := <div xmlns="http://www.w3.org/1999/xhtml"/>
    let $entry := doc('/db/apps/hsg-shell/tests/data/news/twitter/twitter-996046266021896194.xml')
    let $model := map{
        "entry":    $entry
    }
    let $expected := $entry/a:entry/a:content/xhtml:div
    let $actual := news:article-content($node, $model)
    return  if (deep-equal($expected, $actual)) then 'true' else <result><actual>{$actual}</actual><expected>{$expected}</expected></result>
};

(:
 :  WHEN calling news:thumbnail
 :  GIVEN an atom entry as $model?entry
 :  GIVEN that entry has a thumbnail image (/a:entry/a:link[@rel eq 'enclosure'])
 :  THEN insert the linked image
 :)
declare %test:assertEquals('true') function x:test-news-thumbnail(){
    let $node := <div xmlns="http://www.w3.org/1999/xhtml"/>
    let $entry := doc('/db/apps/hsg-shell/tests/data/news/press/press-release-frus1969-76ve15p2Ed2.xml')
    let $model := map{
        "entry":    $entry
    }
    let $expected := 
        <img src="https://static.history.state.gov/frus/frus1969-76ve15p2Ed2/covers/frus1969-76ve15p2Ed2.jpg" alt="Cover image of frus1969-76ve15p2Ed2"/>
    let $actual := news:thumbnail($node, $model)
    return  if (deep-equal($expected, $actual)) then 'true' else <result><actual>{$actual}</actual><expected>{$expected}</expected></result>
};