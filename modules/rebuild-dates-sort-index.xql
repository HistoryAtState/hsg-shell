xquery version "3.1";

declare namespace frus="http://history.state.gov/frus/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace memsort="http://exist-db.org/xquery/memsort" at "java:org.existdb.memsort.SortModule";

memsort:create(
    "doc-dateTime-min",
    collection("/db/apps/frus/volumes")//tei:div,
    function($div) {
        $div/@frus:doc-dateTime-min/xs:dateTime(.)
    }
)
