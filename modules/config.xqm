xquery version "3.1";

(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)
module namespace config="http://history.state.gov/ns/site/hsg/config";
import module namespace console="http://exist-db.org/xquery/console";

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

declare variable $config:module-config := doc($config:odd-source || "/configuration.xml")/*;

declare variable $config:FRUS_VOLUMES_COL := "/db/apps/frus/volumes";

declare variable $config:FRUS_METADATA_COL := "/db/apps/frus/bibliography/";

declare variable $config:FRUS_CODE_TABLES_COL := "/db/apps/frus/code-tables/";

declare variable $config:S3_CACHE_COL := "/db/apps/s3/cache/";

declare variable $config:S3_BUCKET := "static.history.state.gov";

declare variable $config:HSG_S3_CACHE_COL := $config:S3_CACHE_COL || "/" || $config:S3_BUCKET || "/";

declare variable $config:S3_DOMAIN := $config:S3_BUCKET || ".s3.amazonaws.com";

declare variable $config:BUILDINGS_COL := "/db/apps/other-publications/buildings";
declare variable $config:COUNTRIES_COL := "/db/apps/rdcr";
declare variable $config:COUNTRIES_ARTICLES_COL := "/db/apps/rdcr/articles";
declare variable $config:SHORT_HISTORY_COL := "/db/apps/other-publications/short-history";
declare variable $config:MILESTONES_COL := "/db/apps/milestones/chapters";
declare variable $config:EDUCATION_COL := "/db/apps/other-publications/education/introductions";
declare variable $config:FAQ_COL := "/db/apps/other-publications/faq";
declare variable $config:HAC_COL := "/db/apps/hac";
declare variable $config:HIST_DOCS :=  "/db/apps/hsg-shell/pages/historicaldocuments";

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
            "select-section": function($document-id, $section-id) { doc($config:FRUS_VOLUMES_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/historicaldocuments/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "title": "Historical Documents",
            "base-path": function($document-id, $section-id) { "frus/" || $document-id }
        },
        "buildings": map {
            "collection": $config:BUILDINGS_COL,
            "select-document": function($document-id) { doc($config:BUILDINGS_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:BUILDINGS_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/departmenthistory/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "title": "Buildings - Department History",
            "base-path": function($document-id, $section-id) { "buildings" }
        },
        "historicaldocuments": map {
            "title": "Historical Documents"
        },
        "about-frus": map {
            "title": "About the Foreign Relations Series - Historical Documents"
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
            "odd": "departmenthistory.odd",
            "title": "Countries",
            "base-path": function($document-id, $section-id) { "countries" }
        },
        "departmenthistory": map {
            "title": "Department History"
        },
        "people": map {
            "title": "People - Department History"
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
        "travels": map {
            "title": "Presidents and Secretaries of State Foreign Travels - Department History"
        },
        "travels-president": map {
            "title": "Travels of the President - Department History"
        },
        "travels-secretary": map {
            "title": "Travels of the Secretary of State - Department History"
        },
        "milestones": map {
            "collection": $config:MILESTONES_COL,
            "select-document": function($document-id) { doc($config:MILESTONES_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:MILESTONES_COL|| '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/milestones/" || string-join(($document-id, $section-id), '/') },
            "odd": "departmenthistory.odd",
            "title": "Milestones in the History of U.S. Foreign Relations",
            "base-path": function($document-id, $section-id) { "milestones" }
        },
        "short-history": map {
            "collection": $config:SHORT_HISTORY_COL,
            "select-document": function($document-id) { doc($config:SHORT_HISTORY_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:SHORT_HISTORY_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/departmenthistory/" || string-join(($document-id, $section-id), '/') },
            "odd": "departmenthistory.odd",
            "title": "Short History - Department History",
            "base-path": function($document-id, $section-id) { "short-history" }
        },
        "faq": map {
            "collection": $config:FAQ_COL,
            "select-document": function($document-id) { doc($config:FAQ_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:FAQ_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/about/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "title": "FAQ - About Us"
},
        "hac": map {
            "collection": $config:HAC_COL,
            "select-document": function($document-id) { doc($config:HAC_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:HAC_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/about/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "title": "Historical Advisory Committee - About Us"
        },
        "education": map {
            "collection": $config:EDUCATION_COL,
            "select-document": function($document-id) { doc($config:EDUCATION_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:EDUCATION_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/about/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "title": "Education Resources"
        },
        "frus-history-monograph": map {
            "collection": $config:FRUS_HISTORY_MONOGRAPH_COL,
            "select-document": function($document-id) { doc($config:FRUS_HISTORY_MONOGRAPH_COL || '/' || $document-id || '.xml') },
            "select-section": function($document-id, $section-id) { doc($config:FRUS_HISTORY_MONOGRAPH_COL || '/' || $document-id || '.xml')/id($section-id) },
            "html-href": function($document-id, $section-id) { "$app/historicaldocuments/" || string-join(($document-id, $section-id), '/') },
            "odd": "frus.odd",
            "title": "History of the Foreign Relations Series",
            "base-path": function($document-id, $section-id) { "frus-history" }
        }
    };

declare variable $config:PUBLICATION-COLLECTIONS := 
    map {
        $config:FRUS_VOLUMES_COL: "frus",
        $config:BUILDINGS_COL: "buildings",
        $config:SHORT_HISTORY_COL: "short-history",
        $config:FAQ_COL: "faq",
        $config:HAC_COL: "hac",
        $config:EDUCATION_COL: "edu",
        $config:FRUS_HISTORY_MONOGRAPH_COL: "frus-history-monograph"
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