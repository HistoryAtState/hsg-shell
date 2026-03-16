/**
 * Tags – People headline
 * @see tests/specs/tags/prod_tags.spec.js (wdio)
 */

describe('Tags People', function () {
  beforeEach(function () {
    cy.visit('tags/people')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('People')
  })
})
