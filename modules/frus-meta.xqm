xquery version "3.1";

(:
 : Module for handling of frus bibliographies
 :)
module namespace fm = "http://history.state.gov/ns/site/hsg/frus-meta";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace frus="http://history.state.gov/ns/site/hsg/frus-html" at "frus-html.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";


declare
    %templates:wrap
    %templates:default("start", 1)
    %templates:default("per-page", 20)
function fm:init-frus-list($node as node()?, $model as map(*), $start as xs:integer, $per-page as xs:integer) as map(*) {
    let $volume-meta := fm:sorted($model?collection, $start, $per-page)
    return (
        map {
            "total":        count($model?collection),
            "volume-meta":  $volume-meta,
            "hits":         $model?collection
        }
    )
};

declare function fm:sorted ($collection, $start as xs:integer, $per-page as xs:integer) {
    let $sorted := (
        for $volume in $collection
        let $id := fm:get-id($volume)
        order by $id ascending
        return $volume
    )
    return (
        subsequence($sorted, $start, $per-page),
        util:log('info', ('frus-meta.xqm, fm:sorted ', subsequence($sorted, $start, $per-page)))
    )
};

declare function fm:get-id ($collection) {
    $collection/volume[@id]
};

