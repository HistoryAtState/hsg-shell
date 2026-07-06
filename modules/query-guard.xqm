xquery version "3.1";

(:~
 : Query guard — rejects malicious or malformed values of the search `q`
 : parameter before they reach the query pipeline.
 :
 : The site's search deliberately exposes Lucene query syntax to users (phrases,
 : booleans, wildcards, proximity — see pages/search/tips.xml), so the documented
 : operators " + - ( ) * ? ~ and the AND/OR/NOT keywords must pass through
 : untouched. This module only blocks input that can never be part of a
 : legitimate query:
 :   1. rejected characters — leftover percent-encoding, control characters, and
 :      the Lucene metacharacters that are NOT documented as features; and
 :   2. SQL-injection signatures — inert against our Lucene backend, but rejected
 :      to keep obvious attack traffic out of the query pipeline and the logs.
 :
 : The controller calls a single entry point, query-guard:check(), so the reject
 : policy lives entirely here.
 :
 : Note: eXist's fn:matches uses the W3C XPath regex grammar. It supports the
 : \p{...} category escapes but has NO \b word-boundary escape and cannot express
 : a reference to codepoint 0, so control characters are matched with \p{Cc} and
 : word boundaries with (^|\W) / (\W|$).
 :)
module namespace query-guard = "http://history.state.gov/ns/site/hsg/query-guard";

(:~
 : Characters that make a `q` value invalid:
 :   %                    leftover percent-encoding — request parameters are
 :                        already URL-decoded, so a literal % signals a malformed
 :                        or double-encoded request
 :   ! : ^ / \ [ ] { }    Lucene metacharacters not exposed as search features
 :   \p{Cc}               ASCII/Unicode control characters
 : The documented operators (" + - ( ) * ? ~) are intentionally absent so that
 : phrase, boolean, wildcard, and proximity searches keep working.
 :)
declare %private variable $query-guard:INVALID-CHARS-REGEX as xs:string :=
    "[%!:/{}\[\]\^\\\p{Cc}]";

(:~
 : Signatures of SQL-injection probes that slip past the character blacklist: a
 : payload such as
 :   gMxR' UNION ALL SELECT NULL,NULL,...-- -
 : uses only letters, digits, spaces, commas, apostrophes and hyphens, none of
 : which are rejected characters. The site has no SQL backend (searches run
 : against Lucene, so these can never actually inject), but rejecting them keeps
 : obvious attack traffic out of the query pipeline and the logs.
 :
 : This is a deliberately heuristic, case-insensitive match. It targets shapes
 : that do not occur in ordinary history queries:
 :   union [all] select        classic UNION-based injection
 :   ; select|insert|drop|...   stacked statements
 :   or/and <n> = <n>           boolean tautologies (e.g. OR 1=1)
 :   sleep(/benchmark(/...      time-based blind injection
 :   --<space or end>           inline SQL comment terminator
 : Trade-off: an unusual literal search like "Union Select Committee" could trip
 : the first rule. That is accepted as the cost of a simple, readable rule.
 :)
declare %private variable $query-guard:SQL-INJECTION-REGEX as xs:string :=
    string-join(
        (
            "(^|\W)union\s+(all\s+)?select(\W|$)",
            ";\s*(select|insert|update|delete|drop|alter|create|truncate|exec|union)(\W|$)",
            "(^|\W)(or|and)\s+\d+\s*=\s*\d+",
            "(^|\W)(sleep|benchmark|pg_sleep|waitfor\s+delay)\s*\(",
            "(^|\s)--(\s|$)"
        ),
        "|"
    );

(:~
 : Does any `q` value contain a character we refuse to pass to Lucene?
 : @param $q the raw (already URL-decoded) `q` value(s); a `q` parameter may be
 :           repeated, so this accepts a sequence
 : @return true if any value contains a rejected character
 :)
declare function query-guard:has-invalid-characters($q as xs:string*) as xs:boolean {
    some $value in $q satisfies matches($value, $query-guard:INVALID-CHARS-REGEX)
};

(:~
 : Does any `q` value look like a SQL-injection probe? Matching is
 : case-insensitive.
 : @param $q the raw (already URL-decoded) `q` value(s)
 : @return true if any value matches a known injection signature
 :)
declare function query-guard:looks-like-sql-injection($q as xs:string*) as xs:boolean {
    some $value in $q satisfies matches($value, $query-guard:SQL-INJECTION-REGEX, "i")
};

(:~
 : Single entry point: should this `q` value be rejected with HTTP 400?
 : Combines every reject rule so callers need only this one function.
 : @param $q the raw (already URL-decoded) `q` value(s)
 : @return true if the query is a malicious or malformed payload to reject
 :)
declare function query-guard:check($q as xs:string*) as xs:boolean {
    query-guard:has-invalid-characters($q)
    or query-guard:looks-like-sql-injection($q)
};
