/**
 * Visits by Foreign Leaders headline
 * @see tests/specs/departmenthistory/prod_departmenthistory_titles.spec.js (wdio)
 */

describe('Visits by Foreign Leaders', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/visits')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Visits by Foreign Leaders')
  })
})
