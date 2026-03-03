/**
 * Foreign Economic Policy conference landing headline
 * @see tests/specs/conferences/prod_conferences_titles.spec.js (wdio)
 */

describe('2011 Foreign Econ', function () {
  beforeEach(function () {
    cy.visit('conferences/2011-foreign-economic-policy')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('"Foreign Economic Policy, 1973-1976"')
  })
})
