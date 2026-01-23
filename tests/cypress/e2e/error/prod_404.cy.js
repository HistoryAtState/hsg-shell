/**
 * Checks 404 error page
 */

describe('Requesting a non existing page', () => {
  it('should redirect to the 404 error page', () => {
    // Use cy.visit() directly with relative path - baseUrl handles the full URL
    cy.visit('asdfg', { failOnStatusCode: false })
    cy.title().should('include', 'Page not found - Office of the Historian')
  })
})