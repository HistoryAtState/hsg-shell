/**
 * Buildings – Introduction headline
 * @see tests/specs/departmenthistory/prod_buildings_titles.spec.js (wdio)
 */

describe('Buildings Intro', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/buildings/intro')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Introduction')
  })
})
