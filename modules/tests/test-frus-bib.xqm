xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-frus-bib";

import module namespace fb="http://history.state.gov/ns/site/hsg/frus-bib" at "../frus-bib.xqm";
import module namespace t="http://history.state.gov/ns/site/hsg/xqsuite" at "../xqsuite.xqm";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "../app.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "../pages.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "../config.xqm";
import module namespace ut="http://history.state.gov/ns/site/hsg/app-util" at "../app-util.xqm";
import module namespace templates="http://exist-db.org/xquery/templates";

declare namespace test="http://exist-db.org/xquery/xqsuite";
declare namespace a="http://www.w3.org/2005/Atom";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare boundary-space preserve;

declare variable $x:test_col := collection('/db/apps/hsg-shell/tests/data/frus-bib');

(:
 :  WHEN calling fb:init-all-frus()
 :  GIVEN a collection in $model?collection (of FRUS bibliographic data)
 :  GIVEN a position to start from, $start
 :  GIVEN a number of entries to return, $per-page
 :  THEN return a map with $per-page ?volumes-meta documents sorted and selected from $model?collection
 :  AND ?total as the integer total of volume metadata documents in $model?collection 
 :)

(:
 :  WHEN calling fb:sorted()
 :  GIVEN a sequence of volume metadata $model?volumes-meta
 :  GIVEN a $start position in the sequence
 :  GIVEN a number of entries to return, $num
 :  THEN return the entries corresponding to those between the $start
 :  and ($start + $num) positions in the sequence inclusive, where the sequence
 :  has been sorted by $volume-meta/volume/@id ascending.
 :)

(:
 :  WHEN calling fb:id()
 :  GIVEN a $volume-meta document
 :  THEN return the value of $volume-meta/volume/@id
 :)

(:
 :  WHEN calling fb:id()
 :  GIVEN a $node
 :  GIVEN a $model map containing a .?volume-meta document
 :  THEN
 :)
 
(:
 :  WHEN calling fb:title()
 :  GIVEN a $volume-meta document
 :  THEN return the whitespace-normalised content of that document's title ($volume-meta/volume/title[@type eq 'complete'])
 :)

(:
 :  WHEN calling fb:title()
 :  GIVEN a $node
 :  GIVEN a $model map
 :  THEN return (TODO TFJH: what HTML do we want the templating engine to return?)
 :)

(:
 :  WHEN calling fb:thumbnail()
 :  GIVEN a $volume-meta element (with ID $id)
 :  THEN return the thumbnail image URI at https://static.history.state.gov/frus/{$id}/covers/{$id}-thumb.jpg
 :)

(:
 :  WHEN calling fb:thumbnail()
 :  GIVEN an img element $node (TODO TFJH: confirm that this is where the template function will be defined)
 :  GIVEN a $model map with .?volume-meta document
 :  THEN return an img element with @src = fb:thumbnail($model?volume-meta)
 :  AND @alt = "Book Cover of " || fb:title($model?volume-meta) 
 :)

(:
 :  WHEN calling fb:isbn()
 :  GIVEN a $volume-meta document with an ISBN-13 (e.g. frus1969-76v31)
 :  THEN return the 13-digit ISBN (as a string)
 :)
 
(:
 :  WHEN calling fb:isbn()
 :  GIVEN a $volume-meta document without any ISBN (e.g. frus1861)
 :  THEN return the empty sequence
 :)
 
(:
 :  WHEN calling fb:isbn()
 :  GIVEN a $volume-meta document with no ISBN-13 but with an ISBN-10 (no real examples)
 :  THEN return ???  - options are to return the ISBN-10, or to convert to ISBN-13.
 :)

(:
 :  WHEN calling fb:isbn()
 :  GIVEN a $node
 :  GIVEN a $model with a .?volume-meta document
 :  THEN return (TODO TFJH: confirm exact HTML node features to be returned)
 :  AND with value fb:isbn($model?volume-meta)
 :)

(:
 :  WHEN calling fb:pub-status()
 :  GIVEN a $volume-meta document (e.g. frus1969-76v31)
 :  THEN return the publication status $volume-meta/volume/publication-status (e.g. "published")
 :)

(:
 :  WHEN calling fb:pub-status()
 :  GIVEN a $node
 :  GIVEN a $model with a .?volume-meta document
 :  THEN return (TODO TFJH: confirm exact HTML node features to be returned)
 :  AND with value fb:pub-status($model?volume-meta)
 :)