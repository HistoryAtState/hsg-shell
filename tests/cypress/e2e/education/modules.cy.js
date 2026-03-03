/**
 * Curriculum Modules headline
 * @see tests/specs/education/prod_education_titles.spec.js (wdio)
 */

describe('Curriculum Modules', function () {
  beforeEach(function () {
    cy.visit('education/modules')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Curriculum Modules')
  })
})
