import module namespace m='http://www.tei-c.org/pm/models/departmenthistory/epub' at '/db/apps/hsg-shell/transform/departmenthistory-epub.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["../transform/departmenthistory.css"],
    "collection": "/db/apps/hsg-shell/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)