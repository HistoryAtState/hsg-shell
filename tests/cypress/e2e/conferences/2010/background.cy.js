/**
 * Southeast Asia – Background Materials headline
 * @see tests/specs/conferences/prod_conferences_titles.spec.js (wdio)
 */

describe('2010 Background', function () {
  beforeEach(function () {
    cy.visit('conferences/2010-southeast-asia/background-materials')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h3').first().normalizeHeadlineText('Background Materials')
  })
})
