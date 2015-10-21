xquery version "3.0";

import module namespace console="http://exist-db.org/xquery/console";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

(: 
console:log('request:get-uri(): ' || request:get-uri())
,
console:log('$exist:path: ' || $exist:path)
,
:)
(: redirect requests for app root ('') to '/' :)
if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>
    
(: handle request for landing page, e.g., http://history.state.gov/ :)
else if ($exist:path eq "/") then
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
        <redirect url="{replace(request:get-uri(), '/$', '')}"/>
    </dispatch>

(: TODO: remove bower_components once grunt/gulp integration is added :)
(: handle requests for static resources: css, js, images, etc. :)
else if (contains($exist:path, "/resources/") or contains($exist:path, "/bower_components/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/{replace($exist:path, '^.*((resources|bower_components).*)$', '$1')}"/>
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
                                        <forward url="{$exist:controller}/pages/404.html"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
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
                                let $chapter-id := $fragments[2]
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="chapter-id" value="{$chapter-id}"/>
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
                                    <forward url="{$exist:controller}/modules/view.xql"/>
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
                            let $vol-id := $fragments[1]
                            let $section-id := $fragments[2]
                            return
                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward url="{$exist:controller}/pages/{$page}"/>
                                    <view>
                                        <forward url="{$exist:controller}/modules/view.xql">
                                            <add-parameter name="volume" value="{$vol-id}"/>
                                            <add-parameter name="id" value="{$section-id}"/>
                                        </forward>
                                    </view>
                            		<error-handler>
                            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                            			<forward url="{$exist:controller}/modules/view.xql"/>
                            		</error-handler>
                                </dispatch>
                        else 
                            let $page := "historicaldocuments/volume-landing.html"
                            let $vol-id := $fragments[1]
                            return 
                                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                    <forward url="{$exist:controller}/pages/{$page}"/>
                                    <view>
                                        <forward url="{$exist:controller}/modules/view.xql">
                                            <add-parameter name="volume" value="{$vol-id}"/>
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
                        <forward url="{$exist:controller}/modules/view.xql"/>
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
                                        <forward url="{$exist:controller}/modules/view.xql"/>
                                    </view>
                            		<error-handler>
                            			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                            			<forward url="{$exist:controller}/modules/view.xql"/>
                            		</error-handler>
                                </dispatch>
                            default return
                                let $country-id := $fragments[2]
                                let $page := 'countries/archives/article.html'
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="country-id" value="{$country-id}"/>
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
                                    <forward url="{$exist:controller}/modules/view.xql"/>
                                </view>
                        		<error-handler>
                        			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                        			<forward url="{$exist:controller}/modules/view.xql"/>
                        		</error-handler>
                            </dispatch>
                default return
                    let $page := 'countries/article.html'
                    let $country-id := $fragments[1]
                    return
                        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                            <forward url="{$exist:controller}/pages/{$page}"/>
                            <view>
                                <forward url="{$exist:controller}/modules/view.xql">
                                    <add-parameter name="country-id" value="{$country-id}"/>
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
                        <forward url="{$exist:controller}/modules/view.xql"/>
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
            case "short-history" return ()
            case "buildings" return ()
            case "people" return
                if ($fragments[2]) then
                    switch ($fragments[2])
                        case "secretaries" return 
                            let $page := 'departmenthistory/people/secretaries.html'
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
                        case "principals-chiefs" return 
                            let $page := 'departmenthistory/people/principals-chiefs.html'
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
                        case "by-name" return
                            if ($fragments[3]) then 
                                let $page := 'departmenthistory/people/letter.html'
                                let $letter := $fragments[3]
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="letter" value="{$letter}"/>
                                            </forward>
                                        </view>
                                		<error-handler>
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                            else 
                                let $page := 'departmenthistory/people/by-name.html'
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
                        case "by-year" return
                            if ($fragments[3]) then 
                                let $page := 'departmenthistory/people/year.html'
                                let $year := $fragments[3]
                                return
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/pages/{$page}"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <add-parameter name="year" value="{$year}"/>
                                            </forward>
                                        </view>
                                		<error-handler>
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                            else 
                                let $page := 'departmenthistory/people/by-year.html'
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
                                            <forward url="{$exist:controller}/modules/view.xql"/>
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
                                                    <forward url="{$exist:controller}/modules/view.xql"/>
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
                                                    <forward url="{$exist:controller}/modules/view.xql"/>
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
                                            <forward url="{$exist:controller}/modules/view.xql"/>
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
                                <forward url="{$exist:controller}/modules/view.xql"/>
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
                                            <forward url="{$exist:controller}/modules/view.xql"/>
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
                                            <forward url="{$exist:controller}/modules/view.xql"/>
                                        </view>
                                		<error-handler>
                                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                                			<forward url="{$exist:controller}/modules/view.xql"/>
                                		</error-handler>
                                    </dispatch>
                        default return 
                            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                <forward url="{$exist:controller}/pages/404.html"/>
                                <view>
                                    <forward url="{$exist:controller}/modules/view.xql">
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
                                <forward url="{$exist:controller}/modules/view.xql"/>
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
                                <forward url="{$exist:controller}/modules/view.xql"/>
                            </view>
                    		<error-handler>
                    			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                    			<forward url="{$exist:controller}/modules/view.xql"/>
                    		</error-handler>
                        </dispatch>
            default return
                let $page := 
                    switch ($fragments[1]) 
                        case "wwi" return 'departmenthistory/wwi.html'
                        default return 'departmenthistory/index.html'
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

(: handle requests for about section :)
else if (matches($exist:path, '^/about/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/about/'), '/')[. ne '']
    let $page := 
        if ($fragments[1]) then
            switch ($fragments[1])
                case "contact-us" return 'about/contact-us.html'
                case "the-historian" return 'about/the-historian.html'
                case "recent-publications" return 'about/recent-publications.html'
                default return '404.html'
        else
            'about/index.html'
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

(: handle requests for milestones section :)
else if (matches($exist:path, '^/milestones/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/milestones/'), '/')[. ne '']
    return
        if ($fragments[1]) then
            if ($fragments[2]) then
                let $chapter-id := $fragments[1]
                let $article-id := $fragments[2]
                let $page := 'milestones/chapter/article.html'
                return
                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                        <forward url="{$exist:controller}/pages/{$page}"/>
                        <view>
                            <forward url="{$exist:controller}/modules/view.xql">
                                <add-parameter name="chapter-id" value="{$chapter-id}"/>
                                <add-parameter name="article-id" value="{$article-id}"/>
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
                                <forward url="{$exist:controller}/modules/view.xql"/>
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
                                    <add-parameter name="chapter-id" value="{$chapter-id}"/>
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
                        <forward url="{$exist:controller}/modules/view.xql"/>
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
                let $conference-id := $fragments[1]
                let $section-id := $fragments[2]
                let $page := 'conferences/conference/section.html'
                return
                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                        <forward url="{$exist:controller}/pages/{$page}"/>
                        <view>
                            <forward url="{$exist:controller}/modules/view.xql">
                                <add-parameter name="conference-id" value="{$conference-id}"/>
                                <add-parameter name="section-id" value="{$section-id}"/>
                            </forward>
                        </view>
                		<error-handler>
                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                			<forward url="{$exist:controller}/modules/view.xql"/>
                		</error-handler>
                    </dispatch>
            else
                let $conference-id := $fragments[1]
                let $page := 'conferences/conference/index.html'
                return
                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                        <forward url="{$exist:controller}/pages/{$page}"/>
                        <view>
                            <forward url="{$exist:controller}/modules/view.xql">
                                <add-parameter name="conference-id" value="{$conference-id}"/>
                            </forward>
                        </view>
                		<error-handler>
                			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
                			<forward url="{$exist:controller}/modules/view.xql"/>
                		</error-handler>
                    </dispatch>
        else
            let $page := 'conferences/index.html'
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

(: handle requests for developer section :)
else if (matches($exist:path, '^/developer/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/developer/'), '/')[. ne '']
    let $page := 
        if ($fragments[1]) then
            switch ($fragments[1])
                case "catalog" return 'developer/catalog.html'
                default return '404.html'
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
(: TODO add the atom feeds: /open/frus-latest.xml, /open/frus-metadata.xml:)
else if (matches($exist:path, '^/open/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/open/'), '/')[. ne '']
    let $page := 
        if ($fragments[1]) then
            switch ($fragments[1])
                case "frus-latest" return 'open/frus-latest/index.html'
                case "frus-metadata" return 'open/frus-metadata/index.html'
                default return '404.html'
        else
            'open/index.html'
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

else if (matches($exist:path, '^/search/?')) then
    let $fragments := tokenize(substring-after($exist:path, '/search/'), '/')[. ne '']
    let $page := 
        if ($fragments[1]) then
            switch ($fragments[1])
                case "tips" return 'search/tips.html'
                default return '404.html'
        else
            'search/index.html'
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

(: fallback: return 404 :)
else
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/pages/404.html"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <add-parameter name="uri" value="{$exist:path}"/>
            </forward>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/pages/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>