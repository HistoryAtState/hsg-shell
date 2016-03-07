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

declare option output:method "xml";

declare variable $opds:opds-path := 'api/v1/catalog';
declare variable $opds:server-url := substring-before(request:get-url(), $opds:opds-path);
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
    let $volumes := collection($config:FRUS_VOLUMES_COL)
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
        opds:link('image/jpeg', 'http://opds-spec.org/image', concat('//s3.amazonaws.com/static.history.state.gov/frus/', $vol-id, '/covers/', $vol-id, '.jpg'), concat('Cover of ', $title))
    let $cover-image-thumbnail-link :=
        opds:link('image/jpeg', 'http://opds-spec.org/image/thumbnail', concat('//s3.amazonaws.com/static.history.state.gov/frus/', $vol-id, '/covers/', $vol-id, '-thumb.jpg'), concat('Thumbnail-sized cover of ', $title))
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
    <error>"recent" not supported yet</error>
};

declare function opds:browse() {
    <error>"browse" not supported yet</error>
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
    case 'all' return opds:all()
    case 'recent' return opds:recent()
    case 'browse' return opds:browse()
    default return opds:catalog()
