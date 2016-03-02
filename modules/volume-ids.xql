xquery version "3.0";

(: 
    FRUS volume-id API
:)

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";

declare option output:method "xml";

let $start-time := util:system-time()
let $hits := for $x in xmldb:get-child-resources($config:FRUS_VOLUMES_COL) order by $x return replace($x, '.xml', '')
let $hitcount := count($hits)
let $end-time := util:system-time()
let $runtime := (($end-time - $start-time) div xs:dayTimeDuration('PT1S'))
return
    <results>
        <summary>
            <volumes>{$hitcount}</volumes>
            <time>{$runtime} seconds</time>
            <datetime-retrieved>{current-dateTime()}</datetime-retrieved>
        </summary>
        <volume-ids>{
            for $hit in $hits
                return
                    <volume-id>{$hit}</volume-id>
        }</volume-ids>
    </results>
