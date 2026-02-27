/**
 * World Wide Diplomatic Archives Index headline
 */

describe('Archives index', function () {
  beforeEach(function () {
    cy.visit('countries/archives')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('World Wide Diplomatic Archives Index')
  })
})
