/**
 * Tags main headline
 * @see tests/specs/tags/prod_tags.spec.js (wdio)
 */

describe('Tags', function () {
  beforeEach(function () {
    cy.visit('tags')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Tags')
  })
})
