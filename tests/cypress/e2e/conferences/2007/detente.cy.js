/**
 * Detente conference – Schedule headline
 * @see tests/specs/conferences/prod_conferences_titles.spec.js (wdio)
 */

describe('2007 Detente', function () {
  beforeEach(function () {
    cy.visit('conferences/2007-detente')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Schedule')
  })
})
