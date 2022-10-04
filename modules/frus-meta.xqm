xquery version "3.1";

(:
 : Module for handling of frus bibliographies
 :)
module namespace fm = "http://history.state.gov/ns/site/hsg/frus-meta";

import module namespace templates="http://exist-db.org/xquery/html-templating";
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

declare function fm:title($node, $model) {
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

declare function fm:thumbnail($node, $model) {
    let $volume-meta := $model?volume-meta
    return
        element { node-name($node) } {
            $node/(@* except @data-template),
            attribute data-src { fm:thumbnail($volume-meta) },
            attribute alt { 'Book Cover of ' || fm:title($volume-meta) }
        }
};


declare function fm:isbn($volume-meta as document-node(element(volume))) {
    $volume-meta/volume/((isbn13, isbn10)[normalize-space(.) ne ''])[1]/string(.)
};

declare function fm:isbn($node, $model) {};

declare function fm:isbn-format($node, $model) {};

declare function fm:pub-status($volume-meta as document-node(element(volume))) {
    $volume-meta/volume/publication-status/string(.)
};

declare function fm:if-pub-date($node, $model) {};

declare function fm:pub-date($node, $model) {};

declare function fm:pub-date($volume-meta as document-node(element(volume))) {};

declare function fm:get-media-types($node, $model) {
    let $id := fm:id($model?volume-meta)
    return map{
        "media-types": (
            "epub"[frus:exists-ebook($id)],
            "mobi"[frus:exists-mobi($id)],
            "pdf"[frus:exists-pdf($id)]
        )
    }
};

declare function fm:if-media($node, $model) {
    if (exists($model?media-types))
    then
        element {node-name($node)} {
            $node/(@* except @data-template),
            templates:process($node/node(), $model)
        }
    else ()
};

declare function fm:if-media-type($node, $model, $type) {
    if ($type = $model?media-types)
    then
        element {node-name($node)} {
            $node/(@* except (@data-template|@data-template-type)),
            templates:process($node/node(), $model)
        }
    else ()
};

declare function fm:epub-href-attribute($node, $model) {
    $model?volume-meta
    => fm:id()
    => frus:epub-url()
};

declare function fm:mobi-href-attribute($node, $model) {
    $model?volume-meta
    => fm:id()
    => frus:mobi-url()
};

declare function fm:pdf-href-attribute($node, $model) {
    $model?volume-meta
    => fm:id()
    => frus:pdf-url(())
};

declare function fm:epub-size($node, $model) {
    $model?volume-meta
    => fm:id()
    => frus:epub-size()
};

declare function fm:mobi-size($node, $model) {
    $model?volume-meta
    => fm:id()
    => frus:mobi-size()
};

declare function fm:pdf-size($node, $model) {
    $model?volume-meta
    => fm:id()
    => frus:pdf-size()
};