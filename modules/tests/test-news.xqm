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
 :  THEN return a map with ?collection := $config:NEWS_COL
 :  AND ?total as an integer
 :  AND ?entries as $num atom entries
 :)

(:
 :  WHEN calling news:sorted()
 :  GIVEN a sequence of atom entries $entries
 :  GIVEN a $start position in the sequence
 :  GIVEN an $end position in the sequence
 :  THEN return the entries corresponding to those between the $start
 :  and $end position in the sequence inclusive, where the sequence
 :  has been sorted by date descending.
 :)

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