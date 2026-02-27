/**
 * Conference main page headline
 */

describe('Conferences', function () {
  beforeEach(function () {
    cy.visit('conferences')
  })

  it('should display the headline', function () {
    cy.contains('#content-inner h1', 'Conferences')
  })
})
