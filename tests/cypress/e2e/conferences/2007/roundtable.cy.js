/**
 * Detente – Roundtable introduction headline
 */

describe('2007 Roundtable', function () {
  beforeEach(function () {
    cy.visit('conferences/2007-detente/roundtable1')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Introduction to Roundtable Discussion of Former Government Officials')
  })
})
