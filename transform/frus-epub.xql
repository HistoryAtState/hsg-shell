(:~

    Transformation module generated from TEI ODD extensions for processing models.
    ODD: /db/apps/hsg-shell/resources/odd/source/frus.odd
 :)
xquery version "3.1";

module namespace model="http://www.tei-c.org/pm/models/frus/epub";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare namespace xhtml='http://www.w3.org/1999/xhtml';

declare namespace skos='http://www.w3.org/2004/02/skos/core#';

declare namespace frus='http://history.state.gov/frus/ns/1.0';

import module namespace css="http://www.tei-c.org/tei-simple/xquery/css";

import module namespace html="http://www.tei-c.org/tei-simple/xquery/functions";

import module namespace epub="http://www.tei-c.org/tei-simple/xquery/functions/epub";

(:~

    Main entry point for the transformation.
    
 :)
declare function model:transform($options as map(*), $input as node()*) {
        
    let $config :=
        map:merge(($options,
            map {
                "output": ["epub","web"],
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
                    case element(handShift) return
                        html:inline($config, ., ("tei-handShift", css:map-rend-to-class(.)), .)
                    case element(castItem) return
                        (: Insert item, rendered as described in parent list rendition. :)
                        html:listItem($config, ., ("tei-castItem", css:map-rend-to-class(.)), ., ())
                    case element(item) return
                        html:listItem($config, ., ("tei-item", css:map-rend-to-class(.)), ., ())
                    case element(teiHeader) return
                        (
                            epub:block($config, ., ("tei-teiHeader1", css:map-rend-to-class(.)), .),
                            html:omit($config, ., ("tei-teiHeader2", css:map-rend-to-class(.)), .)
                        )

                    case element(figure) return
                        if (@rend='smallfloatinline') then
                            epub:block($config, ., ("tei-figure1", "float-left", "figure-floated", css:map-rend-to-class(.)), .)
                        else
                            if (head or @rendition='simple:display') then
                                epub:block($config, ., ("tei-figure2", css:map-rend-to-class(.)), .)
                            else
                                html:inline($config, ., ("tei-figure3", css:map-rend-to-class(.)), .)
                    case element(supplied) return
                        if (parent::choice) then
                            html:inline($config, ., ("tei-supplied1", css:map-rend-to-class(.)), .)
                        else
                            if (@reason='damage') then
                                html:inline($config, ., ("tei-supplied2", css:map-rend-to-class(.)), .)
                            else
                                if (@reason='illegible' or not(@reason)) then
                                    html:inline($config, ., ("tei-supplied3", css:map-rend-to-class(.)), .)
                                else
                                    if (@reason='omitted') then
                                        html:inline($config, ., ("tei-supplied4", css:map-rend-to-class(.)), .)
                                    else
                                        html:inline($config, ., ("tei-supplied5", css:map-rend-to-class(.)), .)
                    case element(milestone) return
                        html:inline($config, ., ("tei-milestone", css:map-rend-to-class(.)), .)
                    case element(label) return
                        if (@foo='baz') then
                            html:inline($config, ., ("tei-label1", css:map-rend-to-class(.)), .)
                        else
                            html:inline($config, ., ("tei-label2", css:map-rend-to-class(.)), .)
                    case element(signed) return
                        if (parent::closer) then
                            epub:block($config, ., ("tei-signed1", css:map-rend-to-class(.)), .)
                        else
                            html:inline($config, ., ("tei-signed2", css:map-rend-to-class(.)), .)
                    case element(pb) return
                        (
                            (: No function found for behavior: pb-link :)
                            $config?apply($config, ./node())
                        )

                    case element(pc) return
                        html:inline($config, ., ("tei-pc", css:map-rend-to-class(.)), .)
                    case element(TEI) return
                        html:document($config, ., ("tei-TEI", css:map-rend-to-class(.)), .)
                    case element(anchor) return
                        html:anchor($config, ., ("tei-anchor", css:map-rend-to-class(.)), ., @xml:id)
                    case element(formula) return
                        if (@rendition='simple:display') then
                            epub:block($config, ., ("tei-formula1", css:map-rend-to-class(.)), .)
                        else
                            html:inline($config, ., ("tei-formula2", css:map-rend-to-class(.)), .)
                    case element(choice) return
                        if (sic and corr) then
                            epub:alternate($config, ., ("tei-choice4", css:map-rend-to-class(.)), ., corr[1], sic[1])
                        else
                            if (abbr and expan) then
                                epub:alternate($config, ., ("tei-choice5", css:map-rend-to-class(.)), ., expan[1], abbr[1])
                            else
                                if (orig and reg) then
                                    epub:alternate($config, ., ("tei-choice6", css:map-rend-to-class(.)), ., reg[1], orig[1])
                                else
                                    $config?apply($config, ./node())
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
                                epub:note($config, ., ("tei-note3", css:map-rend-to-class(.)), ., "foot", @n/string())
                    case element(addSpan) return
                        html:anchor($config, ., ("tei-addSpan", css:map-rend-to-class(.)), ., @xml:id)
                    case element(dateline) return
                        epub:block($config, ., ("tei-dateline", css:map-rend-to-class(.)), .)
                    case element(back) return
                        epub:block($config, ., ("tei-back", css:map-rend-to-class(.)), .)
                    case element(del) return
                        html:inline($config, ., ("tei-del", css:map-rend-to-class(.)), .)
                    case element(trailer) return
                        epub:block($config, ., ("tei-trailer", css:map-rend-to-class(.)), .)
                    case element(titlePart) return
                        epub:block($config, ., css:get-rendition(., ("tei-titlePart", css:map-rend-to-class(.))), .)
                    case element(ab) return
                        html:paragraph($config, ., ("tei-ab", css:map-rend-to-class(.)), .)
                    case element(revisionDesc) return
                        html:omit($config, ., ("tei-revisionDesc", css:map-rend-to-class(.)), .)
                    case element(subst) return
                        html:inline($config, ., ("tei-subst", css:map-rend-to-class(.)), .)
                    case element(am) return
                        html:inline($config, ., ("tei-am", css:map-rend-to-class(.)), .)
                    case element(roleDesc) return
                        epub:block($config, ., ("tei-roleDesc", css:map-rend-to-class(.)), .)
                    case element(orig) return
                        html:inline($config, ., ("tei-orig", css:map-rend-to-class(.)), .)
                    case element(opener) return
                        epub:block($config, ., ("tei-opener", css:map-rend-to-class(.)), .)
                    case element(speaker) return
                        epub:block($config, ., ("tei-speaker", css:map-rend-to-class(.)), .)
                    case element(publisher) return
                        html:inline($config, ., ("tei-publisher", css:map-rend-to-class(.)), .)
                    case element(imprimatur) return
                        epub:block($config, ., ("tei-imprimatur", css:map-rend-to-class(.)), .)
                    case element(rs) return
                        html:inline($config, ., ("tei-rs", css:map-rend-to-class(.)), .)
                    case element(figDesc) return
                        html:omit($config, ., ("tei-figDesc", css:map-rend-to-class(.)), .)
                    case element(foreign) return
                        html:inline($config, ., ("tei-foreign", css:map-rend-to-class(.)), .)
                    case element(fileDesc) return
                        (
                            epub:block($config, ., ("tei-fileDesc1", css:map-rend-to-class(.)), titleStmt),
                            epub:block($config, ., ("tei-fileDesc2", css:map-rend-to-class(.)), publicationStmt)
                        )

                    case element(seg) return
                        html:inline($config, ., css:get-rendition(., ("tei-seg", css:map-rend-to-class(.))), .)
                    case element(profileDesc) return
                        html:omit($config, ., ("tei-profileDesc", css:map-rend-to-class(.)), .)
                    case element(floatingText) return
                        epub:block($config, ., ("tei-floatingText", css:map-rend-to-class(.)), .)
                    case element(text) return
                        html:body($config, ., ("tei-text", css:map-rend-to-class(.)), .)
                    case element(sp) return
                        epub:block($config, ., ("tei-sp", css:map-rend-to-class(.)), .)
                    case element(table) return
                        if (.//row/@rendition or .//cell/@rendition) then
                            html:table($config, ., css:get-rendition(., ("tei-table1", css:map-rend-to-class(.))), .)
                        else
                            html:table($config, ., css:get-rendition(., ("tei-table2", "table", "table-hover", "table-bordered", css:map-rend-to-class(.))), .)
                    case element(abbr) return
                        html:inline($config, ., ("tei-abbr", css:map-rend-to-class(.)), .)
                    case element(group) return
                        epub:block($config, ., ("tei-group", css:map-rend-to-class(.)), .)
                    case element(cb) return
                        epub:break($config, ., ("tei-cb", css:map-rend-to-class(.)), ., 'column', @n)
                    case element(listBibl) return
                        if (bibl) then
                            html:list($config, ., ("tei-listBibl1", css:map-rend-to-class(.)), bibl, ())
                        else
                            epub:block($config, ., ("tei-listBibl2", css:map-rend-to-class(.)), .)
                    case element(c) return
                        html:inline($config, ., ("tei-c", css:map-rend-to-class(.)), .)
                    case element(address) return
                        epub:block($config, ., ("tei-address", css:map-rend-to-class(.)), .)
                    case element(g) return
                        if (not(text())) then
                            html:glyph($config, ., ("tei-g1", css:map-rend-to-class(.)), .)
                        else
                            html:inline($config, ., ("tei-g2", css:map-rend-to-class(.)), .)
                    case element(author) return
                        if (ancestor::teiHeader) then
                            html:omit($config, ., ("tei-author1", css:map-rend-to-class(.)), .)
                        else
                            html:inline($config, ., ("tei-author2", css:map-rend-to-class(.)), .)
                    case element(castList) return
                        if (child::*) then
                            html:list($config, ., css:get-rendition(., ("tei-castList", css:map-rend-to-class(.))), castItem, ())
                        else
                            $config?apply($config, ./node())
                    case element(l) return
                        epub:block($config, ., css:get-rendition(., ("tei-l", css:map-rend-to-class(.))), .)
                    case element(closer) return
                        epub:block($config, ., ("tei-closer", css:map-rend-to-class(.)), .)
                    case element(rhyme) return
                        html:inline($config, ., ("tei-rhyme", css:map-rend-to-class(.)), .)
                    case element(p) return
                        if (@rend = 'center') then
                            html:paragraph($config, ., css:get-rendition(., ("tei-p1", css:map-rend-to-class(.))), .)
                        else
                            if (@rend = 'flushleft') then
                                html:paragraph($config, ., css:get-rendition(., ("tei-p2", css:map-rend-to-class(.))), .)
                            else
                                html:paragraph($config, ., css:get-rendition(., ("tei-p3", css:map-rend-to-class(.))), .)
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
                    case element(q) return
                        if (l) then
                            epub:block($config, ., css:get-rendition(., ("tei-q1", css:map-rend-to-class(.))), .)
                        else
                            if (ancestor::p or ancestor::cell) then
                                html:inline($config, ., css:get-rendition(., ("tei-q2", css:map-rend-to-class(.))), .)
                            else
                                epub:block($config, ., css:get-rendition(., ("tei-q3", css:map-rend-to-class(.))), .)
                    case element(measure) return
                        html:inline($config, ., ("tei-measure", css:map-rend-to-class(.)), .)
                    case element(epigraph) return
                        epub:block($config, ., ("tei-epigraph", css:map-rend-to-class(.)), .)
                    case element(actor) return
                        html:inline($config, ., ("tei-actor", css:map-rend-to-class(.)), .)
                    case element(s) return
                        html:inline($config, ., ("tei-s", css:map-rend-to-class(.)), .)
                    case element(lb) return
                        epub:break($config, ., css:get-rendition(., ("tei-lb", css:map-rend-to-class(.))), ., 'line', @n)
                    case element(docTitle) return
                        if (ancestor::teiHeader) then
                            (: Omit if located in teiHeader. :)
                            html:omit($config, ., ("tei-docTitle1", css:map-rend-to-class(.)), .)
                        else
                            epub:block($config, ., css:get-rendition(., ("tei-docTitle2", css:map-rend-to-class(.))), .)
                    case element(w) return
                        html:inline($config, ., ("tei-w", css:map-rend-to-class(.)), .)
                    case element(titlePage) return
                        epub:block($config, ., css:get-rendition(., ("tei-titlePage", css:map-rend-to-class(.))), .)
                    case element(stage) return
                        epub:block($config, ., ("tei-stage", css:map-rend-to-class(.)), .)
                    case element(name) return
                        html:inline($config, ., ("tei-name", css:map-rend-to-class(.)), .)
                    case element(lg) return
                        epub:block($config, ., ("tei-lg", css:map-rend-to-class(.)), .)
                    case element(front) return
                        epub:block($config, ., ("tei-front", css:map-rend-to-class(.)), .)
                    case element(desc) return
                        html:inline($config, ., ("tei-desc", css:map-rend-to-class(.)), .)
                    case element(role) return
                        epub:block($config, ., ("tei-role", css:map-rend-to-class(.)), .)
                    case element(num) return
                        html:inline($config, ., ("tei-num", css:map-rend-to-class(.)), .)
                    case element(docEdition) return
                        if (ancestor::teiHeader) then
                            (: Omit if located in teiHeader. :)
                            html:omit($config, ., ("tei-docEdition1", css:map-rend-to-class(.)), .)
                        else
                            html:inline($config, ., ("tei-docEdition2", css:map-rend-to-class(.)), .)
                    case element(postscript) return
                        epub:block($config, ., ("tei-postscript", css:map-rend-to-class(.)), .)
                    case element(docImprint) return
                        if (ancestor::teiHeader) then
                            (: Omit if located in teiHeader. :)
                            html:omit($config, ., ("tei-docImprint1", css:map-rend-to-class(.)), .)
                        else
                            html:inline($config, ., ("tei-docImprint2", css:map-rend-to-class(.)), .)
                    case element(space) return
                        html:inline($config, ., ("tei-space", css:map-rend-to-class(.)), .)
                    case element(cell) return
                        (: Insert table cell. :)
                        html:cell($config, ., css:get-rendition(., ("tei-cell", css:map-rend-to-class(.))), ., ())
                    case element(div) return
                        if ($parameters?document-list and div[@type='question']) then
                            (: No function found for behavior: document-list :)
                            $config?apply($config, ./node())
                        else
                            if ($parameters?document-list and @type = ('compilation', 'chapter', 'subchapter', 'section', 'part') and exists(div[@type and not(@type = 'online-supplement')])) then
                                (: No function found for behavior: document-list :)
                                $config?apply($config, ./node())
                            else
                                epub:block($config, ., ("tei-div3", css:map-rend-to-class(.)), .)
                    case element(reg) return
                        html:inline($config, ., ("tei-reg", css:map-rend-to-class(.)), .)
                    case element(graphic) return
                        html:graphic($config, ., css:get-rendition(., ("tei-graphic", css:map-rend-to-class(.))), ., 
                            if (matches(@url, '^https?://')) then @url else ( xs:anyURI('https://static.history.state.gov/' || $parameters?base-uri ||
                            "/" || @url || (if (matches(@url, "^.*\.(jpg|png|gif)$")) then "" else ".png")) )
                        , (), (), @scale, (../desc, ../figDesc) => head() => normalize-space())
                    case element(ref) return
                        (: No function found for behavior: ref :)
                        $config?apply($config, ./node())
                    case element(pubPlace) return
                        html:inline($config, ., ("tei-pubPlace", css:map-rend-to-class(.)), .)
                    case element(add) return
                        html:inline($config, ., ("tei-add", css:map-rend-to-class(.)), .)
                    case element(docDate) return
                        if (ancestor::teiHeader) then
                            (: Omit if located in teiHeader. :)
                            html:omit($config, ., ("tei-docDate1", css:map-rend-to-class(.)), .)
                        else
                            html:inline($config, ., ("tei-docDate2", css:map-rend-to-class(.)), .)
                    case element(head) return
                        if (parent::figure) then
                            epub:block($config, ., ("tei-head1", css:map-rend-to-class(.)), .)
                        else
                            if (parent::table) then
                                epub:block($config, ., ("tei-head2", css:map-rend-to-class(.)), .)
                            else
                                if (parent::list/@type = ('participants', 'to', 'from', 'subject')) then
                                    epub:block($config, ., ("tei-head3", css:map-rend-to-class(.)), .)
                                else
                                    if (parent::list) then
                                        epub:block($config, ., ("tei-head4", css:map-rend-to-class(.)), .)
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
                                                    epub:block($config, ., ("tei-head8", css:map-rend-to-class(.)), .)
                    case element(ex) return
                        html:inline($config, ., ("tei-ex", css:map-rend-to-class(.)), .)
                    case element(time) return
                        html:inline($config, ., ("tei-time", css:map-rend-to-class(.)), .)
                    case element(castGroup) return
                        if (child::*) then
                            (: Insert list. :)
                            html:list($config, ., ("tei-castGroup", css:map-rend-to-class(.)), castItem|castGroup, ())
                        else
                            $config?apply($config, ./node())
                    case element(bibl) return
                        if (parent::listBibl) then
                            html:listItem($config, ., ("tei-bibl1", css:map-rend-to-class(.)), ., ())
                        else
                            html:inline($config, ., ("tei-bibl2", css:map-rend-to-class(.)), .)
                    case element(unclear) return
                        html:inline($config, ., ("tei-unclear", css:map-rend-to-class(.)), .)
                    case element(salute) return
                        if (parent::closer) then
                            html:inline($config, ., ("tei-salute1", css:map-rend-to-class(.)), .)
                        else
                            epub:block($config, ., ("tei-salute2", css:map-rend-to-class(.)), .)
                    case element(title) return
                        if (@level = 's') then
                            html:inline($config, ., ("tei-title1", css:map-rend-to-class(.)), .)
                        else
                            html:inline($config, ., ("tei-title2", css:map-rend-to-class(.)), .)
                    case element(date) return
                        html:inline($config, ., ("tei-date", css:map-rend-to-class(.)), .)
                    case element(argument) return
                        epub:block($config, ., ("tei-argument", css:map-rend-to-class(.)), .)
                    case element(corr) return
                        if (parent::choice and count(parent::*/*) gt 1) then
                            (: simple inline, if in parent choice. :)
                            html:inline($config, ., ("tei-corr1", css:map-rend-to-class(.)), .)
                        else
                            html:inline($config, ., ("tei-corr2", css:map-rend-to-class(.)), .)
                    case element(cit) return
                        if (child::quote and child::bibl) then
                            (: Insert citation :)
                            html:cit($config, ., ("tei-cit", css:map-rend-to-class(.)), ., ())
                        else
                            $config?apply($config, ./node())
                    case element(sic) return
                        if (parent::choice and count(parent::*/*) gt 1) then
                            html:inline($config, ., ("tei-sic1", css:map-rend-to-class(.)), .)
                        else
                            html:inline($config, ., ("tei-sic2", css:map-rend-to-class(.)), .)
                    case element(expan) return
                        html:inline($config, ., ("tei-expan", css:map-rend-to-class(.)), .)
                    case element(spGrp) return
                        epub:block($config, ., ("tei-spGrp", css:map-rend-to-class(.)), .)
                    case element(body) return
                        (
                            html:index($config, ., ("tei-body1", css:map-rend-to-class(.)), 'toc', .),
                            epub:block($config, ., ("tei-body2", css:map-rend-to-class(.)), .)
                        )

                    case element(fw) return
                        if (ancestor::p or ancestor::ab) then
                            html:inline($config, ., ("tei-fw1", css:map-rend-to-class(.)), .)
                        else
                            epub:block($config, ., ("tei-fw2", css:map-rend-to-class(.)), .)
                    case element(encodingDesc) return
                        html:omit($config, ., ("tei-encodingDesc", css:map-rend-to-class(.)), .)
                    case element(quote) return
                        if (ancestor::p and empty(descendant::p|descendant::div)) then
                            (: If it is inside a paragraph then it is inline, otherwise it is block level; no extra quote marks around :)
                            html:inline($config, ., css:get-rendition(., ("tei-quote1", css:map-rend-to-class(.))), .)
                        else
                            (: If it is inside a paragraph then it is inline, otherwise it is block level :)
                            epub:block($config, ., css:get-rendition(., ("tei-quote2", css:map-rend-to-class(.))), .)
                    case element(gap) return
                        html:omit($config, ., ("tei-gap", css:map-rend-to-class(.)), .)
                    case element(addrLine) return
                        epub:block($config, ., ("tei-addrLine", css:map-rend-to-class(.)), .)
                    case element(row) return
                        (: Insert table row. :)
                        html:row($config, ., css:get-rendition(., ("tei-row", css:map-rend-to-class(.))), .)
                    case element(docAuthor) return
                        if (ancestor::teiHeader) then
                            (: Omit if located in teiHeader. :)
                            html:omit($config, ., ("tei-docAuthor1", css:map-rend-to-class(.)), .)
                        else
                            html:inline($config, ., ("tei-docAuthor2", css:map-rend-to-class(.)), .)
                    case element(byline) return
                        epub:block($config, ., ("tei-byline", css:map-rend-to-class(.)), .)
                    case element(titleStmt) return
                        (
                            html:heading($config, ., ("tei-titleStmt1", css:map-rend-to-class(.)), title[@type="complete"], ()),
                            if (count(editor[@role = 'primary']) gt 1) then
                                epub:block($config, ., ("tei-titleStmt2", css:map-rend-to-class(.)), "Editors:")
                            else
                                (),
                            if (count(editor[@role = 'primary'][. ne '']) eq 1) then
                                epub:block($config, ., ("tei-titleStmt3", css:map-rend-to-class(.)), "Editor:")
                            else
                                (),
                            if (editor[@role = 'primary'][. ne '']) then
                                (: No function found for behavior: list-from-items :)
                                $config?apply($config, ./node())
                            else
                                (),
                            if (editor[@role = 'general'][. ne '']) then
                                epub:block($config, ., ("tei-titleStmt5", css:map-rend-to-class(.)), "General Editor:")
                            else
                                (),
                            if (editor[@role = 'general'][. ne '']) then
                                (: No function found for behavior: list-from-items :)
                                $config?apply($config, ./node())
                            else
                                ()
                        )

                    case element(publicationStmt) return
                        (
                            epub:block($config, ., ("tei-publicationStmt1", css:map-rend-to-class(.)), publisher),
                            epub:block($config, ., ("tei-publicationStmt2", css:map-rend-to-class(.)), pubPlace),
                            epub:block($config, ., ("tei-publicationStmt3", css:map-rend-to-class(.)), date[@type="publication-date"])
                        )

                    case element(xhtml:object) return
                        (: No function found for behavior: passthrough :)
                        $config?apply($config, ./node())
                    case element(xhtml:div) return
                        (: No function found for behavior: passthrough :)
                        $config?apply($config, ./node())
                    case element(xhtml:script) return
                        (: No function found for behavior: passthrough :)
                        $config?apply($config, ./node())
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

