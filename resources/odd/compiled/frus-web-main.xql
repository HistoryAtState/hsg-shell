import module namespace m='http://www.tei-c.org/tei-simple/models/frus.odd/web' at '/db/apps/hsg-shell/resources/odd/compiled/frus-web.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["../generated/frus.css"],
    "collection": "/db/apps/hsg-shell/resources/odd/compiled",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)