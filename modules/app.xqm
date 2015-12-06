xquery version "3.0";

module namespace app="http://history.state.gov/ns/site/hsg/templates";

import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace templates="http://exist-db.org/xquery/templates" ;

declare
    %templates:wrap
function app:hide-if-empty($node as node(), $model as map(*), $property as xs:string) {
        if (empty($model($property))) then
            attribute style { "display: none" }
        else
            (),
        templates:process($node/node(), $model)
};

declare
    %templates:wrap
function app:fix-links($node as node(), $model as map(*)) {
    app:fix-links(templates:process($node/node(), $model))
};

declare function app:fix-this-link($node as node(), $model as map(*)) {
    app:fix-links(
        templates:process(
            element { node-name($node) } { $node/@* except $node/@data-template, $node/node() }, 
            $model
        )
    )
};

declare function app:nginx-request-uri($node as node(), $model as map(*)) {
    (
    <meta name="nginx-request-uri" value="{request:get-header('nginx-request-uri')}"/>,
    <meta name="request-context-path" value="{request:get-context-path()}"/>,
    <meta name="request-get-uri" value="{request:get-uri()}"/>,
    <meta name="request-get-url" value="{request:get-url()}"/>,
    <meta name="request-get-effective-uri" value="{request:get-effective-uri()}"/>
    )
};

declare function app:fix-links($nodes as node()*) {
    let $nginx-request-uri := request:get-header('nginx-request-uri')
    let $path-to-app := 
        (: if request received from nginx :)
        if ($nginx-request-uri) then 
            if (starts-with($nginx-request-uri, '/beta')) then 
                "/beta"
            (: we must be out of beta! urls can assume root :) 
            else
                ""
        (: otherwise we're in the eXist URL space :)
        else 
            request:get-context-path() || "/apps/hsg-shell"
    for $node in $nodes
    return
        typeswitch($node)
            case element(a) | element(link) return
                (: skip links with @data-template attributes; otherwise we can run into duplicate @href errors :)
                if ($node/@data-template) then 
                    $node 
                else
                    let $href := 
                        replace(
                            replace($node/@href, "\$extern", "https://history.state.gov"),
                            "\$app",
                            $path-to-app
                        )
                    return
                        element { node-name($node) } {
                            attribute href {$href}, $node/@* except $node/@href, app:fix-links($node/node())
                        }
            case element(img) | element(script) return
                (: allow imgs and scripts with @data-template attributes :)
                let $src := 
                    replace(
                        replace($node/@src, "\$extern", "https://history.state.gov"),
                        "\$app",
                        $path-to-app
                    )
                return
                    element { node-name($node) } {
                        attribute src {$src}, $node/@* except $node/@src, $node/node()
                    }
            case element(option) return
                (: skip links with @data-template attributes; otherwise we can run into duplicate @value errors :)
                if ($node/@data-template) then 
                    $node 
                else
                    let $value := 
                        replace(
                            replace($node/@value, "\$extern", "http://history.state.gov"),
                            "\$app",
                            $path-to-app
                        )
                    return
                        element { node-name($node) } {
                            attribute value {$value}, $node/@* except $node/@value, $node/node()
                        }
            case element(form) return
                (: skip links with @data-template attributes; otherwise we can run into duplicate @value errors :)
                if ($node/@data-template) then 
                    $node 
                else
                    let $action := 
                        replace(
                            replace($node/@action, "\$extern", "http://history.state.gov"),
                            "\$app",
                            $path-to-app
                        )
                    return
                        element { node-name($node) } {
                            attribute action {$action}, $node/@* except $node/@action, $node/node()
                        }
            case element() return
                element { node-name($node) } {
                    $node/@*, app:fix-links($node/node())
                }
            default return
                $node
};

declare
    %templates:wrap
function app:handle-error($node as node(), $model as map(*), $code as xs:int?) {
    let $errcode := number(request:get-attribute("hsg-shell.errcode"))
    let $log := console:log("error: " || $errcode || " code: " || $code)
    return
        if ((empty($errcode) and empty($code)) or $code = $errcode) then
            (templates:process($node/node(), $model),
            response:set-status-code(if ($errcode) then $errcode else 400))
        else
            ()
};

declare function app:uri($node as node(), $model as map(*)) {
    <code>{request:get-attribute("hsg-shell.path")}</code>
};

declare function app:parse-params($node as node(), $model as map(*)) {
    element { node-name($node) } {
        for $attr in $node/@*
        return
            if (matches($attr, "\$\{[^\}]+\}")) then
                attribute { node-name($attr) } {
                    string-join(
                        let $parsed := analyze-string($attr, "\$\{([^\}]+?)(?:\:([^\}]+))?\}")
                        for $token in $parsed/node()
                        return
                            typeswitch($token)
                                case element(fn:non-match) return $token/string()
                                case element(fn:match) return
                                    let $paramName := $token/fn:group[1]
                                    let $default := $token/fn:group[2]
                                    return
                                        (request:get-parameter($paramName, $default), $model?($paramName))[1]
                                default return $token
                    )
                }
            else
                $attr,
        templates:process($node/node(), $model)
    }
};

declare function app:available-pages($node as node(), $model as map(*)) {
    <ul>
        {
        for $section in doc($config:app-root || '/templates/site.html')//div[@id = 'navbar-collapse-1']//a[starts-with(@href, '$app')][not(@class = 'dropdown-toggle')]/ancestor::li[2]
        return
            <li>{
                $section/a/string(),
                <ul>{
                    let $available-pages := $section//a[starts-with(@href, '$app')][not(@class = 'dropdown-toggle')]
                    for $link in $available-pages
                    return
                        <li>
                            {element {node-name($link)} {$link/@href, $link/string()}}
                        </li>
                }</ul>
            }</li>
        }
    </ul>
};

declare function app:not-yet-available-pages($node as node(), $model as map(*)) {
    <ul>
        {
        for $section in doc($config:app-root || '/templates/site.html')//div[@id = 'navbar-collapse-1']//a[starts-with(@href, '$extern')][not(@class = 'dropdown-toggle')]/ancestor::li[2]
        return
            <li>{
                $section/a/string(),
                <ul>{
                    let $available-pages := $section//a[starts-with(@href, '$extern')][not(@class = 'dropdown-toggle')]
                    for $link in $available-pages
                    return
                        <li>
                            {element {node-name($link)} {$link/@href, $link/string()}}
                        </li>
                }</ul>
            }</li>
        }
    </ul>
};


declare function app:bytes-to-readable($bytes as xs:integer) {
    if ($bytes gt 1000000) then
        concat((round($bytes div 10000) div 100), 'mb')
    else if ($bytes gt 1000) then 
        concat(round($bytes div 1000), 'kb')
    else ()
};

declare function app:year-from-date($date) {
    if ($date castable as xs:date) then 
        year-from-date($date)
    else if (matches($date, '^\d{4}-\d{2}$')) then
        replace($date, '^(\d{4})-\d{2}$', '$1')
    else (: (if (matches($date, '^\d{4}$'))) then :)
        string($date)
};

declare function app:date-to-english($date as xs:string) as xs:string {
    let $english-months := ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')
    return
        if ($date castable as xs:date) then 
            let $month-num := month-from-date($date)
            let $month := $english-months[$month-num]
            let $year := year-from-date($date)
            let $day := day-from-date($date)
            return 
                concat($month, ' ', $day, ', ', $year)
        else if (matches($date, '^\d{4}-\d{2}$')) then
            let $year := substring($date, 1, 4)
            let $month-num := xs:integer(substring($date, 6, 2))
            let $month := $english-months[$month-num]
            return 
                concat($month, ' ', $year)
        else 
            $date
};

declare %templates:wrap function app:load-most-recent-tweets($node as node(), $model as map(*), $how-many as xs:integer) {
    let $ordered-tweets := 
        for $tweet in collection($config:TWITTER_COL)/tweet
        order by $tweet/date
        return $tweet
    let $tweets-to-show := subsequence($ordered-tweets, count($ordered-tweets) - $how-many + 1)
    let $newest-on-top := reverse($tweets-to-show)
    let $content := map { "tweets": $newest-on-top }
    let $html := templates:process($node/*, map:new(($model, $content)))
    return
        $html
};

declare function app:tweet-html($node as node(), $model as map(*)) {
    let $nodes := $model?tweet/html/node()
    for $node in $nodes
    return 
        ($node, if ($node/self::a and $node/following-sibling::node()[1]/self::a) then '&#160;' else ())
};

declare function app:tweet-date($node as node(), $model as map(*)) {
    app:format-relative-date(xs:dateTime($model?tweet/date))
};

declare %templates:wrap function app:tweet-href($node as node(), $model as map(*)) {
    attribute href { $model?tweet/url/string() }
};

declare function app:format-relative-date($created as xs:dateTime) as xs:string {
    let $same-day := if (current-dateTime() - $created le xs:dayTimeDuration('P1D')) then true() else false()
    return
        if ($same-day) then
            let $duration := current-dateTime() - $created 
            return
                if (hours-from-duration($duration) ge 1) then concat(hours-from-duration($duration), 'h')
                else if (minutes-from-duration($duration) ge 1) then concat(minutes-from-duration($duration), 'm')
                else 'just now'
        else
            let $date := format-dateTime($created, '[D] [Mn,*-3]')
            let $tokens := tokenize($date, '\s')
            let $day := $tokens[1]
            let $month := $tokens[2]
            let $month := concat(upper-case(substring($month, 1, 1)), lower-case(substring($month, 2, 2)))
            return 
                concat($day, ' ', $month)
};

declare %templates:wrap function app:load-most-recent-tumblr-posts($node as node(), $model as map(*), $how-many as xs:integer) {
    let $ordered-posts := 
        for $post in collection($config:TUMBLR_COL)/post
        order by $post/date
        return $post
    let $posts-to-show := subsequence($ordered-posts, count($ordered-posts) - $how-many + 1)
    let $newest-on-top := reverse($posts-to-show)
    let $content := map { "posts": $newest-on-top }
    let $html := templates:process($node/*, map:new(($model, $content)))
    return
        $html
};

declare function app:tumblr-post-title($node as node(), $model as map(*)) {
    $model?post/short-title/string()
};

declare function app:tumblr-post-date($node as node(), $model as map(*)) {
    app:format-relative-date(xs:dateTime($model?post/date))
};

declare %templates:wrap function app:tumblr-post-href($node as node(), $model as map(*)) {
    attribute href { $model?post/url/string() }
};

(: carousel :)

declare %templates:wrap function app:load-carousel-items($node as node(), $model as map(*)) {
    let $carousel-ids := doc($config:CAROUSEL_COL || '/data/display-order/display-order.xml')//topic-id
    let $carousel-items := collection($config:CAROUSEL_COL || '/data/entries')/topic[id = $carousel-ids]
    let $ordered-carousel-items := for $item in $carousel-items order by index-of($carousel-ids, $item/id) return $item
    let $content := map { "carousel-items": $ordered-carousel-items }
    let $html := templates:process($node/*, map:new(($model, $content)))
    return
        $html
};

declare function app:carousel-list-slide-to-count-attribute($node as node(), $model as map(*)) {
    let $item := $model?carousel-item
    let $n := index-of($model?carousel-items, $item) - 1
    return
        attribute data-slide {$n}
};

declare function app:carousel-list-class-attribute($node as node(), $model as map(*)) {
    let $item := $model?carousel-item
    let $n := index-of($model?carousel-items, $item) - 1
    return
        if ($n = 0) then
            attribute class {"active"}
        else ()
};

declare function app:carousel-image-src-attribute($node as node(), $model as map(*)) {
    let $item := $model?carousel-item
    let $vol-id := replace($item/image, '\.(png|jpg)', '')
    let $image-src := '//' || $config:S3_DOMAIN || '/frus/' || $vol-id || '/covers/' || $vol-id || '.jpg'
    return
        attribute src { $image-src }
};

declare function app:carousel-image-alt-attribute($node as node(), $model as map(*)) {
    let $item := $model?carousel-item
    let $image-alt := $item/image-description
    return
        attribute alt { $image-alt }
};

declare function app:carousel-div-class-attribute($node as node(), $model as map(*)) {
    let $item := $model?carousel-item
    let $n := index-of($model?carousel-items, $item) - 1
    return
        attribute class {
            "item" ||
            (
                if ($n = 0) then
                    " active"
                else ()
            )
        }
};

declare function app:carousel-item-heading($node as node(), $model as map(*)) {
    let $item := $model?carousel-item
    let $heading := $item/title/node()
    return
        $heading
};

declare %templates:wrap function app:carousel-item-description($node as node(), $model as map(*)) {
    let $item := $model?carousel-item
    let $description := $item/body/node()
    return
        $description
};

declare function app:carousel-item-href-attribute($node as node(), $model as map(*)) {
    let $item := $model?carousel-item
    let $link := $item/link/string()
    let $href := if (starts-with($link, '/')) then ('$app' || $link) else $link
    return
        attribute href { $href }
};

declare function app:non-beta-link($node as node(), $model as map(*)) {
    let $url := 'https://history.state.gov' || 
        (
            request:get-parameter('url', ()), 
            substring-after(request:get-uri(), '/hsg-shell') || 
                (
                    if (request:get-query-string() ne '') then 
                        ('?' || request:get-query-string()) 
                    else 
                        ()
                )
        )[1]
    return
        element a { $node/@* except $node/@href, attribute href {$url}, 'Go to non-beta page: ' || $url }
};

declare function app:insert-url-parameter($node as node(), $model as map(*)) {
    element a { attribute href { 
        concat(
            app:fix-this-link($node, $model)/@href, 
            if (ends-with(request:get-uri(), '/about-the-beta')) then 
                ()
            else 
                concat(
                    '?url=', 
                    encode-for-uri(
                        concat(
                            if (starts-with(request:get-uri(), '/beta/exist/apps/hsg-shell')) then
                                substring-after(request:get-uri(), '/beta/exist/apps/hsg-shell') 
                            else if (starts-with(request:get-uri(), '/exist/apps/hsg-shell')) then
                                substring-after(request:get-uri(), '/exist/apps/hsg-shell') 
                            else 
                                request:get-uri()
                            ,
                            if (request:get-query-string() ne '') then 
                                ('?' || request:get-query-string()) 
                            else 
                                ()
                        )
                    )
                )
        )
    }, $node/@* except $node/@href, $node/node() } 
};