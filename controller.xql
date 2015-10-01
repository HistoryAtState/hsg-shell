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
    let $match := analyze-string($exist:path, "^/historicaldocuments/?([^/]+)/?(.*)$")
    let $volume := $match//fn:group[@nr = "1"]/string()
    let $id := $match//fn:group[@nr = "2"]/string()
    let $page :=
        if ($volume and $volume != "") then
            if (starts-with($volume, "frus")) then
                (: volume interior page :)
                if ($id and $id != "") then 
                    "historicaldocuments/volume-interior.html"
                (: volume landing page :)
                else
                    "historicaldocuments/volume-landing.html"
            else
                "historicaldocuments/administrations.html"
        (: section landing page :)
        else (: if (not($volume) and not($id)) then :)
            'historicaldocuments/index.html' 
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/pages/{$page}"/>
            <view>
                <forward url="{$exist:controller}/modules/view.xql">
                    <add-parameter name="volume" value="{$volume}"/>
                    <add-parameter name="id" value="{$id}"/>
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
    let $country := $fragments[1]
    let $id := $fragments[2]
    let $page := 'countries/index.html' 
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/pages/{$page}"/>
            <view>
                <forward url="{$exist:controller}/modules/view.xql">
                    <add-parameter name="country" value="{$country}"/>
                    <add-parameter name="id" value="{$id}"/>
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