/**
 * Biographies of the Secretaries of State headline
 */

describe('Secretaries of State', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/people/secretaries')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Biographies of the Secretaries of State')
  })
})
