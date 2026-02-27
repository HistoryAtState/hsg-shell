/**
 * 404 error page
 */

describe('404 error page', function () {
  it('should redirect to the 404 error page', function () {
    cy.visit('asdfg', { failOnStatusCode: false })
    cy.title().should('include', 'Page not found - Office of the Historian')
  })
})
