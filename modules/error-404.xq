xquery version "3.1";

import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";
import module namespace link="http://history.state.gov/ns/site/hsg/link" at "link.xqm";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html";
declare option output:html-version "5";
declare option output:media-type "text/html";

templates:apply(
    doc('/db/apps/hsg-shell/pages/error-page-404.xml'),
    function($functionName as xs:string, $arity as xs:integer) {
        function-lookup(xs:QName($functionName), $arity)
    },
    (),
    map {
        $templates:CONFIG_APP_ROOT : $config:app-root,
        $templates:CONFIG_STOP_ON_ERROR : true()
    }
)
