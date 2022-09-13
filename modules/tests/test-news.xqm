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

declare variable $x:test_col := collection('../../tests/data/news');

(:
 :  WHEN calling news:init-news-list()
 :  GIVEN a position to start from, $start
 :  GIVEN a number of entries to return, $num
 :  THEN return a map with ?entries as $num atom entries from $model?collection
 :  AND ?total as the integer total of entries in ?entries 
 :)
declare
    %test:assertEquals('true')
function x:test-init-news-list-collection(){
    let $expected := collection('../../tests/data/news')
    let $model := map{
            "collection": $x:test_col
        }
    let $actual := news:init-news-list((), $model, 1, 5)
    return 
        if (deep-equals($actual?collection, $expected))
        then 'true'
        else 
            <result>
                <actual>{$actual?collection}</actual>
                <expected>{$expected}</expected>
            </result>
};

declare
    %test:assertEquals(5)
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
    let $actual := news:init-news-list((), $model, 2, 3)
    let $entries := $actual?entries
    return $entries/a:entry/a:id
};

(:
 :  WHEN calling news:sorted()
 :  GIVEN a sequence of atom entries $entries
 :  GIVEN a $start position in the sequence
 :  GIVEN an $end position in the sequence
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
    let $actual := news:sorted($entries, 3, 5)
    return $actual/a:entry/a:id
};

(:
 :  WHEN calling news:init-news-entry()
 :  GIVEN a model containing an atom entry as ?to
 :  GIVEN no supplied $document-id
 :  THEN return a map with ?entry with the result of ?to
 :  AND ?type taken from ?entry
 :  AND ?sort-date taken from ?entry
 :)

(:
 :  WHEN calling news:init-news-entry()
 :  GIVEN model NOT containing ?to
 :  GIVEN a model containing the ?collection of atom entries
 :  GIVEN a supplied $document-id
 :  THEN return a map with ?entry corresponding to $document-id
 :  AND ?type taken from ?entry
 :  AND ?sort-date taken from ?entry
 :)

(:
 :  WHEN calling news:get-sort-date()
 :  GIVEN a supplied atom entry with an updated date
 :  THEN return the updated date as a dateTime
 :)

(:
 :  WHEN calling news:get-sort-date()
 :  GIVEN a supplied atom entry with no updated date
 :  THEN return the created date as a dateTime
 :)

(:
 :  WHEN calling news:date
 :  GIVEN a $model map with ?type
 :  GIVEN a $model map with ?sort-date
 :  GIVEN a span $node
 :  THEN add the string ("hsg-badge--" || ?type) to $node/@class
 :  AND replace the contents of $node with app:format-date-month-short-day-year($model?sort-date)
 :)

(:
 :  WHEN calling news:title
 :  GIVEN a $model?entry
 :  RETURN the title nodes from the entry
 :)

(:
 :  WHEN calling news:heading-link
 :  GIVEN a $model?entry
 :  GIVEN a <a/> $node
 :  RETURN the <a/> node with preserved @class
 :  AND @href corresponding to $model?entry/a:entry/a:link[@rel eq 'self']/@href
 :  AND content corresponding to news:title($node, $model)
 :)
 
(:
 :  WHEN calling news:further-links
 :  GIVEN a $model?entry with one or more 'further' types of $link
 :      (//a:link[not(@rel = ('self', 'enclosure'))])
 :  GIVEN a $node/a template hyperlink
 :  THEN return a hyperlink for each $link
 :  AND set @href to $link/$href
 :  AND set the text content to $link/@title (if present)
 :  AND set the text content to 'Visit Resource' (if not)
 :  AND preserve any other attributes from $node/a
 :  
 :)

(:
 :  WHEN calling news:summary
 :  GIVEN an atom entry as $model?entry
 :  GIVEN that entry has an non-empty summary
 :  THEN generate a summary from a:entry/a:summary/xhtml:div/node()
 :)

(:
 :  WHEN calling news:summary
 :  GIVEN an atom entry as $model?entry
 :  GIVEN that entry has no non-empty summary
 :  THEN generate a summary from a:entry/a:content/xhtml:div/node()
 :)
 
(:
 :  WHEN calling news:article-content
 :  GIVEN an atom entry as $model?entry
 :  THEN generate content from a:entry/a:content/xhtml:div/node()
 :)