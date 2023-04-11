xquery version "3.1";

module namespace t="http://history.state.gov/ns/site/hsg/xqsuite";

declare namespace test="http://exist-db.org/xquery/xqsuite";

(:

# XQsuite Helper functions

## return-model()

This function returns the a zero argument function which returns the page template `$model` map; it returns a function rather than a map directly as template functions returning a map are intercepted by the HTML templating module:
:)

declare function t:return-model($node as node()?, $model as map(*)?) as function(*) {
    function() {$model}
};