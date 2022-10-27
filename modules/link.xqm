xquery version "3.1";

(:
 : Module for creation of links and related functionality
 :)
module namespace link = "http://history.state.gov/ns/site/hsg/link";

import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace site="http://ns.evolvedbinary.com/sitemap" at "sitemap-config.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace ut="http://history.state.gov/ns/site/hsg/app-util" at "app-util.xqm";

declare function link:generate-from-state($url-state as map(*)) as element(a)* {
    (: $url-state is generated from the site config for a given URL :)
    let $uri := $url-state?current-url
    let $app-root :=
        try {$app:APP_ROOT}
        catch * {
        (: Assume APP_ROOT is '/exist/apps/hsg-shell'; Needed for xqsuite testing,
                 since there is no context for calls to e.g. request:get-header(). :)
        '/exist/apps/hsg-shell'
        }
    let $full-url := $app-root || $uri

    return 
        <a href="{ $full-url }">
            {
                $url-state?link-attributes!.(), (: any class or rdfa attributes may be passed in as a function using the $url-state:)
                if (ends-with($full-url, $url-state?original-url))
                then (attribute aria-current { "page" })
                else ()
            }
            <span>{link:generate-label-from-state($url-state)}</span>
        </a>
};

declare function link:generate-label-from-state($url-state as map(*)) {
    (: $url-state is generated from the site config for a given URL :)
    let $uri := $url-state?current-url
    let $page-template := $url-state?page-template
    let $parameters as map(*)? := 
        map:merge(
            (
                let $param-names as xs:string* := try {request:get-parameter-names()} catch err:XPDY0002 {()}
                for $param-name in $param-names[. = ('region', 'subject')] (: filter necessary to avoid e.g. section-id being over-written :)
                return map{
                    $param-name: request:get-parameter($param-name, '')
                },
                $url-state?parameters,
                for $param in doc($page-template)//*[@data-template eq 'pages:breadcrumb']/@*[starts-with(name(.), 'data-template-')]
                return map{
                    name($param) => substring-after('data-template-'):
                    string($param)
                }
            ), map{'duplicates': 'use-last'}
        )
    let $publication-id := $parameters?publication-id
    let $breadcrumb-title as function(*)? := $config:PUBLICATIONS?($publication-id)?breadcrumb-title
    let $label := 
        if ($uri eq '/')
            then "Home"
        else if (doc($page-template)//*[@id eq 'breadcrumb-title'])
            then doc($page-template)//*[@id eq 'breadcrumb-title']/node()
        else if (exists($breadcrumb-title)) 
            then $breadcrumb-title($parameters) 
        else if ($config:PUBLICATIONS?($publication-id)?title)
            then $config:PUBLICATIONS?($publication-id)?title
        else 
            "Office of the Historian"
    return (
        ut:normalize-nodes($label)
    )
};

declare function link:report-issue($node as element(a), $model) as element(a) {
    let $uri := (
        $model?uri,
        try { substring-after(request:get-uri(), $app:APP_ROOT)}
            catch err:XPDY0002 { 'test-path' }  (: some contexts do not have a request object, e.g. xqsuite testing :)
    )[1]
    return
        <a>{
            attribute href {
                link:email(
                    'history@state.gov',                    (:email address:)
                    'Error on page `' || $uri || '`',       (:email subject:)
                    link:report-issue-body($node, $model)   (:email body:)
                )
            },
            $node/node()
        }</a>
};

declare function link:email($email as xs:string, $subject as xs:string?, $body as xs:string?) as xs:string {
    let $subjClean := (
        $subject ! ("subject=" || encode-for-uri(.))
    )
    let $bodyClean := (
        $body ! ("body=" || substring(., 1, 2000) => encode-for-uri())
    )
    let $params as xs:string* := ($subjClean, $bodyClean)
    return (
        "mailto:" ||
        $email ||
        "?"[exists($params)] ||
        string-join($params,  '&amp;')
    )
};

declare function link:report-issue-body($node, $model) as xs:string {
    let $error as xs:string? := (templates:process(<pre class="error app:error-description"/>, $model)/string(.))[1][normalize-space(.) ne '']
    let $url := (
        $model?url,
        try { request:get-url() }
            catch err:XPDY0002 { 'test-url' }  (: some contexts do not have a request object, e.g. xqsuite testing :)
    )[1]
    let $tab := codepoints-to-string(9)
    let $parameters as xs:string* :=
        for $param in try {request:get-parameter-names()} catch err:XPDY0002 {()}
        return ($tab || $param || ':  ' || request:get-parameter($param, ()))
    return (
        "",
        "_________________________________________________________",
        "Please provide any additional information above this line",
        "",
        "Requested URL:",
        $tab || $url,
        ""[exists($parameters)],
        "Parameters:"[exists($parameters)],
        $parameters,
        ""[$error],
        "Error Description:"[$error],
        $error
    ) => ut:join-lines()
};
