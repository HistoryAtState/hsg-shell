xquery version "3.1";

(:
 : Module for handling of frus bibliographies
 :)
module namespace fb = "http://history.state.gov/ns/site/hsg/frus-bib";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";