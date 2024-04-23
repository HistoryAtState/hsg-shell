xquery version "3.1";

import module namespace site="http://ns.evolvedbinary.com/sitemap" at "/db/apps/hsg-shell/modules/sitemap-config.xqm";

let $full   := doc('/db/apps/hsg-shell/urls.xml')
let $_ := util:log("info", "start generating sitemap")    
let $generate := site:build-map($full/*)
let $_ := util:log("info", "finished generating sitemap")    
return
    "success"