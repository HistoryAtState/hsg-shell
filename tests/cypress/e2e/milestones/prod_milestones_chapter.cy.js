/**
 * Checks milestones chapter pages
 */

const red = 'rgba(169,68,66,1)'

describe('Milestones chapter- and their sub pages: ', function () {
  it('should display a red alert note to readers', function () {
    cy.openPage('milestones/1750-1775/parliamentary-taxation')
    cy.get('#content-inner div.alert.alert-danger').should('exist')
    cy.getCssProperty('#content-inner div.alert.alert-danger', 'color').then((textColor) => {
      expect(textColor.value).to.equal(red)
    })
  })
})