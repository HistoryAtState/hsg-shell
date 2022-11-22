xquery version "3.1";

(: import module namespace console="http://exist-db.org/xquery/console"; :)

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace map="http://www.w3.org/2005/xpath-functions/map";
declare namespace request="http://exist-db.org/xquery/request";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

declare function local:get-url() {
    concat(
        request:get-scheme(),
        '://',
        request:get-server-name(),
        let $server-port := request:get-server-port()
        return
            if ($server-port = (80, 443)) then
                ()
            else
                concat(":", string($server-port)),
        local:get-uri()
        )
};

declare function local:get-uri() {
    (request:get-header("nginx-request-uri"), request:get-uri())[1]
};

(:
console:log('request:get-uri(): ' || request:get-uri())
,
console:log('nginx-request-uri: ' || request:get-header('nginx-request-uri'))
,
console:log('exist:path: ' || $exist:path)
,
:)

let $if-modified-since := request:get-header("If-Modified-Since")
return
    if ($if-modified-since) then
        request:set-attribute("if-modified-since", $if-modified-since)
    else
        (),

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{local:get-uri()}/"/>
    </dispatch>

(: handle request for landing page, e.g., http://history.state.gov/ :)
else if ($exist:path eq "/" or (: remove after beta period :) ($exist:path eq '' and request:get-header('nginx-request-uri') eq '/')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/pages/index.xml"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
        <error-handler>
            <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </error-handler>
    </dispatch>

(: strip trailing slash :)
else if (ends-with($exist:path, "/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{replace(local:get-uri(), '/$', '')}"/>
    </dispatch>

(: TODO: remove bower_components once grunt/gulp integration is added :)
(: handle requests for static resources: css, js, images, etc. :)
else if (contains($exist:path, "/resources/") or contains($exist:path, "/bower_components/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/{replace($exist:path, '^.*((resources|bower_components).*)$', '$1')}"/>
    </dispatch>

else if (ends-with($exist:path, "transform/frus.css"))
then (
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <set-header name="Cache-Control" value="no-cache" />
        <cache-control cache="yes"/>
    </dispatch>
)

(: handle requests for static resource: robots.txt :)
else if ($exist:path = ("/robots.txt", "/opensearch.xml", "/favicon.ico")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller || "/resources" || $exist:path}"/>
    </dispatch>

else if (starts-with($exist:path, "/sitemap")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller || "/resources/sitemaps" || $exist:path}"/>
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



(: handle requests for ajax services :)
else if (ends-with($exist:resource, ".xql")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <ignore/>
    </dispatch>

(: handle requests for historicaldocuments section :)
else if (matches($exist:path, '^/historicaldocuments/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/historicaldocuments/'), '/')[. ne '']
    (:let $log := util:log("info","hsg-shell controller.xql fragments: " || string-join(for $f at $n in $fragments return concat($n, ": ", $f), ', ')):)
    return
        if ($fragments[1]) then
            switch ($fragments[1])
                case "pre-1861" return
                    if ($fragments[2]) then
                        if ($fragments[3]) then
                            switch ($fragments[3])
                                case "all" return
                                    let $page := "historicaldocuments/pre-1861/serial-set/all.xml"
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
                                case "browse" return
                                    let $page := "historicaldocuments/pre-1861/serial-set/browse.xml"
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
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/error-page.xml">
                                        </forward>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <set-attribute name="hsg-shell.errcode" value="404"/>
                                                <add-parameter name="uri" value="{$exist:path}"/>
                                            </forward>
                                        </view>
                                        <error-handler>
                                            <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                        </error-handler>
                                    </dispatch>
                        else
                            let $page := "historicaldocuments/pre-1861/serial-set/index.xml"
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
                    else
                        let $page := "historicaldocuments/pre-1861/index.xml"
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
                case "frus-history" return
                    if ($fragments[2]) then
                        switch ($fragments[2])
                            case "documents" return
                                if ($fragments[3]) then
                                    let $page := "historicaldocuments/frus-history/documents/document.xml"
                                    let $document-id := $fragments[3]
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql">
                                                    <add-parameter name="document-id" value="{$document-id}"/>
                                                </forward>
                                            </view>
                                            <error-handler>
                                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </error-handler>
                                        </dispatch>
                                else
                                    let $page := "historicaldocuments/frus-history/documents/index.xml"
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
                            case "events" return
                                let $page := "historicaldocuments/frus-history/events/index.xml"
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
                            case "research" return
                                if ($fragments[3]) then
                                    let $page := "historicaldocuments/frus-history/research/article.xml"
                                    let $article-id := $fragments[3]
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql">
                                                    <add-parameter name="article-id" value="{$article-id}"/>
                                                </forward>
                                            </view>
                                            <error-handler>
                                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </error-handler>
                                        </dispatch>
                                else
                                    let $page := "historicaldocuments/frus-history/research/index.xml"
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
                            case "appendix-a" return
                                let $page := "historicaldocuments/frus-history/appendix-a.xml"
                                let $section-id := "appendix-a"
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="publication-id" value="frus-history-monograph"/>
                                                <add-parameter name="document-id" value="frus-history"/>
                                                <add-parameter name="section-id" value="{$section-id}"/>
                                                <add-parameter name="requested-url" value="{local:get-url()}"/>
                                            </forward>
                                        </view>
                                        <error-handler>
                                            <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                        </error-handler>
                                    </dispatch>
                            default return
                                let $page := "historicaldocuments/frus-history/monograph-interior.xml"
                                let $section-id := $fragments[2]
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="publication-id" value="frus-history-monograph"/>
                                                <add-parameter name="document-id" value="frus-history"/>
                                                <add-parameter name="section-id" value="{$section-id}"/>
                                                <add-parameter name="requested-url" value="{local:get-url()}"/>
                                            </forward>
                                        </view>
                                        <error-handler>
                                            <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                        </error-handler>
                                    </dispatch>
                    else
                        let $page := "historicaldocuments/frus-history/index.xml"
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="frus-history-monograph"/>
                                        <add-parameter name="document-id" value="frus-history"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                case "quarterly-releases" return
                    if ($fragments[2]) then
                        let $page := "historicaldocuments/quarterly-releases/announcements/" || $fragments[2] || ".xml"
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
                    else
                        let $page := "historicaldocuments/quarterly-releases/index.xml"
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
                case "guide-to-sources-on-vietnam-1969-1975" return
                    let $page := "historicaldocuments/vietnam-guide.xml"
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}">
                            </forward>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <add-parameter name="publication-id" value="vietnam-guide"/>
                                    <add-parameter name="document-id" value="guide-to-sources-on-vietnam-1969-1975"/>
                                </forward>
                            </view>
                            <error-handler>
                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                <forward url="{$exist:controller}/modules/view.xql"/>
                            </error-handler>
                        </dispatch>
                case "volume-titles" return
                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                        <forward url="{$exist:controller}/pages/historicaldocuments/volume-titles.xml"/>
                        <view>
                            <forward url="{$exist:controller}/modules/view.xql">
                                <add-parameter name="publication-id" value="frus-list"/>
                            </forward>
                            <error-handler>
                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                <forward url="{$exist:controller}/modules/view.xql"/>
                            </error-handler>
                        </view>
                    </dispatch>
                default return
                    if (starts-with($fragments[1], "frus")) then
                        if ($fragments[2]) then
                            let $page := "historicaldocuments/volume-interior.xml"
                            let $document-id := $fragments[1]
                            let $section-id := $fragments[2]
                            return
                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward url="{$exist:controller}/pages/{$page}"/>
                                    <view>
                                        <forward url="{$exist:controller}/modules/view.xql">
                                            <add-parameter name="publication-id" value="frus"/>
                                            <add-parameter name="document-id" value="{$document-id}"/>
                                            <add-parameter name="section-id" value="{$section-id}"/>
                                            <add-parameter name="requested-url" value="{local:get-url()}"/>
                                        </forward>
                                    </view>
                                    <error-handler>
                                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                        <forward url="{$exist:controller}/modules/view.xql"/>
                                    </error-handler>
                                </dispatch>
                        else
                            let $page := "historicaldocuments/volume-landing.xml"
                            let $document-id := $fragments[1]
                            return
                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward url="{$exist:controller}/pages/{$page}"/>
                                    <view>
                                        <forward url="{$exist:controller}/modules/view.xql">
                                            <add-parameter name="publication-id" value="frus"/>
                                            <add-parameter name="document-id" value="{$document-id}"/>
                                        </forward>
                                    </view>
                                    <error-handler>
                                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                        <forward url="{$exist:controller}/modules/view.xql"/>
                                    </error-handler>
                                </dispatch>
                    else
                        if ($fragments[1] = ("about-frus", "citing-frus", "ebooks", "other-electronic-resources", "status-of-the-series")) then
                            let $page := "historicaldocuments/" || $fragments[1] || ".xml"
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
                        else
                            let $page := "historicaldocuments/administrations.xml"
                            let $administration-id := $fragments[1]
                            return
                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward url="{$exist:controller}/pages/{$page}"/>
                                    <view>
                                        <forward url="{$exist:controller}/modules/view.xql">
                                            <add-parameter name="administration-id" value="{$administration-id}"/>
                                        </forward>
                                    </view>
                                    <error-handler>
                                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                        <forward url="{$exist:controller}/modules/view.xql"/>
                                    </error-handler>
                                </dispatch>
        (: section landing page :)
        else if (ends-with($exist:path, '/historicaldocuments')) then
            let $page := 'historicaldocuments/index.xml'
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/pages/{$page}"/>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <add-parameter name="publication-id" value="historicaldocuments"/>
                        </forward>
                    </view>
                    <error-handler>
                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </error-handler>
                </dispatch>
        else (: anything else is an error:)
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/pages/error-page.xml"/>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                        <set-attribute name="hsg-shell.errcode" value="404"/>
                        <add-parameter name="uri" value="{$exist:path}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>

(: handle requests for countries section :)
else if (matches($exist:path, '^/countries/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/countries/'), '/')[. ne '']
    return
        if ($fragments[1]) then
            switch ($fragments[1])
                case "all" return
                    let $page := 'countries/all.xml'
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
                case "issues" return
                    if ($fragments[2]) then
                        let $document-id := $fragments[2]
                        let $page := 'countries/issues/article.xml'
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="countries-issues"/>
                                        <add-parameter name="document-id" value="{$document-id}"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                    else
                        let $page := 'countries/issues/index.xml'
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
                case "archives" return
                    if ($fragments[2]) then
                        switch ($fragments[2])
                            case "all" return
                                let $page := 'countries/archives/all.xml'
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward url="{$exist:controller}/pages/{$page}"/>
                                    <view>
                                        <forward url="{$exist:controller}/modules/view.xql">
                                            <add-parameter name="publication-id" value="archives"/>
                                        </forward>
                                    </view>
                                    <error-handler>
                                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                        <forward url="{$exist:controller}/modules/view.xql"/>
                                    </error-handler>
                                </dispatch>
                            default return
                                let $document-id := $fragments[2]
                                let $page := 'countries/archives/article.xml'
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="publication-id" value="archives"/>
                                                <add-parameter name="document-id" value="{$document-id}"/>
                                            </forward>
                                        </view>
                                        <error-handler>
                                            <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                        </error-handler>
                                    </dispatch>
                    else
                        let $page := 'countries/archives/index.xml'
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="archives"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                default return
                    let $page := 'countries/article.xml'
                    let $document-id := $fragments[1]
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}"/>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <add-parameter name="publication-id" value="countries"/>
                                    <add-parameter name="document-id" value="{$document-id}"/>
                                </forward>
                            </view>
                            <error-handler>
                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                <forward url="{$exist:controller}/modules/view.xql"/>
                            </error-handler>
                        </dispatch>
        else if (ends-with($exist:path, '/countries')) then
            let $page := 'countries/index.xml'
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/pages/{$page}"/>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <add-parameter name="publication-id" value="countries"/>
                        </forward>
                    </view>
                    <error-handler>
                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </error-handler>
                </dispatch>
        else (: anything else is an error :)
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/pages/error-page.xml"/>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                        <set-attribute name="hsg-shell.errcode" value="404"/>
                        <add-parameter name="uri" value="{$exist:path}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>

(: handle requests for departmenthistory section :)
else if (matches($exist:path, '^/departmenthistory/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/departmenthistory/'), '/')[. ne '']
    return
        if ($fragments[1]) then
            switch ($fragments[1])
                case "timeline" return
                    if ($fragments[2]) then
                        let $page := 'departmenthistory/timeline/section.xml'
                        let $section-id := $fragments[2]
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="timeline"/>
                                        <add-parameter name="document-id" value="timeline"/>
                                        <add-parameter name="section-id" value="{$section-id}"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                    else
                        let $page := 'departmenthistory/timeline/index.xml'
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="timeline"/>
                                        <add-parameter name="document-id" value="timeline"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                case "short-history" return
                    if ($fragments[2]) then
                        let $page := 'departmenthistory/short-history/section.xml'
                        let $section-id := $fragments[2]
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="short-history"/>
                                        <add-parameter name="document-id" value="short-history"/>
                                        <add-parameter name="section-id" value="{$section-id}"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                    else
                        let $page := 'departmenthistory/short-history/index.xml'
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="short-history"/>
                                        <add-parameter name="document-id" value="short-history"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                case "buildings" return
                    if ($fragments[2]) then
                        let $page := 'departmenthistory/buildings/section.xml'
                        let $section-id := $fragments[2]
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="buildings"/>
                                        <add-parameter name="document-id" value="buildings"/>
                                        <add-parameter name="section-id" value="{$section-id}"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                    else
                        let $page := 'departmenthistory/buildings/index.xml'
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="buildings"/>
                                        <add-parameter name="document-id" value="buildings"/>
                                        <add-parameter name="section-id" value="intro"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>

                case "people" return
                    if ($fragments[2]) then
                        switch ($fragments[2])
                            case "secretaries" return
                                let $page := 'departmenthistory/people/secretaries.xml'
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="publication-id" value="{$fragments[2]}"/>
                                            </forward>
                                        </view>
                                        <error-handler>
                                            <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                        </error-handler>
                                    </dispatch>
                            case "principals-chiefs" return
                                let $page := 'departmenthistory/people/principals-chiefs.xml'
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="publication-id" value="{$fragments[2]}"/>
                                            </forward>
                                        </view>
                                        <error-handler>
                                            <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                        </error-handler>
                                    </dispatch>
                            case "by-name" return
                                if ($fragments[3]) then
                                    let $page := 'departmenthistory/people/by-name/letter.xml'
                                    let $letter := $fragments[3]
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql">
                                                    <add-parameter name="letter" value="{$letter}"/>
                                                    <add-parameter name="publication-id" value="people-by-alpha"/>
                                                </forward>
                                            </view>
                                            <error-handler>
                                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </error-handler>
                                        </dispatch>
                                else
                                    let $page := 'departmenthistory/people/by-name/index.xml'
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql">
                                                    <add-parameter name="publication-id" value="people-by-alpha"/>
                                                </forward>
                                            </view>
                                            <error-handler>
                                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </error-handler>
                                        </dispatch>
                            case "by-year" return
                                if ($fragments[3]) then
                                    let $page := 'departmenthistory/people/by-year/year.xml'
                                    let $year := $fragments[3]
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql">
                                                    <add-parameter name="publication-id" value="people-by-year"/>
                                                    <add-parameter name="year" value="{$year}"/>
                                                </forward>
                                            </view>
                                            <error-handler>
                                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </error-handler>
                                        </dispatch>
                                else
                                    let $page := 'departmenthistory/people/by-year/index.xml'
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql">
                                                    <add-parameter name="publication-id" value="people-by-year"/>
                                                </forward>
                                            </view>
                                            <error-handler>
                                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </error-handler>
                                        </dispatch>
                            case "principalofficers" return
                                if ($fragments[3]) then
                                    let $page := 'departmenthistory/people/principalofficers/by-role-id.xml'
                                    let $role-id := $fragments[3]
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql">
                                                    <add-parameter name="role-id" value="{$role-id}"/>
                                                    <add-parameter name="publication-id" value="people-by-role"/>
                                                </forward>
                                            </view>
                                            <error-handler>
                                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </error-handler>
                                        </dispatch>
                                else
                                    let $page := 'departmenthistory/people/principalofficers/index.xml'
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql">
                                                    <add-parameter name="publication-id" value="people"/>
                                                </forward>
                                            </view>
                                            <error-handler>
                                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </error-handler>
                                        </dispatch>
                            case "chiefsofmission" return
                                if ($fragments[3]) then
                                    switch ($fragments[3])
                                        case "by-country" return
                                            let $page := 'departmenthistory/people/chiefsofmission/countries-list.xml'
                                            return
                                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                    <forward url="{$exist:controller}/pages/{$page}"/>
                                                    <view>
                                                        <forward url="{$exist:controller}/modules/view.xql">
                                                            <add-parameter name="publication-id" value="people"/>
                                                        </forward>
                                                    </view>
                                                    <error-handler>
                                                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                        <forward url="{$exist:controller}/modules/view.xql"/>
                                                    </error-handler>
                                                </dispatch>
                                        case "by-organization" return
                                            let $page := 'departmenthistory/people/chiefsofmission/international-organizations-list.xml'
                                            return
                                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                    <forward url="{$exist:controller}/pages/{$page}"/>
                                                    <view>
                                                        <forward url="{$exist:controller}/modules/view.xql">
                                                            <add-parameter name="publication-id" value="people"/>
                                                        </forward>
                                                    </view>
                                                    <error-handler>
                                                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                        <forward url="{$exist:controller}/modules/view.xql"/>
                                                    </error-handler>
                                                </dispatch>
                                        default return
                                            let $page := 'departmenthistory/people/chiefsofmission/by-role-or-country-id.xml'
                                            let $role-or-country-id := $fragments[3]
                                            return
                                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                    <forward url="{$exist:controller}/pages/{$page}"/>
                                                    <view>
                                                        <forward url="{$exist:controller}/modules/view.xql">
                                                            <add-parameter name="role-or-country-id" value="{$role-or-country-id}"/>
                                                            <add-parameter name="publication-id" value="people"/>
                                                        </forward>
                                                    </view>
                                                    <error-handler>
                                                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                        <forward url="{$exist:controller}/modules/view.xql"/>
                                                    </error-handler>
                                                </dispatch>
                                else
                                    let $page := 'departmenthistory/people/chiefsofmission/index.xml'
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql">
                                                    <add-parameter name="publication-id" value="people"/>
                                                </forward>
                                            </view>
                                            <error-handler>
                                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </error-handler>
                                        </dispatch>
                            default return
                                let $page := 'departmenthistory/people/person.xml'
                                let $person-id := $fragments[2]
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="person-id" value="{$person-id}"/>
                                                <add-parameter name="document-id" value="{$person-id}"/>
                                                <add-parameter name="publication-id" value="people"/>
                                            </forward>
                                        </view>
                                        <error-handler>
                                            <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                        </error-handler>
                                    </dispatch>
                    else
                        let $page := 'departmenthistory/people/index.xml'
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="people"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                case "travels" return
                    if ($fragments[2]) then
                        switch ($fragments[2])
                            case "president" return
                                if ($fragments[3]) then
                                    let $page := 'departmenthistory/travels/president/person-or-country.xml'
                                    let $person-or-country-id := $fragments[3]
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql">
                                                    <add-parameter name="person-or-country-id" value="{$person-or-country-id}"/>
                                                    <add-parameter name="publication-id" value="travels-president"/>
                                                </forward>
                                            </view>
                                            <error-handler>
                                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </error-handler>
                                        </dispatch>
                                else
                                    let $page := 'departmenthistory/travels/president/index.xml'
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql">
                                                    <add-parameter name="publication-id" value="travels-president"/>
                                                </forward>
                                            </view>
                                            <error-handler>
                                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </error-handler>
                                        </dispatch>
                            case "secretary" return
                                if ($fragments[3]) then
                                    let $page := 'departmenthistory/travels/secretary/person-or-country.xml'
                                    let $person-or-country-id := $fragments[3]
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql">
                                                    <add-parameter name="person-or-country-id" value="{$person-or-country-id}"/>
                                                    <add-parameter name="publication-id" value="travels-secretary"/>
                                                </forward>
                                            </view>
                                            <error-handler>
                                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </error-handler>
                                        </dispatch>
                                else
                                    let $page := 'departmenthistory/travels/secretary/index.xml'
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql">
                                                    <add-parameter name="publication-id" value="travels-secretary"/>
                                                </forward>
                                            </view>
                                            <error-handler>
                                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </error-handler>
                                        </dispatch>
                            default return
                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward url="{$exist:controller}/pages/error-page.xml">
                                    </forward>
                                    <view>
                                        <forward url="{$exist:controller}/modules/view.xql">
                                            <set-attribute name="hsg-shell.errcode" value="404"/>
                                            <add-parameter name="uri" value="{$exist:path}"/>
                                        </forward>
                                    </view>
                                    <error-handler>
                                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                        <forward url="{$exist:controller}/modules/view.xql"/>
                                    </error-handler>
                                </dispatch>
                    else
                        let $page := 'departmenthistory/travels/index.xml'
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="travels-secretary"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                case "visits" return
                    if ($fragments[2]) then
                        let $page := 'departmenthistory/visits/country-or-year.xml'
                        let $country-or-year := $fragments[2]
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="visits"/>
                                        <add-parameter name="country-or-year" value="{$country-or-year}"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                    else
                        let $page := 'departmenthistory/visits/index.xml'
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="visits"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                case "diplomatic-couriers" return
                    if ($fragments[2]) then
                        let $publication-id := 'diplomatic-couriers'
                        let $film-ids := ("before-the-jet-age", "behind-the-iron-curtain", "into-moscow", "through-the-khyber-pass")
                        let $page :=
                            if ($fragments[2] = $film-ids) then
                                'departmenthistory/diplomatic-couriers/' || $fragments[2] || '.xml'
                            else
                                ()
                        let $film-id :=
                            if ($fragments[2] = $film-ids) then
                                $fragments[2]
                            else
                                ()
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="{$publication-id}"/>
                                        <add-parameter name="film-id" value="{$film-id}"/>
                                    </forward>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                    else
                        let $page := 'departmenthistory/diplomatic-couriers/index.xml'
                        let $publication-id := 'diplomatic-couriers'
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
                default return
                    let $page :=
                        switch ($fragments[1])
                            case "wwi" return 'departmenthistory/wwi.xml'
                            default return 'departmenthistory/index.xml'
                    let $link :=
                        switch ($fragments[1])
                            case "wwi" return 'wwi'
                            default return 'departmenthistory'
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}"/>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <add-parameter name="publication-id" value="{$link}"/>
                                </forward>
                            </view>
                            <error-handler>
                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                <forward url="{$exist:controller}/modules/view.xql"/>
                            </error-handler>
                        </dispatch>

        else if (ends-with($exist:path, '/departmenthistory')) then
            let $page := "departmenthistory/index.xml"
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/pages/{$page}"/>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <add-parameter name="publication-id" value="departmenthistory"/>
                        </forward>
                    </view>
                    <error-handler>
                        <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </error-handler>
                </dispatch>

        else (: anything else is an error :)
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/pages/error-page.xml"/>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                        <set-attribute name="hsg-shell.errcode" value="404"/>
                        <add-parameter name="uri" value="{$exist:path}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>

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
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}">
                            </forward>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <set-attribute name="hsg-shell.errcode" value="404"/>
                                    <add-parameter name="uri" value="{$exist:path}"/>
                                </forward>
                            </view>
                            <error-handler>
                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                <forward url="{$exist:controller}/modules/view.xql"/>
                            </error-handler>
                        </dispatch>
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
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/pages/error-page.xml"/>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                        <set-attribute name="hsg-shell.errcode" value="404"/>
                        <add-parameter name="uri" value="{$exist:path}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>


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
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/pages/error-page.xml"/>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                        <set-attribute name="hsg-shell.errcode" value="404"/>
                        <add-parameter name="uri" value="{$exist:path}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>

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
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/pages/error-page.xml"/>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                        <set-attribute name="hsg-shell.errcode" value="404"/>
                        <add-parameter name="uri" value="{$exist:path}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>

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
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/pages/error-page.xml"/>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                        <set-attribute name="hsg-shell.errcode" value="404"/>
                        <add-parameter name="uri" value="{$exist:path}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>

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
                    let $page := "error-page.xml"
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}"/>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <set-attribute name="hsg-shell.errcode" value="404"/>
                                </forward>
                            </view>
                            <error-handler>
                                <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                                <forward url="{$exist:controller}/modules/view.xql"/>
                            </error-handler>
                        </dispatch>
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
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/pages/error-page.xml"/>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                        <set-attribute name="hsg-shell.errcode" value="404"/>
                        <add-parameter name="uri" value="{$exist:path}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>

(: handle requests for news pages :)
 else if (matches($exist:path, '^/news(/|$)')) then
    let $fragments := tokenize(substring-after($exist:path, '/news/'), '/')[. ne '']
    let $log := util:log('info', ('controller.xq, Endpoint => ^/news/?'))
    let $log := util:log('info', ('$fragments=', $fragments))
    (: TODO TFJH: Refactor url endpoints for news articles, this is just an interim solution for template development :)
    return 
        if ($fragments[1]) 
        then (
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/pages/news/news-article.xml"/>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                        <add-parameter name="publication-id" value="news"/>
                        <add-parameter name="document-id" value="{$fragments[1]}"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>
        ) 
        else (
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/pages/news/news-list.xml"/>
                <view>
                    <forward url="{$exist:controller}/modules/view.xql">
                        <add-parameter name="publication-id" value="news"/>
                    </forward>
                </view>
                <error-handler>
                    <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
                    <forward url="{$exist:controller}/modules/view.xql"/>
                </error-handler>
            </dispatch>
        )

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
                    (),
            map{"duplicates": "use-last"}
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
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/pages/error-page.xml"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <set-attribute name="hsg-shell.errcode" value="404"/>
                <add-parameter name="uri" value="{$exist:path}"/>
            </forward>
        </view>
        <error-handler>
            <forward url="{$exist:controller}/pages/error-page.xml" method="get"/>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </error-handler>
    </dispatch>
