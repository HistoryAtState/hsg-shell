/**
 * Short History main headline
 */

describe('Short History', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/short-history')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('A Short History of the Department of State')
  })
})
