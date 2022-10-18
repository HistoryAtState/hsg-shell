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

declare %test:assertEquals("mailto:history@state.gov?subject=Error%20on%20page%20%60thispage%60&amp;body=%0A____________________________%0APlease%20Reply%20above%20this%20Line%0A%0ARequested%20URL%3A%0A%20%20%20%20example.com%2Fthispage%0A") function x:link-report-issue() {
    let $node := <a data-template="link:report-issue">Report an issue on this page</a>
    let $model := map{
        "url": "example.com/thispage",
        "local-uri":  "thispage"
    }
    return link:report-issue($node, $model)/@href/string(.)
};

(:
 :  WHEN calling link:report-issue-body()
 :  GIVEN a $node in the context of an error page (e.g. <a data-template="link:report-issue">Report an issue on this page</a>)
 :  GIVEN a $model containing the requested url (e.g. $model?url = 'example.com/thispage')
 :  THEN return the URI-encoded concatenation of strings (e.g. 'reply above this line', the requested URL, and the error message)
 :)

declare 
    %test:assertEquals('%0A____________________________%0APlease%20Reply%20above%20this%20Line%0A%0ARequested%20URL%3A%0A%20%20%20%20example.com%2Fthispage%0A%0AError%20Description%3A%0Atemplates%3ANotFound%20No%20template%20function%20found%20for%20call%20app%3Atweet-xhtml%20%28Max%20arity%20of%2020%20has%20been%20exceeded%20in%20searching%20for%20this%20template%20function.%20If%20needed%2C%20adjust%20%24templates%3AMAX_ARITY%20in%20the%20templates.xql%20module.%29%20%5Bat%20line%20190%2C%20column%2085%2C%20source%3A%20%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0AIn%20function%3A%0A%09templates%3Acall%28item%28%29%2C%20element%28%29%2C%20map%28%2A%29%29%20%5B136%3A36%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess%28node%28%29%2A%2C%20map%28%2A%29%29%20%5B147%3A81%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess%28node%28%29%2A%2C%20map%28%2A%29%29%20%5B434%3A23%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09app%3Aeach%28node%28%29%2C%20map%28%2A%29%2C%20xs%3Astring%2C%20xs%3Astring%29%20%5B-1%3A-1%3A%2Fdb%2Fapps%2Fhsg-shell%2Fmodules%2Fapp.xqm%5D%0A%09templates%3Aprocess-output%28element%28%29%2C%20map%28%2A%29%2C%20item%28%29%2A%2C%20element%28function%29%29%20%5B210%3A9%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Acall-by-introspection%28element%28%29%2C%20map%28%2A%29%2C%20map%28%2A%29%2C%20function%28%2A%29%29%20%5B188%3A28%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Acall%28item%28%29%2C%20element%28%29%2C%20map%28%2A%29%29%20%5B136%3A36%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess%28node%28%29%2A%2C%20map%28%2A%29%29%20%5B356%3A18%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09app%3Aload-most-recent-tweets%28node%28%29%2C%20map%28%2A%29%2C%20xs%3Ainteger%29%20%5B-1%3A-1%3A%2Fdb%2Fapps%2Fhsg-shell%2Fmodules%2Fapp.xqm%5D%0A%09templates%3Aprocess-output%28element%28%29%2C%20map%28%2A%29%2C%20item%28%29%2A%2C%20element%28function%29%29%20%5B210%3A9%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Acall-by-introspection%28element%28%29%2C%20map%28%2A%29%2C%20map%28%2A%29%2C%20function%28%2A%29%29%20%5B188%3A28%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Acall%28item%28%29%2C%20element%28%29%2C%20map%28%2A%29%29%20%5B136%3A36%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess%28node%28%29%2A%2C%20map%28%2A%29%29%20%5B147%3A81%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess%28node%28%29%2A%2C%20map%28%2A%29%29%20%5B147%3A81%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess%28node%28%29%2A%2C%20map%28%2A%29%29%20%5B147%3A81%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess%28node%28%29%2A%2C%20map%28%2A%29%29%20%5B147%3A81%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess%28node%28%29%2A%2C%20map%28%2A%29%29%20%5B147%3A81%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess%28node%28%29%2A%2C%20map%28%2A%29%29%20%5B147%3A81%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess%28node%28%29%2A%2C%20map%28%2A%29%29%20%5B147%3A81%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess%28node%28%29%2A%2C%20map%28%2A%29%29%20%5B147%3A81%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess%28node%28%29%2A%2C%20map%28%2A%29%29%20%5B575%3A36%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09pages%3Aapp-root%28node%28%29%2C%20map%28%2A%29%29%20%5B-1%3A-1%3A%2Fdb%2Fapps%2Fhsg-shell%2Fmodules%2Fpages.xqm%5D%0A%09templates%3Aprocess-output%28element%28%29%2C%20map%28%2A%29%2C%20item%28%29%2A%2C%20element%28function%29%29%20%5B210%3A9%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Acall-by-introspection%28element%28%29%2C%20map%28%2A%29%2C%20map%28%2A%29%2C%20function%28%2A%29%29%20%5B188%3A28%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Acall%28item%28%29%2C%20element%28%29%2C%20map%28%2A%29%29%20%5B136%3A36%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess%28node%28%29%2A%2C%20map%28%2A%29%29%20%5B430%3A17%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess-output%28element%28%29%2C%20map%28%2A%29%2C%20item%28%29%2A%29%20%5B229%3A9%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess-output%28element%28%29%2C%20map%28%2A%29%2C%20item%28%29%2A%2C%20element%28function%29%29%20%5B210%3A9%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Acall-by-introspection%28element%28%29%2C%20map%28%2A%29%2C%20map%28%2A%29%2C%20function%28%2A%29%29%20%5B188%3A28%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Acall%28item%28%29%2C%20element%28%29%2C%20map%28%2A%29%29%20%5B136%3A36%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess%28node%28%29%2A%2C%20map%28%2A%29%29%20%5B132%3A51%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aprocess%28node%28%29%2A%2C%20map%28%2A%29%29%20%5B89%3A9%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D%0A%09templates%3Aapply%28node%28%29%2B%2C%20function%28%2A%29%2C%20map%28%2A%29%3F%2C%20map%28%2A%29%3F%29%20%5B64%3A9%3A%2Fexist%2Fetc%2F..%2Fdata%2Fexpathrepo%2Ftemplating-1.0.4%2Fcontent%2Ftemplates.xqm%5D')
function x:link-report-issue-body(){
    let $html := doc('/db/apps/hsg-shell/tests/data/error-page.xml')
    let $node := $html/html/body[1]/footer[1]/section[3]/div[1]/div[1]/p[1]/a[1]
    let $model := map{
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