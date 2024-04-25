xquery version "3.1";

(:
 : Template functions to handle HSG sidebars
 :)
module namespace side = "http://history.state.gov/ns/site/hsg/sidebar";

import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace site="http://ns.evolvedbinary.com/sitemap" at "sitemap-config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";
import module namespace link="http://history.state.gov/ns/site/hsg/link" at "link.xqm";
import module namespace templates="http://exist-db.org/xquery/html-templating";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare namespace hsg="http://history.state.gov/ns/site/hsg";

declare function side:info($node, $model) {
    let $github := substring-after(site:get-uri(), $app:APP_ROOT) => side:github-url()
    return
        <aside class="hsg-aside--info">
            <div id="info" class="hsg-panel">
                <div class="hsg-panel-heading">
                    <h2 class="hsg-sidebar-title">Info</h2>
                </div>
                <ul class="hsg-list-group">
                    <li class="hsg-list-group-item"><a href="#" class="hsg-cite__button--sidebar">Cite this resource</a></li>
                    {
                        if (exists($github)) then 
                            <li class="hsg-list-group-item">Download raw data from <a href="{$github}">HistoryAtState on GitHub</a></li>
                        else ()
                    }
                </ul>
            </div>
        </aside>
};

declare function side:github-url($uri as xs:string) {
    side:github-url($uri, $site:config)
};

declare function side:github-url($uri as xs:string, $site-config as element(site:root)) {
    site:call-for-uri-step(
        $uri,
        $site-config,
        function($state as map(*)){
            ($state?cfg.step/ancestor-or-self::site:step/site:config/hsg:github)[1]/@href ! string(.)
        },
        map{}
    )
};

declare function side:section-nav($node as node(), $model as map(*)){
  side:generate-section-nav(substring-after(site:get-uri(), $app:APP_ROOT))
};

declare function side:generate-section-nav($uri as xs:string) as element(div)? {
  let $site-section := '/' || (tokenize($uri,'/')[. ne ''])[1]
  let $section-title :=
      site:call-with-parameters-for-uri-steps(
        $site-section,
        $site:config,
        link:generate-label-from-state#1,
        map{'original-url': $uri}
      )[2]
  let $section-links :=
      site:call-for-uri-step-children(
        $site-section,
        $site:config,
        link:generate-from-state#1,
        map{'exclude-role': 'section-nav', 'skip-role': 'section-nav', 'original-url': $uri}
      )

  return if ($section-links) then
    <aside id="sections" class="hsg-aside--section">
        <div class="hsg-panel">
          {
            if ($section-title) then
              <div class="hsg-panel-heading">
                <h2 class="hsg-sidebar-title">{$section-title}</h2>
              </div>
            else ()
          }{
            if ($section-links) then
              <ul class="hsg-list-group">
                {
                  for $link in $section-links return
                  <li class="hsg-list-group-item">{$link}</li>
                }
              </ul>
            else ()
          }
        </div>
    </aside>
  else ()
};

declare function side:docs-on-page($node, $model) {
    if ($model?data instance of element(tei:pb)) then
        element {node-name($node)} {
            $node/(@* except @data-template),
            templates:process($node/*, map:merge(($model, map{'pb-doc-ids': side:doc-ids-on-page($model?data)}), map{'duplicates':'use-last'}))
        }
    else ()
};

declare function side:doc-ids-on-page($this-page as element(tei:pb)) as xs:string* {
    let $next-page := $this-page/following::tei:pb[1]
    let $next-page-starts-document as xs:boolean := $next-page/preceding-sibling::element()[1][self::tei:head] or (not($next-page/preceding-sibling::element()) and $next-page/parent::tei:div/@type = 'document')
    let $fragment-ending-this-page :=
        if ($next-page-starts-document) then
            $next-page/parent::tei:div
        else
            $next-page
    let $page-div-ids :=
        (
            $this-page/ancestor::tei:div[@type='document'],
            ($this-page/following::tei:div[@type='document'][not(. >> $next-page)] except $next-page/ancestor::tei:div[@type="document"][$next-page-starts-document])
            
        )/@xml:id
    return $page-div-ids
};
