xquery version "3.1";

(:~
 : Template functions to handle page by page navigation and display
 : pages using TEI Simple.
 :)
module namespace pages="http://history.state.gov/ns/site/hsg/pages";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace expath="http://expath.org/ns/pkg";

import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace site="http://ns.evolvedbinary.com/sitemap" at "sitemap-config.xqm";
import module namespace side="http://history.state.gov/ns/site/hsg/sidebar" at "sidebar.xqm";
import module namespace link="http://history.state.gov/ns/site/hsg/link" at "link.xqm";

(: if request received from nginx :)
(: otherwise we're in the eXist URL space :)
declare variable $pages:app-root :=
    if (request:get-header('nginx-request-uri')) 
    then ("")
    else (request:get-context-path() || substring-after($config:app-root, "/db"))
;

declare variable $pages:EXIDE :=
    let $pkg := collection(repo:get-root())//expath:package[@name = "http://exist-db.org/apps/eXide"]
    let $appLink :=
        if ($pkg) then
            substring-after(util:collection-name($pkg), repo:get-root())
        else
            ()
    let $path := string-join((request:get-context-path(), request:get-attribute("$exist:prefix"), $appLink, "index.html"), "/")
    return
        replace($path, "/+", "/")
;

declare
    %templates:default("view", "div")
    %templates:default("ignore", "false")
function pages:load(
    $node as node(), $model as map(*),
    $publication-id as xs:string?, $document-id as xs:string?, $section-id as xs:string?,
    $view as xs:string, $ignore as xs:boolean,
    $open-graph-keys as xs:string?, $open-graph-keys-exclude as xs:string?, $open-graph-keys-add as xs:string?
) {
    util:log("debug", ("loading publication-id: ", $publication-id, " document-id: ", $document-id, " section-id: ", $section-id)),
    let $publication-config := ($config:PUBLICATIONS?($publication-id), map{})[1]

    let $static-open-graph := map:merge((
        for $meta in $node//*[@id eq 'static-open-graph']/meta
        return map{ string($meta/@property) : function($node as node()?, $model as map(*)?) {$meta} }
    ))

    let $static-open-graph-keys := map:keys($static-open-graph)

    let $ogk as xs:string* := if ($open-graph-keys) then tokenize($open-graph-keys, '\s') else $config:OPEN_GRAPH_KEYS
    let $ogke as xs:string* := ($static-open-graph-keys, tokenize($open-graph-keys-exclude, '\s'))
    let $ogka as xs:string* := ($static-open-graph-keys, tokenize($open-graph-keys-add, '\s')[not(. = $static-open-graph-keys)])

    let $content := map {
        "data": pages:load-xml($publication-config, $document-id, $section-id, $view, $ignore),
        "publication-id": $publication-id,
        "document-id": $document-id,
        "section-id": $section-id,
        "collection": collection($publication-config?collection),
        "view": $view,
        "base-path":
            (: allow for pages that do not have $config:PUBLICATIONS?select-document defined :)
            (: ... TODO: I do not see any such cases in config:PUBLICATIONS! Check if OK to remove this entry? - JW :)
            if (map:contains($publication-config, 'base-path')) then (
                $publication-config?base-path($document-id, $section-id)
            ) else (),
        "odd": ($publication-config?transform, $config:odd-transform-default)[1],
        "open-graph-keys": ($ogka, $ogk[not(. = $ogke)]),
        "open-graph": map:merge(($config:OPEN_GRAPH, $static-open-graph),  map{ "duplicates": "use-last" }),
        "url":
            try { request:get-url() }
            catch err:XPDY0002 { 'test-url' },  (: some contexts do not have a request object, e.g. xqsuite testing :)
        "local-uri":
            try { substring-after(request:get-uri(), $app:APP_ROOT)}
            catch err:XPDY0002 { 'test-path' }  (: some contexts do not have a request object, e.g. xqsuite testing :)
    }
    let $model-with-content := map:merge(($model, $content), map{ 'duplicates': 'use-last' })

    let $citation-meta := map{
        'citation-meta':
        if (map:contains($publication-config, 'citation-meta')) then
            $publication-config?citation-meta($node, $model-with-content)
        else
            config:default-citation-meta($node, $model-with-content)
    }

    let $with-citation := map:merge(($model-with-content, $citation-meta),  map{ "duplicates": "use-last" })

    return templates:process($node/*, $with-citation)
};

declare function pages:load-xml($publication-config as map(*), $document-id as xs:string?, $section-id as xs:string?, $view as xs:string) {
    pages:load-xml($publication-config, $document-id, $section-id, $view, false())
};

declare function pages:load-xml($publication-config as map(*), $document-id as xs:string?, $section-id as xs:string?, $view as xs:string, $ignore as xs:boolean?) {
    util:log("debug", ("pages:load-xml: config:", $publication-config , " document: ", $document-id, "; section: ", $section-id, "; view: ", $view)),
    if (empty($document-id) and empty($section-id)) then () else (
        let $block :=
            if ($view = "div" and $section-id) then
                $publication-config?select-section($document-id, $section-id)
            else if ($view = 'div') then
                $publication-config?select-document($document-id)//tei:body
            else
                $publication-config?select-document($document-id)//tei:text

        return
            if (empty($block) and not($ignore)) then (
                pages:load-fallback-page($document-id, $section-id)
            ) else (
                util:log("debug", ("pages:load-xml: Loaded ", document-uri(root($block)), ". Node name: ", node-name($block), ".")),
                $block
            )
    )
};

declare function pages:load-fallback-page($document-id as xs:string?, $section-id as xs:string?) {
    util:log("debug", ("Loading fallback page for ", $document-id)),
    let $volume := $config:FRUS_COL_VOLUMES/id($document-id)
    return
        if (empty($volume)) then (
            request:set-attribute("hsg-shell.errcode", 404),
            request:set-attribute("hsg-shell.path", string-join(($document-id, $section-id), "/")),
            error(QName("http://history.state.gov/ns/site/hsg", "not-found"), "document " || $document-id || " section " || $section-id || " not found")
        ) else
            pages:volume-to-tei($volume)
};

(: TODO delete after completing import of external location data and deciding on whether to keep summary data or not :)
declare function pages:volume-to-tei($volume as element()) {
    <tei:TEI xmlns:frus="http://history.state.gov/frus/ns/1.0" xml:id="{$volume/@xml:id}">
        <tei:teiHeader>
            <tei:fileDesc>
                {$volume//tei:fileDesc/node()}
            </tei:fileDesc>
            <tei:sourceDesc>
                {
                    if ($volume/summary/*) then
                        <tei:div>
                            <tei:head>Overview</tei:head>
                            {$volume/summary/*}
                        </tei:div>
                    else if ($volume/external-location[. ne '']) then
                        <tei:div>
                            <tei:p>This volume is available at the following location:</tei:p>
                            <tei:list>
                            {
                                $volume/external-location[. ne ''] !
                                    <tei:item>
                                        <tei:ref target="{.}">{
                                            switch (./@loc)
                                                case "madison" return "University of Wisconsin-Madison"
                                                case "worldcat" return "WorldCat"
                                                default return "Link"
                                        }</tei:ref>
                                    </tei:item>
                            }
                            </tei:list>
                        </tei:div>
                    else
                        ()
                }
            </tei:sourceDesc>
        </tei:teiHeader>
    </tei:TEI>
};

declare function pages:xml-link($node as node(), $model as map(*), $doc as xs:string) {
    let $doc-path := $config:app-root || $doc
    let $eXide-link := $pages:EXIDE || "?open=" || $doc-path
    let $rest-link := '/exist/rest' || $doc-path
    return
        element { node-name($node) } {
            $node/@* except ($node/@href, $node/@class),
            if ($pages:EXIDE)
            then (
                attribute href { $eXide-link },
                attribute data-exide-open { $doc-path },
                attribute class { "eXide-open " || $node/@class },
                attribute target { "eXide" }
            ) else (
                attribute href { $rest-link },
                attribute target { "_blank" }
            ),
            $node/node()
        }
};

declare
    %templates:default("view", "div")
    %templates:default("heading-offset", 0)
function pages:view($node as node(), $model as map(*), $view as xs:string, $heading-offset as xs:int, $document-id as xs:string?) {
    let $log := util:log("debug", "pages:view: view: " || $view || " heading-offset: " || $heading-offset)    
    let $xml :=
        if ($view = "div") then
            if ($model?data[@subtype='removed-pending-rewrite']) then
                <tei:div>
                    { $model?data/tei:head }
                    <tei:p>Notice to readers: This article has been removed pending review to ensure
                        it meets our standards for accuracy and clarity. The revised article will be
                        posted as soon as it is ready. In the meantime, we apologize for any
                        inconvenience, and we thank you for your patience.</tei:p>
                </tei:div>
            else
                pages:get-content($model?data)
        else
            $model?data//*:body/*

    return
        if ($xml instance of element(tei:pb))
        then (
            let $this-page := $xml
            let $next-page := $this-page/following::tei:pb[1]
            let $next-page-starts-document := $next-page/preceding-sibling::element()[1][self::tei:head] or (not($next-page/preceding-sibling::element()) and $next-page/parent::tei:div/@type = 'document')
            let $fragment-ending-this-page :=
                if ($next-page-starts-document) then
                    $next-page/parent::tei:div
                else
                    $next-page
            let $page-div-ids :=
                (
                    $this-page/ancestor::tei:div[@type='document'],
                    $fragment-ending-this-page/ancestor-or-self::tei:div[@type='document']/preceding::tei:div[@type='document'][.>> $this-page]
                )/@xml:id

            let $pg-id :=  concat('#', $xml/@xml:id)
            let $tif-graphic := $this-page/ancestor::tei:TEI//tei:surface[@start=string($pg-id)]//tei:graphic[@mimeType="image/tiff"]
            let $tif-graphic-height := $tif-graphic/@height => substring-before("px")
            let $tif-graphic-width := $tif-graphic/@width => substring-before("px")
            let $tif-graphic-url := $tif-graphic/@url
            let $src := concat('https://', $config:S3_DOMAIN, '/frus/', $document-id, '/medium/', $xml/@facs, '.png')
            return (
                <noscript>
                    <div class="content">
                        <img src="{ $src }" class="img-responsive img-thumbnail center-block"/>
                    </div>
                </noscript>
                ,
                <section class="osd-wrapper content">
                    <div id="viewer" data-doc-id="{ $document-id }" data-facs="{ $xml/@facs }" data-url="{ $tif-graphic-url }" data-width="{ $tif-graphic-width }" data-height="{ $tif-graphic-height }"></div>
                </section>
            )
        )
        else
            pages:process-content($model?odd, $xml, map { "base-uri": $model?base-path, "heading-offset": $heading-offset })
};

declare
    %templates:wrap
function pages:header($node as node(), $model as map(*)) {
    let $header := $model?data/ancestor-or-self::tei:TEI/tei:teiHeader
    return
        pages:process-content($model?odd, $header)
};

declare function pages:process-content($odd as function(*), $xml as element()*) {
    pages:process-content($odd, $xml, ())
};

declare function pages:process-content($odd as function(*), $xml as element()*, $parameters as map(*)?) {    
	let $html :=
	    $odd($xml, $parameters)
    let $content := pages:clean-footnotes($html)
    (: let $class := if ($html//*[@class = ('margin-note')]) then "margin-right" else () :)
    return
        <div class="content">
            {
            $content
            ,
            if ($html//li[@class="footnote"]) then
                <div class="footnotes">
                    <ol>{$html//li[@class="footnote"]}</ol>
                </div>
            else
                ()
            }
        </div>
};

declare function pages:clean-footnotes($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch($node)
            case element(li) return
                if ($node/@class = "footnote") then
                    ()
                else
                    element { node-name($node) } {
                        $node/@*,
                        pages:clean-footnotes($node/node())
                    }
            case element() return
                element { node-name($node) } {
                    $node/@*,
                    pages:clean-footnotes($node/node())
                }
            default return
                $node
};

declare
    %templates:wrap
function pages:table-of-contents($node as node(), $model as map(*), $odd as xs:string) {
    pages:toc-div(root($model?data), $odd)
};

declare %private function pages:toc-div($node, $odd as xs:string) {
    let $divs := $node//tei:div[empty(ancestor::tei:div) or ancestor::tei:div[1] is $node][tei:head]
    return
        <ul>
        {
            for $div in $divs
            let $html := for-each($div/tei:head//text(), function($node) {
                if ($node/ancestor::tei:note) then
                    ()
                else
                    $node
            })
            return
                <li>
                    <a class="toc-link" href="{util:document-name($div)}?root={util:node-id($div)}&amp;odd={$odd}">{$html}</a>
                    {pages:toc-div($div, $odd)}
                </li>
        }
        </ul>
};

declare
    %templates:wrap
function pages:styles($node as node(), $model as map(*), $odd as xs:string?) {
    attribute href {
        let $name := replace($odd, "^([^/\.]+).*$", "$1")
        return
            $pages:app-root || "/transform/" || $name || ".css"
    }
};

declare
    %templates:wrap
    %templates:default("view", "div")
function pages:navigation($node as node(), $model as map(*), $view as xs:string) {
    let $div := $model("data")
    let $work := $div/ancestor-or-self::tei:TEI
    return
        if ($view = "single") then
            map {
                "div" : $div,
                "work" : $work
            }
        else
            let $prevDiv := ($config:PUBLICATIONS?($model?publication-id)?previous)($model)
            let $nextDiv := ($config:PUBLICATIONS?($model?publication-id)?next)($model)
            return
                map {
                    "previous" : $prevDiv,
                    "next" : $nextDiv,
                    "work" : $work,
                    "div" : $div
                }
};

declare function pages:get-content($div as element()) {
    if ($div instance of element(tei:teiHeader)) then
        $div
    else (: if ($div instance of element(tei:div)) then :)
        $div
};

declare
    %templates:wrap
function pages:navigation-title($node as node(), $model as map(*)) {
    pages:title($model('data')/ancestor-or-self::tei:TEI)
};

declare function pages:title($work as element()) {
    let $main-title := $work/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[./@type = 'complete']/text()
    return
        if ($main-title) then $main-title else $work/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1]/text()
};

declare
    %templates:default("view", "div")
function pages:navigation-link($node as node(), $model as map(*), $direction as xs:string, $view as xs:string) {
    if ($view = "single") then
        ()
    else if (exists($model($direction))) then
        <a data-doc="{util:document-name($model?($direction)?data)}"
            data-root="{util:node-id($model?($direction)?data)}"
            data-current="{util:node-id($model('div'))}">
        {
            $node/@* except $node/@href,
            let $publication-id := $model?publication-id
            let $document-id := $model?document-id
            let $href :=
                typeswitch ($model?($direction)?href)
                case $fn as function(*) return $fn($model)
                default $s return $s
            return
                attribute href { app:fix-href($href) },
            $node/node()
        }
        </a>
    else
        <a href="#" style="visibility: hidden;">{$node/@class, $node/node()}</a>
};

declare function pages:generate-title ($model, $content) {
    (: Use generate-short-title; suppress default output as this will be suffixed below in any case. :)
    let $title := pages:generate-short-title($content, $model)[. ne "Office of the Historian"]

    let $head :=
        if ($model?section-id) then
            if ($model?data instance of element(tei:div)) then
                $model?data/tei:head
            else
                root($model?data)//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'complete']
        (: we can't trust pages:load-xml for the purposes of finding a document's title, since it returns the document's first descendant div :)
        (: allow for pages that don't have $config:PUBLICATIONS?select-document defined :)
        else if ($model?publication-id and map:contains(map:get($config:PUBLICATIONS, $model?publication-id), 'select-document')) then
            map:get($config:PUBLICATIONS, $model?publication-id)?select-document($model?document-id)//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'complete']
        (: allow for pages that don't have an entry in $config:PUBLICATIONS at all :)
        else
            ()

    return string-join(($head, $title, "Office of the Historian")[. ne ""], " - ")
};

(: The short title does not include super-section titles, in contrast to the full title.
 :
 : The short title is populated by the first non-empty value from the following list:
 : - A pre-defined static title on the page template: `$node/ancestor-or-self::*[last()]//div[@id="static-title"]/string()`
 : - The title defined by publication-id: `if ($model?publication-id) then map:get($config:PUBLICATIONS, $model?publication-id)?title else ()`
 : - The first H1, H2, or H3 title in the content: ($node/ancestor-or-self::*[last()]//(h1|h2|h3))[1]
 : - A fallback string of 'Office of the Historian'
 :)
declare function pages:generate-short-title($node, $model) as xs:string? {
    (
        $node/ancestor-or-self::*[last()]//div[@id="static-title"]/normalize-space(),
        $config:PUBLICATIONS?($model?publication-id)?title,
        $node/ancestor-or-self::*[last()]//(h1|h2|h3),
        'Office of the Historian'
    )[. ne ''][1]
};

(: Generate page breadcrumbs :)
declare function pages:breadcrumb($node, $model){
  util:log("debug", "pages:breadcrumb site:get-url: " || site:get-uri() || " $app:APP_ROOT: " || $app:APP_ROOT),
  pages:generate-breadcrumbs(substring-after(site:get-uri(), $app:APP_ROOT))
};

declare function pages:generate-breadcrumbs($uri as xs:string) as element(div) {
  <nav class="hsg-breadcrumb hsg-breadcrumb--wrap" aria-label="breadcrumbs">
    <ol
        vocab="http://schema.org/"
        typeof="BreadcrumbList"
        class="hsg-breadcrumb__list"
    >
      {
        site:call-with-parameters-for-uri-steps($uri, $site:config, pages:generate-breadcrumb-item#1)
      }
    </ol>
  </nav>
};

declare function pages:generate-breadcrumb-item($uri-step-state as map(*)) as element(li)*{
    (: The URI step state is generated from the site config file for each URI in the breadcrumb list :)
    <li
        class="hsg-breadcrumb__list-item"
        property="itemListElement"
        typeof="ListItem"
    >
    {
        (: We want to pass through appropriate attributes to the link generator :)
        let $link-attributes := function() as attribute()* {
            attribute class { "hsg-breadcrumb__link" },
            attribute property { "item" },
            attribute typeof { "WebPage" }
        }
        let $state := map:merge(($uri-step-state, map{'link-attributes': $link-attributes}), map{'duplicates': 'use-last'})
        return link:generate-from-state($state)
    }
    </li>
};


declare function pages:app-root($node as node(), $model as map(*)) {
    let $root := try {
        if (request:get-header("nginx-request-uri")) then (
            ""
            (: replace(request:get-header("nginx-request-uri"), "^(\w+://[^/]+).*$", "$1") :)
        ) else
            request:get-context-path() || substring-after($config:app-root, "/db")}
        catch err:XPDY0002 {()} (: required for local testing when there is no request :)
    return
    element { node-name($node) } {
        $node/@*,
        attribute data-app { $root },
        let $content as node()* := templates:process($node/*, $model)
        let $title := string-join((pages:generate-short-title($content, $model)[. ne 'Office of the Historian'], "Office of the Historian"), " - ")

        let $log := util:log("debug", "pages:app-root -> title: " || $title)
        return (
            <head>
                {$content[self::head]/*}
                <title>{$title}</title>
            </head>,
            $content/self::body
        )
    }
};

(: lets a template provide a full path to a document, as used in pages/departmenthistory/buildings.
 : TODO: extend with an $odd parameter. :)
declare function pages:render-document($node, $model, $document-path, $section-id) {
    pages:process-content($model?odd,
        doc($document-path)/id($section-id))
};

declare
    %templates:wrap
function pages:document-link($node, $model) {
    element a {
        $node/@*,
        root($model?data)//tei:title[@type = 'complete']/string()
    }
};

declare
    %templates:wrap
function pages:section-link($node, $model) {
    element a {
        $node/@*,
        if ($model?data instance of element(tei:div)) then
            $model?data/tei:head[1]/string()
        else
            root($model?data)//tei:title[@type = 'complete']/string()
    }
};

(: Page title for conferences/*
TODO Refactor and create a page title module :)
declare
    %templates:wrap
function pages:conference-title($node, $model) {
    element a {
        $node/@*,
        if ($model?data instance of element(tei:div)) then
            concat($model?data/tei:head[1]/string(), ' - Conferences')
        else
            concat(root($model?data)//tei:title[@type = 'short']/string(), ' - Conferences')
    }
};

(: Page title for conferences/**/*
TODO Refactor and create a page title module :)
declare
    %templates:wrap
function pages:conference-subpage-title($node, $model) {
    element a {
        $node/@*,
        concat($model?data/tei:head[1]/string(), ' - ', root($model?data)//tei:title[@type = 'short']/string(), ' - Conferences')
    }
};

(: Page title for about/hac/*
TODO Refactor and create a page title module :)
declare
    %templates:wrap
function pages:hac-title($node, $model) {
    element a {
        $node/@*,
        if ($model?data instance of element(tei:div)) then
            concat($model?data/tei:head[1]/string(), ' - Historical Advisory Committee - About Us')
        else
            concat(root($model?data)//tei:title[@type = 'short']/string(), ' - Historical Advisory Committee - About Us')
    }
};

(: Page title for about/faq/*
TODO Refactor and create a page title module:)
declare
    %templates:wrap
function pages:faq-title($node, $model) {
    element a {
        $node/@*,
        if ($model?data instance of element(tei:div)) then
            concat($model?data/tei:head[1]/string(), ' - FAQs - About Us')
        else
            concat(root($model?data)//tei:title[@type = 'short']/string(), ' - FAQs - About Us')
    }
};

declare function pages:deep-section-breadcrumbs($node, $model, $truncate as xs:boolean?) {
    if ($model?data instance of element(tei:div)) then
        for $div in $model?data/ancestor-or-self::tei:div[@xml:id]
        return
            element li {
                attribute class { "section-breadcrumb"},
                element a {
                    attribute class { "section" },
                    attribute href { $div/@xml:id },
                    if ($truncate) then
                        let $words := tokenize($div/tei:head, '\s+')
                        let $max-word-count := 8
                        return
                            if (count($words) gt $max-word-count) then
                                concat(string-join(subsequence($words, 1, $max-word-count), ' '), '...')
                            else
                                $div/tei:head/string()
                    else
                        $div/tei:head/string()
                }
            }
    else
        element li {
            attribute class { "section-breadcrumb" },
            element a {
                attribute class { "section" },
                root($model?data)//tei:title[@type = 'complete']/string()
            }
        }
};

declare function pages:deep-section-page-title($node, $model) {
    if ($model?data instance of element(tei:div)) then
        for $div in $model?data/ancestor-or-self::tei:div[1]
        return concat($div/tei:head/string(), ' - ', pages:section-category($node, $model))
    else ()
};

declare function pages:section-category($node, $model) {
    root($model?data)//tei:title[@type = 'short']/string()
};

declare function pages:asides($node, $model){
    (:
     : function to generate asides (e.g. sidebars) on pages; eventually all sidebar content will be generated here,
     : but for now we will recurse over existing content.
     :)
    let $static-asides :=
    <aside class="hsg-aside--static">
        {
            let $nodes := $node/node()[not(@data-template eq 'pages:section-nav')]
            let $processed := templates:process($nodes, $model)
            return app:fix-links($processed)
        }
    </aside>
    return
        <div class="hsg-width-sidebar">
            {
                (: side:info($node, $model), :)
                $static-asides,
                side:section-nav($node, $model)
            }
        </div>
};

declare function pages:suppress($node as node()?, $model as map(*)?) {};

declare function pages:unless-asides($node, $model){
    if ($node/ancestor::body//aside[@data-template eq 'pages:asides'])
    then ()
    else $node
};
