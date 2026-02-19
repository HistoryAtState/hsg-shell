/**
 * Buildings – Section 3 headline (Pennsylvania State House)
 */

describe('Buildings Section 3', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/buildings/section3')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Pennsylvania State House (Independence Hall), Philadelphia\nIntermittingly from May 10, 1775 to March 1, 1781')
  })
})
