/**
 * FRUS Latest volumes headline
 * @see tests/specs/open/prod_open_titles.spec.js (wdio)
 */

describe('FRUS Latest', function () {
  beforeEach(function () {
    cy.visit('open/frus-latest')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Latest Volumes of Foreign Relations of the United States Series')
  })
})
