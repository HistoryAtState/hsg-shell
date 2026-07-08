xquery version "3.1";

module namespace x="http://history.state.gov/ns/site/hsg/tests/test-query-guard";

import module namespace query-guard="http://history.state.gov/ns/site/hsg/query-guard" at "../query-guard.xqm";

declare namespace test="http://exist-db.org/xquery/xqsuite";

(: ---- SQL-injection probes: must be flagged ---- :)

declare
    %test:assertTrue
function x:sqli-union-all-select() {
    query-guard:looks-like-sql-injection("gMxR' UNION ALL SELECT NULL,NULL,NULL-- -")
};

declare
    %test:assertTrue
function x:sqli-union-select-columns() {
    query-guard:looks-like-sql-injection("' union select 1,2,3 from users")
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
function x:sqli-time-based-sleep() {
    query-guard:looks-like-sql-injection("1) OR sleep(5)")
};

declare
    %test:assertTrue
function x:sqli-time-based-waitfor() {
    query-guard:looks-like-sql-injection("1; waitfor delay '0:0:5'")
};

declare
    (: the tell-tale UNION column-count padding, even without a nearby "select" :)
    %test:assertTrue
function x:sqli-null-column-list() {
    query-guard:looks-like-sql-injection("foo NULL,NULL,NULL bar")
};

(: ---- legitimate history queries: must NOT be flagged ---- :)
(: These are the accidental-flag cases the review asked us to double-check. :)

declare
    %test:assertFalse
function x:ok-soviet-union() {
    query-guard:looks-like-sql-injection("Soviet Union")
};

declare
    (: "union" and "Select Committee" adjacent — flagged by a naive "union select" rule :)
    %test:assertFalse
function x:ok-european-union-select-committee() {
    query-guard:looks-like-sql-injection("European Union Select Committee")
};

declare
    %test:assertFalse
function x:ok-select-committee() {
    query-guard:looks-like-sql-injection("Select Committee on Assassinations")
};

declare
    (: double dash as a typographic separator — flagged by a naive "--" comment rule :)
    %test:assertFalse
function x:ok-double-dash-separator() {
    query-guard:looks-like-sql-injection("Nixon -- Kissinger relations")
};

declare
    (: "sleep (" in prose — flagged by a naive "sleep(" rule :)
    %test:assertFalse
function x:ok-sleep-in-prose() {
    query-guard:looks-like-sql-injection("fell asleep (finally) in 1945")
};

declare
    %test:assertFalse
function x:ok-and-keyword() {
    query-guard:looks-like-sql-injection("arms control and disarmament")
};

declare
    %test:assertFalse
function x:ok-or-keyword() {
    query-guard:looks-like-sql-injection("Guatemala OR El Salvador")
};

declare
    %test:assertFalse
function x:ok-drop-without-semicolon() {
    query-guard:looks-like-sql-injection("a sharp drop in relations")
};

declare
    %test:assertFalse
function x:ok-hyphenated() {
    query-guard:looks-like-sql-injection("Berlin-Baghdad railway")
};

declare
    (: "null" appears inside Nullification / annulment; the rule needs two commas'd NULLs :)
    %test:assertFalse
function x:ok-nullification() {
    query-guard:looks-like-sql-injection("Nullification Crisis of 1832")
};

declare
    %test:assertFalse
function x:ok-annulment() {
    query-guard:looks-like-sql-injection("annulment of the marriage")
};

declare
    %test:assertFalse
function x:ok-documented-operators() {
    query-guard:looks-like-sql-injection('"peaceful nuclear" +treaty -weapon')
};

declare
    %test:assertFalse
function x:ok-empty-sequence() {
    query-guard:looks-like-sql-injection(())
};

(: ---- check(): the single controller entry point ---- :)

declare
    %test:assertFalse
function x:check-valid-query() {
    query-guard:check('"peaceful nuclear" +treaty')
};

declare
    %test:assertTrue
function x:check-rejects-sql-injection() {
    query-guard:check("gMxR' UNION ALL SELECT NULL,NULL-- -")
};

declare
    (: any single injection value in a repeated q parameter rejects the whole set :)
    %test:assertTrue
function x:check-rejects-one-of-many() {
    query-guard:check(("Washington", "1 OR 1=1"))
};

declare
    (: DoS guard: an over-length q is rejected up front, bounding regex work :)
    %test:assertTrue
function x:check-rejects-oversized-query() {
    query-guard:check(string-join(for $i in 1 to 2000 return "a", ""))
};

declare
    (: a normal-length clean query is not rejected by the length gate :)
    %test:assertFalse
function x:check-allows-normal-length-query() {
    query-guard:check("the Cuban missile crisis and Soviet-American relations")
};
