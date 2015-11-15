import module namespace m='http://www.tei-c.org/tei-simple/models/departmenthistory.odd' at '/db/apps/hsg-shell/resources/odd/compiled/departmenthistory-web.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["../generated/departmenthistory.css"],
    "collection": "/db/apps/hsg-shell/resources/odd/compiled",
    "parameters": $parameters
}
return m:transform($options, $xml)