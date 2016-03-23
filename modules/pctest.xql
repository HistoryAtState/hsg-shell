xquery version "3.0";

declare namespace open="http://history.state.gov/ns/xquery/open";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";

declare option output:method "xml";

let $vols := collection($config:FRUS_METADATA_COL)
let $names := for $elem in $vols // summary // * return $elem/local-name()
return
<r> {
    distinct-values($names)
}</r>

