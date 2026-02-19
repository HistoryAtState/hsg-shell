/**
 * Citing the Foreign Relations series headline
 */

describe('Citing FRUS', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments/citing-frus')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Citing the Foreign Relations series')
  })
})
