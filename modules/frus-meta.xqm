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
import module namespace ut="http://history.state.gov/ns/site/hsg/app-util" at "../app-util.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";


declare
    %templates:wrap
    %templates:default("start", 1)
    %templates:default("per-page", 20)
function fm:init-frus-list($node as node()?, $model as map(*), $start as xs:integer, $per-page as xs:integer) as map(*) {
    let $total := count($model?collection)
    let $volume-list := fm:sorted($model?collection, $start, $total)
    return (
        map {
            "total": $total,
            "volumes-meta": $volume-list
        }
    )
};

declare function fm:sorted ($collection, $start as xs:integer, $per-page as xs:integer) {
    let $sorted := (
        for $volume in $collection
        let $id := fm:id($volume)
        order by $id ascending
        return $volume
    )
    return (
        subsequence($sorted, $start, $per-page)
    )
};

declare function fm:id($volume-meta as document-node(element(volume))) {
    $volume-meta/volume/@id/string(.)
};

declare function fm:title($volume-meta as document-node(element(volume))) {
    ($volume-meta/volume/title[@type eq 'complete']/node()) => ut:normalize-nodes()
};

declare
    %templates:wrap
function fm:title($node, $model) {
    fm:title($model?volume-meta)
};

declare function fm:title-url($volume-meta as document-node(element(volume))) {
    app:fix-href('/historicaldocuments/' || fm:id($volume-meta))
};

declare function fm:title-link($node, $model) {
    element {node-name($node)} {
        $node/(@* except @data-template),
        attribute href {fm:title-url($model?volume-meta)},
        templates:process($node/node(), $model)
    }
};

declare function fm:thumbnail($volume-meta as document-node(element(volume))) {
    let $id := fm:id($volume-meta)
    return
        'https://static.history.state.gov/frus/' || $id || '/covers/' || $id || '.jpg'
};

declare function fm:thumbnail($node, $model) {};

declare function fm:isbn($volume-meta as document-node(element(volume))) {};

declare function fm:isbn($node, $model) {};

declare function fm:pub-status($volume-meta as document-node(element(volume))) {};

declare function fm:pub-status($node, $model) {};

declare function fm:get-media-types($node, $model) {};

declare function fm:if-media($node, $model) {};

declare function fm:if-media-type($node, $model, $type) {};

declare function fm:epub-href-attribute($node, $model) {};

declare function fm:mobi-href-attribute($node, $model) {};

declare function fm:pdf-href-attribute($node, $model) {};

declare function fm:epub-size($node, $model) {};

declare function fm:mobi-size($node, $model) {};

declare function fm:pdf-size($node, $model) {};