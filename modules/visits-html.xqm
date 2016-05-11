xquery version "3.0";

module namespace visits = "http://history.state.gov/ns/site/hsg/visits-html";

(:~
 : Visits by Foreign Leaders and Heads of State
 : relevant pages are in pages/departmenthistory/visits: index, etc.
 : draws on data in /db/apps/visits - installed via visits.xar
 :)

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";
import module namespace templates="http://exist-db.org/xquery/templates";

declare variable $visits:DATA_COL := '/db/apps/visits/data';

declare function visits:years($node, $model) {
    <ul>{
        let $years := 
            distinct-values(
                for $date in collection($visits:DATA_COL)//(start-date | end-date)
                let $year := year-from-date($date)
                return $year
                )
        for $year in $years
        order by $year
        return 
            <li><a href="$app/departmenthistory/visits/{$year}">{$year}</a></li>
    }</ul>
};

declare function visits:countries($node, $model) {
    <ul>{
        let $all-countries := collection($visits:DATA_COL)
        for $country in distinct-values($all-countries//from)
        let $country-id := ($all-countries//from[. eq $country])[1]/@id
        order by $country
        return
            <li><a href="$app/departmenthistory/visits/{$country-id}">{$country}</a> {if ($country-id ne '') then () else '*'}</li>
    }</ul>
};

declare function visits:is-country-or-year($country-or-year) {
    if (matches($country-or-year, '^\d{4}')) then 
        'year' 
    else 
        'country'
};

declare function visits:country-or-year-title($node, $model, $country-or-year as xs:string) {
    if (visits:is-country-or-year($country-or-year) = 'year') then
        'Visits By Foreign Leaders in ' || $country-or-year
    else
        'Visits By Foreign Leaders of ' || collection('/db/apps/gsh/data/countries-old')//country[id = $country-or-year]/label
};

declare function visits:country-or-year-page-title($node, $model, $country-or-year as xs:string) {
    if (visits:is-country-or-year($country-or-year) = 'year') then
        $country-or-year
    else
        collection('/db/apps/gsh/data/countries-old')//country[id = $country-or-year]/label
};


declare function visits:country-or-year-breadcrumb($node, $model, $country-or-year as xs:string) {
    <li><a href="$app/departmenthistory/visits/{$country-or-year}">{
        if (visits:is-country-or-year($country-or-year) = 'year') then
            $country-or-year
         else
            collection('/db/apps/gsh/data/countries-old')//country[id = $country-or-year]/label/text()
    }</a></li>
};

declare function visits:country-or-year-table($node, $model, $country-or-year as xs:string) {
    if (visits:is-country-or-year($country-or-year) = 'year') then
        visits:visits-in-year-table($node, $model, $country-or-year cast as xs:integer)
    else
        visits:visits-from-country-table($node, $model, $country-or-year)
};

declare function visits:visits-in-year-table($node, $model, $year as xs:integer) {
    let $visits := 
        for $visit in collection($visits:DATA_COL)//visit[year-from-date(start-date) eq $year]
        order by $visit/start-date
        return $visit
    return
        visits:visits-table($node, $model, $visits, ())
};

declare function visits:visits-from-country-table($node, $model, $country-id as xs:string) {
    let $visits := 
        for $visit in collection($visits:DATA_COL)//visit[from/@id eq $country-id]
        order by $visit/start-date
        return $visit
    return
        visits:visits-table($node, $model, $visits, 'from')
};

declare function visits:visits-table($node, $model, $results-to-display as node()*, $suppress as xs:string*) {
    <table class="hsg-table-default">
        <thead>
            <tr>
                <th>Visitor</th>
                {if ($suppress = 'from') then () else <th>From</th>}
                <th>Description</th>
                <th>Date</th>
            </tr>
        </thead>
        <tbody>{
            for $item in $results-to-display
            return
                <tr>
                    <td>{$item/visitor/string()}</td>
                    {if ($suppress = 'from') then () else <td>{$item/from/string()}</td>}
                    <td>{$item/description/string()}</td>
                    <td>{
                        let $start := if ($item/start-date castable as xs:date) then xs:date($item/start-date) else $item/start-date
                        let $end := if ($item/end-date castable as xs:date) then xs:date($item/end-date) else $item/end-date
                        let $date := 
                            if (not($start castable as xs:date)) then 
                                'date error'
                            else if ($item/start-date = $item/end-date) then
                                format-date($start, '[Mn] [D], [Y0001]', 'en', (), 'US')
                            else if (empty($end)) then 
                                format-date($start, '[Mn] [D], [Y0001]', 'en', (), 'US') 
                            else if (year-from-date($start) eq year-from-date($end) and month-from-date($start) eq month-from-date($end)) then 
                                concat(format-date($start, "[Mn] [D]", 'en', (), 'US'), '–', format-date($end, "[D], [Y0001]", 'en', (), 'US'))
                            else if (year-from-date($start) eq year-from-date($end)) then
                                concat(format-date($start, "[Mn] [D]", 'en', (), 'US'), '–', format-date($end, '[Mn] [D], [Y0001]', 'en', (), 'US'))
                            else 
                                concat(format-date($start, '[Mn] [D], [Y0001]', 'en', (), 'US'), '–', format-date($end, '[Mn] [D], [Y0001]', 'en', (), 'US'))
                        return $date
                    }</td>
                </tr> 
        }</tbody>
    </table>
};