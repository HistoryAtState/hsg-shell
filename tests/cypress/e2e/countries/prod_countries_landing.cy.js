/**
 * Checks departmenthistory page type
 */

describe('The "Countries" landing page', function () {
  beforeEach(function () {
    // Use cy.visit() directly with relative path - baseUrl handles the full URL
    cy.visit('countries')
  })

  it('should display a select input for choosing countries', function () {
    // Match wdio: assert select exists. Rendered HTML may omit data-template; use #content-inner select.
    cy.get('#content-inner select, select[data-template="countries:load-countries"]', { timeout: 10000 }).should('exist')
  })

  // TODO: Check interacting with select input and choose countries
  // TODO: Check sidebar
})