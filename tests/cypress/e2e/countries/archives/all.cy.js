/**
 * All Countries headline
 */

describe('All countries', function () {
  beforeEach(function () {
    cy.visit('countries/archives/all')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('All Countries')
  })
})
