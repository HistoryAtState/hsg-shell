xquery version "3.1";

declare namespace frus="http://history.state.gov/frus/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace cache="http://exist-db.org/xquery/cache" at "java:org.exist.xquery.modules.cache.CacheModule";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace memsort="http://exist-db.org/xquery/memsort" at "java:org.existdb.memsort.SortModule";

(: 
 : This module is intended to be run as a scheduled job, so it is called periodically (@period="600000" is in the unit of ms and translates to 10m).
 : 
 : Logic:
 : 1. If another instance of the job is already running, it it skipped. This requires dba privileges to check, so the query must be chowned by a dba user with setUID permissions.
 : 2. If the job has never been run before, it is run.
 : 3. If the job has been run before, it only runs again if the following criteria are both met:
 :    a. A "DURATION_AFTER_LAST_DB_WRITE" period has passed since the last modification to the collection (e.g., 10m). This allows batch uploads to complete before the reindex is started.
 :    b. A "MINIMUM_DURATION_BETWEEN_REINDEXING" period since the last reindexing has passed (e.g., 60m). This prevents reindexing from occuring too frequently.
 : 4. If the job runs and is successful, the completed time is recorded in the database.
 :)

declare variable $local:DURATION_AFTER_LAST_DB_WRITE := xs:dayTimeDuration("PT10M")
declare variable $local:MINIMUM_DURATION_BETWEEN_REINDEXING := xs:dayTimeDuration("PT1H")
declare variable $local:PATH_TO_THIS_QUERY := "/db/apps/hsg-shell/modules/rebuild-dates-sort-index.xql"
declare variable $local:PATH_TO_STATUS_RECORD := "/db/apps/hsg-shell/modules/rebuild-dates-sort-index-status.xml"

declare function local:reindex() as map(*) {
    let $start-time := util:system-time()
    return
        try { 
            memsort:create(
                "doc-dateTime-min",
                collection("/db/apps/frus/volumes")//tei:div,
                function($div) {
                    $div/@frus:doc-dateTime-min/xs:dateTime(.)
                }
            ),
            map { 
                "result": "ok", 
                "duration": util:system-time() - $start-time 
            }
        } 
        catch * {
            map { 
                "result": "error", 
                "duration": util:system-time() - $start-time 
            }
        }
};

(: 1. If another instance of the job is already running, it it skipped. :)
if (count(system:get-running-xqueries()/system:xquery[system:sourceKey eq $local:PATH_TO_THIS_QUERY]) gt 1) then
    console:log("hsg rebuild-dates-sort-index.xql job skipped. an instance of this job is already running.")
else
    let $status := 
        if (doc-available($local:PATH_TO_STATUS_RECORD)) then
            doc($local:PATH_TO_STATUS_RECORD)/status
        else
            let $status-doc-path-components := $local:PATH_TO_STATUS_RECORD => analyze-string("^.+/[^/]+")/fn:match/string()
            doc(xmldb:store($status-doc-col, $status-doc-name, element status { element created { current-dateTime() }, element last-reindexed { } }))/status
    let $collection := "/db/apps/frus/volumes"
    let $last-reindexed := $status/last-reindexed[. ne ""] ! (. cast as xs:dateTime)
    let $last-modified := (xmldb:get-child-resources($collection) ! xmldb:last-modified($collection, .)) => max()
    
    (: Conditions for reindexing:
     : 1. If the collection not been indexed before, it is run.
     : 2. The collection is indexed again only if all 3 of the following criteria are met:
     :    a. New/updated data has been stored to the collection since the last reindex.
     :    b. A period of time has passed since the last write to the collection. 
     :    c. A period of time has passed since the last reindex.
     :)
    let $job-has-never-been-run := empty($last-reindexed)
    let $new-data-since-last-reindex := $last-modified gt $last-reindexed
    let $db-has-cooled-down := current-dateTime() - $last-modified gt $local:DURATION-AFTER-LAST-DB-WRITE
    let $min-duration-between-reindexing-has-passed := current-dateTime() - $last-reindexed ge $local:MINIMUM-DURATION-BETWEEN-REINDEXING
    return
        if (
            $job-has-never-been-run or 
            (
                $new-data-since-last-reindex and
                $db-has-cooled-down and
                $min-duration-between-reindexing-has-passed
            )
        ) then
            let $log := console:log("hsg rebuild-dates-sort-index.xql job starting.")
            let $reindex := local:reindex() 
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
