/**
 * Tags – Secretaries of State headline
 */

describe('Tags Secretaries', function () {
  beforeEach(function () {
    cy.visit('tags/secretaries-of-state')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Secretaries of State')
  })
})
