xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

<ul>{
    let $links := collection('/db/apps/hsg-shell/pages')//a[starts-with(@href, '$app')]
    let $distinct-hrefs := distinct-values($links/@href/string())
    for $href in $distinct-hrefs
    let $labels := $links[@href = $href]
    order by $href
    return
        <li>{$href}
            <ul>{
                for $label in distinct-values($labels) 
                order by lower-case($label) 
                return 
                    <li><a href="{replace($href, '\$app', '/exist/apps/hsg-shell')}">{$label}</a> ({string-join($links[. = $label] ! base-uri(.), '; ')})</li>
            }</ul>
        </li>
}</ul>