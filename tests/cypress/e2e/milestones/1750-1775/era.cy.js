/**
 * Milestones era 1750-1775 headline
 */

describe('Milestones 1750-1775', function () {
  beforeEach(function () {
    cy.visit('milestones/1750-1775')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Milestones in the History of U.S. Foreign Relations')
  })
})
