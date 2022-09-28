xquery version "3.1";

(:
 : Module for handling of frus bibliographies
 :)
module namespace fm = "http://history.state.gov/ns/site/hsg/frus-meta";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace frus="http://history.state.gov/ns/site/hsg/frus-html" at "frus-html.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function fm:init-frus-list($node, $model) {};