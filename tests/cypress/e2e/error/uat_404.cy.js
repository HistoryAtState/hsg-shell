/**
 * Checks 404 error page
 */

describe('Requesting a non existing page', () => {
  it('should redirect to the 404 error page', () => {
    cy.openPage('asdfg')
    cy.title().should('include', 'An error has occurred - Office of the Historian')
  })
})