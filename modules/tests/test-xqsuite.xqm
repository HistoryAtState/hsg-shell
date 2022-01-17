xquery version "3.1";

module namespace xt="http://history.state.gov/ns/site/hsg/tests/xqsuite";
import module namespace t="http://history.state.gov/ns/site/hsg/xqsuite" at "../xqsuite.xqm";

declare namespace test="http://exist-db.org/xquery/xqsuite";

(: XQsuite tests for module functions :)

(:
# x:return-model() Test

- WHEN calling x:return-model()
  - GIVEN an entry in $model ("publication-id": "frus")
    - THEN calling the resulting function should return a map
    - AND that map should have the entry given in the model

:)

declare %test:assertEquals('frus') function xt:test-return-model() {
    let $node  := ()
    let $model := map { "publication-id": "frus"}
    return t:return-model($node, $model)()?publication-id
};