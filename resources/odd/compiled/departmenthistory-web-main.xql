import module namespace m='http://www.tei-c.org/tei-simple/models/departmenthistory.odd/web' at '/db/apps/hsg-shell/resources/odd/compiled/departmenthistory-web.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["../generated/departmenthistory.css"],
    "collection": "/db/apps/hsg-shell/resources/odd/compiled",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)