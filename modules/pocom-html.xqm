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

declare function pocom:date-to-english($date as xs:string) as xs:string {
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

declare 
    %templates:wrap
function pocom:person-name-first-last($node as node(), $model as map(*), $person-id) {
    let $person := collection($pocom:PEOPLE-COL)/person[id = $person-id]
    let $namebase := $person/persName
    return
        string-join(
            ($namebase/forename, $namebase/surname, $namebase/genName),
            ' '
        )
};

declare 
    %templates:wrap
function pocom:person-name-birth-death($node as node(), $model as map(*), $person-id) {
    let $person := collection($pocom:PEOPLE-COL)/person[id = $person-id]
    let $namebase := $person/persName
    let $dates := concat($person/birth, '–', $person/death)
    let $birth-death := 
        concat(
            if ($person/birth ne '') then $person/birth else '?', 
            '–', 
            if ($person/death/@type eq 'unknown' and $person/death eq '') then '?' else $person/death
            )
    return
        string-join(
            ($namebase/forename, $namebase/surname, $namebase/genName, '(' || $birth-death || ')'),
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
            let $name := pocom:person-name-first-last($node, $model, $person-id)
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
            let $name := pocom:person-name-first-last($node, $model, $person-id)
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
            pocom:chiefs-by-country-id($node, $model, $role-or-country-id)
};

declare function pocom:chiefs-by-country-id($node as node(), $model as map(*), $country-id as xs:string) {
    let $country := collection($pocom:OLD-COUNTRIES-COL)/country[id eq $country-id]
    let $country-name := $country/label/text()
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
                    let $name-birth-death := pocom:person-name-birth-death($node, $model, $chief-id)
                    let $startdate := 
                        (
                        $chief/started/date,
                        $chief/appointed/date
                        )[. ne ''][1]
                    let $start-date-english := if ($startdate) then pocom:date-to-english($startdate) else ()
                    let $end-date-english := if ($chief/ended/date) then pocom:date-to-english($chief/ended/date) else ()
                    let $position-label := $positions-collection/role[id eq $chief/role-title-id]/names/singular/string()
                    (: No more ordering! - we're relying on the document order of the country mission file :)
                    (:order by $startdate:)
                    let $current-territory-id := root($chief)/*/territory-id
                    let $contemporary-territory-id := $chief/contemporary-territory-id
                    let $is-on-todays-map := $current-territory-id eq $contemporary-territory-id
                    let $territory-name := if ($is-on-todays-map) then () else concat(', ', gsh:territory-id-to-short-name($contemporary-territory-id))
                    return
                        <li style="padding-bottom: .5em"><a href="{pocom:person-href($chief-id)}">{$name-birth-death}</a>
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
        <div>
            <h3 id="chiefs-of-mission">Chiefs of Mission</h3>
            {$chieflisting}
            <h3 id="other-nominees">Other Nominees</h3>
            {if ($other-nominees) then $other-nominee-listing else <p><em>None</em></p>}
        </div>
};

declare 
    %templates:wrap 
function pocom:person-entry($node as node(), $model as map(*), $person-id as xs:string) {
(:    if (doc-available(concat('/db/cms/apps/tei-content/data/secretary-bios/', $person-id, '.xml'))) then:)
(:        dept:show-biography() :)
(:    else:)
        let $person := collection($pocom:PEOPLE-COL)/person[id = $person-id]
        let $residence := 
            for $state-code in $person/residence/state-id[. ne '']
            let $state-name := doc($pocom:CODE-TABLES-COL || '/us-state-codes.xml')//item[value = $state-code]/label
            return $state-name
        let $career := (doc($pocom:CODE-TABLES-COL || '/career-appointee-codes.xml')//item[value = $person/career-type]/label/string(), '(Unknown career type)')[1]
        let $formatted-roles := pocom:format-roles($person)
        return
            <div>
                {
                    $career
                    ,
                    if (empty($residence)) then 
                        ()
                    else if (count($residence) gt 1) then 
                        (<br/>, concat('States of Residence: ', string-join($residence, ', ')) )
                    else 
                        (<br/>, concat('State of Residence: ', $residence) )
                    ,
                    <ol>{$formatted-roles}</ol>
                }
            </div>
};

declare function pocom:format-roles($person) {
    let $person-id := $person/id
    let $concurrent-appointments := collection($pocom:CONCURRENT-APPOINTMENTS-COL)/concurrent-appointments[person-id = $person-id]
    let $roles := collection($pocom:DATA-COL)//person-id[. = $person-id][not(parent::concurrent-appointments)]/..
    let $concurrent-groups :=
        for $group in $concurrent-appointments 
        let $concurrent-roles := $roles[id = $group/chief-id]
        return
            <group>{pocom:sort-roles($concurrent-roles) ! (: preserve all info needed to reconstruct position description with dept:format-role() :) element {root(.)/*/name()} {./preceding::territory-id, element {./name()} {./*, <note auto-generated="yes">{pocom:summarize-other-concurrent-appointments($group/id, ./id)}</note>}}}</group>
    let $non-concurrent := pocom:sort-roles($roles[not(id = $concurrent-appointments/chief-id)])
    let $full-listing := pocom:sort-roles(($concurrent-groups, $non-concurrent))
    for $item in $full-listing
    return
        if ($item/self::group) then 
            let $sorted-roles := 
                for $role in $item/*
                (: delicately construct a new root node containing all of the info needed to reconstruct position description with dept:format-role() :)
                let $role-node := element {$role/name()} {$role/*}
                return
                    pocom:format-role($person, $role-node/*[2])
            return
                <li>
                    <em>Concurrent Appointments</em>
                    <ol style="list-style-type: lower-alpha">{$sorted-roles}</ol>
                </li>
        else
            pocom:format-role($person, $item)
};

declare function pocom:sort-roles($roles) {
    (: why, oh why, does sorting not work without the namespace wildcard?! :)
    for $role in $roles
    let $sort-date := subsequence($role//*:date[. ne ''], 1, 1)
    order by $sort-date
    return 
        $role
};

declare function pocom:format-index($node as node(), $model as map(*), $people as element(person)+, $year as xs:integer?) {
    <ul>{
        for $person in $people
        let $person-id := $person/id
        let $url := concat('$app/departmenthistory/people/', $person-id)
        let $namebase := $person/persName
        let $name := concat($namebase/surname, ', ', $namebase/forename, if ($namebase/genName ne '') then concat(', ', $namebase/genName) else ())
        let $dates := concat(if ($person/birth ne '') then $person/birth else '?', '–', if ($person/death/@type eq 'unknown' and $person/death eq '') then '?' else $person/death)
        let $career-indicator := if ($person/career-type = ('fso', 'both')) then '*' else ()
        return
            <li style="padding: .5em 0">{$career-indicator}<a href="{$url}">{$name}</a> ({$dates})
                <ul>{
                    let $roles := collection($pocom:PEOPLE-COL)//person-id[. = $person-id][not(parent::concurrent-appointments)]/..
                    for $role in $roles
                    let $contemporary-territory-id := $role/contemporary-territory-id
                    let $title := concat(pocom:role-label($node, $model, $role/role-title-id, 'singular'), if ($contemporary-territory-id) then concat(', ', gsh:territory-id-to-short-name($contemporary-territory-id)) else ())
                    let $years := 
                        for $date in ($role/started/date, $role/ended/date)
                        return 
                            if ($date castable as xs:date) then 
                                year-from-date(xs:date($date)) 
                            else if (matches($date, '^\d{4}-\d{2}$')) then
                                xs:integer(substring($date, 1, 4))
                            else ()
                    let $years-summary := 
                        if (exists($years)) then 
                            let $start-year := min($years)
                            let $end-year := max($years)
                            return 
                                if ($start-year ne $end-year) then concat($start-year, '–', $end-year) else $start-year
                        else if ($role[not(.//date castable as xs:date)]/note) then
                            string-join($role[not(.//date castable as xs:date)]/note/text(), '; ')
                        else
                            'no date on record'
                    let $event-is-relevant := 
                        if (exists($dates)) then 
                            let $start-year := min($years)
                            let $end-year := max($years)
                            return
                                $year ge $start-year and $year le $end-year
                        else false()
                    order by $years[1]
                    return
                        <li>{if ($event-is-relevant) then attribute style { 'font-weight: bold' } else ()}{$title} ({$years-summary})</li>
                }</ul>
            </li>
    }</ul>
};

declare function pocom:join-with-and($words as xs:string+) as xs:string {
    let $count := count($words)
    return
        if ($count = 1) then 
            $words
        else if ($count = 2) then
            string-join($words, ' and ')
        else
            concat(
                string-join(subsequence($words, 1, $count - 1), ', '),
                ', and ',
                $words[last()]
            )
};
 
declare function pocom:summarize-concurrent-appointments($id as xs:string) {
    pocom:summarize-other-concurrent-appointments($id, ())
};
 
declare function pocom:summarize-other-concurrent-appointments($id as xs:string, $excluded-id as xs:string?) {
    let $doc := collection($pocom:CONCURRENT-APPOINTMENTS-COL)/concurrent-appointments[id = $id]
    let $appointments := collection($pocom:MISSIONS-COUNTRIES-COL)//chief[id = $doc/chief-id[not(. = $excluded-id)]]
    let $countries := pocom:join-with-and($appointments/contemporary-territory-id ! gsh:territory-id-to-short-name(.))
    let $resident-at := gsh:locale-id-to-short-name($doc/resident-at/locale-id)
    let $complete-summary := concat(if ($excluded-id) then 'Also accredited to ' else 'Accredited to ', $countries, '; resident at ', $resident-at, '.')
    return
        $complete-summary
};

declare function pocom:format-role($person, $role) {
    let $role-title-id := $role/role-title-id
    let $roleinfo := collection($pocom:DATA-COL)/*[id = $role-title-id]
    let $roletitle := $roleinfo/names/singular/text()
    let $rolesubtype := $roleinfo/category
    let $roleclass := root($role)/*/name()
    let $current-territory-id := root($role)/*/territory-id
    let $contemporary-territory-id := $role/contemporary-territory-id
    let $whereserved := if ($contemporary-territory-id) then (gsh:territory-id-to-short-name($contemporary-territory-id), (: fall back on original country ID in case it's different than GSH's country ID :) collection($pocom:OLD-COUNTRIES-COL)//id[. = $contemporary-territory-id]/label)[1] else ()
    let $persName := $person/persName
    let $name := concat($persName/forename, ' ', $persName/surname, if ($persName/genName) then concat(' ', $persName/genName) else ())
    let $birth-death := concat(if ($person/birth ne '') then $person/birth else '?', '–', if ($person/death/@type eq 'unknown' and $person/death eq '') then '?' else $person/death)
    let $appointed := $role/appointed
    let $started := $role/started
    let $ended := $role/ended
    let $startdate := 
        (
        $started/date,
        $appointed/date
        )[. ne ''][1]
    let $start-date-english := pocom:date-to-english($startdate)
    let $end-date-english := pocom:date-to-english($ended/date)
    let $dates := 
            if ($roleclass = 'principal-position') then
                (
                if ($appointed/date ne '') then (normalize-space(concat('Appointed: ', $appointed/note, ' ', pocom:date-to-english($appointed/date))), <br/>) else (),
                if ($started/date ne '') then (normalize-space(concat('Entry on Duty: ', $started/note, ' ', pocom:date-to-english($started/date))), <br/>) else (),
                if ($ended/date ne '') then normalize-space(concat('Termination of Appointment: ', $ended/note, ' ', pocom:date-to-english($ended/date) )) else ()
                )
            else (: if ($roleclass = ('country-mission', 'org-mission')) then :)
                (
                if ($appointed/date ne '') then (normalize-space(concat('Appointed: ', $appointed/note, ' ', pocom:date-to-english($appointed/date))), <br/>) else (),
                if ($started/date ne '') then (normalize-space(concat('Presentation of Credentials: ', $started/note, ' ', pocom:date-to-english($started/date))), <br/>) else (),
                if ($ended/date ne '') then normalize-space(concat('Termination of Mission: ', $ended/note, ' ', pocom:date-to-english($ended/date) )) else ()
                )
    let $role-id := $role/id
    let $notes := string-join($role/note, ' ')
        (:
        for $note in $role/note 
        return 
            if ($note/@auto-generated) then 
                <span style="background-color: #dddde8">{$note/string()}</span> 
            else 
                $note/string()
        :)
    order by $startdate
    return
        <li id="{$role-id}">
            <strong>{
                if ($roleclass eq 'country-mission') then 
                    <a href="{pocom:chief-country-href($current-territory-id)}">{concat($roletitle, ' (', $whereserved, ')')}</a>
                else if ($roleclass eq 'org-mission') then
                    <a href="{pocom:chief-role-href($role-title-id)}">{$roletitle}</a>
                else (: if ($roleclasss eq 'principal-position') then :)
                    <a href="{pocom:principal-role-href($role-title-id)}">{$roletitle}</a>
            }</strong>
            <br/>
            {
            $dates,
            if (normalize-space($notes) ne '') then 
                <ul><li><em>{$notes ! (., ' ')}</em></li></ul> 
            else ()
            }
        </li>
};

declare function pocom:people-list($node as node(), $model as map(*)) {
    let $surnames := collection($pocom:PEOPLE-COL)//surname
    let $letters := 
        for $letter in 
            distinct-values(
                for $x in $surnames/substring(., 1, 1) 
                return lower-case($x)
            )
        order by $letter 
        return $letter
    return
        <ul class="numbersnav">{
            for $letter in $letters
            return
                <li><a href="{concat('$app/departmenthistory/people/by-name/', $letter)}">{upper-case($letter)}</a></li>
        }</ul>
};

declare function pocom:people-list-by-letter($node as node(), $model as map(*), $letter as xs:string) {
    let $chiefs := 
        for $chief in collection(concat($pocom:PEOPLE-COL, '/', $letter))/person 
        order by $chief/id 
        return $chief
    return
        pocom:format-index($node, $model, $chiefs, ())
};

declare function pocom:upper-case-letter($node as node(), $model as map(*), $letter as xs:string) {
    upper-case($letter)
};

declare function pocom:people-list-prev-next-letter($node as node(), $model as map(*), $letter as xs:string) {
    let $surnames := collection($pocom:PEOPLE-COL)//surname
    let $letters := for $letter in distinct-values(for $x in $surnames/substring(., 1, 1) return lower-case($x)) order by $letter return $letter
    let $prev := if ($letter gt $letters[1]) then $letters[index-of($letters, $letter) - 1] else ()
    let $next := if ($letter lt $letters[last()]) then $letters[index-of($letters, $letter) + 1] else ()
    let $prevlink := 
        if ($prev) then 
            <li class="left"><a href="{concat('$app/departmenthistory/people/by-name/', $prev)}">« {upper-case($prev)}</a></li>
        else ()
    let $nextlink := 
        if ($next) then
            <li class="right"><a href="{concat('$app/departmenthistory/people/by-name/', $next)}">{upper-case($next)} »</a></li>
        else ()
    return 
        (
        <div id="contentnav">
            <ul>
                {$prevlink, $nextlink}
            </ul> 
        </div>,
        <!-- close contentnav -->
        )
};
