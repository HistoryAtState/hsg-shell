/**
 * Search query handling for hostile / malformed `q` values.
 *
 * Two different behaviours, by design:
 *  - Unsupported Lucene metacharacters (! : ^ / \ [ ] { }) are ESCAPED and
 *    searched literally, so they return a normal 200 results page — never a 400.
 *    Escaping happens at query-build time in search.xqm
 *    (search:escape-unsupported-characters), not in the controller.
 *  - SQL-injection probes ARE rejected with HTTP 400 by query-guard:check()
 *    in the controller, which serves error-page-400.xml.
 *  - Documented Lucene operators (" + - ( ) * ? ~) always pass through.
 *
 * @see modules/search.xqm (search:escape-unsupported-characters)
 * @see modules/query-guard.xqm (query-guard:check)
 * @see controller.xql (case 'search' -> local:serve-bad-request-page)
 */

// Previously rejected with 400; now escaped / passed through as literals -> 200.
const literalQueries = [
  'title:secret',     // : Lucene field syntax, now escaped
  '../../etc/passwd', // / path-looking input, now escaped
  'boost^10',         // ^ boost metacharacter, now escaped
  '[a TO z]',         // [ ] range metacharacter, now escaped
  '{malformed}',      // { } metacharacter, now escaped
  '100%'              // % not a Lucene metachar; passes through literally
]

describe('Search: unsupported characters are searched literally, not rejected', function () {
  literalQueries.forEach(function (q) {
    it(`responds 200 for q="${q}"`, function () {
      cy.request({ url: 'search', qs: { q }, failOnStatusCode: false })
        .its('status')
        .should('eq', 200)
    })
  })
})

// SQL-injection probes: rejected with HTTP 400.
const injectionQueries = [
  // UNION-based probe. Original request:
  //   GET /exist/apps/hsg-shell/search?q=gMxR%27%20UNION%20ALL%20SELECT%20NULL%2C...%2CNULL--%20-
  "gMxR' UNION ALL SELECT NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL-- -",
  '1 OR 1=1',            // boolean tautology
  'x; DROP TABLE users'  // stacked statement
]

describe('Search: SQL-injection probes are rejected with 400', function () {
  injectionQueries.forEach(function (q) {
    it(`responds 400 for q="${q}"`, function () {
      cy.request({ url: 'search', qs: { q }, failOnStatusCode: false })
        .its('status')
        .should('eq', 400)
    })
  })

  it('renders the "Invalid search query" page for a rejected query', function () {
    cy.visit('search', { qs: { q: '1 OR 1=1' }, failOnStatusCode: false })
    cy.get('h1').should('contain', 'Invalid search query')
  })
})

describe('Search: documented operators are still allowed', function () {
  // Regression guard: legitimate Lucene syntax must NOT trigger a 400.
  it('responds 200 for a query using documented operators', function () {
    cy.request({
      url: 'search',
      qs: { q: '"United Nations" +Washington -Berlin' },
      failOnStatusCode: false
    })
      .its('status')
      .should('eq', 200)
  })
})
