/**
 * TOC of a volume – current chapter highlight
 */

describe('FRUS TOC', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments/frus1947v03/comp1')
  })

  it('should highlight the current chapter', function () {
    cy.get('a.hsg-current[href*="historicaldocuments/frus1947v03/comp1"]')
      .should('have.css', 'color', 'rgb(32, 84, 147)')
  })
})
