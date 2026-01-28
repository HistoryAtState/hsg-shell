/**
 * Countries landing – select input
 */

describe('Countries landing', function () {
  beforeEach(function () {
    cy.visit('countries')
  })

  it('should display a select input for choosing countries', function () {
    cy.get('#content-inner select, select[data-template="countries:load-countries"]', { timeout: 10000 }).should('exist')
  })
})
