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
    return (frus:cover-uri($id), 'https://static.history.state.gov/images/document-image.jpg')[1]
};

declare function fm:thumbnail($node, $model) {
    let $volume-meta := $model?volume-meta
    let $media-types := fm:get-media-types($volume-meta)
    return

        element { node-name($node) } {
            $node/(@* except (@data-template, $node/@class)),
            if (not(exists($media-types)))
            then (
                attribute class { $node/@class || ' hsg-list__thumbnail--placeholder' }
            )
            else (attribute class { $node/@class }),
            attribute src { fm:thumbnail($volume-meta) },
            attribute alt { 'Book Cover of ' || fm:title($volume-meta) }
        }
};

declare function fm:isbn($volume-meta as document-node(element(volume))) {
    $volume-meta/volume/((isbn13, isbn10)[normalize-space(.) ne ''])[1]/string(.)
};

declare function fm:isbn($node, $model) {
    let $format as xs:string? := fm:isbn-format($model?volume-meta)
    let $isbn := fm:isbn($model?volume-meta)
    return
        if ($format) then
            element { node-name($node) } {
                $node/(@* except @data-template),
                $isbn
            }
        else ()
};

declare function fm:isbn-format($volume-meta as document-node(element(volume))) {
    if ($volume-meta/volume/isbn13[normalize-space(.) ne '']) then
        "ISBN:"
    else if ($volume-meta/volume/isbn10[normalize-space(.) ne '']) then
        "ISBN-10:"
    else ()
};

declare function fm:isbn-format($node, $model) {
    let $format as xs:string? := fm:isbn-format($model?volume-meta)
    return
        if ($format) then
            element { node-name($node) } {
                $node/(@* except @data-template),
                $format
            }
        else ()
};

declare function fm:pub-status($volume-meta as document-node(element(volume))) {
    let $status := $volume-meta/volume/publication-status/string(.)
    let $code-table := $config:FRUS_COL_CODE_TABLES || "/publication-status-codes.xml"
    return doc($code-table)/code-table/items/item[value eq $status]/label/string(.)
};

declare function fm:pub-status($node, $model) {
    if (exists(fm:pub-date($model?volume-meta))) then
        ()
    else
        element {node-name($node)} {
            $node/(@* except @data-template),
            fm:pub-status($model?volume-meta)
        }
};

declare function fm:get-media-types($volume-meta as document-node(element(volume))) {
    let $id := fm:id($volume-meta) 
    return frus:get-media-types($id)
};

declare function fm:get-media-types($node, $model) {
    let $media-types:= fm:get-media-types($model?volume-meta)
    return map{
        "media-types": $media-types
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
    let $href := $model?volume-meta
        => fm:id()
        => frus:epub-url()
    return
        element {node-name($node)} {
            $node/(@* except (@data-template|@data-template-type)),
            attribute href {$href},
            templates:process($node/node(), $model)
        }
};

declare function fm:mobi-href-attribute($node, $model) {
    let $href := $model?volume-meta
        => fm:id()
        => frus:mobi-url()
    return
        element {node-name($node)} {
            $node/(@* except (@data-template|@data-template-type)),
            attribute href {$href},
            templates:process($node/node(), $model)
        }
};

declare function fm:pdf-href-attribute($node, $model) {
    let $href := $model?volume-meta
        => fm:id()
        => frus:pdf-url(())
    return
        element {node-name($node)} {
            $node/(@* except (@data-template|@data-template-type)),
            attribute href {$href},
            templates:process($node/node(), $model)
        }
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

declare function fm:pub-date($volume-meta as document-node(element(volume))){
    let $date := $volume-meta/volume/(published-date[exists(string(.))])[. ne ''] ! xs:date(.)
    let $year := $volume-meta/volume/(published-year[exists(string(.))])[. ne ''] ! xs:gYear(.)
    return ($date, $year)[1]
};

declare function fm:pub-date($node as element(time), $model) {
    let $date := fm:pub-date($model?volume-meta)
    return 
        if (exists($date)) then
            element time {
                $node/(@* except @data-template),
                attribute datetime {$date},
                app:format-date-month-long-day-year($date)
            }
        else()
};

declare function fm:if-pub-date($node, $model) {
    let $date := fm:pub-date($model?volume-meta)
    return 
        if (exists($date)) then
            element { node-name($node) } {
                $node/(@* except @data-template),
                templates:process($node/node(), $model)
            }
        else ()
};

declare function fm:if-not-pub-date($node, $model) {
    let $date := fm:pub-date($model?volume-meta)
    return 
        if (empty($date)) then
            element { node-name($node) } {
                $node/(@* except @data-template),
                templates:process($node/node(), $model)
            }
        else ()
};