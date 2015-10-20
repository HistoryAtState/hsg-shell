xquery version "3.0";

module namespace fhh = "http://history.state.gov/ns/site/hsg/frus-history-html";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";
import module namespace toc="http://history.state.gov/ns/site/hsg/frus-toc-html" at "frus-toc-html.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $fhh:FRUS_HISTORY_COL := '/db/apps/frus-history';
declare variable $fhh:FRUS_HISTORY_ARTICLES_COL := $fhh:FRUS_HISTORY_COL || '/articles';
declare variable $fhh:FRUS_HISTORY_DOCUMENTS_COL := $fhh:FRUS_HISTORY_COL || '/documents';
declare variable $fhh:FRUS_HISTORY_MONOGRAPH_COL := $fhh:FRUS_HISTORY_COL || '/monograph';

declare function fhh:monograph-title($node, $model) {
    let $doc := doc($fhh:FRUS_HISTORY_MONOGRAPH_COL || '/frus-history.xml')
    let $title := pages:process-content($config:odd, $doc//tei:title[@type='complete'])
    return
        $title
};

declare function fhh:monograph-editors($node, $model) {
    let $doc := doc($fhh:FRUS_HISTORY_MONOGRAPH_COL || '/frus-history.xml')
    let $editors := $doc//tei:titlePage//tei:name
    return
        <ul>
            {
                $editors ! <li>{./string()}</li>                    
            }
        </ul>
};

declare function fhh:monograph-edition-info($node, $model) {
    let $doc := doc($fhh:FRUS_HISTORY_MONOGRAPH_COL || '/frus-history.xml')
    let $edition-info := 
        (
        $doc//tei:fileDesc//tei:publisher,
        $doc//tei:fileDesc//tei:pubPlace,
        $doc//tei:fileDesc//tei:sourceDesc/tei:p
        )
    return
        <ul>
            {
                $edition-info ! <li>{./string()}</li>                    
            }
        </ul>
};

declare function fhh:monograph-toc($node, $model) {
    let $doc := doc($fhh:FRUS_HISTORY_MONOGRAPH_COL || '/frus-history.xml')
    let $toc := toc:toc-passthru($doc, ())
    return
        <div class="toc"><ul>{$toc}</ul></div>
};