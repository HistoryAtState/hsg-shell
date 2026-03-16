/**
 * Travels Abroad of the Secretary of State headline
 * @see tests/specs/departmenthistory/prod_departmenthistory_titles.spec.js (wdio)
 */

describe('Secretary travels', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/travels/secretary')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Travels Abroad of the Secretary of State')
  })
})
