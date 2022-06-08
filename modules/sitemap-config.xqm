xquery version "3.1";

module namespace site="http://ns.evolvedbinary.com/sitemap";

import module namespace util="http://exist-db.org/xquery/util";

declare namespace u="http://www.sitemaps.org/schemas/sitemap/0.9";

declare variable $site:debug as xs:boolean := true();
declare variable $site:config as element(site:root) := doc('/db/apps/hsg-shell/urls.xml')/*;
declare variable $site:base-url := "https://history.state.gov/";

(: A helper function for running tests on annotations :)
declare
  %site:mode-selector("test")
  %site:mode("test")
  %site:match("Hello Kitty")
function site:hello-world($x as xs:string?) {
  let $y := ($x, "World")[1]
  return "Hello "||$y
};

(: A helper function for logging during development :)
declare function site:log($message as xs:string*){
    if ($site:debug) then
        util:log('INFO', $message)
    else ()
};

(: mode-selector() returns the selector function for a named mode; it looks this up using the 
   %site:mode-selector annotation
:)
declare function site:mode-selector($mode-name as xs:string) as function(*)? {
  inspect:module-functions()[
    inspect:inspect-function(.)[
      annotation[
        @name eq "site:mode-selector"
      ][
        value = $mode-name
      ]
    ]
  ][last()]
};

(: mode-on-no-match() returns the default function for a named mode; it looks this up using the 
   %site:mode-default annotation.  These default 'on-no-match' functions allow behaviour
   analagous to 'shallow-skip' etc in xslt.
:)
declare function site:mode-on-no-match($mode-name as xs:string) as function(*)? {
  inspect:module-functions()[
    inspect:inspect-function(.)[
      annotation[
        @name eq "site:on-no-match"
      ][
        value = $mode-name
      ]
    ]
  ][last()]
};

(: mode-templates() is a function that collects together functions associated with a given
   mode using the %site:mode and %site:match annotations.  It builds a map associated with     the named mode, returning a function for each key value in %site:match.  These are 
   intended to correlate with values returned by the mode:selector.
:)
declare function site:mode-templates($mode-name as xs:string)as map(xs:string, function(*)) {
  map:merge((
    for $f in inspect:module-functions()
    let $f-x := inspect:inspect-function($f)[annotation[@name eq "site:mode"][value = $mode-name]]
    return for $match in $f-x/annotation[@name eq "site:match"]/value
      return map{ $match: $f}
  ))
};

(: process() takes items and applies functions to them according to the named mode.
   To avoid inspecting all module functions in every iteration, the selector function
   and templates map are passed in a $state map, which can also be used to store
   "tunnel parameters" for use by the mode functions.
:)
declare function site:process($item, $mode-name as xs:string, $state as map(*)?){
  
  let $selector as function(*) := (
    $state?mode?($mode-name)?selector,
    site:mode-selector($mode-name),
    function($item) { site:local-name-selector($item) } (: Use local name selector by default:)
  )[1]
  
  let $templates as map(xs:string, function(*)) := (
    $state?mode?($mode-name)?templates,
    site:mode-templates($mode-name),
    map{}
  )[1]
  
  let $on-no-match as function(*) := (
    $state?mode?($mode-name)?on-no-match,
    site:mode-on-no-match($mode-name),
    function($item, $state) { site:shallow-skip($item, $state) } (: Use shallow skip by default :)
  )[1]
  
  let $modes as map(*) := map:merge((
      (
        for $mode in ($state?mode ! map:keys(.)[. ne $mode-name])
        return map{$mode: $state?mode?($mode)}
      ),
      map{
        $mode-name: map{
          "selector": $selector,
          "templates": $templates,
          "on-no-match": $on-no-match
        }
      }
    ), map{'duplicates':'use-last'})
  
  let $new-state as map(*) := map:merge((
    $state,
    map{
      'current-mode': $mode-name,
      'mode': $modes
    }
  ), map{"duplicates": "use-last"})
  
  for $i in $item 
  let $s := $selector($i)
  let $result := if (exists($templates?($s))) then $templates?($s) else $on-no-match
  return $result ! .($i, $new-state)
};

(: a convenience overload of process() :)
declare function site:process($item, $mode-name as xs:string){
  site:process($item, $mode-name, map{})
};

(: build-map() creates sitemaps from the sitemap-config, using the 'sitemap' mode. :)
declare function site:build-map($cfg as element()) {
  site:process($cfg, 'sitemap')
};
declare function site:build-map($cfg as element(), $state as map(*)){
  site:process($cfg, 'sitemap', $state)
};

(: local name selector returns the local name of elements, and the local name
   prepended by parent name `/@` for attributes.
:) 
declare
  %site:mode-selector('config', 'sitemap', 'cwpfus', 'find-children')
function site:local-name-selector($node) as xs:string? {
  typeswitch ($node)
  case element() return local-name($node)
  case attribute() return local-name($node/..)||'/@'||local-name($node) 
  default return ()
};

declare
  %site:on-no-match('sitemap', 'cwpfus', 'find-children')
function site:shallow-skip($item, $state as map(*)){
  for $i in $item/*
  return site:process($i, $state?current-mode, $state)
};

declare
  %site:on-no-match('config', 'redirects')
function site:shallow-skip-with-attributes($item, $state as map(*)){
  for $i in $item/(node()|@*)
  return site:process($i, $state?current-mode, $state)
};

(: sitemap-root is the template function matching 'root' elements in the sitemap mode :)
declare
  %site:mode('sitemap')
  %site:match('root')
function site:sitemap-root($root as element(), $state as map(*)){
  let $sitemap-dir := '/db/apps/hsg-shell/resources/sitemaps'
  let $_ := site:log('SMG: Starting sitemap generation')
  let $_ := cache:destroy('last-modified')
  let $_ := if (xmldb:collection-available($sitemap-dir)) then xmldb:remove($sitemap-dir) else ()
  let $_ := xmldb:create-collection('/db/apps/hsg-shell/resources', 'sitemaps')
  let $_ := cache:create('last-modified', map{})
  let $urls := site:process-with-config($root, $state)
  let $maxurls := 100
  let $result := 
    if (count($urls) lt $maxurls)
    then
      <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
        {$urls}
      </urlset>
    else
    <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      {
        for $url-group at $count in $urls
        let $group := ($count - ($count mod $maxurls)) div $maxurls
        group by $group
        order by $group
        let $sitemap := 
          <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            {$url-group}
          </urlset>
        let $_ := xmldb:store($sitemap-dir, 'sitemap'||$group||'.xml', $sitemap)
        return
          <sitemap xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <loc>{$site:base-url}sitemap{$group}.xml</loc>
          </sitemap>
      }
    </sitemapindex>
  let $_ := site:log('SMG: Completed sitemap generation')
  return xmldb:store($sitemap-dir, 'sitemap.xml', $result)
};

declare
  %site:mode('sitemap')
  %site:match('page-template')
function site:sitemap-page-template($page-template as element(site:page-template), $state as map(*)?){
  for $urls in $state?config?urls
  group by $url := $urls ! map:keys(.)
  let $filepaths := (
    for $map in $urls?($url)
    group by $filepath := $map?filepath
    return $filepath
  )
  let $page-template-href := site:eval-avt($page-template/@href, false(), (xs:QName('site:key'), $urls?($url)?keys))
  let $lastmod :=  site:last-modified-from-urls((resolve-uri($page-template-href, base-uri($page-template)), $filepaths))
  return 
    <url xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      <loc>{$site:base-url}{$url}</loc>
      <lastmod>{$lastmod}</lastmod>
    </url>
};

declare function site:last-modified-from-urls($urls as xs:string*) as xs:dateTime? {
  (
    for $url in $urls
    let $date := site:last-modified-from-url($url)
    order by $date descending
    return $date
  )[1]
};

declare function site:last-modified-from-url($url as xs:string) as xs:dateTime?{
  let $cached as xs:dateTime? := cache:get('last-modified', $url)
  return 
    if (exists($cached)) 
    then $cached
    else 
      if (xmldb:collection-available($url))
      then
        let $urls := site:get-urls-from-collection($url)
        return site:last-modified-from-urls($urls)
      else
        let $date as xs:dateTime? :=   try {
          let $col-name := replace($url, '(.+)/.+', '$1')
          let $doc-name := replace($url, '.+/(.+)', '$1')
          return xmldb:last-modified($col-name, $doc-name)
        }
        catch * {
          site:log(('Failure attempting to get last modified date of ', $url)),
          site:log(('Error code: ', $err:code)),
          site:log(('Error description: ', $err:description)),
          site:log(('Error value(s): ', $err:value)),
          site:log(('Error in module: ', $err:module)),
          site:log(('Error line no: ', $err:line-number)),
          site:log(('Addition info: ', $err:additional))
        }
        let $_ := if (exists($date)) then cache:put('last-modified', $url, $date) else ()
        return $date
};

declare
  %site:mode('sitemap')
  %site:match('step')
function site:sitemap-step($step as element(), $state as map(*)?){
  let $_ := site:log(("SMG: processing step: ", $step/@value, $step/@key))
  return site:process-with-config($step, $state)
};

(: convenience function for returning the config :)
declare function site:get-config($node, $state as map(*)) as map(*)?{
  site:config-merge(site:process($node, 'config', $state))
};

declare
  %site:mode('config')
  %site:match('step')
function site:config-step($node, $state as map(*)) as map(*)* {
  let $skipped := $node/(site:path, site:step) (: Don't recurse through steps :)
  let $parent-urls := $state?config?urls
  let $new-config := ($state?config => map:remove('urls')) => map:put('parent-urls', $parent-urls)
  let $new-state := site:state-config-merge($state, $new-config)
  return site:get-config(($node/@*, $node/* except $skipped), $new-state)
};

declare
  %site:mode('config')
  %site:match('root')
function site:config-root($node as element(site:root), $state as map(*)) as map(*)* {
  let $skipped := $node/(site:path, site:step) (: Don't recurse through steps :)
  return (
    map{
      'urls': map{
        '/': map{
          'filepath': util:collection-name($node)
        }
      }
    },
    site:get-config(($node/@*, $node/* except $skipped), $state)
  )
};

declare
  %site:mode('config')
  %site:match('step/@value')
function site:config-step-value($value as attribute(value), $state as map(*)) as map(*)?{
  if ($value/parent::*/site:config/site:src)
  then () (: drive URL generation from site:src if present :)
  else
    let $parent-urls as map(*)*:= $state?config?parent-urls
    let $urls := map:merge((
      for $parent-url in $parent-urls ! map:keys(.)
      let $url := replace($parent-url, '(.*)/$', '$1')||'/'||$value
      return map{
        $url: $parent-urls($parent-url)
      }
    ))
    return map{
        'urls': $urls
      }
};

declare
  %site:mode('config')
  %site:match('src/@child-collections')
function site:config-src-child-collections($child-cols as attribute(child-collections), $state as map(*)) as map(*)*{
  if ($child-cols/../@xq)
  then ()
  else
    let $parent-urls as map(*)*:= $state?config?parent-urls
    let $key-label as xs:string? := $child-cols/(ancestor::site:step[1])[@key]/string(@key)
    for $parent-url in $parent-urls ! map:keys(.)
      let $parent-filepath := resolve-uri($child-cols, replace($parent-urls?($parent-url)?filepath, '(.*)/$', '$1')||'/')
      let $child-collections := xmldb:get-child-collections($parent-filepath)
      for $child-collection in $child-collections
      return map{
        'urls': map{
          replace($parent-url, '(.*)/$', '$1')||'/'||$child-collection: map:merge((
            map{'filepath': $parent-filepath||'/'||$child-collection},
            if ($key-label) 
            then map{'keys': map:merge((
              $parent-urls?($parent-url)?keys,
              map{$key-label: $child-collection}
            ))} 
            else (map{'keys': $parent-urls?($parent-url)?keys})
          ))
        }
      }
};

declare 
  %site:mode('config')
  %site:match('src/@collection')
function site:config-step-src-collection($collection as attribute(collection), $state as map(*)) as map(*)*{
  if ($collection/../@xq)
  then ()
  else
    let $parent-urls as map(*)*:= $state?config?parent-urls
    let $key-label as xs:string? := $collection/(ancestor::site:step[1])[@key]/string(@key)
    for $parent-url in $parent-urls ! map:keys(.)
      let $parent-filepath := replace(resolve-uri($collection, replace($parent-urls?($parent-url)?filepath, '(.*)/$', '$1')||'/'), '(.*)/$', '$1')
      let $filepaths := site:get-urls-from-collection($parent-filepath)
      for $filepath in $filepaths
        let $filename.ext := substring-after($filepath, $parent-filepath||'/')
        let $filename := replace($filename.ext, '(.*?)(\.[^.]+)?$', '$1')
        return map{
          'urls': map{
            $parent-url||'/'||$filename: map:merge((
              map{'filepath': $parent-filepath||'/'||$filename.ext},
              if ($key-label) 
              then map{'keys': map:merge((
                $parent-urls?($parent-url)?keys,
                map{$key-label: $filename}
              ))} 
              else (map{'keys': $parent-urls?($parent-url)?keys})
            ))
          }
        }
};

declare 
  %site:mode('config')
  %site:match('src/@doc')
function site:config-step-src-doc($doc as attribute(doc), $state as map(*)) as map(*)*{
  if ($doc/../@xq)
  then ()
  else
    let $parent-urls as map(*)*:= $state?config?parent-urls
    let $key-label as xs:string? := $doc/(ancestor::site:step[1])[@key]/string(@key)
    for $parent-url in $parent-urls ! map:keys(.)
        let $filepath := replace(resolve-uri($doc, replace($parent-urls?($parent-url)?filepath, '(.*)/$', '$1')||'/'), '(.*)/$', '$1')
        let $filename.ext := tokenize($filepath, '/')[last()]
        let $filename := replace($filename.ext, '(.*?)(\.[^.]+)?$', '$1')
        return map{
          'urls': map{
            replace($parent-url, '(.*)/$', '$1')||'/'||$filename: map:merge((
              map{'filepath': $filepath},
              if ($key-label) 
              then map{'keys': map:merge((
                $parent-urls?($parent-url)?keys,
                map{$key-label: $filename}
              ))} 
              else (map{'keys': $parent-urls?($parent-url)?keys})
            ))
          }
        }
};

declare
  %site:mode('config')
  %site:match('src/@xq')
function site:config-step-src-xq($xq as attribute(xq), $state as map(*)) as map(*)*{
    let $parent-urls as map(*)*:= $state?config?parent-urls
    let $key-label as xs:string? := $xq/(ancestor::site:step[1])[@key]/string(@key)
    for $parent-url in $parent-urls ! map:keys(.)
      let $parent-filepath := $parent-urls?($parent-url)?filepath   
      let $contexts :=
        (: contexts are any file URIs that the xquery is running over :)
        if ($xq/../(@collection, @child-collections, @doc)) then $xq/../(
          @collection!site:get-urls-from-collection(resolve-uri(., $parent-filepath||'/')),
          @child-collections!site:get-urls-from-collection(resolve-uri(., $parent-filepath||'/')),
          @doc!resolve-uri(., $parent-filepath||'/')
        )
        else if (xmldb:collection-available($parent-filepath)) then
          site:get-urls-from-collection($parent-filepath)
        else
          $parent-filepath
      for $context in $contexts
      for $source in util:eval('doc("'||$context||'")/'||$xq, false(), ('site:keys', $parent-urls?($parent-url)?keys))
      let $keys := 
        if ($key-label) 
        then map:merge((
          $parent-urls?($parent-url)?keys,
          map{$key-label: string($source)}
        ))
        else $parent-urls?($parent-url)?keys
      return map{
        'urls': map{
          $parent-url||'/'||encode-for-uri($source): map:merge((
            map{
              'filepath': $context,
              'xq': string($xq)
            },
            map{'keys': $keys}
          ))
        }
      }
};

declare function site:get-urls-from-collection($collection as xs:string) as xs:string* {
  for $resource in xmldb:get-child-resources($collection)
  let $uri := resolve-uri($resource, $collection||'/')
  return $uri[not(util:is-binary-doc(.))],
  for $sub-collection in xmldb:get-child-collections($collection)
  return site:get-urls-from-collection(resolve-uri($sub-collection, $collection||'/'))
};

(:
 :  config-merge is a mini-framework for merging (config) maps; it combines keys,
 :  looking for the key name annotation in one of the following functions: 
 :  - site:config-merge-combine()
 :  - site:config-merge-use-last()
 :  - site:config-merge-use-first()
 :  All of which follow similar behaviour correlating to the behaviour of
 :  map:merge() options.  This a) allows for finer control of combining maps by key
 :  and b) allows options such as 'combine' which are not supported by eXist's
 :  xquery engine.
 :)
 
declare function site:config-merge($maps as map(*)*) as map(*)? {
  let $keys := distinct-values($maps ! map:keys(.))
  return map:merge((
    for $key in $keys
    let $sequence := $maps?($key)
    return map{
      $key : 
      (
        site:config-merge-use-last#2,
        inspect:module-functions()[
          inspect:inspect-function(.)[
            annotation[
              @name eq "site:config-merge"
            ][
              value = $key
            ]
          ]
        ]
      )[last()]($maps, $key)
    }
  ))
    
};

declare
  %site:config-merge('recurse-inclusive')
function site:config-merge-recurse-inclusive($maps as map(*)*, $key){
  let $items := $maps?($key)
  let $maps := $items[. instance of map(*)]
  let $atomix := $items except $maps
  return $atomix, site:config-merge($maps)
};

declare
  %site:config-merge('recurse-exclusive', 'keys')
function site:config-merge-recurse-exclusive($maps as map(*)*, $key){
  let $items := $maps?($key)
  let $maps := $items[. instance of map(*)]
  return site:config-merge($maps)
};

declare 
  %site:config-merge('combine', 'urls') 
function site:config-merge-combine($maps as map(*)*, $key){
  $maps?($key)
};

declare 
  %site:config-merge('use-last', 'parent-urls')
function site:config-merge-use-last($maps as map(*)*, $key){
  $maps[exists(.?($key))][last()]?($key)
};

declare
  %site:config-merge('use-first')
function site:config-merge-use-first($maps as map(*)*, $key){
  $maps[exists(.?($key))][1]?($key)
};

(:  state-config-merge merges the config sub-merge into the state map.  :)
declare function site:state-config-merge($state, $config) as map(*){
  map:merge((
    $state,
    map{
      'config': 
        map:merge((
          $state?config,
          $config
        ), map{'duplicates':'use-last'})
    }
  ), map{'duplicates':'use-last'})
};

declare function site:eval-avt($avt as node(), $cache-flag as xs:boolean, $external-variable) as xs:string? {
(:
  eval-avt takes an attribute value-like string (with embedded values in {curly braces}) and evaluates them.
  It does this by embedding the string in a node tree as element content, evaluating, then taking the 
  string result.
:)

  let $declarations as xs:string* :=
    for $prefix in in-scope-prefixes(($avt/ancestor-or-self::*[. instance of element()])[1])[not(. = ('', 'xml'))]
    return concat("declare namespace ", $prefix, "='", namespace-uri-for-prefix($prefix, ($avt/ancestor-or-self::*[. instance of element()])[1]), "'; ")

  let $tmp as xs:string := concat(
    string-join($declarations),
    "<tmp>",
    $avt,
    "</tmp>"
 )
    
  return util:eval($tmp, $cache-flag, $external-variable) ! string(.)
  
};

declare function site:call-for-uri-step-children($url as xs:string, $config as element(), $function as function(*), $state as map(*)?) {
  let $new.state := map:merge((
    map{
      'parent-url': $url,
      'steps': tokenize($url, '/')[. ne ''],
      'function': $function,
      'current-url': '/',
      'step': '/'
    },
    $state
  ), map{'duplicates':'use-last'})
  return site:process($config, 'find-children', $new.state)
};

declare 
  %site:mode('find-children')
  %site:match('root', 'step')
function site:find-children-step($step as element(), $state as map(*)){
  let $next.step := head($state?steps)
  let $this.key as map(*)? := if ($step/@key) then map{$step/@key: $state?step} else ()
  let $keys := map:merge(($state?keys, $this.key))
  return
    if ($state?current-url eq $state?parent-url) then
      (: we have found a parent :) 
      for $child in $step/site:step[@value][not($state?exclude-role = tokenize(site:config/site:exclude/@role, '\s'))]
      let $child.state := map:merge((
        $state,
        map{
          'full-url': $state?parent-url || '/' || $child/@value,
          'parent-url': $state?parent-url || '/' || $child/@value,
          'current-url': replace($state?current-url, '/$', '') || '/' || $child/@value,
          'step': $child/@value,
          'steps': (),
          'function': $state?function,
          'keys': $keys
        }), map{'duplicates':'use-last'})
      return
        if ($state?skip-role = tokenize($child/site:config/site:skip/@role, '\s')) then
          (: skip a level, treating the child as a new parent :)
          site:process($child, $state?current-mode, $child.state)
        else
          (: For other steps, use cwpfus mode to run function:)
          site:process($child, 'cwpfus', $child.state)
    else
      (: recurse to next URI step :)
      let $next as element(site:step)? := (
        $step/site:step[@value eq $next.step],
        ($step/site:step[@match])[matches($next.step, @match)],
        $step/site:step[not(@match or @value)]
      )[1]
      let $new.state := map:merge((
        $state,
        map{
          'parent-url': $state?parent-url,
          'current-url': replace($state?current-url, '/$', '') || '/' || $next.step,
          'step': $next.step,
          'steps': tail($state?steps),
          'function': $state?function,
          'keys': $keys
        }), map{'duplicates':'use-last'})
      return site:process($next, $state?current-mode, $new.state)
};

declare function site:call-with-parameters-for-uri-steps($url as xs:string, $config as element(), $function as function(*)) {
  site:call-with-parameters-for-uri-steps($url, $config, $function, map{})
};

declare function site:call-with-parameters-for-uri-steps($url as xs:string, $config as element(), $function as function(*), $state as map(*)) {
  let $state := map:merge((
    map{
     'full-url': $url,
     'steps': tokenize($url, '/')[. ne ''],
     'function': $function,
     'current-url': '/'
    },
    $state
  ), map{'duplicates':'use-last'})
  return site:process($config, 'cwpfus', $state)
};

declare
  %site:mode('cwpfus')
  %site:match('root', 'step')
function site:cwpfus-step($root as element(), $state as map(*)) {
  let $next.step := head($state?steps)
  let $this.key as map(*)? := if ($root/@key) then map{$root/@key: $state?step} else ()
  let $keys := map:merge(($state?keys, $this.key))
  let $new.state := map{
    'full-url': $state?full-url,
    'current-url': replace($state?current-url, '/$', '') || '/' || $next.step,
    'step': $next.step,
    'steps': tail($state?steps),
    'function': $state?function,
    'keys': $keys
  }
  let $select := (
    $root/site:step[@value eq $next.step],
    ($root/site:step[@match])[matches($next.step, @match)],
    $root/site:step[not(@match or @value)]
  )[1][$state?current-url ne $state?full-url]
  return (
    (: calls the function by matching any page-templates :)
    site:process($root/site:page-template, 'cwpfus', map:merge(($state, map{'keys': $keys}), map{'duplicates':'use-last'})),
    (: if there are any more url step components, this will continue the process :)
    site:process($select, 'cwpfus', $new.state)
  )
};

declare
  %site:mode('cwpfus')
  %site:match('page-template')
function site:cwpfus-template($page-template as element(site:page-template), $state as map(*)) {
  let $params := map:merge(site:process($page-template/site:with-param, 'cwpfus', $state),map{'duplicates':'use-last'})
  let $page-template.rel := site:eval-avt($page-template/@href, false(), (xs:QName('site:key'), $state?keys))
  let $page-template.abs := resolve-uri($page-template.rel, base-uri($page-template))
  let $new.state := map:merge(
    (
      $state,
      map{'parameters': $params},
      map{'page-template': $page-template.abs}
    ), map{'duplicates': 'use-last'}
  )
  return $state?function($new.state)
};

declare
  %site:mode('cwpfus')
  %site:match('with-param')
function site:cwpfus-with-param($with-param as element(site:with-param), $state as map(*)) {
  map{$with-param/@name: site:process($with-param/(@* except @name), 'cwpfus', $state)}
};

declare
  %site:mode('cwpfus')
  %site:match('with-param/@value')
function site:cwpfus-with-param-value($value as attribute(value), $state as map(*)) {
  string($value)
};

declare
  %site:mode('cwpfus')
  %site:match('with-param/@keyval')
function site:cwpfus-with-param-keyval($keyval as attribute(keyval), $state as map(*)) {
  let $keys := $state?keys
  return $keys?($keyval)
};

declare
  %site:mode('cwpfus')
  %site:match('with-param/@select')
function site:cwpfus-with-param-select($select as attribute(select), $state as map(*)) {
  let $keys := $state?keys
  return util:eval($select, false(), ('site:keys', $keys))
};

declare function site:get-url() {
  (: imported from old controller.xql :)
    concat(
        request:get-scheme(),
        '://',
        request:get-server-name(),
        let $server-port := request:get-server-port()
        return 
            if ($server-port = (80, 443)) then 
                ()
            else 
                concat(":", string($server-port)),
        site:get-uri()
        )
};

declare function site:get-uri() {
  (: imported from old controller.xql :)
    (request:get-header("nginx-request-uri"), request:get-uri())[1]
};

declare function site:generate-redirects($cfg) {
    site:process($cfg, 'redirects')
};

declare
    %site:mode('redirects')
    %site:match('root', 'step')
function site:process-with-config($e as element(), $state as map(*)) {
    let $conf := site:get-config($e, $state) 
    let $new.state := site:state-config-merge($state, $conf)
    return site:process($e/*, $state?current-mode, $new.state)
};

declare
    %site:mode('redirects')
    %site:match('redirect')
function site:redirect($redirect as element(site:redirect), $state as map(*)) {
    let $status as xs:string := xs:string(($redirect/@status, 'permanent')[1])
    let $status-code := 
        switch($status)
        case 'permanent' return '301'
        case 'temporary' return '302'
        default return '301'
    let $old-url as element(site:old-url)? := $redirect/site:old-url
    return if ($old-url) then
        let $new.state := site:state-config-merge($state, map{
            'redirect-status': $status-code
        })
        return site:process($redirect/site:old-url, $state?current-mode, $new.state)
    else
        let $new.state := site:state-config-merge($state, map{
            'redirect-status': $status-code,
            'redirects': 
                for $url in $state?config?urls ! map:keys(.) 
                return map{'from': $url}
        })
        return site:process($redirect/site:new-url, $state?current-mode, $new.state)
    
};

declare 
    %site:mode('redirects')
    %site:match('old-url/@value')
function site:redirect-from-value($value as attribute(value), $state as map(*)) {
    let $urls := $state?config?urls ! map:keys(.)
    let $conf := map{'redirects': for $url in $urls return map{
        'from': $url || '/' || $value,
        'parent-path': $url
    }}
    return site:process($value/ancestor::site:redirect[1]/site:new-url, $state?current-mode, site:state-config-merge($state, $conf))
};

declare %site:mode('redirects') %site:match('old-url/@select')
function site:redirect-from-select($select as attribute(select), $state as map(*)) {
    let $urls := $state?config?urls ! map:keys(.)
    let $conf := map{ 'redirects':
        for $url in $urls
            for $filepath in $state?config?urls?($url)?filepath
                for $last in util:eval(
                    ('doc("'||$filepath||'")'||$select),
                    false(), 
                    ('site:keys', $state?config?urls?($url)?keys)
                )
                let $key := if ($select/../@key) then map{'keys':map{$select/../@key: $last}} else ()
                return map:merge((map{
                    'from': concat($url, '/', $last),
                    'parent-path': $url
                }, $key))
        }
    return site:process($select/ancestor::site:redirect[1]/site:new-url, $state?current-mode, site:state-config-merge($state, $conf))
};

declare %site:mode('redirects') %site:match('old-url/@keyval')
function site:redirect-from-keyval($keyval as attribute(keyval), $state as map(*)) {
    let $urls := $state?config?urls ! map:keys(.)
    let $conf := map{
        'redirects':
            for $url in $urls
                let $keys := map:merge(($state?keys, $state?config?urls?($url)?keys), map{'duplicates':'use-last'})
                return map{
                    'from': $url || '/' || $keys?($keyval),
                    'parent-path': $url
                }
    }
    return site:process($select/ancestor::site:redirect[1]/site:new-url, $state?current-mode, site:state-config-merge($state, $conf))
};

declare %site:mode('redirects') %site:match('new-url/@value')
function site:redirect-to-value($value as attribute(value), $state as map(*)) {
    for $redirect in $state?config?redirects
    return map {
        'status':   $state?config?redirect-status,
        'from'  :   $redirect?from,
        'to'    :   resolve-uri($value, $redirect?parent-path || '/')
    }
};

declare %site:mode('redirects') %site:match('new-url/@select')
function site:redirect-to-select($select as attribute(select), $state as map(*)) {
    for $redirect in $state?config?redirects
    let $url := $state?config?urls?($redirect?parent-path)
    let $filepath := $url?filepath
    let $keys as map(*)* := map:merge((
            $url?keys,
            $redirect?keys
        ), map{'duplicates': 'use-last'})
    return map {
        'status':   $state?config?redirect-status,
        'from'  :   $redirect?from,
        'to'    :   resolve-uri(
                        util:eval(
                             ('doc("'||$filepath||'")'||$select),
                             false(), 
                             (xs:QName('site:keys'), $keys)
                         ),
                         $redirect?parent-path || '/'
                     )
    }
};