xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-app";

import module namespace app="http://history.state.gov/ns/site/hsg/templates" at "../app.xqm";
import module namespace config="http://history.state.gov/ns/site/hsg/config" at "config.xqm";
import module namespace t="http://history.state.gov/ns/site/hsg/xqsuite" at "../xqsuite.xqm";
import module namespace pages="http://history.state.gov/ns/site/hsg/pages" at "../pages.xqm";
import module namespace ut="http://history.state.gov/ns/site/hsg/app-util" at "../app-util.xqm";
import module namespace templates="http://exist-db.org/xquery/html-templating";

declare namespace test="http://exist-db.org/xquery/xqsuite";

(:
 :  WHEN calling app:format-date-month-short-day-year
 :  GIVEN a string that can't be cast to any sort of date (e.g. 'wibble')
 :  THEN throw an error
 :)
declare %test:assertError('app:format-date') function x:app-format-short-year-error() {
    app:format-date-month-short-day-year('wibble')
}; 

(:
 :  WHEN calling app:format-date-month-short-day-year
 :  GIVEN a datetime (e.g. xs:dateTime('2015-06-04T13:03:16-04:00'))
 :  THEN return the formatted date as a string (e.g. "Jun 4, 2015")
 :)

declare %test:assertEquals('Jun 04, 2015') function x:app-format-short-year-dateTime() {
    app:format-date-month-short-day-year(xs:dateTime('2015-06-04T13:03:16-04:00'))
};

(:
 :  WHEN calling app:format-date-month-short-day-year
 :  GIVEN a string that can be cast as a datetime (e.g. "2015-06-04T13:03:16-04:00")
 :  THEN return the formatted date as a string (e.g. "Jun 4, 2015")
 :)
declare %test:assertEquals('Jun 04, 2015') function x:app-format-short-year-dateTime-string() {
    app:format-date-month-short-day-year('2015-06-04T13:03:16-04:00')
};

(:
 :  WHEN calling app:format-date-month-short-day-year
 :  GIVEN a date (e.g. xs:date('2015-06-04'))
 :  THEN return the formatted date as a string (e.g. "Jun 04, 2015")
 :)
declare %test:assertEquals('Jun 04, 2015') function x:app-format-short-year-date() {
    app:format-date-month-short-day-year(xs:date('2015-06-04'))
};

(:
 :  WHEN calling app:format-date-month-short-day-year
 :  GIVEN a string that can be cast as a datetime (e.g. "2015-06-04")
 :  THEN return the formatted date as a string (e.g. "Jun 04, 2015")
 :)
declare %test:assertEquals('Jun 04, 2015') function x:app-format-short-year-date-string() {
    app:format-date-month-short-day-year('2015-06-04')
};

(:
 :  WHEN calling app:format-date-month-short-day-year
 :  GIVEN a Year/Month (e.g. xs:gYearMonth("2015-06"))
 :  THEN return the formatted date as a string (e.g. "Jun, 2015")
 :)

declare %test:assertEquals('Jun, 2015') function x:app-format-short-year-gYearMonth() {
    app:format-date-month-short-day-year(xs:gYearMonth("2015-06"))
};

(:
 :  WHEN calling app:format-date-month-short-day-year
 :  GIVEN a string that can be cast as a Year/Month (e.g. "2015-06")
 :  THEN return the formatted date as a string (e.g. "Jun, 2015")
 :)

declare %test:assertEquals('Jun, 2015') function x:app-format-short-year-gYearMonth-string() {
    app:format-date-month-short-day-year("2015-06")
};


(:
 :  WHEN calling app:format-date-month-short-day-year
 :  GIVEN a Year (e.g. xs:gYear("2015"))
 :  THEN return the formatted date as a string (e.g. "2015")
 :)

declare %test:assertEquals('2015') function x:app-format-short-year-gYear() {
    app:format-date-month-short-day-year(xs:gYear("2015"))
};

(:
 :  WHEN calling app:format-date-month-short-day-year
 :  GIVEN a string that can be cast as a year (e.g. "2015")
 :  THEN return the formatted date as a string (e.g. "2015")
 :)

declare %test:assertEquals('2015') function x:app-format-short-year-gYear-string() {
    app:format-date-month-short-day-year("2015")
};

(:
 :  WHEN calling app:format-date-month-long-day-year
 :  GIVEN a string that can't be cast to any sort of date (e.g. 'wibble')
 :  THEN throw an error
 :)
declare %test:assertError('app:format-date') function x:app-format-long-month-year-error() {
    app:format-date-month-long-day-year('wibble')
}; 

(:
 :  WHEN calling app:format-date-month-long-day-year
 :  GIVEN a datetime (e.g. xs:dateTime('2015-06-04T13:03:16-04:00'))
 :  THEN return the formatted date as a string (e.g. "June 4, 2015")
 :)

declare %test:assertEquals('June 4, 2015') function x:app-format-long-month-year-dateTime() {
    app:format-date-month-long-day-year(xs:dateTime('2015-06-04T13:03:16-04:00'))
};

(:
 :  WHEN calling app:format-date-month-long-day-year
 :  GIVEN a string that can be cast as a datetime (e.g. "2015-06-04T13:03:16-04:00")
 :  THEN return the formatted date as a string (e.g. "June 4, 2015")
 :)
declare %test:assertEquals('June 4, 2015') function x:app-format-long-month-year-dateTime-string() {
    app:format-date-month-long-day-year('2015-06-04T13:03:16-04:00')
};

(:
 :  WHEN calling app:format-date-month-long-day-year
 :  GIVEN a date (e.g. xs:date('2015-06-04'))
 :  THEN return the formatted date as a string (e.g. "June 4, 2015")
 :)
declare %test:assertEquals('June 4, 2015') function x:app-format-long-month-year-date() {
    app:format-date-month-long-day-year(xs:date('2015-06-04'))
};

(:
 :  WHEN calling app:format-date-month-long-day-year
 :  GIVEN a string that can be cast as a datetime (e.g. "2015-06-04")
 :  THEN return the formatted date as a string (e.g. "Jun 4, 2015")
 :)
declare %test:assertEquals('June 4, 2015') function x:app-format-long-month-year-date-string() {
    app:format-date-month-long-day-year('2015-06-04')
};

(:
 :  WHEN calling app:format-date-month-long-day-year
 :  GIVEN a Year/Month (e.g. xs:gYearMonth("2015-06"))
 :  THEN return the formatted date as a string (e.g. "June, 2015")
 :)

declare %test:assertEquals('June, 2015') function x:app-format-long-month-year-gYearMonth() {
    app:format-date-month-long-day-year(xs:gYearMonth("2015-06"))
};

(:
 :  WHEN calling app:format-date-month-long-day-year
 :  GIVEN a string that can be cast as a Year/Month (e.g. "2015-06")
 :  THEN return the formatted date as a string (e.g. "June, 2015")
 :)

declare %test:assertEquals('June, 2015') function x:app-format-long-month-year-gYearMonth-string() {
    app:format-date-month-long-day-year("2015-06")
};


(:
 :  WHEN calling app:format-date-month-long-day-year
 :  GIVEN a Year (e.g. xs:gYear("2015"))
 :  THEN return the formatted date as a string (e.g. "2015")
 :)

declare %test:assertEquals('2015') function x:app-format-long-month-year-gYear() {
    app:format-date-month-long-day-year(xs:gYear("2015"))
};

(:
 :  WHEN calling app:format-date-month-long-day-year
 :  GIVEN a string that can be cast as a year (e.g. "2015")
 :  THEN return the formatted date as a string (e.g. "2015")
 :)

declare %test:assertEquals('2015') function x:app-format-long-month-year-gYear-string() {
    app:format-date-month-long-day-year("2015")
};