/**
 * Buildings – Introduction headline
 */

describe('Buildings Intro', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/buildings/intro')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Introduction')
  })
})
