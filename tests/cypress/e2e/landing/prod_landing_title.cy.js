/**
 * Checks if landing page has the correct title
 */

describe('HSG landing page', function () {
  beforeEach(function () {
    // Use cy.visit() with empty string to visit baseUrl root
    // baseUrl is configured in cypress.config.cjs as 'http://localhost:8080/exist/apps/hsg-shell'
    cy.visit('')
  })

  it('should have the correct title', function () {
    cy.title().should('include', 'Office of the Historian')
  })
})