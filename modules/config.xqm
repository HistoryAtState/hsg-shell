xquery version "3.1";

(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)
module namespace config="http://history.state.gov/ns/site/hsg/config";
import module namespace console="http://exist-db.org/xquery/console";

import module namespace pm-frus='http://www.tei-c.org/tei-simple/models/frus.odd/web/module' at "../resources/odd/compiled/frus-web-module.xql";

declare namespace templates="http://exist-db.org/xquery/templates";

declare namespace expath="http://expath.org/ns/pkg";
declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(:
    Determine the application root collection from the current module load path.
:)
declare variable $config:app-root :=
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    return
        substring-before($modulePath, "/modules")
;

declare variable $config:data-root := $config:app-root || "/data";

declare variable $config:repo-descriptor := doc(concat($config:app-root, "/repo.xml"))/repo:meta;

declare variable $config:expath-descriptor := doc(concat($config:app-root, "/expath-pkg.xml"))/expath:package;

declare variable $config:odd-root := $config:app-root || "/resources/odd";

declare variable $config:odd-source := $config:odd-root || "/source";

declare variable $config:odd-compiled := $config:odd-root || "/compiled";

declare variable $config:odd := "frus.odd";

(: Default transformation function: calls tei simple pm using frus.odd :)
declare variable $config:odd-transform-default := function($xml, $parameters) {
    pm-frus:transform($xml, $parameters)
};

declare variable $config:module-config := doc($config:odd-source || "/configuration.xml")/*;

declare variable $config:FRUS_VOLUMES_COL := "/db/apps/frus/volumes";

declare variable $config:FRUS_METADATA_COL := "/db/apps/frus/bibliography";

declare variable $config:FRUS_METADATA := collection($config:FRUS_METADATA_COL);

declare variable $config:FRUS_CODE_TABLES_COL := "/db/apps/frus/code-tables";

declare variable $config:x-forwarded-host        := request:get-header("X-Forwarded-Host");
declare variable $config:x-forwarded-proto       := request:get-header("X-Forwarded-Proto");
declare variable $config:is-proxied              := not(empty($config:x-forwarded-host));
declare variable $config:exist-path-to-root      := request:get-context-path() || substring-after($config:app-root, "/db");
declare variable $config:proxy-url :=
    if ($config:is-proxied)
    then ($config:x-forwarded-proto || "://" || substring-before($config:x-forwarded-host,":"))
    else ($config:exist-path-to-root);

declare variable $config:S3_CACHE_COL := "/db/apps/s3/cache/";

declare variable $config:S3_BUCKET := "static.history.state.gov.v2";

declare variable $config:HSG_S3_CACHE_COL := $config:S3_CACHE_COL || "/" || $config:S3_BUCKET || "/";
declare variable $config:S3_DOMAIN := "static.history.state.gov";
declare variable $config:S3_URL := 'https://' || $config:S3_DOMAIN;

declare variable $config:DOMAIN_1861 := 'https://hsg-dev-backend1.hsg';
declare variable $config:DOMAIN_1991 := 'https://hsg-dev-backend2.hsg';

declare variable $config:ARCHIVES_COL := "/db/apps/wwdai";
declare variable $config:ARCHIVES_ARTICLES_COL := $config:ARCHIVES_COL || "/articles";
declare variable $config:BUILDINGS_COL := "/db/apps/other-publications/buildings";
declare variable $config:CAROUSEL_COL := "/db/apps/carousel";
declare variable $config:CONFERENCES_COL := "/db/apps/conferences";
declare variable $config:CONFERENCES_ARTICLES_COL := $config:CONFERENCES_COL || "/data";
declare variable $config:COUNTRIES_COL := "/db/apps/rdcr";
declare variable $config:COUNTRIES_ARTICLES_COL := "/db/apps/rdcr/articles";
declare variable $config:COUNTRIES_ISSUES_COL := "/db/apps/rdcr/issues";
declare variable $config:SHORT_HISTORY_COL := "/db/apps/other-publications/short-history";
declare variable $config:ADMINISTRATIVE_TIMELINE_COL := "/db/apps/administrative-timeline/timeline";
declare variable $config:SECRETARY_BIOS_COL := "/db/apps/other-publications/secretary-bios";
declare variable $config:MILESTONES_COL := "/db/apps/milestones/chapters";
declare variable $config:EDUCATION_COL := "/db/apps/other-publications/education/introductions";
declare variable $config:FAQ_COL := "/db/apps/other-publications/faq";
declare variable $config:VIETNAM_GUIDE_COL := "/db/apps/other-publications/vietnam-guide";
declare variable $config:VIEWS_FROM_EMBASSY_COL := "/db/apps/other-publications/views-from-the-embassy";
declare variable $config:VISITS_COL := "/db/apps/visits/data";
declare variable $config:TRAVELS_COL := "/db/apps/travels";
declare variable $config:HAC_COL := "/db/apps/hac";
declare variable $config:HIST_DOCS :=  "/db/apps/hsg-shell/pages/historicaldocuments";
declare variable $config:TWITTER_COL := "/db/apps/twitter/data/HistoryAtState";
declare variable $config:TUMBLR_COL := "/db/apps/tumblr/data/HistoryAtState";

declare variable $config:FRUS_HISTORY_COL := '/db/apps/frus-history';
declare variable $config:FRUS_HISTORY_ARTICLES_COL := $config:FRUS_HISTORY_COL || '/articles';
declare variable $config:FRUS_HISTORY_DOCUMENTS_COL := $config:FRUS_HISTORY_COL || '/documents';
declare variable $config:FRUS_HISTORY_EVENTS_COL := $config:FRUS_HISTORY_COL || '/events';
declare variable $config:FRUS_HISTORY_MONOGRAPH_COL := $config:FRUS_HISTORY_COL || '/monograph';

declare variable $config:IGNORED_DIVS := ("toc");

declare variable $config:PUBLICATIONS :=
    map {
        "frus": map {
            "collection": $config:FRUS_VOLUMES_COL,
            "select-document": function($document-id) { doc($config:FRUS_VOLUMES_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { 
                let $node := doc($config:FRUS_VOLUMES_COL || '/' || $document-id || '.xml')/id($section-id) 
                return
                    (: most requests will be for divs :)
                    if ($node instance of element(tei:div)) then
                        $node
                    (: catch requests for TEI/@xml:id :)
                    else if ($node instance of element(tei:TEI)) then
                        let $requested-url := request:get-parameter("requested-url", ())
                        let $new-url := replace($requested-url, "/" || $document-id || "$", "")
                        return
                            response:redirect-to(xs:anyURI($new-url))
                    (: catch requests for footnotes :)
                    else if ($node instance of element(tei:note)) then
                        let $parent-doc := $node/ancestor::tei:div[1]
                        let $requested-url := request:get-parameter("requested-url", ())
                        let $new-url := replace($requested-url, $section-id || "$", $parent-doc/@xml:id || "#fn:" || util:node-id($node))
                        return
                            response:redirect-to(xs:anyURI($new-url))
                    (: catch requests for index cross-references :)
                    else if ($node instance of element(tei:item)) then
                        let $parent-doc := $node/ancestor::tei:div[1]
                        let $requested-url := request:get-parameter("requested-url", ())
                        let $new-url := replace($requested-url, $section-id || "$", $parent-doc/@xml:id || "#" || $node/@xml:id)
                        return
                            response:redirect-to(xs:anyURI($new-url))
                    else
                        $node
            },
            "html-href": function($document-id, $section-id) { "$app/historicaldocuments/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform":
                (: Called to transform content based on the odd using tei simple pm :)
                function($xml, $parameters) { pm-frus:transform($xml, map:merge(($parameters, map:entry("document-list", true())))) },
            "title": "Historical Documents",
            "base-path": function($document-id, $section-id) { "frus/" || $document-id }
        },
        "buildings": map {
            "collection": $config:BUILDINGS_COL,
            "select-document": function($document-id) { doc($config:BUILDINGS_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:BUILDINGS_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/departmenthistory/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "title": "Buildings - Department History",
            "base-path": function($document-id, $section-id) { "buildings" }
        },
        "historicaldocuments": map {
            "title": "Historical Documents"
        },
        "about-frus": map {
            "title": "About the Foreign Relations Series - Historical Documents"
        },
        "conferences": map {
            "collection": $config:CONFERENCES_ARTICLES_COL,
            "select-document": function($document-id) { doc($config:CONFERENCES_ARTICLES_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:CONFERENCES_ARTICLES_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/conferences/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml,  map:merge(($parameters, map:entry("document-list", true())))) },
            "title": "Conferences",
            "base-path": function($document-id, $section-id) { "conferences" }
        },
        "status-of-the-series": map {
            "title": "Foreign Relations of the United States: Status of the Series - Historical Documents"
        },
        "ebooks": map {
            "title": "Ebooks - Historical Documents"
        },
        "citing-frus": map {
            "title": "Citing the Foreign Relations series - Historical Documents"
        },
        "other-electronic-resources": map {
            "title": "Electronic Resources for U.S. Foreign Relations - Historical Documents"
        },
        "countries": map {
            "collection": $config:COUNTRIES_ARTICLES_COL,
            "select-document": function($document-id) { doc($config:COUNTRIES_ARTICLES_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:COUNTRIES_ARTICLES_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/countries/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "title": "Countries",
            "base-path": function($document-id, $section-id) { "countries" }
        },
        "countries-issues": map {
            "collection": $config:COUNTRIES_ISSUES_COL,
            "select-document": function($document-id) { doc($config:COUNTRIES_ISSUES_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:COUNTRIES_ISSUES_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/countries/issues/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "title": "Issues Relevant to U.S. Foreign Policy",
            "base-path": function($document-id, $section-id) { "countries" }
        },
        "archives": map {
            "collection": $config:ARCHIVES_ARTICLES_COL,
            "select-document": function($document-id) { doc($config:ARCHIVES_ARTICLES_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:ARCHIVES_ARTICLES_COL || '/' || $document-id || '.xml')//tei:body },
            "html-href": function($document-id, $section-id) { "$app/countries/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "title": "World Wide Diplomatic Archives Indes"
        },
        "articles": map {
            "collection": $config:FRUS_HISTORY_ARTICLES_COL,
            "select-document": function($document-id) { doc($config:FRUS_HISTORY_ARTICLES_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:FRUS_HISTORY_ARTICLES_COL || '/' || $document-id || '.xml')//tei:body },
            "html-href": function($document-id, $section-id) { "$app/frus-history/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "base-path": function($document-id, $section-id) { "frus150" }
        },
        "about": map {
            "title": "About Us"
        },
        "departmenthistory": map {
            "title": "Department History"
        },
        "diplomatic-couriers": map {
            "title": "U.S. Diplomatic Couriers - Department History"
        },
        "people": map {
            "collection": $config:SECRETARY_BIOS_COL,
            "select-document": function($document-id) { doc($config:SECRETARY_BIOS_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:SECRETARY_BIOS_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/departmenthistory/people/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform":
                (: Called to transform content based on the odd using tei simple pm :)
                function($xml, $parameters) { pm-frus:transform($xml, map:merge(($parameters, map:entry("document-list", true())))) },
            "title": "People - Department History",
            "base-path": function($document-id, $section-id) { "secretaries" }
        },
        "secretaries": map {
            "title": "Biographies of the Secretaries of State - Department History"
        },
        "principals-chiefs": map {
            "title": "Principal Officers and Chiefs of Mission - Department History"
        },
        "people-by-alpha": map {
            "title": "Principal Officers and Chiefs of Mission Alphabetical Listing - Department History"
        },
        "people-by-year": map {
            "title": "Principal Officers and Chiefs of Mission Chronological Listing - Department History"
        },
        "people-by-role": map {
            "title": "Principal Officers and Chiefs of Mission Alphabetical Listing - Department History"
        },
        "tags": map {
            "title": "Tags"
        },
        "travels": map {
            "title": "Presidents and Secretaries of State Foreign Travels - Department History"
        },
        "travels-president": map {
            "title": "Travels of the President - Department History"
        },
        "travels-secretary": map {
            "title": "Travels of the Secretary of State - Department History"
        },
        "visits": map {
            "title": "Visits of Foreign Leaders and Heads of State - Department History"
        },
        "wwi": map {
            "title": "World War I - Department History"
        },
        "milestones": map {
            "collection": $config:MILESTONES_COL,
            "select-document": function($document-id) { doc($config:MILESTONES_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:MILESTONES_COL|| '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/milestones/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "title": "Milestones in the History of U.S. Foreign Relations",
            "base-path": function($document-id, $section-id) { "milestones" }
        },
        "short-history": map {
            "collection": $config:SHORT_HISTORY_COL,
            "select-document": function($document-id) { doc($config:SHORT_HISTORY_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:SHORT_HISTORY_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/departmenthistory/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml,  map:merge(($parameters, map:entry("document-list", true())))) },
            "title": "Short History - Department History",
            "base-path": function($document-id, $section-id) { "short-history" }
        },
        "timeline": map {
            "collection": $config:ADMINISTRATIVE_TIMELINE_COL,
            "select-document": function($document-id) { doc($config:ADMINISTRATIVE_TIMELINE_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:ADMINISTRATIVE_TIMELINE_COL || '/' || $document-id || '.xml')/id('chapter_' || $section-id) },
            "html-href": function($document-id, $section-id) { "$app/departmenthistory/" || string-join(($document-id, substring-after($section-id, 'chapter_')), '/') },
            "url-fragment": function($div) { if (starts-with($div/@xml:id, 'chapter_')) then substring-after($div/@xml:id, 'chapter_') else $div/@xml:id/string() },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml,  map:merge(($parameters, map:entry("document-list", true())))) },
            "title": "Administrative Timeline - Department History",
            "base-path": function($document-id, $section-id) { "timeline" }
        },
        "faq": map {
            "collection": $config:FAQ_COL,
            "select-document": function($document-id) { doc($config:FAQ_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:FAQ_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/about/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml,  map:merge(($parameters, map:entry("document-list", true())))) },
            "title": "FAQ - About Us"
        },
        "hac": map {
            "collection": $config:HAC_COL,
            "select-document": function($document-id) { doc($config:HAC_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:HAC_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/about/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml,  map:merge(($parameters, map:entry("document-list", true())))) },
            "title": "Historical Advisory Committee - About Us"
        },
        "education": map {
            "collection": $config:EDUCATION_COL,
            "select-document": function($document-id) { doc($config:EDUCATION_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:EDUCATION_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/education/modules/" || string-join(($document-id, $section-id), '#') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "title": "Education Resources"
        },
        "education-modules": map {
            "title": "Curriculum Modules - Education Resources"
        },
        "frus-history-monograph": map {
            "collection": $config:FRUS_HISTORY_MONOGRAPH_COL,
            "select-document": function($document-id) { doc($config:FRUS_HISTORY_MONOGRAPH_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { 
                let $target-section-id :=
                    (: catch xlink requests :)
                    if (starts-with($section-id, "range(")) then
                        substring-before(substring-after($section-id, "range("), ",")
                    else
                        $section-id
                let $node := doc($config:FRUS_HISTORY_MONOGRAPH_COL || '/' || $document-id || '.xml')/id($target-section-id)
                return
                    (: most requests will be for divs :)
                    if ($node instance of element(tei:div)) then
                        $node
                    (: catch requests for TEI/@xml:id :)
                    else if ($node instance of element(tei:TEI)) then
                        let $requested-url := request:get-parameter("requested-url", ())
                        let $new-url := replace($requested-url, "/" || $document-id || "$", "")
                        return
                            response:redirect-to(xs:anyURI($new-url))
                    (: catch requests for footnotes :)
                    else if ($node instance of element(tei:note)) then
                        let $parent-doc := $node/ancestor::tei:div[1]
                        let $requested-url := request:get-parameter("requested-url", ())
                        let $new-url := replace($requested-url, $section-id || "$", $parent-doc/@xml:id || "#fn:" || util:node-id($node))
                        return
                            response:redirect-to(xs:anyURI($new-url))
                    (: catch requests for index cross-references and anchors :)
                    else if ($node instance of element(tei:item) or $node instance of element(tei:anchor)) then
                        let $parent-doc := $node/ancestor::tei:div[1]
                        let $requested-url := request:get-parameter("requested-url", ())
                        let $new-url := replace($requested-url, $section-id, $parent-doc/@xml:id || "#" || $node/@xml:id, "q")
                        return
                            response:redirect-to(xs:anyURI($new-url))
                    else
                        $node
             },
            "html-href": function($document-id, $section-id) { "$app/historicaldocuments/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) {
                pm-frus:transform($xml, map:merge(($parameters, map:entry("document-list", true()))))
            },
            "title": "History of the Foreign Relations Series",
            "base-path": function($document-id, $section-id) { "frus-history" }
        },
        "vietnam-guide": map {
            "collection": $config:VIETNAM_GUIDE_COL,
            "select-document": function($document-id) { doc($config:VIETNAM_GUIDE_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:VIETNAM_GUIDE_COL || '/' || $document-id || '.xml') },
            "html-href": function($document-id, $section-id) { "$app/historicaldocuments/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "title": "Guide to Sources on Vietnam, 1969-1975"
        },
        "views-from-the-embassy": map {
            "collection": $config:VIEWS_FROM_EMBASSY_COL,
            "select-document": function($document-id) { doc($config:VIEWS_FROM_EMBASSY_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:VIEWS_FROM_EMBASSY_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/departmenthistory/wwi" },
            "title": "World War I and the Department - Department History"
        }
    };

declare variable $config:PUBLICATION-COLLECTIONS :=
    map {
        $config:FRUS_VOLUMES_COL: "frus",
        $config:FRUS_METADATA_COL: "frus",
        $config:BUILDINGS_COL: "buildings",
        $config:SHORT_HISTORY_COL: "short-history",
        $config:ADMINISTRATIVE_TIMELINE_COL: "timeline",
        $config:FAQ_COL: "faq",
        $config:HAC_COL: "hac",
        $config:EDUCATION_COL: "education",
        $config:FRUS_HISTORY_MONOGRAPH_COL: "frus-history-monograph",
        $config:CONFERENCES_ARTICLES_COL: "conferences",
        $config:MILESTONES_COL: "milestones",
        $config:FRUS_HISTORY_ARTICLES_COL: "articles",
        $config:SECRETARY_BIOS_COL: "people",
        $config:VIETNAM_GUIDE_COL: "vietnam-guide",
        $config:VIEWS_FROM_EMBASSY_COL: "views-from-the-embassy",
        $config:COUNTRIES_ARTICLES_COL: "countries",
        $config:COUNTRIES_ISSUES_COL: "countries-issues",
        $config:ARCHIVES_ARTICLES_COL: "archives"
    };

(:~
 : Resolve the given path using the current application context.
 : If the app resides in the file system,
 :)
declare function config:resolve($relPath as xs:string) {
    if (starts-with($config:app-root, "/db")) then
        doc(concat($config:app-root, "/", $relPath))
    else
        doc(concat("file://", $config:app-root, "/", $relPath))
};

(:~
 : Returns the repo.xml descriptor for the current application.
 :)
declare function config:repo-descriptor() as element(repo:meta) {
    $config:repo-descriptor
};

(:~
 : Returns the expath-pkg.xml descriptor for the current application.
 :)
declare function config:expath-descriptor() as element(expath:package) {
    $config:expath-descriptor
};

declare %templates:wrap function config:app-title($node as node(), $model as map(*)) as text() {
    $config:expath-descriptor/expath:title/text()
};

declare function config:app-meta($node as node(), $model as map(*)) as element()* {
    <meta xmlns="http://www.w3.org/1999/xhtml" name="description" content="{$config:repo-descriptor/repo:description/text()}"/>,
    for $author in $config:repo-descriptor/repo:author
    return
        <meta xmlns="http://www.w3.org/1999/xhtml" name="creator" content="{$author/text()}"/>
};

(:~
 : For debugging: generates a table showing all properties defined
 : in the application descriptors.
 :)
declare function config:app-info($node as node(), $model as map(*)) {
    let $expath := config:expath-descriptor()
    let $repo := config:repo-descriptor()
    return
        <table class="app-info">
            <tr>
                <td>app collection:</td>
                <td>{$config:app-root}</td>
            </tr>
            {
                for $attr in ($expath/@*, $expath/*, $repo/*)
                return
                    <tr>
                        <td>{node-name($attr)}:</td>
                        <td>{$attr/string()}</td>
                    </tr>
            }
            <tr>
                <td>Controller:</td>
                <td>{ request:get-attribute("$exist:controller") }</td>
            </tr>
        </table>
};
