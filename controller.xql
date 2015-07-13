xquery version "3.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>
    
else if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/frus1948v01p1"/>
    </dispatch>
    
        
else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>

else if (ends-with($exist:resource, ".xql")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    </dispatch>
    
else if (contains($exist:path, "/resources/") or contains($exist:path, "/bower_components/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/{replace($exist:path, '^.*((resources|bower_components).*)$', '$1')}"/>
    </dispatch>
    
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>

else
    let $match := analyze-string($exist:path, "^/([^/]+)/?(.*)$")
    let $volume := $match//fn:group[@nr = "1"]/string()
    let $id := $match//fn:group[@nr = "2"]/string()
    let $page := if ($id and $id != "") then "index.html" else "volume.html"
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/{$page}"/>
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