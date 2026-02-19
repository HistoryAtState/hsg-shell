/**
 * Ebook Catalog API headline
 */

describe('Developer Catalog', function () {
  beforeEach(function () {
    cy.visit('developer/catalog')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Office of the Historian Ebook Catalog API')
  })
})
