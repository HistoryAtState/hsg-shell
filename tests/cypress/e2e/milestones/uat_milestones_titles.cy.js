/**
 * Checks milestones pages
 */

const subpages = {
  links: {
    p1: 'milestones', // landing
    p2: 'milestones/all', // landing subpage containing TOC
    p3: 'milestones/1750-1775', // milestone subpage 2nd level
    p4: 'milestones/1750-1775/foreword' // milestone subpage 3rd level
  },
  titles: {
    p1: 'Milestones in the History of U.S. Foreign Relations', // h1
    p2: 'All Milestones',
    p3: 'Milestones in the History of U.S. Foreign Relations',
    p4: '1750–1775: Diplomatic Struggles in the Colonial Period'
  }
}

describe('Milestones pages: ', function () {
  // Subpage titles check
  describe('Each "Milestones" subpage should be displayed and subsequently', function () {
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
  })
})