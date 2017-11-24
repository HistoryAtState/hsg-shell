xquery version "3.1";

module namespace fd="http://history.state.gov/ns/site/hsg/frus-dates";

import module namespace functx="http://www.functx.com";

declare variable $fd:app-base := "/exist/apps/frus-dates/";

declare function fd:normalize-low($date as xs:string, $timezone as xs:dayTimeDuration) {
    let $dateTime :=
        if ($date castable as xs:dateTime) then 
            adjust-dateTime-to-timezone(xs:dateTime($date), $timezone)
        else if ($date castable as xs:date) then
            let $adjusted-date := adjust-date-to-timezone(xs:date($date), $timezone)
            return
                substring($adjusted-date, 1, 10) || 'T00:00:00' || substring($adjusted-date, 11)
        else if (matches($date, '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$')) then
            adjust-dateTime-to-timezone(xs:dateTime($date || ':00'), $timezone)
        else if (matches($date, '^\d{4}-\d{2}$')) then
            adjust-dateTime-to-timezone(xs:dateTime($date || '-01T00:00:00'), $timezone)
        else (: if (matches($date, '^\d{4}$')) then :)
            adjust-dateTime-to-timezone(xs:dateTime($date || '-01-01T00:00:00'), $timezone)
    return
        $dateTime cast as xs:dateTime
};

declare function fd:normalize-high($date as xs:string, $timezone as xs:dayTimeDuration) as xs:dateTime {
    let $dateTime :=
        if ($date castable as xs:dateTime) then 
            adjust-dateTime-to-timezone(xs:dateTime($date), $timezone)
        else if ($date castable as xs:date) then
            let $adjusted-date := adjust-date-to-timezone(xs:date($date), $timezone)
            return
                substring($adjusted-date, 1, 10) || 'T23:59:59' || substring($adjusted-date, 11)
        else if (matches($date, '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$')) then
            adjust-dateTime-to-timezone(xs:dateTime($date || ':59'), $timezone)
        else if (matches($date, '^\d{4}-\d{2}$')) then
            adjust-dateTime-to-timezone(xs:dateTime($date || '-' || functx:days-in-month($date || '-01') || 'T23:59:59'), $timezone)
        else if (matches($date, '^\d{4}-\d{2}$')) then
            adjust-dateTime-to-timezone(xs:dateTime($date || '-' || functx:days-in-month($date || '-01') || 'T23:59:59'), $timezone)
        else (: if (matches($date, '^\d{4}$')) then :)
            adjust-dateTime-to-timezone(xs:dateTime($date || '-12-31T23:59:59'), $timezone)
    return
        $dateTime cast as xs:dateTime
};

declare function fd:wrap-html($content as element(), $title as xs:string+) {
    <html>
        <head>
            <meta charset="utf-8"/>
            <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
            <meta name="viewport" content="width=device-width, initial-scale=1"/>
            <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
            
            <title>{string-join(reverse($title), ' | ')}</title>
            
            <!-- Latest compiled and minified CSS -->
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous"/>

            <!-- Optional theme -->
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous"/>
            
            <!-- Latest compiled and minified JavaScript -->
            <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"/>
            <style type="text/css">
                table {{ page-break-inside: avoid }}
            </style>
            <style type="text/css" media="print">
                a, a:visited {{ text-decoration: underline; color: #428bca; }}
                a[href]:after {{ content: "" }}
            </style>
        </head>
        <body>
            <div class="container">
                <h3><a href="{$fd:app-base}">{$title[1]}</a></h3>
                {$content}
            </div>
        </body>
    </html>    
};