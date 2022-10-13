xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-sitemap-config";

import module namespace site="http://ns.evolvedbinary.com/sitemap" at "../sitemap-config.xqm";

declare default element namespace "http://www.sitemaps.org/schemas/sitemap/0.9";
declare namespace u="http://www.sitemaps.org/schemas/sitemap/0.9";
declare namespace test="http://exist-db.org/xquery/xqsuite";

declare variable $x:sample := doc('../../tests/data/sitemap-config/sitemap-config.xml');

declare %test:assertEquals('Hello World') function x:test-hello-world(){
  site:hello-world('World')
};

declare %test:assertEquals('Hello Bo Selecta') function x:test-mode-selector(){
  site:mode-selector('test')('Bo Selecta')
};

declare %test:assertEquals('Hello Kitty') function x:test-mode-templates-key(){
  site:mode-templates('test') => map:keys()
};

declare %test:assertEquals('Hello Dave') function x:test-mode-templates-fn(){
  site:mode-templates('test')?('Hello Kitty')('Dave')
};

declare %test:asssertEquals('ancient and modern') function x:test-state-config-merge(){
  let $state := map{
    'config': map{
      'same': 'ancient',
      'changed': 'old'
    }
  }
  let $config := map{
    'changed': 'modern'
  }
  let $result := site:state-config-merge($state, $config)
  return $result?same||' and '||$result?changed
};

declare %test:assertEquals('biscuit barrel') function x:test-config-merge-combine(){
  let $maps as map(*)* := (
    map{'combine': 'biscuit'},
    map{'combine': 'barrel'}
  )
  return site:config-merge($maps)?combine => string-join(" ")
};

declare %test:assertEquals('biscuit') function x:test-config-merge-use-first(){
  let $maps as map(*)* := (
    map{'use-first': 'biscuit'},
    map{'use-first': 'barrel'}
  )
  return site:config-merge($maps)?use-first => string-join(" ")
};

declare %test:assertEquals('barrel') function x:test-config-merge-use-last(){
  let $maps as map(*)* := (
    map{'use-last': 'biscuit'},
    map{'use-last': 'barrel'}
  )
  return site:config-merge($maps)?use-last => string-join(" ")
};

declare %test:assertEquals('barrel') function x:test-config-merge-default(){
  let $maps as map(*)* := (
    map{'something': 'biscuit'},
    map{'something': 'barrel'}
  )
  return site:config-merge($maps)?something => string-join(" ")
};

declare %test:assertEquals('/db/apps/hsg-shell/tests/data/sitemap-config') function x:test-config-root-urls(){
  (: Tests the config returned from the root by exampining the file part of the source for the URL '/' :)
  
  let $state := map{}
  
  return site:get-config($x:sample/site:root, $state)?urls?('/')?filepath
};

declare %test:assertEquals('/db/apps/hsg-shell/tests/data/sitemap-config') function x:test-config-step-music-urls(){
  let $state:= map{
    'config': map{
      'urls': map{
        '/': map{
          'filepath': '/db/apps/hsg-shell/tests/data/sitemap-config'
        }
      }
    }
  }
  
  return site:get-config($x:sample/site:root/site:step[@value eq 'music'], $state)?urls?('/music')?filepath
};

declare %test:assertEquals('/db/apps/hsg-shell/tests/data/sitemap-config') function x:test-config-step-value-music-urls(){
  let $state:= map{
    'config': map{
      'parent-urls': map{
        '/': map{
          'filepath': '/db/apps/hsg-shell/tests/data/sitemap-config'
        }
      }
    }
  }
  
  return site:get-config($x:sample/site:root/site:step[@value eq 'music']/@value, $state)?urls?('/music')?filepath
};

declare %test:assertEquals('/db/apps/hsg-shell/tests/data/sitemap-config/Collection/music-library/beck') function x:test-config-step-artist-urls(){
  let $state:= map{
    'config': map{
      'urls': map{
        '/music': map{
          'filepath': '/db/apps/hsg-shell/tests/data/sitemap-config'
        }
      }
    }
  }
  
  return site:get-config($x:sample/site:root/site:step[@value eq 'music']/site:step[@key eq 'artist'], $state)?urls?('/music/beck')?filepath
};

declare %test:assertEquals('/db/apps/hsg-shell/tests/data/sitemap-config/Collection/music-library/beck/odelay.xml') function x:test-config-step-album-urls(){
  let $state:= map{
    'config': map{
      'urls': map{
        '/music/beck': map{
          'filepath': '/db/apps/hsg-shell/tests/data/sitemap-config/Collection/music-library/beck'
        }
      }
    }
  }
  
  return site:get-config($x:sample/site:root/site:step[@value eq 'music']/site:step[@key eq 'artist']/site:step[@key eq 'album'], $state)?urls?('/music/beck/odelay')?filepath
};

declare %test:assertEquals('/db/apps/hsg-shell/tests/data/sitemap-config/Collection/music-library/beck/odelay.xml') function x:test-config-step-trackNo-urls-filepath(){
  let $state:= map{
    'config': map{
      'urls': map{
        '/music/beck/odelay': map{
          'filepath': '/db/apps/hsg-shell/tests/data/sitemap-config/Collection/music-library/beck/odelay.xml'
        }
      }
    }
  }
  
  return site:get-config($x:sample/site:root/site:step[@value eq 'music']/site:step[@key eq 'artist']/site:step[@key eq 'album']/site:step[@key eq 'trackNo'], $state)?urls?('/music/beck/odelay/2')?filepath

};

declare %test:assertEquals(".//track/metadata[@key='Track Number']") function x:test-config-step-trackNo-urls-xq(){
  let $state:= map{
    'config': map{
      'urls': map{
        '/music/beck/odelay': map{
          'filepath': '/db/apps/hsg-shell/tests/data/sitemap-config/Collection/music-library/beck/odelay.xml'
        }
      }
    }
  }
  
  return site:get-config($x:sample/site:root/site:step[@value eq 'music']/site:step[@key eq 'artist']/site:step[@key eq 'album']/site:step[@key eq 'trackNo'], $state)?urls?('/music/beck/odelay/2')?xq

};

declare %test:assertEquals('/db/apps/hsg-shell/tests/data/sitemap-config/Collection/music-library/beck/the%20information.xml') function x:test-config-step-trackName-filepath(){
  let $state:= map{
    'config': map{
      'urls': map{
        '/music/tracks': map{
          'filepath': '/db/apps/hsg-shell/tests/data/sitemap-config'
        }
      }
    }
  }
  
  return site:get-config($x:sample/site:root/site:step[@value eq 'music']/site:step[@value eq 'tracks']/site:step[@key eq 'trackName'], $state)?urls?('/music/tracks/The%20Horrible%20Fanfare%2FLandslide%2FExoskelton')?filepath
};

declare %test:assertEquals(".//track/metadata[@key='Name']") function x:test-config-step-trackName-xq(){
  let $state:= map{
    'config': map{
      'urls': map{
        '/music/tracks': map{
          'filepath': '/db/apps/hsg-shell/tests/data/sitemap-config'
        }
      }
    }
  }
  
  return site:get-config($x:sample/site:root/site:step[@value eq 'music']/site:step[@value eq 'tracks']/site:step[@key eq 'trackName'], $state)?urls?('/music/tracks/Hotwax')?xq
};

declare %test:assertEquals(
  "/db/apps/hsg-shell/tests/data/sitemap-config/Collection/music-library/lenny%20kravitz/5.xml",
  "/db/apps/hsg-shell/tests/data/sitemap-config/Collection/music-library/magpie%20lane/jack-in-the-green.xml",
  "/db/apps/hsg-shell/tests/data/sitemap-config/Collection/music-library/morcheeba/big%20calm.xml"
) function x:test-config-step-year-filepath(){
  let $state:= map{
    "config": map{
        "urls": map {
            "/music/by-year": map {
                "filepath": "/db/apps/hsg-shell/tests/data/sitemap-config"
            }
        }
    }
  }
  for $filepath in site:get-config($x:sample/site:root/site:step[@value eq 'music']/site:step[@value eq 'by-year']/site:step[@key eq 'year'], $state)?urls?('/music/by-year/1998')?filepath
  order by $filepath
  return $filepath
};

declare %test:assertEquals("beck") function x:test-config-step-album-key-artist(){
    let $state:= map{
        'config': map {
            "urls": map {
                "/music/beck": map {
                    "filepath": "/db/apps/hsg-shell/tests/data/sitemap-config/Collection/music-library/beck",
                    "keys": map {
                        "artist": "beck"
                    }
                }
            }
        }
    }
    let $sample := $x:sample/site:root/site:step[@value eq 'music']/site:step[@key eq 'artist']/site:step[@key eq 'album']

    return site:get-config($sample, $state)?urls?('/music/beck/odelay')?keys?artist
};

declare %test:assertEquals('/db/apps/hsg-shell/tests/data/sitemap-config/Collection/world-factbook/country-data.xml') function x:test-config-step-region-filepath(){
  let $state := map {
    "config": map {
        "urls": map {
            "/world": map {
                "filepath": "/db/apps/hsg-shell/tests/data/sitemap-config"
            }
        }
    }
  }
  let $sample := $x:sample/site:root/site:step[@value='world']/site:step[@key='region']
  return distinct-values(site:get-config($sample, $state)?urls?('/world/Africa')?filepath)
};

declare %test:assertEquals('pages/artist/morcheeba.xml') function x:test-eval-avt(){
  let $page-template as element(site:page-template):= $x:sample/site:root/site:step[@value eq 'music']/site:step[@key eq 'artist']/site:page-template
  let $key := map{
    'artist': 'morcheeba'
  }
  return site:eval-avt($page-template/@href, false(), (xs:QName('site:key'), $key))
};

declare %test:assertEquals('/db/apps/hsg-shell/tests/data/sitemap-config/Collection/world-factbook/country-data.xml') function x:test-get-urls-from-collection-non-binary(){
  site:get-urls-from-collection('/db/apps/hsg-shell/tests/data/sitemap-config/Collection/world-factbook')
};

declare %test:assertEquals('foo') function x:test-call-with-parameters-for-steps-value(){
  site:call-with-parameters-for-uri-steps('/music/beck/odelay/2', $x:sample/*, function($state){$state?parameters?value})
};

declare %test:assertEquals('bar') function x:test-call-with-parameters-for-steps-select(){
  site:call-with-parameters-for-uri-steps('/music/beck/odelay/2', $x:sample/*, function($state){$state?parameters?select})
};

declare %test:assertEquals('2') function x:test-call-with-parameters-for-steps-keyval(){
  site:call-with-parameters-for-uri-steps('/music/beck/odelay/2', $x:sample/*, function($state){$state?parameters?track})
};

declare %test:assertEquals('3') function x:test-call-with-parameters-for-steps-all-steps(){
  site:call-with-parameters-for-uri-steps('/music/beck/odelay/2', $x:sample/*, function($state){$state?parameters?artist})[. eq 'beck'] => count()
};

declare %test:assertEquals('/db/apps/hsg-shell/tests/data/sitemap-config/pages/artist/beck.xml') function x:test-call-with-parameters-for-steps-page-template(){
  site:call-with-parameters-for-uri-steps('/music/beck', $x:sample/*, function($state){$state?page-template})[2]
};

declare %test:assertEquals('true') function x:test-urls-root(){
    let $cfg :=
        <root xmlns="http://ns.evolvedbinary.com/sitemap" xmlns:site="http://ns.evolvedbinary.com/sitemap">
            <step value="countries">
                <page-template href="pages/countries/index.xml">
                    <with-param name="publication-id" value="countries"/>
                </page-template>
                <config>
                    <src collection="/db/apps/rdcr"/>
                </config>
            </step>
        </root>
    let $expected := 
        map {
            "urls": map {
                "/": map {
                    "filepath": "/"
                }
            }
        }
    let $result := site:get-config($cfg, map{})
    
    return 
        if (deep-equal($expected, $result)) then
            'true' 
        else (
            <expected>{serialize($expected, map{'method': 'adaptive','indent': true()})}</expected>,
            <result>{serialize($result, map{'method': 'adaptive','indent': true()})}</result>
        )
};

declare %test:assertEquals('true') function x:test-urls-step-value(){
    let $cfg :=
        <root xmlns="http://ns.evolvedbinary.com/sitemap" xmlns:site="http://ns.evolvedbinary.com/sitemap">
            <step value="countries">
                <page-template href="pages/countries/index.xml">
                    <with-param name="publication-id" value="countries"/>
                </page-template>
                <config>
                    <src collection="/db/apps/rdcr"/>
                </config>
            </step>
        </root>
    let $root.state := map{"config": site:get-config($cfg, map{})}
    let $expected := 
        map {
            "urls": map {
                "/countries": map {
                    "filepath": "/db/apps/rdcr",
                    "keys": ()
                }
            }
        }
    let $result := site:get-config($cfg/site:step, $root.state)
    
    return 
        if (deep-equal($expected, $result)) then
            'true' 
        else (
            <expected>{serialize($expected, map{'method': 'adaptive','indent': true()})}</expected>,
            <result>{serialize($result, map{'method': 'adaptive','indent': true()})}</result>
        )
};

declare %test:assertEquals('true') function x:test-urls-step-value-sub-collection(){
    let $cfg :=
        <root xmlns="http://ns.evolvedbinary.com/sitemap" xmlns:site="http://ns.evolvedbinary.com/sitemap">
            <step value="countries">
                <step value="by-country">
                    <page-template href="pages/countries/by-country.xml"/>
                    <config>
                        <src collection="articles"/>
                    </config>
                </step>
                <page-template href="pages/countries/index.xml">
                    <with-param name="publication-id" value="countries"/>
                </page-template>
                <config>
                    <src collection="/db/apps/rdcr"/>
                </config>
            </step>
        </root>
    let $countries.state := 
        map{
            "config": map {
                "urls": map {
                    "/countries": map {
                        "filepath": "/db/apps/rdcr",
                        "keys": ()
                    } 
                } 
            }
        }
    let $expected := 
        map {
            "urls": map {
                "/countries/by-country": map {
                    "filepath": "/db/apps/rdcr/articles",
                    "keys": ()
                } 
            } 
        }
    let $result := site:get-config($cfg/site:step/site:step[@value eq 'by-country'], $countries.state)
    
    return 
        if (deep-equal($expected, $result)) then
            'true' 
        else (
            <expected>{serialize($expected, map{'method': 'adaptive','indent': true()})}</expected>,
            <result>{serialize($result, map{'method': 'adaptive','indent': true()})}</result>
        )
};

declare %test:assertEquals('true') function x:test-urls-step-key(){
    let $cfg :=
        <root xmlns="http://ns.evolvedbinary.com/sitemap" xmlns:site="http://ns.evolvedbinary.com/sitemap">
            <step value="countries">
                <step value="by-country">
                    <step key="country">
                        <page-template href="pages/countries/article.xml">
                            <with-param name="publication-id" value="countries"/>
                            <with-param name="document-id" keyval="country"/>
                        </page-template>
                        <config>
                            <src collection="."/>
                        </config>
                    </step>
                    <page-template href="pages/countries/by-country.xml"/>
                    <config>
                        <src collection="articles"/>
                    </config>
                </step>
                <page-template href="pages/countries/index.xml">
                    <with-param name="publication-id" value="countries"/>
                </page-template>
                <config>
                    <src collection="/db/apps/rdcr"/>
                </config>
            </step>
        </root>
    let $by-country.state := 
        map{
            "config": map {
                "urls": map {
                    "/countries/by-country": map {
                        "filepath": "/db/apps/rdcr/articles",
                        "keys": ()
                    } 
                } 
            }
        }
    let $expected :=  map {
        "filepath": "/db/apps/rdcr/articles/fiji.xml",
        "keys": map{ 'country': 'fiji' }
    }
    let $result := site:get-config($cfg/site:step/site:step[@value eq 'by-country']/site:step, $by-country.state)?urls?("/countries/by-country/fiji")
    
    return 
        if (deep-equal($expected, $result)) then
            'true' 
        else (
            <expected>{serialize($expected, map{'method': 'adaptive','indent': true()})}</expected>,
            <result>{serialize($result, map{'method': 'adaptive','indent': true()})}</result>
        )
};

declare %test:assertEquals('true') function x:test-urls-step-key-sub-collection-names(){
    let $cfg :=
        <root xmlns="http://ns.evolvedbinary.com/sitemap" xmlns:site="http://ns.evolvedbinary.com/sitemap">
            <step key="person">
                <page-template href="pages/departmenthistory/people/person.xml"/>
                <config>
                    <src collection="/db/apps/pocom/people"/>
                </config>
            </step>
        </root>
    let $root.state := map{"config": site:get-config($cfg, map{})}
    let $expected := map {
        "filepath": "/db/apps/pocom/people/b/bellocchi-natale-h.xml",
        "keys": map {
            "person": "bellocchi-natale-h"
        }
    }
    let $result := site:get-config($cfg/site:step, $root.state)?urls?('/bellocchi-natale-h')
    
    return 
        if (deep-equal($expected, $result)) then
            'true' 
        else (
            <expected>{serialize($expected, map{'method': 'adaptive','indent': true()})}</expected>,
            <result>{serialize($result, map{'method': 'adaptive','indent': true()})}</result>
        )
};
