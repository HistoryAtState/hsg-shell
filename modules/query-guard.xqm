xquery version "3.1";

(:~
 : Query guard — rejects search `q` values that look like SQL-injection probes.
 :
 : The site has no SQL backend (searches run against Lucene), so these payloads
 : can never actually inject; a missed one is inert. The guard exists only to
 : keep obvious automated attack traffic out of the query pipeline and the logs,
 : and the controller turns a positive match into an HTTP 400.
 :
 : Because a false negative is harmless but a false positive turns a legitimate
 : history search into an error page, the patterns below are deliberately biased
 : toward NOT firing: each targets a shape that effectively never occurs in
 : ordinary prose queries. Notably we do NOT flag a bare "union select" (cf.
 : "European Union Select Committee") or a lone "--" dash (cf. "Nixon -- Kissinger").
 :
 : Unsupported Lucene metacharacters (! : ^ / \ [ ] { }) are NOT handled here —
 : they are escaped at query-build time in search.xqm so they search literally.
 :
 : Note: eXist's fn:matches uses the W3C XPath regex grammar, which has no \b
 : word-boundary escape, so boundaries are written as (^|\W) ... (\W|$).
 :)
module namespace query-guard = "http://history.state.gov/ns/site/hsg/query-guard";

(:~
 : Maximum total length (summed over all values) of the `q` parameter the guard
 : will inspect. The guard is hot code: it runs on unauthenticated input ahead of
 : the search, so its cost must not scale with attacker input. Real search queries
 : are short; anything longer is junk or an attempt to make the guard (and the
 : downstream Lucene parse / cache / render) do unbounded work, so check() rejects
 : it up front. fn:matches over these patterns is linear — no catastrophic
 : backtracking — so this cap is defence-in-depth against input *size*, bounding
 : the work to O(MAX). Tune freely; 1000 chars is already far beyond any real query.
 :)
declare variable $query-guard:MAX-QUERY-LENGTH as xs:integer := 1000;

(:~
 : SQL-injection signatures, joined into one case-insensitive pattern. Each
 : alternative is chosen to be extremely unlikely in a real history query:
 :   union all select                  UNION-based injection (ALL makes it safe
 :                                      against "European Union select ...")
 :   union select <sql-token>          UNION-based injection whose column list
 :                                      starts with null / a digit / * / @ /
 :                                      concat / distinct / from (never a plain
 :                                      word like "Committee")
 :   or/and <n> = <n>                  boolean tautology (e.g. OR 1=1)
 :   sleep(/benchmark(/pg_sleep( <n>   time-based blind injection (numeric arg,
 :                                      so ordinary "... asleep (" does not fire)
 :   waitfor delay                     MSSQL time-based injection
 :   ; <sql-verb>                      stacked statement
 :   null , null                       UNION column-count padding (the tell-tale
 :                                     NULL,NULL,... list); requires two
 :                                     comma-separated NULLs so history terms like
 :                                     "Nullification" and "annulment" are safe
 :)
declare %private variable $query-guard:SQL-INJECTION-REGEX as xs:string :=
    string-join(
        (
            "(^|\W)union\s+all\s+select(\W|$)",
            "(^|\W)union\s+select\s+(null(\W|$)|distinct(\W|$)|top(\W|$)|from(\W|$)|concat\W|\d|\*|@)",
            "(^|\W)(or|and)\s+\d+\s*=\s*\d+",
            "(^|\W)(sleep|benchmark|pg_sleep)\s*\(\s*\d",
            "(^|\W)waitfor\s+delay(\W|$)",
            ";\s*(select|insert|update|delete|drop|alter|create|truncate|exec)(\W|$)",
            "(^|\W)null\s*,\s*null"
        ),
        "|"
    );

(:~
 : Does any `q` value look like a SQL-injection probe? Matching is
 : case-insensitive. A `q` parameter may be repeated, so this accepts a sequence
 : and returns true if any single value matches.
 : @param $q the raw (already URL-decoded) `q` value(s)
 : @return true if any value matches a known injection signature
 :)
declare function query-guard:looks-like-sql-injection($q as xs:string*) as xs:boolean {
    some $value in $q satisfies matches($value, $query-guard:SQL-INJECTION-REGEX, "i")
};

(:~
 : Single entry point for the controller: should this `q` value be rejected with
 : HTTP 400? Currently the only reject rule is the SQL-injection heuristic;
 : keeping this thin wrapper means the controller need not know that.
 : @param $q the raw (already URL-decoded) `q` value(s)
 : @return true if the query must be rejected
 :)
declare function query-guard:check($q as xs:string*) as xs:boolean {
    (: Gate on length FIRST, via if/then/else rather than `or`, so an oversized q
       is rejected without fn:matches ever scanning unbounded attacker input.
       (XQuery does not guarantee `or` short-circuits, so the gate must be explicit.) :)
    if (sum($q ! string-length(.)) gt $query-guard:MAX-QUERY-LENGTH) then
        true()
    else
        query-guard:looks-like-sql-injection($q)
};
