(:~

    Transformation module generated from TEI ODD extensions for processing models.
    ODD: /db/apps/hsg-shell/resources/odd/source/frus.odd
 :)
xquery version "3.1";

module namespace model="http://www.tei-c.org/pm/models/frus/web";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare namespace xhtml='http://www.w3.org/1999/xhtml';

declare namespace skos='http://www.w3.org/2004/02/skos/core#';

declare namespace frus='http://history.state.gov/frus/ns/1.0';

import module namespace css="http://www.tei-c.org/tei-simple/xquery/css";

import module namespace html="http://www.tei-c.org/tei-simple/xquery/functions";

import module namespace ext-html="http://history.state.gov/ns/site/hsg/pmf-html" at "xmldb:exist:///db/apps/hsg-shell/modules/ext-html.xql";

(:~

    Main entry point for the transformation.

 :)
declare function model:transform($options as map(*), $input as node()*) {

    let $config :=
        map:merge(($options,
            map {
                "output": ["web"],
                "odd": "/db/apps/hsg-shell/resources/odd/source/frus.odd",
                "apply": model:apply#2,
                "apply-children": model:apply-children#3
            }
        ))

    return (
        html:prepare($config, $input),

        let $output := model:apply($config, $input)
        return
            html:finish($config, $output)
    )
};

declare function model:apply($config as map(*), $input as node()*) {
        let $parameters :=
        if (exists($config?parameters)) then $config?parameters else map {}
        let $mode :=
        if (exists($config?mode)) then $config?mode else ()
        let $trackIds :=
        $parameters?track-ids
        let $get :=
        model:source($parameters, ?)
    return
    $input !         (
            let $node :=
                .
            return
                            typeswitch(.)
                    case element(teiHeader) return
                        (
                            html:block($config, ., ("tei-teiHeader1", css:map-rend-to-class(.)), .),
                            html:omit($config, ., ("tei-teiHeader2", css:map-rend-to-class(.)), .)
                        )

                    case element(fileDesc) return
                        (
                            html:block($config, ., ("tei-fileDesc1", css:map-rend-to-class(.)), titleStmt),
                            html:block($config, ., ("tei-fileDesc2", css:map-rend-to-class(.)), publicationStmt)
                        )

                    case element(titleStmt) return
                        (
                            html:heading($config, ., ("tei-titleStmt1", css:map-rend-to-class(.)), title[@type="complete"], ()),
                            if (count(editor[@role = 'primary']) gt 1) then
                                html:block($config, ., ("tei-titleStmt2", css:map-rend-to-class(.)), "Editors:")
                            else
                                (),
                            if (count(editor[@role = 'primary'][. ne '']) eq 1) then
                                html:block($config, ., ("tei-titleStmt3", css:map-rend-to-class(.)), "Editor:")
                            else
                                (),
                            if (editor[@role = 'primary'][. ne '']) then
                                ext-html:list-from-items($config, ., ("tei-titleStmt4", "hsg-list-editors", css:map-rend-to-class(.)), editor[@role="primary"], ())
                            else
                                (),
                            if (editor[@role = 'general'][. ne '']) then
                                html:block($config, ., ("tei-titleStmt5", css:map-rend-to-class(.)), "General Editor:")
                            else
                                (),
                            if (editor[@role = 'general'][. ne '']) then
                                ext-html:list-from-items($config, ., ("tei-titleStmt6", "hsg-list-editors", css:map-rend-to-class(.)), editor[@role="general"], ())
                            else
                                ()
                        )

                    case element(title) return
                        if (@level = 's') then
                            html:inline($config, ., ("tei-title1", css:map-rend-to-class(.)), .)
                        else
                            html:inline($config, ., ("tei-title2", css:map-rend-to-class(.)), .)
                    case element(publicationStmt) return
                        (
                            html:block($config, ., ("tei-publicationStmt1", css:map-rend-to-class(.)), publisher),
                            html:block($config, ., ("tei-publicationStmt2", css:map-rend-to-class(.)), pubPlace),
                            html:block($config, ., ("tei-publicationStmt3", css:map-rend-to-class(.)), date[@type="publication-date"])
                        )

                    case element(publisher) return
                        html:inline($config, ., ("tei-publisher", css:map-rend-to-class(.)), .)
                    case element(pubPlace) return
                        html:inline($config, ., ("tei-pubPlace", css:map-rend-to-class(.)), .)
                    case element(date) return
                        html:inline($config, ., ("tei-date", css:map-rend-to-class(.)), .)
                    case element(hi) return
                        if (@rend = 'strong') then
                            html:inline($config, ., ("tei-hi1", css:map-rend-to-class(.)), .)
                        else
                            if (@rend = 'italic') then
                                html:inline($config, ., ("tei-hi2", "font-italic", css:map-rend-to-class(.)), .)
                            else
                                if (@rend = 'smallcaps') then
                                    html:inline($config, ., ("tei-hi3", "font-smallcaps", css:map-rend-to-class(.)), .)
                                else
                                    if (@rendition) then
                                        html:inline($config, ., css:get-rendition(., ("tei-hi4", "font-italic", css:map-rend-to-class(.))), .)
                                    else
                                        if (not(@rendition)) then
                                            html:inline($config, ., ("tei-hi5", "font-italic", css:map-rend-to-class(.)), .)
                                        else
                                            $config?apply($config, ./node())
                    case element(note) return
                        if ($parameters?omit-notes) then
                            html:omit($config, ., ("tei-note1", css:map-rend-to-class(.)), .)
                        else
                            if (@rend = 'inline') then
                                html:paragraph($config, ., ("tei-note2", css:map-rend-to-class(.)), .)
                            else
                                ext-html:note($config, ., ("tei-note3", css:map-rend-to-class(.)), ., "foot", @n/string())
                    case element(p) return
                        if (@rend = 'center') then
                            html:paragraph($config, ., css:get-rendition(., ("tei-p1", css:map-rend-to-class(.))), .)
                        else
                            if (@rend = 'flushleft') then
                                html:paragraph($config, ., css:get-rendition(., ("tei-p2", css:map-rend-to-class(.))), .)
                            else
                                html:paragraph($config, ., css:get-rendition(., ("tei-p3", css:map-rend-to-class(.))), .)
                    case element(dateline) return
                        html:block($config, ., ("tei-dateline", css:map-rend-to-class(.)), .)
                    case element(list) return
                        if (head) then
                            (
                                (: Headline for lists, level 4 will transform to html:h4 element :)
                                html:heading($config, ., ("tei-list1", "listHead", css:map-rend-to-class(.)), head/node(), 4),
                                html:list($config, ., ("tei-list2", "list", "hsg-list-default", css:map-rend-to-class(.)), item, ())
                            )

                        else
                            if (@rend = 'bulleted') then
                                html:list($config, ., ("tei-list3", "hsg-list-disc", css:map-rend-to-class(.)), item, ())
                            else
                                if (@type = ('participants', 'to', 'from', 'subject')) then
                                    html:list($config, ., ("tei-list4", "hsg-list-default", css:map-rend-to-class(.)), item, ())
                                else
                                    if (parent::list/@type = ('participants', 'to', 'from', 'subject')) then
                                        (: This is a nested list within a list-item :)
                                        html:list($config, ., ("tei-list5", css:map-rend-to-class(.)), item, ())
                                    else
                                        if (label) then
                                            html:list($config, ., ("tei-list6", "labeled-list", css:map-rend-to-class(.)), item, ())
                                        else
                                            if (ancestor::div[@xml:id='persons']) then
                                                html:list($config, ., ("tei-list7", "list-person", css:map-rend-to-class(.)), item, ())
                                            else
                                                if (ancestor::list) then
                                                    (: This is a nested list within a list :)
                                                    html:list($config, ., ("tei-list8", "hsg-nested-list", css:map-rend-to-class(.)), item, ())
                                                else
                                                    html:list($config, ., ("tei-list9", "hsg-list", css:map-rend-to-class(.)), item, ())
                    case element(head) return
                        if (parent::figure) then
                            html:block($config, ., ("tei-head1", css:map-rend-to-class(.)), .)
                        else
                            if (parent::table) then
                                html:block($config, ., ("tei-head2", css:map-rend-to-class(.)), .)
                            else
                                if (parent::list/@type = ('participants', 'to', 'from', 'subject')) then
                                    html:block($config, ., ("tei-head3", css:map-rend-to-class(.)), .)
                                else
                                    if (parent::list) then
                                        html:block($config, ., ("tei-head4", css:map-rend-to-class(.)), .)
                                    else
                                        if (parent::div and @type='shortened-for-running-head') then
                                            html:omit($config, ., ("tei-head5", css:map-rend-to-class(.)), .)
                                        else
                                            if (ancestor::frus:attachment) then
                                                html:heading($config, ., ("tei-head6", css:map-rend-to-class(.)), ., count(ancestor::div intersect ancestor::frus:attachment//div))
                                            else
                                                if (parent::div) then
                                                    html:heading($config, ., ("tei-head7", css:map-rend-to-class(.)), ., count(ancestor::div) + (if ($parameters?heading-offset) then $parameters?heading-offset else 0))
                                                else
                                                    html:block($config, ., ("tei-head8", css:map-rend-to-class(.)), .)
                    case element(div) return
                        if ($parameters?document-list and div[@type='question']) then
                            ext-html:document-list($config, ., ("tei-div1", css:map-rend-to-class(.)))
                        else
                            if ($parameters?document-list and @type = ('compilation', 'chapter', 'subchapter', 'section', 'part') and exists(div[@type and not(@type = 'online-supplement')])) then
                                ext-html:document-list($config, ., ("tei-div2", css:map-rend-to-class(.)))
                            else
                                html:block($config, ., ("tei-div3", css:map-rend-to-class(.)), .)
                    case element(xhtml:object) return
                        ext-html:passthrough($config, ., ("tei-xhtml_object", css:map-rend-to-class(.)))
                    case element(xhtml:div) return
                        ext-html:passthrough($config, ., ("tei-xhtml_div", css:map-rend-to-class(.)))
                    case element(xhtml:script) return
                        ext-html:passthrough($config, ., ("tei-xhtml_script", css:map-rend-to-class(.)))
                    case element(ref) return
                        ext-html:ref($config, ., ("tei-ref", css:map-rend-to-class(.)), .)
                    case element(pb) return
                        (
                            html:link($config, ., ("tei-pb1", css:map-rend-to-class(.)), concat('[', switch (@type) case 'facsimile' return 'Facsimile ' case 'typeset' return 'Typeset ' default return '', 'Page ', @n, ']'), (), (), map {"link": ()})
                        )

                    case element(quote) return
                        if (ancestor::p and empty(descendant::p|descendant::div)) then
                            (: If it is inside a paragraph then it is inline, otherwise it is block level; no extra quote marks around :)
                            html:inline($config, ., css:get-rendition(., ("tei-quote1", css:map-rend-to-class(.))), .)
                        else
                            (: If it is inside a paragraph then it is inline, otherwise it is block level :)
                            html:block($config, ., css:get-rendition(., ("tei-quote2", css:map-rend-to-class(.))), .)
                    case element(closer) return
                        html:block($config, ., ("tei-closer", css:map-rend-to-class(.)), .)
                    case element(table) return
                        if (.//row/@rendition or .//cell/@rendition) then
                            html:table($config, ., css:get-rendition(., ("tei-table1", css:map-rend-to-class(.))), .)
                        else
                            html:table($config, ., css:get-rendition(., ("tei-table2", "table", "table-hover", "table-bordered", css:map-rend-to-class(.))), .)
                    case element(cell) return
                        (: Insert table cell. :)
                        html:cell($config, ., css:get-rendition(., ("tei-cell", css:map-rend-to-class(.))), ., ())
                    case element(row) return
                        (: Insert table row. :)
                        html:row($config, ., css:get-rendition(., ("tei-row", css:map-rend-to-class(.))), .)
                    case element(graphic) return
                        html:graphic($config, ., css:get-rendition(., ("tei-graphic", css:map-rend-to-class(.))), .,
                            if (matches(@url, '^https?://')) then @url else ( xs:anyURI('https://static.history.state.gov/' || $parameters?base-uri ||
                            "/" || @url || (if (matches(@url, "^.*\.(jpg|png|gif)$")) then "" else ".png")) )
                        , (), (), @scale, (../desc, ../figDesc) => head() => normalize-space())
                    case element(figDesc) return
                        html:omit($config, ., ("tei-figDesc", css:map-rend-to-class(.)), .)
                    case element(figure) return
                        if (@rend='smallfloatinline') then
                            html:block($config, ., ("tei-figure1", "float-left", "figure-floated", css:map-rend-to-class(.)), .)
                        else
                            if (head or @rendition='simple:display') then
                                html:block($config, ., ("tei-figure2", css:map-rend-to-class(.)), .)
                            else
                                html:inline($config, ., ("tei-figure3", css:map-rend-to-class(.)), .)
                    case element(label) return
                        if (@foo='baz') then
                            html:inline($config, ., ("tei-label1", css:map-rend-to-class(.)), .)
                        else
                            html:inline($config, ., ("tei-label2", css:map-rend-to-class(.)), .)
                    case element(gap) return
                        html:omit($config, ., ("tei-gap", css:map-rend-to-class(.)), .)
                    case element(persName) return
                        html:inline($config, ., ("tei-persName", css:map-rend-to-class(.)), .)
                    case element(gloss) return
                        html:inline($config, ., ("tei-gloss", css:map-rend-to-class(.)), .)
                    case element(term) return
                        html:inline($config, ., ("tei-term", css:map-rend-to-class(.)), .)
                    case element(placeName) return
                        html:inline($config, ., ("tei-placeName", css:map-rend-to-class(.)), .)
                    case element(frus:attachment) return
                        html:section($config, ., ("tei-frus_attachment", "attachment", css:map-rend-to-class(.)), .)
                    case element(exist:match) return
                        html:match($config, ., .)
                    case element() return
                        if (namespace-uri(.) = 'http://www.tei-c.org/ns/1.0') then
                            $config?apply($config, ./node())
                        else
                            .
                    case text() | xs:anyAtomicType return
                        html:escapeChars(.)
                    default return
                        $config?apply($config, ./node())

        )

};

declare function model:apply-children($config as map(*), $node as element(), $content as item()*) {

    if ($config?template) then
        $content
    else
        $content ! (
            typeswitch(.)
                case element() return
                    if (. is $node) then
                        $config?apply($config, ./node())
                    else
                        $config?apply($config, .)
                default return
                    html:escapeChars(.)
        )
};

declare function model:source($parameters as map(*), $elem as element()) {

    let $id := $elem/@exist:id
    return
        if ($id and $parameters?root) then
            util:node-by-id($parameters?root, $id)
        else
            $elem
};

declare function model:process-annotation($html, $context as node()) {

    let $classRegex := analyze-string($html/@class, '\s?annotation-([^\s]+)\s?')
    return
        if ($classRegex//fn:match) then (
            if ($html/@data-type) then
                ()
            else
                attribute data-type { ($classRegex//fn:group)[1]/string() },
            if ($html/@data-annotation) then
                ()
            else
                attribute data-annotation {
                    map:merge($context/@* ! map:entry(node-name(.), ./string()))
                    => serialize(map { "method": "json" })
                }
        ) else
            ()

};

declare function model:map($html, $context as node(), $trackIds as item()?) {

    if ($trackIds) then
        for $node in $html
        return
            typeswitch ($node)
                case document-node() | comment() | processing-instruction() return
                    $node
                case element() return
                    if ($node/@class = ("footnote")) then
                        if (local-name($node) = 'pb-popover') then
                            ()
                        else
                            element { node-name($node) }{
                                $node/@*,
                                $node/*[@class="fn-number"],
                                model:map($node/*[@class="fn-content"], $context, $trackIds)
                            }
                    else
                        element { node-name($node) }{
                            attribute data-tei { util:node-id($context) },
                            $node/@*,
                            model:process-annotation($node, $context),
                            $node/node()
                        }
                default return
                    <pb-anchor data-tei="{ util:node-id($context) }">{$node}</pb-anchor>
    else
        $html

};

