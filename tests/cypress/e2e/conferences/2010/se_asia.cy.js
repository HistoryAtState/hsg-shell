/**
 * Southeast Asia conference – Program headline
 */

describe('2010 SE Asia', function () {
  beforeEach(function () {
    cy.visit('conferences/2010-southeast-asia')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Program')
  })
})
