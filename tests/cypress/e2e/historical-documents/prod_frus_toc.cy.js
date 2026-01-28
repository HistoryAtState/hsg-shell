/**
 * Checks the cover image of a volume landing page
 */

describe('The TOC of a volume', () => {
  before(() => {
    cy.visit('historicaldocuments/frus1947v03/comp1')
  })

  it('should highlight the current chapter', () => {
    // #205493 → rgb(32, 84, 147)
    cy.get('a.hsg-current[href*="historicaldocuments/frus1947v03/comp1"]')
      .should('have.css', 'color', 'rgb(32, 84, 147)')
  })
})