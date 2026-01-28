/**
 * Countries main page headline
 */

describe('Countries', function () {
  beforeEach(function () {
    cy.visit('countries')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Countries')
  })
})
