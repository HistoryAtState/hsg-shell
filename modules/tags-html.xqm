xquery version "3.0";

module namespace tags = "http://history.state.gov/ns/site/hsg/tags-html";

import module namespace frus="http://history.state.gov/ns/site/hsg/frus-html" at "frus-html.xqm";
import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace app = "http://history.state.gov/ns/site/hsg/templates" at "app.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $tags:TAGS_COL := '/db/apps/tags';
declare variable $tags:TAXONOMY_COL := $tags:TAGS_COL || '/taxonomy';
declare variable $tags:RESOURCES_COL := $tags:TAGS_COL || '/tagged-resources';

declare function tags:resources($collection) {
    collection($tags:RESOURCES_COL || "/" || $collection)//study
};

declare function tags:count-resources($node, $model, $collection as xs:string) {
    count(tags:resources($collection))
};

declare function tags:count-resource-tags($node, $model) {
    format-number(count(collection($tags:RESOURCES_COL)//tag), '#,###.')
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
            let $hit-count := count((collection($tags:RESOURCES_COL || '/frus') | collection($tags:RESOURCES_COL || '/milestones') | collection($tags:RESOURCES_COL || '/secretary-bios'))//tag[@id  = $top-level//id])
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
        let $hit-count := count((collection($tags:RESOURCES_COL || '/frus') | collection($tags:RESOURCES_COL || '/milestones') | collection($tags:RESOURCES_COL || '/secretary-bios'))//tag[@id  = $entry//id])
        return
            if ($hit-count ge 1 or ($hit-count = 0 and $show-even-if-empty)) then
                <li>
                    {
                    let $item := <span>{$highlight}<a href="$app/tags/{$entry/id}">{$entry/label/string()}</a> ({$hit-count})</span>
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
    let $milestones-resources := collection($tags:RESOURCES_COL || 'milestones')
    let $milestone-tags := $milestones-resources//tag
    let $tagged-milestone-essays := $milestone-tags[@id = $tag-id]/ancestor::study
    let $frus-resources := collection($tags:RESOURCES_COL || '/frus')
    let $volume-tags := $frus-resources//tag
    let $tagged-volumes := $volume-tags[@id = $tag-id]/ancestor::study
    let $secretary-bios-resources := collection($tags:RESOURCES_COL || 'secretary-bios')
    let $secretary-bios-tags := $secretary-bios-resources//tag
    let $tagged-secretary-bios := $secretary-bios-tags[@id = $tag-id]/ancestor::study
    return
        if ($tag-id-exists) then
            <div>
                <h2>{$tag/label/string()}</h2>
                {if ($tag/definition) then <p>{tags:typeswitch($tag/definition)}</p> else ()}
                {
                (:
                if ($child-tags) then
                    <div>
                        <h3>Tags within {$tag/label/string()}:</h3>
                        <ul class="list-unstyled">{
                            for $child in $child-tags
                            return
                                <li><a href="$app/tags/{$child/id}">{$child/label/string()}</a></li>
                        }</ul>
                    </div>
                else ()
                :)
                ''
                }
                {
                if ($tagged-secretary-bios or $tagged-milestone-essays or $tagged-volumes) then
                    (
                    if ($tagged-secretary-bios) then
                        <div>
                            <h3>Biographies of the Secretaries of State ({count($tagged-secretary-bios)})</h3>
                            <ul class="list-unstyled">{
                                for $bio in $tagged-secretary-bios
                                let $url := concat('$app/departmenthistory/people/', $bio/secretary-bios-id)
                                return
                                    <li><a href="{$url}">{$bio/title/string()}</a></li>
                            }</ul>
                        </div>
                    else ()
                    ,
                    if ($tagged-milestone-essays) then
                        <div>
                            <h3>Milestone Essays ({count($tagged-milestone-essays)})</h3>
                            <ul class="list-unstyled">{
                                for $essay in $tagged-milestone-essays
                                let $url := concat('$app/milestones/', $essay/milestone-grouping, '/', $essay/milestone-id)
                                return
                                    <li><a href="{$url}">{$essay/title/string()}</a></li>
                            }</ul>
                        </div>
                    else ()
                    ,
                    if ($tagged-volumes) then
                        <div>
                            <h3><em>Foreign Relations</em> volumes ({count($tagged-volumes)})</h3>
                            <ul class="list-unstyled">{
                                for $volume in $tagged-volumes
                                let $url := "$app" || substring-after($volume/link, 'history.state.gov')
                                let $volume-id := substring-after($url, '/historicaldocuments/')
                                let $volume-title := normalize-space(frus:vol-title($volume-id))
                                order by $volume-id
                                return
                                    <li><a href="{$url}">{$volume-title}</a></li>
                            }</ul>
                        </div>
                    else ()
                    )
                else
                    let $descendant-tag-ids := $child-tags//id
                    let $matching-resource-tags := ($milestones-resources, $frus-resources)//tag[@id = $descendant-tag-ids]
                    let $matching-resources := $matching-resource-tags/ancestor::study
                    return
                        if ($matching-resources) then
                            <div>
                                <p>No resources have been specifically identified as “{$tag/label/string()},” but {count($matching-resources)} resources beneath this level in the taxonomy have been tagged with {count(distinct-values($matching-resource-tags/@id))} distinct tags. Please dig deeper:</p>
                                {tags:descend($tag, $tag/id, false())}
                            </div>
                        else
                            <p>No resources have been tagged {$tag/label/string()}.  Please select another tag from the list on the left.</p>
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
    let $tags := collection($tags:RESOURCES_COL)//link[. = 'http://history.state.gov/historicaldocuments/' || $document-id]/..
    return
        if ($tags) then
            map { "tags": $tags }
        else
            ()
};

declare
    %templates:wrap
function tags:list-tags($node as node(), $model as map(*)) {
    for $tag in $model?tags//tag/@id
    let $label := collection($tags:TAXONOMY_COL)//id[. = $tag]/../label
    order by $tag
    return
        <li class="hsg-list-group-item"><a href="{$app:APP_ROOT}/tags/{$tag}" title="Resources tagged {$label}">{$label/text()}</a></li>
};
