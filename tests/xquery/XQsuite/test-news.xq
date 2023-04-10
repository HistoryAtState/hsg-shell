xquery version "3.1";

import module namespace test="http://exist-db.org/xquery/xqsuite" 
at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:indent "yes";

let $results := test:suite(( inspect:module-functions(xs:anyURI("/db/apps/hsg-shell/modules/tests/test-news.xqm"))
))//testsuite

for $result in $results
return (
  $result/@failures || " failures and " || 
  $result/@errors || " errors out of " ||
  $result/@tests || " tests ("||
  $result/@pending||" pending).",
  $result/testcase[error],
  $result/testcase[failure]
)