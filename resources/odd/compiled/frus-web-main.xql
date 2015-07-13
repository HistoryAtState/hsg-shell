import module namespace m='http://www.tei-c.org/tei-simple/models/frus.odd' at '/db/apps/hsg-shell/resources/odd/compiled/frus-web.xql';

declare variable $xml external;

let $options := map {
    "styles": ["../generated/frus.css"],
    "collection": "/db/apps/hsg-shell/resources/odd/compiled"
}
return m:transform($options, $xml)