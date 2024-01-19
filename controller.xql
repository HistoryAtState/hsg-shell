xquery version "3.1";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace map="http://www.w3.org/2005/xpath-functions/map";
declare namespace request="http://exist-db.org/xquery/request";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

declare variable $local:error-handler := 
    <error-handler>
        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
        <forward url="{$exist:controller}/modules/view.xql"/>
    </error-handler>
;

declare variable $local:nginx-request-uri-header := request:get-header("nginx-request-uri");
declare variable $local:is-proxied-request := exists($local:nginx-request-uri-header);

declare function local:uri() as xs:string {
    if ($local:is-proxied-request)
    then $local:nginx-request-uri-header
    else request:get-uri()
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


declare function local:split-path($path as xs:string) as xs:string* {
    tokenize($path, '/')[. ne '']
};

declare function local:maybe-set-if-modified-since($ims-header-value as xs:string?) as empty-sequence() {
    if (empty($ims-header-value)) then ()
    else request:set-attribute("if-modified-since", $ims-header-value)
};

declare function local:redirect-to-static-404() as element() {
    let $static-error-page :=
        if ($local:is-proxied-request)
        then "static-error-404.html"
        else "local-static-error-404.html"

    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/pages/{$static-error-page}" method="get"/>
        </dispatch>
};

declare variable $local:view-module-url := $exist:controller || "/modules/view.xql";
declare variable $local:error-page-template := $exist:controller || "/pages/error-page.xml";
declare function local:render-page($page-template as xs:string, $parameters as map(*)) as element() {
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/pages/{$page-template}"/>
        <view>
            <forward url="{$local:view-module-url}">{
                for $name in map:keys($parameters)
                let $value := $parameters($name)
                return <add-parameter name="{$name}" value="{$value}" />
            }</forward>
        </view>
        <error-handler>
            <forward url="{$local:error-page-template}" method="get"/>
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
    "exist:path": $exist:path
})
:)

let $path-parts := local:split-path($exist:path)
let $if-modified-since := local:maybe-set-if-modified-since(request:get-header("If-Modified-Since"))

return

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{local:uri()}/"/>
    </dispatch>

(: handle request for landing page, e.g., http://history.state.gov/ :)
else if ($exist:path eq "/" or (: remove after beta period :) ($exist:path eq '' and $local:nginx-request-uri-header eq '/')) then
    local:render-page("index.xml")

(: strip trailing slash :)
else if (ends-with($exist:path, "/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{replace(local:uri(), '/$', '')}"/>
    </dispatch>

(: TODO: remove bower_components once grunt/gulp integration is added :)
(: handle requests for static resources: css, js, images, etc. :)
else if (contains($exist:path, "/resources/") or contains($exist:path, "/bower_components/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/{replace($exist:path, '^.*((resources|bower_components).*)$', '$1')}"/>
    </dispatch>

(: handle requests for static resource: robots.txt :)
else if ($exist:path = ("/robots.txt", "/opensearch.xml", "/favicon.ico")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/resources{$exist:path}"/>
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
    
(: handle requests for resource-name.xml used by replication test :)
else if (ends-with($exist:path, "resource-name.xml")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/tests/xquery/resource-name.xml"/>
    </dispatch>
    
(: handle requests for validate-replication:)
else if (ends-with($exist:path, "validate-replication")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/tests/xquery/validate-replication.xq">
            <set-header name="Cache-Control" value="no-store"/>
        </forward>
    </dispatch>

(: ignore direct requests to main modules :)
else if (ends-with($exist:resource, ".xql")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <ignore/>
    </dispatch>

(: handle requests for historicaldocuments section :)
else if ($path-parts[1] eq 'historicaldocuments') then
    if (count($path-parts) gt 4) then (
        util:log("info", ("hsg-shell controller.xql received >4 path parts: ", string-join($path-parts, ":"))),
        local:redirect-to-static-404()
    )
    else if (empty($path-parts[2])) then
        (: section landing page :)
        local:render-page("historicaldocuments/index.xml", map{
            "publication-id": "historicaldocuments"
        })
    else
        switch ($path-parts[2])
            case "pre-1861" return
                if (empty($path-parts[3])) then
                    local:render-page("historicaldocuments/pre-1861/index.xml")
                else
                    if (empty($path-parts[4])) then
                        local:render-page("historicaldocuments/pre-1861/serial-set/index.xml")
                    else
                        switch ($path-parts[4])
                            case "all" return
                                local:render-page("historicaldocuments/pre-1861/serial-set/all.xml")
                            case "browse" return
                                local:render-page("historicaldocuments/pre-1861/serial-set/browse.xml")
                            default return
                                local:redirect-to-static-404()
            case "frus-history" return
                if (empty($path-parts[3])) then
                    local:render-page("historicaldocuments/frus-history/index.xml", map{
                        "publication-id": "frus-history-monograph",
                        "document-id": "frus-history"
                    })
                else
                    switch ($path-parts[3])
                        case "documents" return
                            if (empty($path-parts[4])) then
                                local:render-page("historicaldocuments/frus-history/documents/document.xml")
                            else
                                local:render-page("historicaldocuments/frus-history/documents/index.xml", map{
                                    "document-id": $path-parts[4]
                                })
                        case "events" return
                            local:render-page("historicaldocuments/frus-history/events/index.xml")
                        case "research" return
                            if (empty($path-parts[4])) then
                                local:render-page("historicaldocuments/frus-history/research/index.xml")
                            else
                                local:render-page("historicaldocuments/frus-history/research/article.xml", map{
                                    "article-id": $path-parts[4]
                                })
                        default return
                            local:render-page("historicaldocuments/frus-history/monograph-interior.xml", map{
                                "publication-id": "frus-history-monograph",
                                "document-id": "frus-history",
                                "section-id": $path-parts[3],
                                "requested-url": local:get-url()
                            })
            case "quarterly-releases" return
                if (empty($path-parts[3])) then
                    local:render-page("historicaldocuments/quarterly-releases/index.xml")
                else
                    local:render-page("historicaldocuments/quarterly-releases/announcements/" || $path-parts[3] || ".xml")
            case "guide-to-sources-on-vietnam-1969-1975" return
                local:render-page("historicaldocuments/vietnam-guide.xml", map{
                    "publication-id": "vietnam-guide",
                    "document-id": "guide-to-sources-on-vietnam-1969-1975"
                })
            default return
                if (starts-with($path-parts[2], "frus")) then
                    (: return 404 for requests with unreasonable numbers of path fragments :)
                    if (count($path-parts) gt 3) then (
                        util:log("info", ("hsg-shell controller.xql received >2 fragments: ", string-join($path-parts, "/"))),
                        local:redirect-to-static-404()
                    )
                    else if ($path-parts[3]) then
                        local:render-page("historicaldocuments/volume-interior.xml", map{
                            "publication-id": "frus",
                            "document-id": $path-parts[2],
                            "section-id": $path-parts[3],
                            "requested-url": local:get-url()
                        })
                    else
                        local:render-page("historicaldocuments/volume-landing.xml", map{
                            "publication-id": "frus",
                            "document-id": $path-parts[2]
                        })
                else
                    if ($path-parts[2] = ("about-frus", "citing-frus", "ebooks", "other-electronic-resources", "status-of-the-series")) then
                        local:render-page("historicaldocuments/" || $path-parts[2] || ".xml")
                    else
                        local:render-page("historicaldocuments/administrations.xml", map{
                            "administration-id": $path-parts[2]
                        })

(: handle requests for countries section :)
else if ($path-parts[1] eq 'countries') then
    if (empty($path-parts[2])) then
        local:render-page('countries/index.xml', map{
            "publication-id": "countries"
        })
    else
        switch ($path-parts[2])
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
                if (empty($path-parts[3])) then
                    local:render-page('countries/archives/index.xml', map {
                        "publication-id": "archives"
                    })
                else
                    switch ($path-parts[3])
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
                (: else (: anything else is an error :)
                    local:redirect-to-static-404() :)

(: handle requests for departmenthistory section :)
else if ($path-parts[1] eq 'departmenthistory') then
    if (empty($path-parts[2])) then
        local:render-page("departmenthistory/index.xml", map {
            "publication-id": "departmenthistory"
        })
    else
        switch ($path-parts[2])
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
                        "section-id": $path-parts[3]
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
                    local:render-page('departmenthistory/buildings/index.xml', map{
                        "publication-id": "buildings",
                        "document-id": "buildings",
                        "section-id": $path-parts[3]
                    })

            case "people" return
                if (empty($path-parts[3])) then
                    local:render-page('departmenthistory/people/index.xml', map{
                        "publication-id": "people"
                    })
                else
                    switch ($path-parts[3])
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
                            if (empty($path-parts[4])) then
                                local:render-page('departmenthistory/people/chiefsofmission/index.xml', map{
                                    "publication-id": "people"
                                })
                            else
                                switch ($path-parts[4])
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
                if (empty($path-parts[3])) then
                    local:render-page('departmenthistory/travels/index.xml', map{
                        "publication-id": "travels-secretary"
                    })
                else
                    switch ($path-parts[3])
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
                                local:render-page('departmenthistory/travels/secretary/person-or-country', map{
                                    "publication-id": "travels-secretary",
                                    "person-or-country-id": $path-parts[4]
                                })
                        default return
                            local:redirect-to-static-404()
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
                if (empty($path-parts[3])) then
                    local:render-page('departmenthistory/diplomatic-couriers/index.xml', map{
                        "publication-id": 'diplomatic-couriers'
                    })
                else
                    switch($path-parts[3])
                        case "before-the-jet-age"
                        case "behind-the-iron-curtain"
                        case "into-moscow"
                        case "through-the-khyber-pass" return
                            local:render-page('departmenthistory/diplomatic-couriers/' || $path-parts[3] || '.xml', map{
                                "publication-id": 'diplomatic-couriers',
                                "film-id": $path-parts[3]
                            })
                        default return
                            local:redirect-to-static-404()
            case "wwi" return
                local:render-page('departmenthistory/wwi.xml', map {
                    "publication-id": "wwi"
                })
            default return
                local:redirect-to-static-404()

(: handle requests for about section :)
else if ($path-parts[1] eq 'about') then
    if (empty($path-parts[2])) then
        local:render-page("about/index.xml", map{
            "publication-id": "about"
        })
    else
        switch ($path-parts[2])
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
                local:redirect-to-static-404()

(: handle requests for milestones section :)
(: milestones/1750-1775/foreword :)
else if ($path-parts[1] eq 'milestones') then
    if (empty($path-parts[2])) then
        local:render-page('milestones/index.xml', map{
            "publication-id": "milestones"
        })
    else if ($path-parts[2] eq "all") then
        local:render-page('milestones/all.xml', map{
            "publication-id": "milestones"
        })
    else if (exists($path-parts[2]) and empty($path-parts[3])) then
        local:render-page('milestones/chapter/index.xml', map{
            "publication-id": "milestones",
            "document-id": $path-parts[2]
        })
    else if (exists($path-parts[2]) and exists($path-parts[3])) then
        local:render-page('milestones/chapter/article.xml', map{
            "publication-id": "milestones",
            "document-id": $path-parts[2],
            "section-id": $path-parts[3]
        })
    else (: anything else is an error :)
        local:redirect-to-static-404()

(: handle requests for conferences section :)
else if ($path-parts[1] eq 'conferences') then
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
else if ($path-parts[1] eq 'developer') then
    if (empty($path-parts[2])) then
        local:render-page('developer/index.xml')
    else if ($path-parts[2] eq 'catalog') then
        local:render-page('developer/catalog.xml')
    else
        local:redirect-to-static-404()

(: handle requests for open section :)
else if ($path-parts[1] eq 'open') then
    if (empty($path-parts[2])) then
        local:render-page("open/index.xml")
    else
        switch ($path-parts[2])
            case "frus-latest"
            case "frus-metadata" return
                local:render-page("pages/open/"|| $path-parts[2] ||"/index.xml")

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
                local:redirect-to-static-404()

(: handle requests for tags section :)
else if ($path-parts[1] eq 'tags') then
    if (empty($path-parts[2])) then
        local:render-page("tags/index.xml", map{ "publication-id": "tags" })
    else
        switch ($path-parts[2])
            case "all" return
                local:render-page("tags/all.xml", map{ "publication-id": "tags" })
            default return
                local:render-page("tags/browse.xml", map{
                    "publication-id": "tags",
                    "tag-id": $path-parts[2]
                })

(: handle requests for education section :)
else if ($path-parts[1] eq 'education') then
    if (empty($path-parts[2])) then
        local:render-page("education/index.xml")
    else
        switch ($path-parts[2])
            case "modules" return
                if (empty($path-parts[3])) then
                    local:render-page("education/modules.xml")
                else
                    local:render-page("education/module.xml", map{
                        "publication-id": "education",
                        "document-id": $path-parts[3]
                    })
            default return
                local:redirect-to-static-404()

(: handle search requests :)
else if ($path-parts[1] eq 'search') then
    if (empty($path-parts[2])) then
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
    else if ($path-parts[2] eq 'tips') then
        local:render-page('search/tips.xml')
    else
        local:redirect-to-static-404()

(: handle OPDS API requests :)
else if ($path-parts[1] eq 'api' and $path-parts[2] eq 'v1') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/modules/opds-catalog.xql">
            <add-parameter name="xql-application-url" value="{local:get-url()}"/>
        </forward>
        <!--TODO Add an error handler appropriate for this API - with error codes, redirects. We currently let bad requests through without raising errors. -->
    </dispatch>

(: handle services requests :)
else if ($path-parts[1] eq 'services' and $path-parts[2] = ('volume-ids', 'volume-images')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/modules/{$path-parts[2]}.xql"/>
        <!--TODO Maybe add an error handler, but not the default one. -->
    </dispatch>

(: fallback: return 404 :)
else
    local:redirect-to-static-404()
