xquery version "3.1";

declare namespace frus="http://history.state.gov/frus/ns/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";

sort:remove-index("doc-dateTime-min-asc"),
sort:create-index-callback(
    "doc-dateTime-min-asc", 
    collection("/db/apps/frus/volumes")//tei:div/@frus:doc-dateTime-min, 
    function($date) { xs:dateTime($date) }, 
    <options order="ascending"/>
),
sort:remove-index("doc-dateTime-max-desc"),
sort:create-index-callback(
    "doc-dateTime-max-desc", 
    collection("/db/apps/frus/volumes")//tei:div/@frus:doc-dateTime-max, 
    function($date) { xs:dateTime($date) }, 
    <options order="descending"/>
)