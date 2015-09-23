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