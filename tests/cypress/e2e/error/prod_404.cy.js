/**
 * Checks 404 error page
 */

describe('Requesting a non existing page', () => {
  it('should redirect to the 404 error page', () => {
    cy.openPage('asdfg')
    cy.title().should('include', 'Page not found - Office of the Historian')
  })
})