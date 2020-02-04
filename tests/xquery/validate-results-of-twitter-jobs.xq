xquery version "3.1";

import module namespace functx = "http://www.functx.com";

(:~
 : Validate scheduled Twitter posts
 : Retrieve scheduler data and filter for results from script "download-recent-twitter-posts.xq"
 : Compare if twitter posts have been downloaded within the given "expression" time limit
 :
 : @return HTML with validated output
 :)
declare function local:get-results() {
    let $xml := scheduler:get-scheduled-jobs()
    let $report := $xml//scheduler:job[@name="XQuery: /db/apps/twitter/jobs/download-recent-twitter-posts.xq"]/scheduler:trigger

    let $expression-raw := data($report/expression)
    let $expression := $expression-raw div 1000
    let $state-raw := data($report/state)
    let $start-raw := data($report/start)
    let $previous-raw := data($report/previous)
    let $next-raw := data($report/next)
    let $current-date-raw := current-dateTime()

    let $state :=
        if ($state-raw eq "NORMAL")
        then "valid"
        else "invalid"

    let $previous :=
        let $duration := (xs:dateTime($current-date-raw)) - (xs:dateTime($previous-raw))
        let $total-duration-in-seconds1 := $duration div xs:dayTimeDuration("PT1S")

        return
            (
                $total-duration-in-seconds1,
                if ($total-duration-in-seconds1 <= $expression)
                then "valid"
                else "invalid"
            )

    let $next :=
        let $duration := (xs:dateTime($current-date-raw)) - (xs:dateTime($next-raw))
        let $total-duration-in-seconds2 := $duration div xs:dayTimeDuration("PT1S")

        return
            (
                $total-duration-in-seconds2,
                if ($total-duration-in-seconds2 <= $expression)
                then "valid"
                else "invalid"
            )

    return (
        <div>
            <h4>Twitter Job Results</h4>
            <ul>
                <li id="state" value="{ $state-raw }">{ $state }</li>
                <li id="previous" value="{ $previous[1] }">{ $previous[2] }</li>
                <li id="next" value="{ $next[1] }">{ $next[2] }</li>
            </ul>
        </div>
    )
};

local:get-results()
