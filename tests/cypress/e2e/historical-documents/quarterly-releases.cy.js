/**
 * Quarterly Releases headline
 */

describe('Quarterly Releases', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments/quarterly-releases')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Quarterly Releases')
  })
})
