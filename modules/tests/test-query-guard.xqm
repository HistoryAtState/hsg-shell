xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-query-guard";

import module namespace query-guard="http://history.state.gov/ns/site/hsg/query-guard" at "../query-guard.xqm";

declare namespace test="http://exist-db.org/xquery/xqsuite";

(: ---- valid queries: plain terms and every documented Lucene operator ---- :)

declare
    %test:assertFalse
function x:plain-word() {
    query-guard:has-invalid-characters("Washington")
};

declare
    %test:assertFalse
function x:phrase-with-space() {
    query-guard:has-invalid-characters("United Nations")
};

declare
    (: documented on the search tips page: phrases, booleans, wildcards, proximity, grouping :)
    %test:assertFalse
function x:documented-phrase-quotes() {
    query-guard:has-invalid-characters('"peaceful nuclear"')
};

declare
    %test:assertFalse
function x:documented-plus-minus() {
    query-guard:has-invalid-characters("+law -sea")
};

declare
    %test:assertFalse
function x:documented-grouping() {
    query-guard:has-invalid-characters('(Guatemala OR "El Salvador") AND Belize')
};

declare
    %test:assertFalse
function x:documented-wildcards() {
    query-guard:has-invalid-characters("te?t Vietna*")
};

declare
    %test:assertFalse
function x:documented-proximity() {
    query-guard:has-invalid-characters('"Cuba submarine"~10')
};

declare
    %test:assertFalse
function x:accented-characters() {
    query-guard:has-invalid-characters("café Málaga")
};

declare
    %test:assertFalse
function x:empty-sequence() {
    query-guard:has-invalid-characters(())
};

(: ---- invalid queries: percent-encoding, control chars, undocumented metachars ---- :)

declare
    %test:assertTrue
function x:percent-encoding() {
    query-guard:has-invalid-characters("te%20st")
};

declare
    %test:assertTrue
function x:bang() {
    query-guard:has-invalid-characters("Washington!")
};

declare
    %test:assertTrue
function x:colon-field-injection() {
    query-guard:has-invalid-characters("hsg-category:frus")
};

declare
    %test:assertTrue
function x:caret-boost() {
    query-guard:has-invalid-characters("term^2")
};

declare
    %test:assertTrue
function x:forward-slash-regex() {
    query-guard:has-invalid-characters("/regex/")
};

declare
    %test:assertTrue
function x:backslash() {
    query-guard:has-invalid-characters("a\b")
};

declare
    %test:assertTrue
function x:square-brackets-range() {
    query-guard:has-invalid-characters("[1946 TO 1947]")
};

declare
    %test:assertTrue
function x:curly-brackets-range() {
    query-guard:has-invalid-characters("{a TO b}")
};

declare
    %test:assertTrue
function x:control-character() {
    query-guard:has-invalid-characters("line1&#x0A;line2")
};

declare
    (: any single invalid value in a repeated q parameter fails the whole set :)
    %test:assertTrue
function x:one-of-many-invalid() {
    query-guard:has-invalid-characters(("valid", "in%20valid"))
};

(: ---- SQL-injection heuristic ---- :)

declare
    %test:assertTrue
function x:sqli-union-select() {
    query-guard:looks-like-sql-injection("gMxR' UNION ALL SELECT NULL,NULL,NULL-- -")
};

declare
    %test:assertTrue
function x:sqli-tautology() {
    query-guard:looks-like-sql-injection("1 OR 1=1")
};

declare
    %test:assertTrue
function x:sqli-stacked-statement() {
    query-guard:looks-like-sql-injection("x; DROP TABLE users")
};

declare
    %test:assertTrue
function x:sqli-time-based() {
    query-guard:looks-like-sql-injection("1) OR sleep(5)")
};

declare
    (: "Union" and "Select Committee" are legitimate history terms, but not adjacent as "union select" :)
    %test:assertFalse
function x:sqli-false-positive-soviet-union() {
    query-guard:looks-like-sql-injection("Soviet Union")
};

declare
    %test:assertFalse
function x:sqli-false-positive-select-committee() {
    query-guard:looks-like-sql-injection("Select Committee on Assassinations")
};

declare
    %test:assertFalse
function x:sqli-false-positive-hyphenated() {
    query-guard:looks-like-sql-injection("Berlin-Baghdad railway")
};

(: ---- check(): the single controller entry point ---- :)

declare
    %test:assertFalse
function x:check-valid-query() {
    query-guard:check('"peaceful nuclear" +treaty')
};

declare
    %test:assertTrue
function x:check-rejects-invalid-characters() {
    query-guard:check("hsg-category:frus")
};

declare
    %test:assertTrue
function x:check-rejects-sql-injection() {
    query-guard:check("gMxR' UNION ALL SELECT NULL,NULL-- -")
};
