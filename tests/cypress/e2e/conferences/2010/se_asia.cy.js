/**
 * Southeast Asia conference – Program headline
 * @see tests/specs/conferences/prod_conferences_titles.spec.js (wdio)
 */

describe('2010 SE Asia', function () {
  beforeEach(function () {
    cy.visit('conferences/2010-southeast-asia')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Program')
  })
})
