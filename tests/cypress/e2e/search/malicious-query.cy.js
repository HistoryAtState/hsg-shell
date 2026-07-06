/**
 * Search query validation – malicious `q` values must be rejected with HTTP 400.
 *
 * The controller calls query-guard:check() (modules/query-guard.xqm) and serves
 * error-page-400.xml with a 400 status when the `q` parameter contains
 * characters we never pass to Lucene (% ! : / \ [ ] { } ^ and ASCII/Unicode
 * control characters) or looks like a SQL-injection probe. Documented operators
 * (" + - ( ) * ? ~) are intentionally still allowed – see the regression guard
 * at the bottom.
 *
 * @see modules/query-guard.xqm (query-guard:check)
 * @see controller.xql (case 'search' -> local:serve-bad-request-page)
 */

// Each value contains at least one rejected metacharacter.
const maliciousQueries = [
  'title:secret',     // : – Lucene field-scoping / injection
  '../../etc/passwd', // / – path traversal
  'boost^10',         // ^ – boost metacharacter
  '[a TO z]',         // [ ] – range metacharacter
  '{malformed}',      // { } – metacharacter
  '100%'              // % – leftover / double percent-encoding
]

describe('Search: malicious queries are rejected with 400', function () {
  maliciousQueries.forEach(function (q) {
    it(`responds 400 for q="${q}"`, function () {
      cy.request({ url: 'search', qs: { q }, failOnStatusCode: false })
        .its('status')
        .should('eq', 400)
    })
  })

  it('renders the "Invalid search query" page for a rejected query', function () {
    cy.visit('search', { qs: { q: 'title:secret' }, failOnStatusCode: false })
    cy.get('h1').should('contain', 'Invalid search query')
  })

  // UNION-based SQL-injection probe. It contains no blacklisted characters
  // (only ' , - and spaces once URL-decoded), so it is caught by the separate
  // SQL-injection heuristic inside query-guard:check(), not the character check.
  // Original request:
  //   GET /exist/apps/hsg-shell/search?q=gMxR%27%20UNION%20ALL%20SELECT%20NULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL%2CNULL--%20-
  it('responds 400 for a UNION-based SQL injection probe', function () {
    const q = "gMxR' UNION ALL SELECT NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL-- -"
    cy.request({ url: 'search', qs: { q }, failOnStatusCode: false })
      .its('status')
      .should('eq', 400)
  })
})

describe('Search: documented operators are still allowed', function () {
  // Regression guard: legitimate Lucene syntax must NOT trigger the 400.
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
