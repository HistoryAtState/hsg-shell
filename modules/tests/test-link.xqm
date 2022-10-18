xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-link";

import module namespace link="http://history.state.gov/ns/site/hsg/link" at "../link.xqm";
import module namespace templates="http://exist-db.org/xquery/html-templating";

declare namespace test="http://exist-db.org/xquery/xqsuite";

declare boundary-space preserve;

(:
 :  WHEN calling link:report-issue()
 :  GIVEN a $node (e.g. <a data-template="link:report-issue">Report an issue on this page</a>)
 :  GIVEN a $model
 :  THEN return the element with an added @href populated by link:email($email, $subject, $body)
 :      WHERE $email is 'history@state.gov'
 :      WHERE $subject is 'Problem on page XXX'
 :      WHERE $body is the result of link:report-issue-body($node, $model)
 :)

declare %test:assertEquals("mailto:history@state.gov?subject=Error%20on%20page%20%60test-path%60&amp;body=%0D%0A_________________________________________________________%0D%0APlease%20provide%20any%20additional%20information%20above%20this%20line%0D%0A%0D%0ARequested%20URL%3A%0D%0A%09example.com%2Fthispage%0D%0A") function x:link-report-issue() {
    let $node := <a data-template="link:report-issue">Report an issue on this page</a>
    let $config := map{
        $templates:CONFIG_FN_RESOLVER : function($functionName as xs:string, $arity as xs:int) {
            try {
                function-lookup(xs:QName($functionName), $arity)
            } catch * {
                ()
            }
        },
        $templates:CONFIG_PARAM_RESOLVER : map{}
    }
    let $model := map {
        $templates:CONFIGURATION : $config,
        "url": "example.com/thispage",
        "local-uri":  "thispage"
    }
    return link:report-issue($node, $model)/@href/string(.)
};

(:
 :  WHEN calling link:report-issue-body()
 :  GIVEN a $node in the context of an error page (e.g. <a data-template="link:report-issue">Report an issue on this page</a>)
 :  GIVEN a $model containing the requested url (e.g. $model?url = 'example.com/thispage')
 :  THEN return the URI-encoded concatenation of strings (e.g. 'reply above this line', the requested URL, and the error message (can't really be reproduced by XQsuite)
 :)

declare 
    %test:assertEquals('%0D%0A_________________________________________________________%0D%0APlease%20provide%20any%20additional%20information%20above%20this%20line%0D%0A%0D%0ARequested%20URL%3A%0D%0A%09example.com%2Fthispage%0D%0A')
function x:link-report-issue-body(){
    let $html := doc('/db/apps/hsg-shell/tests/data/error-page.xml')
    let $node := $html/html/body[1]/footer[1]/section[3]/div[1]/div[1]/p[1]/a[1]
    let $config := map{
        $templates:CONFIG_FN_RESOLVER : function($functionName as xs:string, $arity as xs:int) {
            try {
                function-lookup(xs:QName($functionName), $arity)
            } catch * {
                ()
            }
        },
        $templates:CONFIG_PARAM_RESOLVER : map{}
    }
    let $model := map {
        $templates:CONFIGURATION : $config,
        "url": "example.com/thispage"
    }
    return link:report-issue-body($node, $model) => encode-for-uri()
};

(:
 :  WHEN calling link:email
 :  GIVEN an $email address (e.g. history@state.gov)
 :  GIVEN an $subject line as a string (e.g. 'Subject Line')
 :  GIVEN a $body as a string(e.g. 'Email body')
 :  THEN return the concatenated and URL encoded string (e.g. 'mailto:history@state.gov?subject=Subject%20line&body=Email%20body')
 :)

declare %test:assertEquals('mailto:history@state.gov?subject=Subject%20line&amp;body=Email%20body') function x:link-email() {
    let $email := 'history@state.gov'
    let $subject := 'Subject line'
    let $body := 'Email body'
    return link:email($email, $subject, $body)
};

(:
 :  WHEN calling link:email
 :  GIVEN an $email address (e.g. history@state.gov)
 :  GIVEN no $subject line
 :  GIVEN a $body as a string(e.g. 'Email body')
 :  THEN return the concatenated and URL encoded string (e.g. 'mailto:history@state.gov?body=Email%20body')
 :)

declare %test:assertEquals('mailto:history@state.gov?body=Email%20body') function x:link-email-no-subject() {
    let $email := 'history@state.gov'
    let $subject := ()
    let $body := 'Email body'
    return link:email($email, $subject, $body)
};

(:
 :  WHEN calling link:email
 :  GIVEN an $email address (e.g. history@state.gov)
 :  GIVEN an $subject line as a string (e.g. 'Subject Line')
 :  GIVEN no $body
 :  THEN return the concatenated and URL encoded string (e.g. 'mailto:history@state.gov?subject=Subject%20line')
 :)

declare %test:assertEquals('mailto:history@state.gov?subject=Subject%20line') function x:link-email-no-body() {
    let $email := 'history@state.gov'
    let $subject := 'Subject line'
    let $body := ()
    return link:email($email, $subject, $body)
};
