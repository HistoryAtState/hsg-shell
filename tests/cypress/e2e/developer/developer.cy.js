/**
 * Developer Resources headline
 * @see tests/specs/developer/prod_developer_titles.spec.js (wdio)
 */

describe('Developer', function () {
  beforeEach(function () {
    cy.visit('developer')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Developer Resources')
  })
})
