xquery version "3.1";

(:~
 : Template functions to handle page by page navigation and display
 : pages using TEI Simple.
 :)
module namespace pages="http://history.state.gov/ns/site/hsg/pages";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace expath="http://expath.org/ns/pkg";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
(:import module namespace pmu="http://www.tei-c.org/tei-simple/xquery/util" at "/db/apps/tei-simple/content/util.xql";:)
(:import module namespace odd="http://www.tei-c.org/tei-simple/odd2odd" at "/db/apps/tei-simple/content/odd2odd.xql";:)
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare variable $pages:app-root := request:get-context-path() || substring-after($config:app-root, "/db");

declare variable $pages:EXIDE :=
    let $pkg := collection(repo:get-root())//expath:package[@name = "http://exist-db.org/apps/eXide"]
    let $appLink :=
        if ($pkg) then
            substring-after(util:collection-name($pkg), repo:get-root())
        else
            ()
    let $path := string-join((request:get-context-path(), request:get-attribute("$exist:prefix"), $appLink, "index.html"), "/")
    return
        replace($path, "/+", "/");

declare
    %templates:default("view", "div")
    %templates:default("ignore", "false")
function pages:load($node as node(), $model as map(*), $publication-id as xs:string?, $document-id as xs:string?,
        $section-id as xs:string?, $view as xs:string, $ignore as xs:boolean) {
    let $log := console:log("loading publication-id: " || $publication-id || " document-id: " || $document-id || " section-id: " || $section-id )

    let $content := map {
        "data":
            if (exists($publication-id) and exists($document-id)) then
                pages:load-xml($publication-id, $document-id, $section-id, $view, $ignore)
            else (),
        "publication-id": $publication-id,
        "document-id": $document-id,
        "section-id": $section-id,
        "view": $view,
        "base-path":
            (: allow for pages that don't have $config:PUBLICATIONS?select-document defined :)
            if (exists($publication-id) and map:contains(map:get($config:PUBLICATIONS, $publication-id), 'base-path')) then
                map:get($config:PUBLICATIONS, $publication-id)?base-path($document-id, $section-id)
            else (),
        "odd": if (exists($publication-id)) then map:get($config:PUBLICATIONS, $publication-id)?transform else $config:odd-transform-default
    }

    return
        templates:process($node/*, map:new(($model, $content)))
};

declare function pages:load-xml($publication-id as xs:string, $document-id as xs:string, $section-id as xs:string?, $view as xs:string) {
    pages:load-xml($publication-id, $document-id, $section-id, $view, false())
};

declare function pages:load-xml($publication-id as xs:string, $document-id as xs:string, $section-id as xs:string?,
    $view as xs:string, $ignore as xs:boolean?) {
    console:log("pages:load-xml: publication: " || $publication-id || "; document: " || $document-id || "; section: " || $section-id || "; view: " || $view),
    let $block :=
        if ($view = "div") then
            if ($section-id) then (
                map:get($config:PUBLICATIONS, $publication-id)?select-section($document-id, $section-id)
            ) else
                map:get($config:PUBLICATIONS, $publication-id)?select-document($document-id)//tei:body
        else
            map:get($config:PUBLICATIONS, $publication-id)?select-document($document-id)//tei:text
    return
        if (empty($block) and not($ignore)) then (
            pages:load-fallback-page($publication-id, $document-id, $section-id)
        ) else (
            console:log("pages:load-xml: Loaded " || document-uri(root($block)) || ". Node name: " || node-name($block) || "."),
            $block
        )
};

declare function pages:load-fallback-page($publication-id as xs:string, $document-id as xs:string, $section-id as xs:string?) {
    let $volume := $config:FRUS_METADATA/volume[@id=$document-id]
    let $log := console:log("Loading fallback page for " || $document-id)
    return
        if (empty($volume)) then (
            request:set-attribute("hsg-shell.errcode", 404),
            request:set-attribute("hsg-shell.path", string-join(($document-id, $section-id), "/")),
            error(QName("http://history.state.gov/ns/site/hsg", "not-found"), "publication " || $publication-id || " document " || $document-id || " section " || $section-id || " not found")
        ) else
            pages:volume-to-tei($volume)
};

declare function pages:volume-to-tei($volume as element()) {
    <tei:TEI xmlns:frus="http://history.state.gov/frus/ns/1.0" xml:id="{$volume/@id}">
        <tei:teiHeader>
            <tei:fileDesc>
                <tei:titleStmt>
                    <tei:title type="complete">{$volume/title[@type="complete"]/node()}</tei:title>
                    <tei:title type="subseries">{$volume/title[@type="sub-series"]/node()}</tei:title>
                    <tei:title type="volumenumber">{$volume/title[@type="volumenumber"]/node()}</tei:title>
                    <tei:title type="volume">{$volume/title[@type="volume"]/node()}</tei:title>
                    {
                        for $editor in $volume/editor[. ne '']
                        return
                            <tei:editor>{$editor/@role, $editor/node()}</tei:editor>
                    }
                </tei:titleStmt>
            </tei:fileDesc>
            <tei:sourceDesc>
                {
                    if ($volume/summary/*) then
                        <tei:div>
                            <tei:head>Overview</tei:head>
                            {$volume/summary/*}
                        </tei:div>
                    else if ($volume/location[. ne '']) then
                        <tei:div>
                            <tei:p>This volume is available at the following location:</tei:p>
                            <tei:list>
                            {
                                $volume/location[. ne ''] !
                                    <tei:item>{console:log(serialize(<ref target="{.}">University of Wisconsin-Madison</ref>)), if (./@loc = 'madison') then <tei:ref target="{.}">University of Wisconsin-Madison</tei:ref> else ()}</tei:item>
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
function pages:view($node as node(), $model as map(*), $view as xs:string, $heading-offset as xs:int) {
    let $log := console:log("pages:view: view: " || $view || " heading-offset: " || $heading-offset)
    let $xml :=
        if ($view = "div") then
            pages:get-content($model?data)
        else
            $model?data//*:body/*
    return
        if ($xml instance of element(tei:pb)) then
            let $href := concat('//', $config:S3_DOMAIN, '/frus/', substring-before(util:document-name($xml), '.xml') (:ACK why is this returning blank?!?! root($xml)/tei:TEI/@xml:id:), '/medium/', $xml/@facs, '.png')
            return
                <div class="content">
                    <img src="{$href}" class="img-responsive img-thumbnail center-block"/>
                </div>
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
(:    console:log("Processing content using odd: " || $odd),:)
	let $html :=
	    $odd($xml, $parameters)
(:        pmu:process(odd:get-compiled($config:odd-source, $odd, $config:odd-compiled), $xml, $config:odd-compiled, "web", "../generated", :)
(:            $config:module-config, $parameters):)
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
            $pages:app-root || "/resources/odd/compiled/" || $name || ".css"
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
            (:  TODO: not sure if the following check for divs containing only a div as first element is needed.
                Code was copied from tei-simple generic app where this case could occur and led to empty pages.
                Do we need the same for hsg? The check is very expensive.
            :)
(:            let $parent := $div/ancestor::tei:div[not(*[1] instance of element(tei:div))][1]:)
            let $prevDiv := pages:get-previous($div)
            let $nextDiv := pages:get-next($div)
        (:        ($div//tei:div[not(*[1] instance of element(tei:div))] | $div/following::tei:div)[1]:)
            return
                map {
                    "previous" : $prevDiv,
                    "next" : $nextDiv,
                    "work" : $work,
                    "div" : $div
                }
};

declare function pages:get-next($div as element()) {
    if ($div/self::tei:pb) then
        $div/following::tei:pb[1]
    else if ($div/tei:div[@xml:id]) then
        $div/tei:div[@xml:id][1]
    else
        ($div/following::tei:div[@xml:id] except $div/id($config:IGNORED_DIVS))[1]
};

declare function pages:get-previous($div as element()?) {
    if ($div/self::tei:pb) then
        $div/preceding::tei:pb[1]
    else if (($div/preceding-sibling::tei:div[@xml:id] except $div/id($config:IGNORED_DIVS))[not(tei:div/@type)]) then
        ($div/preceding-sibling::tei:div[@xml:id] except $div/id($config:IGNORED_DIVS))[1]
    else
        (
            $div/ancestor::tei:div[@type = ('compilation', 'chapter', 'subchapter', 'section', 'part')][tei:div/@type][1],
            ($div/preceding::tei:div[@xml:id] except $div/id($config:IGNORED_DIVS))[1]
        )[1]
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
    else if ($model($direction)) then
        <a data-doc="{util:document-name($model($direction))}"
            data-root="{util:node-id($model($direction))}"
            data-current="{util:node-id($model('div'))}">
        {
            $node/@* except $node/@href,
            let $publication-id := $model?publication-id
            let $document-id := $model?document-id
            let $section-id := $model($direction)/@xml:id
            let $href :=
                if (map:contains(map:get($config:PUBLICATIONS, $publication-id), 'html-href')) then
                    map:get($config:PUBLICATIONS, $publication-id)?html-href($document-id, $section-id)
                else
                    $model($direction)/@xml:id
            return
                attribute href { app:fix-href($href) },
            $node/node()
        }
        </a>
    else
        <a href="#" style="visibility: hidden;">{$node/@class, $node/node()}</a>
};

declare function pages:generate-title ($model, $content) {
    (: without an entry in $config:PUBLICATIONS and a publication-id parameter from controller.xql,
     : only the stock "Office of the Historian" title will appear in the <title> element :)
    let $title :=
        if ($model?publication-id) then
            map:get($config:PUBLICATIONS, $model?publication-id)?title
        else
            ($content//(h1|h2|h3))[1]

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

declare
    %templates:wrap
function pages:app-root($node as node(), $model as map(*)) {
    let $root :=
        if (request:get-header("nginx-request-uri")) then (
            ""
            (: replace(request:get-header("nginx-request-uri"), "^(\w+://[^/]+).*$", "$1") :)
        ) else
            request:get-context-path() || substring-after($config:app-root, "/db")
    return
    element { node-name($node) } {
        $node/@*,
        attribute data-app { $root },
        let $content := templates:process($node/*, $model)
        let $title :=
            (: use static override when defined in page template :)
            if ($content//div[@id="static-title"]) then
                string-join(
                    ($content//div[@id="static-title"]/string(), "Office of the Historian")[. ne ""],
                    " - "
                )
            else
                pages:generate-title($model, $content)

        let $log := console:log("pages:app-root -> title: " || $title)
        return (
            <head>
                { $content/self::head/* }
                <title>{$title}</title>
            </head>,
            $content/self::body
        )
    }
};

(: lets a template provide a full path to a document, as used in pages/departmenthistory/buildings.
 : TODO: extend with an $odd parameter. :)
declare function pages:render-document($node, $model, $document-path, $section-id) {
    let $doc := doc($document-path)
    let $section := $doc/id($section-id)
    return
        pages:process-content($model?odd, $section)
};

declare
    %templates:wrap
function pages:document-link($node, $model) {
    element a {
        $node/@*,
        root($model?data)//tei:title[@type = 'complete']/string()
    }
};

(: Page title for education/module.html
TODO: Create a page title module :)
declare
    %templates:wrap
function pages:education-module-title ($node, $model) {
    element a {
        $node/@*,
        concat(root($model?data)//tei:title[@type = 'short']/string(), ' - Curriculum Modules - Education Resources')
    }
};


(: Page title for countries/archives/article
TODO Create a page title module or adapt and move function to modules/countries-html.xqm:)
declare
    %templates:wrap
function pages:archive-title ($node, $model) {
    element a {
        $node/@*,
        concat(root($model?data)//tei:title[@type = 'short']/string(), ' - Archives - Countries')
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

(: Page title for about/hac/*
TODO Refactor with functions pages:faq-title() & pages:hac-title() and create a page title module :)
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

(: Page title for about/hac/*
TODO Refactor with functions pages:faq-title() & pages:hac-title() and create a page title module :)
declare
    %templates:wrap
function pages:conference-subpage-title($node, $model) {
    element a {
        $node/@*,
        concat($model?data/tei:head[1]/string(), ' - ', root($model?data)//tei:title[@type = 'short']/string(), ' - Conferences')
    }
};

(: Page title for about/hac/*
TODO Refactor with function pages:faq-title() & pages:conference-title() and create a page title module :)
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
TODO Refactor with function pages:hac-title() & pages:conference-title() and create a page title module:)
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
