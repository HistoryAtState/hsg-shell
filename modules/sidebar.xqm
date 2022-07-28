xquery version "3.1";

(:
 : Template functions to handle HSG sidebars
 :)
module namespace side = "http://history.state.gov/ns/site/hsg/sidebar";

import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace site="http://ns.evolvedbinary.com/sitemap" at "sitemap-config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";

declare function side:info($node, $model) {
    <aside class="hsg-aside--info">
        <div id="info" class="hsg-panel">
            <div class="hsg-panel-heading">
                <h2 class="hsg-sidebar-title">Info</h2>
            </div>
            <ul class="hsg-list-group">
                <li class="hsg-list-group-item"><a href="#" class="hsg-cite-button">Cite this resource</a></li>
            </ul>
        </div>
    </aside>
};

declare function side:section-nav($node as node(), $model as map(*)){
  side:generate-section-nav(substring-after(request:get-uri(), $app:APP_ROOT))
};

declare function side:generate-section-nav($uri as xs:string) as element(div)? {
  let $site-section := '/' || (tokenize($uri,'/')[. ne ''])[1]
  let $section-title := site:call-with-parameters-for-uri-steps($site-section, $site:config, pages:generate-breadcrumb-label#1)[2]
  let $section-links := site:call-for-uri-step-children($site-section, $site:config, pages:generate-breadcrumb-link#1, map{'exclude-role': 'section-nav', 'skip-role': 'section-nav'})
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
