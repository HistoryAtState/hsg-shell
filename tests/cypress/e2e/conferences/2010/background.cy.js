/**
 * Southeast Asia – Background Materials headline
 */

describe('2010 Background', function () {
  beforeEach(function () {
    cy.visit('conferences/2010-southeast-asia/background-materials')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h3').first().normalizeHeadlineText('Background Materials')
  })
})
