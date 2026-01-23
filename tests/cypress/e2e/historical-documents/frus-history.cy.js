/**
 * FRUS History page headline (empty h1)
 * @see tests/specs/historical-documents/prod_frus_titles.spec.js (wdio)
 */

describe('FRUS History', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments/frus-history')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('')
  })
})
