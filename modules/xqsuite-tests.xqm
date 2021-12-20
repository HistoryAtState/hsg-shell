xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/xqsuite-tests";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";
import module namespace templates="http://exist-db.org/xquery/templates";

declare namespace test="http://exist-db.org/xquery/xqsuite";

(: XQsuite tests for module functions :)

(:
# Helper functions

## return-model()

This function returns the a zero argument function which returns the page template `$model` map; it returns a function rather than a map directly as template functions returning a map are intercepted by the HTML templating module:
:)

declare function x:return-model($node as node()?, $model as map(*)?) as function(*) {
    function() {$model}
};

(:
### Test

- WHEN calling x:return-model()
  - GIVEN an entry in $model ("publication-id": "frus")
    - THEN calling the resulting function should return a map
    - AND that map should have the entry given in the model

:)

declare %test:assertEquals('frus') function x:test-return-model() {
    let $node  := ()
    let $model := map { "publication-id": "frus"}
    return x:return-model($node, $model)()?publication-id
};

(:  
# Test plan for config:open-graph

return values like "og:type": "website" can be considered to be shorthand for:
```HTML
<meta property="og:type" content="website"/>
```

## Should produce open-graph defaults (this essentially tests $config:OPEN_GRAPH and $config:OPEN_GRAPH_KEYS) 

- WHEN calling config:open-graph()
  - GIVEN the default open graph map
    AND the default open graph keys
    AND a test URL 'test-url'
    - THEN return:
                "og:type": "website"
           "twitter:card": "summary"
           "twitter:site": "@HistoryAtState"
           "og:site_name": "Office of the Historian"
         "og:description": "Office of the Historian"
               "og:image": "https://static.history.state.gov/images/avatar_big.jpg"
         "og:image:width": "400"
        "og:image:height": "400"
           "og:image:alt": "Department of State heraldic shield"
               "og:title": pages:generate-short-title()
                 "og:url": "test-url"
:)

declare
    %test:assertEquals(
        '<meta property="og:type" content="website"/>',
        '<meta property="twitter:card" content="summary"/>',
        '<meta property="twitter:site" content="@HistoryAtState"/>',
        '<meta property="og:site_name" content="Office of the Historian"/>',
        '<meta property="og:description" content="Office of the Historian"/>',
        '<meta property="og:image" content="https://static.history.state.gov/images/avatar_big.jpg"/>',
        '<meta property="og:image:width" content="400"/>',
        '<meta property="og:image:height" content="400"/>',
        '<meta property="og:image:alt" content="Department of State heraldic shield"/>',
        '<meta property="og:title" content=pages:generate-short-title()/>',
        '<meta property="og:url" content="test-url"/>'
    )
function x:open-graph-defaults() {
    let $node:= ()
    let $model:= map {
             "open-graph": $config:OPEN_GRAPH,
        "open-graph-keys": $config:OPEN_GRAPH_KEYS,
                    "url": "test-url"
    }
    return config:open-graph($node,$model)
};


(:
## Should produce metadata for specified open graph keys

- WHEN calling config:open-graph()
  - GIVEN a specified set of open graph keys ("og:type", "twitter:card")
    AND the default open graph map
    - THEN return "og:type": "website"
      AND    "twitter:card": "summary"
      AND no other Open Graph metadata (metadata should only be produced when supplied with corresponding keys)
:)

declare
    %test:assertEquals(
        '<meta property="og:type" content="website"/>',
        '<meta property="twitter:card" content="summary"/>'
    )
function x:open-graph-with-keys() {
    let $node:= ()
    let $model:= map {
             "open-graph": $config:OPEN_GRAPH,
        "open-graph-keys": ("og:type", "twitter:card")
    }
    return config:open-graph($node, $model)
};

(:
## Should produce metadata for a specified open graph map


- WHEN calling config:open-graph()
  - GIVEN a specified open graph map
    AND the default set of open graph keys
    - THEN return "twitter:card": "summary_large_image"
      AND no other Open Graph metadata (metadata should only be produced when keys have corresponding functions)
:)

declare
    %test:assertEquals(
        '<meta property="twitter:card" content="summary_large_image"/>'
    ) 
function x:open-graph-with-map() {
    let $node:= ()
    let $model:= map {
        "open-graph": map {
            "twitter:card": function($node, $model) {
                <meta property="twitter:card" content="summary_large_image"/>
            }
        },
        "open-graph-keys": $config:OPEN_GRAPH_KEYS
    }
    return config:open-graph($node, $model)
};

(:
## Should produce metadata for a combination of specified map and keys

  - GIVEN a specified open graph map (map {"made:up": function($node, $model) {<meta property="made:up" content="value"/>}})
    AND a specified open graph key ("made:up")
    - THEN return "made:up": "value"
      AND no other Open Graph metadata
:)

declare
    %test:assertEquals(
        '<meta property="made:up" content="value"/>'
    ) 
function x:open-graph-with-map-and-keys() {
    let $node:= ()
    let $model:= map {
        "open-graph": map {
            "made:up": function($node, $model) {<meta property="made:up" content="value"/>}
        },
        "open-graph-keys": "made:up"
    }
    return config:open-graph($node, $model)
};
 
(:
# Testing plan for pages:load

## Should add default open graph map and keys to $model if none are provided, and there is no static Open Graph

- WHEN HTML templating function pages:load is called
  - GIVEN no static Open Graph data in $node//*
    AND no Open Graph keys
    - THEN return the default set of keys from $config:OPEN_GRAPH_KEYS as $new-model?open-graph-keys
:)

declare %test:assertEquals('og:type twitter:card twitter:site og:site_name og:title og:description og:url og:image') function x:pages-load-add-default-open-graph-keys() {
    let $node := <div data-template="pages:load"><span data-template="x:return-model"/></div>
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
            <div data-template="x:return-model"/>
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

declare %test:assertEquals('made:up og:type twitter:card twitter:site og:site_name og:title og:description og:url og:image') function x:pages-load-add-open-graph-keys-static() {
    let $node := 
        <div data-template="pages:load">
            <div id="static-open-graph" data-template="pages:suppress">
                <meta property="made:up" content="value"/>
            </div>
            <div data-template="x:return-model"/>
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
    let $node := <div data-template="pages:load"><span data-template="x:return-model"/></div>
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

declare %test:assertEquals('twitter:card twitter:site og:site_name og:title og:url og:image') function x:pages-load-add-open-graph-keys-exclude() {
    let $node := <div data-template="pages:load"><span data-template="x:return-model"/></div>
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

declare %test:assertEquals('made:up og:type twitter:card twitter:site og:site_name og:title og:description og:url og:image') function x:pages-load-add-open-graph-keys-add() {
    let $node := <div data-template="pages:load"><span data-template="x:return-model"/></div>
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
    let $node := <div data-template="pages:load"><span data-template="x:return-model"/></div>
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

- When calling pages:app-root($node, $model)
  - Given a node with a static title 'Static'
    - Then return a $new-node/head/title = 'Static'
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
  - Given a node with a H1 heading 'H1'
    - Return 'H1'
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