(:~
 : This is the main XQuery which will (by default) be called by controller.xql
 : to process any URI ending with ".html". It receives the HTML from
 : the controller and passes it to the templating system.
 :)
xquery version "3.1";

import module namespace templates="http://exist-db.org/xquery/html-templating" ;

(:
 : The following modules provide functions which will be called by the
 : templating.
 :)
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace archives="http://history.state.gov/ns/site/hsg/archives-html" at "archives-html.xqm";
import module namespace countries="http://history.state.gov/ns/site/hsg/countries-html" at "countries-html.xqm";
import module namespace edu="http://history.state.gov/ns/site/hsg/education-html" at "education-html.xqm";
import module namespace frus="http://history.state.gov/ns/site/hsg/frus-html" at "frus-html.xqm";
import module namespace frus-history="http://history.state.gov/ns/site/hsg/frus-history-html" at "frus-history-html.xqm";
import module namespace milestones="http://history.state.gov/ns/site/hsg/milestones-html" at "milestones-html.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";
import module namespace pocom="http://history.state.gov/ns/site/hsg/pocom-html" at "pocom-html.xqm";
import module namespace search="http://history.state.gov/ns/site/hsg/search" at "search.xqm";
import module namespace serial-set="http://history.state.gov/ns/site/hsg/serial-set-html" at "serial-set-html.xqm";
import module namespace tags="http://history.state.gov/ns/site/hsg/tags-html" at "tags-html.xqm";
import module namespace travels="http://history.state.gov/ns/site/hsg/travels-html" at "travels-html.xqm";
import module namespace toc="http://history.state.gov/ns/site/hsg/frus-toc-html" at "frus-toc-html.xqm";
import module namespace visits="http://history.state.gov/ns/site/hsg/visits-html" at "visits-html.xqm";
import module namespace news="http://history.state.gov/ns/site/hsg/news" at "news.xqm";
import module namespace pagination="http://history.state.gov/ns/site/hsg/pagination" at "pagination.xqm";
import module namespace link="http://history.state.gov/ns/site/hsg/link" at "link.xqm";
import module namespace side = "http://history.state.gov/ns/site/hsg/sidebar" at "sidebar.xqm";
import module namespace fm="http://history.state.gov/ns/site/hsg/frus-meta" at "frus-meta.xqm";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html";
declare option output:html-version "5";
(: This does not seem to have an effect! :)
declare option output:indent "no";
declare option output:media-type "text/html";

let $publication-id := request:get-parameter('publication-id',())
let $document-id := request:get-parameter('document-id',())
let $section-id := request:get-parameter('section-id',())

let $publication-config := ($config:PUBLICATIONS?($publication-id), map{})[1]
let $created := app:created($publication-config, $document-id, $section-id)
let $last-modified := app:last-modified($publication-config, $document-id, $section-id)
let $not-modified-since := app:modified-since($last-modified, app:safe-parse-if-modified-since-header())

return 
    if ($not-modified-since) then (
        (: if the "If-Modified-Since" header in the client request is later than the
         : last-modified date, then halt further processing of the templates and simply
         : return a 304 response. :)
        response:set-status-code(304),
        app:set-last-modified($last-modified)
    ) else if (request:get-parameter('x-method', ()) eq 'head') then (
        (: When revalidating a cached resource and the "If-Modified-Since" header sent by the client indicates
         : the resource has changed in the meantime, it is just a head request. Do not render the page as the 
         : response body is discarded anyway and just return status code 200. :)
        response:set-status-code(200),
        app:set-last-modified($last-modified)
    ) else (
        (:
         : The HTML is passed in the request from the controller.
         : Run it through the templating system and return the result.
         :)
        templates:apply(
            request:get-data(),
            (:
             : We have to provide a lookup function to templates:apply to help it
             : find functions in the imported application modules. The templates
             : module cannot see the application modules, but the inline function
             : below does see them.
             :)
            function($function-name as xs:string, $arity as xs:integer) as function(*)? {
                function-lookup(xs:QName($function-name), $arity)
            },
            (),
            map {
                $templates:CONFIG_APP_ROOT : $config:app-root,
                $templates:CONFIG_STOP_ON_ERROR : true(),
                $templates:CONFIG_FILTER_ATTRIBUTES : true()
            }
        ),
        (: only set last-modified if rendering was succesful :)
        app:set-last-modified($last-modified),
        app:set-created($created)
    )