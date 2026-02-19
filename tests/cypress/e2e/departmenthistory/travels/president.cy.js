/**
 * Travels Abroad of the President headline
 */

describe('President travels', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/travels/president')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Travels Abroad of the President')
  })
})
