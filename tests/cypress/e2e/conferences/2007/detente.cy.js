/**
 * Detente conference – Schedule headline
 */

describe('2007 Detente', function () {
  beforeEach(function () {
    cy.visit('conferences/2007-detente')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Schedule')
  })
})
