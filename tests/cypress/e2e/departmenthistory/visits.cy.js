/**
 * Visits by Foreign Leaders headline
 */

describe('Visits by Foreign Leaders', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/visits')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Visits by Foreign Leaders')
  })
})
