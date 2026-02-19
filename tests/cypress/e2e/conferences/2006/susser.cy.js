/**
 * China Cold War – Susser Introductions headline
 */

describe('2006 Susser', function () {
  beforeEach(function () {
    cy.visit('conferences/2006-china-cold-war/susser')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Introductions')
  })
})
