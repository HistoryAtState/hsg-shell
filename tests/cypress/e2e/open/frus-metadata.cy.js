/**
 * FRUS Metadata headline
 */

describe('FRUS Metadata', function () {
  beforeEach(function () {
    cy.visit('open/frus-metadata')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Bibliographic Metadata of the Foreign Relations of the United States Series')
  })
})
