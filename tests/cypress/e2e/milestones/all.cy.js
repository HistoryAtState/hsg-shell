/**
 * All Milestones headline
 */

describe('All Milestones', function () {
  beforeEach(function () {
    cy.visit('milestones/all')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('All Milestones')
  })
})
