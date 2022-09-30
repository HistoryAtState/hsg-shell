xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-frus-meta";

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
 :  GIVEN a collection in $model?collection (of FRUS bibliographic data) with $total number of volumes
 :  GIVEN a position to start from, $start
 :  GIVEN a number of entries to return, $per-page
 :  THEN return a map with $total ?volumes-meta documents sorted and selected from $model?collection
 :  AND ?total as the integer total of volume metadata documents in $model?collection 
 :)

declare
    %test:assertEquals(3)
function x:test-init-frus-list-total(){
    let $model := map{
            "collection": $x:test_col
        }
    let $actual := fm:init-frus-list((), $model, 1, 50)
    return $actual?total
};

declare
    %test:assertEquals(
        'frus1861',
        'frus1969-76v31',
        'frus1981-88v11'
    )
function x:test-init-frus-list(){
    let $model := map{
            "collection": $x:test_col
        }
    let $actual := fm:init-frus-list((), $model, 1, 50)
    return $actual?volumes-meta ! /volume/@id/string(.)
};

(:
 :  WHEN calling fm:sorted()
 :  GIVEN a sequence of volume metadata $model?volumes-meta
 :  GIVEN a $start position in the sequence
 :  GIVEN a number of entries to return, $per-page
 :  THEN return the entries corresponding to those between the $start
 :  and ($start + $per-page) positions in the sequence inclusive, where the sequence
 :  has been sorted by $volume-meta/volume/@id ascending.
 :)

declare
    %test:assertEquals(
        'frus1969-76v31',
        'frus1981-88v11'
    )
function x:test-fm-sorted() {
    let $actual := fm:sorted($x:test_col, 2, 2)
    return $actual ! string(/volume/@id)
};

(:
 :  WHEN calling fm:id()
 :  GIVEN a $volume-meta document
 :  THEN return the value of $volume-meta/volume/@id
 :)

declare
     %test:assertEquals('frus1861')
function x:test-fm-id() {
    let $volume-meta := doc('/db/apps/hsg-shell/tests/data/frus-meta/frus1861.xml')
    return fm:id($volume-meta)
};
 
(:
 :  WHEN calling fm:title()
 :  GIVEN a $volume-meta document
 :  THEN return the whitespace-normalised content of that document's title ($volume-meta/volume/title[@type eq 'complete'])
 :)
 
declare
    %test:assertEquals('Message of the President of the United States to the Two Houses of Congress, at the Commencement of the Second Session of the Thirty-seventh Congress')
function x:test-fm-title() {
    let $volume-meta := doc('/db/apps/hsg-shell/tests/data/frus-meta/frus1861.xml')
    return fm:title($volume-meta)
};

(:  WHEN calling fm:title()
 :  GIVEN a $node
 :  GIVEN a $model?volume-meta document
 :  THEN return fm:title($model?volume-meta
 :)
declare %test:assertEquals('Message of the President of the United States to the Two Houses of Congress, at the Commencement of the Second Session of the Thirty-seventh Congress')
function x:test-fm-title-template() {
    let $volume-meta := doc('/db/apps/hsg-shell/tests/data/frus-meta/frus1861.xml')
    let $node := ()
    let $model := map{
        'volume-meta':  $volume-meta
    }
    return fm:title($node, $model)
};

(:
 :  WHEN calling fm:title-url()
 :  GIVEN a $volume-meta document
 :  THEN return the (fixed) URL of the corresponding FRUS landing page
 :)

declare
    %test:assertEquals('/exist/apps/hsg-shell/historicaldocuments/frus1861')
function x:test-fm-title-url() {
    let $volume-meta := doc('/db/apps/hsg-shell/tests/data/frus-meta/frus1861.xml')
    return fm:title-url($volume-meta)
};

(:
 :  WHEN calling fm:title-link()
 :  GIVEN a <a/> $node
 :  GIVEN a $model?volume-meta document
 :  THEN return a @href link to the volume landing page (fm:title-url())
 :  THEN process any child nodes and attributes
 :)
declare %test:assertEquals('true') function x:test-fm-title-link() {
    let $node := 
        <a class="hsg-list__link" data-template="fm:title-link">
            <h3/>
        </a>
    let $config := map{
        $templates:CONFIG_FN_RESOLVER : function($functionName as xs:string, $arity as xs:int) {
            try {
                function-lookup(xs:QName($functionName), $arity)
            } catch * {
                ()
            }
        },
        $templates:CONFIG_PARAM_RESOLVER : map{}
    }
    let $model := map {
        $templates:CONFIGURATION : $config,
        "volume-meta":  doc('/db/apps/hsg-shell/tests/data/frus-meta/frus1861.xml')
    }
    let $expected := 
        <a class="hsg-list__link" href="/exist/apps/hsg-shell/historicaldocuments/frus1861">
            <h3/>
        </a>
    let $actual := fm:title-link($node, $model)
    return  if (deep-equal($expected, $actual)) then 'true' else <result><actual>{$actual}</actual><expected>{$expected}</expected></result>
};

(:
 :  WHEN calling fm:thumbnail()
 :  GIVEN a $volume-meta element (with ID $id)
 :  THEN return the thumbnail image URI at https://static.history.state.gov/frus/{$id}/covers/{$id}.jpg
 :)
declare
    %test:assertEquals('https://static.history.state.gov/frus/frus1969-76v31/covers/frus1969-76v31.jpg')
function x:test-fm-thumbnail() {
    let $volume-meta := doc('/db/apps/hsg-shell/tests/data/frus-meta/frus1969-76v31.xml')
    return
        fm:thumbnail($volume-meta)
};

(:
 :  WHEN calling fm:thumbnail()
 :  GIVEN an img element $node 
 :  GIVEN a $model map with .?volume-meta document
 :  THEN return an img element with @data-src = fm:thumbnail($model?volume-meta)
 :  AND @alt = "Book Cover of " || fm:title($model?volume-meta) 
 :)
declare
    %test:assertEquals('true')
function x:test-fm-thumbnail-templates() {
    let $node :=
        <img class="hsg-news__thumbnail" data-template="fm:thumbnail"/>
    let $model := map {
        "volume-meta":  doc('/db/apps/hsg-shell/tests/data/frus-meta/frus1969-76v31.xml')
    }
    let $expected :=
        <img class="hsg-news__thumbnail"
             data-src="https://static.history.state.gov/frus/frus1969-76v31/covers/frus1969-76v31.jpg"
             alt="Book Cover of Foreign Relations of the United States, 1969–1976, Volume XXXI, Foreign Economic Policy, 1973–1976"/>
    let $actual := fm:thumbnail($node, $model)
    return
        if (deep-equal($expected, $actual))
        then 'true'
        else
            <result><actual>{$actual}</actual><expected>{$expected}</expected></result>
};

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