xquery version "3.0";

(: 
    FRUS volume-id API
:)

declare namespace opds="http://history.state.gov/ns/xquery/opds";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace request="http://exist-db.org/xquery/request";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace fh="http://history.state.gov/ns/site/hsg/frus-html" at "frus-html.xqm";
import module namespace tags="http://history.state.gov/ns/site/hsg/tags-html" at "tags-html.xqm";

declare option output:method "xml";

declare variable $opds:opds-path := 'api/v1/catalog';
declare variable $opds:server-url := substring-before(request:get-parameter('xql-application-url', ''), $opds:opds-path);
declare variable $opds:opds-base-url := $opds:server-url || $opds:opds-path;
declare variable $opds:feed-author-name {'Office of the Historian'};
declare variable $opds:opds-search-url {concat($opds:server-url, 'opensearch.xml')};
declare variable $opds:frus-ebook-volume-ids { fh:volumes-with-ebooks() };

declare function opds:feed($id, $title, $updated, $author-name, $author-uri, $links, $entries) {
    util:declare-option('exist:serialize', 'method=xml media-type=text/xml indent=yes')
    ,
    <feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en">
        <id>{$id}</id>
        <title>{$title}</title>
        <updated>{$updated}</updated>
        <author>
            <name>{$author-name}</name>
            <uri>{$author-uri}</uri>
        </author>
        {$links}
        {$entries}
    </feed>
};

declare function opds:link($type, $rel, $href, $title) {
    element { QName('http://www.w3.org/2005/Atom', 'link') } {
        if ($type) then attribute type {$type} else (),
        if ($rel) then attribute rel {$rel} else (),
        if ($href) then attribute href {$href} else (),
        if ($title) then attribute title {$title} else ()
    }
};

declare function opds:navigation-link($rel, $href, $title) {
    let $type := 'application/atom+xml;profile=opds-catalog;kind=navigation'
    return 
        opds:link($type, $rel, $href, $title)
};

declare function opds:acquisition-link($rel, $href, $title) {
    let $type := 'application/atom+xml;profile=opds-catalog;kind=acquisition'
    return 
        opds:link($type, $rel, $href, $title)
};
declare function opds:search-link() {
    let $type := 'application/opensearchdescription+xml'
    let $rel := 'search'
    let $href := $opds:opds-search-url
    let $title := 'Search Office of the Historian ebooks'
    return 
        opds:link($type, $rel, $href, $title)
};


declare function opds:entry($title, $id, $updated, $summary, $content, $link) {
    element { QName('http://www.w3.org/2005/Atom', 'entry') } {
        element title {$title},
        element id {$id},
        element updated {$updated},
        element summary { attribute type {'text'}, $summary},
        (: NOTE: I'm suppressing the content element since ShuBooks won't show summary when content is present :)
        (:         
        if ($summary = $content or $content = '' or empty($content)) then 
            ()
        else 
            element content {$content},
        :)
        $link
    }
};


declare function opds:ebook-entries($vol-ids) {
    (: not needed? let $all-volumes := collection($config:FRUS_VOLUMES_COL) :)
    for $vol-id in $vol-ids
    let $title := normalize-space(fh:vol-title($vol-id, 'volume'))
    let $id := $vol-id
    let $updated := xs:dateTime(fh:ebook-last-updated($vol-id))
    let $summary:= normalize-space(fh:vol-title($vol-id))
    let $content := 
        ()
        (: NOTE: I'm suppressing the volume summary for now since the <content> element causes ShuBooks to not show the <summary> element. :)
        (:
        let $volume-summary := $volumes/volume[@id = $vol-id]/summary[string(.) ne '']
        return
            if ($volume-summary) then
                <div xmlns="http://www.w3.org/1999/xhtml">{render:render($volume-summary, ())/*}</div>
            else ()
        :)
    let $epub-mobi-links :=
        if (fh:exists-ebook($vol-id)) then 
            (
            opds:link('application/epub+zip', 'http://opds-spec.org/acquisition', fh:epub-url($vol-id), concat($title, ' (EPUB)')),
            opds:link('application/x-mobipocket-ebook', 'http://opds-spec.org/acquisition', fh:mobi-url($vol-id), concat($title, ' (Mobi)'))
            )
        else ()
    let $pdf-link :=
        if (fh:exists-pdf($vol-id)) then 
            opds:link('application/pdf', 'http://opds-spec.org/acquisition', fh:epub-url($vol-id), concat($title, ' (PDF)'))
        else ()
    let $cover-image-link :=
        opds:link('image/jpeg', 'http://opds-spec.org/image', concat('https://s3.amazonaws.com/static.history.state.gov/frus/', $vol-id, '/covers/', $vol-id, '.jpg'), concat('Cover of ', $title))
    let $cover-image-thumbnail-link :=
        opds:link('image/jpeg', 'http://opds-spec.org/image/thumbnail', concat('https://s3.amazonaws.com/static.history.state.gov/frus/', $vol-id, '/covers/', $vol-id, '-thumb.jpg'), concat('Thumbnail-sized cover of ', $title))
    let $links := ($epub-mobi-links, $pdf-link, $cover-image-link, $cover-image-thumbnail-link)
    return
        opds:entry(
            $title,
            $id,
            $updated,
            $summary,
            $content,
            $links
            )
};

declare function opds:all() {
    let $feed-id := concat($opds:opds-base-url, '/all')
    let $feed-title := 'All Ebooks'
    let $feed-updated := current-dateTime()
    let $feed-author-name := $opds:feed-author-name
    let $feed-author-uri := $opds:server-url
    let $feed-links := 
        (
        opds:acquisition-link('self', $feed-id, $feed-title),
        opds:acquisition-link('start', $opds:opds-base-url, 'Home'),
        opds:search-link()
        )
    let $vol-ids := 
        for $vol-id in $opds:frus-ebook-volume-ids
        order by $vol-id
        return $vol-id
    let $entries := opds:ebook-entries($vol-ids)
    return
        opds:feed($feed-id, $feed-title, $feed-updated, $feed-author-name, $feed-author-uri, $feed-links, $entries)
};

declare function opds:recent() {
    let $feed-id := concat($opds:opds-base-url, '/recent')
    let $feed-title := 'Recently Published'
    let $feed-updated := current-dateTime()
    let $feed-author-name := $opds:feed-author-name
    let $feed-author-uri := $opds:server-url
    let $feed-links := 
        (
        opds:acquisition-link('self', $feed-id, $feed-title),
        opds:acquisition-link('start', $opds:opds-base-url, 'Home'),
        opds:search-link()
        )

    let $all-volumes := collection($config:FRUS_METADATA_COL)
    let $selected-volumes :=
        for $volume in $all-volumes/volume[@id = $opds:frus-ebook-volume-ids][publication-status eq 'published']
        order by $volume/published-year descending
        return $volume
    let $n := xs:integer(request:get-parameter('n', '10'))
    let $last-n-volumes := subsequence($selected-volumes, 1, $n)
    let $last-n-volume-ids := $last-n-volumes/@id/string()
    let $entries := opds:ebook-entries($last-n-volume-ids)

    return
        opds:feed($feed-id, $feed-title, $feed-updated, $feed-author-name, $feed-author-uri, $feed-links, $entries)
};

declare function opds:tag-not-found-error($tag-requested as xs:string) {
    (
    response:set-status-code(404)
    ,
    <html>
        <head>
            <title>Error 404 (Not Found)</title>
        </head>
        <body>
            <div>
                <h1>Error 404 (Not Found)</h1>
                <p>
                    No resource with tag, "{$tag-requested}", was found.  
                    Please check the value of the tag URL parameter, or follow a valid link from <a href="/api/v1/catalog">the catalog root</a>.
                </p>
            </div>
        </body>
    </html>
    )
};

declare function opds:browse() {
    let $taxonomy := collection($tags:TAXONOMY_COL)/taxonomy
    let $tag-requested := request:get-parameter('tag', ())[1]
    let $tag-exists := $taxonomy//id[. = $tag-requested]
    return
        if ($tag-requested and not($tag-exists)) then
            opds:tag-not-found-error($tag-requested)
        else
        
        
    let $tag := if ($tag-requested) then $tag-exists/.. else $taxonomy

    let $feed-id := concat($opds:opds-base-url, '/browse', if ($tag-requested) then concat('?tag=', $tag-requested) else ())
    let $feed-title := if ($tag-requested) then $tag/label/string() else 'Keywords'
    let $feed-updated := current-dateTime()
    let $feed-author-name := $opds:feed-author-name
    let $feed-author-uri := $opds:server-url
    let $feed-links := 
        (
        opds:acquisition-link('self', $feed-id, $feed-title),
        opds:acquisition-link('start', $opds:opds-base-url, 'Home'),
        opds:search-link()
        )

    let $sub-tags := $tag/(category | tag)
    
    let $tag-entries := 
        for $tag in $sub-tags
        let $title := $tag/label/string()
        let $id := $tag/id/string()
        let $updated := current-dateTime()
        let $vols-with-this-tag := tags:resources('frus')[.//tag/@id = $tag//id]
        let $vols-with-this-tag := 
            for $vol in $vols-with-this-tag
            let $link := $vol/link
            let $vol-id := substring-after($link, 'historicaldocuments/')
            return
                if ($vol-id = $opds:frus-ebook-volume-ids) then $vol else ()
        let $descendant-tags := $tag/(descendant::category | descendant::tag)/id
        let $summary := concat(if (count($descendant-tags) gt 0) then concat(count($descendant-tags), ' sub-topics, ') else (), count($vols-with-this-tag), ' volumes')
        let $content := concat('Browse volumes with subject ', $title)
        let $links := opds:navigation-link('subsection', concat($opds:opds-base-url, '/browse?tag=', $id), $title)
        return
            opds:entry(
                $title,
                $id,
                $updated,
                $summary,
                $content,
                $links
                )
    
    let $vols-with-this-tag := tags:resources('frus')[.//tag/@id = $tag-requested]
    let $vol-ids :=
        for $vol in $vols-with-this-tag
        let $vol-id := substring-after($vol/link, 'historicaldocuments/')
        order by $vol-id
        return
            $vol-id
    let $vol-ids :=  $vol-ids[. = $opds:frus-ebook-volume-ids]
    let $volume-entries := opds:ebook-entries($vol-ids)
    
    let $entries := ($tag-entries, $volume-entries)
    
    return
        opds:feed($feed-id, $feed-title, $feed-updated, $feed-author-name, $feed-author-uri, $feed-links, $entries)
};


declare function opds:search() {
    let $taxonomy := collection($tags:TAXONOMY_COL)/taxonomy
    let $q := request:get-parameter('q', ())[1]
    let $tag-hits := if ($q) then $taxonomy//label[ft:query(., $q)]/.. else ()
    let $tag-hit-ids := $tag-hits/id
    return
    
    let $feed-id := concat($opds:opds-base-url, '/search?q=', $q)
    let $feed-title := concat('Search ebooks for "', $q, '"')
    let $feed-updated := current-dateTime()
    let $feed-author-name := $opds:feed-author-name
    let $feed-author-uri := $opds:server-url
    let $feed-links := 
        (
        opds:acquisition-link('self', $feed-id, $feed-title),
        opds:acquisition-link('start', $opds:opds-base-url, 'Home'),
        opds:search-link()
        )

    let $entries := 
        for $tag in $tag-hits
        let $title := $tag/label/string()
        let $id := $tag/id/string()
        let $updated := current-dateTime()
        let $vols-with-this-tag := tags:resources('frus')[.//tag/@id = $tag//id]
        let $vols-with-this-tag := 
            for $vol in $vols-with-this-tag
            let $link := $vol/link
            let $vol-id := substring-after($link, 'historicaldocuments/')
            return
                if ($vol-id = $opds:frus-ebook-volume-ids) then $vol else ()
        let $descendant-tags := $tag/(descendant::category | descendant::tag)/id
        let $summary := concat(if (count($descendant-tags) gt 0) then concat(count($descendant-tags), ' sub-topics, ') else (), count($vols-with-this-tag), ' volumes')
        let $content := concat('Browse volumes with subject ', $title)
        let $links := opds:navigation-link('subsection', concat($opds:opds-base-url, '/browse?tag=', $id), $title)
        order by $title
        return
            opds:entry(
                $title,
                $id,
                $updated,
                $summary,
                $content,
                $links
                )
    
    return
        opds:feed($feed-id, $feed-title, $feed-updated, $feed-author-name, $feed-author-uri, $feed-links, $entries)
};

declare function opds:catalog() {
    let $feed-id := $opds:opds-base-url
    let $feed-title := 'Office of the Historian Ebook Catalog'
    let $feed-updated := current-dateTime()
    let $feed-author-name := $opds:feed-author-name
    let $feed-author-uri := $opds:server-url
    let $feed-links := 
        (
        opds:acquisition-link('self', $feed-id, $feed-title),
        opds:navigation-link('start', $feed-id, 'Foreign Relations of the United States'),
        opds:search-link()
        )
    let $entries := 
        (
        opds:entry(
            'All Volumes',
            'all',
            current-dateTime(),
            'All Foreign Relations of the United States series ebooks',
            'All Foreign Relations of the United States series ebooks',
            opds:acquisition-link('subsection', concat($opds:opds-base-url, '/all'), 'Foreign Relations of the United States Ebook Catalog')
            )
        ,
        opds:entry(
            'Recently Published',
            'recent',
            current-dateTime(),
            '10 Most Recently Published Volumes',
            '10 Most Recently Published Volumes',
            opds:acquisition-link('http://opds-spec.org/sort/new', concat($opds:opds-base-url, '/recent'), '10 Most Recently Published')
            )
        ,
        opds:entry(
            'Browse By Keywords',
            'browse',
            current-dateTime(),
            'Browse By Keywords',
            'Browse By Keywords',
            opds:navigation-link('subsection', concat($opds:opds-base-url, '/browse'), 'Browse By Keywords')
            )
        )
    return
        opds:feed($feed-id, $feed-title, $feed-updated, $feed-author-name, $feed-author-uri, $feed-links, $entries)
};


let $fragments := tokenize(substring-after(request:get-url(), $opds:opds-path), '/')[. ne '']
let $operation := $fragments[1] (: first url step after "/catalog" :)
let $start-time := util:system-time()
let $end-time := util:system-time()
let $runtime := (($end-time - $start-time) div xs:dayTimeDuration('PT1S'))
return
    switch($operation)
    (: TODO Add an error handler appropriate for this API - with error codes, redirects. We currently let bad requests through without raising errors. :)
    case 'all' return opds:all()
    case 'recent' return opds:recent()
    case 'browse' return opds:browse()
    case 'search' return opds:search()
    default return opds:catalog()