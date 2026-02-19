/**
 * Department History index headline
 */

describe('Department History', function () {
  beforeEach(function () {
    cy.visit('departmenthistory')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Department History')
  })
})
