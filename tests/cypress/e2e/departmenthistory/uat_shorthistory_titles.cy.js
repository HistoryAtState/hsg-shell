/**
 * Checks departmenthistory short-history page type
 */

const subpages = {
  links: {
    p1: 'departmenthistory/short-history',
    p2: 'departmenthistory/short-history/foundations',
    p3: 'departmenthistory/short-history/origins'
  },
  titles: {
    p1: 'A Short History of the Department of State',
    p2: 'Foundations of Foreign Affairs, 1775-1823',
    p3: 'Origins of a Diplomatic Tradition'
  }
}

describe('Short-history pages: ', function () {
  // Subpage titles check
  describe('Each "Short-history" subpage should be displayed and subsequently', function () {
    it('should display the headline "' + subpages.titles.p1 + '" ', function () {
      cy.openPage(subpages.links.p1)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p1)
      })
    })

    it('should display the headline "' + subpages.titles.p2 + '" ', function () {
      cy.openPage(subpages.links.p2)
      cy.getHeadlineH3().then((title) => {
        expect(title).to.equal(subpages.titles.p2)
      })
    })

    it('should display the headline "' + subpages.titles.p3 + '" ', function () {
      cy.openPage(subpages.links.p3)
      cy.getHeadlineH2().then((title) => {
        expect(title).to.equal(subpages.titles.p3)
      })
    })
  })
})