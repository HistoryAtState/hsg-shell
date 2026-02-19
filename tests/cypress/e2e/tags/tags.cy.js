/**
 * Tags main headline
 */

describe('Tags', function () {
  beforeEach(function () {
    cy.visit('tags')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Tags')
  })
})
