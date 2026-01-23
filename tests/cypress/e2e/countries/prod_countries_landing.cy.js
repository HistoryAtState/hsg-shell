/**
 * Checks departmenthistory page type
 */

describe('The "Countries" landing page', function () {
  beforeEach(function () {
    // Use cy.visit() directly with relative path - baseUrl handles the full URL
    cy.visit('countries')
  })

  it('should display a select input for choosing countries', function () {
    cy.get('select[data-template="countries:load-countries"]').should('exist')
  })

  // TODO: Check interacting with select input and choose countries
  // TODO: Check sidebar
})