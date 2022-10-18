(:~
 : This is the main XQuery which will (by default) be called by controller.xql
 : to process any URI ending with ".html". It receives the HTML from
 : the controller and passes it to the templating system.
 :)
xquery version "3.0";

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
import module namespace fm="http://history.state.gov/ns/site/hsg/frus-meta" at "frus-meta.xqm";
import module namespace link="http://history.state.gov/ns/site/hsg/link" at "link.xqm";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";

let $config := map {
    $templates:CONFIG_APP_ROOT : $config:app-root,
    $templates:CONFIG_STOP_ON_ERROR : true()
}
(:
 : We have to provide a lookup function to templates:apply to help it
 : find functions in the imported application modules. The templates
 : module cannot see the application modules, but the inline function
 : below does see them.
 :)
let $lookup := function($functionName as xs:string, $arity as xs:int) {
    try {
        function-lookup(xs:QName($functionName), $arity)
    } catch * {
        ()
    }
}
(:
 : The HTML is passed in the request from the controller.
 : Run it through the templating system and return the result.
 :)
let $content := request:get-data()
return
    (
        templates:apply($content, $lookup, (), $config),
        let $last-modified := request:get-attribute("hsgshell.last-modified")
        let $created := request:get-attribute("hsgshell.created")
        return
            if (exists($last-modified) and exists($created)) then
                (
                    app:set-last-modified($last-modified),
                    app:set-created($created)
                )
            else
                ()
    )