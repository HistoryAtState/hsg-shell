/**
 * Archives: Afghanistan headline
 */

describe('Archives Afghanistan', function () {
  beforeEach(function () {
    cy.visit('countries/archives/afghanistan')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('World Wide Diplomatic Archives Index: Afghanistan')
  })
})
