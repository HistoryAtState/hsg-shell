/**
 * Southeast Asia – Vietnam Photo Gallery headline
 * @see tests/specs/conferences/prod_conferences_titles.spec.js (wdio)
 */

describe('2010 Photos', function () {
  beforeEach(function () {
    cy.visit('conferences/2010-southeast-asia/photos')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Vietnam Photo Gallery')
  })
})
