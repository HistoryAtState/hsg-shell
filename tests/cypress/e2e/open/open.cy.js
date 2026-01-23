/**
 * Open Government Initiative headline
 * @see tests/specs/open/prod_open_titles.spec.js (wdio)
 */

describe('Open Government', function () {
  beforeEach(function () {
    cy.visit('open')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Open Government Initiative')
  })
})
