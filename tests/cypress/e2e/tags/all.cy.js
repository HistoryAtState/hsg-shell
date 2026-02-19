/**
 * Tags – All Tags headline
 */

describe('All Tags', function () {
  beforeEach(function () {
    cy.visit('tags/all')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('All Tags')
  })
})
