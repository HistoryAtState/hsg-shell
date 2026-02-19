/**
 * FRUS Latest volumes headline
 */

describe('FRUS Latest', function () {
  beforeEach(function () {
    cy.visit('open/frus-latest')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Latest Volumes of Foreign Relations of the United States Series')
  })
})
