/**
 * Travels Abroad of the Secretary of State headline
 */

describe('Secretary travels', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/travels/secretary')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Travels Abroad of the Secretary of State')
  })
})
