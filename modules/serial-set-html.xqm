xquery version "3.0";

module namespace ssh = "http://history.state.gov/ns/site/hsg/serial-set-html";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $ssh:SERIAL_SET_COL := '/db/apps/other-publications/serial-set';

declare variable $ssh:SERIAL_SET_DOC { doc($ssh:SERIAL_SET_COL || '/pre-1861.xml') };

declare variable $ssh:BIBLS { $ssh:SERIAL_SET_DOC//tei:listBibl/tei:bibl };

declare variable $ssh:REGIONS { distinct-values($ssh:BIBLS/tei:term[@type='region']) };

declare variable $ssh:SUBJECTS { distinct-values($ssh:BIBLS/tei:term[@type='subject']) };

declare function ssh:regions-count($node, $model) {
    count($ssh:REGIONS)
};

declare function ssh:subjects-count($node, $model) {
    count($ssh:SUBJECTS)
}; 

declare function ssh:bibls-count($node, $model) {
    count($ssh:BIBLS)
};

declare function ssh:region-subject-list($node, $model) {
    <ul class="hsg-list-unstyled">{
        for $region in $ssh:REGIONS 
        let $regional-subject-entries := $ssh:BIBLS[tei:term[@type = 'region'] = $region]/tei:term[@type = 'subject']
        order by $region 
        return 
            <li><a href="$app/historicaldocuments/pre-1861/serial-set/browse?region={encode-for-uri($region)}">{$region}</a> ({count($regional-subject-entries)})
                <ul>{
                    for $subject in distinct-values($regional-subject-entries)
                    let $subject-entries := $regional-subject-entries[../tei:term[@type = 'subject'] = $subject]
                    order by $subject
                    return
                        <li><a href="$app/historicaldocuments/pre-1861/serial-set/browse?region={encode-for-uri($region)}&amp;subject={encode-for-uri($subject)}">{$subject}</a> ({count($subject-entries)})</li>
                }</ul>
            </li>
    }</ul>
};

declare function ssh:region-and-or-subject-name($node, $model) {
    let $region := request:get-parameter('region', ())
    let $regionUrl := "$app/historicaldocuments/pre-1861/serial-set/browse?region=" || encode-for-uri($region)
    let $regionElement := <li><a href="#{$regionUrl}">{$region}</a></li>

    let $subject := request:get-parameter('subject', ())
    let $subjectElement :=
        if ($subject) then
            <li><a href="{$regionUrl}&amp;subject={encode-for-uri($subject)}">{$subject}</a></li>
        else
            ()

    return ($regionElement, $subjectElement)
};

declare function ssh:region-and-subject-link($node, $model) {
    let $region := request:get-parameter('region', ())
    let $subject := request:get-parameter('subject', ())
    for $i in ($region, $subject)[exists(.)]
        return <li><a href="$app/historicaldocuments/pre-1861/serial-set/browse?region={encode-for-uri($region)}">{$i}</a></li>
};

declare function ssh:bibls-filtered-table($node, $model) {
    let $region := request:get-parameter('region', ())
    let $subject := request:get-parameter('subject', ())
    let $request-type := 
        if ($region and $subject) then
            'region-subject'
        else if ($region) then
            'region'
        else 
            'all'
    let $bibls :=
        switch ($request-type)
            case "region-subject" return
                $ssh:BIBLS//tei:term[@type='region'][. = $region]/.. intersect $ssh:BIBLS//tei:term[@type='subject'][. = $subject]/..
            case "region" return
                $ssh:BIBLS//tei:term[@type='region'][. = $region]/..
            default return
                $ssh:BIBLS
    let $cols-to-exclude :=
        switch ($request-type)
            case "region-subject" return
                ('Region', 'Subject')
            case "region" return
                'Region'
            default return
                ()
    return
        ssh:bibls-to-table($bibls, $cols-to-exclude)
};

declare function ssh:bibls-filtered-count($node, $model) {
    let $region := request:get-parameter('region', ())
    let $subject := request:get-parameter('subject', ())
    let $request-type := 
        if ($region and $subject) then
            'region-subject'
        else if ($region) then
            'region'
        else 
            'all'
    let $bibls :=
        switch ($request-type)
            case "region-subject" return
                $ssh:BIBLS//tei:term[@type='region'][. = $region]/.. intersect $ssh:BIBLS//tei:term[@type='subject'][. = $subject]/..
            case "region" return
                $ssh:BIBLS//tei:term[@type='region'][. = $region]/..
            default return
                $ssh:BIBLS
    return
        count($bibls)
};

declare function ssh:bibls-to-table($bibls as element()+, $cols-to-exclude as xs:string*) {
    <table class="hsg-table-bordered">
        <thead>{
            for $head in ('Region', 'Subject', 'Title', 'Date', 'Citation', 'Pages')[not(. = $cols-to-exclude)]
            return
                <th>{ $head }</th>
        }</thead>
        <tbody>{
            let $ordered-bibls := 
                for $bibl in $bibls
                let $date := $bibl/tei:date/@when/string()
                let $year := substring($date, 1, 4)
                let $month := substring($date, 6, 2)
                let $day := substring($date, 9, 2)
                order by $year, $month, $day
                return $bibl
            for $bibl at $n in $ordered-bibls
            let $region := $bibl/tei:term[@type='region']/string()
            let $subject := $bibl/tei:term[@type='subject']/string()
            let $title := $bibl/tei:title/string()
            let $date := $bibl/tei:date/@when/string()
            let $citation := $bibl/tei:bibl/string()
            let $page-count := $bibl/tei:extent/tei:measure/@quantity/string()
            let $class := if ($n mod 2 = 0) then 'even' else 'odd'
            return
                <tr class="{$class}">
                    {if ($cols-to-exclude = 'Region') then () else <td class="span-1"><a href="$app/historicaldocuments/pre-1861/serial-set/browse?region={encode-for-uri($region)}">{$region}</a></td>}
                    {if ($cols-to-exclude = 'Subject') then () else <td class="span-1"><a href="$app/historicaldocuments/pre-1861/serial-set/browse?region={encode-for-uri($region)}&amp;subject={encode-for-uri($subject)}">{$subject}</a></td>}
                    <td class="span-5">{$title}</td>
                    <td class="span-1">{ if ($date castable as xs:date) then format-date(adjust-date-to-timezone(xs:date($date), ()), '[MNn] [D], [Y]') else $date }</td>
                    <td class="span-3">{$citation}</td>
                    <td class="span-1">{$page-count}</td>
                </tr>
        }</tbody>
    </table>
};

declare function ssh:article-title($node, $model, $country-id as xs:string) {
    let $doc := doc($ssh:ARCHIVES_ARTICLES_COL || '/' || $country-id || '.xml')
    let $title := $doc//tei:title[@type='complete']/string()
    return
        $title
};

declare function ssh:article($node, $model, $country-id as xs:string) {
    let $doc := doc($ssh:ARCHIVES_ARTICLES_COL || '/' || $country-id || '.xml')
    let $text := $doc//tei:body
    return
        pages:process-content($model?odd, $text)
};

