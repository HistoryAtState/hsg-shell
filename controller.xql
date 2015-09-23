xquery version "3.0";

import module namespace console="http://exist-db.org/xquery/console";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

console:log('request:get-uri(): ' || request:get-uri())
,
console:log('$exist:path: ' || $exist:path)
,
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
    let $log := console:log('using historicaldocuments for exist:path: ' || $exist:path)
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
    let $log := console:log('volume: ' || $volume || ' id: ' || $id || ' page: ' || $page)
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
    			<forward url="{$exist:controller}/error-page.html" method="get"/>
    			<forward url="{$exist:controller}/modules/view.xql"/>
    		</error-handler>
        </dispatch>
        
else if (matches($exist:path, '^/countries/?')) then
    let $log := console:log('using countries for exist:path: ' || $exist:path)
    let $fragments := tokenize(substring-after($exist:path, '/countries/'), '/')[. ne '']
    let $country := $fragments[1]
    let $id := $fragments[2]
    let $page := 'countries/index.html' 
    let $log := console:log('country: ' || $country || ' id: ' || $id || ' page: ' || $page)
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
    			<forward url="{$exist:controller}/error-page.html" method="get"/>
    			<forward url="{$exist:controller}/modules/view.xql"/>
    		</error-handler>
        </dispatch>

else if (matches($exist:path, '^/departmenthistory/?')) then
    let $log := console:log('using department for exist:path: ' || $exist:path)
    let $fragments := tokenize(substring-after($exist:path, '/departmenthistory/'), '/')[. ne '']
    return
        switch ($fragments[1])
            case "short-history" return ()
            case "buildings" return ()
            case "people" return ()
            case "travels" return ()
            case "visits" return ()
            case "wwi" return ()
            default return
                let $page := 'departmenthistory/index.html'
                return
                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                        <forward url="{$exist:controller}/pages/{$page}"/>
                        <view>
                            <forward url="{$exist:controller}/modules/view.xql"/>
                        </view>
                		<error-handler>
                			<forward url="{$exist:controller}/error-page.html" method="get"/>
                			<forward url="{$exist:controller}/modules/view.xql"/>
                		</error-handler>
                    </dispatch>
else
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/404.html"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql">
                <add-parameter name="uri" value="{$exist:path}"/>
            </forward>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>

