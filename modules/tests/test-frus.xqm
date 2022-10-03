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

declare variable $x:test_s3 := '/db/apps/hsg-shell/tests/data/s3-cache/static.history.state.gov.v2';

(:
 :  This function replaces the contents of the S3 cache with the test data at $x:test_s3
 :  before running any tests.
 :)

declare
    %test:setUp
function x:setup-tests-s3() {
    (: remove the existing cache :)
    xmldb:remove('/db/apps/s3/cache'),
    (: recreate empty cache collection :)
    xmldb:create-collection('/db/apps/s3', 'cache'),
    (: copy the test collection :)
    xmldb:copy-collection($x:test_s3, '/db/apps/s3/cache')
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