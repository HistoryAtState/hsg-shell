xquery version "3.0";

module namespace fhh = "http://history.state.gov/ns/site/hsg/frus-history-html";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace toc="http://history.state.gov/ns/site/hsg/frus-toc-html" at "frus-toc-html.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $fhh:FRUS_HISTORY_COL := '/db/apps/frus-history';
declare variable $fhh:FRUS_HISTORY_ARTICLES_COL := $fhh:FRUS_HISTORY_COL || '/articles';
declare variable $fhh:FRUS_HISTORY_DOCUMENTS_COL := $fhh:FRUS_HISTORY_COL || '/documents';
declare variable $fhh:FRUS_HISTORY_EVENTS_COL := $fhh:FRUS_HISTORY_COL || '/events';
declare variable $fhh:FRUS_HISTORY_MONOGRAPH_COL := $fhh:FRUS_HISTORY_COL || '/monograph';

declare function fhh:monograph-title($node, $model) {
    let $doc := doc($fhh:FRUS_HISTORY_MONOGRAPH_COL || '/frus-history.xml')
    let $title := pages:process-content($config:odd, $doc//tei:title[@type='complete'])
    return
        $title
};

declare function fhh:monograph-editors($node, $model) {
    let $doc := doc($fhh:FRUS_HISTORY_MONOGRAPH_COL || '/frus-history.xml')
    let $editors := $doc//tei:titlePage//tei:name
    return
        <ul>
            {
                $editors ! <li>{./string()}</li>                    
            }
        </ul>
};

declare function fhh:monograph-edition-info($node, $model) {
    let $doc := doc($fhh:FRUS_HISTORY_MONOGRAPH_COL || '/frus-history.xml')
    let $edition-info := 
        (
        $doc//tei:fileDesc//tei:publisher,
        $doc//tei:fileDesc//tei:pubPlace,
        $doc//tei:fileDesc//tei:sourceDesc/tei:p
        )
    return
        <ul>
            {
                $edition-info ! <li>{./string()}</li>                    
            }
        </ul>
};

declare function fhh:monograph-toc($node, $model) {
    let $doc := doc($fhh:FRUS_HISTORY_MONOGRAPH_COL || '/frus-history.xml')
    let $toc := toc:toc-passthru($doc, ())
    return
        <ul>{$toc}</ul>
};

declare function fhh:chapter($node, $model, $chapter-id) {
    let $doc := doc($fhh:FRUS_HISTORY_MONOGRAPH_COL || '/frus-history.xml')
    let $chapter := $doc/id($chapter-id)
    return
        pages:process-content($config:odd, $chapter)
};

declare function fhh:most-recent-documents($node, $model) {
    let $documents := 
        for $doc in collection($fhh:FRUS_HISTORY_DOCUMENTS_COL)/tei:TEI
        let $created := $doc//tei:date[@type='created']/@when
        let $posted := $doc//tei:date[@type='posted']/@when
        order by $posted descending, $created
        return
            $doc
    return
        <ul>
            {
            for $doc in subsequence($documents, 1, 3)
            let $title := $doc//tei:title[@type='short']
            let $id := substring-before(util:document-name($doc), '.xml')
            return
                <li><a href="$app/historicaldocuments/frus-history/documents/{$id}">{$title/string()}</a></li>
            }
            <li><a href="$app/historicaldocuments/frus-history/documents">... All Documents</a> ({count($documents)})</li>
        </ul>
};

declare function fhh:most-recent-articles($node, $model) {
    let $articles := 
        for $doc in collection($fhh:FRUS_HISTORY_ARTICLES_COL)/tei:TEI[.//tei:author]
        let $posted := $doc//tei:publicationStmt/tei:date/@when
        order by $posted descending
        return 
            $doc
    return
        <ul>
            {
            for $doc in subsequence($articles, 1, 3)
            let $title := pages:process-content($config:odd, $doc//tei:title[@type="short"])
            let $date := $doc//tei:publicationStmt/tei:date
            let $url := replace(util:document-name($doc), '.xml$', '')
            return
                <li><a href="$app/historicaldocuments/frus-history/research/{$url}">{$title}</a> ({$date/string()})</li>
            }
            <li><a href="$app/historicaldocuments/frus-history/research">... All Articles</a> ({count($articles)})</li>
        </ul>
};

declare function fhh:most-recent-events($node, $model) {
    let $events := collection($fhh:FRUS_HISTORY_EVENTS_COL)/event
    let $upcoming-events := $events[xs:date(event-date) ge current-date()]
    let $upcoming-events-list := 
        for $event in $upcoming-events
        order by xs:date($event/event-date) ascending
        return
            fhh:event-to-sidebar-list-item($event)
    let $recent-events := $events[xs:date(event-date) lt current-date()]
    let $recent-events-ordered := 
        for $event in $recent-events
        order by xs:date($event/event-date) descending
        return $event
    let $most-recent-3-events := subsequence($recent-events-ordered, 1, 3)
    let $recent-events-list := 
        for $event in $most-recent-3-events
        return
            fhh:event-to-sidebar-list-item($event)
    return
        (
        if ($upcoming-events) then
            (
                <h3><a href="$app/historicaldocuments/frus-history/events">Upcoming Events</a></h3>,
                <ul>{
                    $upcoming-events-list
                    ,
                    if ($recent-events) then
                        ()
                    else 
                        <li><a href="$app/historicaldocuments/frus-history/events">... All events ({count($events)})</a></li>
                }</ul>
            )
        else ()
        ,
        if ($recent-events) then
            (
                <h3><a href="./frus-history/events">Recent Events</a></h3>,
                <ul>{
                    $recent-events-list
                    ,
                    <li><a href="$app/historicaldocuments/frus-history/events">... All events ({count($events)})</a></li>
                }</ul>
            )
        else ()
        )
};

declare function fhh:event-to-sidebar-list-item($event as element(event)) {
    let $event-date := app:date-to-english($event/event-date)
    let $event-teaser := $event/teaser/node()
    return
        <li>
            {$event-teaser} {$event-date}
        </li>
};

declare function fhh:document-list($node, $model) {
    let $documents := collection($fhh:FRUS_HISTORY_DOCUMENTS_COL)/tei:TEI
    let $sort-by := request:get-parameter('sort-by', 'posted')
    return
        if ($sort-by = 'created') then
            (
            <p>{count($documents)} documents, sorted by document date. (<a href="?sort-by=posted">Sort by date posted.</a>)</p>,
            <ol>{
                for $doc in $documents
                let $title := $doc//tei:title[@type='complete']
                let $created := $doc//tei:date[@type='created']/@when
                let $id := substring-before(util:document-name($doc), '.xml')
                order by $created
                return
                    <li><a href="$app/historicaldocuments/frus-history/documents/{$id}">{$title/string()}</a></li>
            }</ol>
            )
        else (: if ($sort-by = 'posted') then :)
            (
            <p>{count($documents)} documents, sorted by date posted (most recent batch first). (<a href="?sort-by=created">Sort by document date.</a>)</p>,
            for $doc in $documents
            let $date-posted := $doc//tei:date[@type='posted']
            group by $date-posted-value := $date-posted/@when
            order by $date-posted-value descending
            return
                <ul>
                    <li><strong>{$date-posted-value/../string()}</strong>
                        <ol>{
                            for $each-doc in $doc
                            let $title := $each-doc//tei:title[@type='complete']
                            let $created := $each-doc//tei:date[@type='created']/@when
                            let $id := substring-before(util:document-name($each-doc), '.xml')
                            order by $created
                            return
                                <li><a href="$app/historicaldocuments/frus-history/documents/{$id}">{$title/string()}</a></li>
                        }</ol>
                    </li>
                </ul>
            )
};

declare function fhh:document-list-full($node, $model, $document-id) {
    let $documents := collection($fhh:FRUS_HISTORY_DOCUMENTS_COL)/tei:TEI
    return
        <ul>{
            for $doc in $documents
            let $title := $doc//tei:title[@type='short']
            let $created := $doc//tei:date[@type='created']/@when
            let $id := substring-before(util:document-name($doc), '.xml')
            let $highlight := if ($id = $document-id) then attribute class {'highlight'} else ()
            order by $created
            return
                <li>{$highlight}<a href="./{$id}">{$title/string()}</a></li>
        }</ul>
};

declare function fhh:document-title($node, $model, $document-id) {
    let $doc := doc($fhh:FRUS_HISTORY_DOCUMENTS_COL || "/" || $document-id || ".xml")
    let $title := $doc//tei:title[@type='complete']
    return
        pages:process-content($config:odd, $title)
};

declare function fhh:document($node, $model, $document-id) {
    let $doc := doc($fhh:FRUS_HISTORY_DOCUMENTS_COL || "/" || $document-id || ".xml")
    let $text := $doc//tei:text/*
    return
        pages:process-content($config:odd, $text)
};

declare function fhh:document-pdf($node, $model, $document-id) {
    let $doc := doc($fhh:FRUS_HISTORY_DOCUMENTS_COL || "/" || $document-id || ".xml")
    let $pdf-text := $doc//tei:sourceDesc
    return
        pages:process-content($config:odd, $pdf-text)
};

declare function fhh:articles-list($node, $model) {
    for $article in collection($fhh:FRUS_HISTORY_ARTICLES_COL)/tei:TEI[.//tei:author]
    let $title := pages:process-content($config:odd, $article//tei:title[@type="complete"])
    let $url := replace(util:document-name($article), '.xml$', '')
    let $author := $article//tei:author
    let $teaser := pages:process-content($config:odd, $article//tei:body/tei:div[1]/tei:p[1]) (: TODO suppress footnotes from being displayed here :)
    let $date := $article//tei:publicationStmt/tei:date
    order by xs:date($date/@when) descending
    return
        <div>
            <h3>
                <a href="$app/historicaldocuments/frus-history/research/{$url}">{$title}</a>
            </h3>
            <p>By {$author/string()}</p>
            <p>{$date}</p>
            {$teaser}
        </div>
};

declare function fhh:article-list-sidebar($node, $model, $article-id) {
    <ul>{
        for $article in collection($fhh:FRUS_HISTORY_ARTICLES_COL)/tei:TEI[.//tei:author]
        let $title := pages:process-content($config:odd, $article//tei:title[@type="short"])
        let $id := replace(util:document-name($article), '.xml$', '')
        let $highlight-status := if ($id eq $article-id) then attribute class {'highlight'} else ()
        let $date := $article//tei:publicationStmt/tei:date
        order by $date/@when descending
        return
            <li>{$highlight-status}<a href="$app/historicaldocuments/frus-history/research/{$id}">{$title}</a> ({$date/text()})</li>
    }</ul>
};

declare function fhh:article-title($node, $model, $article-id) {
    let $article := doc($fhh:FRUS_HISTORY_ARTICLES_COL || "/" || $article-id || ".xml")
    return
        pages:process-content($config:odd, $article//tei:title[@type='complete'])
};

declare function fhh:article-author($node, $model, $article-id) {
    let $article := doc($fhh:FRUS_HISTORY_ARTICLES_COL || "/" || $article-id || ".xml")
    let $author := $article//tei:author/text()
    let $affiliation := $article//tei:sponsor/text()
    let $date := $article//tei:publicationStmt/tei:date/text()
    return
        (
            <h3>By <span itemprop="author">{$author}</span><br/>
            <span itemprop="sourceOrganization">{$affiliation}</span></h3>,
            <h4>Released <span itemprop="datePublished">{$date}</span></h4>
        )    
};

declare function fhh:article-description($node, $model, $article-id) {
    let $article := doc($fhh:FRUS_HISTORY_ARTICLES_COL || "/" || $article-id || ".xml")
    let $publication-statement := $article//tei:sourceDesc/tei:p
    return
        pages:process-content($config:odd, $publication-statement)
};

declare function fhh:article($node, $model, $article-id) {
    let $article := doc($fhh:FRUS_HISTORY_ARTICLES_COL || "/" || $article-id || ".xml")
    return
        pages:process-content($config:odd, $article//tei:text/*)
};

declare function fhh:events($node, $model) {
    let $events := collection($fhh:FRUS_HISTORY_EVENTS_COL)/event
    let $upcoming-events := $events[xs:date(event-date) ge current-date()]
    let $upcoming-events-list := 
        for $event at $count in $upcoming-events
        order by xs:date($event/event-date) ascending
        return
            (
            $event/full-description/node(),
            if ($count lt count($upcoming-events)) then <hr/> else ()
            )

    let $recent-events := $events[xs:date(event-date) lt current-date()]
    let $recent-events-list := 
        for $event at $count in $recent-events
        order by xs:date($event/event-date) descending
        return
            (
            $event/full-description/node(),
            if ($count lt count($recent-events)) then <hr/> else ()
            )
    return
        <div>
            {
            if ($upcoming-events) then 
                (
                <h1>Upcoming Events</h1>,
                $upcoming-events-list
                )
            else ()
            }
            <h1>Recent Events</h1>
            { $recent-events-list }
        </div>
};