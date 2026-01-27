/**
 * Checks the cover image of a volume landing page
 */

describe('The TOC of a volume', () => {
  before(() => {
    cy.visit('historicaldocuments/frus1947v03/comp1')
  })

  it('should highlight the current chapter', () => {
    cy.getCssProperty('a.hsg-current[href*="historicaldocuments/frus1947v03/comp1"]', 'color').then((currentLink) => {
      const color = currentLink.parsed.hex
      expect(color).to.equal('#205493')
    })
  })
})