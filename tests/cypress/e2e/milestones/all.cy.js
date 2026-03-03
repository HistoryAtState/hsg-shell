/**
 * All Milestones headline
 * @see tests/specs/milestones/prod_milestones_titles.spec.js (wdio)
 */

describe('All Milestones', function () {
  beforeEach(function () {
    cy.visit('milestones/all')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('All Milestones')
  })
})
