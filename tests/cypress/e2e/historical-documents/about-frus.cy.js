/**
 * About FRUS headline
 */

describe('About FRUS', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments/about-frus')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('About the Foreign Relations of the United States Series')
  })
})
