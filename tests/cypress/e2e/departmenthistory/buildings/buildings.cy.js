/**
 * Buildings of the Department of State – main headline
 */

describe('Buildings', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/buildings')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Buildings of the Department of State')
  })
})
