/**
 * Tags – Buchanan person headline
 * @see tests/specs/tags/prod_tags.spec.js (wdio)
 */

describe('Tags Buchanan', function () {
  beforeEach(function () {
    cy.visit('tags/buchanan-james-p')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Buchanan, James (P)')
  })
})
