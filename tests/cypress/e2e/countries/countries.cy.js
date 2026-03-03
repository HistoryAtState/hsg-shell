/**
 * Countries main page headline
 * @see tests/specs/countries/prod_countries_titles.spec.js (wdio)
 */

describe('Countries', function () {
  beforeEach(function () {
    cy.visit('countries')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Countries')
  })
})
