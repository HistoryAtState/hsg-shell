/**
 * Status of the FRUS Series headline
 * @see tests/specs/historical-documents/prod_frus_titles.spec.js (wdio)
 */

describe('Status of the Series', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments/status-of-the-series')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Status of the Foreign Relations of the United States Series')
  })
})
