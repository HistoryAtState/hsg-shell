xquery version "3.1";

module namespace app="http://history.state.gov/ns/site/hsg/templates";

import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
import module namespace templates="http://exist-db.org/xquery/html-templating";

declare variable $app:APP_ROOT :=
    let $nginx-request-uri := 
        try {request:get-header('nginx-request-uri')} (: e.g. XQsuite has no request :)
        catch * {()}
    let $context-path := 
        try {request:get-context-path()}
        catch * {'/exist'}
    return
        (: if request received from nginx :)
        if ($nginx-request-uri) then
            if (starts-with($nginx-request-uri, '/beta')) then
                "/beta"
            (: we must be out of beta! urls can assume root :)
            else
                ""
        (: otherwise we're in the eXist URL space :)
        else
            $context-path || "/apps/hsg-shell";

declare
    %templates:wrap
function app:hide-if-empty($node as node(), $model as map(*), $property as xs:string) {
        if (empty($model($property))) then
            attribute style { "display: none" }
        else
            (),
        templates:process($node/node(), $model)
};

declare function app:if-parameter-set($node as node(), $model as map(*), $param as xs:string) as item()* {
    let $param := request:get-parameter($param, ())
    return
        if (exists($param) and string-join($param) != "") then
            templates:process($node/node(), $model)
        else
            ()
};

declare function app:if-parameter-unset($node as node(), $model as item()*, $param as xs:string) as item()* {
    let $param := request:get-parameter($param, ())
    return
        if (empty($param) or string-join($param) = "") then
            templates:process($node/node(), $model)
        else
            ()
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

declare function app:fix-href($href as xs:string*) {
    let $href.1 := 
        if (starts-with($href, '/') and not(starts-with($href, $app:APP_ROOT)))
        then ($app:APP_ROOT || $href)
        else $href
    return replace(
        replace(
            replace(
              $href.1,
              "\$extern",
              "https://history.state.gov"
            ),
            "\$app",
            $app:APP_ROOT
        ),
        "\$s3static",
        $config:S3_URL
    )
};

declare function app:fix-links($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch($node)
            case element(a) | element(link) return
                (: skip links with @data-template attributes; otherwise we can run into duplicate @href errors :)
                if ($node/@data-template) then
                    $node
                else
                    let $href := app:fix-href($node/@href)
                    return
                        element { node-name($node) } {
                            attribute href {$href}, $node/@* except $node/@href, app:fix-links($node/node())
                        }
            case element(img) | element(script) return
                (: allow imgs and scripts with @data-template attributes :)
                let $src := app:fix-href($node/@src)
                return
                    element { node-name($node) } {
                        attribute src {$src}, $node/@* except $node/@src, $node/node()
                    }
            case element(option) return
                (: skip links with @data-template attributes; otherwise we can run into duplicate @value errors :)
                if ($node/@data-template) then
                    $node
                else
                    let $value := app:fix-href($node/@value)
                    return
                        element { node-name($node) } {
                            attribute value {$value}, $node/@* except $node/@value, $node/node()
                        }
            case element(form) return
                (: skip links with @data-template attributes; otherwise we can run into duplicate @value errors :)
                if ($node/@data-template) then
                    $node
                else
                    let $action := app:fix-href($node/@action)
                    return
                        element { node-name($node) } {
                            attribute action {$action}, $node/@* except $node/@action, app:fix-links($node/node())
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
    let $errcode := request:get-attribute("hsg-shell.errcode")
    let $log := console:log("error: " || $errcode || " code: " || $code)
    return
        if ((empty($errcode) and empty($code)) or $code = number($errcode)) then
            (templates:process($node/node(), $model),
            response:set-status-code(if ($errcode) then $errcode else 400))
        else
            ()
};

declare function app:format-http-date($dateTime as xs:dateTime) as xs:string {
    $dateTime
    => adjust-dateTime-to-timezone(xs:dayTimeDuration("PT0H"))
    => format-dateTime("[FNn,*-3], [D01] [MNn,*-3] [Y0001] [H01]:[m01]:[s01] [Z0000]", "en", (), ())
};

declare function app:set-last-modified($last-modified as xs:dateTime) {
    response:set-header("Last-Modified", app:format-http-date($last-modified))
};

declare function app:set-created($created as xs:dateTime) {
    response:set-header("Created", app:format-http-date($created))
};

(:
 : 2015-06-04T13:03:16-04:00 -> Jun 4, 2015
 :)
declare function app:format-date-month-short-day-year($dateTime) as xs:string {
    typeswitch($dateTime)
    case xs:dateTime return
        $dateTime
        => adjust-dateTime-to-timezone(xs:dayTimeDuration("PT0H"))
        => format-dateTime("[MNn,*-3] [D01], [Y]", "en", (), ())
    case xs:date return
        $dateTime
        => adjust-date-to-timezone(xs:dayTimeDuration("PT0H"))
        => format-date("[MNn,*-3] [D01], [Y]", "en", (), ())
    case xs:gYearMonth return
        (xs:string($dateTime) || '-01')
        => xs:date()
        => adjust-date-to-timezone(xs:dayTimeDuration("PT0H"))
        => format-date("[MNn,*-3], [Y]", "en", (), ())
    case xs:gYear return xs:string($dateTime)
    default return
        if ($dateTime castable as xs:dateTime) then xs:dateTime($dateTime) => app:format-date-month-short-day-year()
        else if ($dateTime castable as xs:date) then xs:date($dateTime) => app:format-date-month-short-day-year()
        else if ($dateTime castable as xs:gYearMonth) then xs:gYearMonth($dateTime) => app:format-date-month-short-day-year()
        else if ($dateTime castable as xs:gYear) then xs:gYear($dateTime) => app:format-date-month-short-day-year()
        else error(xs:QName('app:format-date'), "Could not recognise &quot;" || $dateTime || "&quot; as a date")
};

(:
 : 2015-06-04T13:03:16-04:00 -> June 4, 2015
 :)
declare function app:format-date-month-long-day-year($dateTime) as xs:string {
    typeswitch($dateTime)
    case xs:dateTime return
        $dateTime
        => adjust-dateTime-to-timezone(xs:dayTimeDuration("PT0H"))
        => format-dateTime('[MNn] [D], [Y0001]', 'en', (), 'US')
    case xs:date return
        $dateTime
        => adjust-date-to-timezone(xs:dayTimeDuration("PT0H"))
        => format-date('[MNn] [D], [Y0001]', 'en', (), 'US')
    case xs:gYearMonth return
        (xs:string($dateTime) || '-01')
        => xs:date()
        => adjust-date-to-timezone(xs:dayTimeDuration("PT0H"))
        => format-date('[MNn], [Y0001]', 'en', (), 'US')
    case xs:gYear return xs:string($dateTime)
    default return
        if ($dateTime castable as xs:dateTime) then xs:dateTime($dateTime) => app:format-date-month-long-day-year()
        else if ($dateTime castable as xs:date) then xs:date($dateTime) => app:format-date-month-long-day-year()
        else if ($dateTime castable as xs:gYearMonth) then xs:gYearMonth($dateTime) => app:format-date-month-long-day-year()
        else if ($dateTime castable as xs:gYear) then xs:gYear($dateTime) => app:format-date-month-long-day-year()
        else error(xs:QName('app:format-date'), "Could not recognise &quot;" || $dateTime || "&quot; as a date")
};

(:
 : 2015-06-04T13:03:16-04:00 -> yyyy-mm-dd -> 2015-06-04
 :)
declare function app:format-date-short ($date as xs:dateTime) as xs:string {
    let $date := substring-before($date, 'T')
    return $date
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
                        let $parsed := analyze-string($attr, "\$\{([^\}]+?)(?::([^\}]+))?\}")
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
        for $section in doc($config:app-root || '/templates/site.xml')//div[@id = 'navbar-collapse-1']//a[starts-with(@href, '$app')][not(@class = 'dropdown-toggle')]/ancestor::li[2]
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
        for $section in doc($config:app-root || '/templates/site.xml')//div[@id = 'navbar-collapse-1']//a[starts-with(@href, '$extern')][not(@class = 'dropdown-toggle')]/ancestor::li[2]
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


declare function app:bytes-to-readable($bytes as xs:integer?) {
    if (empty($bytes)) then
        "unknown"
    else if ($bytes gt 1000000) then
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
        order by $tweet/date descending
        return $tweet
    let $tweets-to-show := subsequence($ordered-tweets, 1, $how-many)
    let $content := map { "tweets": $tweets-to-show }
    let $html := templates:process($node/*, map:merge(($model, $content),  map{"duplicates": "use-last"}))
    return
        $html
};

declare function app:tweet-html($node as node(), $model as map(*)) {
    $model?tweet/html/node()
};

declare function app:tweet-date($node as node(), $model as map(*)) {
    app:format-relative-date(xs:dateTime($model?tweet/date))
};

declare function app:tweet-href-attribute($node as node(), $model as map(*)) {
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
    let $html := templates:process($node/*, map:merge(($model, $content),  map{"duplicates": "use-last"}))
    return
        $html
};

declare function app:tumblr-post-title($node as node(), $model as map(*)) {
    $model?post/short-title/string()
};

declare function app:tumblr-post-date($node as node(), $model as map(*)) {
    app:format-relative-date(xs:dateTime($model?post/date))
};

declare function app:tumblr-post-href-attribute($node as node(), $model as map(*)) {
    attribute href { $model?post/url/string() }
};

(: carousel :)

declare %templates:wrap function app:load-carousel-items($node as node(), $model as map(*)) {
    let $carousel-ids := doc($config:CAROUSEL_COL || '/data/display-order/display-order.xml')//topic-id
    let $carousel-items := collection($config:CAROUSEL_COL || '/data/entries')/topic[id = $carousel-ids]
    let $ordered-carousel-items := for $item in $carousel-items order by index-of($carousel-ids, $item/id) return $item
    let $content := map { "carousel-items": $ordered-carousel-items }
    let $html := templates:process($node/*, map:merge(($model, $content),  map{"duplicates": "use-last"}))
    return
        $html
};

(: workaround bug in templates:each :)
declare function app:each($node as node(), $model as map(*), $from as xs:string, $to as xs:string) {
    for $item in $model($from)
    return
        element { node-name($node) } {
            $node/@*, templates:process($node/node(), map:merge(($model, map:entry($to, $item)),  map{"duplicates": "use-last"}))
        }
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
    let $image-src := $item/image
    return
        attribute src { $image-src }
};

declare function app:carousel-image-alt-attribute($node as node(), $model as map(*)) {
    let $item := $model?carousel-item
    let $image-alt := $item/image-description
    return
        attribute alt { $image-alt }
};

declare function app:carousel-image-dimension-attributes($node as node(), $model as map(*)) {
    let $item := $model?carousel-item
    let $image-height := $item/image-height
    let $image-width := $item/image-width
    return
        (
            attribute height { $image-height },
            attribute width { $image-width }
        )
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
        element a { $node/@* except $node/@href, attribute href {$url}, 'Go to the non-beta page' }
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

declare function app:error-description($node as node(), $model as map(*)) {
    try {templates:error-description($node, $model)}
    catch * {
        element { node-name($node) } {
            $node/@*,
            $err:description
        }
    }
};
