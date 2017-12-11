xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace frus="http://history.state.gov/frus/ns/1.0";



let $range-start:=xs:dateTime('1865-04-28T00:00:00Z')
let $range-end:=xs:dateTime('1995-05-27T23:59:59Z')
let $q:='foo'

return

collection("/db/apps/frus/volumes")//tei:div[@frus:doc-dateTime-min ge $range-start][@frus:doc-dateTime-max le $range-end][ft:query(., $q)]
