xquery version "3.0";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

sm:chmod(xs:anyURI($target || "/modules/view.xql"), "rwsr-xr-x"),
sm:chmod(xs:anyURI($target || "/modules/frus-ajax.xql"), "rwsr-xr-x"),
sm:chmod(xs:anyURI($target || "/modules/fo.xql"), "rwsr-xr-x"),
sm:chmod(xs:anyURI($target || "/modules/lib/regenerate.xql"), "rwsr-xr-x"),
sm:chown(xs:anyURI($target || "/modules/rebuild-dates-sort-index.xql"), "admin"),
sm:chmod(xs:anyURI($target || "/modules/rebuild-dates-sort-index.xql"), "rwsr-xr-x"),
sm:chmod(xs:anyURI($target || "/tests/xquery/validate-results-of-twitter-jobs.xq"), "rwsr-xr-x"),
sm:chmod(xs:anyURI($target || "/tests/xquery/validate-replication.xq"), "rwsr-xr-x"),
util:eval(xs:anyURI($target || "/modules/lib/regenerate.xql"))
