/**
 * Archives: Bahamas headline
 * @see tests/specs/countries/prod_countries_titles.spec.js (wdio)
 */

describe('Archives Bahamas', function () {
  beforeEach(function () {
    cy.visit('countries/archives/bahamas')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('World Wide Diplomatic Archives Index: Bahamas')
  })
})
