/**
 * Education main headline
 */

describe('Education', function () {
  beforeEach(function () {
    cy.visit('education')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Education')
  })
})
