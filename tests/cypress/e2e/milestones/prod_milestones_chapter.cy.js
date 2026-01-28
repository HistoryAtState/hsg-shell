/**
 * Checks milestones chapter pages
 */

const red = 'rgba(169,68,66,1)'

describe('Milestones chapter- and their sub pages: ', function () {
  beforeEach(function () {
    cy.visit('milestones/1750-1775/parliamentary-taxation')
  })

  it('should display a red alert note to readers', function () {
    cy.get('#content-inner div.alert.alert-danger')
      .should('exist')
      // color is typically reported as rgb(...) by Cypress; accept rgb or rgba with the expected components.
      .should('have.css', 'color')
      .then((value) => {
        const normalized = value.replace(/\s+/g, '')
        const expectedRgb = 'rgb(169,68,66)'.replace(/\s+/g, '')
        const expectedRgba = red.replace(/\s+/g, '')
        expect([expectedRgb, expectedRgba]).to.include(normalized)
      })
  })
})