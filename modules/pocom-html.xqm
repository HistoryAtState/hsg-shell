xquery version "3.0";

module namespace pocom = "http://history.state.gov/ns/site/hsg/pocom-html";

(:~
 : "pocom" stands for Principal Officers and Chiefs of Mission
 : relevant pages are in pages/departmenthistory/people: index, principals-chiefs, secretaries, etc.
 : draws on data in /db/apps/pocom - installed via pocom.xar
 :)

import module namespace gsh="http://history.state.gov/ns/xquery/geospatialhistory" at "/db/apps/gsh/modules/gsh.xqm";
import module namespace templates="http://exist-db.org/xquery/templates";

declare variable $pocom:DATA-COL := '/db/apps/pocom';
declare variable $pocom:CODE-TABLES-COL := $pocom:DATA-COL || '/code-tables';
declare variable $pocom:CONCURRENT-APPOINTMENTS-COL := $pocom:DATA-COL || '/concurrent-appointments';
declare variable $pocom:MISSIONS-COUNTRIES-COL := $pocom:DATA-COL || '/missions-countries';
declare variable $pocom:MISSIONS-ORGS-COL := $pocom:DATA-COL || '/missions-orgs';
declare variable $pocom:PEOPLE-COL := $pocom:DATA-COL || '/people';
declare variable $pocom:POSITIONS-PRINCIPALS-COL := $pocom:DATA-COL || '/positions-principals';
declare variable $pocom:ROLES-COUNTRY-CHIEFS-COL := $pocom:DATA-COL || '/roles-country-chiefs';
declare variable $pocom:OLD-COUNTRIES-COL := '/db/apps/gsh/data/countries-old';

declare function pocom:year-from-date($date) {
    if ($date castable as xs:date) then 
        year-from-date($date)
    else if (matches($date, '^\d{4}-\d{2}$')) then
        replace($date, '^(\d{4})-\d{2}$', '$1')
    else ()
};

declare function pocom:date-to-english($date) as xs:string {
    let $english-months := ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')
    return
        if ($date castable as xs:date) then 
            let $month-num := month-from-date($date)
            let $month := $english-months[$month-num]
            let $year := year-from-date($date)
            let $day := day-from-date($date)
            return 
                concat($month, ' ', $day, ', ', $year)
        else if (matches($date, '^\d{4}-\d{2}$')) then
            let $year := substring($date, 1, 4)
            let $month-num := xs:integer(substring($date, 6, 2))
            let $month := $english-months[$month-num]
            return 
                concat($month, ' ', $year)
        else 
            $date
};

declare function pocom:person($person-id) {
    collection($pocom:PEOPLE-COL)/person[id = $person-id]
};

declare function pocom:person-name-first-last($person-id) {
    let $person := collection($pocom:PEOPLE-COL)/person[id = $person-id]
    let $namebase := $person/persName
    return
        string-join(
            ($namebase/forename, $namebase/surname, $namebase/genName),
            ' '
        )
};

declare function pocom:person-href($person-id) {
    '$app/departmenthistory/people/' || $person-id
};

declare function pocom:secretaries($node as node(), $model as map(*)) {
    <ol>
        {
            for $secretary in doc($pocom:POSITIONS-PRINCIPALS-COL || '/secretary.xml')//principal[not(@treatAsConsecutive)]
            let $person-id := $secretary/person-id
            let $name := pocom:person-name-first-last($person-id)
            let $startyear := pocom:year-from-date($secretary/started/date)
            let $endyear := 
                if ($secretary/following-sibling::principal[1][@treatAsConsecutive]) then
                    pocom:year-from-date($secretary/following-sibling::principal[1][@treatAsConsecutive]/ended/date)
                else 
                    pocom:year-from-date($secretary/ended/date)
            let $years := concat($startyear, '–', $endyear)
            return
                <li><a href="{pocom:person-href($person-id)}">{$name}</a> ({$years})</li>
        }
    </ol>
};

declare function pocom:principal-role-href($role-id) {
    '$app/departmenthistory/people/principalofficers/' || $role-id
};

declare function pocom:principal-officers($node as node(), $model as map(*)) {
    <ul>
        {
            for $rolecategory in doc($pocom:CODE-TABLES-COL || '/role-category-codes.xml')//item[not(value = ('', 'country', 'international-organization'))]
            return
                <li>
                    {$rolecategory/label/string()}
                    <ul>
                        {
                            for $roles in collection($pocom:POSITIONS-PRINCIPALS-COL)/principal-position[category eq $rolecategory/value]
                            let $roleid := $roles/id
                            let $rolename := $roles/names/plural
                            order by $rolename
                            return
                                <li><a href="{pocom:principal-role-href($roleid)}">{$rolename/string()}</a></li>
                        }
                    </ul>
                </li>
        }
    </ul>
};

declare function pocom:principal-officers-by-role-id($node as node(), $model as map(*), $role-id as xs:string) {
    let $role := collection($pocom:DATA-COL)//id[. = $role-id]/..
    let $principalslisting :=
        <ul>
            {
            for $principal in ($role//principal, $role//chief)
            let $person-id := $principal/person-id
            let $name := pocom:person-name-first-last($person-id)
            let $startdate := 
                (
                $principal/started/date,
                $principal/appointed/date
                )[. ne ''][1]
            let $startyear := pocom:year-from-date($startdate)
            let $endyear := pocom:year-from-date($principal/ended/date)
            let $years := if ($startyear = $endyear) then $startyear else concat($startyear, '–', $endyear)
            let $note := $principal/note/text() 
                (: If we want to show the note in this list add this before the </li>:
                 :     {if ($note) then (<ul><li><em>{$note}</em></li></ul>) else ''}
                 :)
            return
                <li><a href="{pocom:person-href($person-id)}">{$name}</a> ({$years})</li>
            }
        </ul>
    let $description := $role/description
    return
        (
            if ($description) then <div style="font-style: italic">{$description/node()}</div> else ()
            ,
            $principalslisting
        )
};

declare 
    %templates:wrap 
function pocom:role-label($node as node(), $model as map(*), $role-id as xs:string, $form as xs:string) {
    let $role := collection($pocom:DATA-COL)//id[. = $role-id]/..
    return
        if ($form = 'plural') then
            $role/names/plural/string()
        else
            $role/names/singular/string()
};

declare 
    %templates:wrap 
function pocom:role-or-country-label($node as node(), $model as map(*), $role-or-country-id as xs:string, $form as xs:string) {
    let $role := collection($pocom:DATA-COL)//id[. = $role-or-country-id]/..
    let $country := collection($pocom:OLD-COUNTRIES-COL)//id[. = $role-or-country-id]/..
    return
        if ($role) then
            if ($form = 'plural') then
                $role/names/plural/string()
            else
                $role/names/singular/string()
        else
            concat('Chiefs of Mission for ', $country/label/string())
};

declare function pocom:chief-role-href($role-id) {
    '$app/departmenthistory/people/chiefsofmission/' || $role-id
};

declare function pocom:chief-country-href($country-id) {
    '$app/departmenthistory/people/chiefsofmission/' || $country-id
};

declare function pocom:international-organizations-list($node as node(), $model as map(*)) {
    <ul>
        {
        for $roles in collection($pocom:DATA-COL || '/missions-orgs')/org-mission
        let $role-id := $roles/id/string()
        let $role-label := $roles/names/plural/string()
        order by $role-label
        return
            <li><a href="{pocom:chief-role-href($role-id)}">{$role-label}</a></li>
        }
    </ul>
};

declare function pocom:chiefs-countries-list($node as node(), $model as map(*)) {
    let $countries := collection($pocom:OLD-COUNTRIES-COL)//country[not(iso2 = ("aw", "bm", "bt", "ky", "xa", "cw", "hk", "kp", "kr", "xj", "qr", "tw", "xd", "us"))] (: suppress dependencies and usa :)
    let $letters := for $letter in distinct-values($countries/substring(label, 1, 1)) order by $letter return $letter
    let $count := count($letters)
    let $first-half := $letters[position() = (1 to xs:integer($count div 2))]
    let $second-half := $letters[position() = ((xs:integer($count div 2) to $count))]
    return
        <div class="row">
            {
                for $group in (1, 2) (: feels kludgy, but better than old version; TODO: replace with group-by? :)
                return
                    <div class="col-md-6">
                        {
                            let $letter-group := if ($group = 1) then $first-half else $second-half
                            for $letter in $letter-group
                            order by lower-case($letter)
                            return
                                <div>
                                    <h3>{$letter}</h3>
                                    <ul>{
                                        for $country in $countries[starts-with(label, $letter)]
                                        let $country-id := $country/id/text()
                                        let $country-name := $country/label/text()
                                        order by $country-name
                                        return
                                           <li> 
                                               <a href="{pocom:chief-country-href($country-id)}">{$country-name}</a>
                                           </li>
                                    }</ul>
                                </div>
                        }
                    </div>
            }
        </div>
};

declare function pocom:chiefs-by-role-or-country-id($node as node(), $model as map(*), $role-or-country-id as xs:string) {
    let $role := collection($pocom:DATA-COL)//id[. = $role-or-country-id]/..
    let $country := collection($pocom:OLD-COUNTRIES-COL)//id[. = $role-or-country-id]/..
    return
        if ($role) then
            pocom:principal-officers-by-role-id($node, $model, $role-or-country-id)
        else
            pocom:chiefs-by-country-id($role-or-country-id)
};

declare function pocom:chiefs-by-country-id($country-id) {
    let $country := collection($pocom:OLD-COUNTRIES-COL)/country[id eq $country-id]
    let $country-name := $country/label/text()
    let $country-iso2 := $country/iso2/text()
    let $country-mission := collection($pocom:MISSIONS-COUNTRIES-COL)/country-mission[territory-id eq $country-id]
    let $chiefs-entries := $country-mission/chiefs/*
    let $other-nominees := $country-mission/other-nominees/chief
    let $people-collection := collection($pocom:PEOPLE-COL)
    let $positions-collection := collection($pocom:ROLES-COUNTRY-CHIEFS-COL)
    let $chieflisting :=
        <ul>
            {
            for $chief-entry in $chiefs-entries
            return
                if ($chief-entry/self::chief) then
                    let $chief := $chief-entry
                    let $chief-id := $chief/person-id
                    let $person := $people-collection/person[id = $chief-id]
                    let $persName := $person/persName
                    let $name := concat($persName/forename, ' ', $persName/surname, if ($persName/genName) then concat(' ', $persName/genName) else ())
                    let $birth-death := concat(if ($person/birth ne '') then $person/birth else '?', '–', if ($person/death/@type eq 'unknown' and $person/death eq '') then '?' else $person/death)
                    let $startdate := 
                        (
                        $chief/started/date,
                        $chief/appointed/date
                        )[. ne ''][1]
                    let $start-date-english := pocom:date-to-english($startdate)
                    let $end-date-english := pocom:date-to-english($chief/ended/date)
                    let $position-label := $positions-collection/role[id eq $chief/role-title-id]/names/singular/string()
                    (: No more ordering! - we're relying on the document order of the country mission file :)
                    (:order by $startdate:)
                    let $current-territory-id := root($chief)/*/territory-id
                    let $contemporary-territory-id := $chief/contemporary-territory-id
                    let $is-on-todays-map := $current-territory-id eq $contemporary-territory-id
                    let $territory-name := if ($is-on-todays-map) then () else concat(', ', gsh:territory-id-to-short-name($contemporary-territory-id))
                    return
                        <li style="padding-bottom: .5em"><a href="{pocom:person-href($chief-id)}">{data($name)} ({$birth-death})</a>
                            <ul><li>{$position-label} {$territory-name}, {if ($start-date-english = $end-date-english) then $start-date-english else concat($start-date-english, '–', $end-date-english)}</li></ul>
                        </li>
            else (: if ($chief-entry/self::mission-note) then :)
                <li style="background-color: #dddde8; margin-bottom: .5em; padding: .75em 0 .75em 1.5em;">{$chief-entry/text/string()}</li>
            }
        </ul>
    let $other-nominee-listing :=
        <ul>
            {
            for $chief in $other-nominees
            let $chief-id := $chief/person-id
            let $person := $people-collection/person[id = $chief-id]
            let $persName := $person/persName
            let $name := concat($persName/forename, ' ', $persName/surname, if ($persName/genName) then concat(' ', $persName/genName) else ())
            let $birth-death := concat(if ($person/birth ne '') then $person/birth else '?', '–', if ($person/death/@type eq 'unknown' and $person/death eq '') then '?' else $person/death)
            let $note := $chief/note
            let $position-label := $positions-collection/role[id eq $chief/role-title-id]/names/singular/string()
            return
                <li style="padding-bottom: .5em"><a href="{pocom:person-href($chief-id)}">{data($name)} ({$birth-death})</a>
                    <ul><li>{concat($position-label, if ($note) then concat(': ', $note) else ())}</li></ul>
                </li>
            }
        </ul>
    return
        <div class="content">
            <h3 id="chiefs-of-mission">Chiefs of Mission</h3>
            {$chieflisting}
            <h3 id="other-nominees">Other Nominees</h3>
            {if ($other-nominees) then $other-nominee-listing else <p><em>None</em></p>}
        </div>
};