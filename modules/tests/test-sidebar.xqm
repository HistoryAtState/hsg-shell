xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/sidebar";
import module namespace t="http://history.state.gov/ns/site/hsg/xqsuite" at "../xqsuite.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "../pages.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "../config.xqm";
import module namespace side="http://history.state.gov/ns/site/hsg/sidebar" at "../sidebar.xqm";
import module namespace templates="http://exist-db.org/xquery/html-templating";

declare namespace test="http://exist-db.org/xquery/xqsuite";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace hsg="http://history.state.gov/ns/site/hsg";

(: testing for section navigation sidebar :)

declare variable $x:sitemap := 
  <root xmlns="http://ns.evolvedbinary.com/sitemap" xmlns:site="http://ns.evolvedbinary.com/sitemap">
    <step value="departmenthistory">
     <step value="timeline">
       <step key="section">
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/timeline/section.xml">
           <with-param name="publication-id" value="timeline"/>
           <with-param name="document-id" value="timeline"/>
           <with-param name="section-id" keyval="section"/>
         </page-template>
         <config>
           <src doc="/db/apps/administrative-timeline/timeline/timeline.xml" xq=".//@xml:id"/>
         </config>
       </step>
       <page-template href="/db/apps/hsg-shell/pages/departmenthistory/timeline/index.xml">
         <with-param name="publication-id" value="timeline"/>
         <with-param name="document-id" value="timeline"/>
       </page-template>
     </step>
     <step value="short-history">
       <step key="section">
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/short-history/section.xml">
           <with-param name="publication-id" value="short-history"/>
           <with-param name="document-id" value="short-history"/>
           <with-param name="section-id" keyval="section"/>
         </page-template>
         <config>
           <src doc="/db/apps/other-publications/short-history/short-history.xml" xq=".//@xml:id"/>
         </config>
       </step>
       <page-template href="/db/apps/hsg-shell/pages/departmenthistory/short-history/index.xml">
         <with-param name="publication-id" value="short-history"/>
         <with-param name="document-id" value="short-history"/>
       </page-template>
       <config>
         <section-nav-exclude/>
       </config>
     </step>
     <step value="buildings">
       <step key="section">
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/buildings/section.xml">
           <with-param name="publication-id" value="buildings"/>
           <with-param name="document-id" value="buildings"/>
           <with-param name="section-id" keyval="section"/>
         </page-template>
         <config>
           <src doc="/db/apps/other-publications/buildings/buildings.xml" xq=".//@xml:id"/>
         </config>
       </step>
       <page-template href="/db/apps/hsg-shell/pages/departmenthistory/buildings/index.xml">
         <with-param name="publication-id" value="buildings"/>
         <with-param name="document-id" value="buildings"/>
         <with-param name="section-id" value="intro"/>
       </page-template>
     </step>
     <step value="people">
       <step value="secretaries">
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/people/secretaries.xml">
           <with-param name="publication-id" value="secretaries"/>
         </page-template>
       </step>
       <step value="principals-chiefs">
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/people/principals-chiefs.xml">
           <with-param name="publication-id" value="principals-chiefs"/>
         </page-template>
       </step>
       <step value="by-name">
         <step key="letter">
           <page-template href="/db/apps/hsg-shell/pages/departmenthistory/people/by-name/letter.xml">
             <with-param name="publication-id" value="people-by-alpha"/>
             <with-param name="letter" keyval="letter"/>
           </page-template>
           <config>
             <src child-collections="/db/apps/pocom/people"/>
           </config>
         </step>
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/people/by-name/index.xml">
           <with-param name="publication-id" value="people-by-alpha"/>
         </page-template>
         <config>
           <section-nav-exclude/>
         </config>
       </step>
       <step value="by-year">
         <step key="year">
           <page-template href="/db/apps/hsg-shell/pages/departmenthistory/people/by-year/year.xml">
             <with-param name="publication-id" value="people-by-year"/>
             <with-param name="year" keyval="year"/>
           </page-template>
           <config>
             <src collection="/db/apps/pocom" xq="distinct-values(for $date in .//date[not(. = '')] return xs:integer(substring($date, 1, 4)))"/>
           </config>
         </step>
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/people/by-year/index.xml">
           <with-param name="publication-id" value="people-by-year"/>
         </page-template>
         <config>
           <section-nav-exclude/>
         </config>
       </step>
       <step value="principalofficers">
         <step key="role">
           <page-template href="/db/apps/hsg-shell/pages/departmenthistory/people/principalofficers/by-role-id.xml">
             <with-param name="publication-id" value="people-by-role"/>
             <with-param name="role-id" keyval="role"/>
           </page-template>
           <config>
             <src collection="/db/apps/pocom/positions-principals"/>
           </config>
         </step>
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/people/principalofficers/index.xml">
           <with-param name="publication-id" value="people"/>
         </page-template>
         <config>
           <section-nav-exclude/>
         </config>
       </step>
       <step value="chiefsofmission">
         <step value="by-country">
           <page-template href="/db/apps/hsg-shell/pages/departmenthistory/people/chiefsofmission/countries-list.xml">
             <with-param name="publication-id" value="people"/>
           </page-template>
         </step>
         <step value="by-organization">
           <page-template href="/db/apps/hsg-shell/pages/departmenthistory/people/chiefsofmission/international-organizations-list.xml">
             <with-param name="publication-id" value="people"/>
           </page-template>
         </step>
         <step key="org">
           <page-template href="/db/apps/hsg-shell/pages/departmenthistory/people/chiefsofmission/by-role-or-country-id.xml">
             <with-param name="publication-id" value="people"/>
             <with-param name="role-or-country-id" keyval="org"/>
           </page-template>
           <config>
             <src collection="/db/apps/pocom/missions-orgs"/>
             <src collection="/db/apps/pocom/missions-countries"/>
           </config>
         </step>
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/people/chiefsofmission/index.xml">
           <with-param name="publication-id" value="people"/>
         </page-template>
         <config>
           <section-nav-exclude/>
         </config>
       </step>
       <step key="person">
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/people/person.xml">
           <with-param name="person-id" keyval="person"/>
           <with-param name="document-id" keyval="person"/>
           <with-param name="publication-id" value="people"/>
         </page-template>
         <config>
           <src collection="/db/apps/pocom/people"/>
         </config>
       </step>
       <page-template href="/db/apps/hsg-shell/pages/departmenthistory/people/index.xml">
         <with-param name="publication-id" value="people"/>
       </page-template>
       <config>
         <section-nav-skip/>
       </config>
     </step>
     <step value="travels">
       <step value="president">
         <step key="id">
           <page-template href="/db/apps/hsg-shell/pages/departmenthistory/travels/president/person-or-country.xml">
             <with-param name="person-or-country-id" keyval="id"/>
             <with-param name="publication-id" value="travels-president"/>
           </page-template>
           <config>
             <src collection="/db/apps/travels/president-travels" xq="trips/trip/@who"/>
             <src collection="/db/apps/travels/president-travels" xq="distinct-values(trips/trip/country/@id)"/>
           </config>
         </step>
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/travels/president/index.xml">
           <with-param name="publication-id" value="travels-president"/>
         </page-template>
       </step>
       <step value="secretary">
         <step key="id">
           <page-template href="/db/apps/hsg-shell/pages/departmenthistory/travels/secretary/person-or-country.xml">
             <with-param name="person-or-country-id" keyval="id"/>
             <with-param name="publication-id" value="travels-secretary"/>
           </page-template>
           <config>
             <src collection="/db/apps/travels/secretary-travels" xq="distinct-values(trips/trip/@who)"/>
             <src collection="/db/apps/travels/secretary-travels" xq="distinct-values(trips/trip/country/@id)"/>
           </config>
         </step>
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/travels/secretary/index.xml">
           <with-param name="publication-id" value="travels-secretary"/>
         </page-template>
       </step>
       <page-template href="/db/apps/hsg-shell/pages/departmenthistory/travels/index.xml">
         <with-param name="publication-id" value="travels-secretary"/>
       </page-template>
       <config>
         <section-nav-skip/>
       </config>
     </step>
     <step value="visits">
       <step key="id">
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/visits/country-or-year.xml">
           <with-param name="publication-id" value="visits"/>
           <with-param name="country-or-year" keyval="id"/>
         </page-template>
         <config>
           <src collection="/db/apps/visits/data" xq="distinct-values(             for $date in .//(start-date | end-date)             let $year := year-from-date($date)             return $year           )"/>
           <src collection="/db/apps/visits/data" xq="visits/visit/from/@id"/>
         </config>
       </step>
       <page-template href="/db/apps/hsg-shell/pages/departmenthistory/visits/index.xml">
         <with-param name="publication-id" value="visits"/>
       </page-template>
     </step>
     <step value="wwi">
       <page-template href="/db/apps/hsg-shell/pages/departmenthistory/wwi.xml">
         <with-param name="publication-id" value="wwi"/>
       </page-template>
     </step>
     <step value="diplomatic-couriers">
       <step value="before-the-jet-age">
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/diplomatic-couriers/before-the-jet-age.xml">
           <with-param name="publication-id" value="diplomatic-couriers"/>
           <with-param name="film-id" value="before-the-jet-age"/>
         </page-template>
       </step>
       <step value="behind-the-iron-curtain">
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/diplomatic-couriers/behind-the-iron-curtain.xml">
           <with-param name="publication-id" value="diplomatic-couriers"/>
           <with-param name="film-id" value="behind-the-iron-curtain"/>
         </page-template>
       </step>
       <step value="into-moscow">
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/diplomatic-couriers/into-moscow.xml">
           <with-param name="publication-id" value="diplomatic-couriers"/>
           <with-param name="film-id" value="into-moscow"/>
         </page-template>
       </step>
       <step value="through-the-khyber-pass">
         <page-template href="/db/apps/hsg-shell/pages/departmenthistory/diplomatic-couriers/through-the-khyber-pass.xml">
           <with-param name="publication-id" value="diplomatic-couriers"/>
           <with-param name="film-id" value="through-the-khyber-pass"/>
         </page-template>
       </step>
       <page-template href="/db/apps/hsg-shell/pages/departmenthistory/diplomatic-couriers/index.xml">
         <with-param name="publication-id" value="diplomatic-couriers"/>
       </page-template>
     </step>
     <page-template href="/db/apps/hsg-shell/pages/departmenthistory/index.xml">
       <with-param name="publication-id" value="departmenthistory"/>
     </page-template>
   </step>
  </root>
;

declare variable $x:expected := 
    <aside id="sections" class="hsg-aside--section">
        <div class="hsg-panel">
            <div class="hsg-panel-heading">
                <h2 class="hsg-sidebar-title">Department History</h2>
            </div>
            <ul class="hsg-list-group">
                <li class="hsg-list-group-item">
                    <a href="/exist/apps/hsg-shell/departmenthistory/timeline">
                        <span>Administrative Timeline</span>
                    </a>
                </li>
                <li class="hsg-list-group-item">
                    <a href="/exist/apps/hsg-shell/departmenthistory/buildings">
                        <span>Buildings of the Department</span> 
                    </a>
                </li>
                <li class="hsg-list-group-item">
                    <a href="/exist/apps/hsg-shell/departmenthistory/people/secretaries">
                        <span>Biographies of the Secretaries of State</span> 
                    </a>
                </li>
                <li class="hsg-list-group-item">
                    <a href="/exist/apps/hsg-shell/departmenthistory/people/principals-chiefs">
                        <span>Principal Officers and Chiefs of Mission</span> 
                    </a>
                </li>
                <li class="hsg-list-group-item">
                    <a href="/exist/apps/hsg-shell/departmenthistory/travels/president">
                        <span>Travels of the President</span> 
                    </a>
                </li>
                <li class="hsg-list-group-item">
                    <a href="/exist/apps/hsg-shell/departmenthistory/travels/secretary">
                        <span>Travels of the Secretary</span> 
                    </a>
                </li>
                <li class="hsg-list-group-item">
                    <a href="/exist/apps/hsg-shell/departmenthistory/visits">
                        <span>Visits by Foreign Leaders</span> 
                    </a>
                </li>
                <li class="hsg-list-group-item">
                    <a href="/exist/apps/hsg-shell/departmenthistory/wwi">
                        <span>World War I and the Department</span> 
                    </a>
                </li>
                <li class="hsg-list-group-item">
                    <a href="/exist/apps/hsg-shell/departmenthistory/diplomatic-couriers">
                        <span>U.S. Diplomatic Couriers</span> 
                    </a>
                </li>
            </ul>
        </div>
    </aside>
;

(:
 :  WHEN generating a section nav panel
 :  GIVEN a top level url ("/departmenthistory")
 :  THEN return the generated section nav panel
 :)

declare %test:assertEquals('true') function x:section-nav-toplevel(){
  let $result := side:generate-section-nav('/departmenthistory')
  return if (deep-equal($x:expected, $result)) 
  then 'true' 
  else (<result>{$result}</result>, <expected>{$x:expected}</expected>)
};

(:
 :  WHEN generating a section nav panel
 :  GIVEN a lower level url ("/departmenthistory/travels/secretary/root-elihu")
 :  THEN return the same generated section nav panel as for the top level
 :)

declare %test:assertEquals('true') function x:section-nav-bottomlevel(){
  let $result   := side:generate-section-nav('/departmenthistory/travels/secretary/root-elihu')
  let $expected := side:generate-section-nav('/departmenthistory')
  return if (deep-equal($expected, $result)) then
    'true' 
  else (<result>{$result}</result>, <expected>{$expected}</expected>)
};

declare variable $x:github-config as element() := doc('/db/apps/hsg-shell/tests/data/asides/github-config.xml')/*;

(:
 :  WHEN calling side:github-url()
 :  GIVEN a site-config (e.g. $x:github-config)
 :  GIVEN a site URI without a corresponding github entry in the site config (e.g. '/no-github')
 :  THEN return ()
 :)
declare %test:assertEmpty function x:side-github-url-no-github(){
    side:github-url('/no-github', $x:github-config)
};

(:
 :  WHEN calling side:github-url()
 :  GIVEN a site-config
 :  GIVEN a site URI corresponding to a github entry in the site config (e.g. '/github-parent')
 :  THEN return the corresponding URI (e.g. 'https://github.com/example/parent')
 :)
declare %test:assertEquals('https://github.com/example/parent') function x:side-github-url-parent-github(){
    side:github-url('/github-parent', $x:github-config)
};

(:
 :  WHEN calling side:github-url()
 :  GIVEN a site-config
 :  GIVEN a site URI inheriting a github entry in the site config (e.g. '/github-parent/inherited-child')
 :  THEN return the corresponding URI (e.g. 'https://github.com/example/parent')
 :)
declare %test:assertEquals('https://github.com/example/parent') function x:side-github-url-inherited-child() {
    side:github-url('/github-parent/inherited-child', $x:github-config)
};

(:
 :  WHEN calling side:github-url()
 :  GIVEN a site-config
 :  GIVEN a site URI associated with a (changed) github entry in the site config (e.g. '/github-parent/github-child/inherited-grandchild')
 :  THEN return the corresponding URI (e.g. 'https://github.com/example/child')
 :)
declare %test:assertEquals('https://github.com/example/child') function x:side-github-url-github-child() {
    side:github-url('/github-parent/github-child', $x:github-config)
};

(:
 :  WHEN calling side:github-url()
 :  GIVEN a site-config
 :  GIVEN a site URI associated with an inherited (changed) github entry in the site config (e.g. '/github-parent/github-child/inherited-grandchild')
 :  THEN return the corresponding URI (e.g. 'https://github.com/example/child')
 :)
declare %test:assertEquals('https://github.com/example/child') function x:side-github-url-inherited-grandchild() {
    side:github-url('/github-parent/github-child/inherited-grandchild', $x:github-config)
};

(:
 :  WHEN calling side:github-url()
 :  GIVEN a site-config
 :  GIVEN a site URI associated with an empty github entry in the site config (e.g. '/github-parent/no-github-child')
 :  THEN return ()
 :)
declare %test:assertEmpty function x:side-github-url-no-github-child(){
    side:github-url('/github-parent/no-github-child', $x:github-config)
};

(:
 :  WHEN calling side:github-url()
 :  GIVEN a site-config
 :  GIVEN a site URI associated with an inherited empty github entry in the site config (e.g. '/github-parent/no-github-child/inherited-no-child')
 :  THEN return ()
 :)
declare %test:assertEmpty function x:side-github-url-no-github-inherited-no-child(){
    side:github-url('/github-parent/no-github-child/inherited-no-child', $x:github-config)
};