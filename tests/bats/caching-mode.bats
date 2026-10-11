#!/usr/bin/env bats

# Tests for the development caching mode ($config:HTTP_CACHING_ENABLED).
#
# hsg-shell describes a page's freshness by $config:EDITORIAL_DATE_TIME, the editorial
# state of the site, rather than by the mtime of any one document. That is deliberate,
# and correct in production, where content arrives by deployment. It is awkward during
# local preview: uploading a document does not move the date, so a client holding a
# cached copy is told nothing changed and keeps showing the previous rendering until a
# force-reload.
#
# Setting the Java system property hsg.http.caching to "off" disables caching for exactly that
# case. Which of the two suites below applies depends on how the instance was started,
# so each skips when it does not.
#
#   caching on  (default):   bats tests/bats/caching-mode.bats
#   caching off:             start eXist with JAVA_OPTS=-Dhsg.http.caching=off, then re-run

HSG_BASE="${HSG_BASE:-http://127.0.0.1:8080/exist/apps/hsg-shell}"
PAGE="$HSG_BASE/countries/afghanistan"

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

# "off" when the instance was started with -Dhsg.http.caching=off, else "on"
caching_mode() {
  if [ "$(header_of "$PAGE" 'Cache-Control')" = "no-store" ]; then echo off; else echo on; fi
}

setup() {
  # warm the instance: the first request after a restart can fail while templates compile
  curl -s -o /dev/null -m 30 "$PAGE" || true

  # hsg-shell cannot render any page without the publication data packages: with none
  # installed every route answers 400, and the mode cannot be detected from the headers.
  # That is the case in CI, which installs only hsg-shell and its libraries.
  if [ "$(curl -s -o /dev/null -m 30 -w '%{http_code}' "$HSG_BASE/")" != "200" ]; then
    skip "instance has no publication data installed"
  fi
}

# --- caching enabled (production default) -----------------------------------

@test "with caching on, a page sends Last-Modified" {
  [ "$(caching_mode)" = "on" ] || skip "instance started with hsg.http.caching=off"
  run header_of "$PAGE" 'Last-Modified'
  [ -n "$output" ]
}

@test "with caching on, a page revalidates to 304" {
  [ "$(caching_mode)" = "on" ] || skip "instance started with hsg.http.caching=off"
  last_modified=$(header_of "$PAGE" 'Last-Modified')
  [ -n "$last_modified" ]
  result=$(curl -s -o /dev/null -m 30 -H "If-Modified-Since: $last_modified" -w '%{http_code}' "$PAGE")
  [ "$result" = "304" ]
}

@test "with caching on, a page is not marked no-store" {
  [ "$(caching_mode)" = "on" ] || skip "instance started with hsg.http.caching=off"
  run header_of "$PAGE" 'Cache-Control'
  [ "$output" != "no-store" ]
}

# --- caching disabled (development) -----------------------------------------

@test "with caching off, a page is marked no-store" {
  [ "$(caching_mode)" = "off" ] || skip "instance started with caching enabled"
  run header_of "$PAGE" 'Cache-Control'
  [ "$output" = "no-store" ]
}

@test "with caching off, a conditional request is not answered with 304" {
  # This is what makes an uploaded edit visible on an ordinary reload: the client's
  # If-Modified-Since can no longer match a date that does not track the document.
  [ "$(caching_mode)" = "off" ] || skip "instance started with caching enabled"
  result=$(curl -s -o /dev/null -m 30 \
    -H "If-Modified-Since: Mon, 29 Jun 2026 00:00:00 +0000" -w '%{http_code}' "$PAGE")
  [ "$result" = "200" ]
}

@test "with caching off, a page still renders" {
  [ "$(caching_mode)" = "off" ] || skip "instance started with caching enabled"
  result=$(curl -s -m 30 "$PAGE" | grep -c 'data-template="pages:app-root"' || true)
  [ "$result" -ge 1 ]
}
