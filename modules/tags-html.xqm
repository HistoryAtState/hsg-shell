xquery version "3.0";

module namespace tags = "http://history.state.gov/ns/site/hsg/tags-html";

import module namespace frus="http://history.state.gov/ns/site/hsg/frus-html" at "frus-html.xqm";
import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace app = "http://history.state.gov/ns/site/hsg/templates" at "app.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $tags:TAGS_COL := '/db/apps/tags';
declare variable $tags:TAXONOMY_COL := $tags:TAGS_COL || '/taxonomy';

declare function tags:resources($collection) {
    switch ($collection)
        case "frus" return collection($config:FRUS_COL_VOLUMES)//tei:keywords[@scheme eq "https://history.state.gov/tags"]/root(.)/tei:TEI
        case "secretary-bios" return collection($config:OP_SECRETARY_BIOS_COL)//tei:keywords[@scheme eq "https://history.state.gov/tags"]/root(.)/tei:TEI
        default return ()
};

declare function tags:count-resources($node, $model, $collection as xs:string) {
    count(tags:resources($collection))
};

declare function tags:count-resource-tags($node, $model) {
    format-number(
        count(
            (
                collection($config:FRUS_COL_VOLUMES)//tei:keywords[@scheme eq "https://history.state.gov/tags"]/tei:term,
                collection($config:OP_SECRETARY_BIOS_COL)//tei:keywords[@scheme eq "https://history.state.gov/tags"]/tei:term
            )
        ),
        '#,###.'
    )
};

declare function tags:tag-count($node, $model) {
    format-number(count(collection($tags:TAXONOMY_COL)//id), '#,###.')
};

declare function tags:tags-in-context-toc($node, $model, $tag-id as xs:string*) {
    let $tag := collection($tags:TAXONOMY_COL)//id[. = $tag-id]/..
    return
        <ul class="list-unstyled">{
            for $top-level in collection($tags:TAXONOMY_COL)/taxonomy/(tag | category)
            let $highlight := if ($top-level = $tag) then attribute class {'highlight'} else ()
            let $hit-count := 
                count(
                    (
                        collection($config:FRUS_COL_VOLUMES)//tei:keywords[@scheme eq "https://history.state.gov/tags"]//tei:term[. = $top-level//id],
                        collection($config:OP_SECRETARY_BIOS_COL)//tei:keywords[@scheme eq "https://history.state.gov/tags"]/tei:term[. = $top-level//id]
                    )
                )
            return
                <li>{
                    let $item := <span>{$highlight}<a href="$app/tags/{$top-level/id}">{$top-level/label/string()}</a> ({$hit-count})</span>
                    return
                        if ($highlight) then $item else $item/node()
                    ,
                    if ($top-level//id = $tag-id) then tags:descend($top-level, $tag, true()) else ()
                    }
                </li>
        }</ul>
};

declare function tags:descend($taxonomy-level, $tag, $show-even-if-empty) {
    <ul class="list-unstyled">{
        let $entries := $taxonomy-level/(tag | category)
        for $entry in $entries
        let $highlight := if ($entry = $tag) then attribute class {'highlight'} else ()
        let $hit-count := 
            count(
                (
                    collection($config:FRUS_COL_VOLUMES)//tei:keywords[@scheme eq "https://history.state.gov/tags"]/tei:term[. = $entry//id],
                    collection($config:OP_SECRETARY_BIOS_COL)//tei:keywords[@scheme eq "https://history.state.gov/tags"]/tei:term[. = $entry//id]
                )
            )
        return
            if ($hit-count ge 1 or ($hit-count = 0 and $show-even-if-empty)) then
                <li>
                    {
                    let $item := <span>{$highlight}<a href="$app/tags/{$entry/id}">{$entry/label/string()}</a> ({format-number($hit-count, '#,###.')})</span>
                    return
                        if ($highlight) then $item else $item/node()
                    ,
                    if ($entry//id = $tag/id) then tags:descend($entry, $tag, $show-even-if-empty) else ()}
                </li>
            else ()
    }</ul>
};

declare function tags:get-link($node, $model, $tag-id as xs:string) {
    let $tag-id-exists := collection($tags:TAXONOMY_COL)//id[. = $tag-id]
    let $tag := $tag-id-exists/..
    return <a href="$app/tags/{$tag/id/string()}">{$tag/label/string()}</a>
};

declare function tags:show-tag($node, $model, $tag-id as xs:string) {
    let $tag-id-exists := collection($tags:TAXONOMY_COL)//id[. = $tag-id]
    let $tag := $tag-id-exists/..
    let $child-tags := $tag/(tag | category)
    let $tagged-volumes := collection($config:FRUS_COL_VOLUMES)//tei:keywords[@scheme eq "https://history.state.gov/tags"][tei:term = $tag-id]/root(.)/tei:TEI
    let $tagged-secretary-bios := collection($config:OP_SECRETARY_BIOS_COL)//tei:keywords[@scheme eq "https://history.state.gov/tags"][tei:term = $tag-id]/root(.)/tei:TEI
    return
        if ($tag-id-exists) then
            <div>
                <h2>{$tag/label/string()}</h2>
                {if ($tag/definition) then <p>{tags:typeswitch($tag/definition)}</p> else ()}
                {
                if ($tagged-secretary-bios or $tagged-volumes) then
                    (
                    if ($tagged-secretary-bios) then
                        <div>
                            <h3>Biographies of the Secretaries of State ({count($tagged-secretary-bios)})</h3>
                            <ul class="list-unstyled">{
                                for $bio in $tagged-secretary-bios
                                let $url := concat('$app/departmenthistory/people/', $bio/secretary-bios-id)
                                return
                                    <li><a href="{$url}">{$bio//tei:title[@type eq "short"]/string()}</a></li>
                            }</ul>
                        </div>
                    else ()
                    ,
                    if ($tagged-volumes) then
                        <div>
                            <h3><em>Foreign Relations</em> volumes ({count($tagged-volumes)})</h3>
                            <ul class="list-unstyled">{
                                for $volume in $tagged-volumes
                                let $volume-id := $volume/@xml:id
                                let $url := "$app/historicaldocuments/" || $volume-id
                                let $volume-title := normalize-space(frus:vol-title($volume-id))
                                order by $volume-id
                                return
                                    <li><a href="{$url}">{$volume-title}</a></li>
                            }</ul>
                        </div>
                    else ()
                    ,
                    if ($child-tags) then
                        <div>
                            <h3>Resources covering specific subjects within {$tag/label/string()}:</h3>
                            { tags:descend($tag, $tag/id, false()) }
                        </div>
                    else ()
                    )
                else
                    let $descendant-tag-ids := $child-tags//id
                    let $matching-resource-tags := 
                        (
                            collection($config:FRUS_COL_VOLUMES)//tei:keywords[@scheme eq "https://history.state.gov/tags"]/tei:term[. = $descendant-tag-ids],
                            collection($config:OP_SECRETARY_BIOS_COL)//tei:keywords[@scheme eq "https://history.state.gov/tags"]/tei:term[. = $descendant-tag-ids]
                        )
                    let $matching-resources := $matching-resource-tags/root(.)/tei:TEI
                    return
                        if ($matching-resources) then
                            <div>
                                <p>No resources have been specifically identified as “{$tag/label/string()},” but {count($matching-resources)} resources beneath this level in the taxonomy have been tagged with {count(distinct-values($matching-resource-tags))} distinct tags. Please dig deeper:</p>
                                {tags:descend($tag, $tag/id, false())}
                            </div>
                        else
                            <p>No resources have been tagged {$tag/label/string()}.</p>
                }
            </div>
    else
        (
        request:set-attribute("hsg-shell.errcode", 404),
        request:set-attribute("hsg-shell.path", string-join(("tags", $tag-id), "/")),
        error(QName("http://history.state.gov/ns/site/hsg", "not-found"), "tag-id " || $tag-id || " not found")
        )
};

declare function tags:all-tags($node, $model) {
    tags:taxonomy-to-html-list(collection($tags:TAXONOMY_COL)/taxonomy)
};

declare function tags:taxonomy-to-html-list($taxonomy-node) {
    <ul class="hsg-tag-list">{
        for $tag in $taxonomy-node/(tag | category)
        return
            <li><a href="$app/tags/{$tag/id}">{$tag/label/string()}</a>{
                if ($tag/definition) then <span class="hsg-font-italic">&#160; {tags:typeswitch($tag/definition)}</span> else (),
                if ($tag/(tag|category)) then tags:taxonomy-to-html-list($tag) else ()
            }</li>
    }</ul>
};

declare function tags:recurse($node) {
    for $child in $node/node()
    return
        tags:typeswitch($child)
};

declare function tags:typeswitch($nodes) {
    for $node in $nodes
    return
        typeswitch ($node)
            case text() return $node
            case element(id) return ()
            case element(definition) return tags:definition($node)
            case element(ptr) return tags:ptr($node)
            case element(a) return $node
            default return tags:recurse($node)
};


declare function tags:definition($node) {
    tags:recurse($node)
};

declare function tags:usage-hint($node) {
    tags:recurse($node)
};

declare function tags:ptr($node) {
    let $target := $node/@target
    let $label := collection($tags:TAXONOMY_COL)//(tag|category)[id = $target]/label/string()
    return
        <a href="$app/tags/{$target}">{$label}</a>
};

declare
    %templates:wrap
function tags:load-tags($node as node(), $model as map(*), $document-id as xs:string) {
    let $tags := $config:PUBLICATIONS?frus?select-document($document-id)//tei:keywords[@scheme eq "https://history.state.gov/tags"]/tei:term
    return
        if ($tags) then
            map { "tags": $tags }
        else
            ()
};

declare
    %templates:wrap
function tags:list-tags($node as node(), $model as map(*)) {
    for $tag in $model?tags
    let $label := collection($tags:TAXONOMY_COL)//id[. = $tag]/../label
    order by $tag
    return
        <li class="hsg-list-group-item"><a href="{$app:APP_ROOT}/tags/{$tag}" title="Resources tagged {$label}">{$label/text()}</a></li>
};
