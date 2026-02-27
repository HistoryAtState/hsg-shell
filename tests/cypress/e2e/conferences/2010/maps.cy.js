/**
 * Southeast Asia – Maps headline
 */

describe('2010 Maps', function () {
  beforeEach(function () {
    cy.visit('conferences/2010-southeast-asia/maps')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Maps')
  })
})
