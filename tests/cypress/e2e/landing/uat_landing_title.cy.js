/**
 * Checks if landing page has the correct title
 */

describe('HSG landing page', function () {
  it('should have the correct title', function () {
    cy.openPage()
    cy.title().should('include', 'Latest News - Office of the Historian')
  })
})