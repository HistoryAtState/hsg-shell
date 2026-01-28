/**
 * Short History – Foundations headline
 */

describe('Short History Foundations', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/short-history/foundations')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h3').first().normalizeHeadlineText('Foundations of Foreign Affairs, 1775-1823')
  })
})
