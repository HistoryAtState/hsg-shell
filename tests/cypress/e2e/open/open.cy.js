/**
 * Open Government Initiative headline
 */

describe('Open Government', function () {
  beforeEach(function () {
    cy.visit('open')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Open Government Initiative')
  })
})
