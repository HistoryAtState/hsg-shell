/**
 * Milestones main headline
 */

describe('Milestones', function () {
  beforeEach(function () {
    cy.visit('milestones')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Milestones in the History of U.S. Foreign Relations')
  })
})
