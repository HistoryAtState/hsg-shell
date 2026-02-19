/**
 * Milestones chapter – red alert note
 */

const red = 'rgba(169,68,66,1)'

describe('Milestones chapter alert', function () {
  beforeEach(function () {
    cy.visit('milestones/1750-1775/parliamentary-taxation')
  })

  it('should display a red alert note to readers', function () {
    cy.get('#content-inner div.alert.alert-danger')
      .should('exist')
      .should('have.css', 'color')
      .then((value) => {
        const normalized = value.replace(/\s+/g, '')
        const expectedRgb = 'rgb(169,68,66)'.replace(/\s+/g, '')
        const expectedRgba = red.replace(/\s+/g, '')
        expect([expectedRgb, expectedRgba]).to.include(normalized)
      })
  })
})
