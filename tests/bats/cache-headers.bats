#!/usr/bin/env bats

# Cache-header tests.
#
# These expect hsg-shell to be reachable at $HSG_BASE, which defaults to a
# container on port 8080, matching smoke-test.bats.
#
# Background: hsg-shell's Last-Modified is not resource-specific — app:last-modified
# falls back to $config:EDITORIAL_DATE_TIME, a constant — so any cached response
# revalidates as 304 indefinitely. That is tolerable for content, which is what the
# constant is meant to describe, but not for error responses: a 404 that entered a
# cache could never be corrected, and only a force-reload would escape it. Error
# responses are therefore sent with Cache-Control: no-store and take no part in
# Last-Modified negotiation.
#
# hsg-shell raises errors two different ways, and both are covered below:
#   - the controller calls local:serve-not-found-page / local:serve-bad-request-page
#   - a publication route renders normally and signals failure during templating,
#     via the hsg-shell.errcode request attribute, which app:handle-error turns
#     into a 4xx status

HSG_BASE="${HSG_BASE:-http://127.0.0.1:8080/exist/apps/hsg-shell}"

# Echoes the status code for a GET.
status_of() {
  curl -s -o /dev/null -m 30 -w '%{http_code}' "$1"
}

# hsg-shell cannot render any page without the publication data packages: with none
# installed, every route answers 400 from app:handle-error's default, and nothing here
# is meaningful. That is the case in CI, which installs only hsg-shell and the handful
# of libraries it depends on, so these tests skip there and run against an instance
# that has been populated.
setup() {
  # the first request after a restart can fail while templates compile
  curl -s -o /dev/null -m 30 "$HSG_BASE/" || true
  if [ "$(status_of "$HSG_BASE/")" != "200" ]; then
    skip "instance has no publication data installed"
  fi
}

# Echoes a response header's full value, preserving case. Header names are matched
# case-insensitively without relying on GNU awk's IGNORECASE.
header_of() {
  curl -s -D - -o /dev/null -m 30 "$1" \
    | tr -d '\r' \
    | awk -v want="$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')" '
        {
          colon = index($0, ":")
          if (colon > 0) {
            name = tolower(substr($0, 1, colon - 1))
            if (name == want) {
              value = substr($0, colon + 1)
              sub(/^ +/, "", value)
              print value
              exit
            }
          }
        }'
}

# --- error responses must not be cacheable ---------------------------------

@test "a controller-level 404 is not cacheable" {
  run status_of "$HSG_BASE/zzdoesnotexist"
  [ "$output" = "404" ]

  run header_of "$HSG_BASE/zzdoesnotexist" "Cache-Control"
  [ "$output" = "no-store" ]
}

@test "a 404 from a publication route is not cacheable" {
  run status_of "$HSG_BASE/countries/zzdoesnotexist"
  [ "$output" = "404" ]

  run header_of "$HSG_BASE/countries/zzdoesnotexist" "Cache-Control"
  [ "$output" = "no-store" ]
}

@test "a 404 for an over-long path is not cacheable" {
  # The controller rejects requests with an unreasonable number of path parts.
  # This shares local:render-page's error parameters with the 400 path, so the
  # bad-request response is covered by the same mechanism.
  run status_of "$HSG_BASE/a/b/c/d/e/f/g/h/i/j/k/l"
  [ "$output" = "404" ]

  run header_of "$HSG_BASE/a/b/c/d/e/f/g/h/i/j/k/l" "Cache-Control"
  [ "$output" = "no-store" ]
}

# --- successful responses must keep caching ---------------------------------

@test "a successful page is still cacheable" {
  run status_of "$HSG_BASE/countries/afghanistan"
  [ "$output" = "200" ]

  # no-store on content would defeat the frontend cache
  run header_of "$HSG_BASE/countries/afghanistan" "Cache-Control"
  [ "$output" != "no-store" ]
}

@test "a successful page still sends Last-Modified" {
  run header_of "$HSG_BASE/countries/afghanistan" "Last-Modified"
  [ -n "$output" ]
}

@test "a successful page still revalidates to 304" {
  last_modified=$(header_of "$HSG_BASE/countries/afghanistan" "Last-Modified")
  [ -n "$last_modified" ]

  result=$(curl -s -o /dev/null -m 30 -H "If-Modified-Since: $last_modified" \
    -w '%{http_code}' "$HSG_BASE/countries/afghanistan")
  [ "$result" = "304" ]
}

# --- the error page still renders -------------------------------------------

@test "the 404 page still has a body" {
  result=$(curl -s -m 30 "$HSG_BASE/zzdoesnotexist" | grep -c 'data-template="pages:app-root"' || true)
  [ "$result" -ge 1 ]
}
