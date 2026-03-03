/**
 * 404 error page
 * @see tests/specs/error/prod_404.spec.js (wdio)
 */

describe('404 error page', function () {
  it('should redirect to the 404 error page', function () {
    cy.visit('asdfg', { failOnStatusCode: false })
    cy.title().should('include', 'Page not found - Office of the Historian')
  })
})
