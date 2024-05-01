xquery version "3.1";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace map="http://www.w3.org/2005/xpath-functions/map";
declare namespace request="http://exist-db.org/xquery/request";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

declare variable $path-parts := tokenize($exist:path, '/')[. ne ''];
declare variable $nginx-request-uri-header := request:get-header("nginx-request-uri");

declare function local:uri() as xs:string {
    ($nginx-request-uri-header, request:get-uri())[1]
};

declare function local:port($port as xs:integer) as xs:string? {
    if ($port = (80, 443)) then () else ":" || $port
};

declare function local:get-url() {
    concat(
        request:get-scheme(),
        '://',
        request:get-server-name(),
        local:port(request:get-server-port()),
        local:uri()
    )
};

declare function local:maybe-set-if-modified-since($ims-header-value as xs:string?) as empty-sequence() {
    if (empty($ims-header-value)) then ()
    else request:set-attribute("if-modified-since", $ims-header-value)
};

declare function local:serve-not-found-page() as element() {
    response:set-status-code(404),
    local:render-page("error-page-404.xml")
};

declare variable $local:view-module-url := $exist:controller || "/modules/view.xql";
declare function local:render-page($page-template as xs:string, $parameters as map(*)) as element() {
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/pages/{$page-template}"/>
        <view>
            <forward url="{$local:view-module-url}">{
                map:for-each($parameters, function ($name as xs:string, $value as xs:string) as element() {
                    <add-parameter xmlns="http://exist.sourceforge.net/NS/exist"
                        name="{$name}" value="{$value}" />
                })
            }</forward>
        </view>
        <error-handler>
            <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
            <forward url="{$local:view-module-url}"/>
        </error-handler>
    </dispatch>
};

declare function local:render-page($page-template as xs:string) as element() {
    local:render-page($page-template, map{})
};


(:
util:log('debug', map {
    "request:get-uri": request:get-uri(),
    "nginx-request-uri": request:get-header('nginx-request-uri'),
    "exist:path": $exist:path,
    "path-parts": $path-parts
}),
:)

local:maybe-set-if-modified-since(request:get-header("If-Modified-Since")),

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{local:uri()}/"/>
    </dispatch>

(: handle request for landing page, e.g., http://history.state.gov/ :)
else if ($exist:path eq "/" or (: remove after beta period :) ($exist:path eq '' and $nginx-request-uri-header eq '/')) then
    local:render-page("index.xml")

(: strip trailing slash :)
else if (ends-with($exist:path, "/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{replace(local:uri(), '/$', '')}"/>
    </dispatch>

(: handle requests for static resources: css, js, images, etc. :)
else if (contains($exist:path, "/resources/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/{replace($exist:path, '^.*(resources.*)$', '$1')}"/>
    </dispatch>

(: handle requests for twitter test :)
else if (ends-with($exist:path, "validate-results-of-twitter-jobs.xq")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/tests/xquery/validate-results-of-twitter-jobs.xq"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
        <error-handler>
            <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </error-handler>
    </dispatch>

(: ignore direct requests to main modules :)
else if (ends-with($exist:resource, ".xql")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <ignore/>
    </dispatch>

else if (starts-with($exist:path, "/sitemap")) then
     <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
         <forward url="{$exist:controller || "/resources/sitemaps" || $exist:path}"/>
     </dispatch>

(: reject ANY request with more than 4 path parts -> /a/b/c/d/e :)
else if (count($path-parts) gt 4) then (
    util:log("info", ("hsg-shell controller.xql received >4 path parts: ", string-join($path-parts, ":"))),
    local:serve-not-found-page()
)

else switch($path-parts[1])

    (: handle requests for static resource: robots.txt :)
    case "robots.txt"
    case "opensearch.html"
    case "favicon.ico" return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <!-- TODO: add cache header! -->
            <forward url="{$exist:controller}/resources/{$exist:path}"/>
        </dispatch>
    case "transform" return
        if ($path-parts[2] eq "frus.css") then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <!-- <set-header name="Cache-Control" value="no-cache" /> -->
                <cache-control cache="yes"/>
            </dispatch>
        else
            local:serve-not-found-page()
    (: handle requests for historicaldocuments section :)
    case 'historicaldocuments' return
        switch (string($path-parts[2]))
            case '' return
                (: section landing page :)
                local:render-page("historicaldocuments/index.xml", map{
                    "publication-id": "historicaldocuments"
                })
            case "about-frus"
            case "citing-frus"
            case "ebooks"
            case "other-electronic-resources"
            case "status-of-the-series" return
                local:render-page("historicaldocuments/" || $path-parts[2] || ".xml")
            case "guide-to-sources-on-vietnam-1969-1975" return
                local:render-page("historicaldocuments/vietnam-guide.xml", map{
                    "publication-id": "vietnam-guide",
                    "document-id": "guide-to-sources-on-vietnam-1969-1975"
                })
            (:
            case "volume-titles" return
                local:render-page("historicaldocuments/volume-titles.xml", map{
                    "publication-id": "frus-list"
                })
            :)
            case "quarterly-releases" return
                if (empty($path-parts[3])) then
                    local:render-page("historicaldocuments/quarterly-releases/index.xml")
                else
                    local:render-page("historicaldocuments/quarterly-releases/announcements/" || $path-parts[3] || ".xml")
            case "pre-1861" return
                if (empty($path-parts[3])) then
                    local:render-page("historicaldocuments/pre-1861/index.xml")
                else if ($path-parts[3] eq 'serial-set') then
                    switch (string($path-parts[4]))
                        case '' return
                            local:render-page("historicaldocuments/pre-1861/serial-set/index.xml")
                        case "all" return
                            local:render-page("historicaldocuments/pre-1861/serial-set/all.xml")
                        case "browse" return
                            local:render-page("historicaldocuments/pre-1861/serial-set/browse.xml")
                        default return
                            local:serve-not-found-page()
                else
                    local:serve-not-found-page()
            case "frus-history" return
                switch (string($path-parts[3]))
                    case '' return
                        local:render-page("historicaldocuments/frus-history/index.xml", map{
                            "publication-id": "frus-history-monograph",
                            "document-id": "frus-history"
                        })
                    case "events" return
                        local:render-page("historicaldocuments/frus-history/events/index.xml")
                    case "documents" return
                        if (empty($path-parts[4])) then
                            local:render-page("historicaldocuments/frus-history/documents/index.xml")
                        else
                            local:render-page("historicaldocuments/frus-history/documents/document.xml", map{
                                "document-id": $path-parts[4]
                            })
                    case "research" return
                        if (empty($path-parts[4])) then
                            local:render-page("historicaldocuments/frus-history/research/index.xml")
                        else
                            local:render-page("historicaldocuments/frus-history/research/article.xml", map{
                                "article-id": $path-parts[4]
                            })
                    case "appendix-a" return
                            local:render-page("historicaldocuments/frus-history/appendix-a.xml", map{
                                "publication-id": "frus-history-monograph",
                                "document-id": "frus-history",
                                "section-id": "appendix-a",
                                    "requested-url": local:get-url()
                            })  
                    default return
                        (: TODO: can we check easily here, if a section-id is valid? :)
                        local:render-page("historicaldocuments/frus-history/monograph-interior.xml", map{
                            "publication-id": "frus-history-monograph",
                            "document-id": "frus-history",
                            "section-id": $path-parts[3],
                            "requested-url": local:get-url()
                        })
            default return
                (: return 404 for requests with unreasonable numbers of path path-parts :)
                if (count($path-parts) gt 3) then (
                    util:log("info", ("hsg-shell controller.xql received >2 path-parts: ", string-join($path-parts, "/"))),
                    local:serve-not-found-page()
                )
                else if (starts-with($path-parts[2], "frus")) then
                    if (empty($path-parts[3])) then
                        local:render-page("historicaldocuments/volume-landing.xml", map{
                            "publication-id": "frus",
                            "document-id": $path-parts[2]
                        })
                    else
                        local:render-page("historicaldocuments/volume-interior.xml", map{
                            "publication-id": "frus",
                            "document-id": $path-parts[2],
                            "section-id": $path-parts[3],
                            "requested-url": local:get-url()
                        })
                else
                    local:render-page("historicaldocuments/administrations.xml", map{
                        "administration-id": $path-parts[2]
                    })

    (: handle requests for countries section :)
    case 'countries' return
        switch (string($path-parts[2]))
            case '' return
                local:render-page('countries/index.xml', map{
                    "publication-id": "countries"
                })
            case "all" return
                local:render-page('countries/all.xml')
            case "issues" return
                if (empty($path-parts[3])) then
                    local:render-page('countries/issues/index.xml')
                else
                    local:render-page('countries/issues/article.xml', map {
                        "publication-id": "countries-issues",
                        "document-id": $path-parts[3]
                    })
            case "archives" return
                switch (string($path-parts[3]))
                    case '' return
                        local:render-page('countries/archives/index.xml', map {
                            "publication-id": "archives"
                        })

                    case "all" return
                        local:render-page('countries/archives/all.xml', map {
                            "publication-id": "archives"
                        })
                    default return
                        local:render-page('countries/archives/article.xml', map {
                            "publication-id": "archives",
                            "document-id": $path-parts[3]
                        })
            default return
                (: FIXME: find out which values are allowed here :)
                local:render-page('countries/article.xml', map{
                    "publication-id": "countries",
                    "document-id": $path-parts[2]
                })

(: handle requests for departmenthistory section :)
    case 'departmenthistory' return
        switch (string($path-parts[2]))
            case '' return
                local:render-page("departmenthistory/index.xml", map {
                    "publication-id": "departmenthistory"
                })

            case "timeline" return
                if (empty($path-parts[3])) then
                    local:render-page("departmenthistory/timeline/index.xml", map {
                        "publication-id": "timeline",
                        "document-id": "timeline"
                    })
                else
                    local:render-page("departmenthistory/timeline/section.xml", map {
                        "publication-id": "timeline",
                        "document-id": "timeline",
                        "section-id": "chapter_" || $path-parts[3]
                    })
            case "short-history" return
                if (empty($path-parts[3])) then
                    local:render-page('departmenthistory/short-history/index.xml', map{
                        "publication-id": "short-history",
                        "document-id": "short-history"
                    })
                else
                    local:render-page('departmenthistory/short-history/section.xml', map{
                        "publication-id": "short-history",
                        "document-id": "short-history",
                        "section-id": $path-parts[3]
                    })
            case "buildings" return
                if (empty($path-parts[3])) then
                    local:render-page('departmenthistory/buildings/index.xml', map{
                        "publication-id": "buildings",
                        "document-id": "buildings",
                        "section-id": "intro"
                    })
                else
                    local:render-page('departmenthistory/buildings/section.xml', map{
                        "publication-id": "buildings",
                        "document-id": "buildings",
                        "section-id": $path-parts[3]
                    })

            case "people" return
                switch (string($path-parts[3]))
                    case '' return
                        local:render-page('departmenthistory/people/index.xml', map{
                            "publication-id": "people"
                        })
                    case "secretaries"
                    case "principals-chiefs" return
                        local:render-page('departmenthistory/people/' || $path-parts[3] || '.xml', map{
                            "publication-id": $path-parts[3]
                        })
                    case "by-name" return
                        if (empty($path-parts[4])) then
                            local:render-page('departmenthistory/people/by-name/index.xml', map{
                                "publication-id": "people-by-alpha"
                            })
                        else
                            local:render-page('departmenthistory/people/by-name/letter.xml', map{
                                "publication-id": "people-by-alpha",
                                "letter": $path-parts[4]
                            })
                    case "by-year" return
                        if (empty($path-parts[4])) then
                            local:render-page('departmenthistory/people/by-year/index.xml', map{
                                "publication-id": "people-by-year"
                            })
                        else
                            local:render-page('departmenthistory/people/by-year/year.xml', map{
                                "publication-id": "people-by-year",
                                "year": $path-parts[4]
                            })
                    case "principalofficers" return
                        if (empty($path-parts[4])) then
                            local:render-page('departmenthistory/people/principalofficers/index.xml', map{
                                "publication-id": "people"
                            })
                        else
                            local:render-page('departmenthistory/people/principalofficers/by-role-id.xml', map{
                                "publication-id": "people-by-role",
                                "role-id": $path-parts[4]
                            })
                    case "chiefsofmission" return
                        switch (string($path-parts[4]))
                            case '' return
                                local:render-page('departmenthistory/people/chiefsofmission/index.xml', map{
                                    "publication-id": "people"
                                })

                            case "by-country" return
                                local:render-page('departmenthistory/people/chiefsofmission/countries-list.xml', map{
                                    "publication-id": "people"
                                })
                            case "by-organization" return
                                local:render-page('departmenthistory/people/chiefsofmission/international-organizations-list.xml', map{
                                    "publication-id": "people"
                                })
                            default return
                                local:render-page('departmenthistory/people/chiefsofmission/by-role-or-country-id.xml', map{
                                    "publication-id": "people",
                                    "role-or-country-id": $path-parts[4]
                                })
                    default return
                        local:render-page('departmenthistory/people/person.xml', map{
                            "publication-id": "people",
                            "person-id": $path-parts[3],
                            "document-id": $path-parts[3]
                        })

            case "travels" return
                switch (string($path-parts[3]))
                    case '' return
                        local:render-page('departmenthistory/travels/index.xml', map{
                            "publication-id": "travels-secretary"
                        })

                    case "president" return
                        if (empty($path-parts[4])) then
                            local:render-page('departmenthistory/travels/president/index.xml', map{
                                "publication-id": "travels-president"
                            })
                        else
                            local:render-page('departmenthistory/travels/president/person-or-country.xml', map{
                                "publication-id": "travels-president",
                                "person-or-country-id": $path-parts[4]
                            })
                    case "secretary" return
                        if (empty($path-parts[4])) then
                            local:render-page('departmenthistory/travels/secretary/index.xml', map{
                                "publication-id": "travels-secretary"
                            })
                        else
                            local:render-page('departmenthistory/travels/secretary/person-or-country.xml', map{
                                "publication-id": "travels-secretary",
                                "person-or-country-id": $path-parts[4]
                            })
                    default return
                        local:serve-not-found-page()

            case "visits" return
                if (empty($path-parts[3])) then
                    local:render-page('departmenthistory/visits/index.xml', map{
                        "publication-id": "visits"
                    })
                else
                    local:render-page('departmenthistory/visits/country-or-year.xml', map{
                        "publication-id": "visits",
                        "country-or-year": $path-parts[3]
                    })

            case "diplomatic-couriers" return
                switch(string($path-parts[3]))
                    case '' return
                        local:render-page('departmenthistory/diplomatic-couriers/index.xml', map{
                            "publication-id": 'diplomatic-couriers'
                        })

                    case "before-the-jet-age"
                    case "behind-the-iron-curtain"
                    case "into-moscow"
                    case "through-the-khyber-pass" return
                        local:render-page('departmenthistory/diplomatic-couriers/' || $path-parts[3] || '.xml', map{
                            "publication-id": 'diplomatic-couriers',
                            "film-id": $path-parts[3]
                        })
                    default return
                        local:serve-not-found-page()

            case "wwi" return
                local:render-page('departmenthistory/wwi.xml', map {
                    "publication-id": "wwi"
                })
            default return
                local:serve-not-found-page()

(: handle requests for about section :)
    case 'about' return
        switch (string($path-parts[2]))
            case '' return
                local:render-page("about/index.xml", map{
                    "publication-id": "about"
                })
            case "faq" return
                if (empty($path-parts[3])) then
                    local:render-page("about/faq/index.xml", map{
                        "publication-id": "faq",
                        "document-id": "faq"
                    })
                else
                    local:render-page("about/faq/section.xml", map{
                        "publication-id": "faq",
                        "document-id": "faq",
                        "section-id": $path-parts[3]
                    })
            case "hac" return
                if (empty($path-parts[3])) then
                    local:render-page("about/hac/index.xml", map{
                        "publication-id": "hac",
                        "document-id": "hac"
                    })
                else
                    local:render-page("about/hac/section.xml", map{
                        "publication-id": "hac",
                        "document-id": "hac",
                        "section-id": $path-parts[3]
                    })
            case "contact-us" return local:render-page('about/contact-us.xml')
            case "the-historian" return local:render-page('about/the-historian.xml')
            case "recent-publications" return local:render-page('about/recent-publications.xml')
            case "content-warning" return local:render-page('about/content-warning.xml')
            default return
                local:serve-not-found-page()

(: handle requests for milestones section :)
    case 'milestones' return
        if (empty($path-parts[2])) then
            local:render-page('milestones/index.xml', map{
                "publication-id": "milestones"
            })
        (: milestones/all :)
        else if ($path-parts[2] eq "all") then
            local:render-page('milestones/all.xml', map{
                "publication-id": "milestones"
            })
        (: milestones/1750-1775 :)
        else if (exists($path-parts[2]) and empty($path-parts[3])) then
            local:render-page('milestones/chapter/index.xml', map{
                "publication-id": "milestones",
                "document-id": $path-parts[2]
            })
        (: milestones/1750-1775/foreword :)
        else if (exists($path-parts[2]) and exists($path-parts[3])) then
            local:render-page('milestones/chapter/article.xml', map{
                "publication-id": "milestones",
                "document-id": $path-parts[2],
                "section-id": $path-parts[3]
            })
        else (: (FIXME: this is currently never the case) anything else is an error :)
            local:serve-not-found-page()

(: handle requests for conferences section :)
    case 'conferences' return
        if (empty($path-parts[2])) then
            local:render-page('conferences/index.xml', map{
                "publication-id": 'conferences'
            })
        else if (empty($path-parts[3])) then
            local:render-page('conferences/conference/index.xml', map{
                "publication-id": 'conferences',
                "document-id": $path-parts[2]
            })
        else
            local:render-page('conferences/conference/section.xml', map{
                "publication-id": 'conferences',
                "document-id": $path-parts[2],
                "section-id": $path-parts[3]
            })

    (: handle requests for developer section :)
    case 'developer' return
        if (empty($path-parts[2])) then
            local:render-page('developer/index.xml')
        else if ($path-parts[2] eq 'catalog') then
            local:render-page('developer/catalog.xml')
        else
            local:serve-not-found-page()

(: handle requests for open section :)
    case 'open' return
        switch (string($path-parts[2]))
            case '' return
                local:render-page("open/index.xml")
            case "frus-latest"
            case "frus-metadata" return
                local:render-page("open/"|| $path-parts[2] ||"/index.xml")

            case "frus-latest.xml" return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/modules/open.xql">
                        <add-parameter name="xql-feed" value="latest"/>
                        <add-parameter name="xql-application-url" value="{local:get-url()}"/>
                    </forward>
                </dispatch>
            case "frus-metadata.xml" return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/modules/open.xql">
                        <add-parameter name="xql-feed" value="metadata"/>
                        <add-parameter name="xql-application-url" value="{local:get-url()}"/>
                    </forward>
                </dispatch>
            default return
                local:serve-not-found-page()

(: handle requests for tags section :)
    case 'tags' return
        switch (string($path-parts[2]))
            case '' return
                local:render-page("tags/index.xml", map{ "publication-id": "tags" })
            case "all" return
                local:render-page("tags/all.xml", map{ "publication-id": "tags" })
            default return
                local:render-page("tags/browse.xml", map{
                    "publication-id": "tags",
                    "tag-id": $path-parts[2]
                })

(: handle requests for education section :)
    case 'education' return
        switch (string($path-parts[2]))
            case '' return
                local:render-page("education/index.xml")
            case "modules" return
                if (empty($path-parts[3])) then
                    local:render-page("education/modules.xml")
                else
                    local:render-page("education/module.xml", map{
                        "publication-id": "education",
                        "document-id": $path-parts[3]
                    })
            default return
                local:serve-not-found-page()

(: handle requests for news pages :)
(: TODO TFJH: Refactor url endpoints for news articles, this is just an interim solution for template development :)
(:
    case 'news' return
        switch (string($path-parts[2]))
            case '' return
                local:render-page("news/news-list.xml", map{ "publication-id": "news" })
            default return
                local:render-page("news/news-article.xml", map{
                    "publication-id": "news",
                    "document-id": $path-parts[2]
                })
:)

(: handle search requests :)
    case 'search' return
        switch (string($path-parts[2]))
            case '' return
                let $show-search-results := fold-left(("q", "start-date", "end-date"), false(), function($result, $next-parameter-name) {
                    let $values := request:get-parameter($next-parameter-name, ()) ! normalize-space()[. ne ""]
                    return $result or exists($values)
                })
                (: If a search query is present, show the results template :)
                let $page :=
                    if ($show-search-results) then
                        'search/search-result.xml'
                    else
                        'search/search-landing.xml'
                return
                    local:render-page($page, map{
                        "suppress-sitewide-search-field": "true"
                    })
            case 'tips' return
                local:render-page('search/tips.xml')
            default return
                local:serve-not-found-page()

    (: handle OPDS API requests :)
    case 'api' return
        if ($path-parts[2] eq 'v1') then
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/modules/opds-catalog.xql">
                    <add-parameter name="xql-application-url" value="{local:get-url()}"/>
                </forward>
                <!--TODO Add an error handler appropriate for this API - with error codes, redirects. We currently let bad requests through without raising errors. -->
            </dispatch>
        else
            local:serve-not-found-page()

    (: handle services requests :)
    case 'services' return
        switch($path-parts[2])
            case 'volume-ids'
            case 'volume-images' return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/modules/{$path-parts[2]}.xql"/>
                    <!--TODO Maybe add an error handler, but not the default one. -->
                </dispatch>
            default return
                local:serve-not-found-page()

    (: fallback: return 404 :)
    default return
        local:serve-not-found-page()
