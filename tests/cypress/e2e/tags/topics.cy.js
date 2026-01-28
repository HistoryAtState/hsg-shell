/**
 * Tags – Topics headline
 */

describe('Tags Topics', function () {
  beforeEach(function () {
    cy.visit('tags/topics')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Topics')
  })
})
