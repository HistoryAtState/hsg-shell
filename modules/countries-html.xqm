xquery version "3.0";

module namespace ch = "http://history.state.gov/ns/site/hsg/countries-html";

import module namespace templates="http://exist-db.org/xquery/templates";

declare
    %templates:wrap
function ch:countries($node as node(), $model as map(*), $country as xs:string?) {
    for $c in ('china', 'england', 'iran')
    let $selected := if ($c = $country) then attribute selected {"selected"} else ()
    let $brief-title := concat(upper-case(substring($c, 1, 1)), substring($c, 2))
    return
        <option>{ 
            attribute value { "./countries/" || $c },
            $selected,
            $brief-title
        }</option>
};