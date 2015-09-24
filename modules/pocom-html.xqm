xquery version "3.0";

module namespace pocom = "http://history.state.gov/ns/site/hsg/pocom-html";

(:~
 : "pocom" stands for Principal Officers and Chiefs of Mission
 : relevant pages are in pages/departmenthistory/people: index, principals-chiefs, secretaries, etc.
 : draws on data in /db/apps/pocom - installed via pocom.xar
 :)

import module namespace templates="http://exist-db.org/xquery/templates" ;

declare variable $pocom:DATA-COL := '/db/apps/pocom';
declare variable $pocom:PEOPLE-COL := $pocom:DATA-COL || '/people';
declare variable $pocom:POSITIONS-PRINCIPALS-COL := $pocom:DATA-COL || '/positions-principals';
declare variable $pocom:CODE-TABLES-COL := $pocom:DATA-COL || '/code-tables';

declare function pocom:year-from-date($date) {
    if ($date castable as xs:date) then 
        year-from-date($date)
    else if (matches($date, '^\d{4}-\d{2}$')) then
        replace($date, '^(\d{4})-\d{2}$', '$1')
    else ()
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
    let $rolename := $role/names/plural
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