import module namespace m='http://www.tei-c.org/tei-simple/models/teisimple.odd' at '/db/apps/hsg-shell/resources/odd/compiled/teisimple-print.xql';

declare variable $xml external;

let $options := map {
    "styles": ["../generated/teisimple.css"],
    "collection": "/db/apps/hsg-shell/resources/odd/compiled"
}
return m:transform($options, $xml)