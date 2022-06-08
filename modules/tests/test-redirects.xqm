xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-redirects";

import module namespace site="http://ns.evolvedbinary.com/sitemap" at "../sitemap-config.xqm";

declare namespace test="http://exist-db.org/xquery/xqsuite";

declare variable $x:site := doc('../../tests/data/redirects/site.xml')/*;
declare variable $x:redirects as map(*)* := site:generate-redirects($x:site);

(:
 :  WHEN generating redirect config from $x:site
 :  GIVEN a URL '/countries/macedonia'
 :  THEN redirect to '/countries/north-macedonia'
 :)
 
declare %test:assertEquals("/countries/north-macedonia") function x:test-hard-coded-redirect-to(){
    $x:redirects[.?from eq '/countries/macedonia']?to
};
 
(:
 :  WHEN generating redirect config from $x:site
 :  GIVEN a URL '/countries/macedonia'
 :  THEN use the specified status code of '301' (permanent)
 :)

declare %test:assertEquals("301") function x:test-hard-coded-redirect-status(){
    $x:redirects[.?from eq '/countries/macedonia']?status
};

(:
 :  WHEN generating redirect config from $x:site
 :  GIVEN a url with an 'old' id: '/people/jones-malika'
 :  THEN redirect to the corresponding ID: '/people/james-makila'
 :)

declare %test:assertEquals("/people/james-makila") function x:test-calculated-redirect-to(){
    $x:redirects[.?from eq '/people/jones-malika']?to
};

(:
 :  WHEN generating redirect config from $x:site
 :  GIVEN a url with an 'old' id: '/people/jones-malika'
 :  THEN use the default status code of '301' (permanent)
 :)

declare %test:assertEquals("301") function x:test-calculated-redirect-status(){
    $x:redirects[.?from eq '/people/jones-malika']?status
};

(:
 :  WHEN generating redirect config from $x:site
 :  GIVEN a url with a current id: '/people/james-makila'
 :  THEN do not create a redirect
 :)

declare %test:assertTrue function x:test-calculated-redirect-no-redirect(){
    exists($x:redirects) and
    empty($x:redirects[.?from eq '/people/james-makila']?to)
};

(:
 :  WHEN generating redirect config from $x:site
 :  GIVEN a url prefix: '/departmenthistory/short-history'
 :  THEN redirect to '/publications/short-history
 :)

declare %test:assertEquals("/publications/short-history") function x:test-prefix-redirect-to(){
    $x:redirects[.?from eq '/departmenthistory/short-history']?to
};

(:
 :  WHEN generating redirect config from $x:site
 :  GIVEN a url prefix: '/departmenthistory/short-history'
 :  THEN use the specified status code of '302' (temporary)
 :)

declare %test:assertEquals("302") function x:test-prefix-redirect-status(){
    $x:redirects[.?from eq '/departmenthistory/short-history']?status
};
