xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/xqsuite-tests";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";

declare namespace test="http://exist-db.org/xquery/xqsuite";

(: XQsuite tests for module functions :)

(:  
# Test plan for config:open-graph

return values like "og:type": "website" can be considered to be shorthand for:
```HTML
<meta property="og:type" content="website"/>
```
:)


(:
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

  - GIVEN a specified open graph map (map {"twitter:card": function($node, $model) {<meta property="twitter:card" content="summary_large_image"/>}})
    AND the default set of open graph keys
    - THEN return "twitter:card": "summary_large_image"
      AND no other Open Graph metadata (metadata should only be produced when keys have corresponding functions)

## Should produce metadata for a combination of specified map and keys

  - GIVEN a specified open graph map (map {"made:up": function($node, $model) {<meta property="made:up" content="value"/>}})
    AND a specified open graph key ("made:up")
    - THEN return "made:up": "value"
      AND no other Open Graph metadata
    
:)

 
(:
# Testing plan for pages:load

## Should add default open graph map and keys to $model if none are provided, and there is no static Open Graph
## Static Open Graph properties should replace corresponding entries in the open graph map
## Should replace open graph keys with $open-graph-keys tokens
## Should remove open graph keys corresponding to $open-graph-keys-exclude
## Should add new open graph keys with $open-graph-keys-add
## Should replace $open-graph-keys-exclude tokens in supplied $open-graph-keys with $open-graph-keys-add


:)

(:
# Test Plan for generate-short-title()

- WHEN calling generate-short-title()

  - GIVEN empty argments
    - THEN return "Office of the Historian"

  - GIVEN an empty HTML h1 heading "H1", ($node//h1))[1] = "" //Empty String
    - THEN return "Office of the Historian"

  - GIVEN a HTML h1 heading "H1", ($node//h1))[1] = "H1"
    - THEN return "H1"
    
  - GIVEN a HTML h2 heading "H2", ($node//h2))[1] = "H2"
    - THEN return "H2"
    
  - GIVEN a HTML h3 heading "H3", ($node//h3))[1] = "H3"
    - THEN return "H3"
    
  - GIVEN an empty HTML h2 heading "H2", ($node//h2))[1] = "" //Empty String
    AND a following HTML h1 heading "H1", ($node//h1))[1] = "H1"
    - THEN return "H1"
    
  - GIVEN a publication ID, $model?publication-id = "articles", with no associated title,  map:get($config:PUBLICATIONS, $model?publication-id)?title = ()
    AND a HTML h3 heading "H3", ($node//h3))[1] = "H3"
    - THEN return "H3"
    
  - GIVEN a publication ID, $model?publication-id = "frus", with an associated title,  map:get($config:PUBLICATIONS, $model?publication-id)?title = "Historical Documents"
    AND a HTML h3 heading "H3", ($node//h3))[1] = "H3"
    - THEN return "Historical Documents"
    
  - GIVEN an empty static title, ($node//h1))[1] = "" //Empty String
    AND a publication ID with an associated title, $model?publication-id = "frus"
    - THEN return "Historical Documents"
    
  - GIVEN a Static title "Static", $node/ancestor::*[last()]//div[@id="static-title"]/string() = "Static"
    AND a publication ID with an associated title, $model?publication-id = "frus"
    - THEN return "Static"

 :)