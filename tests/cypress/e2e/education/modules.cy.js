/**
 * Curriculum Modules headline
 */

describe('Curriculum Modules', function () {
  beforeEach(function () {
    cy.visit('education/modules')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Curriculum Modules')
  })
})
