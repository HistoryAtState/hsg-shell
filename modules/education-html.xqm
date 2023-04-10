xquery version "3.0";

module namespace edu = "http://history.state.gov/ns/site/hsg/education-html";

import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "pages.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $edu:EDUCATION_COL := '/db/apps/other-publications/education';
declare variable $edu:INTRODUCTIONS_COL := $edu:EDUCATION_COL || '/introductions';
declare variable $edu:MODULES_COL := $edu:EDUCATION_COL || '/modules';

declare function edu:modules-sidebar($node, $model) {
    <ul class="hsg-list-group">
        {
            let $ordered-modules :=
                for $module in collection($edu:MODULES_COL)//module[published-status eq 'published']
                return $module
            for $module in $ordered-modules
            let $tei-document-name := $module/tei-document-name/text()
            let $title := $module/title/text()
            return
                <li class="hsg-list-group-item"><a href="$app/education/modules/{$tei-document-name}">{$title}</a></li>
        }
    </ul>
};

declare function edu:list-modules-brief($node, $model) {
    <ol>
        {
            let $ordered-modules :=
                for $module in collection($edu:MODULES_COL)//module[published-status eq 'published']
                order by xs:integer($module/year-published) descending
                return $module
            for $module in $ordered-modules
            let $title := $module/title/text()
            let $year-published := $module/year-published/text()
            let $punctuation :=
                if ($module = $ordered-modules[position() eq last() - 1]) then
                    '; and'
                else if ($module = $ordered-modules[last()]) then
                    '.'
                else
                    ';'
            return
                <li><strong>{$title}</strong> ({$year-published}){$punctuation}</li>
        }
    </ol>
};

declare function edu:list-modules-full($node, $model) {
    for $module in collection($edu:MODULES_COL)//module[published-status eq 'published']
    let $year-published := $module/year-published/text()
    let $tei-document-name := $module/tei-document-name/text()
    let $tei-intro := doc(concat($edu:INTRODUCTIONS_COL, '/', $tei-document-name, '.xml'))
    let $title := $tei-intro//tei:title[@type='short']/text()
    let $text := $tei-intro//tei:body/tei:div[1]/tei:p[1]
    let $description := pages:process-content($model?odd, $text)
    let $availability-status := $module/availability-status
    let $availability-message :=
        <span class="availability-info">{
            if ($availability-status eq 'available') then
                <a href="http://videodirect.state.gov/">Available for mail order</a>
            else
                'Sorry, this title is out of print'
        }</span>
    order by $year-published descending
    return
        <div>
            <h3><a href="$app/education/modules/{$tei-document-name}">{$title}</a></h3>
            {$description}
            <p>Published in {$year-published}.  {$availability-message}.  The full introduction and curriculum materials are <a href="{concat('$app/education/modules/', $tei-document-name)}">available online</a>.</p>
            <hr />
        </div>
};

declare function edu:module-introduction($node, $model, $document-id as xs:string) {
    let $module := collection($edu:MODULES_COL)//module[tei-document-name eq $document-id]
    let $doc := doc(concat($edu:INTRODUCTIONS_COL, '/', $module/tei-document-name, '.xml'))
    let $longtitle := $doc//tei:title[@type='complete']
    let $text := $doc//tei:text/*
    let $intro-body := pages:process-content($model?odd, $text)
    let $file := $module//file
    let $file-name := $file/name/text()
    let $file-label := $file/label/text()
    let $availability-status := $module/availability-status
    let $availability-message :=
        <span class="availability-info">{
            if ($availability-status eq 'available') then
                <a href="http://videodirect.state.gov/">Available for mail order</a>
            else
                'This title is out of print'
        }</span>
    return
        <div>
            <h2>{$longtitle/string()}</h2><hr />
            <p>{$availability-message}. Download the <a href="{concat('$s3static/', 'edu-modules/', $file-name)}">{$file-label}</a>.</p>
            {$intro-body}
        </div>
};

(: Page title for education/module.html
TODO: Create a page title module :)
declare
    %templates:wrap
function edu:education-module-title ($node, $model) {
    concat(root($model?data)//tei:title[@type = 'short']/string(), ' - ', map:get($config:PUBLICATIONS, 'education-modules')?title)
};
