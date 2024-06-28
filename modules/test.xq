xquery version "3.1";

(:
    A basic health check endpoint for monitoring services
:)

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";

map {
    "status": "ok",
    "time": current-dateTime()
}
