xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-app";

import module namespace ut="http://history.state.gov/ns/site/hsg/app-util" at "../app-util.xqm";
(:import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "../app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace t="http://history.state.gov/ns/site/hsg/xqsuite" at "../xqsuite.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "../pages.xqm";:)
import module namespace templates="http://exist-db.org/xquery/html-templating";

declare namespace test="http://exist-db.org/xquery/xqsuite";

(:
 :  WHEN calling ut:join-lines
 :  GIVEN $lines as a sequence of strings (e.g. "hello", "world")
 :  THEN return a string consisting of the strings joined with a newline character (e.g. "hello&x0d;&x0a;world")
 :  NB we have to test this using url encoding to avoid munging of windows line endings
 :)
declare %test:assertEquals('hello%0D%0Aworld') function x:ut-join-lines(){
    let $lines := ('hello', 'world')
    return ($lines => ut:join-lines() => encode-for-uri()) 
};