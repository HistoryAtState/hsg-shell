xquery version "3.0";

import module namespace console="http://exist-db.org/xquery/console";

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

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{local:get-uri()}/"/>
    </dispatch>

(: handle request for landing page, e.g., http://history.state.gov/ :)
else if ($exist:path eq "/" or (: remove after beta period :) ($exist:path eq '' and request:get-header('nginx-request-uri') eq '/')) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/pages/index.html"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
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

(: handle requests for static resource: robots.txt :)
else if ($exist:path = ("/robots.txt", "/opensearch.xml", "/favicon.ico")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller || "/resources" || $exist:path}"/>
    </dispatch>

(: handle requests for ajax services :)
else if (ends-with($exist:resource, ".xql")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <ignore/>
    </dispatch>

(: handle requests for historicaldocuments section :)
else if (matches($exist:path, '^/historicaldocuments/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/historicaldocuments/'), '/')[. ne '']
(:    let $log := console:log("hsg-shell controller.xql fragments: " || string-join(for $f at $n in $fragments return concat($n, ": ", $f), ', ')):)
    return
        if ($fragments[1]) then
            switch ($fragments[1])
                case "pre-1861" return
                    if ($fragments[2]) then
                        if ($fragments[3]) then
                            switch ($fragments[3])
                                case "all" return
                                    let $page := "historicaldocuments/pre-1861/serial-set/all.html"
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </view>
                                    		<error-handler>
                                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                    			<forward url="{$exist:controller}/modules/view.xql"/>
                                    		</error-handler>
                                        </dispatch>
                                case "browse" return
                                    let $page := "historicaldocuments/pre-1861/serial-set/browse.html"
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </view>
                                    		<error-handler>
                                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                    			<forward url="{$exist:controller}/modules/view.xql"/>
                                    		</error-handler>
                                        </dispatch>
                                default return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/error-page.html">
                                        </forward>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <set-attribute name="hsg-shell.errcode" value="404"/>
                                                <add-parameter name="uri" value="{$exist:path}"/>
                                            </forward>
                                        </view>
                                		<error-handler>
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                        else
                            let $page := "historicaldocuments/pre-1861/serial-set/index.html"
                            return
                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward url="{$exist:controller}/pages/{$page}"/>
                                    <view>
                                        <forward url="{$exist:controller}/modules/view.xql"/>
                                    </view>
                            		<error-handler>
                            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                            			<forward url="{$exist:controller}/modules/view.xql"/>
                            		</error-handler>
                                </dispatch>
                    else
                        let $page := "historicaldocuments/pre-1861/index.html"
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </view>
                        		<error-handler>
                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                        			<forward url="{$exist:controller}/modules/view.xql"/>
                        		</error-handler>
                            </dispatch>
                case "frus-history" return
                    if ($fragments[2]) then
                        switch ($fragments[2])
                            case "documents" return
                                if ($fragments[3]) then
                                    let $page := "historicaldocuments/frus-history/documents/document.html"
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
                                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                    			<forward url="{$exist:controller}/modules/view.xql"/>
                                    		</error-handler>
                                        </dispatch>
                                else
                                    let $page := "historicaldocuments/frus-history/documents/index.html"
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </view>
                                    		<error-handler>
                                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                    			<forward url="{$exist:controller}/modules/view.xql"/>
                                    		</error-handler>
                                        </dispatch>
                            case "events" return
                                let $page := "historicaldocuments/frus-history/events/index.html"
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                        </view>
                                		<error-handler>
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                            case "research" return
                                if ($fragments[3]) then
                                    let $page := "historicaldocuments/frus-history/research/article.html"
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
                                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                    			<forward url="{$exist:controller}/modules/view.xql"/>
                                    		</error-handler>
                                        </dispatch>
                                else
                                    let $page := "historicaldocuments/frus-history/research/index.html"
                                    return
                                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                            <forward url="{$exist:controller}/pages/{$page}"/>
                                            <view>
                                                <forward url="{$exist:controller}/modules/view.xql"/>
                                            </view>
                                    		<error-handler>
                                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                    			<forward url="{$exist:controller}/modules/view.xql"/>
                                    		</error-handler>
                                        </dispatch>
                            default return
                                let $page := "historicaldocuments/frus-history/monograph-interior.html"
                                let $section-id := $fragments[2]
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="publication-id" value="frus-history-monograph"/>
                                                <add-parameter name="document-id" value="frus-history"/>
                                                <add-parameter name="section-id" value="{$section-id}"/>
                                            </forward>
                                        </view>
                                		<error-handler>
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                    else
                        let $page := "historicaldocuments/frus-history/index.html"
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
                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                        			<forward url="{$exist:controller}/modules/view.xql"/>
                        		</error-handler>
                            </dispatch>
                case "quarterly-releases" return
                    if ($fragments[2]) then
                        let $page := "historicaldocuments/quarterly-releases/announcements/" || $fragments[2] || ".html"
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </view>
                                <error-handler>
                                    <forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </error-handler>
                            </dispatch>
                    else
                        let $page := "historicaldocuments/quarterly-releases/index.html"
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </view>
                        		<error-handler>
                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                        			<forward url="{$exist:controller}/modules/view.xql"/>
                        		</error-handler>
                            </dispatch>
                case "guide-to-sources-on-vietnam-1969-1975" return
                    let $page := "historicaldocuments/vietnam-guide.html"
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
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
                default return
                    if (starts-with($fragments[1], "frus")) then
                        if ($fragments[2]) then
                            let $page := "historicaldocuments/volume-interior.html"
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
                                        </forward>
                                    </view>
                            		<error-handler>
                            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                            			<forward url="{$exist:controller}/modules/view.xql"/>
                            		</error-handler>
                                </dispatch>
                        else
                            let $page := "historicaldocuments/volume-landing.html"
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
                            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                            			<forward url="{$exist:controller}/modules/view.xql"/>
                            		</error-handler>
                                </dispatch>
                    else
                        if ($fragments[1] = ("about-frus", "citing-frus", "ebooks", "other-electronic-resources", "status-of-the-series")) then
                            let $page := "historicaldocuments/" || $fragments[1] || ".html"
                            return
                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward url="{$exist:controller}/pages/{$page}"/>
                                    <view>
                                        <forward url="{$exist:controller}/modules/view.xql"/>
                                    </view>
                            		<error-handler>
                            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                            			<forward url="{$exist:controller}/modules/view.xql"/>
                            		</error-handler>
                                </dispatch>
                        else
                            let $page := "historicaldocuments/administrations.html"
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
                            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                            			<forward url="{$exist:controller}/modules/view.xql"/>
                            		</error-handler>
                                </dispatch>
        (: section landing page :)
        else (: if (not($fragments[1])) then :)
            let $page := 'historicaldocuments/index.html'
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/pages/{$page}"/>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <add-parameter name="publication-id" value="historicaldocuments"/>
                        </forward>
                    </view>
            		<error-handler>
            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
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
                    let $page := 'countries/all.html'
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}"/>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql"/>
                            </view>
                    		<error-handler>
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
                case "issues" return
                    if ($fragments[2]) then
                        let $resource := $fragments[2]
                        let $page := 'countries/issues/resource.html'
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="resource" value="{$resource}"/>
                                    </forward>
                                </view>
                        		<error-handler>
                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                        			<forward url="{$exist:controller}/modules/view.xql"/>
                        		</error-handler>
                            </dispatch>
                    else
                        let $page := 'countries/issues/index.html'
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </view>
                        		<error-handler>
                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                        			<forward url="{$exist:controller}/modules/view.xql"/>
                        		</error-handler>
                            </dispatch>
                case "archives" return
                    if ($fragments[2]) then
                        switch ($fragments[2])
                            case "all" return
                                let $page := 'countries/archives/all.html'
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward url="{$exist:controller}/pages/{$page}"/>
                                    <view>
                                        <forward url="{$exist:controller}/modules/view.xql">
                                            <add-parameter name="publication-id" value="archives"/>
                                        </forward>
                                    </view>
                            		<error-handler>
                            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                            			<forward url="{$exist:controller}/modules/view.xql"/>
                            		</error-handler>
                                </dispatch>
                            default return
                                let $document-id := $fragments[2]
                                let $page := 'countries/archives/article.html'
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
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                    else
                        let $page := 'countries/archives/index.html'
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <add-parameter name="publication-id" value="archives"/>
                                    </forward>
                                </view>
                        		<error-handler>
                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                        			<forward url="{$exist:controller}/modules/view.xql"/>
                        		</error-handler>
                            </dispatch>
                default return
                    let $page := 'countries/article.html'
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
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
        else
            let $page := 'countries/index.html'
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/pages/{$page}"/>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <add-parameter name="publication-id" value="countries"/>
                        </forward>
                    </view>
            		<error-handler>
            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
            			<forward url="{$exist:controller}/modules/view.xql"/>
            		</error-handler>
                </dispatch>

(: handle requests for departmenthistory section :)
else if (matches($exist:path, '^/departmenthistory/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/departmenthistory/'), '/')[. ne '']
    return
        switch ($fragments[1])
            case "short-history" return
                if ($fragments[2]) then
                    let $page := 'departmenthistory/short-history/section.html'
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
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
                else
                    let $page := 'departmenthistory/short-history/index.html'
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
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
            case "buildings" return
                if ($fragments[2]) then
                    let $page := 'departmenthistory/buildings/section.html'
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
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
                else
                    let $page := 'departmenthistory/buildings/index.html'
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
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>

            case "people" return
                if ($fragments[2]) then
                    switch ($fragments[2])
                        case "secretaries" return
                            let $page := 'departmenthistory/people/secretaries.html'
                            return
                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward url="{$exist:controller}/pages/{$page}"/>
                                    <view>
                                        <forward url="{$exist:controller}/modules/view.xql">
                                            <add-parameter name="publication-id" value="{$fragments[2]}"/>
                                        </forward>
                                    </view>
                            		<error-handler>
                            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                            			<forward url="{$exist:controller}/modules/view.xql"/>
                            		</error-handler>
                                </dispatch>
                        case "principals-chiefs" return
                            let $page := 'departmenthistory/people/principals-chiefs.html'
                            return
                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward url="{$exist:controller}/pages/{$page}"/>
                                    <view>
                                        <forward url="{$exist:controller}/modules/view.xql">
                                            <add-parameter name="publication-id" value="{$fragments[2]}"/>
                                        </forward>
                                    </view>
                            		<error-handler>
                            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                            			<forward url="{$exist:controller}/modules/view.xql"/>
                            		</error-handler>
                                </dispatch>
                        case "by-name" return
                            if ($fragments[3]) then
                                let $page := 'departmenthistory/people/by-name/letter.html'
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
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                            else
                                let $page := 'departmenthistory/people/by-name/index.html'
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="publication-id" value="people-by-alpha"/>
                                            </forward>
                                        </view>
                                		<error-handler>
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                        case "by-year" return
                            if ($fragments[3]) then
                                let $page := 'departmenthistory/people/by-year/year.html'
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
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                            else
                                let $page := 'departmenthistory/people/by-year/index.html'
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">                                                                                    <add-parameter name="publication-id" value="people-by-year"/>
                                            </forward>
                                        </view>
                                		<error-handler>
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                        case "principalofficers" return
                            if ($fragments[3]) then
                                let $page := 'departmenthistory/people/principalofficers/by-role-id.html'
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
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                            else
                                let $page := 'departmenthistory/people/principalofficers/index.html'
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="publication-id" value="people"/>
                                            </forward>
                                        </view>
                                		<error-handler>
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                        case "chiefsofmission" return
                            if ($fragments[3]) then
                                switch ($fragments[3])
                                    case "by-country" return
                                        let $page := 'departmenthistory/people/chiefsofmission/countries-list.html'
                                        return
                                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                <forward url="{$exist:controller}/pages/{$page}"/>
                                                <view>
                                                    <forward url="{$exist:controller}/modules/view.xql">
                                                        <add-parameter name="publication-id" value="people"/>
                                                    </forward>
                                                </view>
                                        		<error-handler>
                                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                        			<forward url="{$exist:controller}/modules/view.xql"/>
                                        		</error-handler>
                                            </dispatch>
                                    case "by-organization" return
                                        let $page := 'departmenthistory/people/chiefsofmission/international-organizations-list.html'
                                        return
                                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                                <forward url="{$exist:controller}/pages/{$page}"/>
                                                <view>
                                                    <forward url="{$exist:controller}/modules/view.xql">
                                                        <add-parameter name="publication-id" value="people"/>
                                                    </forward>
                                                </view>
                                        		<error-handler>
                                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                        			<forward url="{$exist:controller}/modules/view.xql"/>
                                        		</error-handler>
                                            </dispatch>
                                    default return
                                        let $page := 'departmenthistory/people/chiefsofmission/by-role-or-country-id.html'
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
                                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                        			<forward url="{$exist:controller}/modules/view.xql"/>
                                        		</error-handler>
                                            </dispatch>
                            else
                                let $page := 'departmenthistory/people/chiefsofmission/index.html'
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="publication-id" value="people"/>
                                            </forward>
                                        </view>
                                		<error-handler>
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                        default return
                            let $page := 'departmenthistory/people/person.html'
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
                            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                            			<forward url="{$exist:controller}/modules/view.xql"/>
                            		</error-handler>
                                </dispatch>
                else
                    let $page := 'departmenthistory/people/index.html'
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}"/>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <add-parameter name="publication-id" value="people"/>
                                </forward>
                            </view>
                    		<error-handler>
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
            case "travels" return
                if ($fragments[2]) then
                    switch ($fragments[2])
                        case "president" return
                            if ($fragments[3]) then
                                let $page := 'departmenthistory/travels/president/person-or-country.html'
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
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                            else
                                let $page := 'departmenthistory/travels/president/index.html'
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="publication-id" value="travels-president"/>
                                            </forward>
                                        </view>
                                		<error-handler>
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                        case "secretary" return
                            if ($fragments[3]) then
                                let $page := 'departmenthistory/travels/secretary/person-or-country.html'
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
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                            else
                                let $page := 'departmenthistory/travels/secretary/index.html'
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="publication-id" value="travels-secretary"/>
                                            </forward>
                                        </view>
                                		<error-handler>
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                        default return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/error-page.html">
                                </forward>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
                                        <set-attribute name="hsg-shell.errcode" value="404"/>
                                        <add-parameter name="uri" value="{$exist:path}"/>
                                    </forward>
                                </view>
                        		<error-handler>
                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                        			<forward url="{$exist:controller}/modules/view.xql"/>
                        		</error-handler>
                            </dispatch>
                else
                    let $page := 'departmenthistory/travels/index.html'
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}"/>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <add-parameter name="publication-id" value="travels-secretary"/>
                                </forward>
                            </view>
                    		<error-handler>
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
            case "visits" return
                if ($fragments[2]) then
                    let $page := 'departmenthistory/visits/country-or-year.html'
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
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
                else
                    let $page := 'departmenthistory/visits/index.html'
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}"/>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <add-parameter name="publication-id" value="visits"/>
                                </forward>
                            </view>
                    		<error-handler>
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
            default return
                let $page :=
                    switch ($fragments[1])
                        case "diplomatic-couriers" return 'departmenthistory/diplomatic-couriers.html'
                        case "wwi" return 'departmenthistory/wwi.html'
                        default return 'departmenthistory/index.html'
                let $link :=
                    switch ($fragments[1])
                        case "diplomatic-couriers" return 'diplomatic-couriers'
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
                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                			<forward url="{$exist:controller}/modules/view.xql"/>
                		</error-handler>
                    </dispatch>

(: handle requests for about section :)
else if ($exist:path = '/about-the-beta') then
    let $page := 'about-the-beta.html'
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
    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
    			<forward url="{$exist:controller}/modules/view.xql"/>
    		</error-handler>
        </dispatch>

(: handle requests for about section :)
else if (matches($exist:path, '^/about/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/about/'), '/')[. ne '']
    let $log := console:log("hsg-shell controller.xql fragments: " || string-join(for $f at $n in $fragments return concat($n, ": ", $f), ', '))
    return
        if ($fragments[1]) then
            switch ($fragments[1])
                case "faq" return
                    if ($fragments[2]) then
                        let $page := "about/faq/section.html"
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
                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                        			<forward url="{$exist:controller}/modules/view.xql"/>
                        		</error-handler>
                            </dispatch>
                    else
                        let $page := "about/faq/index.html"
                        let $publication-id := 'faq'
                        let $document-id := 'faq'
                        let $section-id := 'state-records'
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
                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                        			<forward url="{$exist:controller}/modules/view.xql"/>
                        		</error-handler>
                            </dispatch>
                case "hac" return
                    if ($fragments[2]) then
                        let $page := "about/hac/section.html"
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
                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                        			<forward url="{$exist:controller}/modules/view.xql"/>
                        		</error-handler>
                            </dispatch>
                    else
                        let $page := "about/hac/index.html"
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
                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                        			<forward url="{$exist:controller}/modules/view.xql"/>
                        		</error-handler>
                            </dispatch>
                default return
                    let $page :=
                        switch ($fragments[1])
                            case "contact-us" return 'about/contact-us.html'
                            case "the-historian" return 'about/the-historian.html'
                            case "recent-publications" return 'about/recent-publications.html'
                            default return 'error-page.html'
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
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
        else
            let $page := "about/index.html"
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/pages/{$page}"/>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <add-parameter name="publication-id" value="about"/>
                        </forward>
                    </view>
            		<error-handler>
            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
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
                let $page := 'milestones/chapter/article.html'
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
                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                			<forward url="{$exist:controller}/modules/view.xql"/>
                		</error-handler>
                    </dispatch>
            else
                if ($fragments[1] = 'all') then
                    let $page := 'milestones/all.html'
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}"/>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <add-parameter name="publication-id" value="milestones"/>
                                </forward>
                            </view>
                    		<error-handler>
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
                else
                    let $chapter-id := $fragments[1]
                    let $page := 'milestones/chapter/index.html'
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
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
        else
            let $page := 'milestones/index.html'
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/pages/{$page}"/>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <add-parameter name="publication-id" value="milestones"/>
                        </forward>
                    </view>
            		<error-handler>
            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
            			<forward url="{$exist:controller}/modules/view.xql"/>
            		</error-handler>
                </dispatch>

(: handle requests for conferences section :)
else if (matches($exist:path, '^/conferences/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/conferences/'), '/')[. ne '']
    return
        if ($fragments[1]) then
            if ($fragments[2]) then
                let $page := 'conferences/conference/section.html'
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
                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                			<forward url="{$exist:controller}/modules/view.xql"/>
                		</error-handler>
                    </dispatch>
            else
                let $page := 'conferences/conference/index.html'
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
                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                			<forward url="{$exist:controller}/modules/view.xql"/>
                		</error-handler>
                    </dispatch>
        else
            let $page := 'conferences/index.html'
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
            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
            			<forward url="{$exist:controller}/modules/view.xql"/>
            		</error-handler>
                </dispatch>

(: handle requests for developer section :)
else if (matches($exist:path, '^/developer/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/developer/'), '/')[. ne '']
    let $page :=
        if ($fragments[1]) then
            switch ($fragments[1])
                case "catalog" return 'developer/catalog.html'
                default return 'error-page.html'
        else
            'developer/index.html'
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/pages/{$page}"/>
            <view>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </view>
    		<error-handler>
    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
    			<forward url="{$exist:controller}/modules/view.xql"/>
    		</error-handler>
        </dispatch>

(: handle requests for open section :)
else if (matches($exist:path, '^/open/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/open/'), '/')[. ne '']
    let $choice :=
        if ($fragments[1]) then
            switch ($fragments[1])
                case "frus-latest" return <choice page="pages/open/frus-latest/index.html" mode="html"/>
                case "frus-metadata" return <choice page="pages/open/frus-metadata/index.html" mode="html"/>
                case "frus-latest.xml" return <choice page="modules/open.xql" mode="xml" xql-feed="latest"/>
                case "frus-metadata.xml" return <choice page="modules/open.xql" mode="xml" xql-feed="metadata"/>
                default return <choice page="error-page.html" mode="html"/>
        else
            <choice page="pages/open/index.html" mode="html"/>
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
    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
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
                    let $page := "tags/all.html"
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}"/>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <add-parameter name="publication-id" value="tags"/>
                                </forward>
                            </view>
                    		<error-handler>
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
                default return
                    let $page := "tags/browse.html"
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
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
        else
            let $page := "tags/index.html"
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/pages/{$page}"/>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql">
                            <add-parameter name="publication-id" value="tags"/>
                        </forward>
                    </view>
            		<error-handler>
            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
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
                        let $page := "education/module.html"
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
                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                        			<forward url="{$exist:controller}/modules/view.xql"/>
                        		</error-handler>
                            </dispatch>
                    else
                        let $page := "education/modules.html"
                        return
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/{$page}"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </view>
                        		<error-handler>
                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                        			<forward url="{$exist:controller}/modules/view.xql"/>
                        		</error-handler>
                            </dispatch>
                default return
                    let $page := "error-page.html"
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}">
        </forward>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <set-attribute name="hsg-shell.errcode" value="404"/>
                                </forward>
                            </view>
                    		<error-handler>
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
        else
            let $page := "education/index.html"
            return
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward url="{$exist:controller}/pages/{$page}"/>
                    <view>
                        <forward url="{$exist:controller}/modules/view.xql"/>
                    </view>
            		<error-handler>
            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
            			<forward url="{$exist:controller}/modules/view.xql"/>
            		</error-handler>
                </dispatch>

(: handle search requests :)
else if (matches($exist:path, '^/search/?')) then
    let $query := request:get-parameter("q", ())
    let $start-date := request:get-parameter("start_date", ())
    let $end-date := request:get-parameter("end_date", ())
    let $start-time := request:get-parameter("start_time", ())
    let $end-time := request:get-parameter("end_time", ())
    let $log := console:log("q: " || $query || " start_date: " || $start-date || " end_date: " || $end-date || " start_time: " || $start-time || " end_time: " || $end-time)
    let $fragments := tokenize(substring-after($exist:path, '/search/'), '/')[. ne '']
    let $page :=
        (: If a search query is present, show the results template :)
        if (string-length($query) gt 0 or string-length($start-date) gt 0 or string-length($end-date) gt 0) then
            'search/search-result.html'
        else if ($fragments[1]) then
            switch ($fragments[1])
                case "select-volumes" return 'search/select-volumes.html'
                case "tips" return 'search/tips.html'
                default return 'error-page.html'
        else
            'search/search-landing.html'
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/pages/{$page}"/>
            <view>
                <forward url="{$exist:controller}/modules/view.xql">
                    <add-parameter name="suppress-sitewide-search-field" value="true"/>
                    <add-parameter name="query" value="{$query}"/>
                    <add-parameter name="start-date" value="{$start-date}"/>
                    <add-parameter name="end-date" value="{$end-date}"/>
                    <add-parameter name="start-time" value="{$start-time}"/>
                    <add-parameter name="end-time" value="{$end-time}"/>
                </forward>
            </view>
    		<error-handler>
    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
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
        <forward url="{$exist:controller}/pages/error-page.html"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <set-attribute name="hsg-shell.errcode" value="404"/>
                <add-parameter name="uri" value="{$exist:path}"/>
            </forward>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
