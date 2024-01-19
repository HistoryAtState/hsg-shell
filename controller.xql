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
                        "document-id": "timeline"
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
                                    "publication-id": "travels-president"
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
else if (matches($exist:path, '^/about/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/about/'), '/')[. ne '']
    (: let $log := console:log("hsg-shell controller.xql fragments: " || string-join(for $f at $n in $fragments return concat($n, ": ", $f), ', ')) :)
    return
        if ($fragments[1]) then
            switch ($fragments[1])
                case "faq" return
                    if ($fragments[2]) then
                        let $page := "about/faq/section.xml"
                        let $publication-id := 'faq'
                        let $document-id := 'faq'
                        let $section-id := $fragments[2]
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="{$publication-id}"/>
                                        <add-parameter name="document-id" value="{$document-id}"/>
                                        <add-parameter name="section-id" value="{$section-id}"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                    else
                        let $page := "about/faq/index.xml"
                        let $publication-id := 'faq'
                        let $document-id := 'faq'
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="{$publication-id}"/>
                                        <add-parameter name="document-id" value="{$document-id}"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                case "hac" return
                    if ($fragments[2]) then
                        let $page := "about/hac/section.xml"
                        let $publication-id := 'hac'
                        let $document-id := 'hac'
                        let $section-id := $fragments[2]
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="{$publication-id}"/>
                                        <add-parameter name="document-id" value="{$document-id}"/>
                                        <add-parameter name="section-id" value="{$section-id}"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                    else
                        let $page := "about/hac/index.xml"
                        let $publication-id := 'hac'
                        let $document-id := 'hac'
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="{$publication-id}"/>
                                        <add-parameter name="document-id" value="{$document-id}"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                default return
                    let $page :=
                        switch ($fragments[1])
                            case "contact-us" return 'about/contact-us.xml'
                            case "the-historian" return 'about/the-historian.xml'
                            case "recent-publications" return 'about/recent-publications.xml'
                            case "content-warning" return 'about/content-warning.xml'
                            default return 'error-page.xml'
                    return
                        local:redirect-to-static-404()
        else if (ends-with($exist:path, '/about')) then
            let $page := "about/index.xml"
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/pages/{$page}"/>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <add-parameter name="publication-id" value="about"/>
                        </forward>
                    </view>
                    <error-handler>
                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </error-handler>
                </dispatch>
        else (: anything else is an error :)
            local:redirect-to-static-404()


(: handle requests for milestones section :)
else if (matches($exist:path, '^/milestones/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/milestones/'), '/')[. ne '']
    return
        if ($fragments[1]) then
            if ($fragments[2]) then
                let $document-id := $fragments[1]
                let $section-id := $fragments[2]
                let $page := 'milestones/chapter/article.xml'
                return
                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                        <forward url="{$exist:controller}/pages/{$page}"/>
                        <view>
                            <forward url="{$exist:controller}/modules/view.xql">
                                <add-parameter name="publication-id" value="milestones"/>
                                <add-parameter name="document-id" value="{$document-id}"/>
                                <add-parameter name="section-id" value="{$section-id}"/>
                            </forward>
                        </view>
                        <error-handler>
                            <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                            <forward url="{$exist:controller}/modules/view.xql"/>
                        </error-handler>
                    </dispatch>
            else
                if ($fragments[1] = 'all') then
                    let $page := 'milestones/all.xml'
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}"/>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <add-parameter name="publication-id" value="milestones"/>
                                </forward>
                            </view>
                            <error-handler>
                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                <forward url="{$exist:controller}/modules/view.xql"/>
                            </error-handler>
                        </dispatch>
                else
                    let $chapter-id := $fragments[1]
                    let $page := 'milestones/chapter/index.xml'
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}"/>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <add-parameter name="publication-id" value="milestones"/>
                                    <add-parameter name="document-id" value="{$chapter-id}"/>
                                </forward>
                            </view>
                            <error-handler>
                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                <forward url="{$exist:controller}/modules/view.xql"/>
                            </error-handler>
                        </dispatch>
        else if (ends-with($exist:path, '/milestones')) then
            let $page := 'milestones/index.xml'
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/pages/{$page}"/>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <add-parameter name="publication-id" value="milestones"/>
                        </forward>
                    </view>
                    <error-handler>
                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </error-handler>
                </dispatch>
        else (: anything else is an error :)
            local:redirect-to-static-404()

(: handle requests for conferences section :)
else if (matches($exist:path, '^/conferences/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/conferences/'), '/')[. ne '']
    return
        if ($fragments[1]) then
            if ($fragments[2]) then
                let $page := 'conferences/conference/section.xml'
                let $publication-id := 'conferences'
                let $document-id := $fragments[1]
                let $section-id := $fragments[2]
                return
                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                        <forward url="{$exist:controller}/pages/{$page}"/>
                        <view>
                            <forward url="{$exist:controller}/modules/view.xql">
                                <add-parameter name="publication-id" value="{$publication-id}"/>
                                <add-parameter name="document-id" value="{$document-id}"/>
                                <add-parameter name="section-id" value="{$section-id}"/>
                            </forward>
                        </view>
                        <error-handler>
                            <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                            <forward url="{$exist:controller}/modules/view.xql"/>
                        </error-handler>
                    </dispatch>
            else
                let $page := 'conferences/conference/index.xml'
                let $publication-id := 'conferences'
                let $document-id := $fragments[1]
                return
                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                        <forward url="{$exist:controller}/pages/{$page}"/>
                        <view>
                            <forward url="{$exist:controller}/modules/view.xql">
                                <add-parameter name="publication-id" value="{$publication-id}"/>
                                <add-parameter name="document-id" value="{$document-id}"/>
                            </forward>
                        </view>
                        <error-handler>
                            <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                            <forward url="{$exist:controller}/modules/view.xql"/>
                        </error-handler>
                    </dispatch>
        else if (ends-with($exist:path, '/conferences')) then
            let $page := 'conferences/index.xml'
            let $publication-id := 'conferences'
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/pages/{$page}"/>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <add-parameter name="publication-id" value="{$publication-id}"/>
                        </forward>
                    </view>
                    <error-handler>
                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </error-handler>
                </dispatch>
        else (: anything else is an error :)
            local:redirect-to-static-404()

(: handle requests for developer section :)
else if (matches($exist:path, '^/developer/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/developer/'), '/')[. ne '']
    let $page :=
        if ($fragments[1]) then
            switch ($fragments[1])
                case "catalog" return 'developer/catalog.xml'
                default return 'error-page.xml'
        else
            'developer/index.xml'
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/pages/{$page}"/>
            <view>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </view>
            <error-handler>
                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </error-handler>
        </dispatch>

(: handle requests for open section :)
else if (matches($exist:path, '^/open/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/open/'), '/')[. ne '']
    let $choice :=
        if ($fragments[1]) then
            switch ($fragments[1])
                case "frus-latest" return <choice page="pages/open/frus-latest/index.xml" mode="html"/>
                case "frus-metadata" return <choice page="pages/open/frus-metadata/index.xml" mode="html"/>
                case "frus-latest.xml" return <choice page="modules/open.xql" mode="xml" xql-feed="latest"/>
                case "frus-metadata.xml" return <choice page="modules/open.xql" mode="xml" xql-feed="metadata"/>
                default return <choice page="error-page.xml" mode="html"/>
        else
            <choice page="pages/open/index.xml" mode="html"/>
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/{$choice/@page}">
                {if($choice/@xql-feed)
                    then <add-parameter name="xql-feed" value="{$choice/@xql-feed}"/>
                    else () }
                {if($choice/@mode = 'xml')
                    then <add-parameter name="xql-application-url" value="{local:get-url()}"/>
                    else () }
            </forward>
            {if($choice/@mode = 'html') then (
            <view>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </view>,
            <error-handler>
                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </error-handler>
            ) else ()}
        </dispatch>

(: handle requests for tags section :)
else if (matches($exist:path, '^/tags/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/tags/'), '/')[. ne '']
    return
        if ($fragments[1]) then
            switch ($fragments[1])
                case "all" return
                    let $page := "tags/all.xml"
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}"/>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <add-parameter name="publication-id" value="tags"/>
                                </forward>
                            </view>
                            <error-handler>
                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                <forward url="{$exist:controller}/modules/view.xql"/>
                            </error-handler>
                        </dispatch>
                default return
                    let $page := "tags/browse.xml"
                    let $tag-id := $fragments[1]
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}"/>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <add-parameter name="publication-id" value="tags"/>
                                    <add-parameter name="tag-id" value="{$tag-id}"/>
                                </forward>
                            </view>
                            <error-handler>
                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                <forward url="{$exist:controller}/modules/view.xql"/>
                            </error-handler>
                        </dispatch>
        else if (ends-with($exist:path, '/tags')) then
            let $page := "tags/index.xml"
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/pages/{$page}"/>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <add-parameter name="publication-id" value="tags"/>
                        </forward>
                    </view>
                    <error-handler>
                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </error-handler>
                </dispatch>
        else (: anything else is an error :)
            local:redirect-to-static-404()

(: handle requests for education section :)
else if (matches($exist:path, '^/education/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/education/'), '/')[. ne '']
    return
        if ($fragments[1]) then
            switch ($fragments[1])
                case "modules" return
                    if ($fragments[2]) then
                        let $page := "education/module.xml"
                        let $document-id := $fragments[2]
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="education"/>
                                        <add-parameter name="document-id" value="{$document-id}"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                    else
                        let $page := "education/modules.xml"
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                default return
                    local:redirect-to-static-404()
        else if (ends-with($exist:path, '/education')) then
            let $page := "education/index.xml"
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/pages/{$page}"/>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </view>
                    <error-handler>
                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </error-handler>
                </dispatch>
        else (: anything else is an error :)
            local:redirect-to-static-404()

(: handle search requests :)
else if (matches($exist:path, '^/search/?')) then
    let $params :=
        map:merge(
            for $name in 
                (: request:get-parameter-names() :)
                ("q", "start-date", "end-date")
            let $values := request:get-parameter($name, ()) ! normalize-space()[. ne ""]
            return 
                if (exists($values)) then 
                    map:entry($name, $values)
                else
                    ()
        )
    (: let $log := console:log($params) :)
    let $fragments := tokenize(substring-after($exist:path, '/search/'), '/')[. ne '']
    let $is-keyword := map:contains($params, "q")
    let $is-date := map:contains($params, "start-date") or map:contains($params, "end-date")
    let $page :=
        (: If a search query is present, show the results template :)
        if ($is-keyword or $is-date) then
            'search/search-result.xml'
        else if ($fragments[1]) then
            switch ($fragments[1])
                case "tips" return 'search/tips.xml'
                default return 'error-page.xml'
        else
            'search/search-landing.xml'
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/pages/{$page}"/>
            <view>
                <forward url="{$exist:controller}/modules/view.xql">
                    <add-parameter name="suppress-sitewide-search-field" value="true"/>
                </forward>
            </view>
            <error-handler>
                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </error-handler>
        </dispatch>

(: handle OPDS API requests :)
else if (matches($exist:path, '^/api/v1/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/api/v1/'), '/')[. ne '']
    let $xql := switch ($fragments[1])
        case "catalog" return 'opds-catalog.xql'
        default return 'opds-catalog.xql'
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/modules/{$xql}">
                <add-parameter name="xql-application-url" value="{local:get-url()}"/>
            </forward>
            <!--TODO Add an error handler appropriate for this API - with error codes, redirects. We currently let bad requests through without raising errors. -->
        </dispatch>

(: handle services requests :)
else if (matches($exist:path, '^/services/.+?') and substring-after($exist:path, '/services/') = ('volume-ids', 'volume-images')) then
    let $fragments := tokenize(substring-after($exist:path, '/services/'), '/')[. ne '']
    let $xql := switch ($fragments[1])
        case "volume-ids" return 'volume-ids.xql'
        case "volume-images" return 'volume-images.xql'
        default return ()
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/modules/{$xql}"/>
            <!--TODO Maybe add an error handler, but not the default one. -->
        </dispatch>

(: fallback: return 404 :)
else
    local:redirect-to-static-404()
