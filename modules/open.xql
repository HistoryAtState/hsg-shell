xquery version "3.0";

(: 
    "Open goverment" atom feed for latest volumes.
:)

declare namespace open="http://history.state.gov/ns/xquery/open";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";

declare option output:method "xml";

declare function open:frus-latest() {
    <latest/>
};

declare function open:frus-metadata() {
    <metadata/>
};


switch(request:get-parameter('xql-feed', ''))
case 'latest' return open:frus-latest()
case 'metadata' return open:frus-metadata()
default return <error/>
