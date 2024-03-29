xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-pages";
import module namespace t="http://history.state.gov/ns/site/hsg/xqsuite" at "../xqsuite.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "../pages.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "../config.xqm";
import module namespace templates="http://exist-db.org/xquery/html-templating";

declare namespace test="http://exist-db.org/xquery/xqsuite";
declare namespace tei="http://www.tei-c.org/ns/1.0";


(:
# Testing plan for pages:load

## Should add default open graph map and keys to $model if none are provided, and there is no static Open Graph

- WHEN HTML templating function pages:load is called
  - GIVEN no static Open Graph data in $node//*
    AND no Open Graph keys
    - THEN return the default set of keys from $config:OPEN_GRAPH_KEYS as $new-model?open-graph-keys
:)

declare
    %test:pending('Awaiting NPE resolution - TFJH')
    %test:assertEquals('og:type twitter:card twitter:site og:site_name og:title og:description og:image og:url citation')
function x:pages-load-add-default-open-graph-keys() {
    let $node := <div data-template="pages:load"><span data-template="t:return-model"/></div>
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
        $templates:CONFIGURATION : $config
    }
    let $new-model := pages:load($node, $model, "frus", (), (), "div", false(), (), (), ())()

    return $new-model?open-graph-keys => string-join(' ')
};

(:
## Static Open Graph properties should replace corresponding entries in the open graph map

- WHEN HTML templating function pages:load is called
  - GIVEN a static Open Graph entry in $node//div[@id eq 'static-open-graph']/meta
    AND @property 'og:description'
    AND @content 'Custom hard-coded description goes here.'
    AND no Open Graph keys
    - THEN return $new-model?open-graph?og:description as a function which returns'Custom hard-coded description goes here.'
:)

declare
    %test:pending('Awaiting NPE resolution - TFJH')
    %test:assertEquals('<meta property="og:description" content="Custom hard-coded description goes here"/>')
function x:pages-load-add-open-graph-static() {
    let $node :=
        <div data-template="pages:load">
            <div id="static-open-graph" data-template="pages:suppress">
                <meta property="og:description" content="Custom hard-coded description goes here"/>
            </div>
            <div data-template="t:return-model"/>
        </div>
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
        $templates:CONFIGURATION : $config
    }
    let $new-model := pages:load($node, $model, "frus", (), (), "div", false(), (), (), ())()

    return $new-model?open-graph?("og:description")((),())
};

(:
## Static Open Graph properties should add their keys to open-graph-keys

- WHEN HTML templating function pages:load is called
  - GIVEN a static Open Graph entry in $node//div[@id eq 'static-open-graph']/meta
    AND @property 'made:up'
    AND @content 'value'
    AND no Open Graph keys
    - THEN return $new-model?open-graph-keys including 'made:up'
:)

declare
    %test:pending('Awaiting NPE resolution - TFJH')
    %test:assertEquals('made:up og:type twitter:card twitter:site og:site_name og:title og:description og:image og:url citation')
function x:pages-load-add-open-graph-keys-static() {
    let $node :=
        <div data-template="pages:load">
            <div id="static-open-graph" data-template="pages:suppress">
                <meta property="made:up" content="value"/>
            </div>
            <div data-template="t:return-model"/>
        </div>
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
        $templates:CONFIGURATION : $config
    }
    let $new-model := pages:load($node, $model, "frus", (), (), "div", false(), (), (), ())()

    return $new-model?open-graph-keys => string-join(' ')
};

(:
## Should replace open graph keys with $open-graph-keys tokens

- WHEN HTML templating function pages:load is called
  - GIVEN no static Open Graph data in $node//*
    AND Open Graph keys specified by the @data-template-open-graph-keys template parameter
    - THEN return the specified set of keys as $new-model?open-graph-keys
:)

declare
    %test:pending('Awaiting NPE resolution - TFJH')
    %test:assertEquals('og:type og:description')
function x:pages-load-add-open-graph-keys() {
    let $node := <div data-template="pages:load"><span data-template="t:return-model"/></div>
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
        $templates:CONFIGURATION : $config
    }
    let $new-model := pages:load($node, $model, "frus", (), (), "div", false(), "og:type og:description", (), ())()

    return $new-model?open-graph-keys => string-join(' ')
};

(:
## Should remove open graph keys corresponding to $open-graph-keys-exclude

- WHEN HTML templating function pages:load is called
  - GIVEN no static Open Graph data in $node//*
    AND no Open Graph keys
    AND Open Graph keys specified by the @data-template-open-graph-keys-exclude template parameter
    - THEN return the the default set of keys from $config:OPEN_GRAPH_KEYS excluding the sepcified keys as $new-model?open-graph-keys
:)

declare
    %test:pending('Awaiting NPE resolution - TFJH')
    %test:assertEquals('twitter:card twitter:site og:site_name og:title og:image og:url')
function x:pages-load-add-open-graph-keys-exclude() {
    let $node := <div data-template="pages:load"><span data-template="t:return-model"/></div>
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
        $templates:CONFIGURATION : $config
    }
    let $new-model := pages:load($node, $model, "frus", (), (), "div", false(), (), "og:type og:description citation", ())()

    return $new-model?open-graph-keys => string-join(' ')
};

(:
## Should add new open graph keys with $open-graph-keys-add

- WHEN HTML templating function pages:load is called
  - GIVEN no static Open Graph data in $node//*
    AND no Open Graph keys
    AND Open Graph keys specified by the @data-template-open-graph-keys-add template parameter ("made:up")
    - THEN return the the default set of keys from $config:OPEN_GRAPH_KEYS in addition to the sepcified keys as $new-model?open-graph-keys
:)

declare
    %test:pending('Awaiting NPE resolution - TFJH')
    %test:assertEquals('made:up og:type twitter:card twitter:site og:site_name og:title og:description og:image og:url citation')
function x:pages-load-add-open-graph-keys-add() {
    let $node := <div data-template="pages:load"><span data-template="t:return-model"/></div>
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
        $templates:CONFIGURATION : $config
    }
    let $new-model := pages:load($node, $model, "frus", (), (), "div", false(), (), (), "made:up")()

    return $new-model?open-graph-keys => string-join(' ')
};

(:
## Should replace $open-graph-keys-exclude tokens in supplied $open-graph-keys with $open-graph-keys-add

- WHEN HTML templating function pages:load is called
  - GIVEN no static Open Graph data in $node//*
    AND a set of Open Graph keys specified by the $open-graph-keys template parameter
    AND a set of Open Graph keys specified by the $open
    AND Open Graph keys specified by the @data-template-open-graph-keys-add template parameter
    - THEN the set of keys is returned as $new-model?open-graph-keys
      AND that set of keys includes the $graph-keys keys except for those specified
:)

declare
    %test:pending('Awaiting NPE resolution - TFJH')
    %test:assertEquals('made:up twitter:card')
function x:pages-load-add-open-graph-keys-replace() {
    let $node := <div data-template="pages:load"><span data-template="t:return-model"/></div>
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
        $templates:CONFIGURATION : $config
    }
    let $new-model := pages:load($node, $model, "frus", (), (), "div", false(), "og:type twitter:card", "og:type", "made:up")()

    return $new-model?open-graph-keys => string-join(' ')
};

(:
# Test Plan for generate-title()

- WHEN calling generate-title()
  - GIVEN no other title information
    - Then return "Office of the Historian"
:)

declare %test:assertEquals('Office of the Historian') function x:generate-title-default() {
    let $model := map {}
    let $content := ()
    return pages:generate-title($model, $content)
};

(:
  - GIVEN a title 'frus' and head 'head'
    - Then return "head - Historical Documents - Office of the Historian"
:)

declare %test:assertEquals('head - Historical Documents - Office of the Historian') function x:generate-title-with-head() {
    let $model := map {
        "publication-id": "frus",
        "section-id": "x",
        "data": <tei:div><tei:head>head</tei:head></tei:div>
    }
    let $content := ()
    return pages:generate-title($model, $content)
};

(:

# Test Plan for generate-short-title()

- WHEN calling generate-short-title()

  - GIVEN empty argments
    - THEN return "Office of the Historian"
:)

declare %test:assertEquals("Office of the Historian") function x:generate-short-title-default() {
    pages:generate-short-title((),())
};

(:
  - GIVEN an empty HTML h1 heading "H1", ($node//h1))[1] = "" //Empty String
    - THEN return "Office of the Historian"
:)

declare %test:assertEquals("Office of the Historian") function x:generate-short-title-empty-H1() {
    let $node :=
        (<div>
            <h1/>
            <p>Not a title</p>
        </div>)
    return pages:generate-short-title($node, ())
};

(:
  - GIVEN a HTML h1 heading "H1", ($node//h1))[1] = "H1"
    - THEN return "H1"
:)

declare %test:assertEquals("H1") function x:generate-short-title-H1() {
    let $node :=
        <div>
            <h1>H1</h1>
            <p>Not a title</p>
        </div>
    return pages:generate-short-title($node, ())
};

(:
- GIVEN a HTML h2 heading "H2", ($node//h2))[1] = "H2"
    - THEN return "H2"
:)

declare %test:assertEquals("H2") function x:generate-short-title-H2(){
    let $node :=
        <div>
            <h2>H2</h2>
            <p>Not a title</p>
            <h1>H1</h1>
        </div>
    return pages:generate-short-title($node, ())
};

(:
  - GIVEN a HTML h3 heading "H3", ($node//h3))[1] = "H3"
    - THEN return "H3"
:)

declare %test:assertEquals("H3") function x:generate-short-title-H3(){
    let $node :=
        <div>
            <h3>H3</h3>
            <p>Not a title</p>
            <h1>H1</h1>
        </div>
    return pages:generate-short-title($node, ())
};

(:
  - GIVEN an empty HTML h2 heading "H2", ($node//h2))[1] = "" //Empty String
    AND a following HTML h1 heading "H1", ($node//h1))[1] = "H1"
    - THEN return "H1"
:)

declare %test:assertEquals("H1") function x:generate-short-title-H1-after-empty-H2(){
    let $node :=
        <div>
            <h2/>
            <p>Not a title</p>
            <h1>H1</h1>
        </div>
    return pages:generate-short-title($node, ())
};

(:
  - GIVEN a publication ID, $model?publication-id = "articles", with no associated title,  map:get($config:PUBLICATIONS, $model?publication-id)?title = ()
    AND a HTML h3 heading "H3", ($node//h3))[1] = "H3"
    - THEN return "H3"
:)

declare %test:assertEquals("H3") function x:generate-short-title-empty-publication-ID() {
    let $node  := <div><h3>H3</h3></div>
    let $model := map { "publication-id": "articles"}
    return pages:generate-short-title($node, $model)
};

(:
  - GIVEN a publication ID, $model?publication-id = "frus", with an associated title,  map:get($config:PUBLICATIONS, $model?publication-id)?title = "Historical Documents"
    AND a HTML h3 heading "H3", ($node//h3))[1] = "H3"
    - THEN return "Historical Documents"
:)

declare %test:assertEquals("Historical Documents") function x:generate-short-title-publication-ID() {
    let $node  := <div><h3>H3</h3></div>
    let $model := map { "publication-id": "frus"}
    return pages:generate-short-title($node, $model)
};

(:
  - GIVEN an empty static title, ($node//h1))[1] = "" //Empty String
    AND a publication ID with an associated title, $model?publication-id = "frus"
    - THEN return "Historical Documents"
:)

declare %test:assertEquals("Historical Documents") function x:generate-short-title-empty-static() {
    let $node  := <div><div id="static-title"></div></div>
    let $model := map { "publication-id": "frus"}
    return pages:generate-short-title($node, $model)
};

(:
  - GIVEN a Static title "Static", $node/ancestor::*[last()]//div[@id="static-title"]/string() = "Static"
    AND a publication ID with an associated title, $model?publication-id = "frus"
    - THEN return "Static"
:)

declare %test:assertEquals("Static") function x:generate-short-title-static() {
    let $node  := <div><div id="static-title">Static</div></div>
    let $model := map { "publication-id": "frus"}
    return pages:generate-short-title($node, $model)
};

(:
# Test plan for pages:app-root

- WHEN calling pages:app-root($node, $model)
  - GIVEN a node with a static title 'Static'
    - THEN return a $new-node/head/title = 'Static'
:)

declare %test:assertEquals("Static - Office of the Historian") function x:app-root-static() {
    let $node := <div><div id="static-title">Static</div></div>
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
        $templates:CONFIGURATION : $config
    }
    return pages:app-root($node, $model)/head/title/string()
};

(:

- WHEN calling pages:app-root($node, $model)
  - GIVEN a node with a H1 heading 'H1'
    - THEN return 'H1'
:)

declare %test:assertEquals("H1 - Office of the Historian") function x:app-root-h1() {
    let $node := <div><h1>H1</h1></div>
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
        $templates:CONFIGURATION : $config
    }
    return pages:app-root($node, $model)/head/title/string()
};

(:
# Test plans for breadcrumbs

For the purpose of these tests, $app refers to the URI root of the hsg-shell app.

Test data generator: :)

declare function x:generate-breadcrumb-test-data($url as xs:string){
    let $data := map{
        '/about': [
            <span>Home</span>,
            <span>About</span>
        ],
        '/historicaldocuments/about-frus': [
            <span>Home</span>,
            <span>Historical Documents</span>,
            <span>About the <em>Foreign Relations</em> Series</span>
        ],
        '/about/faq/what-is-frus': [
            <span>Home</span>,
            <span>About</span>,
            <span>Frequently Asked Questions</span>,
            <span>Where can I find information about the Foreign...</span>
        ],
        '/about/hac/members': [
            <span>Home</span>,
            <span>About</span>,
            <span>Historical Advisory Committee</span>,
            <span>Members</span>
        ],
        '/conferences/2011-foreign-economic-policy/panel': [
            <span>Home</span>,
            <span>Conferences</span>,
            <span>Foreign Economic Policy, 1973-1976</span>,
            <span>Panel Discussion</span>
        ],
        '/countries/mali': [
            <span>Home</span>,
            <span>Countries</span>,
            <span>A Guide to the United States’ History of Recognition, Diplomatic, and Consular Relations, by Country, since 1776: Mali</span>
        ],
        '/countries/issues/italian-unification': [
            <span>Home</span>,
            <span>Countries</span>,
            <span>Issues</span>,
            <span>Issues Relevant to U.S. Foreign Diplomacy: Unification of Italian States</span>
        ],
        '/countries/archives/angola': [
            <span>Home</span>,
            <span>Countries</span>,
            <span>Archives</span>,
            <span>World Wide Diplomatic Archives Index: Angola</span>
        ],
        '/departmenthistory/buildings/intro': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>Buildings of the Department</span>,
            <span>Introduction</span>
        ],
        '/departmenthistory/people/hilsman-roger-jr': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>People</span>,
            <span>Roger Hilsman Jr.</span>
        ],
        '/departmenthistory/people/by-name/t': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>People</span>,
            <span>By Name</span>,
            <span>Starting with T</span>
        ],
        '/departmenthistory/people/by-year/1979': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>People</span>,
            <span>By Year</span>,
            <span>1979</span>
        ],
        '/departmenthistory/people/chiefsofmission/fiji': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>People</span>,
            <span>Chiefs of Mission</span>,
            <span>Fiji</span>
        ],
        '/departmenthistory/people/chiefsofmission/representative-to-au': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>People</span>,
            <span>Chiefs of Mission</span>,
            <span>Representatives of the U.S.A. to the African Union</span>
        ],
        '/departmenthistory/people/principalofficers/secretary': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>People</span>,
            <span>Principal Officers By Title</span>,
            <span>Secretaries of State</span>
        ],
        '/departmenthistory/short-history/superpowers': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>Short History</span>,
            <span>Superpowers Collide, 1961-1981</span>
        ],
        '/departmenthistory/short-history/cubanmissile': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>Short History</span>,
            <span>The Cuban Missile Crises</span>
        ],
        '/departmenthistory/timeline/1970-1979': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>Administrative Timeline</span>,
            <span>1970–1979</span>
        ],
        '/departmenthistory/travels/president/taft-william-howard': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>Presidential and Secretaries Travels Abroad</span>,
            <span>Travels of the President</span>,
            <span>William Howard Taft</span>
        ],
        '/departmenthistory/travels/president/laos': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>Presidential and Secretaries Travels Abroad</span>,
            <span>Travels of the President</span>,
            <span>Laos</span>
        ],
        '/departmenthistory/travels/secretary/root-elihu': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>Presidential and Secretaries Travels Abroad</span>,
            <span>Travels of the Secretary</span>,
            <span>Elihu Root</span>
        ],
        '/departmenthistory/travels/secretary/laos': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>Presidential and Secretaries Travels Abroad</span>,
            <span>Travels of the Secretary</span>,
            <span>Laos</span>
        ],
        '/departmenthistory/visits/cuba': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>Visits by Foreign Leaders</span>,
            <span>Cuba</span>
        ],
        '/departmenthistory/visits/1979': [
            <span>Home</span>,
            <span>Department History</span>,
            <span>Visits by Foreign Leaders</span>,
            <span>1979</span>
        ],
        '/education/modules/history-diplomacy-intro': [
            <span>Home</span>,
            <span>Education</span>,
            <span>Curriculum Modules</span>,
            <span>Introduction to Curriculum Packet on “A History of Diplomacy”</span>
        ],
        '/historicaldocuments/wilson': [
            <span>Home</span>,
            <span>Historical Documents</span>,
            <span>Woodrow Wilson Administration (1913–1921)</span>
        ],
        '/historicaldocuments/frus1981-88v11/persons': [
            <span>Home</span>,
            <span>Historical Documents</span>,
            <span>Foreign Relations of the United States, 1981–1988, Volume XI, START I</span>,
            <span>Persons</span>
        ],
        '/historicaldocuments/frus1894/ch25': [
            <span>Home</span>,
            <span>Historical Documents</span>,
            <span>Papers Relating to the Foreign Relations of the United States, 1894, With the Annual Message of the President, Transmitted to Congress, December 3, 1894</span>,
            <span>Friendly offices to Japanese in China</span>
        ],
        '/historicaldocuments/frus1952-54v07p1/d379': [
            <span>Home</span>,
            <span>Historical Documents</span>,
            <span>Foreign Relations of the United States, 1952–1954, Germany and Austria, Volume VII, Part 1</span>,
            <span>Document 379</span>
        ],
        '/historicaldocuments/frus-history/foreword': [
            <span>Home</span>,
            <span>Historical Documents</span>,
            <span>History of the <em>Foreign Relations</em> Series</span>,
            <span>Foreword</span>
        ],
        '/historicaldocuments/frus-history/documents/2002-08-19-athens-02867': [
            <span>Home</span>,
            <span>Historical Documents</span>,
            <span>History of the <em>Foreign Relations</em> Series</span>,
            <span>Documents</span>,
            <span>Telegram From Embassy Athens, 2002</span>
        ],
        '/historicaldocuments/frus-history/research/a-good-years-work': [
            <span>Home</span>,
            <span>Historical Documents</span>,
            <span>History of the <em>Foreign Relations</em> Series</span>,
            <span>Research</span>,
            <span>A Good Year’s Work</span>
        ],
        '/historicaldocuments/pre-1861/serial-set/browse?region=Europe': [
            <span>Home</span>,
            <span>Historical Documents</span>,
            <span>Pre-1861 U.S. foreign relations materials</span>,
            <span>U.S. foreign relations materials in the pre-1861 U.S. Congressional Serial Set</span>,
            <span>Europe</span>
        ],
        '/historicaldocuments/pre-1861/serial-set/browse?region=Europe&amp;subject=France': [
            <span>Home</span>,
            <span>Historical Documents</span>,
            <span>Pre-1861 U.S. foreign relations materials</span>,
            <span>U.S. foreign relations materials in the pre-1861 U.S. Congressional Serial Set</span>,
            <span>France</span>
        ],
        '/milestones/1977-1980': [
            <span>Home</span>,
            <span>Milestones</span>,
            <span>1977-1980</span>
        ],
        '/milestones/1977-1980/china-policy': [
            <span>Home</span>,
            <span>Milestones</span>,
            <span>1977-1980</span>,
            <span>China Policy</span>
        ],
        '/tags/clay-henry': [
            <span>Home</span>,
            <span>Tags</span>,
            <span>Clay, Henry</span>
        ]
    }
    let $url-tokens as xs:string* := tokenize($url, '/')
    return 
         <nav class="hsg-breadcrumb hsg-breadcrumb--wrap" aria-label="breadcrumbs">
            <ol vocab="http://schema.org/" typeof="BreadcrumbList" class="hsg-breadcrumb__list">
                {
                    for $i in (1 to count($url-tokens))
                    let $href := '/exist/apps/hsg-shell/' || string-join($url-tokens[position() le $i][. ne ''], '/')
                    let $span := $data?($url)?($i)
                    return
                    <li class="hsg-breadcrumb__list-item" property="itemListElement" typeof="ListItem">
                        <a href="{$href}" class="hsg-breadcrumb__link" property="item" typeof="WebPage">
                            {
                                if ($i eq count($url-tokens))
                                then attribute aria-current {'page'}
                                else (),
                                $span
                            }
                        </a>
                    </li>
                }
            </ol>
         </nav>
};

(:

## Page template about/index.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/about`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `About`:      `$app/about`
:)

declare
  %test:assertEquals('true')
function x:test-pages-breadcrumb-about() {
  let $result := pages:generate-breadcrumbs('/about')
  let $expected := x:generate-breadcrumb-test-data('/about')
  return if (deep-equal($expected, $result)) 
  then 'true' 
  else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

(: Test results with mixed content (em elements) :)

declare %test:assertEquals('true')
function x:test-pages-breadcrumb-with-elements() {
  let $result := pages:generate-breadcrumbs('/historicaldocuments/about-frus')
  let $expected := x:generate-breadcrumb-test-data('/historicaldocuments/about-frus')
  return if (deep-equal($expected, $result)) 
  then 'true' 
  else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

(:

#### Page template about/faq/section.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/about/faq/what-is-frus`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `About`:      `$app/about`
      `Frequently Asked Questions`: `$app/about/faq`
      `Where can I find information about the Foreign...`: `$app/about/faq/what-is-frus`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-faq-section(){
  let $expected := x:generate-breadcrumb-test-data('/about/faq/what-is-frus')
  let $result := pages:generate-breadcrumbs('/about/faq/what-is-frus')
  return if (deep-equal($expected, $result)) 
  then 'true' 
  else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

(:
#### Page template about/hac/section.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/about/hac/members`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `About`:      `$app/about`
      `Historical Advisory Committee`:  `$app/about/hac`
      `Members`:    `/about/hac/members`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-hac-section(){
  let $expected as element(nav) := x:generate-breadcrumb-test-data('/about/hac/members')
  let $result := pages:generate-breadcrumbs('/about/hac/members')
  return if (deep-equal($expected, $result)) 
  then 'true' 
  else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

(:

#### Page template conferences/conference/section.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/conferences/2011-foreign-economic-policy/panel`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Conferences`:    `$app/conferences`
      `Foreign Economic Policy, 1973-1976`: `$app/conferences/2011-foreign-economic-policy`
      `Panel Discussion`:   `$app/conferences/2011-foreign-economic-policy/panel`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-conference-secion(){
  let $expected := x:generate-breadcrumb-test-data('/conferences/2011-foreign-economic-policy/panel')
let $result := pages:generate-breadcrumbs('/conferences/2011-foreign-economic-policy/panel')
  return if (deep-equal($expected, $result)) 
  then 'true' 
  else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

(:

### Page template countries/article.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/countries/mali`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Countries`:  `$app/countries`
      `A Guide to the United States’ History of Recognition, Diplomatic, and Consular Relations, by Country, since 1776: Mali`: `$app/countries/mali`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-country-article(){
  let $expected := x:generate-breadcrumb-test-data('/countries/mali')
  let $result := pages:generate-breadcrumbs('/countries/mali')
  return if (deep-equal($expected, $result)) 
  then 'true' 
  else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

(:
#### Page template countries/issues/article.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/countries/issues/italian-unification`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Countries`:  `$app/countries`
      `Issues`:     `$app/countries/issues`
      `Issues Relevant to U.S. Foreign Diplomacy: Unification of Italian States`:   `$app/countries/issues/italian-unification`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-country-issue-article(){
  let $expected := x:generate-breadcrumb-test-data('/countries/issues/italian-unification')
  let $result := pages:generate-breadcrumbs('/countries/issues/italian-unification')
  return if (deep-equal($expected, $result)) 
  then 'true' 
  else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

(:
#### Page template countries/archives/article.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/countries/archives/angola`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Countries`:  `$app/countries`
      `Archives`:   `$app/countries/archives`
      `World Wide Diplomatic Archives Index: Angola`:   `$app/countries/archives/angola`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-country-archive-article(){
  let $expected := x:generate-breadcrumb-test-data('/countries/archives/angola')
  let $result := pages:generate-breadcrumbs('/countries/archives/angola')
  return if (deep-equal($expected, $result)) 
  then 'true' 
  else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

(:
#### Page template departmenthistory/buildings/section.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/buildings/intro`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Buildings`:  `$app/departmenthistory/buildings`
      `Introduction`: `$app/departmenthistory/buildings/intro`

Note that this page didn't originally include a 'local' permalink breadcrumb.
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-building-section(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/buildings/intro')
  let $result := pages:generate-breadcrumbs('/departmenthistory/buildings/intro')
  return if (deep-equal($expected, $result)) 
  then 'true' 
  else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

(:
#### Page template departmenthistory/people/person.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/people/hilsman-roger-jr`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `People`:     `$app/departmenthistory/people`
      `Roger Hilsman Jr.`:  `$app/departmenthistory/people/hilsman-roger-jr`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-person(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/people/hilsman-roger-jr')
  let $result := pages:generate-breadcrumbs('/departmenthistory/people/hilsman-roger-jr')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:
##### Page template departmenthistory/people/by-name/letter.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/people/by-name/t`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `People`:     `$app/departmenthistory/people`
      `By Name`:    `$app/departmenthistory/people/by-name`
      `Starting with T`:    `$app/departmenthistory/people/by-name/t`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-person-letter(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/people/by-name/t')
  let $result := pages:generate-breadcrumbs('/departmenthistory/people/by-name/t')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:
##### Page template departmenthistory/people/by-year/year.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/people/by-year/1979`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `People`:     `$app/departmenthistory/people`
      `By Year`:    `$app/departmenthistory/people/by-year`
      `1979`:       `$app/departmenthistory/people/by-year/1979`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-person-year(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/people/by-year/1979')
  let $result := pages:generate-breadcrumbs('/departmenthistory/people/by-year/1979')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:

##### Page template departmenthistory/people/chiefsofmission/by-role-or-country-id.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/people/chiefsofmission/fiji`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `People`:     `$app/departmenthistory/people`
      `Chiefs of Mission`:    `$app/departmenthistory/people/chiefsofmission`
      `Fiji`:       `$app/departmenthistory/people/chiefsofmission/fiji`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-person-country(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/people/chiefsofmission/fiji')
  let $result := pages:generate-breadcrumbs('/departmenthistory/people/chiefsofmission/fiji')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:
  - GIVEN a URL `$app/departmenthistory/people/chiefsofmission/representative-to-au`
    -THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `People`:     `$app/departmenthistory/people`
      `Chiefs of Mission`:    `$app/departmenthistory/people/chiefsofmission`
      `Representatives of the U.S.A. to the African Union`: `$app/departmenthistory/people/chiefsofmission/representative-to-au`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-person-org(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/people/chiefsofmission/representative-to-au')
  let $result := pages:generate-breadcrumbs('/departmenthistory/people/chiefsofmission/representative-to-au')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:

##### Page template departmenthistory/people/principalofficers/by-role-id.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/people/principalofficers/secretary`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `People`:     `$app/departmenthistory/people`
      `Principal Officers`:    `$app/departmenthistory`
      `Secretaries of State`:  `$app/departmenthistory/people/principalofficers/secretary`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-pocom-role(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/people/principalofficers/secretary')
  let $result := pages:generate-breadcrumbs('/departmenthistory/people/principalofficers/secretary')
  return if (deep-equal($expected, $result)) 
  then 'true' 
  else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

(:
#### Page template departmenthistory/short-history/section.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/short-history/superpowers`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Short History`:  `$app/departmenthistory/short-history`
      `Superpowers Collide, 1961-1981`: `$app/departmenthistory/short-history/superpowers`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-frus-short-history-section(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/short-history/superpowers')
  let $result := pages:generate-breadcrumbs('/departmenthistory/short-history/superpowers')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:
  - GIVEN a URL `$app/departmenthistory/short-history/cubanmissile`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Short History`:  `$app/departmenthistory/short-history`
      `The Cuban Missile Crises`:   `$app/departmenthistory/short-history/cubanmissile`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-frus-short-history-subsection(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/short-history/cubanmissile')
  let $result := pages:generate-breadcrumbs('/departmenthistory/short-history/cubanmissile')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:

#### Page template departmenthistory/timeline/section.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/timeline/1970-1979`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Administrative Timeline`:    `/$app/departmenthistory/timeline`
      `1970-1979`:  `/$app/departmenthistory/timeline/1970-1979`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-frus-timeline-section(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/timeline/1970-1979')
  let $result := pages:generate-breadcrumbs('/departmenthistory/timeline/1970-1979')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:
##### Page template departmenthistory/travels/president/person-or-country.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/travels/president/taft-william-howard`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Presidential and Secretaries Travels Abroad`:    `$app/departmenthistory/travels`
      `Presidents`: `$app/departmenthistory/travels/president`
      `William Howard Taft`:    `$app/departmenthistory/travels/president/taft-william-howard`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-travels-president-person(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/travels/president/taft-william-howard')
  let $result := pages:generate-breadcrumbs('/departmenthistory/travels/president/taft-william-howard')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:
  - GIVEN a URL `$app/departmenthistory/travels/president/laos`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Presidential and Secretaries Travels Abroad`:    `$app/departmenthistory/travels`
      `Presidents`: `$app/departmenthistory/travels/president`
      `Laos`:       `$app/departmenthistory/travels/president/laos`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-travels-president-country(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/travels/president/laos')
  let $result := pages:generate-breadcrumbs('/departmenthistory/travels/president/laos')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:
##### Page template departmenthistory/travels/secretary/person-or-country.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/travels/secretary/root-elihu`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Presidential and Secretaries Travels Abroad`:    `$app/departmenthistory/travels`
      `Secretaries`:    `$app/departmenthistory/travels/secretary`
      `Elihu Root`: `$app/departmenthistory/travels/secretary/root-elihu`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-travels-secretary-person(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/travels/secretary/root-elihu')
  let $result := pages:generate-breadcrumbs('/departmenthistory/travels/secretary/root-elihu')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:
  - GIVEN a URL `$app/departmenthistory/travels/secretary/laos`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Presidential and Secretaries Travels Abroad`:    `$app/departmenthistory/travels`
      `Secretaries`:    `$app/departmenthistory/travels/secretary`
      `Laos`:       `$app/departmenthistory/travels/secretary/laos`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-travels-secretary-country(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/travels/secretary/laos')
  let $result := pages:generate-breadcrumbs('/departmenthistory/travels/secretary/laos')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:
#### Page template departmenthistory/visits/country-or-year.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/visits/cuba`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Visits by Foreign Leaders`:  `$app/departmenthistory/visits`
      `Cuba`:       `$app/departmenthistory/visits/cuba`
:)

declare %test:assertEquals('true')
function x:test-pages-breadcrumb-visits-country(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/visits/cuba')
  let $result := pages:generate-breadcrumbs('/departmenthistory/visits/cuba')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:
  - GIVEN a URL `$app/departmenthistory/visits/1979`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Visits by Foreign Leaders`:  `$app/departmenthistory/visits`
      `1979`:       `$app/departmenthistory/visits/1979`
:)

declare %test:assertEquals('true')
function x:test-pages-breadcrumb-visits-year(){
  let $expected := x:generate-breadcrumb-test-data('/departmenthistory/visits/1979')
  let $result := pages:generate-breadcrumbs('/departmenthistory/visits/1979')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:

#### Page template education/module.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/education/modules/history-diplomacy-intro`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Education`:  `$app/education`
      `Curriculum Modules`: `$app/education/modules`
      `Introduction to Curriculum Packet on `A History of Diplomacy`:   `$app/education/modules/history-diplomacy-intro`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-education-module(){
  let $expected := x:generate-breadcrumb-test-data('/education/modules/history-diplomacy-intro')
  let $result := pages:generate-breadcrumbs('/education/modules/history-diplomacy-intro')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:
### Page template historicaldocuments/administrations.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/historicaldocuments/wilson`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Historical Documents`:   `$app/historicaldocuments`
      `Woodrow Wilson Administration (1913-1921)`:    `$app/historicaldocuments/wilson`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-frus-administration(){
  let $expected := x:generate-breadcrumb-test-data('/historicaldocuments/wilson')
  let $result := pages:generate-breadcrumbs('/historicaldocuments/wilson')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:

### Page template historicaldocuments/volume-interior.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/historicaldocuments/frus1981-88v11/persons`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Historical Documents`:   `$app/historicaldocuments`
      `Foreign Relations of the United States, 1981-1988, Volume XI, START I`:  `$app/historicaldocuments/frus1981-88v11`
      `Persons`:    `$app/historicaldocuments/frus1981-88v11/persons`
:)

declare %test:assertEquals('true')
function x:test-pages-breadcrumb-frus(){
  let $expected := x:generate-breadcrumb-test-data('/historicaldocuments/frus1981-88v11/persons')
  let $result := pages:generate-breadcrumbs('/historicaldocuments/frus1981-88v11/persons')
  return if (deep-equal($expected, $result)) then 'true' else $result

};

(: footnotes in chapter titles to be suppressed :)

declare %test:assertEquals('true')
function x:test-pages-breadcrumb-frus-footnote-in-head(){
    let $expected := x:generate-breadcrumb-test-data('/historicaldocuments/frus1894/ch25')
    let $result := pages:generate-breadcrumbs('/historicaldocuments/frus1894/ch25')
    return if (deep-equal($expected, $result)) then 'true' else $result
};

(: documents to be styled appropriately; no footnotes in header :)

declare %test:assertEquals('true')
function x:test-pages-breadcrumb-frus-document-no(){
    let $expected := x:generate-breadcrumb-test-data('/historicaldocuments/frus1952-54v07p1/d379')
    let $result := pages:generate-breadcrumbs('/historicaldocuments/frus1952-54v07p1/d379')
    return if (deep-equal($expected, $result)) then 'true' else $result
};

(:

#### Page template historicaldocuments/frus-history/monograph-interior.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/historicaldocuments/frus-history/foreword`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Historical Documents`:   `$app/historicaldocuments`
      `Toward “Thorough, Accurate, and Reliable”: A History of the <em>Foreign Relations of the United States</em> Series`:  `$app/historicaldocuments/frus-history`
      `Foreword`:   `$app/historicaldocuments/frus-history/foreword`

:)

declare %test:assertEquals('true')
function x:test-pages-breadcrumb-frus-history-section(){
  let $expected := x:generate-breadcrumb-test-data('/historicaldocuments/frus-history/foreword')
  let $result := pages:generate-breadcrumbs('/historicaldocuments/frus-history/foreword')
  return if (deep-equal($expected, $result)) 
  then 'true' 
  else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

(:

##### Page template historicaldocuments/frus-history/documents/document.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/historicaldocuments/frus-history/documents/2002-08-19-athens-02867`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Historical Documents`:   `$app/historicaldocuments`
      `History of the <em>Foreign Relations</em> Series`:   `$app/historicaldocuments/frus-history`
      `Documents`:  `$app/historicaldocuments/frus-history/documents`
      `Telegram From Embassy Athens, 2002`: `$app/historicaldocuments/frus-history/documents/2002-08-19-athens-02867`
:)

declare %test:assertEquals('true')
function x:test-pages-breadcrumb-frus-documents(){
  let $expected := x:generate-breadcrumb-test-data('/historicaldocuments/frus-history/documents/2002-08-19-athens-02867')
  let $result := pages:generate-breadcrumbs('/historicaldocuments/frus-history/documents/2002-08-19-athens-02867')
  return if (deep-equal($expected, $result)) 
  then 'true' 
  else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

(:

#### Page template historicaldocuments/frus-history/research/article.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/historicaldocuments/frus-history/research/a-good-years-work`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Historical Documents`:   `$app/historicaldocuments`
      `Toward “Thorough, Accurate, and Reliable”: A History of the Foreign Relations of the United States Series`:   `$app/historicaldocuments/frus-history`
      `Research`:   `$app/historicaldocuments/frus-history/research`
      `A Good Year's Work`: `$app/historicaldocuments/frus-history/research/a-good-years-work`
:)

declare %test:assertEquals('true') function x:test-pages-breadcrumb-frus-history-articles(){
  let $expected := x:generate-breadcrumb-test-data('/historicaldocuments/frus-history/research/a-good-years-work')
  let $result := pages:generate-breadcrumbs('/historicaldocuments/frus-history/research/a-good-years-work')
  return if (deep-equal($expected, $result)) 
  then 'true' 
  else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

(:

##### Page template historicaldocuments/pre-1861/serial-set/browse.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/historicaldocuments/pre-1861/serial-set/browse?region=Europe&subject=France`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Historical Documents`:   `$app/historicaldocuments`
      `Pre-1861 U.S. foreign relations materials`:  `$app/historicaldocuments/pre-1861`
      `U.S. foreign relations materials in the pre-1861 U.S. Congressional Serial Set`: `$app/historicaldocuments/pre-1861/serial-set`
      `Europe`:     `$app/historicaldocuments/pre-1861/serial-set/browse?region=Europe`
:)

declare
%test:pending('testing Url parameters not possible at this time; implement test when/if URI reimplemented')
%test:assertEquals('true') function x:test-pages-breadcrumb-serial-set-region(){
  let $expected := x:generate-breadcrumb-test-data('/historicaldocuments/pre-1861/serial-set/browse?region=Europe')
  let $result := pages:generate-breadcrumbs('/historicaldocuments/pre-1861/serial-set/browse?region=Europe')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/historicaldocuments/pre-1861/serial-set/browse?region=Europe&subject=France`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Historical Documents`:   `$app/historicaldocuments`
      `Pre-1861 U.S. foreign relations materials`:  `$app/historicaldocuments/pre-1861`
      `U.S. foreign relations materials in the pre-1861 U.S. Congressional Serial Set`: `$app/historicaldocuments/pre-1861/serial-set`
      `France`:     `$app/historicaldocuments/pre-1861/serial-set/browse?region=Europe&subject=France`
:)

declare
%test:pending('testing Url parameters not possible at this time; implement test when/if URI reimplemented')
%test:assertEquals('true') function x:test-pages-breadcrumb-serial-set-subject(){
  let $expected := x:generate-breadcrumb-test-data('/historicaldocuments/pre-1861/serial-set/browse?region=Europe&amp;subject=France')
  let $result := pages:generate-breadcrumbs('/historicaldocuments/pre-1861/serial-set/browse?region=Europe&amp;subject=France')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:
### Page template milestones/chapter/index.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/milestones/1977-1980`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Milestones`: `$app/milestones`
      `1977-1980`:  `$app/milestones/1977-1980`
:)

declare %test:assertEquals('true')
function x:test-pages-breadcrumb-milestone-chapter(){
  let $expected := x:generate-breadcrumb-test-data('/milestones/1977-1980')
  let $result := pages:generate-breadcrumbs('/milestones/1977-1980')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:
### Page template milestones/chapter/article.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/milestones/1977-1980/china-policy`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Milestones`: `$app/milestones`
      `1977-1980`:  `$app/milestones/1977-1980`
      `China Policy`:   `$app/milestones/1977-1980/china-policy`
:)

declare %test:assertEquals('true')
function x:test-pages-breadcrumb-milestone-article(){
  let $expected := x:generate-breadcrumb-test-data('/milestones/1977-1980/china-policy')
  let $result := pages:generate-breadcrumbs('/milestones/1977-1980/china-policy')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:
### Page template tags/browse.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/tags/clay-henry`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Tags`:       `$app/tags`
      `Clay, Henry`:    `$app/tags/clay-henry`

:)

declare %test:assertEquals('true')
function x:test-pages-breadcrumb-tags(){
  let $expected := x:generate-breadcrumb-test-data('/tags/clay-henry')
  let $result := pages:generate-breadcrumbs('/tags/clay-henry')
  return if (deep-equal($expected, $result)) then 'true' else $result
};
