(:~

    Transformation module generated from TEI ODD extensions for processing models.
    ODD: /db/apps/hsg-shell/resources/odd/compiled/frus.odd
 :)
xquery version "3.1";

module namespace model = "http://www.tei-c.org/pm/models/frus/web";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare namespace xhtml = 'http://www.w3.org/1999/xhtml';

declare namespace skos = 'http://www.w3.org/2004/02/skos/core#';

declare namespace frus = 'http://history.state.gov/frus/ns/1.0';

import module namespace css = "http://www.tei-c.org/tei-simple/xquery/css";

import module namespace html = "http://www.tei-c.org/tei-simple/xquery/functions";

import module namespace ext-html = "http://history.state.gov/ns/site/hsg/pmf-html" at "xmldb:exist:///db/apps/hsg-shell/modules/ext-html.xql";

(:~

    Main entry point for the transformation.
    
 :)
declare function model:transform($options as map(*), $input as node()*) {
        
    let $config :=
        map:merge(($options,
            map {
                "output": ["web"],
                "odd": "/db/apps/hsg-shell/resources/odd/compiled/frus.odd",
                "apply": model:apply#2,
                "apply-children": model:apply-children#3
            }
        ),  map{"duplicates": "use-last"})
    
    return (
        html:prepare($config, $input),
    
        model:apply($config, $input)
    )
};

declare function model:apply($config as map(*), $input as node()*) {
    let $parameters := 
        if (exists($config?parameters)) then $config?parameters else map {}
    return
    $input !         (
            typeswitch(.)
                case element(ab) return
                    html:paragraph($config, ., ("tei-ab"), .)
                case element(abbr) return
                    html:inline($config, ., ("tei-abbr"), .)
                case element(actor) return
                    html:inline($config, ., ("tei-actor"), .)
                case element(add) return
                    html:inline($config, ., ("tei-add"), .)
                case element(address) return
                    html:block($config, ., ("tei-address"), .)
                case element(addrLine) return
                    html:block($config, ., ("tei-addrLine"), .)
                case element(addSpan) return
                    html:anchor($config, ., ("tei-addSpan"), ., @xml:id)
                case element(am) return
                    html:inline($config, ., ("tei-am"), .)
                case element(anchor) return
                    html:anchor($config, ., ("tei-anchor"), ., @xml:id)
                case element(argument) return
                    html:block($config, ., ("tei-argument"), .)
                case element(author) return
                    if (ancestor::teiHeader) then
                        html:omit($config, ., ("tei-author1"), .)
                    else
                        html:inline($config, ., ("tei-author2"), .)
                case element(back) return
                    html:block($config, ., ("tei-back"), .)
                case element(bibl) return
                    if (parent::listBibl) then
                        html:listItem($config, ., ("tei-bibl1"), ., ())
                    else
                        html:inline($config, ., ("tei-bibl2"), .)
                case element(body) return
                    (
                        html:index($config, ., ("tei-body1"), 'toc', .),
                        html:block($config, ., ("tei-body2"), .)
                    )

                case element(byline) return
                    html:block($config, ., ("tei-byline"), .)
                case element(c) return
                    html:inline($config, ., ("tei-c"), .)
                case element(castGroup) return
                    if (child::*) then
                        (: Insert list. :)
                        html:list($config, ., ("tei-castGroup"), castItem|castGroup)
                    else
                        $config?apply($config, ./node())
                case element(castItem) return
                (: Insert item, rendered as described in parent list rendition. :)
                    html:listItem($config, ., ("tei-castItem"), ., ())
                case element(castList) return
                    if (child::*) then
                        html:list($config, ., css:get-rendition(., ("tei-castList")), castItem, ())
                    else
                        $config?apply($config, ./node())
                case element(cb) return
                    html:break($config, ., ("tei-cb"), ., 'column', @n)
                case element(cell) return
                    (: Insert table cell. :)
                    html:cell($config, ., css:get-rendition(., ("tei-cell")), ., ())
                case element(choice) return
                    if (sic and corr) then
                        html:alternate($config, ., ("tei-choice1"), ., corr[1], sic[1], ())
                    else
                        if (abbr and expan) then
                            html:alternate($config, ., ("tei-choice1"), ., expan[1], abbr[1], ())
                        else
                            if (orig and reg) then
                                html:alternate($config, ., ("tei-choice6"), ., reg[1], orig[1], ())
                            else
                                $config?apply($config, ./node())
                case element(cit) return
                    if (child::quote and child::bibl) then
                    (: Insert citation :)
                        html:cit($config, ., ("tei-cit"), ., .)
                    else
                        $config?apply($config, ./node())
                case element(closer) return
                    html:block($config, ., ("tei-closer"), .)
                case element(corr) return
                    if (parent::choice and count(parent::*/*) gt 1) then
                        (: simple inline, if in parent choice. :)
                        html:inline($config, ., ("tei-corr1"), .)
                    else
                        html:inline($config, ., ("tei-corr2"), .)
                case element(date) return
                    html:inline($config, ., ("tei-date"), .)
                case element(dateline) return
                    html:block($config, ., ("tei-dateline"), .)
                case element(del) return
                    html:inline($config, ., ("tei-del"), .)
                case element(desc) return
                    html:inline($config, ., ("tei-desc"), .)
                case element(div) return
                    if ($parameters?document-list and div[@type='question']) then
                        ext-html:document-list($config, ., ("tei-div1"))
                    else
                        if ($parameters?document-list and @type = ('compilation', 'chapter', 'subchapter', 'section', 'part') and exists(div[@type and not(@type = 'online-supplement')])) then
                            ext-html:document-list($config, ., ("tei-div2"))
                        else
                            html:block($config, ., ("tei-div2"), .)
                case element(docAuthor) return
                    if (ancestor::teiHeader) then
                        (: Omit if located in teiHeader. :)
                        html:omit($config, ., ("tei-docAuthor1"), .)
                    else
                        html:inline($config, ., ("tei-docAuthor2"), .)
                case element(docDate) return
                    if (ancestor::teiHeader) then
                        (: Omit if located in teiHeader. :)
                        html:omit($config, ., ("tei-docDate1"), .)
                    else
                        html:inline($config, ., ("tei-docDate2"), .)
                case element(docEdition) return
                    if (ancestor::teiHeader) then
                        (: Omit if located in teiHeader. :)
                        html:omit($config, ., ("tei-docEdition1"), .)
                    else
                        html:inline($config, ., ("tei-docEdition2"), .)
                case element(docImprint) return
                    if (ancestor::teiHeader) then
                        (: Omit if located in teiHeader. :)
                        html:omit($config, ., ("tei-docImprint1"), .)
                    else
                        html:inline($config, ., ("tei-docImprint2"), .)
                case element(docTitle) return
                    if (ancestor::teiHeader) then
                        (: Omit if located in teiHeader. :)
                        html:omit($config, ., ("tei-docTitle1"), .)
                    else
                        html:block($config, ., css:get-rendition(., ("tei-docTitle2")), .)
                case element(epigraph) return
                    html:block($config, ., ("tei-epigraph"), .)
                case element(ex) return
                    html:inline($config, ., ("tei-ex"), .)
                case element(expan) return
                    html:inline($config, ., ("tei-expan"), .)
                case element(figDesc) return
                    html:omit($config, ., ("tei-figDesc"), .)
                case element(figure) return
                    if (@rend='smallfloatinline') then
                        html:block($config, ., ("tei-figure1", "float-left", "figure-floated"), .)
                    else
                        if (head or @rendition='simple:display') then
                            html:block($config, ., ("tei-figure2"), .)
                        else
                            html:inline($config, ., ("tei-figure2"), .)
                case element(floatingText) return
                    html:block($config, ., ("tei-floatingText"), .)
                case element(foreign) return
                    html:inline($config, ., ("tei-foreign"), .)
                case element(formula) return
                    if (@rendition='simple:display') then
                        html:block($config, ., ("tei-formula1"), .)
                    else
                        html:inline($config, ., ("tei-formula2"), .)
                case element(front) return
                    html:block($config, ., ("tei-front"), .)
                case element(fw) return
                    if (ancestor::p or ancestor::ab) then
                        html:inline($config, ., ("tei-fw1"), .)
                    else
                        html:block($config, ., ("tei-fw2"), .)
                case element(g) return
                    if (not(text())) then
                        html:glyph($config, ., ("tei-g1"), .)
                    else
                        html:inline($config, ., ("tei-g2"), .)
                case element(gap) return
                    html:omit($config, ., ("tei-gap"), .)
                case element(graphic) return
                    html:graphic($config, ., css:get-rendition(., ("tei-graphic")), ., if (matches(@url, '^https?://')) then @url else ( xs:anyURI('https://static.history.state.gov/' || $parameters?base-uri || 
                            "/" || @url || (if (matches(@url, "^.*\.(jpg|png|gif)$")) then "" else ".png")) ), (), (), @scale, (../desc, ../figDesc) => head() => normalize-space())
                case element(group) return
                    html:block($config, ., ("tei-group"), .)
                case element(handShift) return
                    html:inline($config, ., ("tei-handShift"), .)
                case element(head) return
                    if (parent::figure) then
                        html:block($config, ., ("tei-head1"), .)
                    else
                        if (parent::table) then
                            html:block($config, ., ("tei-head1"), .)
                        else
                            if (parent::list/@type = ('participants', 'to', 'from', 'subject')) then
                                html:block($config, ., ("tei-head1"), .)
                            else
                                if (parent::list) then
                                    html:block($config, ., ("tei-head1"), .)
                                else
                                    if (parent::div and @type='shortened-for-running-head') then
                                        html:omit($config, ., ("tei-head1"), .)
                                    else
                                        if (ancestor::frus:attachment) then
                                            html:heading($config, ., ("tei-head1"), ., count(ancestor::div intersect ancestor::frus:attachment//div))
                                        else
                                            if (parent::div) then
                                                html:heading($config, ., ("tei-head7"), ., count(ancestor::div) + (if ($parameters?heading-offset) then $parameters?heading-offset else 0))
                                            else
                                                html:block($config, ., ("tei-head2"), .)
                case element(hi) return
                    if (@rend = 'strong') then
                        html:inline($config, ., ("tei-hi1"), .)
                    else
                        if (@rend = 'italic') then
                            html:inline($config, ., ("tei-hi1", "font-italic"), .)
                        else
                            if (@rend = 'smallcaps') then
                                html:inline($config, ., ("tei-hi1", "font-smallcaps"), .)
                            else
                                if (@rendition) then
                                    html:inline($config, ., css:get-rendition(., ("tei-hi1", "font-italic")), .)
                                else
                                    if (not(@rendition)) then
                                        html:inline($config, ., ("tei-hi5", "font-italic"), .)
                                    else
                                        $config?apply($config, ./node())
                case element(imprimatur) return
                    html:block($config, ., ("tei-imprimatur"), .)
                    case element(item) return
                    html:listItem($config, ., ("tei-item"), ., ())
                    case element (l) return
                    html:block($config, ., css:get-rendition(., ("tei-l")), .)
                case element(label) return
                    if (@foo='baz') then
                        html:inline($config, ., ("tei-label1"), .)
                    else
                        html:inline($config, ., ("tei-label2"), .)
                case element(lb) return
                    html:break($config, ., css:get-rendition(., ("tei-lb")), ., 'line', @n)
                case element(lg) return
                    html:block($config, ., ("tei-lg"), .)
                case element(list) return
                    if (head) then
                    (
                    (: Headline for lists, level 4 will transform to html:h4 element :)
                    html:heading($config, ., ("tei-list1", "listHead"), head/ node (), 4),
                    html:list($config, ., ("tei-list2", "list", "hsg-list-default"), item, ())
                    )

                    else
                    if (@rend = 'bulleted') then
                    html:list($config, ., ("tei-list1", "hsg-list-disc"), item, ())
                    else
                    if (@type = ('participants', 'to', 'from', 'subject')) then
                    html:list($config, ., ("tei-list1", "hsg-list-default"), item, ())
                    else
                    if ( parent::list/@type = ('participants', 'to', 'from', 'subject')) then
                    (: This is a nested list within a list-item :)
                    html:list($config, ., ("tei-list1"), item, ())
                    else
                    if (label) then
                    html:list($config, ., ("tei-list1", "labeled-list"), item, ())
                    else
                    if (ancestor::div[@xml:id = 'persons']) then
                    html:list($config, ., ("tei-list1", "list-person"), item, ())
                    else
                    if ( ancestor::list) then
                    (: This is a nested list within a list :)
                    html:list($config, ., ("tei-list6", "hsg-nested-list"), item, ())
                    else
                    html:list($config, ., ("tei-list2", "hsg-list"), item, ())
                    case element (listBibl) return
                    if (bibl) then
                    html:list($config, ., ("tei-listBibl1"), bibl, ())
                    else
                        html:block($config, ., ("tei-listBibl2"), .)
                case element(measure) return
                    html:inline($config, ., ("tei-measure"), .)
                case element(milestone) return
                    html:inline($config, ., ("tei-milestone"), .)
                case element(name) return
                    html:inline($config, ., ("tei-name"), .)
                case element(note) return
                    if ($parameters?omit-notes) then
                        html:omit($config, ., ("tei-note1"), .)
                    else
                        if (@rend = 'inline') then
                            html:paragraph($config, ., ("tei-note2"), .)
                        else
                            ext-html:note($config, ., ("tei-note2"), ., "foot", @n/string())
                case element(num) return
                    html:inline($config, ., ("tei-num"), .)
                case element(opener) return
                    html:block($config, ., ("tei-opener"), .)
                case element(orig) return
                    html:inline($config, ., ("tei-orig"), .)
                case element(p) return
                    if (@rend = 'center') then
                        html:paragraph($config, ., css:get-rendition(., ("tei-p1")), .)
                    else
                        if (@rend = 'flushleft') then
                            html:paragraph($config, ., css:get-rendition(., ("tei-p2")), .)
                        else
                            html:paragraph($config, ., css:get-rendition(., ("tei-p2")), .)
                case element(pb) return
                    (
                        html:link($config, ., ("tei-pb1"), concat('[', switch (@type) case 'facsimile' return 'Facsimile ' case 'typeset' return 'Typeset ' default return '', 'Page ', @n, ']'), @xml:id)
                    )

                case element(pc) return
                    html:inline($config, ., ("tei-pc"), .)
                case element(postscript) return
                    html:block($config, ., ("tei-postscript"), .)
                case element(publisher) return
                    html:inline($config, ., ("tei-publisher"), .)
                case element(pubPlace) return
                    html:inline($config, ., ("tei-pubPlace"), .)
                case element(q) return
                    if (l) then
                        html:block($config, ., css:get-rendition(., ("tei-q1")), .)
                    else
                        if (ancestor::p or ancestor::cell) then
                            html:inline($config, ., css:get-rendition(., ("tei-q2")), .)
                        else
                            html:block($config, ., css:get-rendition(., ("tei-q2")), .)
                case element(quote) return
                    if (ancestor::p and empty(descendant::p|descendant::div)) then
                        (: If it is inside a paragraph then it is inline, otherwise it is block level; no extra quote marks around :)
                        html:inline($config, ., css:get-rendition(., ("tei-quote1")), .)
                    else
                        (: If it is inside a paragraph then it is inline, otherwise it is block level :)
                        html:block($config, ., css:get-rendition(., ("tei-quote2")), .)
                case element(ref) return
                    ext-html:ref($config, ., ("tei-ref"), .)
                case element(reg) return
                    html:inline($config, ., ("tei-reg"), .)
                case element(rhyme) return
                    html:inline($config, ., ("tei-rhyme"), .)
                case element(role) return
                    html:block($config, ., ("tei-role"), .)
                case element(roleDesc) return
                    html:block($config, ., ("tei-roleDesc"), .)
                case element(row) return
                    (: Insert table row. :)
                    html:row($config, ., css:get-rendition(., ("tei-row")), .)
                case element(rs) return
                    html:inline($config, ., ("tei-rs"), .)
                case element(s) return
                    html:inline($config, ., ("tei-s"), .)
                case element(salute) return
                    if (parent::closer) then
                        html:inline($config, ., ("tei-salute1"), .)
                    else
                        html:block($config, ., ("tei-salute2"), .)
                case element(seg) return
                    html:inline($config, ., css:get-rendition(., ("tei-seg")), .)
                case element(sic) return
                    if (parent::choice and count(parent::*/*) gt 1) then
                        html:inline($config, ., ("tei-sic1"), .)
                    else
                        html:inline($config, ., ("tei-sic2"), .)
                case element(signed) return
                    if (parent::closer) then
                        html:block($config, ., ("tei-signed1"), .)
                    else
                        html:inline($config, ., ("tei-signed2"), .)
                case element(sp) return
                    html:block($config, ., ("tei-sp"), .)
                case element(space) return
                    html:inline($config, ., ("tei-space"), .)
                case element(speaker) return
                    html:block($config, ., ("tei-speaker"), .)
                case element(spGrp) return
                    html:block($config, ., ("tei-spGrp"), .)
                case element(stage) return
                    html:block($config, ., ("tei-stage"), .)
                case element(subst) return
                    html:inline($config, ., ("tei-subst"), .)
                case element(supplied) return
                    if (parent::choice) then
                        html:inline($config, ., ("tei-supplied1"), .)
                    else
                        if (@reason='damage') then
                            html:inline($config, ., ("tei-supplied1"), .)
                        else
                            if (@reason='illegible' or not(@reason)) then
                                html:inline($config, ., ("tei-supplied1"), .)
                            else
                                if (@reason='omitted') then
                                    html:inline($config, ., ("tei-supplied4"), .)
                                else
                                    html:inline($config, ., ("tei-supplied2"), .)
                case element(table) return
                    if (.//row/@rendition or .//cell/@rendition) then
                        html:table($config, ., css:get-rendition(., ("tei-table1")), .)
                    else
                        html:table($config, ., css:get-rendition(., ("tei-table2", "table", "table-hover", "table-bordered")), .)
                case element(fileDesc) return
                    (
                        html:block($config, ., ("tei-fileDesc1"), titleStmt),
                        html:block($config, ., ("tei-fileDesc2"), publicationStmt)
                    )

                case element(profileDesc) return
                    html:omit($config, ., ("tei-profileDesc"), .)
                case element(revisionDesc) return
                    html:omit($config, ., ("tei-revisionDesc"), .)
                case element(encodingDesc) return
                    html:omit($config, ., ("tei-encodingDesc"), .)
                case element(teiHeader) return
                    (
                        html:block($config, ., ("tei-teiHeader1"), .),
                        html:omit($config, ., ("tei-teiHeader2"), .)
                    )

                case element(TEI) return
                    html:document($config, ., ("tei-TEI"), .)
                case element(text) return
                    html:body($config, ., ("tei-text"), .)
                case element(time) return
                    html:inline($config, ., ("tei-time"), .)
                case element(title) return
                    if (@level = 's') then
                        html:inline($config, ., ("tei-title1"), .)
                    else
                        html:inline($config, ., ("tei-title2"), .)
                case element(titlePage) return
                    html:block($config, ., css:get-rendition(., ("tei-titlePage")), .)
                case element(titlePart) return
                    html:block($config, ., css:get-rendition(., ("tei-titlePart")), .)
                case element(trailer) return
                    html:block($config, ., ("tei-trailer"), .)
                case element(unclear) return
                    html:inline($config, ., ("tei-unclear"), .)
                case element(w) return
                    html:inline($config, ., ("tei-w"), .)
                case element(cell) return
                    (: Insert table cell. :)
                    html:cell($config, ., css:get-rendition(., ("tei-cell")), ., ())
                case element(row) return
                    (: Insert table row. :)
                    html:row($config, ., css:get-rendition(., ("tei-row")), .)
                case element(titleStmt) return
                    (
                        html:heading($config, ., ("tei-titleStmt1"), title[@type="complete"], ()),
                        if (count(editor[@role = 'primary']) gt 1) then
                            html:block($config, ., ("tei-titleStmt2"), "Editors:")
                        else
                            (),
                        if (count(editor[@role = 'primary'][. ne '']) eq 1) then
                            html:block($config, ., ("tei-titleStmt2"), "Editor:")
                        else
                            (),
                        if (editor[@role = 'primary'][. ne '']) then
                            ext-html:list-from-items($config, ., ("tei-titleStmt2"), editor[@role="primary"], ())
                        else
                            (),
                        if (editor[@role = 'general'][. ne '']) then
                            html:block($config, ., ("tei-titleStmt2"), "General Editor:")
                        else
                            (),
                        if (editor[@role = 'general'][. ne '']) then
                            ext-html:list-from-items($config, ., ("tei-titleStmt2"), editor[@role="general"], ())
                        else
                            ()
                    )

                case element(publicationStmt) return
                    (
                        html:block($config, ., ("tei-publicationStmt1"), publisher),
                        html:block($config, ., ("tei-publicationStmt2"), pubPlace),
                        html:block($config, ., ("tei-publicationStmt2"), date[@type="publication-date"])
                    )

                case element(xhtml:object) return
                    ext-html:passthrough($config, ., ("tei-xhtml:object"))
                case element(xhtml:div) return
                    ext-html:passthrough($config, ., ("tei-xhtml:div"))
                case element(xhtml:script) return
                    ext-html:passthrough($config, ., ("tei-xhtml:script"))
                case element(persName) return
                    html:inline($config, ., ("tei-persName"), .)
                case element(gloss) return
                    html:inline($config, ., ("tei-gloss"), .)
                case element(term) return
                    html:inline($config, ., ("tei-term"), .)
                case element(placeName) return
                    html:inline($config, ., ("tei-placeName"), .)
                case element(frus:attachment) return
                    html:section($config, ., ("tei-frus:attachment", "attachment"), .)
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

