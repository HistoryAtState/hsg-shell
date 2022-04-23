xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-pages";
import module namespace t="http://history.state.gov/ns/site/hsg/xqsuite" at "../xqsuite.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "../pages.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "../config.xqm";
import module namespace templates="http://exist-db.org/xquery/templates";

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

declare %test:assertEquals('og:type twitter:card twitter:site og:site_name og:title og:description og:image og:url') function x:pages-load-add-default-open-graph-keys() {
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

declare %test:assertEquals('<meta property="og:description" content="Custom hard-coded description goes here"/>') function x:pages-load-add-open-graph-static() {
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

declare %test:assertEquals('made:up og:type twitter:card twitter:site og:site_name og:title og:description og:image og:url') function x:pages-load-add-open-graph-keys-static() {
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

declare %test:assertEquals('og:type og:description') function x:pages-load-add-open-graph-keys() {
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

declare %test:assertEquals('twitter:card twitter:site og:site_name og:title og:image og:url') function x:pages-load-add-open-graph-keys-exclude() {
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
    let $new-model := pages:load($node, $model, "frus", (), (), "div", false(), (), "og:type og:description", ())()
    
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

declare %test:assertEquals('made:up og:type twitter:card twitter:site og:site_name og:title og:description og:image og:url') function x:pages-load-add-open-graph-keys-add() {
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

declare %test:assertEquals('made:up twitter:card') function x:pages-load-add-open-graph-keys-replace() {
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

## Page template about/index.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/about`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `About`:      `$app/about` 
:)

declare
  %test:assertEquals('<div class="hsg-breadcrumb-wrapper"><ol class="breadcrumb"><li><a href="/exist/apps/hsg-shell/">  Home  </a></li><li><a href="/exist/apps/hsg-shell/about"> About </a></li></ol></div>')
function x:test-pages-breadcrumb-about() as element(div) {
  pages:generate-breadcrumbs('/about')
};

(: Test results with mixed content (em elements) :)

declare %test:assertEquals('<div class="hsg-breadcrumb-wrapper"><ol class="breadcrumb"><li><a href="/exist/apps/hsg-shell/">  Home  </a></li><li><a href="/exist/apps/hsg-shell/historicaldocuments"> Historical Documents </a></li><li><a href="/exist/apps/hsg-shell/historicaldocuments/about-frus"> About the <em>Foreign Relations</em> Series </a></li></ol></div>')
function x:test-pages-breadcrumb-with-elements() {
  pages:generate-breadcrumbs('/historicaldocuments/about-frus')
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
  let $expected := 
    <div class="hsg-breadcrumb-wrapper">
      <ol class="breadcrumb">
        <li>
          <a href="/exist/apps/hsg-shell/">  Home  </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/about"> About </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/about/faq"> Frequently Asked Questions </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/about/faq/what-is-frus">  Where can I find information about the Foreign...  </a>
        </li>
      </ol>
    </div>
  let $result := pages:generate-breadcrumbs('/about/faq/what-is-frus')
  return if (deep-equal($expected, $result)) then 'true' else $result
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
  let $expected as element(div) := 
    <div class="hsg-breadcrumb-wrapper">
      <ol class="breadcrumb">
        <li>
          <a href="/exist/apps/hsg-shell/">  Home  </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/about"> About </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/about/hac"> Historical Advisory Committee </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/about/hac/members">  Members  </a>
        </li>
      </ol>
    </div>
  let $result := pages:generate-breadcrumbs('/about/hac/members')
  return if (deep-equal($expected, $result)) then 'true' else $result
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
  let $expected := 
    <div class="hsg-breadcrumb-wrapper">
      <ol class="breadcrumb">
        <li>
          <a href="/exist/apps/hsg-shell/">  Home  </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/conferences"> Conferences </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/conferences/2011-foreign-economic-policy">  Foreign Economic Policy, 1973-1976  </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/conferences/2011-foreign-economic-policy/panel">  Panel Discussion  </a>
        </li>
      </ol>
    </div>
  let $result := pages:generate-breadcrumbs('/conferences/2011-foreign-economic-policy/panel')
  return if (deep-equal($expected, $result)) then 'true' else $result
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
  let $expected := 
    <div class="hsg-breadcrumb-wrapper">
      <ol class="breadcrumb">
        <li>
            <a href="/exist/apps/hsg-shell/">  Home  </a>
        </li>
        <li>
            <a href="/exist/apps/hsg-shell/countries"> Countries </a>
        </li>
        <li>
            <a href="/exist/apps/hsg-shell/countries/mali">  A Guide to the United States’ History of Recognition,
                    Diplomatic, and Consular Relations, by Country, since 1776: Mali  </a>
        </li>
      </ol>
    </div>
  let $result := pages:generate-breadcrumbs('/countries/mali')
  return if (deep-equal($expected, $result)) then 'true' else $result
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
  let $expected := 
    <div class="hsg-breadcrumb-wrapper">
      <ol class="breadcrumb">
        <li>
          <a href="/exist/apps/hsg-shell/">  Home  </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/countries"> Countries </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/countries/issues"> Issues </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/countries/issues/italian-unification">  Issues Relevant to U.S. Foreign Diplomacy: Unification of
                    Italian States  </a>
        </li>
      </ol>
    </div>
  let $result := pages:generate-breadcrumbs('/countries/issues/italian-unification')
  return if (deep-equal($expected, $result)) then 'true' else $result
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
  let $expected := 
    <div class="hsg-breadcrumb-wrapper">
      <ol class="breadcrumb">
        <li>
          <a href="/exist/apps/hsg-shell/">  Home  </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/countries"> Countries </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/countries/archives"> Archives </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/countries/archives/angola">  World Wide Diplomatic Archives Index: Angola  </a>
        </li>
      </ol>
    </div>
  let $result := pages:generate-breadcrumbs('/countries/archives/angola')
  return if (deep-equal($expected, $result)) then 'true' else $result
};

(:
#### Page template departmenthistory/buildings/section.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/buildings/intro`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Buildings`:  `$app/departmenthistory/buildings`

Note that this page doesn't include a 'local' permalink breadcrumb.

#### Page template departmenthistory/people/person.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/people/hilsman-roger-jr`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `People`:     `$app/departmenthistory/people`
      `Roger Hilsman Jr.`:  `$app/departmenthistory/people/hilsman-roger-jr`

##### Page template departmenthistory/people/by-name/letter.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/people/by-name/t`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `People`:     `$app/departmenthistory/people`
      `By Name`:    `$app/departmenthistory/people/by-name`
      `Starting with T`:    `$app/departmenthistory/people/by-name/t`

##### Page template departmenthistory/people/by-year/year.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/people/by-year/1979`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `People`:     `$app/departmenthistory/people`
      `By Year`:    `$app/departmenthistory/people/by-year`
      `1979`:       `$app/departmenthistory/people/by-year/1979`

##### Page template departmenthistory/people/chiefsofmission/by-role-or-country-id.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/people/chiefsofmission/fiji`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `People`:     `$app/departmenthistory/people`
      `Chiefs of Mission`:    `$app/departmenthistory/people/chiefsofmission`
      `Fiji`:       `$app/departmenthistory/people/chiefsofmission/fiji`
  - GIVEN a URL `$app/departmenthistory/people/chiefsofmission/representative-to-au`
    -THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `People`:     `$app/departmenthistory/people`
      `Chiefs of Mission`:    `$app/departmenthistory/people/chiefsofmission`
      `Representatives of the U.S.A. to the African Union`: `$app/departmenthistory/people/chiefsofmission/representative-to-au`

##### Page template departmenthistory/people/principalofficers/by-role-id.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/people/principalofficers/secretary`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `People`:     `$app/departmenthistory/people`
      `Principal Officers`:    `$app/departmenthistory`
      `Secretaries of State`:  `$app/departmenthistory/people/principalofficers/secretary`

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
  let $expected := 
    <div class="hsg-breadcrumb-wrapper">
      <ol class="breadcrumb">
        <li>
          <a href="/exist/apps/hsg-shell/">  Home  </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/departmenthistory"> Department History </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/departmenthistory/short-history"> Short History </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/departmenthistory/short-history/superpowers">  Superpowers Collide, 1961-1981  </a>
        </li>
      </ol>
    </div>
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
  let $expected := 
    <div class="hsg-breadcrumb-wrapper">
      <ol class="breadcrumb">
        <li>
          <a href="/exist/apps/hsg-shell/">  Home  </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/departmenthistory"> Department History </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/departmenthistory/short-history"> Short History </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/departmenthistory/short-history/cubanmissile">  The Cuban Missile Crises  </a>
        </li>
      </ol>
    </div>
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
  let $expected := 
    <div class="hsg-breadcrumb-wrapper">
      <ol class="breadcrumb">
        <li>
          <a href="/exist/apps/hsg-shell/">  Home  </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/departmenthistory"> Department History </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/departmenthistory/timeline"> Administrative Timeline </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/departmenthistory/timeline/1970-1979">  1970–1979  </a>
        </li>
      </ol>
    </div>
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
  - GIVEN a URL `$app/departmenthistory/travels/president/laos`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Presidential and Secretaries Travels Abroad`:    `$app/departmenthistory/travels`
      `Presidents`: `$app/departmenthistory/travels/president`
      `Laos`:       `$app/departmenthistory/travels/president/laos`

##### Page template departmenthistory/travels/secretary/person-or-country.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/travels/secretary/root-elihu`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Presidential and Secretaries Travels Abroad`:    `$app/departmenthistory/travels`
      `Secretaries`:    `$app/departmenthistory/travels/secretary`
      `Elihu Root`: `$app/departmenthistory/travels/secretary/root-elihu`
  - GIVEN a URL `$app/departmenthistory/travels/president/laos`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Presidential and Secretaries Travels Abroad`:    `$app/departmenthistory/travels`
      `Secretaries`:    `$app/departmenthistory/travels/secretary`
      `Laos`:       `$app/departmenthistory/travels/secretary/laos`

#### Page template departmenthistory/visits/country-or-year.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/departmenthistory/visits/cuba`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Visits by Foreign Leaders`:  `$app/departmenthistory/visits`
      `Cuba`:       `$app/departmenthistory/visits/cuba`
  - GIVEN a URL `$app/departmenthistory/visits/1979`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Department History`:  `$app/departmenthistory`
      `Visits by Foreign Leaders`:  `$app/departmenthistory/visits`
      `1979`:       `$app/departmenthistory/visits/1979`

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
  let $expected := 
    <div class="hsg-breadcrumb-wrapper">
      <ol class="breadcrumb">
        <li>
          <a href="/exist/apps/hsg-shell/">  Home  </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/education"> Education </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/education/modules"> Curriculum Modules </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/education/modules/history-diplomacy-intro">  Introduction to Curriculum Packet on “A History of
                    Diplomacy”  </a>
        </li>
      </ol>
    </div>
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
  let $expected := 
        <div class="hsg-breadcrumb-wrapper">
            <ol class="breadcrumb">
                <li>
                    <a href="/exist/apps/hsg-shell/">  Home  </a>
                </li>
                <li>
                    <a href="/exist/apps/hsg-shell/historicaldocuments"> Historical Documents </a>
                </li>
                <li>
                    <a href="/exist/apps/hsg-shell/historicaldocuments/frus1981-88v11">  Foreign Relations of the United States, 1981–1988, Volume XI,
                    START I  </a>
                </li>
                <li>
                    <a href="/exist/apps/hsg-shell/historicaldocuments/frus1981-88v11/persons">  Persons  </a>
                </li>
            </ol>
        </div>
  let $result := pages:generate-breadcrumbs('/historicaldocuments/frus1981-88v11/persons')
  return if (deep-equal($expected, $result)) then 'true' else $result
  
};

(: footnotes in chapter titles to be suppressed :)

declare %test:assertEquals('<div class="hsg-breadcrumb-wrapper"><ol class="breadcrumb"><li><a href="/exist/apps/hsg-shell/">  Home  </a></li><li><a href="/exist/apps/hsg-shell/historicaldocuments"> Historical Documents </a></li><li><a href="/exist/apps/hsg-shell/historicaldocuments/frus1894">  Papers Relating to the Foreign Relations of the United
                    States, 1894, With the Annual Message of the President, Transmitted to Congress,
                    December 3, 1894  </a></li><li><a href="/exist/apps/hsg-shell/historicaldocuments/frus1894/ch25">  Friendly offices to Japanese in ChinaSee
                            Senate Ex. Doc. No. 36, Fifty-third Congress, third
                        session.  </a></li></ol></div>') 
function x:test-pages-breadcrumb-frus-footnote-in-head(){
  pages:generate-breadcrumbs('/historicaldocuments/frus1894/ch25')
};

(: documents to be styled appropriately; no footnotes in header :)

declare %test:assertEquals('<div class="hsg-breadcrumb-wrapper"><ol class="breadcrumb"><li><a href="/exist/apps/hsg-shell/">  Home  </a></li><li><a href="/exist/apps/hsg-shell/historicaldocuments"> Historical Documents </a></li><li><a href="/exist/apps/hsg-shell/historicaldocuments/frus1952-54v07p1">  Foreign Relations of the United States, 1952–1954, Germany
                    and Austria, Volume VII, Part 1  </a></li><li><a href="/exist/apps/hsg-shell/historicaldocuments/frus1952-54v07p1/d379">  Document 379  </a></li></ol></div>')
function x:test-pages-breadcrumb-frus-document-no(){
  pages:generate-breadcrumbs('/historicaldocuments/frus1952-54v07p1/d379')
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
  let $expected := 
    <div class="hsg-breadcrumb-wrapper">
      <ol class="breadcrumb">
        <li>
          <a href="/exist/apps/hsg-shell/">  Home  </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/historicaldocuments"> Historical Documents </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/historicaldocuments/frus-history">  Toward “Thorough, Accurate, and Reliable”: A History of the
                        Foreign Relations of the United States Series  </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/historicaldocuments/frus-history/foreword">  Foreword  </a>
        </li>
      </ol>
    </div>
  let $result := pages:generate-breadcrumbs('/historicaldocuments/frus-history/foreword')
  return if (deep-equal($expected, $result)) then 'true' else $result
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
  let $expected := 
    <div class="hsg-breadcrumb-wrapper">
      <ol class="breadcrumb">
        <li>
          <a href="/exist/apps/hsg-shell/">  Home  </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/historicaldocuments"> Historical Documents </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/historicaldocuments/frus-history">  Toward “Thorough, Accurate, and Reliable”: A History of the
                        Foreign Relations of the United States Series  </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/historicaldocuments/frus-history/research"> Research </a>
        </li>
        <li>
          <a href="/exist/apps/hsg-shell/historicaldocuments/frus-history/research/a-good-years-work">  A Good Year’s Work  </a>
        </li>
      </ol>
    </div>
  let $result := pages:generate-breadcrumbs('/historicaldocuments/frus-history/research/a-good-years-work')
  return if (deep-equal($expected, $result)) then 'true' else $result
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
  let $expected := 
    <div class="hsg-breadcrumb-wrapper">
        <ol class="breadcrumb">
            <li><a href="/exist/apps/hsg-shell/">  Home  </a></li>
            <li><a href="/exist/apps/hsg-shell/historicaldocuments"> Historical Documents </a></li>
            <li><a href="/exist/apps/hsg-shell/historicaldocuments/pre-1861"> Pre-1861 U.S. foreign relations materials </a></li>
            <li><a href="/exist/apps/hsg-shell/historicaldocuments/pre-1861/serial-set"> U.S. foreign relations materials in the pre-1861 U.S. Congressional Serial Set </a></li>
            <li><a href="/exist/apps/hsg-shell/historicaldocuments/pre-1861/serial-set/browse">  France  </a></li>
        </ol>
    </div>
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
  let $expected := ''
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
      
### Page template milestones/chapter/article.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/milestones/1977-1980/china-policy`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Milestones`: `$app/milestones`
      `1977-1980`:  `$app/milestones/1977-1980`
      `China Policy`:   `$app/milestones/1977-1980/china-policy`
     
### Page template tags/browse.xml

- WHEN building page breadcrumbs
  - GIVEN a URL `$app/tags/clay-henry`
    - THEN return a breadcrumb list:
      `Home`:       `$app`
      `Tags`:       `$app/tags`
      `Clay, Henry`:    `$app/tags/clay-henry`
      
:)
