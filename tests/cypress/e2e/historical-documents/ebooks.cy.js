/**
 * Ebooks headline
 */

describe('FRUS Ebooks', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments/ebooks')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Ebooks')
  })
})
