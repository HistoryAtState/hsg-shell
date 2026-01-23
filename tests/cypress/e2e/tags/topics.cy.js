/**
 * Tags – Topics headline
 * @see tests/specs/tags/prod_tags.spec.js (wdio)
 */

describe('Tags Topics', function () {
  beforeEach(function () {
    cy.visit('tags/topics')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Topics')
  })
})
