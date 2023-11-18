xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-frus";

import module namespace fm="http://history.state.gov/ns/site/hsg/frus-meta" at "../frus-meta.xqm";
import module namespace frus="http://history.state.gov/ns/site/hsg/frus-html" at "../frus-html.xqm";
import module namespace t="http://history.state.gov/ns/site/hsg/xqsuite" at "../xqsuite.xqm";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "../app.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "../pages.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "../config.xqm";
import module namespace ut="http://history.state.gov/ns/site/hsg/app-util" at "../app-util.xqm";
import module namespace templates="http://exist-db.org/xquery/html-templating";

declare namespace test="http://exist-db.org/xquery/xqsuite";

declare variable $x:test_s3 := '/db/apps/hsg-shell/tests/data/s3-cache/static.history.state.gov.v3';

(:
 :  This function replaces the contents of the S3 cache with the test data at $x:test_s3
 :  before running any tests.
 :)

declare
    %test:setUp
function x:setup-tests-s3() {
    (: move to a temporary backup collection :)
    xmldb:create-collection('/db/apps/hsg-publish-data', 'bak'),
    xmldb:move('/db/apps/hsg-publish-data/data', '/db/apps/hsg-publish-data/bak'),
    (: recreate empty cache collection :)
    xmldb:create-collection('/db/apps/hsg-publish-data', 'data'),
    (: copy the test collection :)
    xmldb:copy-collection($x:test_s3, '/db/apps/hsg-publish-data/data')
};
 
(:
 :  This function restores the contents of the S3 cache after running tests (if required)
 :)

declare
    %test:tearDown
function x:teardown-tests-s3() {
    (: remove the existing cache :)
    xmldb:remove('/db/apps/hsg-publish-data/data'),
    (: recreate empty cache collection :)
    xmldb:create-collection('/db/apps/hsg-publish-data', 'data'),
    (: restore original cache collection :)
    xmldb:move('/db/apps/hsg-publish-data/bak/cache', '/db/apps/hsg-publish-data/data'),
    (: remove backup collection :)
    xmldb:remove('/db/apps/hsg-publish-data/bak')
};


(:
 :  WHEN running frus:exists-mobi()
 :  GIVEN the $id of a frus volume with an associated .mobi file (e.g frus1969-76v31)
 :  RETURN true()
 :)

declare %test:assertTrue %test:assertExists function x:frus-exists-mobi-true() {
    frus:exists-mobi('frus1969-76v31')
};

(:
 :  WHEN running frus:exists-mobi()
 :  GIVEN the $id of a frus volume with no associated .mobi file (e.g frus1861)
 :  RETURN false()
 :)

declare %test:assertFalse %test:assertExists function x:frus-exists-mobi-false() {
    frus:exists-mobi('frus1861')
};

(:
 :  WHEN calling frus:get-media-types()
 :  GIVEN an $id that has associate media types (e.g. frus1969-76v31)
 :  THEN return a sequence of available media types (e.g. 'epub', 'mobi', 'pdf').
 :)
declare
    %test:assertEquals('true')
function x:test-frus-get-media-types() {
    let $expected := ("epub", "mobi", "pdf")
    let $actual := frus:get-media-types('frus1969-76v31')
    return
        if (deep-equal($expected, $actual))
        then 'true'
        else
            <result>
                <actual>{serialize($actual, map{'method':'adaptive', 'indent':true()})}</actual>
                <expected>{serialize($expected, map{'method':'adaptive', 'indent':true()})}</expected>
            </result>
};

(:
 :  WHEN calling frus:get-media-types()
 :  GIVEN an $id which has a single associated media type (e.g. frus1981-88v11)
 :  THEN return a map with the key 'media-types' with the value a sequence consisting of the available type (e.g 'pdf'). 
 :)

declare
    %test:assertEquals('pdf')
function x:test-frus-get-media-types-single() {
    frus:get-media-types('frus1981-88v11')
};

(:
 :  WHEN calling frus:get-media-types()
 :  GIVEN an $id which has no associated media types (e.g. frus1861)
 :  THEN return an empty sequence. 
 :)

declare
    %test:assertEmpty
function x:test-frus-get-media-types-none() {
    frus:get-media-types('frus1861')
};

(:
 :  WHEN calling frus:cover-uri($id)
 :  GIVEN an $id corresponding to an electronically published frus volume (e.g. frus1969-76v31)
 :  RETURN the URL of the cover image (e.g. 'https://static.history.state.gov/frus/frus1969-76v31/covers/frus1969-76v31.jpg')
 :)

declare
    %test:assertEquals('https://static.history.state.gov/frus/frus1969-76v31/covers/frus1969-76v31.jpg')
function x:test-frus-cover-uri() {
    frus:cover-uri('frus1969-76v31')
};

(:
 :  WHEN calling frus:cover-uri($id)
 :  GIVEN an $id corresponding to a frus volume with no cover image (e.g. 'frus1977-80v04')
 :  RETURN ()
 :)

declare %test:assertEmpty function x:test-frus-cover-uri-none() {
    frus:cover-uri('frus1977-80v04')
};

(:
 :  WHEN calling frus:cover-img()
 :  GIVEN an image element $img
 :  GIVEN a $model?document-id corresponding to an electronically published frus volume (e.g. frus1969-76v31)
 :  RETURN the image element, preserving existing attributes
 :  RETURN @src to the cover image ('https://static.history.state.gov/frus/frus1969-76v31/covers/frus1969-76v31.jpg')
 :  RETURN @alt { 'Book Cover of ' || frus:vol-title($model?document-id) }
 :)

declare %test:assertEquals('true') function x:test-frus-cover-img() {
    let $node :=
        <img class="hsg-frus__cover" data-template="frus:cover-img"/>
    let $model := map {
        "document-id":  'frus1981-88v11'
    }
    let $expected :=
        <img class="hsg-frus__cover"
             src="https://static.history.state.gov/frus/frus1981-88v11/covers/frus1981-88v11.jpg"
             alt="Book Cover of {frus:vol-title($model?document-id) => normalize-space()}"/>
    let $actual := frus:cover-img($node, $model)
    return
        if (deep-equal($expected, $actual))
        then 'true'
        else
            <result><actual>{$actual}</actual><expected>{$expected}</expected></result>
};

(:
 :  WHEN calling frus-cover-img()
 :  GIVEN an image element $img
 :  GIVEN a $model?document-id corresponding to a frus volume with no cover image (e.g. 'frus1977-80v04')
 :  RETURN ()
 :)

declare %test:assertEmpty function x:test-frus-cover-img-none() {
    let $node :=
        <img class="hsg-frus__cover" data-template="frus:cover-img"/>
    let $model := map {
        "document-id":  'frus1977-80v04'
    }
    return frus:cover-img($node, $model)
};

(:
 :  Regression test for frus previous links
 :
 :  WHEN calling pages:navigation-link()
 :  GIVEN a $node <a/> (e.g. from pages/historicaldocuments/volume-interior.xml)
 :  GIVEN a $model with keys and (pseudo-) values:
 :      map{
 :          "next": frus1969-76v02/comp1,
 :          "div":  frus1969-76v02/ch1,
 :          "publication-id":   'frus',
 :          "document-id":  'frus1969-76v02'
 :      }
 :  GIVEN a $direction "previous"
 :  GIVEN a $view "div"
 :  RETURN a <a/> with attributes
 :)
declare
    %test:assertEquals('true')
function x:test-frus-prev-link() {
    let $node := 
        <a data-template="pages:navigation-link" data-template-direction="previous" class="page-nav nav-prev">
           <i class="glyphicon glyphicon-chevron-left"/>
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
            "publication-id":   'frus',
            "document-id":      'frus1969-76v02',
            "previous": pages:load-xml('frus', 'frus1969-76v02', 'comp1', 'div'),
            "div":  pages:load-xml('frus', 'frus1969-76v02', 'ch1', 'div')
        }
    let $actual := pages:navigation-link($node, $model, "previous", "div")
    let $expected := 
        <a data-doc="frus1969-76v02.xml" data-root="1.5.4.4" data-current="1.5.4.4.8" data-template="pages:navigation-link" data-template-direction="previous" class="page-nav nav-prev" href="/exist/apps/hsg-shell/historicaldocuments/frus1969-76v02/comp1">
           <i class="glyphicon glyphicon-chevron-left"/>
        </a>
    return 
        if (deep-equal($expected, $actual))
        then 'true'
        else
            <result><actual>{$actual}</actual><expected>{$expected}</expected></result>
};

(:
 :  Regression test for frus next links
 :
 :  WHEN calling pages:navigation-link()
 :  GIVEN a $node <a/> (e.g. from pages/historicaldocuments/volume-interior.xml)
 :  GIVEN a $model with keys and (pseudo-) values:
 :      map{
 :          "next": frus1969-76v02/d1,
 :          "div":  frus1969-76v02/ch1,
 :          "publication-id":   'frus',
 :          "document-id":  'frus1969-76v02'
 :      }
 :  GIVEN a $direction "next"
 :  GIVEN a $view "div"
 :  RETURN a <a/> with attributes
 :)
declare
    %test:assertEquals('true')
function x:test-frus-next-link() {
    let $node := 
        <a data-template="pages:navigation-link" data-template-direction="next" class="page-nav nav-next">
           <i class="glyphicon glyphicon-chevron-right"/>
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
            "publication-id":   'frus',
            "document-id":      'frus1969-76v02',
            "next": pages:load-xml('frus', 'frus1969-76v02', 'd1', 'div'),
            "div":  pages:load-xml('frus', 'frus1969-76v02', 'ch1', 'div')
        }
    let $actual := pages:navigation-link($node, $model, "next", "div")
    let $expected := 
        <a data-doc="frus1969-76v02.xml" data-root="1.5.4.4.8.8" data-current="1.5.4.4.8" data-template="pages:navigation-link" data-template-direction="next" class="page-nav nav-next" href="/exist/apps/hsg-shell/historicaldocuments/frus1969-76v02/d1">
           <i class="glyphicon glyphicon-chevron-right"/>
        </a>
    return
        if (deep-equal($expected, $actual))
        then 'true'
        else
            <result><actual>{$actual}</actual><expected>{$expected}</expected></result>
};