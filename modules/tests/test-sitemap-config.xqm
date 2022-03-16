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

declare %test:assertEquals('urlset') function x:test-build-map-root(){
  site:build-map($x:sample/site:root) => local-name()
};
