xquery version "3.1";

import module namespace test="http://exist-db.org/xquery/xqsuite" 
at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:indent "yes";

let $modules := for $module in xmldb:get-child-resources("/db/apps/hsg-shell/modules/tests/") return "/db/apps/hsg-shell/modules/tests/"||$module

let $tests as function(*)* := for $uri in $modules return inspect:module-functions(xs:anyURI($uri))

let $results := test:suite(($tests))

for $result in $results//testsuite
return (
  tokenize($result/@package, '/')[last()]||": "||
  $result/@failures || " failures and " || 
  $result/@errors || " errors out of " ||
  $result/@tests || " tests ("||
  $result/@pending||" pending).",
  $result/testcase[error],
  $result/testcase[failure]
)