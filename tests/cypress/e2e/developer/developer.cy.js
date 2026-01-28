/**
 * Developer Resources headline
 */

describe('Developer', function () {
  beforeEach(function () {
    cy.visit('developer')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Developer Resources')
  })
})
