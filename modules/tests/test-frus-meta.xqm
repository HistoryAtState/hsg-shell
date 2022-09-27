xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-frus-bib";

import module namespace fm="http://history.state.gov/ns/site/hsg/frus-meta" at "../frus-meta.xqm";
import module namespace frus="http://history.state.gov/ns/site/hsg/frus-html" at "../frus-html.xqm";
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

declare variable $x:test_col := collection('/db/apps/hsg-shell/tests/data/frus-meta');

(:
 :  WHEN calling fm:init-frus-list()
 :  GIVEN a collection in $model?collection (of FRUS bibliographic data)
 :  GIVEN a position to start from, $start
 :  GIVEN a number of entries to return, $per-page
 :  THEN return a map with $per-page ?volumes-meta documents sorted and selected from $model?collection
 :  AND ?total as the integer total of volume metadata documents in $model?collection 
 :)

(:
 :  WHEN calling fm:sorted()
 :  GIVEN a sequence of volume metadata $model?volumes-meta
 :  GIVEN a $start position in the sequence
 :  GIVEN a number of entries to return, $num
 :  THEN return the entries corresponding to those between the $start
 :  and ($start + $num) positions in the sequence inclusive, where the sequence
 :  has been sorted by $volume-meta/volume/@id ascending.
 :)

(:
 :  WHEN calling fm:id()
 :  GIVEN a $volume-meta document
 :  THEN return the value of $volume-meta/volume/@id
 :)

(:
 :  WHEN calling fm:id()
 :  GIVEN a $node
 :  GIVEN a $model map containing a .?volume-meta document
 :  THEN
 :)
 
(:
 :  WHEN calling fm:title()
 :  GIVEN a $volume-meta document
 :  THEN return the whitespace-normalised content of that document's title ($volume-meta/volume/title[@type eq 'complete'])
 :)

(:
 :  WHEN calling fm:title-url()
 :  GIVEN a $volume-meta document
 :  THEN return the (relative) URL of the corresponding FRUS landing page
 :)

(:
 :  WHEN calling fm:title-link()
 :  GIVEN a <a/> $node
 :  GIVEN a $model map
 :  THEN return a link to the volume landing page (fm:title-url())
 :  WITH the text of the link corresponding to fm:title()
 :)

(:
 :  WHEN calling fm:thumbnail()
 :  GIVEN a $volume-meta element (with ID $id)
 :  THEN return the thumbnail image URI at https://static.history.state.gov/frus/{$id}/covers/{$id}-thumb.jpg
 :)

(:
 :  WHEN calling fm:thumbnail()
 :  GIVEN an img element $node 
 :  GIVEN a $model map with .?volume-meta document
 :  THEN return an img element with @src = fm:thumbnail($model?volume-meta)
 :  AND @alt = "Book Cover of " || fm:title($model?volume-meta) 
 :)

(:
 :  WHEN calling fm:isbn()
 :  GIVEN a $volume-meta document with an ISBN-13 (e.g. frus1969-76v31)
 :  THEN return the 13-digit ISBN (as a string)
 :)
 
(:
 :  WHEN calling fm:isbn()
 :  GIVEN a $volume-meta document without any ISBN (e.g. frus1861)
 :  THEN return the empty sequence
 :)
 
(:
 :  WHEN calling fm:isbn()
 :  GIVEN a $volume-meta document with no ISBN-13 but with an ISBN-10 (no real examples)
 :  THEN return the 10-digit ISBN.
 :)

(:
 :  WHEN calling fm:isbn()
 :  GIVEN a $node
 :  GIVEN a $model with a .?volume-meta document
 :  THEN return (TODO TFJH: confirm exact HTML node features to be returned)
 :  AND with value fm:isbn($model?volume-meta)
 :)

(:
 :  WHEN calling fm:pub-status()
 :  GIVEN a $volume-meta document (e.g. frus1969-76v31)
 :  THEN return the publication status $volume-meta/volume/publication-status (e.g. "published")
 :)

(:
 :  WHEN calling fm:pub-status()
 :  GIVEN a $node
 :  GIVEN a $model with a .?volume-meta document
 :  THEN return (TODO TFJH: confirm exact HTML node features to be returned)
 :  AND with value fm:pub-status($model?volume-meta)
 :)

(:
 :  WHEN calling fm:get-media-types()
 :  GIVEN a $model?volume-meta document with $id
 :  THEN add a sequence consisting of the available types ('epub', 'mobi', 'pdf') to the model map with the key 'media-types'
 :)
 
 (: TODO TFJH: add specific examples calling corresponding frus:media-exists functions :)
 
(:
 :  WHEN calling fm:if-media
 :  GIVEN a $model?media-types populated with a sequence of strings
 :  THEN return true()
 :)
 
(:
 :  WHEN calling fm:if-media
 :  GIVEN an empty $model?media-types 
 :  THEN return false()
 :)

(:
 :  WHEN calling fm:if-media-type
 :  GIVEN a provided $type (e.g. 'epub')
 :  GIVEN a $model?media-type containing $type
 :  THEN return true()
 :)

(:
 :  WHEN calling fm:if-media-type
 :  GIVEN a provided $type (e.g. 'pdf')
 :  GIVEN a $model?media-type NOT containing $type
 :  THEN return false()
 :)

(:
 :  WHEN calling fm:epub-href-attribute
 :  GIVEN a $model?volume-meta with $id
 :  THEN return frus:epub-url($id)
 :)

(:
 :  WHEN calling fm:mobi-href-attribute
 :  GIVEN a $model?volume-meta with $id
 :  THEN return frus:mobi-url($id)
 :)

(:
 :  WHEN calling fm:pdf-href-attribute
 :  GIVEN a $model?volume-meta with $id
 :  THEN return frus:pdf-url($id)
 :)

(:
 :  WHEN calling fm:epub-size
 :  GIVEN a $model?volume-meta with $id
 :  THEN return frus:epub-size($id)
 :)

(:
 :  WHEN calling fm:mobi-size
 :  GIVEN a $model?volume-meta with $id
 :  THEN return frus:epub-size($id)
 :)

(:
 :  WHEN calling fm:pdf-size
 :  GIVEN a $model?volume-meta with $id
 :  THEN return frus:epub-size($id)
 :)