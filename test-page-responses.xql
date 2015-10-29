xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

let $pages :=
    (
        '/',
        '/about',
        '/about/contact-us',
        '/about/faq',
        '/about/hac',
        '/about/the-historian',
        '/conferences',
        '/developer',
        '/education',
        '/open',
        '/historicaldocuments',
        '/historicaldocuments/truman',
        '/historicaldocuments/pre-truman',
        '/historicaldocuments/frus1969-76v18',
        '/historicaldocuments/frus1969-76v18/d1'
    )
let $app-base-url := 'http://localhost:8080/exist/apps/hsg-shell'
let $items :=
    for $page in $pages
    let $url := $app-base-url || $page
    let $request := <http:request href="{$url}" method="GET"/>
    let $response := http:send-request($request)[1]
    return
        <item>{$request, $response}</item>
return
    <div>
        <h1>{count($items)} pages tested</h1>
        {
            for $item-group in $items
            group by $status-code := $item-group/http:response/@status
            order by $status-code
            return
                <div>
                    <h2>{$status-code/string()} ({count($item-group)})</h2>
                    <table>
                        <thead>
                            <tr>
                                <th>Page</th>
                                <th>Status</th>
                                <th>Message</th>
                                <th>Time spent</th>
                            </tr>
                        </thead>
                        <tbody>
                            {
                                for $item in $item-group
                                let $url := $item/http:request/@href
                                let $status := $item/http:response/@status
                                let $message := $item/http:response/@message
                                let $spent-millis := $item/http:response/@spent-millis
                                order by $url
                                return
                                    <tr>
                                        <td><a href="{$url}">{substring-after($url, $app-base-url)}</a></td>
                                        <td>{$status/string()}</td>
                                        <td>{$message/string()}</td>
                                        <td>{$spent-millis/string()}ms</td>
                                    </tr>
                            }
                            <tr>
                                <td/>
                                <td/>
                                <td>Total:</td>
                                <td>{sum($item-group/http:response/@spent-millis ! (. cast as xs:integer))}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
        }
    </div>