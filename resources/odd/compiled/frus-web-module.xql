module namespace pml='http://www.tei-c.org/tei-simple/models/frus.odd/web/module';

import module namespace m='http://www.tei-c.org/tei-simple/models/frus.odd/web' at '/db/apps/hsg-shell/resources/odd/compiled/frus-web.xql';

(: Generated library module to be directly imported into code which
 : needs to transform TEI nodes using the ODD this module is based on.
 :)
declare function pml:transform($xml as node()*, $parameters as map(*)?) {

   let $options := map {
       "styles": ["../generated/frus.css"],
       "collection": "/db/apps/hsg-shell/resources/odd/compiled",
       "parameters": if (exists($parameters)) then $parameters else map {}
   }
   return m:transform($options, $xml)
};