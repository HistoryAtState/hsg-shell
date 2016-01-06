(:~

    Transformation module generated from TEI ODD extensions for processing models.
    ODD: /db/apps/hsg-shell/resources/odd/compiled/departmenthistory.odd
 :)
xquery version "3.1";

module namespace model="http://www.tei-c.org/tei-simple/models/departmenthistory.odd";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare namespace xhtml='http://www.w3.org/1999/xhtml';

import module namespace css="http://www.tei-c.org/tei-simple/xquery/css" at "xmldb:exist://embedded-eXist-server/db/apps/tei-simple/content/css.xql";

import module namespace html="http://www.tei-c.org/tei-simple/xquery/functions" at "xmldb:exist://embedded-eXist-server/db/apps/tei-simple/content/html-functions.xql";

(:~

    Main entry point for the transformation.
    
 :)
declare function model:transform($options as map(*), $input as node()*) {
        
    let $config :=
        map:new(($options,
            map {
                "output": ["web"],
                "odd": "/db/apps/hsg-shell/resources/odd/compiled/departmenthistory.odd",
                "apply": model:apply#2,
                "apply-children": model:apply-children#3
            }
        ))
        return
            model:apply($config, $input)
                        
};

declare function model:apply($config as map(*), $input as node()*) {
    let $parameters := 
        if (exists($config?parameters)) then $config?parameters else map {}
    return
    $input !         (
            typeswitch(.)
                case element(abbr) return
                    html:inline($config, ., ("tei-abbr"), .)
                case element(add) return
                    html:inline($config, ., ("tei-add"), .)
                case element(address) return
                    html:block($config, ., ("tei-address"), .)
                case element(addrLine) return
                    html:block($config, ., ("tei-addrLine"), .)
                case element(author) return
                    if (ancestor::teiHeader) then
                        html:omit($config, ., ("tei-author1"), .)
                    else
                        html:inline($config, ., ("tei-author2"), .)
                case element(bibl) return
                    if (parent::listBibl) then
                        html:listItem($config, ., ("tei-bibl1"), .)
                    else
                        html:inline($config, ., ("tei-bibl2"), .)
                case element(cb) return
                    html:break($config, ., ("tei-cb"), ., 'column', @n)
                case element(choice) return
                    if (sic and corr) then
                        html:alternate($config, ., ("tei-choice4"), ., corr[1], sic[1])
                    else
                        if (abbr and expan) then
                            html:alternate($config, ., ("tei-choice5"), ., expan[1], abbr[1])
                        else
                            if (orig and reg) then
                                html:alternate($config, ., ("tei-choice6"), ., reg[1], orig[1])
                            else
                                $config?apply($config, ./node())
                case element(cit) return
                    if (child::quote and child::bibl) then
                        (: Insert citation :)
                        html:cit($config, ., ("tei-cit"), .)
                    else
                        $config?apply($config, ./node())
                case element(corr) return
                    if (parent::choice and count(parent::*/*) gt 1) then
                        (: simple inline, if in parent choice. :)
                        html:inline($config, ., ("tei-corr1"), .)
                    else
                        html:inline($config, ., ("tei-corr2"), .)
                case element(date) return
                    html:inline($config, ., ("tei-date"), .)
                case element(del) return
                    html:inline($config, ., ("tei-del"), .)
                case element(desc) return
                    html:inline($config, ., ("tei-desc"), .)
                case element(expan) return
                    html:inline($config, ., ("tei-expan"), .)
                case element(foreign) return
                    html:inline($config, ., ("tei-foreign"), .)
                case element(gap) return
                    if (desc) then
                        html:inline($config, ., ("tei-gap1"), .)
                    else
                        if (@extent) then
                            html:inline($config, ., ("tei-gap2"), @extent)
                        else
                            html:inline($config, ., ("tei-gap3"), .)
                case element(graphic) return
                    html:graphic($config, ., ("tei-graphic"), ., xs:anyURI('//s3.amazonaws.com/static.history.state.gov/' || $parameters?base-uri || 
                            "/" || @url || (if (matches(@url, "^.*\.[^\.]+$")) then "" else ".png")), @width, @height, @scale, desc)
                case element(head) return
                    if (parent::figure) then
                        html:block($config, ., ("tei-head1"), .)
                    else
                        if (parent::table) then
                            html:block($config, ., ("tei-head2"), .)
                        else
                            if (parent::list/@type = ('participants', 'to', 'from', 'subject')) then
                                html:block($config, ., ("tei-head3"), .)
                            else
                                if (parent::list) then
                                    html:block($config, ., ("tei-head4"), .)
                                else
                                    if (parent::div and @type='shortened-for-running-head') then
                                        html:omit($config, ., ("tei-head5"), .)
                                    else
                                        if (parent::div) then
                                            html:heading($config, ., ("tei-head6"), .)
                                        else
                                            html:block($config, ., ("tei-head7"), .)
                case element(hi) return
                    if (@rend = 'strong') then
                        html:inline($config, ., ("tei-hi1"), .)
                    else
                        if (@rend = 'italic') then
                            html:inline($config, ., ("tei-hi2"), .)
                        else
                            if (@rend = 'smallcaps') then
                                html:inline($config, ., ("tei-hi3"), .)
                            else
                                if (@rendition) then
                                    html:inline($config, ., css:get-rendition(., ("tei-hi4")), .)
                                else
                                    if (not(@rendition)) then
                                        html:inline($config, ., ("tei-hi5"), .)
                                    else
                                        $config?apply($config, ./node())
                case element(item) return
                    html:listItem($config, ., ("tei-item"), .)
                case element(l) return
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
                    if (@rend = 'bulleted') then
                        html:list($config, ., ("tei-list1"), item)
                    else
                        if (@type = ('participants', 'to', 'from', 'subject')) then
                            html:list($config, ., ("tei-list2"), item)
                        else
                            if (label) then
                                html:list($config, ., ("tei-list3"), item)
                            else
                                html:list($config, ., ("tei-list4"), item)
                case element(listBibl) return
                    if (bibl) then
                        html:list($config, ., ("tei-listBibl1"), bibl)
                    else
                        html:block($config, ., ("tei-listBibl2"), .)
                case element(measure) return
                    html:inline($config, ., ("tei-measure"), .)
                case element(milestone) return
                    html:inline($config, ., ("tei-milestone"), .)
                case element(name) return
                    html:inline($config, ., ("tei-name"), .)
                case element(note) return
                    if (@rend = 'inline') then
                        html:paragraph($config, ., ("tei-note1"), .)
                    else
                        html:note($config, ., ("tei-note2"), ., "foot", @n/string())
                case element(num) return
                    html:inline($config, ., ("tei-num"), .)
                case element(orig) return
                    html:inline($config, ., ("tei-orig"), .)
                case element(p) return
                    if (@rend = 'center') then
                        html:paragraph($config, ., css:get-rendition(., ("tei-p1")), .)
                    else
                        if (@rend = 'flushleft') then
                            html:paragraph($config, ., css:get-rendition(., ("tei-p2")), .)
                        else
                            html:paragraph($config, ., css:get-rendition(., ("tei-p3")), .)
                case element(pb) return
                    (
                        html:link($config, ., ("tei-pb1"), concat('[Page ', @n, ']'), @xml:id)
                    )

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
                            html:block($config, ., css:get-rendition(., ("tei-q3")), .)
                case element(quote) return
                    if (ancestor::p and empty(descendant::p|descendant::div)) then
                        (: If it is inside a paragraph then it is inline, otherwise it is block level; no extra quote marks around :)
                        html:inline($config, ., css:get-rendition(., ("tei-quote1")), .)
                    else
                        (: If it is inside a paragraph then it is inline, otherwise it is block level :)
                        html:block($config, ., css:get-rendition(., ("tei-quote2")), .)
                case element(ref) return
                    (: No function found for behavior: ref :)
                    $config?apply($config, ./node())
                case element(reg) return
                    html:inline($config, ., ("tei-reg"), .)
                case element(rs) return
                    html:inline($config, ., ("tei-rs"), .)
                case element(sic) return
                    if (parent::choice and count(parent::*/*) gt 1) then
                        html:inline($config, ., ("tei-sic1"), .)
                    else
                        html:inline($config, ., ("tei-sic2"), .)
                case element(sp) return
                    html:block($config, ., ("tei-sp"), .)
                case element(speaker) return
                    html:block($config, ., ("tei-speaker"), .)
                case element(stage) return
                    html:block($config, ., ("tei-stage"), .)
                case element(time) return
                    html:inline($config, ., ("tei-time"), .)
                case element(title) return
                    html:inline($config, ., ("tei-title"), .)
                case element(unclear) return
                    html:inline($config, ., ("tei-unclear"), .)
                case element(revisionDesc) return
                    html:omit($config, ., ("tei-revisionDesc"), .)
                case element(encodingDesc) return
                    html:omit($config, ., ("tei-encodingDesc"), .)
                case element(fileDesc) return
                    (
                        html:block($config, ., ("tei-fileDesc1"), titleStmt),
                        html:block($config, ., ("tei-fileDesc2"), publicationStmt)
                    )

                case element(profileDesc) return
                    html:omit($config, ., ("tei-profileDesc"), .)
                case element(publicationStmt) return
                    (
                        html:block($config, ., ("tei-publicationStmt1"), publisher),
                        html:block($config, ., ("tei-publicationStmt2"), pubPlace),
                        html:block($config, ., ("tei-publicationStmt3"), date)
                    )

                case element(teiHeader) return
                    (
                        html:block($config, ., ("tei-teiHeader1"), .),
                        html:omit($config, ., ("tei-teiHeader2"), .)
                    )

                case element(titleStmt) return
                    (
                        html:heading($config, ., ("tei-titleStmt1"), title[@type="complete"]),
                        if (count(editor[@role = 'primary']) gt 1) then
                            html:block($config, ., ("tei-titleStmt2"), "Editors:")
                        else
                            (),
                        if (count(editor[@role = 'primary']) eq 1) then
                            html:block($config, ., ("tei-titleStmt3"), "Editor:")
                        else
                            (),
                        if (editor[@role = 'primary']) then
                            (: No function found for behavior: list-from-items :)
                            $config?apply($config, ./node())
                        else
                            (),
                        if (editor[@role = 'general']) then
                            html:block($config, ., ("tei-titleStmt5"), "General Editor:")
                        else
                            (),
                        if (editor[@role = 'general']) then
                            (: No function found for behavior: list-from-items :)
                            $config?apply($config, ./node())
                        else
                            ()
                    )

                case element(g) return
                    if (not(text())) then
                        html:glyph($config, ., ("tei-g1"), .)
                    else
                        html:inline($config, ., ("tei-g2"), .)
                case element(addSpan) return
                    html:anchor($config, ., ("tei-addSpan"), ., @xml:id)
                case element(am) return
                    html:inline($config, ., ("tei-am"), .)
                case element(ex) return
                    html:inline($config, ., ("tei-ex"), .)
                case element(fw) return
                    if (ancestor::p or ancestor::ab) then
                        html:inline($config, ., ("tei-fw1"), .)
                    else
                        html:block($config, ., ("tei-fw2"), .)
                case element(handShift) return
                    html:inline($config, ., ("tei-handShift"), .)
                case element(space) return
                    html:inline($config, ., ("tei-space"), .)
                case element(subst) return
                    html:inline($config, ., ("tei-subst"), .)
                case element(supplied) return
                    if (parent::choice) then
                        html:inline($config, ., ("tei-supplied1"), .)
                    else
                        if (@reason='damage') then
                            html:inline($config, ., ("tei-supplied2"), .)
                        else
                            if (@reason='illegible' or not(@reason)) then
                                html:inline($config, ., ("tei-supplied3"), .)
                            else
                                if (@reason='omitted') then
                                    html:inline($config, ., ("tei-supplied4"), .)
                                else
                                    html:inline($config, ., ("tei-supplied5"), .)
                case element(c) return
                    html:inline($config, ., ("tei-c"), .)
                case element(pc) return
                    html:inline($config, ., ("tei-pc"), .)
                case element(s) return
                    html:inline($config, ., ("tei-s"), .)
                case element(w) return
                    html:inline($config, ., ("tei-w"), .)
                case element(ab) return
                    html:paragraph($config, ., ("tei-ab"), .)
                case element(anchor) return
                    html:anchor($config, ., ("tei-anchor"), ., @xml:id)
                case element(seg) return
                    html:inline($config, ., css:get-rendition(., ("tei-seg")), .)
                case element(actor) return
                    html:inline($config, ., ("tei-actor"), .)
                case element(castGroup) return
                    if (child::*) then
                        (: Insert list. :)
                        html:list($config, ., ("tei-castGroup"), castItem|castGroup)
                    else
                        $config?apply($config, ./node())
                case element(castItem) return
                    (: Insert item, rendered as described in parent list rendition. :)
                    html:listItem($config, ., ("tei-castItem"), .)
                case element(castList) return
                    if (child::*) then
                        html:list($config, ., css:get-rendition(., ("tei-castList")), castItem)
                    else
                        $config?apply($config, ./node())
                case element(role) return
                    html:block($config, ., ("tei-role"), .)
                case element(roleDesc) return
                    html:block($config, ., ("tei-roleDesc"), .)
                case element(spGrp) return
                    html:block($config, ., ("tei-spGrp"), .)
                case element(argument) return
                    html:block($config, ., ("tei-argument"), .)
                case element(back) return
                    html:block($config, ., ("tei-back"), .)
                case element(body) return
                    (
                        html:index($config, ., ("tei-body1"), 'toc', .),
                        html:block($config, ., ("tei-body2"), .)
                    )

                case element(byline) return
                    html:block($config, ., ("tei-byline"), .)
                case element(closer) return
                    html:block($config, ., ("tei-closer"), .)
                case element(dateline) return
                    html:block($config, ., ("tei-dateline"), .)
                case element(div) return
                    if (@type = ('compilation', 'chapter')) then
                        (: No function found for behavior: document-list :)
                        $config?apply($config, ./node())
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
                case element(floatingText) return
                    html:block($config, ., ("tei-floatingText"), .)
                case element(front) return
                    html:block($config, ., ("tei-front"), .)
                case element(group) return
                    html:block($config, ., ("tei-group"), .)
                case element(imprimatur) return
                    html:block($config, ., ("tei-imprimatur"), .)
                case element(opener) return
                    html:block($config, ., ("tei-opener"), .)
                case element(postscript) return
                    html:block($config, ., ("tei-postscript"), .)
                case element(salute) return
                    if (parent::closer) then
                        html:inline($config, ., ("tei-salute1"), .)
                    else
                        html:block($config, ., ("tei-salute2"), .)
                case element(signed) return
                    if (parent::closer) then
                        html:block($config, ., ("tei-signed1"), .)
                    else
                        html:inline($config, ., ("tei-signed2"), .)
                case element(TEI) return
                    html:document($config, ., ("tei-TEI"), .)
                case element(text) return
                    html:body($config, ., ("tei-text"), .)
                case element(titlePage) return
                    html:block($config, ., css:get-rendition(., ("tei-titlePage")), .)
                case element(titlePart) return
                    html:block($config, ., css:get-rendition(., ("tei-titlePart")), .)
                case element(trailer) return
                    html:block($config, ., ("tei-trailer"), .)
                case element(cell) return
                    (: Insert table cell. :)
                    html:cell($config, ., ("tei-cell"), .)
                case element(figDesc) return
                    html:inline($config, ., ("tei-figDesc"), .)
                case element(figure) return
                    if (head or @rendition='simple:display') then
                        html:block($config, ., ("tei-figure1", "float-left figure-floated"), .)
                    else
                        html:inline($config, ., ("tei-figure2", "float-left figure-floated"), .)
                case element(formula) return
                    if (@rendition='simple:display') then
                        html:block($config, ., ("tei-formula1"), .)
                    else
                        html:inline($config, ., ("tei-formula2"), .)
                case element(row) return
                    if (@role='label') then
                        html:row($config, ., ("tei-row1"), .)
                    else
                        (: Insert table row. :)
                        html:row($config, ., ("tei-row2"), .)
                case element(table) return
                    html:table($config, ., ("tei-table"), .)
                case element(rhyme) return
                    html:inline($config, ., ("tei-rhyme"), .)
                case element(persName) return
                    html:inline($config, ., ("tei-persName"), .)
                case element(gloss) return
                    html:inline($config, ., ("tei-gloss"), .)
                case element(term) return
                    html:inline($config, ., ("tei-term"), .)
                case element(exist:match) return
                    html:match($config, ., .)
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

