/**
 * Ebook Catalog API headline
 * @see tests/specs/developer/prod_developer_titles.spec.js (wdio)
 */

describe('Developer Catalog', function () {
  beforeEach(function () {
    cy.visit('developer/catalog')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Office of the Historian Ebook Catalog API')
  })
})
