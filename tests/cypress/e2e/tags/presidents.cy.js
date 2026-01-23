/**
 * Tags – Presidents headline
 * @see tests/specs/tags/prod_tags.spec.js (wdio)
 */

describe('Tags Presidents', function () {
  beforeEach(function () {
    cy.visit('tags/presidents')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Presidents')
  })
})
