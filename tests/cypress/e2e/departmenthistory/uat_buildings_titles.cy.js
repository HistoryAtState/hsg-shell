/**
 * Checks departmenthistory subpage type "buildings"
 */

const subpages = {
  links: {
    p1: 'departmenthistory/buildings',
    p2: 'departmenthistory/buildings/intro',
    p3: 'departmenthistory/buildings/foreword',
    p4: 'departmenthistory/buildings/section1',
    p5: 'departmenthistory/buildings/section2', // TODO: Check footnotes and references
    p6: 'departmenthistory/buildings/section3'
  },
  titles: {
    p1: 'Buildings of the Department of State', // h1
    p2: 'Introduction',
    p3: 'Original Foreword',
    p4: 'The Period of the Continental Congress',
    p5: 'Carpenters\' Hall, Philadelphia\nSept. 5, 1774—Oct. 26, 1774',
    p6: 'Pennsylvania State House (Independence Hall), Philadelphia\nIntermittingly from May 10, 1775 to March 1, 1781'
  }
}

describe('Buildings pages: ', function () {
  // Subpage titles check
  describe('Each "Buildings" subpage should be displayed and subsequently', function () {
    it('should display the headline "' + subpages.titles.p1 + '" ', function () {
      cy.openPage(subpages.links.p1)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p1)
      })
    })

    it('should display the headline "' + subpages.titles.p2 + '" ', function () {
      cy.openPage(subpages.links.p2)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p2)
      })
    })

    it('should display the headline "' + subpages.titles.p3 + '" ', function () {
      cy.openPage(subpages.links.p3)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p3)
      })
    })

    it('should display the headline "' + subpages.titles.p4 + '" ', function () {
      cy.openPage(subpages.links.p4)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p4)
      })
    })

    it('should display the headline "' + subpages.titles.p5 + '" ', function () {
      cy.openPage(subpages.links.p5)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p5)
      })
    })

    it('should display the headline "' + subpages.titles.p6 + '" ', function () {
      cy.openPage(subpages.links.p6)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p6)
      })
    })
  })
})