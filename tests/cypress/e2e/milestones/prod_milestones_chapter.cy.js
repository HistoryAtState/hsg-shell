/**
 * Checks milestones chapter pages
 */

const red = 'rgba(169,68,66,1)'

describe('Milestones chapter- and their sub pages: ', function () {
  beforeEach(function () {
    cy.visit('milestones/1750-1775/parliamentary-taxation')
  })

  it('should display a red alert note to readers', function () {
    cy.get('#content-inner div.alert.alert-danger').should('exist')
    cy.getCssProperty('#content-inner div.alert.alert-danger', 'color').then((textColor) => {
      // Normalize color format - convert rgb to rgba if needed, handle spacing
      const colorValue = textColor.value.replace(/\s+/g, '')
      const normalizedColor = colorValue.startsWith('rgb(') && !colorValue.startsWith('rgba(')
        ? colorValue.replace('rgb(', 'rgba(').replace(')', ',1)')
        : colorValue
      const expectedColor = red.replace(/\s+/g, '')
      expect(normalizedColor).to.equal(expectedColor)
    })
  })
})