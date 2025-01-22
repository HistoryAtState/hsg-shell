xquery version "3.1";

(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)
module namespace config="http://history.state.gov/ns/site/hsg/config";

import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";
import module namespace tu="http://history.state.gov/ns/site/hsg/tei-util" at "tei-util.xqm";
import module namespace frus-history = "http://history.state.gov/ns/site/hsg/frus-history-html" at "frus-history-html.xqm";

import module namespace pm-frus='http://www.tei-c.org/pm/models/frus/web/module' at "../transform/frus-web-module.xql";

declare namespace templates="http://exist-db.org/xquery/html-templating";

declare namespace expath="http://expath.org/ns/pkg";
declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace a="http://www.w3.org/2005/Atom";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

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

declare variable $config:default-odd := "frus.odd";

declare variable $config:odd := $config:default-odd;

declare variable $config:odd-root := $config:app-root || "/resources/odd";

declare variable $config:odd-source := $config:odd-root || "/source";

declare variable $config:odd-compiled := "/transform";

declare variable $config:output := "transform";

declare variable $config:output-root := $config:app-root || "/" || $config:output;

(: Default transformation function: calls tei simple pm using frus.odd :)
declare variable $config:odd-transform-default := function($xml, $parameters) {
    pm-frus:transform($xml, $parameters)
};

declare variable $config:module-config := doc($config:odd-source || "/configuration.xml")/*;

(:
 : The default to use for determining the amount of content to be shown
 : on a single page. Possible values: 'div' for showing entire divs (see
 : the parameters below for further configuration), or 'page' to browse
 : a document by actual pages determined by TEI pb elements.
 :)
declare variable $config:default-view := "div";

declare variable $config:FRUS_VOLUMES_COL := "/db/apps/frus/volumes";

(: TODO: Create post-install task for `toc:generate-frus-tocs()` to create this folder, if not available  :)
declare variable $config:FRUS_VOLUMES_TOC := "/db/apps/frus/frus-toc/";

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

declare variable $config:S3_BUCKET := "static.history.state.gov.v3";

declare variable $config:S3_DOMAIN := "static.history.state.gov";
declare variable $config:S3_URL := 'https://' || $config:S3_DOMAIN;

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
declare variable $config:NEWS_COL := "/db/apps/hsg-shell/tests/data/news";
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
            "document-last-modified": function($document-id) { 
                (
                    xmldb:last-modified($config:FRUS_VOLUMES_COL, $document-id || '.xml'),
                    (: for volumes that we do not have as TEI yet, fall back on volume metadata :)
                    xmldb:last-modified($config:FRUS_METADATA_COL, $document-id || '.xml')
                )[1]
            },
            "section-last-modified": function($document-id, $section-id) {
                (
                    xmldb:last-modified($config:FRUS_VOLUMES_COL, $document-id || '.xml'),
                    xmldb:last-modified($config:FRUS_METADATA_COL, $document-id || '.xml')
                )[1]
            },
            "document-created": function($document-id) { 
                (
                    xmldb:created($config:FRUS_VOLUMES_COL, $document-id || '.xml'),
                    (: for volumes that we do not have as TEI yet, fall back on volume metadata :)
                    xmldb:created($config:FRUS_METADATA_COL, $document-id || '.xml')
                )[1]
            },
            "section-created": function($document-id, $section-id) {
                (
                    xmldb:created($config:FRUS_VOLUMES_COL, $document-id || '.xml'),
                    xmldb:created($config:FRUS_METADATA_COL, $document-id || '.xml')
                )[1]
            },
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
                function($xml, $parameters) { pm-frus:transform($xml, map:merge(($parameters, map:entry("document-list", true())),  map{"duplicates": "use-last"})) },
            "title": "Historical Documents",
            "next":     tu:get-next#1,
            "previous": tu:get-previous#1,
            "base-path": function($document-id, $section-id) { "frus/" || $document-id },
            "open-graph": map{
                    "og:type": function($node as node()?, $model as map(*)?) {'document'}
                },
            "citation-meta": function($node as node()?, $model as map(*)?) as map(*) {
                    config:tei-citation-meta($node, $model)
                },
            "breadcrumb-title": 
              function($parameters as map(*)) as xs:string? {
                config:tei-full-breadcrumb-title(
                  $parameters?publication-id,
                  $parameters?document-id,
                  $parameters?section-id,
                  $parameters?truncate
                )
              }        
        },
        "frus-list": map{
            "collection": $config:FRUS_METADATA_COL
        },
        "frus-administration": map {
          "select-section": function($administration-id) {
              doc($config:FRUS_CODE_TABLES_COL || '/administration-code-table.xml')//item[value = $administration-id]
            },
          "breadcrumb-title": function($parameters as map(*)) as xs:string? {
              let $admin := $config:PUBLICATIONS?frus-administration?select-section($parameters?administration-id)
              return $admin/label/string()
            }
        },
        "buildings": map {
            "collection": $config:BUILDINGS_COL,
            "document-last-modified": function($document-id) { xmldb:last-modified($config:BUILDINGS_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:BUILDINGS_COL, $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:BUILDINGS_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:BUILDINGS_COL, $document-id || '.xml') },
            "select-document": function($document-id) { doc($config:BUILDINGS_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:BUILDINGS_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/departmenthistory/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "title": "Buildings - Department History",
            "next":     tu:get-next#1,
            "previous": tu:get-previous#1,
            "base-path": function($document-id, $section-id) { "buildings" },
            "breadcrumb-title": function($parameters as map(*)) {
                config:tei-full-breadcrumb-title-from-section('buildings', 'buildings', $parameters?section-id, false())
              }
        },
        "historicaldocuments": map {
            "title": "Historical Documents"
        },
        "about-frus": map {
            "title": "About the Foreign Relations Series - Historical Documents"
        },
        "conferences": map {
            "collection": $config:CONFERENCES_ARTICLES_COL,
            "document-last-modified": function($document-id) { xmldb:last-modified($config:CONFERENCES_ARTICLES_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:CONFERENCES_ARTICLES_COL, $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:CONFERENCES_ARTICLES_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:CONFERENCES_ARTICLES_COL, $document-id || '.xml') },
            "select-document": function($document-id) { doc($config:CONFERENCES_ARTICLES_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:CONFERENCES_ARTICLES_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/conferences/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml,  map:merge(($parameters, map:entry("document-list", true())), map{"duplicates": "use-last"})) },
            "title": "Conferences",
            "next":     tu:get-next#1,
            "previous": tu:get-previous#1,
            "base-path": function($document-id, $section-id) { "conferences" },
            "breadcrumb-title": function($parameters as map(*)) as xs:string? {
                config:tei-full-breadcrumb-title(
                  $parameters?publication-id,
                  $parameters?document-id,
                  $parameters?section-id,
                  $parameters?truncate
                )
              }
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
            "document-last-modified": function($document-id) { xmldb:last-modified($config:COUNTRIES_ARTICLES_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:COUNTRIES_ARTICLES_COL, $document-id || '.xml') },
            "select-document": function($document-id) { doc($config:COUNTRIES_ARTICLES_COL || '/' || $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:COUNTRIES_ARTICLES_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:COUNTRIES_ARTICLES_COL, $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:COUNTRIES_ARTICLES_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/countries/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "title": "Countries",
            "base-path": function($document-id, $section-id) { "countries" },
            "breadcrumb-title": function($parameters as map(*)) as xs:string? {
                config:tei-full-breadcrumb-title(
                  $parameters?publication-id,
                  $parameters?document-id,
                  $parameters?section-id,
                  $parameters?truncate
                )
              }
        },
        "countries-issues": map {
            "collection": $config:COUNTRIES_ISSUES_COL,
            "document-last-modified": function($document-id) { xmldb:last-modified($config:COUNTRIES_ISSUES_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:COUNTRIES_ISSUES_COL, $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:COUNTRIES_ISSUES_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:COUNTRIES_ISSUES_COL, $document-id || '.xml') },
            "select-document": function($document-id) { doc($config:COUNTRIES_ISSUES_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:COUNTRIES_ISSUES_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/countries/issues/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "title": "Issues Relevant to U.S. Foreign Policy",
            "base-path": function($document-id, $section-id) { "countries" },
            "breadcrumb-title": function($parameters as map(*)) as xs:string? {
                config:tei-full-breadcrumb-title(
                  $parameters?publication-id,
                  $parameters?document-id,
                  $parameters?section-id,
                  $parameters?truncate
                )
              }
        },
        "archives": map {
            "collection": $config:ARCHIVES_ARTICLES_COL,
            "document-last-modified": function($document-id) { xmldb:last-modified($config:ARCHIVES_ARTICLES_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:ARCHIVES_ARTICLES_COL, $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:ARCHIVES_ARTICLES_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:ARCHIVES_ARTICLES_COL, $document-id || '.xml') },
            "select-document": function($document-id) { doc($config:ARCHIVES_ARTICLES_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:ARCHIVES_ARTICLES_COL || '/' || $document-id || '.xml')//tei:body },
            "html-href": function($document-id, $section-id) { "$app/countries/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "title": "World Wide Diplomatic Archives Index",
            "breadcrumb-title": function($parameters as map(*)) as xs:string? {
                config:tei-full-breadcrumb-title(
                  $parameters?publication-id,
                  $parameters?document-id,
                  $parameters?section-id,
                  $parameters?truncate
                )
              }
        },
        "frus-history-articles": map {
            "collection": $config:FRUS_HISTORY_ARTICLES_COL,
            "document-last-modified": function($document-id) { xmldb:last-modified($config:FRUS_HISTORY_ARTICLES_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:FRUS_HISTORY_ARTICLES_COL, $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:FRUS_HISTORY_ARTICLES_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:FRUS_HISTORY_ARTICLES_COL, $document-id || '.xml') },
            "select-document": function($document-id) { doc($config:FRUS_HISTORY_ARTICLES_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:FRUS_HISTORY_ARTICLES_COL || '/' || $document-id || '.xml')/id($section-id) },
            "next": frus-history:get-next-article#1,
            "previous": frus-history:get-previous-article#1,
            "html-href": function($document-id, $section-id) { "$app/frus-history/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "base-path": function($document-id, $section-id) { "frus150" },
            "breadcrumb-title": 
              function($parameters as map(*)) as xs:string? {
                config:tei-short-breadcrumb-title($parameters?publication-id, $parameters?document-id)
              }
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
            "document-last-modified": function($document-id) { xmldb:last-modified($config:SECRETARY_BIOS_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:SECRETARY_BIOS_COL, $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:SECRETARY_BIOS_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:SECRETARY_BIOS_COL, $document-id || '.xml') },
            "select-document": function($document-id) { doc($config:SECRETARY_BIOS_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:SECRETARY_BIOS_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/departmenthistory/people/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform":
                (: Called to transform content based on the odd using tei simple pm :)
                function($xml, $parameters) { pm-frus:transform($xml, map:merge(($parameters, map:entry("document-list", true())),  map{"duplicates": "use-last"})) },
            "title": "People - Department History",
            "base-path": function($document-id, $section-id) { "secretaries" },
            "breadcrumb-title": function($parameters as map(*)) as xs:string? {
                let $role as element(org-mission)? := collection('/db/apps/pocom/missions-orgs')/org-mission[id eq $parameters?role-or-country-id]
                let $country as element(country)? := collection('/db/apps/gsh/data/countries-old')/country[id eq $parameters?role-or-country-id]
                let $person as element(person)? := collection('/db/apps/pocom/people')/person[id eq $parameters?person-id]
                return
                  if (exists($role)) then
                    $role/names/plural/string()
                  else if (exists($country)) then
                    $country/label/string()
                  else if (exists($person)) then
                    $person/persName/string-join((forename, surname, genName), ' ')
                  else ()
              }
        },
        "secretaries": map {
            "title": "Biographies of the Secretaries of State - Department History"
        },
        "principals-chiefs": map {
            "title": "Principal Officers and Chiefs of Mission - Department History"
        },
        "people-by-alpha": map {
            "title": "Principal Officers and Chiefs of Mission Alphabetical Listing - Department History",
            "breadcrumb-title": 
              function($parameters as map(*)) as xs:string? {
                  "Starting with " || upper-case($parameters?letter)
                }
        },
        "people-by-year": map {
            "title": "Principal Officers and Chiefs of Mission Chronological Listing - Department History",
            "breadcrumb-title": function($parameters as map(*)) as xs:string? {
                $parameters?year
              }
        },
        "people-by-role": map {
            "title": "Principal Officers and Chiefs of Mission Alphabetical Listing - Department History",
            "breadcrumb-title": function($parameters as map(*)) as xs:string? {
                collection('/db/apps/pocom/positions-principals')/principal-position[id eq $parameters?role-id]/names/plural/string()
              }
        },
        "tags": map {
            "title": "Tags",
            "breadcrumb-title": function($parameters as map(*)) as xs:string? {
                collection('/db/apps/tags/taxonomy')//*[id eq $parameters?tag-id]/label/string()
              }
        },
        "travels": map {
            "title": "Presidents and Secretaries of State Foreign Travels - Department History"
        },
        "travels-president": map {
            "title": "Travels of the President - Department History",
            "breadcrumb-title": function($parameters as map(*)) as xs:string?{
                config:visits-breadcrumb-title($parameters?person-or-country-id, $config:TRAVELS_COL||"/president-travels")
              }
        },
        "travels-secretary": map {
            "title": "Travels of the Secretary of State - Department History",
            "breadcrumb-title": function($parameters as map(*)) as xs:string?{
                config:visits-breadcrumb-title($parameters?person-or-country-id, $config:TRAVELS_COL||"/secretary-travels")
              }
        },
        "visits": map {
            "title": "Visits of Foreign Leaders and Heads of State - Department History",
            "breadcrumb-title": 
              function($parameters as map(*)) as xs:string? {
                let $key := $parameters?country-or-year
                let $country as element()? := collection('/db/apps/gsh/data/countries-old')//country[id eq $key]
                return if (exists($country)) then
                  $country/label/string()
                else (: $key is a year :)
                  $key
              }
        },
        "wwi": map {
            "title": "World War I - Department History"
        },
        "milestones": map {
            "collection": $config:MILESTONES_COL,
            "document-last-modified": function($document-id) { xmldb:last-modified($config:MILESTONES_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:MILESTONES_COL, $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:MILESTONES_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:MILESTONES_COL, $document-id || '.xml') },
            "select-document": function($document-id) { doc($config:MILESTONES_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:MILESTONES_COL|| '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/milestones/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "title": "Milestones in the History of U.S. Foreign Relations",
            "next":     tu:get-next#1,
            "previous": tu:get-previous#1,
            "base-path": function($document-id, $section-id) { "milestones" },
            "breadcrumb-title": function($parameters as map(*)) {
                if (exists($parameters?section-id)) then
                  $config:PUBLICATIONS?($parameters?publication-id)?select-section($parameters?document-id, $parameters?section-id)/tei:head[1]/string()
                else $parameters?document-id
              }
        },
        "short-history": map {
            "collection": $config:SHORT_HISTORY_COL,
            "document-last-modified": function($document-id) { xmldb:last-modified($config:SHORT_HISTORY_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:SHORT_HISTORY_COL, $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:SHORT_HISTORY_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:SHORT_HISTORY_COL, $document-id || '.xml') },
            "select-document": function($document-id) { doc($config:SHORT_HISTORY_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:SHORT_HISTORY_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/departmenthistory/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml,  map:merge(($parameters, map:entry("document-list", true())),  map{"duplicates": "use-last"})) },
            "title": "Short History - Department History",
            "next":     tu:get-next#1,
            "previous": tu:get-previous#1,
            "base-path": function($document-id, $section-id) { "short-history" },
            "breadcrumb-title": function($parameters as map(*)) as xs:string? {
                config:tei-full-breadcrumb-title(
                  $parameters?publication-id,
                  $parameters?document-id,
                  $parameters?section-id,
                  $parameters?truncate
                )
              }
        },
        "timeline": map {
            "collection": $config:ADMINISTRATIVE_TIMELINE_COL,
            "document-last-modified": function($document-id) { xmldb:last-modified($config:ADMINISTRATIVE_TIMELINE_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:ADMINISTRATIVE_TIMELINE_COL, $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:ADMINISTRATIVE_TIMELINE_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:ADMINISTRATIVE_TIMELINE_COL, $document-id || '.xml') },
            "select-document": function($document-id) { doc($config:ADMINISTRATIVE_TIMELINE_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:ADMINISTRATIVE_TIMELINE_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/departmenthistory/" || string-join(($document-id, substring-after($section-id, 'chapter_')), '/') },
            "url-fragment": function($div) { if (starts-with($div/@xml:id, 'chapter_')) then substring-after($div/@xml:id, 'chapter_') else $div/@xml:id/string() },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml,  map:merge(($parameters, map:entry("document-list", true())),  map{"duplicates": "use-last"})) },
            "title": "Administrative Timeline - Department History",
            "next":     tu:get-next#1,
            "previous": tu:get-previous#1,
            "base-path": function($document-id, $section-id) { "timeline" },
            "breadcrumb-title": function($parameters as map(*)) as xs:string? {
                config:tei-full-breadcrumb-title(
                  $parameters?publication-id,
                  $parameters?document-id,
                  $parameters?section-id,
                  $parameters?truncate
                )
              }
        },
        "faq": map {
            "collection": $config:FAQ_COL,
            "document-last-modified": function($document-id) { xmldb:last-modified($config:FAQ_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:FAQ_COL, $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:FAQ_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:FAQ_COL, $document-id || '.xml') },
            "select-document": function($document-id) { doc($config:FAQ_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:FAQ_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/about/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml,  map:merge(($parameters, map:entry("document-list", true())),  map{"duplicates": "use-last"})) },
            "title": "FAQ - About Us",
            "next":     tu:get-next#1,
            "previous": tu:get-previous#1,
            "breadcrumb-title": function($parameters as map(*)) as xs:string? {
                config:tei-full-breadcrumb-title(
                  $parameters?publication-id,
                  $parameters?document-id,
                  $parameters?section-id,
                  $parameters?truncate
                )
              }
        },
        "hac": map {
            "collection": $config:HAC_COL,
            "document-last-modified": function($document-id) { xmldb:last-modified($config:HAC_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:HAC_COL, $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:HAC_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:HAC_COL, $document-id || '.xml') },
            "select-document": function($document-id) { doc($config:HAC_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:HAC_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/about/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml,  map:merge(($parameters, map:entry("document-list", true())),  map{"duplicates": "use-last"})) },
            "title": "Historical Advisory Committee - About Us",
            "next":     tu:get-next#1,
            "previous": tu:get-previous#1,
            "breadcrumb-title": function($parameters as map(*)) as xs:string? {
                config:tei-full-breadcrumb-title(
                  $parameters?publication-id,
                  $parameters?document-id,
                  $parameters?section-id,
                  $parameters?truncate
                )
              }
        },
        "education": map {
            "collection": $config:EDUCATION_COL,
            "document-last-modified": function($document-id) { xmldb:last-modified($config:EDUCATION_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:EDUCATION_COL, $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:EDUCATION_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:EDUCATION_COL, $document-id || '.xml') },
            "select-document": function($document-id) { doc($config:EDUCATION_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:EDUCATION_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/education/modules/" || string-join(($document-id, $section-id), '#') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "title": "Education Resources",
            "breadcrumb-title": function($parameters as map(*)) as xs:string? {
                config:tei-full-breadcrumb-title(
                  $parameters?publication-id,
                  $parameters?document-id,
                  $parameters?section-id,
                  $parameters?truncate
                )
              }
        },
        "education-modules": map {
            "title": "Curriculum Modules - Education Resources"
        },
        "frus-history-monograph": map {
            "collection": $config:FRUS_HISTORY_MONOGRAPH_COL,
            "document-last-modified": function($document-id) { xmldb:last-modified($config:FRUS_HISTORY_MONOGRAPH_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:FRUS_HISTORY_MONOGRAPH_COL, $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:FRUS_HISTORY_MONOGRAPH_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:FRUS_HISTORY_MONOGRAPH_COL, $document-id || '.xml') },
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
                pm-frus:transform($xml, map:merge(($parameters, map:entry("document-list", true())),  map{"duplicates": "use-last"}))
            },
            "title": "History of the Foreign Relations Series",
            "next":     tu:get-next#1,
            "previous": tu:get-previous#1,
            "base-path": function($document-id, $section-id) { "frus-history" },
            "open-graph": map{
                    "og:type": function($node as node()?, $model as map(*)?) {'document'}
                },
            "citation-meta": function($node as node()?, $model as map(*)?) as map(*)* {
                    config:tei-citation-meta($node, $model)
                },
            "breadcrumb-title": function($parameters as map(*)) {
                config:tei-full-breadcrumb-title(
                  $parameters?publication-id,
                  $parameters?document-id,
                  $parameters?section-id,
                  $parameters?truncate
                )
              }
        },
        "frus-history-documents": map {
            "collection": $config:FRUS_HISTORY_DOCUMENTS_COL,
            "document-last-modified": function($document-id) { xmldb:last-modified($config:FRUS_HISTORY_DOCUMENTS_COL, $document-id || '.xml') },  
            "document-created": function($document-id) { xmldb:created($config:FRUS_HISTORY_DOCUMENTS_COL, $document-id || '.xml') },
            "next": frus-history:get-next-doc#1,
            "previous": frus-history:get-previous-doc#1,
            "select-document": function($document-id) { doc($config:FRUS_HISTORY_DOCUMENTS_COL || "/" || $document-id || ".xml") },
            "breadcrumb-title": function($parameters as map(*)) as xs:string? {
              config:tei-short-breadcrumb-title($parameters?publication-id, $parameters?document-id)
            }
        },
        "vietnam-guide": map {
            "collection": $config:VIETNAM_GUIDE_COL,
            "document-last-modified": function($document-id) { xmldb:last-modified($config:VIETNAM_GUIDE_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:VIETNAM_GUIDE_COL, $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:VIETNAM_GUIDE_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:VIETNAM_GUIDE_COL, $document-id || '.xml') },
            "select-document": function($document-id) { doc($config:VIETNAM_GUIDE_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:VIETNAM_GUIDE_COL || '/' || $document-id || '.xml') },
            "html-href": function($document-id, $section-id) { "$app/historicaldocuments/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "transform": function($xml, $parameters) { pm-frus:transform($xml, $parameters) },
            "title": "Guide to Sources on Vietnam, 1969-1975"
        },
        "views-from-the-embassy": map {
            "collection": $config:VIEWS_FROM_EMBASSY_COL,
            "document-last-modified": function($document-id) { xmldb:last-modified($config:VIEWS_FROM_EMBASSY_COL, $document-id || '.xml') },  
            "section-last-modified": function($document-id, $section-id) { xmldb:last-modified($config:VIEWS_FROM_EMBASSY_COL, $document-id || '.xml') },
            "document-created": function($document-id) { xmldb:created($config:VIEWS_FROM_EMBASSY_COL, $document-id || '.xml') },
            "section-created": function($document-id, $section-id) {xmldb:created($config:VIEWS_FROM_EMBASSY_COL, $document-id || '.xml') },
            "select-document": function($document-id) { doc($config:VIEWS_FROM_EMBASSY_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:VIEWS_FROM_EMBASSY_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/departmenthistory/wwi" },
            "title": "World War I and the Department - Department History"
        },
        "serial-set": map{
          "breadcrumb-title": function($parameters as map(*)) as xs:string* {
            let $subject as xs:string? := $parameters?subject
            let $region as xs:string? := $parameters?region
            return
              if (exists($subject)) then $subject
              else if (exists($region)) then $region
              else ()
          }
        },
        "news": map{
            "collection": $config:NEWS_COL,
            "select-document": function($document-id) { 
                collection($config:NEWS_COL)/*[.//a:id eq $document-id] => root()
            },
            "document-last-modified": function($document-id) {
                let $uri := collection($config:NEWS_COL)/*[.//a:id eq $document-id] => document-uri()
                let $col-name := replace($uri, '(.+)/.+', '$1')
                let $doc-name := replace($uri, '.+/(.+)', '$1')
                return xmldb:last-modified($col-name, $doc-name)
            },
            "document-created": function($document-id) { 
                let $uri := collection($config:NEWS_COL)/*[.//a:id eq $document-id] => document-uri()
                let $col-name := replace($uri, '(.+)/.+', '$1')
                let $doc-name := replace($uri, '.+/(.+)', '$1')
                return xmldb:created($col-name, $doc-name)
            },
            "breadcrumb-title": 
                function($parameters as map(*)) {
                    collection($config:NEWS_COL)/a:entry[a:id eq $parameters?document-id]/a:title/xhtml:div/node()
                }  
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
        $config:ARCHIVES_ARTICLES_COL: "archives",
        $config:NEWS_COL: "news"
    };

declare variable $config:OPEN_GRAPH_KEYS := ("og:type", "twitter:card", "twitter:site", "og:site_name", "og:title", "og:description", "og:image", "og:url", "citation");

declare variable $config:OPEN_GRAPH as map(xs:string, function(*)) := map{
    "twitter:card": function($node, $model) {
            <meta property='twitter:card' content='summary'/>
        },
    "twitter:site": function($node, $model) {
            <meta property='twitter:site' content='@HistoryAtState'/>
        },
    "og:site_name": function($node, $model) {
            <meta property='og:site_name' content='Office of the Historian'/>
        },
    "og:image": function($node, $model) {
            for $img in $model?data//tei:graphic
            return
                <meta property="og:image" content="https://static.history.state.gov/{$model?base-path}/{$img/@url}"/>,
                <meta property="og:image" content="https://static.history.state.gov/images/avatar_big.jpg"/>,
                <meta property="og:image:width" content="400"/>,
                <meta property="og:image:height" content="400"/>,
                <meta property="og:image:alt" content="Office of the Historian social media avatar"/>
        },
    "og:type": function($node, $model) {
            <meta property="og:type" content="{
                let $publication-id := $model?publication-id
                let $pub-type := $config:PUBLICATIONS?($publication-id)?open-graph?("og:type")
                return
                    ($pub-type ! .($node, $model), 'website')[1]
            }"/>
        },
    "og:title": function($node, $model) {
            <meta property="og:title" content="{pages:generate-short-title($node, $model)}"/>
        },
    "og:description": function($node, $model) {
            <meta property="og:description" content="Office of the Historian"/>
        },
    "og:url": function($node, $model) {
            <meta property="og:url" content="{$model?url}"/>
        },
    "citation": function ($node, $model) as element(meta)* {
            let $citation-meta as function(*)? := $config:PUBLICATIONS?($model?publication-id)?citation-meta
            let $cls as array(*) := array {
                if (exists($model?citation-meta)) then 
                    $model?citation-meta
                else if (exists($citation-meta)) then
                    $citation-meta($node, $model)
                else 
                    config:default-citation-meta($node, $model)
            }

            return config:cls-to-html($cls)
        }
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
    (:
    config:open-graph(
        $node, 
        map:merge(
            (
                map{
                    "open-graph-keys": $config:OPEN_GRAPH_KEYS,
                    "open-graph": $config:OPEN_GRAPH,
                    "url": request:get-url()
                },
                $model
            ),
            map{"duplicates": "use-last"}
        )
    ),
    :)
    for $author in $config:repo-descriptor/repo:author[fn:normalize-space(.) ne '']
    return
        <meta xmlns="http://www.w3.org/1999/xhtml" name="creator" content="{$author/text()}"/>
};

(:~
 : This function creates Open Graph metadata for page templates.
 : See https://github.com/HistoryAtState/hsg-project/wiki/social-media-cards.
 :)
declare function config:open-graph($node as node()?, $model as map(*)?) as element()* {
    for $key in $model?open-graph-keys 
    for $fn in $model?open-graph($key)
    return $fn($node, $model)
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

(:
 : Function for generating short titles from TEI content
 :)
declare function config:tei-short-breadcrumb-title($publication-id as xs:string?, $document-id as xs:string?) as xs:string? {
  let $article := $config:PUBLICATIONS?($publication-id)?select-document($document-id)
  return $article//tei:title[@type='short']/string()
};

(:
 : Function for generating full titles from TEI content
 :)
declare function config:tei-full-breadcrumb-title($publication-id as xs:string, $document-id as xs:string?, $section-id as xs:string?, $truncate as xs:boolean?) as xs:string? {
  if (exists($document-id)) then 
    if (exists($section-id)) then 
      (: Return the breadcrumb title for the section within the frus volume :)
      config:tei-full-breadcrumb-title-from-section($publication-id, $document-id, $section-id, $truncate)
    else (: not exists($section-id) :) config:tei-full-breadcrumb-title-from-document($publication-id, $document-id)
  else (: not exists($document-id) :) ()
};

declare function config:tei-full-breadcrumb-title-from-document($publication-id as xs:string, $document-id as xs:string) as xs:string? {
  (: Return the breadcrumb title for the frus volume :)
  let $doc := $config:PUBLICATIONS?($publication-id)?select-document($document-id)
  return ($doc//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'complete'])[1]/string()
};

declare function config:tei-full-breadcrumb-title-from-section($publication-id as xs:string?, $document-id as xs:string?, $section-id as xs:string?, $truncate as xs:boolean?) {
let $div := $config:PUBLICATIONS?($publication-id)?select-section($document-id, $section-id)
return 
  if ($div/@type eq 'document') then
    concat('Document ', $div/@n/string()) 
  else (:$div/@type ne 'document':) (
    if ($div instance of element(tei:pb)) then 
      concat(
        (
          if ($div/@type eq "facsimile") then 
            let $next-sibling := $div/following-sibling::element()[1]/self::tei:div/@n
            let $ancestor-div := $div/ancestor::tei:div[1]/@n
            let $parent-doc as attribute()? := ($next-sibling, $ancestor-div)[1]
            return "Document "[exists($parent-doc)] || ($parent-doc) || " Facsimile "
          else ()
        ), 
        'Page ', 
        $div/@n/string()
      )
    else (:$div not instance of element(tei:pb):) (
      if ($truncate) then
       let $words := tokenize($div/tei:head[1]/string-join((node() except tei:note) ! string()), '\s+')
       let $max-word-count := 8
       return
         if (count($words) gt $max-word-count) then
           concat(string-join(subsequence($words, 1, $max-word-count), ' '), '...')
         else
           $div/tei:head[1]/string-join((node() except tei:note) ! string())
      else
       $div/tei:head[1]/string-join((node() except tei:note) ! normalize-space(.), ' ') 
    )
  )
};

declare function config:visits-breadcrumb-title($id as xs:string, $collection as xs:string) as xs:string? {
  (
    (collection($collection)//trip[@who eq $id])[1]/name, 
    collection('/db/apps/gsh/data/territories')/territory[id eq $id]/short-form-name
  )[1]/string()
};

declare function config:tei-citation-meta($node as node()?, $model as map(*)?) {
    let $publication-id := $model?publication-id
    let $section-id := $model?section-id
    let $doc := $config:PUBLICATIONS?($publication-id)?select-document($model?document-id)
    let $section := $config:PUBLICATIONS?($publication-id)?select-section($model?document-id, $section-id)
    return if (exists($section-id)) then
        config:tei-section-citation-meta($node, $model, $doc, $section)
    else 
        config:tei-document-citation-meta($node, $model, $doc)
};

declare function config:tei-section-citation-meta($node as node()?, $model as map(*)?) as map(*) {
    let $publication-id := $model?publication-id
    let $section-id := $model?section-id
    let $doc := $config:PUBLICATIONS?($publication-id)?select-document($model?document-id)
    let $section := $config:PUBLICATIONS?($publication-id)?select-section($model?document-id, $section-id)
    return config:tei-section-citation-meta($node, $model, $doc, $section)
};

declare function config:tei-section-citation-meta($node as node()?, $model as map(*)?, $doc as document-node()?, $section as node()?) as map(*) {
    let $location := 
        if ($section/@type eq 'document') then
            'Document '||$section/@n
        else if ($section/self::tei:pb) then (
            $section/replace(@n, '\[?(.+?)\]?', '$1')
        )
        else (
            ($section//text()[normalize-space(.) ne ''])[1]/preceding::tei:pb[1]/replace(@n, '\[?(.+?)\]?', '$1') ||
            '-' ||
            ($section//text()[normalize-space(.) ne ''])[last()]/preceding::tei:pb[1]/replace(@n, '\[?(.+?)\]?', '$1')
        )
    let $citation_title := config:tei-full-breadcrumb-title($model?publication-id, $model?document-id, $model?section-id, false())
    let $shared-citation := config:tei-shared-citation-meta($node, $model, $doc)
    let $book_title := $doc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='volume']/string(.)
    return map:merge((
        $shared-citation,
        map { 'type': "chapter" },
        if (exists($citation_title)) then map{ 'title': $citation_title } else (),
        if (exists($book_title)) then map{'container-title': $book_title} else (),
        if (exists($location[. ne '-'])) then map{'page': $location} else ()
    ), map{'duplicates':'use-last'})
};

declare function config:tei-document-citation-meta($node as node()?, $model as map(*)?) as map(*) {
    let $publication-id := $model?publication-id
    let $doc := $config:PUBLICATIONS?($publication-id)?select-document($model?document-id)
    return config:tei-document-citation-meta($node, $model, $doc)
};

declare function config:tei-document-citation-meta($node as node()?, $model as map(*)?, $doc as document-node()?) as map(*) {
    let $citation_title :=
        config:tei-full-breadcrumb-title($model?publication-id, $model?document-id, $model?section-id, false())
    let $shared-citation := config:tei-shared-citation-meta($node, $model, $doc)
    return map:merge((
        $shared-citation,
        map { 'type': "book" },
        if (exists($citation_title)) then map{ 'title': $citation_title} else ()
    ), map{'duplicates': 'use-last'})
};

declare function config:tei-shared-citation-meta($node as node()?, $model as map(*)?, $doc as document-node()?) as map(*) {
    let $doc := $config:PUBLICATIONS?($model?publication-id)?select-document($model?document-id)

    let $fileDesc := $doc/tei:TEI/tei:teiHeader/tei:fileDesc
    let $editors :=
        for $editor in $fileDesc/tei:titleStmt/tei:editor[@role eq 'primary']
        let $name-parts := tokenize($editor, '\s')
        return map{
            'family': $name-parts[last()],
            'given': string-join($name-parts[position() ne last()], ' ')
        }

    let $series_title := $fileDesc/tei:titleStmt/tei:title[@type='series']/string()
    let $series_number := $fileDesc/tei:titleStmt/tei:title[@type='sub-series']/string()
    let $volume := $fileDesc/tei:titleStmt/tei:title[@type='volume-number']/string()

    let $publisher := $fileDesc/tei:publicationStmt/tei:publisher/string()
    let $issued := $fileDesc/tei:publicationStmt/tei:date[@type eq 'publication-date']/string()
    let $isbn := $fileDesc/tei:publicationStmt/tei:idno[@type eq 'isbn-13']/string()

    return map:merge((
        config:default-citation-meta($node, $model),
        if (exists($editors)) then map{'editor': array { $editors }} else (),
        if (exists($series_title)) then map{'collection-title': $series_title} else (),
        if (exists($series_number)) then map{'collection-number': $series_number} else (),
        if (exists($volume)) then map{'volume':$volume} else (),
        if (exists($publisher)) then map{'publisher': $publisher} else (),
        if (exists($issued)) then map{'issued': map{'raw': $issued} } else (),
        if (exists($isbn)) then map { 'ISBN': $isbn } else ()
    ), map {'duplicates': 'use-last'})
        
};

declare function config:default-citation-meta($node as node()?, $model as map(*)) as map(*)? {
    let $accessed := current-date()
    let $url := (
        $model?url,
        try {request:get-url()}
        catch err:XPDY0002 { 'test-url' } (: Some contexts e.g. xquery testing have no request context :)
    )[1]
    let $local-uri := (
        $model?local-uri,
        try {substring-after($url, $pages:app-root)}
        catch err:XPDY0002 { 'test-path' } (: Some contexts e.g. xquery testing have no request context :)
    )[1]
    return map:merge((
        map{ 'id':  $local-uri },
        map{ 'type':    'webpage'},
        map{ 'title': pages:generate-short-title($node, $model)},
        map{ 'collection-title': "Office of the Historian"},
        map{ 'accessed':    
            map{
                'date-parts':   array {
                    array{
                        year-from-date($accessed),
                        month-from-date($accessed),
                        day-from-date($accessed)
                    }
                }
            }
        },
        map{ 'URL': $url }
    ), map{'duplicates': 'use-last'})
};

declare %templates:wrap function config:csl-json($node as node(), $model as map(*)) as xs:string? {
    if (exists($model?citation-meta)) then 
        serialize(array { $model?citation-meta }, map{'method':'json'}) => normalize-space()
    else
        serialize(array { config:default-citation-meta($node, $model) }, map{'method':'json'}) => normalize-space()
};

declare variable $config:cls-to-zotero as map(xs:string, function(*)) := map {
    "ISBN":
        function($value) as element(meta)*{
            <meta name="citation_isbn" content="{$value}"/>
        },
    "volume":
        function($value) as element(meta)*{
            <meta name="citation_volume" content="{$value}"/>
        },
    "type":
        function($value) as element(meta)*{
            let $type-mapping := map{
                "graphic": "artwork",
                "song": "audioRecording",
                "bill": "bill",
                "post-weblog": "blogPost",
                "book": "book",
                "chapter": "bookSection",
                "legal_case": "case",
                "paper-conference": "conferencePaper",
                "entry-dictionary": "dictionaryEntry",
                "document": "document",
                "entry-encyclopedia": "encyclopediaArticle",
                "post": "forumPost",
                "interview": "interview",
                "article-journal": "journalArticle",
                "personal_communication": "letter",
                "article-magazine": "magazineArticle",
                "manuscript": "manuscript",
                "map": "map",
                "article-newspaper": "newspaperArticle",
                "patent": "patent",
                "article": "preprint",
                "speech": "presentation",
                "report": "report",
                "legislation": "statute",
                "thesis": "thesis",
                "broadcast": "tvBroadcast",
                "motion_picture": "videoRecording",
                "webpage": "webpage"
            }
            for $type in $type-mapping?($value)
            return <meta name="DC.type" content="{$type}"/>
        },
    "editor":
        function($editors) as element(meta)*{
            (:eg "editor": [
        			{
        				"family": "Lawler",
        				"given": "Daniel J."
        			},
        			{
        				"family": "Mahan",
        				"given": "Erin R."
        			}
        		]
        		:)
            for $editor in array:flatten($editors)
            return <meta name="citation_editor" content="{config:cls-name($editor)}"/>
        },
    "publisher-place":
        function($value) as element(meta)*{
            <meta name="place" content="{$value}"/>
        },
    "publisher":
        function($value) as element(meta)*{
            <meta name="citation_publisher" content="{$value}"/>
        },
    "container-title":
        function($value) as element(meta)*{
            <meta name="citation_book_title" content="{$value}"/>
        },
    "title":
        function($value) as element(meta)*{
            <meta name="citation_title" content="{$value}"/>
        },
    "collection-number":
        function($value) as element(meta)*{
            <meta name="citation_series_number" content="{$value}"/>
        },
    "page":
        function($value) as element(meta)*{
            if (contains($value, '-')) then (
                (: capture as page range :)
                <meta name="citation_firstpage" content="{substring-before($value, '-')}"/>,
                <meta name="citation_lastpage" content="{substring-after($value, '-')}"/>
            )
            else
                (: capture as a single page/location reference :)
                <meta name="citation_firstpage" content="{$value}"/>
        },
    "issued":
        function($value) as element(meta)*{
            <meta name="citation_date" content="{config:cls-date($value)}"/>
        },
    "URL":
        function($value) as element(meta)*{
            <meta name="citation_public_url" content="{$value}"/>
        },
    "accessed":
        function($value) as element(meta)*{
            <meta name="accessDate" content="{config:cls-date($value)}"/>
        },
    "collection-title":
        function($value) as element(meta)*{
            <meta name="citation_series_title" content="{$value}"/>
        }
};

declare function config:cls-name($name as map(*)) {
    string-join(($name?given, $name?family), ' ')
};

declare function config:cls-date($date as map(*)) {
    if ($date?raw castable as xs:date or matches($date?raw, '\d{4}(-\d{2}(-\d{2})?)?')) then
        $date?raw
    else if (array:size($date?date-parts) eq 1) then
        config:cls-date-parts($date?date-parts?1)
    else ()
};

declare function config:cls-date-parts($date as array(*)) {
    let $d-seq := array:flatten($date)
    let $year  := $d-seq[1]
    let $month := $d-seq[2] ! format-number(., '00')
    let $day   := $d-seq[3] ! format-number(., '00')
    return string-join(($year, $month, $day), '-')
};

declare function config:cls-to-html($json as array(map(*))) as element(meta)* {
    map:for-each($json?1, function ($key, $value) {
        if (map:contains($config:cls-to-zotero, $key)) then
            $config:cls-to-zotero?($key)($value)
        else ()
    })
};