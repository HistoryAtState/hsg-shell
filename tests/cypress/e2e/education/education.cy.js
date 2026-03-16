/**
 * Education main headline
 * @see tests/specs/education/prod_education_titles.spec.js (wdio)
 */

describe('Education', function () {
  beforeEach(function () {
    cy.visit('education')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Education')
  })
})
