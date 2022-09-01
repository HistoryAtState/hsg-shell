import module namespace m='http://www.tei-c.org/pm/models/teisimple/epub' at '/db/apps/hsg-shell/transform/teisimple-epub.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["../transform/teisimple.css"],
    "collection": "/db/apps/hsg-shell/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)