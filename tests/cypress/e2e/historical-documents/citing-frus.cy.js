/**
 * Citing the Foreign Relations series headline
 * @see tests/specs/historical-documents/prod_frus_titles.spec.js (wdio)
 */

describe('Citing FRUS', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments/citing-frus')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Citing the Foreign Relations series')
  })
})
