xquery version "3.1";

declare namespace frus="http://history.state.gov/frus/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace cache="http://exist-db.org/xquery/cache" at "java:org.exist.xquery.modules.cache.CacheModule";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace memsort="http://exist-db.org/xquery/memsort" at "java:org.existdb.memsort.SortModule";

(: 
 : This module is intended to be run as a scheduled job, so it is called periodically (e.g., every 600000ms/10m).
 : 
 : Logic:
 : 1. If another instance of the job is already running, it it skipped. This requires dba privileges to check, so the query must be chowned by a dba user and 
 : 2. If the job has never been run before, or if the database has just restarted (thus clearing the in-memory memsort index), it is run.
 : 3. If the job has been run before, it only runs again if:
 :    a. A "$wait-after-last-db-write" period has passed since the last modification to the collection (e.g., 10m). This allows batch uploads to complete before the reindex is started.
 :    b. A "$max-reindex-interval" period since the last reindexing has passed (e.g., 60m). This prevents reindexing from occuring too frequently.
 : 4. If the job runs and is successful, the completed time is recorded in the database.
 :)

if (count(system:get-running-xqueries()/system:xquery[system:sourceKey eq "/db/apps/hsg-shell/modules/rebuild-dates-sort-index.xql"]) gt 1) then
    console:log("hsg rebuild-dates-sort-index.xql job skipped. an instance of this job is already running.")
else
    let $status-doc-col := "/db/apps/hsg-shell/modules"
    let $status-doc-name := "rebuild-dates-sort-index-status.xml"
    let $status-doc-path := $status-doc-col || "/" || $status-doc-name
    let $status := 
        if (doc-available($status-doc-path)) then
            doc($status-doc-path)/status
        else
            doc(xmldb:store($status-doc-col, $status-doc-name, element status { element created { current-dateTime() }, element last-reindexed { } }))/status
    let $collection := "/db/apps/frus/volumes"
    let $last-reindexed := $status/last-reindexed[. ne ""] ! (. cast as xs:dateTime)
    let $last-modified := (xmldb:get-child-resources($collection) ! xmldb:last-modified($collection, .)) => max()
    let $startup-time := current-dateTime() - system:get-uptime()
    let $wait-after-last-db-write := xs:dayTimeDuration("PT10M")
    let $max-reindex-interval := xs:dayTimeDuration("PT1H")
    
    (: conditions for reindexing :)
    let $needs-reindexing := 
        (: never indexed :)
        empty($last-reindexed) 
        (: resources have been added or edited :)
        or $last-modified gt $last-reindexed
    let $db-has-cooled-down := current-dateTime() - $last-modified gt $wait-after-last-db-write
    let $max-reindex-interval-has-passed := current-dateTime() - $last-reindexed ge $max-reindex-interval
    let $ready-to-reindex := empty($last-reindexed) or ($db-has-cooled-down and $max-reindex-interval-has-passed)
    let $force-reindex-now := 
        (: the database has restarted and index needs to be rebuilt right away :)
        $last-reindexed lt $startup-time
    return
        if (($needs-reindexing and $ready-to-reindex) or $force-reindex-now) then
            let $log := console:log("hsg rebuild-dates-sort-index.xql job starting.")
            let $start-time := util:system-time()
            let $reindex := 
                try { 
                    memsort:create(
                        "doc-dateTime-min",
                        collection("/db/apps/frus/volumes")//tei:div,
                        function($div) {
                            if ($div/@frus:doc-dateTime-min castable as xs:dateTime) then
                                $div/@frus:doc-dateTime-min cast as xs:dateTime
                            else
                                ()
                        }
                    ),
                    map { "result": "ok", "duration": util:system-time() - $start-time }
                } catch * {
                    map { "result": "error", "duration": util:system-time() - $start-time }
                }
            return
                if ($reindex?result eq "error") then
                    console:log("hsg rebuild-dates-sort-index.xql job failed after " || $reindex?duration || ".")
                else 
                    (
                        update value $status/last-reindexed with util:system-dateTime(),
                        console:log("hsg rebuild-dates-sort-index.xql job successful after " || $reindex?duration || ".")
                    )
        else
            console:log("hsg rebuild-dates-sort-index.xql job skipped. needs-reindexing: " || $needs-reindexing || ", ready-to-reindex: " || $ready-to-reindex || ".")
