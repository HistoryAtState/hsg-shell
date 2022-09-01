xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-config";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "../config.xqm";

declare namespace test="http://exist-db.org/xquery/xqsuite";
declare namespace tei="http://www.tei-c.org/ns/1.0";

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
     %test:assertEquals('true') 
function x:open-graph-defaults() {
    let $expected as element(meta)* := (
        <meta property="og:type" content="website"/>,
        <meta property="twitter:card" content="summary"/>,
        <meta property="twitter:site" content="@HistoryAtState"/>,
        <meta property="og:site_name" content="Office of the Historian"/>,
        <meta property="og:title" content="Office of the Historian"/>,
        <meta property="og:description" content="Office of the Historian"/>,
        <meta property="og:image" content="https://static.history.state.gov/images/avatar_big.jpg"/>,
        <meta property="og:image:width" content="400"/>,
        <meta property="og:image:height" content="400"/>,
        <meta property="og:image:alt" content="Department of State heraldic shield"/>,
        <meta property="og:url" content="test-url"/>,
        <meta name="DC.type" content="webpage"/>,
        <meta name="citation_series_title" content="Office of the Historian"/>,
        <meta name="citation_title" content="Office of the Historian"/>,
        <meta name="citation_public_url" content="test-url"/>,
        <meta name="accessDate" content="{format-date(current-date(), '[Y0001]-[M01]-[D01]')}"/>
    )
    let $node:= ()
    let $model:= map {
             "open-graph": $config:OPEN_GRAPH,
        "open-graph-keys": $config:OPEN_GRAPH_KEYS,
                    "url": "test-url"
    }
    let $result as element(meta)* := config:open-graph($node,$model)
    return if (deep-equal($expected, $result)) 
    then 'true'
    else (<result>{$result}</result>, <expected>{$expected}</expected>)
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