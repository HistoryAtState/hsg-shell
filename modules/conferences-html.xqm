xquery version "3.0";

module namespace conferences = "http://history.state.gov/ns/site/hsg/conferences-html";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $conferences:CONFERENCES_COL := '/db/apps/conferences';
declare variable $conferences:CONFERENCES_DATA_COL := $conferences:CONFERENCES_COL || '/data';

declare function conferences:conference-title($node, $model, $conference-id as xs:string) {
    let $doc := doc($conferences:CONFERENCES_DATA_COL || '/' || $conference-id || '.xml')
    let $title := $doc//tei:title[@type='complete']/string()
    return
        $title
};

declare function conferences:conference-intro($node, $model, $conference-id as xs:string) {
    let $doc := doc($conferences:CONFERENCES_DATA_COL || '/' || $conference-id || '.xml')
    let $text := ($doc//tei:div[@xml:id])[1]
    return
        pages:process-content($config:odd, $text)
};

declare function conferences:article-title($node, $model, $conference-id as xs:string, $section-id as xs:string) {
    let $doc := doc($conferences:CONFERENCES_DATA_COL || '/' || $chapter-id || '.xml')
    let $title := $doc//tei:title[@type='complete']/string()
    return
        $title
};

declare function conferences:article($node, $model, $conference-id as xs:string, $section-id as xs:string) {
    let $doc := doc($conferences:CONFERENCES_DATA_COL || '/' || $chapter-id || '.xml')
    let $text := $doc/id($section-id)
    return
        pages:process-content($config:odd, $text)
};