import module namespace m='http://www.tei-c.org/pm/models/teisimple/web' at '/db/apps/hsg-shell/transform/teisimple-web.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["../transform/teisimple.css"],
    "collection": "/db/apps/hsg-shell/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)