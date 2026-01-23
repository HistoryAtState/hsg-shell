/**
 * Milestones 1750-1775 foreword headline
 * @see tests/specs/milestones/prod_milestones_titles.spec.js (wdio)
 */

describe('Milestones Foreword', function () {
  beforeEach(function () {
    cy.visit('milestones/1750-1775/foreword')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('1750–1775: Diplomatic Struggles in the Colonial Period')
  })
})
