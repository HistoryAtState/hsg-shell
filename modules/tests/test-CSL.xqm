xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-CSL";

import module namespace config="http://history.state.gov/ns/site/hsg/config" at "../config.xqm";
import module namespace templates="http://exist-db.org/xquery/templates";

declare namespace test="http://exist-db.org/xquery/xqsuite";
declare namespace  tei="http://www.tei-c.org/ns/1.0";

declare variable $x:frus.section.citation := parse-json(concat('
    {
        "id": "/historicaldocuments/frus1969-76v19p1/d75",
        "type": "chapter",
        "collection-number": "1969–1976",
        "collection-title": "Foreign Relations of the United States",
        "container-title": "Korea, 1969–1972",
        "page": "Document 75",
        "publisher": "Office of the Historian",
        "title": "Document 75",
        "URL": "https://history.state.gov/historicaldocuments/frus1969-76v19p1/d75",
        "volume": "Volume XIX, Part 1",
        "ISBN":   "9780160771088",
        "editor": [
            {
            	"family": "Lawler",
            	"given": "Daniel J."
            },
            {
            	"family": "Mahan",
            	"given": "Erin R."
            }
        ],
        "accessed": {
            "date-parts": [
            	[
                    ',year-from-date(current-date()),',
                    ',month-from-date(current-date()),',
                    ',day-from-date(current-date()),'
            	]
            ]
        },
        "issued": {
            "raw": "2009"
        }
    }
'));

declare variable $x:frus.doc := doc('/db/apps/hsg-shell/tests/data/citations/frus.doc.xml');

(:
 :  WHEN running template function app:CSL-json
 :  GIVEN a model including the CSL-json:
 :      [
 :      	{
 :      		"id": "/about/contact-us",
 :      		"type": "webpage",
 :      		"container-title": "Office of the Historian",
 :      		"title": "Contact Us"
 :      	}
 :      ]
 :  THEN serialise the json and output it.
 :)
declare %test:assertEquals('true') function x:test-embed-csl-json(){
    let $node := 
        <script type="application/json" id="original_citation" data-template="config:csl-json"/>
    let $citation-meta := 
        map {
            "id":               "/about/contact-us",
            "type":             "webpage",
            "container-title":  "Office of the Historian",
            "title":            "Contact Us"
        }
    let $config := map{
        $templates:CONFIG_FN_RESOLVER : function($functionName as xs:string, $arity as xs:int) {
            try {
                function-lookup(xs:QName($functionName), $arity)
            } catch * {
                ()
            }
        },
        $templates:CONFIG_PARAM_RESOLVER : map{}
    }
    let $model := map {
        $templates:CONFIGURATION : $config,
        "citation-meta": $citation-meta
    }
    let $expected :=
        <script type="application/json" id="original_citation" data-template="config:csl-json">[{{"id":"/about/contact-us","type":"webpage","container-title":"Office of the Historian","title":"Contact Us"}}]</script>
    let $result := templates:process($node, $model)
    return if (deep-equal($expected, $result)) 
    then 'true'
    else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

(:
 :  WHEN transforming CLS-json to HTML embedded metadata (config:cls-to-html)
 :  GIVEN the CLS-json $json
 :  THEN produce $expected
 :)
declare %test:assertEquals('true') function x:test-cls-to-html(){
    let $json := array { $x:frus.section.citation }
    let $expected := 
        let $ex.metas as element(meta)* :=
            (
                <meta name="DC.type" content="bookSection"/>,
                <meta name="citation_series_number" content="1969–1976"/>,
                <meta name="citation_series_title" content="Foreign Relations of the United States"/>,
                <meta name="citation_book_title" content="Korea, 1969–1972"/>,
                <meta name="citation_firstpage" content="Document 75"/>,
                <meta name="citation_publisher" content="Office of the Historian"/>,
                <meta name="citation_title" content="Document 75"/>,
                <meta name="citation_public_url" content="https://history.state.gov/historicaldocuments/frus1969-76v19p1/d75"/>,
                <meta name="citation_volume" content="Volume XIX, Part 1"/>,
                <meta name="citation_editor" content="Daniel J. Lawler"/>,
                <meta name="citation_editor" content="Erin R. Mahan"/>,
                <meta name="accessDate" content="{format-date(current-date(), '[Y0001]-[M01]-[D01]')}"/>,
                <meta name="citation_date" content="2009"/>,
                <meta name="citation_isbn" content="9780160771088"/>
            )
        for $ex.meta in $ex.metas
        order by $ex.meta/@name, $ex.meta/@content (: order both expected and actual result to allow comparison :)
        return $ex.meta
    let $result := 
        let $r.metas as element(meta)* := config:cls-to-html($json)
        for $r.meta in $r.metas
        order by $r.meta/@name, $r.meta/@content   (: order both expected and actual result to allow comparison :)
        return $r.meta
    return if (deep-equal($expected, $result)) 
    then 'true'
    else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

declare %test:assertEquals('true') function x:test-generate-cls-frus-section(){
    let $model := map{
        'publication-id': 'frus',
        'document-id':  'frus1969-76v19p1',
        'section-id':   'd75',
        'local-uri':    '/historicaldocuments/frus1969-76v19p1/d75',
        'url':    'https://history.state.gov/historicaldocuments/frus1969-76v19p1/d75'
    }
    let $expected := $x:frus.section.citation
    let $result := config:tei-section-citation-meta((), $model)
    return if (deep-equal($expected, $result)) 
    then 'true'
    else (<result>{serialize($result, map{'method':'adaptive', 'indent':true()})}</result>, <expected>{serialize($expected, map{'method': 'adaptive', 'indent': true()})}</expected>)
};
