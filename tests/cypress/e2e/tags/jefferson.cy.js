/**
 * Tags – Jefferson person headline
 * @see tests/specs/tags/prod_tags.spec.js (wdio)
 */

describe('Tags Jefferson', function () {
  beforeEach(function () {
    cy.visit('tags/jefferson-thomas-s')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Jefferson, Thomas (S)')
  })
})
