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

(:
 :  WHEN calling link:email
 :  GIVEN an $email address (e.g. history@state.gov)
 :  GIVEN an $subject line as a string (e.g. 'Subject Line')
 :  GIVEN a $body as a string(e.g. 'Email body')
 :  THEN return the concatenated and URL encoded string (e.g. 'mailto:history@state.gov?subject=Subject%20line&body=Email%20body')
 :)