xquery version "3.1";

(:
 : Module for creation of links and related functionality
 :)
module namespace link = "http://history.state.gov/ns/site/hsg/link";

import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace site="http://ns.evolvedbinary.com/sitemap" at "sitemap-config.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";


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
                if (ends-with($url-state?full-url, $uri))
                then (attribute aria-current { "page" })
                else (),
                attribute data-originating {$url-state?full-url},
                attribute data-current {$uri}
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
        link:normalize-nodes($label)
    )
};

declare function link:normalize-nodes($nodes) {
    for $node in $nodes
    return 
        typeswitch ($node)
        case xs:string return
            normalize-space($node)
        case text() return string-join((
            (' ')[matches($node, '^\s+\S')], (: convert any leading whitespace to a single space :)
            normalize-space($node),
            (' ')[matches($node, '\S\s+$')] (: convert any trailing whitespace to a single space :)
        ))
        case element() return element {node-name($node)} { 
            link:normalize-nodes(($node/@*, $node/node())) 
        }
        default return $node
    
};