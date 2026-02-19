/**
 * Status of the FRUS Series headline
 */

describe('Status of the Series', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments/status-of-the-series')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Status of the Foreign Relations of the United States Series')
  })
})
