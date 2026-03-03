/**
 * Countries landing – select input
 * @see tests/specs/countries/prod_countries_landing.spec.js (wdio)
 */

describe('Countries landing', function () {
  beforeEach(function () {
    cy.visit('countries')
  })

  it('should display a select input for choosing countries', function () {
    cy.get('#content-inner select, select[data-template="countries:load-countries"]', { timeout: 10000 }).should('exist')
  })
})
