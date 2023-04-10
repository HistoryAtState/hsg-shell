xquery version "3.0";

import module namespace test="http://exist-db.org/xquery/xqsuite" 
at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

test:suite((
    inspect:module-functions(xs:anyURI("./modules/tests/test-xqsuite.xqm")),
    inspect:module-functions(xs:anyURI("./modules/tests/test-config.xqm")),
    inspect:module-functions(xs:anyURI("./modules/tests/test-pages.xqm"))
))