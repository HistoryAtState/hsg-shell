/**
 * Buildings – Section 1 headline
 */

describe('Buildings Section 1', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/buildings/section1')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('The Period of the Continental Congress')
  })
})
