xquery version "3.1";

module namespace ut="http://history.state.gov/ns/site/hsg/app-util";

(:~
 : serializes a parameter
 : omits parameters with no value -> `()`
 : usually a single pair of `name=value`
 : multiple entries for parameters that return a sequence
 :)
declare
function ut:serialize-parameter ($parameters as map(*), $parameter-name as xs:string) as xs:string* {
    for-each(
        $parameters($parameter-name),
        function ($value) {
            $parameter-name || '=' || encode-for-uri($value)
        }
    )
};

declare
function ut:serialize-parameters ($parameters as map(*)) as xs:string {
    let $parameter-names := map:keys($parameters)
    let $serialized-parameters :=
        for-each(
            $parameter-names,
            ut:serialize-parameter($parameters, ?)
        )
    return
        ('?' || $serialized-parameters => string-join('&amp;'))
};

(:~
 : return a map:entry with $parameter-name as key and
 : its current value as value
 :
 : @param $parameter-name
~:)
declare
    %private
function ut:create-parameter-map-entry ($parameter-name as xs:string) as map(*) {
     map:entry($parameter-name, request:get-parameter($parameter-name, ()))
};

(:~
 : return a map of all parameters in $parameter-names as key and
 : their current value as value
 :
 : @param $parameter-names a sequence of parameter names ('start')
~:)
declare
function ut:get-parameter-values ($parameter-names as xs:string*) as map(*) {
    map:merge(for-each($parameter-names, ut:create-parameter-map-entry#1))
};
