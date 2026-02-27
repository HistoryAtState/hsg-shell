/**
 * Panel Discussion headline
 */

describe('2011 Panel', function () {
  beforeEach(function () {
    cy.visit('conferences/2011-foreign-economic-policy/panel')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Panel Discussion')
  })
})
