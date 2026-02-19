/**
 * Tags – Places headline
 */

describe('Tags Places', function () {
  beforeEach(function () {
    cy.visit('tags/places')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Places')
  })
})
