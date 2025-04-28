xquery version "3.1";

module namespace visits = "http://history.state.gov/ns/site/hsg/visits-html";

(:~
 : Visits by Foreign Leaders and Heads of State
 : relevant pages are in pages/departmenthistory/visits: index, etc.
 : draws on data in /db/apps/visits - installed via visits.xar
 :)

import module namespace templates="http://exist-db.org/xquery/html-templating";

declare variable $visits:DATA_COL := '/db/apps/visits/data';

declare function visits:load($node, $model, $country-or-year as xs:string) {
    let $is-year := matches($country-or-year, '^\d{4}')
    let $visits := 
        if ($is-year) then
            collection($visits:DATA_COL)//visit[year-from-date(start-date) eq xs:integer($country-or-year)]
        else
            collection($visits:DATA_COL)//visit[from/@id eq $country-or-year]
    let $sorted-visits := 
        for $visit in $visits
        order by $visit/start-date
        return $visit
    return
        if ($is-year) then
            let $page-title := $country-or-year
            let $title := 'Visits By Foreign Leaders in ' || $country-or-year
            let $table := visits:visits-table($sorted-visits, ())
            return
                map {
                    "page-title": $page-title,
                    "title": $title,
                    "table": $table
                }
        else
            let $page-title := $sorted-visits[last()]/from/string()
            let $title := 'Visits By Foreign Leaders of ' || $page-title
            let $table := visits:visits-table($sorted-visits, "from")
            return
                map {
                    "page-title": $page-title,
                    "title": $title,
                    "table": $table
                }
};

declare function visits:page-title($node, $model) {
    $model?page-title
};

declare function visits:title($node, $model) {
    $model?title
};

declare function visits:breadcrumb($node, $model) {
    $model?breadcrumb
};

declare function visits:table($node, $model) {
    $model?table
};

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

declare function visits:visits-table($results-to-display as node()*, $suppress as xs:string*) {
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
                    <td>{$item/description/node()}</td>
                    <td>{
                        let $start := if ($item/start-date castable as xs:date) then xs:date($item/start-date) else $item/start-date
                        let $end := if ($item/end-date castable as xs:date) then xs:date($item/end-date) else $item/end-date
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
