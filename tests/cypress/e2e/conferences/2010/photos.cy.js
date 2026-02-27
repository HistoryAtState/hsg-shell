/**
 * Southeast Asia – Vietnam Photo Gallery headline
 */

describe('2010 Photos', function () {
  beforeEach(function () {
    cy.visit('conferences/2010-southeast-asia/photos')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Vietnam Photo Gallery')
  })
})
