/**
 * Buildings – Section 2 headline (Carpenters' Hall)
 * @see tests/specs/departmenthistory/prod_buildings_titles.spec.js (wdio)
 */

describe('Buildings Section 2', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/buildings/section2')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText("Carpenters' Hall, Philadelphia\nSept. 5, 1774—Oct. 26, 1774")
  })
})
