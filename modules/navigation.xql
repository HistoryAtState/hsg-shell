(:
 :
 :  Copyright (C) 2017 Wolfgang Meier
 :
 :  This program is free software: you can redistribute it and/or modify
 :  it under the terms of the GNU General Public License as published by
 :  the Free Software Foundation, either version 3 of the License, or
 :  (at your option) any later version.
 :
 :  This program is distributed in the hope that it will be useful,
 :  but WITHOUT ANY WARRANTY; without even the implied warranty of
 :  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 :  GNU General Public License for more details.
 :
 :  You should have received a copy of the GNU General Public License
 :  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 :)
xquery version "3.1";

module namespace nav="http://www.tei-c.org/tei-simple/navigation";

declare function nav:document-type($div as element()) {
    switch (namespace-uri($div))
        case "http://www.tei-c.org/ns/1.0" return
            "tei"
        case "http://docbook.org/ns/docbook" return
            "docbook"
        default return
            "jats"
};

declare %private function nav:dispatch($config as map(*), $function as xs:string, $args as array(*)) {
    let $fn := function-lookup(xs:QName($config?type || "-nav:" || $function), array:size($args))
    return
        if (exists($fn)) then
            apply($fn, $args)
        else
            ()
};

(:
declare function nav:get-root($root as xs:string?, $options as map(*)?) {
    tei-nav:get-root($root, $options),
    docbook-nav:get-root($root, $options)
};
:)

declare function nav:get-header($config as map(*), $node as element()) {
    nav:dispatch($config, "get-header", [$config, $node])
};

declare function nav:get-section-for-node($config as map(*), $node as element()) {
    nav:dispatch($config, "get-section-for-node", [$config, $node])
};

declare function nav:get-section($config as map(*), $doc as document-node()) {
    nav:dispatch($config, "get-section", [$config, $doc])
};

(:
declare function nav:get-metadata($config as map(*), $root as element(), $field as xs:string) {
    nav:dispatch($config, "get-metadata", [$config, $root, $field])
};
:)

declare function nav:get-document-title($config as map(*), $root as element()) {
    nav:dispatch($config, "get-document-title", [$config, $root])
};

declare function nav:get-subsections($config as map(*), $root as node()) {
    nav:dispatch($config, "get-subsections", [$config, $root])
};

declare function nav:get-section-heading($config as map(*), $section as node()) {
    nav:dispatch($config, "get-section-heading", [$config, $section])
};

declare function nav:get-first-page-start($config as map(*), $data as node()) {
    nav:dispatch($config, "get-first-page-start", [$config, $data])
};

declare function nav:sort($sort-by as xs:string, $items as element()*) {
    if (empty($items)) then
        ()
    else
        nav:dispatch(map { "type": nav:document-type(head($items)) }, "sort", [$sort-by, $items])
};

declare function nav:get-content($config as map(*), $div as element()) {
    nav:dispatch($config, "get-content", [$config, $div])
};

declare function nav:get-next($config as map(*), $div as element(), $view as xs:string) {
    nav:dispatch($config, "get-next", [$config, $div, $view])
};

declare function nav:get-previous($config as map(*), $div as element(), $view as xs:string) {
    nav:dispatch($config, "get-previous", [$config, $div, $view])
};

declare function nav:get-previous-div($config as map(*), $div as element()) {
    nav:dispatch($config, "get-previous-div", [$config, $div])
};

declare function nav:output-footnotes($footnotes as element()*) {
    <div class="footnotes">
        <ol>
        {
            for $note in $footnotes
            order by number($note/@value)
            return
                $note
        }
        </ol>
    </div>
};

declare function nav:index($config as map(*), $root) {
    nav:dispatch($config, "index", [$config, $root])
};
