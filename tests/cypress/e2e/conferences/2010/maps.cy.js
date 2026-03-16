/**
 * Southeast Asia – Maps headline
 * @see tests/specs/conferences/prod_conferences_titles.spec.js (wdio)
 */

describe('2010 Maps', function () {
  beforeEach(function () {
    cy.visit('conferences/2010-southeast-asia/maps')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Maps')
  })
})
