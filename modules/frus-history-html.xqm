xquery version "3.0";

module namespace fhh = "http://history.state.gov/ns/site/hsg/frus-history-html";

import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace toc="http://history.state.gov/ns/site/hsg/frus-toc-html" at "frus-toc-html.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $fhh:FRUS_HISTORY_COL := $config:FRUS_HISTORY_COL;
declare variable $fhh:FRUS_HISTORY_ARTICLES_COL := $config:FRUS_HISTORY_ARTICLES_COL;
declare variable $fhh:FRUS_HISTORY_DOCUMENTS_COL := $config:FRUS_HISTORY_DOCUMENTS_COL;
declare variable $fhh:FRUS_HISTORY_EVENTS_COL := $config:FRUS_HISTORY_EVENTS_COL;
declare variable $fhh:FRUS_HISTORY_MONOGRAPH_COL := $config:FRUS_HISTORY_MONOGRAPH_COL;

declare function fhh:monograph-title($node, $model) {
    let $doc := doc($fhh:FRUS_HISTORY_MONOGRAPH_COL || '/frus-history.xml')
    let $title := $model?odd($doc//tei:title[@type='complete'], ())
    return
        <h2 class="navigation-title">{$title}</h2>
};

(: Page title for Monograph sections, same content as <h1> heading :)
declare function fhh:monograph-page-title($node, $model, $section-id) {
    let $doc := doc($fhh:FRUS_HISTORY_MONOGRAPH_COL || '/frus-history.xml')
    let $section := $doc/id($section-id)/tei:head
return
    pages:process-content($model?odd, $section)
};

declare function fhh:monograph-editors($node, $model) {
    let $doc := doc($fhh:FRUS_HISTORY_MONOGRAPH_COL || '/frus-history.xml')
    let $editors := $doc//tei:titlePage//tei:name
    return
        <dl>
            <!-- {if(count($editors) gt 1) then <dt>Editors:</dt> else <dt>Editor:</dt>} -->
            {$editors ! <dd>{./string()}</dd>}
        </dl>
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
        <p>
            {
                for $line at $i in $edition-info
                return ($line/string(), if($i < count($edition-info)) then <br/> else ())
            }
        </p>
};

declare function fhh:monograph-toc($node, $model) {
    let $doc := doc($fhh:FRUS_HISTORY_MONOGRAPH_COL || '/frus-history.xml')
    let $toc := toc:toc-passthru($model, $doc, ())
    return
        <ul>{$toc}</ul>
};

declare function fhh:chapter($node, $model, $chapter-id) {
    let $doc := doc($fhh:FRUS_HISTORY_MONOGRAPH_COL || '/frus-history.xml')
    let $chapter := $doc/id($chapter-id)
    return
        pages:process-content($model?odd, $chapter)
};

declare function fhh:document-breadcrumb($node as node(), $model as map(*), $document-id as xs:string) {
    let $doc := doc($fhh:FRUS_HISTORY_DOCUMENTS_COL || "/" || $document-id || ".xml")
    let $title := $doc//tei:title[@type='short']
    return
        <a href="$app/historicaldocuments/frus-history/documents/{$document-id}">{$title/string()}</a>
};

declare function fhh:document-page-title($node as node(), $model as map(*), $document-id as xs:string) {
    let $doc := doc($fhh:FRUS_HISTORY_DOCUMENTS_COL || "/" || $document-id || ".xml")
    let $title := $doc//tei:title[@type='complete']
return
    $title
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
        <ul class="hsg-list-group">
            {
            for $doc in subsequence($documents, 1, 3)
            let $title := $doc//tei:title[@type='short']
            let $id := substring-before(util:document-name($doc), '.xml')
            return
                <li class="hsg-list-group-item"><a href="$app/historicaldocuments/frus-history/documents/{$id}">{$title/string()}</a></li>
            }
            <li class="hsg-list-group-item"><a href="$app/historicaldocuments/frus-history/documents">... All Documents</a> ({count($documents)})</li>
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
        <ul class="hsg-list-group">
            {
            for $doc in subsequence($articles, 1, 3)
            let $title := pages:process-content($model?odd, $doc//tei:title[@type="short"])
            let $date := $doc//tei:publicationStmt/tei:date
            let $url := replace(util:document-name($doc), '.xml$', '')
            return
                <li class="hsg-list-group-item"><a href="$app/historicaldocuments/frus-history/research/{$url}">{$title}</a> ({$date/string()})</li>
            }
            <li class="hsg-list-group-item"><a href="$app/historicaldocuments/frus-history/research">... All Articles</a> ({count($articles)})</li>
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
                <div class="hsg-panel-heading-second-level"><h3 class="hsg-sidebar-title-second-level"><a href="$app/historicaldocuments/frus-history/events">Upcoming Events</a></h3></div>,
                <ul class="hsg-list-group">{
                    $upcoming-events-list
                    ,
                    if ($recent-events) then
                        ()
                    else
                        <li class="hsg-list-group-item"><a href="$app/historicaldocuments/frus-history/events">... All events ({count($events)})</a></li>
                }</ul>
            )
        else ()
        ,
        if ($recent-events) then
            (
                <div class="hsg-panel-heading-second-level"><h3 class="hsg-sidebar-title-second-level"><a href="./frus-history/events">Recent Events</a></h3></div>,
                <ul class="hsg-list-group">{
                    $recent-events-list
                    ,
                    <li class="hsg-list-group-item"><a href="$app/historicaldocuments/frus-history/events">... All events ({count($events)})</a></li>
                }</ul>
            )
        else ()
        )
};

declare function fhh:event-to-sidebar-list-item($event as element(event)) {
    let $event-date := app:date-to-english($event/event-date)
    let $event-teaser := $event/teaser/node()
    return
        <li class="hsg-list-group-item">
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

declare function fhh:get-next-article($model) {
    let $div := $model?data/ancestor-or-self::tei:TEI
    let $documents := collection($fhh:FRUS_HISTORY_ARTICLES_COL)/tei:TEI
    let $col := 
            for $doc in $documents
            let $created := $doc//tei:publicationStmt/tei:date/@when
            order by $created
            return $doc
    let $index := index-of($col, $div)
    let $size := count($col)
    let $data := 
        switch($index)
            case $size return ()
            default return ($col[$index + 1]//tei:body)[1]
    let $href := if ($data) then "$app/historicaldocuments/frus-history/research/" || substring-before(util:document-name($data), '.xml') else ()
    return 
        if ($data) then 
            map{
                "data": $data,
                "href": $href
            }
        else ()
};

declare function fhh:get-previous-article($model) {
    let $div := $model?data/ancestor-or-self::tei:TEI
    let $documents := collection($fhh:FRUS_HISTORY_ARTICLES_COL)/tei:TEI
    let $col := 
            for $doc in $documents
            let $created := $doc//tei:publicationStmt/tei:date/@when
            order by $created
            return $doc
    let $index := index-of($col, $div)
    let $data := 
        switch($index)
            case 1 return ()
            default return ($col[$index - 1]//tei:body)[1]
    let $href := if ($data) then "$app/historicaldocuments/frus-history/research/" || substring-before(util:document-name($data), '.xml') else ()
    return 
        if ($data) then 
            map{
                "data": $data,
                "href": $href
            }
        else ()
};
declare function fhh:get-next-doc($model) {
    let $div := $model?data/ancestor-or-self::tei:TEI
    let $documents := collection($fhh:FRUS_HISTORY_DOCUMENTS_COL)/tei:TEI
    let $col := 
            for $doc in $documents
            let $created := $doc//tei:date[@type='created']/@when
            order by $created
            return $doc
    let $index := index-of($col, $div)
    let $size := count($col)
    let $data := 
        switch($index)
            case $size return ()
            default return ($col[$index + 1]//tei:body)[1]
    let $href := if ($data) then "$app/historicaldocuments/frus-history/documents/" || substring-before(util:document-name($data), '.xml') else ()
    return 
        if ($data) then 
            map{
                "data": $data,
                "href": $href
            }
        else ()
};

declare function fhh:get-previous-doc($model) {
    let $div := $model?data/ancestor-or-self::tei:TEI
    let $documents := collection($fhh:FRUS_HISTORY_DOCUMENTS_COL)/tei:TEI
    let $col := 
            for $doc in $documents
            let $created := $doc//tei:date[@type='created']/@when
            order by $created
            return $doc
    let $index := index-of($col, $div)
    let $data := 
        switch($index)
            case 1 return ()
            default return ($col[$index - 1]//tei:body)[1]
    let $href := if ($data) then "$app/historicaldocuments/frus-history/documents/" || substring-before(util:document-name($data), '.xml') else ()
    return 
        if ($data) then 
            map{
                "data": $data,
                "href": $href
            }
        else ()
};

declare function fhh:document-list-full($node, $model, $document-id) {
    let $documents := collection($fhh:FRUS_HISTORY_DOCUMENTS_COL)/tei:TEI
    return
        <ul class="hsg-list-group">{
            for $doc in $documents
            let $title := $doc//tei:title[@type='short']
            let $created := $doc//tei:date[@type='created']/@when
            let $id := substring-before(util:document-name($doc), '.xml')
            let $highlight := if ($id = $document-id) then 'highlight' else ''
            order by $created
            return
                <li class="hsg-list-group-item {$highlight}"><a href="./{$id}">{$title/string()}</a></li>
        }</ul>
};

declare function fhh:document-title($node, $model, $document-id) {
    let $doc := doc($fhh:FRUS_HISTORY_DOCUMENTS_COL || "/" || $document-id || ".xml")
    let $title := $doc//tei:title[@type='complete']
    return
        pages:process-content($model?odd, $title)
};

declare function fhh:document($node, $model, $document-id) {
    let $doc := doc($fhh:FRUS_HISTORY_DOCUMENTS_COL || "/" || $document-id || ".xml")
    let $text := $doc//tei:text/*
    return
        pages:process-content($model?odd, $text)
};

declare function fhh:document-pdf($node, $model, $document-id) {
    let $doc := doc($fhh:FRUS_HISTORY_DOCUMENTS_COL || "/" || $document-id || ".xml")
    let $pdf-text := $doc//tei:sourceDesc
    return
        pages:process-content($model?odd, $pdf-text)
};

declare function fhh:articles-list($node, $model) {
    for $article in collection($fhh:FRUS_HISTORY_ARTICLES_COL)/tei:TEI[.//tei:author]
    let $title := pages:process-content($model?odd, $article//tei:title[@type="complete"])
    let $url := replace(util:document-name($article), '.xml$', '')
    let $author := $article//tei:author
    let $teaser := pages:process-content($model?odd, $article//tei:body/tei:div[1]/tei:p[1]) (: TODO suppress footnotes from being displayed here :)
    let $date := $article//tei:publicationStmt/tei:date
    order by xs:date($date/@when) descending
    return
        <div class="article-container">
            <h3>
                <a href="$app/historicaldocuments/frus-history/research/{$url}">{$title}</a>
            </h3>
            <p>By {$author/string()}{$date}</p>
            {$teaser}
        </div>
};

declare function fhh:article-list-sidebar($node, $model, $article-id) {
    <ul class="hsg-list-group">{
    for $article in collection($fhh:FRUS_HISTORY_ARTICLES_COL)/tei:TEI[.//tei:author]
    let $title := pages:process-content($model?odd, $article//tei:title[@type="short"])
    let $id := replace(util:document-name($article), '.xml$', '')
    let $highlight-status := if ($id eq $article-id) then 'highlight' else ''
    let $date := $article//tei:publicationStmt/tei:date
    order by $date/@when descending
    return
        <li class="hsg-list-group-item {$highlight-status}"><a href="$app/historicaldocuments/frus-history/research/{$id}">{$title}</a> ({$date/text()})</li>
        }</ul>
};

declare function fhh:article-breadcrumb($node, $model, $document-id) {
    let $article := doc($fhh:FRUS_HISTORY_ARTICLES_COL || "/" || $document-id || ".xml")
    let $title := $article//tei:title[@type='short']
    return
        <a href="$app/historicaldocuments/frus-history/research/{$article-id}">{$title/string()}</a>
};

declare function fhh:article-title($node, $model, $document-id) {
    let $article := doc($fhh:FRUS_HISTORY_ARTICLES_COL || "/" || $document-id || ".xml")
    return
        pages:process-content($model?odd, $article//tei:title[@type='complete'])
};

declare function fhh:article-author($node, $model, $document-id) {
    let $article := doc($fhh:FRUS_HISTORY_ARTICLES_COL || "/" || $document-id || ".xml")
    let $author := $article//tei:author/text()
    let $affiliation := $article//tei:sponsor/text()
    let $date := $article//tei:publicationStmt/tei:date/text()
    return
        (
            if ($author) then
                <h3>By 
                    <span itemprop="author">{$author}</span><br/>
                    <span itemprop="sourceOrganization">{$affiliation}</span>
                </h3>
            else
                (),
            <h4>Released <span itemprop="datePublished">{$date}</span></h4>
        )
};

declare function fhh:article-description($node, $model, $document-id) {
    let $article := doc($fhh:FRUS_HISTORY_ARTICLES_COL || "/" || $document-id || ".xml")
    let $publication-statement := $article//tei:sourceDesc/tei:p
    return
        pages:process-content($model?odd, $publication-statement)
};

declare function fhh:article($node, $model, $document-id) {
    let $article := doc($fhh:FRUS_HISTORY_ARTICLES_COL || "/" || $document-id || ".xml")
    return
        pages:process-content($model?odd, $article//tei:text/*, map { "base-uri": "frus150" })
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

declare 
    %templates:replace
function fhh:appendix-a-chart-intro($node as node(), $model as map(*)) {
    let $chart-intro := doc('/db/apps/frus-history/frus-production-chart/frus-production-chart-intro.html')
    return (
        $chart-intro
    )
};

declare 
    %templates:replace
function fhh:appendix-a-chart-data($node as node(), $model as map(*)) {
    let $chart-data := util:binary-to-string(util:binary-doc('/db/apps/frus-history/frus-production-chart/frus-production-chart-data.json'))
    let $chart-parameters := util:binary-to-string(util:binary-doc('/db/apps/frus-history/frus-production-chart/frus-production-chart-parameters.json'))
    return (
    <script type="text/javascript">
        const g = window.g = new Dygraph(document.getElementById("graph"), {$chart-data}, {$chart-parameters});
        function change(el) {{
            g.setVisibility(parseInt(el.id), el.checked);
        }}
    </script>
    )
};