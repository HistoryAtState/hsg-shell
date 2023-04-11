xquery version "3.0";

module namespace travels = "http://history.state.gov/ns/site/hsg/travels-html";

(:~
 : Travels of Presidents and Secretaries of State
 : relevant pages are in pages/departmenthistory/travels: index, president, secretary, etc.
 : draws on data in /db/apps/travels - installed via travels.xar
 :)

import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "app.xqm";
import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";
import module namespace pocom = "http://history.state.gov/ns/site/hsg/pocom-html" at "pocom-html.xqm";
import module namespace templates="http://exist-db.org/xquery/html-templating";

declare variable $travels:DATA_COL := '/db/apps/travels';
declare variable $travels:PRESIDENT_TRAVELS_COL := '/db/apps/travels/president-travels';
declare variable $travels:SECRETARY_TRAVELS_COL := '/db/apps/travels/secretary-travels';
declare variable $travels:PRESIDENTS_COL := '/db/apps/travels/presidents';


declare function travels:load-secretary($node as node(), $model as map(*), $person-or-country-id as xs:string) {
    let $matching-secretary := collection($travels:SECRETARY_TRAVELS_COL)//@who[. eq $person-or-country-id]/..
    let $is-person-or-country-id := 
        if ($matching-secretary) then
            'person'
        else
            'country'
    let $title :=
        if ($is-person-or-country-id eq 'person') then
            pocom:person-name-first-last($node, $model, $person-or-country-id)
        else
            gsh:territory-id-to-short-name($person-or-country-id)
    let $breadcrumb := <li><a href="$app/departmenthistory/travels/secretary/{$person-or-country-id}">{$title}</a></li>
    let $table := 
        if ($is-person-or-country-id eq 'person') then
            travels:by-person("secretary", $person-or-country-id)
        else
            travels:by-country("secretary", $person-or-country-id)
    return
        map {
            "title": $title,
            "breadcrumb": $breadcrumb,
            "table": $table
        }
};

declare function travels:load-president($node as node(), $model as map(*), $person-or-country-id as xs:string) {
    let $matching-president := collection($travels:PRESIDENTS_COL)//president[id eq $person-or-country-id]
    let $is-person-or-country-id := 
            if ($matching-president) then
                'person'
            else
                'country'
    let $title :=
        if ($is-person-or-country-id eq 'person') then
            $matching-president/name/string()
        else
            gsh:territory-id-to-short-name($person-or-country-id)
    let $breadcrumb := <li><a href="$app/departmenthistory/travels/secretary/{$person-or-country-id}">{$title}</a></li>
    let $table := 
        if ($is-person-or-country-id eq 'person') then
            travels:by-person("president", $person-or-country-id)
        else
            travels:by-country("president", $person-or-country-id)
    return
        map {
            "title": $title,
            "breadcrumb": $breadcrumb,
            "table": $table
        }
};

declare function travels:breadcrumb($node as node(), $model as map(*)) {
    $model?breadcrumb
};

declare function travels:title($node as node(), $model as map(*)) {
    $model?title
};

declare function travels:table($node as node(), $model as map(*)) {
    $model?table
};

declare function travels:presidents($node as node(), $model as map(*)) {
    <ul>
        {
            let $presidents := collection($travels:PRESIDENTS_COL)//president
            for $president-id in distinct-values(collection($travels:PRESIDENT_TRAVELS_COL)//trip/@who)
            let $president := $presidents[id eq $president-id]
            let $president-name := $president/name
            let $start-year := year-from-date(xs:date($president/took-office-date))
            let $end-year := if ($president/left-office-date ne '') then year-from-date(xs:date($president/left-office-date)) else ()
            order by $start-year
            return
                <li><a href="$app/departmenthistory/travels/president/{$president-id}">{$president-name/string()}</a> ({$start-year}–{$end-year})</li>
        }
    </ul>
};

declare function travels:presidents-destinations($node as node(), $model as map(*)) {
    <ul>
        {
            for $country in distinct-values(collection($travels:PRESIDENT_TRAVELS_COL)//country)
            let $country-id := collection($travels:PRESIDENT_TRAVELS_COL)//country[. eq $country][1]/@id/string()
            order by $country
            return
                <li><a href="$app/departmenthistory/travels/president/{$country-id}">{$country}</a></li>
        }
    </ul>
};

declare function travels:secretaries($node as node(), $model as map(*)) {
    <ul>
        {
            let $secretaries-who-travelled := for $x in xmldb:get-child-resources($travels:SECRETARY_TRAVELS_COL) return replace($x, '.xml$', '')
            for $person-id in $secretaries-who-travelled
            let $name := pocom:person-name-first-last($node, $model, $person-id)
            let $secretary-role := doc($pocom:POSITIONS-PRINCIPALS-COL || '/secretary.xml')//principal[person-id eq $person-id][1]
            let $startyear := app:year-from-date($secretary-role/started/date)
            let $endyear :=
                if ($secretary-role/following-sibling::principal[@treatAsConsecutive]) then
                    app:year-from-date($secretary-role/following-sibling::principal[@treatAsConsecutive][last()]/ended/date)
                else
                    app:year-from-date($secretary-role/ended/date)
           let $years := concat($startyear, '–', $endyear)
           order by $secretary-role/started/date
           return
               <li><a href="$app/departmenthistory/travels/secretary/{$person-id}">{$name}</a> ({$years})</li>
        }
    </ul>
};

declare function travels:secretaries-destinations($node as node(), $model as map(*)) {
    <ul>
        {
            for $country in distinct-values(collection($travels:SECRETARY_TRAVELS_COL)//country)
            let $country-id := collection($travels:SECRETARY_TRAVELS_COL)//country[. eq $country][1]/@id/string()
            order by $country
            return
                <li><a href="$app/departmenthistory/travels/secretary/{$country-id}">{$country}</a></li>
        }
    </ul>
};

declare function travels:by-country($role as xs:string, $country-id as xs:string) as element(table) {
    let $collection := if ($role eq 'president') then $travels:PRESIDENT_TRAVELS_COL else $travels:SECRETARY_TRAVELS_COL
    let $trips :=
        for $trip in collection($collection)//trip[country/@id eq $country-id]
        order by $trip/start-date
        return $trip
    return
        travels:travels-to-table($trips, 'country')
};

declare function travels:by-person($role as xs:string, $person-id as xs:string) as element(table) {
    let $collection := if ($role eq 'president') then $travels:PRESIDENT_TRAVELS_COL else $travels:SECRETARY_TRAVELS_COL
    let $trips :=
        for $trip in collection($collection)//trip[@who eq $person-id]
        order by $trip/start-date
        return $trip
    return
        travels:travels-to-table($trips, 'name')
};

declare function travels:travels-to-table($results-to-display as node()*, $suppress as xs:string*) as element(table) {
    let $suppress-name := $suppress = "name"
    let $suppress-country := $suppress = "country"
    return
        <table class="hsg-table-default">
            <thead>
                <tr>
                    {if ($suppress-name) then () else <th>Name</th>}
                    {if ($suppress-country) then () else <th>Country</th>}
                    <th>Locale</th>
                    <th>Remarks</th>
                    <th>Date</th>
                </tr>
            </thead>
            <tbody>{
                for $item in $results-to-display
                return
                    <tr>
                        {if ($suppress-name) then () else <td>{if ($item/name) then $item/name/text() else pocom:person-name-by-id($item/@who)}</td>}
                        {if ($suppress-country) then () else <td>{$item/country/text()}</td>}
                        <td>{$item/locale/text()}</td>
                        <td>{$item/remarks/text()}</td>
                        <td>{
                            let $start := if ($item/start-date castable as xs:date) then xs:date($item/start-date/text()) else $item/start-date/text()
                            let $end := if ($item/end-date castable as xs:date) then xs:date($item/end-date/text()) else $item/end-date/text()
                            let $date :=
                                if (not($start castable as xs:date)) then
                                    'date error'
                                else if ($item/start-date eq $item/end-date) then
                                    format-date($start, '[MNn] [D], [Y0001]', 'en', (), 'US')
                                else if (empty($end)) then
                                    format-date($start, '[MNn] [D], [Y0001]', 'en', (), 'US')
                                else if (year-from-date($start) eq year-from-date($end) and month-from-date($start) eq month-from-date($end)) then
                                    concat(format-date($start, "[MNn] [D]", 'en', (), 'US'), '–', format-date($end, "[D], [Y0001]", 'en', (), 'US'))
                                else if (year-from-date($start) eq year-from-date($end)) then
                                    concat(format-date($start, "[MNn] [D]", 'en', (), 'US'), '–', format-date($end, '[MNn] [D], [Y0001]', 'en', (), 'US'))
                                else
                                    concat(format-date($start, '[MNn] [D], [Y0001]', 'en', (), 'US'), '–', format-date($end, '[MNn] [D], [Y0001]', 'en', (), 'US'))
                            return $date
                        }</td>
                    </tr>
            }</tbody>
        </table>
};
