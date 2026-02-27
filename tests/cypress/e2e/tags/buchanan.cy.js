/**
 * Tags – Buchanan person headline
 */

describe('Tags Buchanan', function () {
  beforeEach(function () {
    cy.visit('tags/buchanan-james-p')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Buchanan, James (P)')
  })
})
