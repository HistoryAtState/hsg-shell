xquery version "3.1";

import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "../../modules/app.xqm";
import module namespace http = "http://expath.org/ns/http-client";


let $datetime := current-dateTime()
let $xml := <root datetime="{$datetime}"/>

let $target-col := "/db/apps/hsg-shell/tests/xquery"
let $target-name := "resource-name.xml"
let $store-on-1861 := xmldb:store($target-col, $target-name, $xml)    
let $wait := util:wait(2000)
let $replicated-xml := 
    http:send-request( 
        <http:request method="get" href="https://1991.history.state.gov/resource-name.xml?date={$datetime}" />
    )
let $datetime-1861 := doc( $target-col || "/" || $target-name)//root/@datetime/string()
let $datetime-1991 := $replicated-xml[2]/root/@datetime/string()
let $replication-successful := $datetime-1861 = $datetime-1991

return 
    <div>
        <h4>Replication Test Result</h4>
        <ul>
            <li id="1861" value="{ $datetime-1861 }"/>
            <li id="1991" value="{ $datetime-1991 }"/>
            <li id="replication" value="{ $replication-successful }"/>
        </ul>
    </div>
