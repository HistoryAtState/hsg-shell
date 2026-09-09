/**
 * Direct HTTP access to XQuery modules must be refused with a 404.
 *
 * The controller used to answer requests for `*.xql` with `<ignore/>`, which
 * hands the request straight to eXist-db. eXist then tries to execute the
 * module, and the resulting XQuery error page leaks internal details
 * (module paths, function names, stack traces). That branch is gone: `*.xql`
 * requests now fall through to the controller's final `default` and get the
 * site's own 404 page.
 *
 * Library modules (`*.xqm`) and test scripts (`*.xq`) never matched the
 * `<ignore/>` branch and always took that same path. They are covered here as
 * a regression guard.
 *
 * @see controller.xql (fallback `default return local:serve-not-found-page()`)
 * @see tests/cypress/e2e/error/404.cy.js
 */

const NOT_FOUND_TITLE = 'Page not found - Office of the Historian'

// Markers that only appear when eXist renders an XQuery error itself.
const XQUERY_ERROR_MARKERS = [
  'XPathException',
  'exerr:',
  'err:XPST',
  'err:XPDY',
  'err:XPTY',
  'XQuery error'
]

function expectSiteNotFound (path) {
  cy.request({ url: path, failOnStatusCode: false }).then(function (res) {
    expect(res.status, `status for ${path}`).to.eq(404)
    expect(res.body, `body for ${path}`).to.include(NOT_FOUND_TITLE)
    XQUERY_ERROR_MARKERS.forEach(function (marker) {
      expect(res.body, `body for ${path} must not contain "${marker}"`).not.to.include(marker)
    })
  })
}

// Main modules: executable if eXist gets to see the request.
const mainModules = [
  'modules/view.xql',
  'modules/frus-ajax.xql',
  'modules/open.xql',
  'modules/opds-catalog.xql',
  'modules/volume-ids.xql',
  'modules/volume-images.xql',
  'modules/does-not-exist.xql'
]

describe('Security: direct requests to main modules (*.xql) return the site 404 page', function () {
  mainModules.forEach(function (path) {
    it(`responds 404 without an XQuery error for ${path}`, function () {
      expectSiteNotFound(path)
    })
  })

  it('responds 404 for a main module requested with query parameters', function () {
    expectSiteNotFound('modules/view.xql?publication-id=app')
  })

  it('responds 404 for the controller itself', function () {
    expectSiteNotFound('controller.xql')
  })

  it('renders the "Page not found" page in the browser', function () {
    cy.visit('modules/view.xql', { failOnStatusCode: false })
    cy.title().should('include', NOT_FOUND_TITLE)
  })
})

// Library modules and test scripts: never routed, must stay 404.
const otherModules = [
  'modules/app.xqm',
  'modules/query-guard.xqm',
  'modules/search.xqm',
  'tests/xquery/validate-replication.xq'
]

describe('Security: direct requests to library modules and scripts return the site 404 page', function () {
  otherModules.forEach(function (path) {
    it(`responds 404 without an XQuery error for ${path}`, function () {
      expectSiteNotFound(path)
    })
  })
})
