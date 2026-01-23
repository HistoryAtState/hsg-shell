/**
 * Archives: Zimbabwe headline
 * @see tests/specs/countries/prod_countries_titles.spec.js (wdio)
 */

describe('Archives Zimbabwe', function () {
  beforeEach(function () {
    cy.visit('countries/archives/zimbabwe')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('World Wide Diplomatic Archives Index: Zimbabwe')
  })
})
