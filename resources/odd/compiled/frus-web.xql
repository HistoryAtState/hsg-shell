(:~

    Transformation module generated from TEI ODD extensions for processing models.
    ODD: /db/apps/hsg-shell/resources/odd/compiled/frus.odd
 :)
xquery version "3.1";

module namespace model="http://www.tei-c.org/tei-simple/models/frus.odd";

declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace css="http://www.tei-c.org/tei-simple/xquery/css" at "xmldb:exist://embedded-eXist-server/db/apps/tei-simple/content/css.xql";

import module namespace html="http://www.tei-c.org/tei-simple/xquery/functions" at "xmldb:exist://embedded-eXist-server/db/apps/tei-simple/content/html-functions.xql";

import module namespace ext-html="http://history.state.gov/ns/site/hsg/pmf-html" at "xmldb:exist://embedded-eXist-server/db/apps/tei-simple/content/../../hsg-shell/modules/ext-html.xql";

(:~

    Main entry point for the transformation.
    
 :)
declare function model:transform($options as map(*), $input as node()*) {
        
    let $config :=
        map:new(($options,
            map {
                "output": ["web"],
                "odd": "/db/apps/hsg-shell/resources/odd/compiled/frus.odd",
                "apply": model:apply#2,
                "apply-children": model:apply-children#3
            }
        ))
        return
            model:apply($config, $input)
                        
};

declare function model:apply($config as map(*), $input as node()*) {
    $input !     (
        typeswitch(.)
            case element(abbr) return
                html:inline($config, ., "abbr", .)
            case element(add) return
                html:inline($config, ., "add", .)
            case element(address) return
                html:block($config, ., "address", .)
            case element(addrLine) return
                html:block($config, ., "addrLine", .)
            case element(author) return
                if (ancestor::teiHeader) then
                    html:omit($config, ., "author1", .)
                else
                    html:inline($config, ., "author2", .)
            case element(bibl) return
                if (parent::listBibl) then
                    html:listItem($config, ., "bibl1", .)
                else
                    html:inline($config, ., "bibl2", .)
            case element(cb) return
                html:break($config, ., "cb", ., 'column', @n)
            case element(choice) return
                if (sic and corr) then
                    html:alternate($config, ., "choice4", ., corr[1], sic[1])
                else
                    if (abbr and expan) then
                        html:alternate($config, ., "choice5", ., expan[1], abbr[1])
                    else
                        if (orig and reg) then
                            html:alternate($config, ., "choice6", ., reg[1], orig[1])
                        else
                            $config?apply($config, ./node())
            case element(cit) return
                if (child::quote and child::bibl) then
                    (: Insert citation :)
                    html:cit($config, ., "cit", .)
                else
                    $config?apply($config, ./node())
            case element(corr) return
                if (parent::choice and count(parent::*/*) gt 1) then
                    (: simple inline, if in parent choice. :)
                    html:inline($config, ., "corr1", .)
                else
                    html:inline($config, ., "corr2", .)
            case element(date) return
                html:inline($config, ., "date", .)
            case element(del) return
                html:inline($config, ., "del", .)
            case element(desc) return
                html:inline($config, ., "desc", .)
            case element(expan) return
                html:inline($config, ., "expan", .)
            case element(foreign) return
                html:inline($config, ., "foreign", .)
            case element(gap) return
                if (desc) then
                    html:inline($config, ., "gap1", .)
                else
                    if (@extent) then
                        html:inline($config, ., "gap2", @extent)
                    else
                        html:inline($config, ., "gap3", .)
            case element(graphic) return
                html:graphic($config, ., "graphic", ., @url, @width, @height, @scale, desc)
            case element(head) return
                if (parent::figure) then
                    html:block($config, ., "head1", .)
                else
                    if (parent::table) then
                        html:block($config, ., "head2", .)
                    else
                        if (parent::lg) then
                            html:block($config, ., "head3", .)
                        else
                            if (parent::list) then
                                html:block($config, ., "head4", .)
                            else
                                if (parent::div) then
                                    html:heading($config, ., "head5", .)
                                else
                                    html:block($config, ., "head6", .)
            case element(hi) return
                if (@rend = 'strong') then
                    html:inline($config, ., "hi1", .)
                else
                    if (@rend = 'italic') then
                        html:inline($config, ., "hi2", .)
                    else
                        if (@rend = 'smallcaps') then
                            html:inline($config, ., "hi3", .)
                        else
                            if (@rendition) then
                                html:inline($config, ., css:get-rendition(., "hi4"), .)
                            else
                                if (not(@rendition)) then
                                    html:inline($config, ., "hi5", .)
                                else
                                    $config?apply($config, ./node())
            case element(item) return
                html:listItem($config, ., "item", .)
            case element(l) return
                html:block($config, ., css:get-rendition(., "l"), .)
            case element(label) return
                html:inline($config, ., "label", .)
            case element(lb) return
                html:break($config, ., css:get-rendition(., "lb"), ., 'line', @n)
            case element(lg) return
                html:block($config, ., "lg", .)
            case element(list) return
                if (@rendition) then
                    html:list($config, ., css:get-rendition(., "list1"), item)
                else
                    if (not(@rendition)) then
                        html:list($config, ., "list2", item)
                    else
                        $config?apply($config, ./node())
            case element(listBibl) return
                if (bibl) then
                    html:list($config, ., "listBibl1", bibl)
                else
                    html:block($config, ., "listBibl2", .)
            case element(measure) return
                html:inline($config, ., "measure", .)
            case element(milestone) return
                html:inline($config, ., "milestone", .)
            case element(name) return
                html:inline($config, ., "name", .)
            case element(note) return
                if (@place) then
                    html:note($config, ., "note1", ., @place, @n)
                else
                    html:note($config, ., "note2", ., (), ())
            case element(num) return
                html:inline($config, ., "num", .)
            case element(orig) return
                html:inline($config, ., "orig", .)
            case element(p) return
                if (@rend = 'center') then
                    html:paragraph($config, ., css:get-rendition(., "p1"), .)
                else
                    html:paragraph($config, ., css:get-rendition(., "p2"), .)
            case element(pb) return
                html:break($config, ., css:get-rendition(., "pb"), ., 'page', (concat(if(@n) then     concat(@n,' ') else '',if(@facs) then     concat('@',@facs) else '')))
            case element(publisher) return
                html:inline($config, ., "publisher", .)
            case element(pubPlace) return
                html:inline($config, ., "pubPlace", .)
            case element(q) return
                if (l) then
                    html:block($config, ., css:get-rendition(., "q1"), .)
                else
                    if (ancestor::p or ancestor::cell) then
                        html:inline($config, ., css:get-rendition(., "q2"), .)
                    else
                        html:block($config, ., css:get-rendition(., "q3"), .)
            case element(quote) return
                if (ancestor::p) then
                    (: If it is inside a paragraph then it is inline, otherwise it is block level :)
                    html:inline($config, ., css:get-rendition(., "quote1"), .)
                else
                    (: If it is inside a paragraph then it is inline, otherwise it is block level :)
                    html:block($config, ., css:get-rendition(., "quote2"), .)
            case element(ref) return
                if (not(@target)) then
                    html:inline($config, ., "ref1", .)
                else
                    if (not(text())) then
                        html:link($config, ., "ref2", @target, @target)
                    else
                        html:link($config, ., "ref3", ., @target)
            case element(reg) return
                html:inline($config, ., "reg", .)
            case element(rs) return
                html:inline($config, ., "rs", .)
            case element(sic) return
                if (parent::choice and count(parent::*/*) gt 1) then
                    html:inline($config, ., "sic1", .)
                else
                    html:inline($config, ., "sic2", .)
            case element(sp) return
                html:block($config, ., "sp", .)
            case element(speaker) return
                html:block($config, ., "speaker", .)
            case element(stage) return
                html:block($config, ., "stage", .)
            case element(time) return
                html:inline($config, ., "time", .)
            case element(title) return
                html:inline($config, ., "title", .)
            case element(unclear) return
                html:inline($config, ., "unclear", .)
            case element(revisionDesc) return
                html:omit($config, ., "revisionDesc", .)
            case element(encodingDesc) return
                html:omit($config, ., "encodingDesc", .)
            case element(fileDesc) return
                (
                    html:block($config, ., "fileDesc1", titleStmt),
                    html:block($config, ., "fileDesc2", publicationStmt)
                )

            case element(profileDesc) return
                html:omit($config, ., "profileDesc", .)
            case element(publicationStmt) return
                (
                    html:block($config, ., "publicationStmt1", publisher),
                    html:block($config, ., "publicationStmt2", pubPlace),
                    html:block($config, ., "publicationStmt3", date)
                )

            case element(teiHeader) return
                html:block($config, ., "teiHeader", .)
            case element(titleStmt) return
                (
                    html:heading($config, ., "titleStmt1", title[@type="complete"]),
                    html:block($config, ., "titleStmt2", "Editors:"),
                    ext-html:list-from-items($config, ., "titleStmt3", editor[@role="primary"], ()),
                    html:block($config, ., "titleStmt4", "General Editor:"),
                    ext-html:list-from-items($config, ., "titleStmt5", editor[@role="general"], ())
                )

            case element(g) return
                if (not(text())) then
                    html:glyph($config, ., "g1", .)
                else
                    html:inline($config, ., "g2", .)
            case element(addSpan) return
                html:anchor($config, ., "addSpan", ., @xml:id)
            case element(am) return
                html:inline($config, ., "am", .)
            case element(ex) return
                html:inline($config, ., "ex", .)
            case element(fw) return
                if (ancestor::p or ancestor::ab) then
                    html:inline($config, ., "fw1", .)
                else
                    html:block($config, ., "fw2", .)
            case element(handShift) return
                html:inline($config, ., "handShift", .)
            case element(space) return
                html:inline($config, ., "space", .)
            case element(subst) return
                html:inline($config, ., "subst", .)
            case element(supplied) return
                if (parent::choice) then
                    html:inline($config, ., "supplied1", .)
                else
                    if (@reason='damage') then
                        html:inline($config, ., "supplied2", .)
                    else
                        if (@reason='illegible' or not(@reason)) then
                            html:inline($config, ., "supplied3", .)
                        else
                            if (@reason='omitted') then
                                html:inline($config, ., "supplied4", .)
                            else
                                html:inline($config, ., "supplied5", .)
            case element(c) return
                html:inline($config, ., "c", .)
            case element(pc) return
                html:inline($config, ., "pc", .)
            case element(s) return
                html:inline($config, ., "s", .)
            case element(w) return
                html:inline($config, ., "w", .)
            case element(ab) return
                html:paragraph($config, ., "ab", .)
            case element(anchor) return
                html:anchor($config, ., "anchor", ., @xml:id)
            case element(seg) return
                html:inline($config, ., css:get-rendition(., "seg"), .)
            case element(actor) return
                html:inline($config, ., "actor", .)
            case element(castGroup) return
                if (child::*) then
                    (: Insert list. :)
                    html:list($config, ., "castGroup", castItem|castGroup)
                else
                    $config?apply($config, ./node())
            case element(castItem) return
                (: Insert item, rendered as described in parent list rendition. :)
                html:listItem($config, ., "castItem", .)
            case element(castList) return
                if (child::*) then
                    html:list($config, ., css:get-rendition(., "castList"), castItem)
                else
                    $config?apply($config, ./node())
            case element(role) return
                html:block($config, ., "role", .)
            case element(roleDesc) return
                html:block($config, ., "roleDesc", .)
            case element(spGrp) return
                html:block($config, ., "spGrp", .)
            case element(argument) return
                html:block($config, ., "argument", .)
            case element(back) return
                html:block($config, ., "back", .)
            case element(body) return
                (
                    html:index($config, ., "body1", 'toc', .),
                    html:block($config, ., "body2", .)
                )

            case element(byline) return
                html:block($config, ., "byline", .)
            case element(closer) return
                html:block($config, ., "closer", .)
            case element(dateline) return
                html:block($config, ., "dateline", .)
            case element(div) return
                if (@type='title_page') then
                    html:block($config, ., "div1", .)
                else
                    if (parent::body or parent::front or parent::back) then
                        html:section($config, ., "div2", .)
                    else
                        html:block($config, ., "div3", .)
            case element(docAuthor) return
                if (ancestor::teiHeader) then
                    (: Omit if located in teiHeader. :)
                    html:omit($config, ., "docAuthor1", .)
                else
                    html:inline($config, ., "docAuthor2", .)
            case element(docDate) return
                if (ancestor::teiHeader) then
                    (: Omit if located in teiHeader. :)
                    html:omit($config, ., "docDate1", .)
                else
                    html:inline($config, ., "docDate2", .)
            case element(docEdition) return
                if (ancestor::teiHeader) then
                    (: Omit if located in teiHeader. :)
                    html:omit($config, ., "docEdition1", .)
                else
                    html:inline($config, ., "docEdition2", .)
            case element(docImprint) return
                if (ancestor::teiHeader) then
                    (: Omit if located in teiHeader. :)
                    html:omit($config, ., "docImprint1", .)
                else
                    html:inline($config, ., "docImprint2", .)
            case element(docTitle) return
                if (ancestor::teiHeader) then
                    (: Omit if located in teiHeader. :)
                    html:omit($config, ., "docTitle1", .)
                else
                    html:block($config, ., css:get-rendition(., "docTitle2"), .)
            case element(epigraph) return
                html:block($config, ., "epigraph", .)
            case element(floatingText) return
                html:block($config, ., "floatingText", .)
            case element(front) return
                html:block($config, ., "front", .)
            case element(group) return
                html:block($config, ., "group", .)
            case element(imprimatur) return
                html:block($config, ., "imprimatur", .)
            case element(opener) return
                html:block($config, ., "opener", .)
            case element(postscript) return
                html:block($config, ., "postscript", .)
            case element(salute) return
                if (parent::closer) then
                    html:inline($config, ., "salute1", .)
                else
                    html:block($config, ., "salute2", .)
            case element(signed) return
                if (parent::closer) then
                    html:block($config, ., "signed1", .)
                else
                    html:inline($config, ., "signed2", .)
            case element(TEI) return
                html:document($config, ., "TEI", .)
            case element(text) return
                html:body($config, ., "text", .)
            case element(titlePage) return
                html:block($config, ., css:get-rendition(., "titlePage"), .)
            case element(titlePart) return
                html:block($config, ., css:get-rendition(., "titlePart"), .)
            case element(trailer) return
                html:block($config, ., "trailer", .)
            case element(cell) return
                (: Insert table cell. :)
                html:cell($config, ., "cell", .)
            case element(figDesc) return
                html:inline($config, ., "figDesc", .)
            case element(figure) return
                if (head or @rendition='simple:display') then
                    html:block($config, ., "figure1", .)
                else
                    html:inline($config, ., "figure2", .)
            case element(formula) return
                if (@rendition='simple:display') then
                    html:block($config, ., "formula1", .)
                else
                    html:inline($config, ., "formula2", .)
            case element(row) return
                if (@role='label') then
                    html:row($config, ., "row1", .)
                else
                    (: Insert table row. :)
                    html:row($config, ., "row2", .)
            case element(table) return
                html:table($config, ., "table", .)
            case element(rhyme) return
                html:inline($config, ., "rhyme", .)
            case element(persName) return
                html:inline($config, ., "persName", .)
            case element(gloss) return
                html:inline($config, ., "gloss", .)
            case element(term) return
                html:inline($config, ., "term", .)
            case element(exist:match) return
                html:match($config, ., .)
            case text() | xs:anyAtomicType return
                html:escapeChars(.)
            default return 
                $config?apply($config, ./node())

    )

};

declare function model:apply-children($config as map(*), $node as element(), $content as item()*) {
        
    let $id := $node/@xml:id
    return
        if ($id) then
            attribute id { $id }
        else
            (),
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

