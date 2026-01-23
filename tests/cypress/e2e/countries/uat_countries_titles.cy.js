/**
 * Checks departmenthistory page type
 */

const regex = /(\<|\/)[a-z]*>/gi

const subpages = {
  links: {
    p1: 'countries', // 1st level subpage (landing)
    p2: 'countries/archives', // 2nd level sub page
    p3: 'countries/archives/all', // 3rd level overview page
    p4: 'countries/archives/afghanistan', // 4th level sub page
    p5: 'countries/archives/bahamas', // 4th level sub page
    p6: 'countries/archives/zimbabwe' // 4th level sub page
  },
  titles: {
    p1: 'Countries',
    p2: 'World Wide Diplomatic Archives Index',
    p3: 'All Countries',
    p4: 'World Wide Diplomatic Archives Index: Afghanistan',
    p5: 'World Wide Diplomatic Archives Index: Bahamas',
    p6: 'World Wide Diplomatic Archives Index: Zimbabwe'
  }
}

describe('Countries pages: ', function () {
  // Subpage titles check
  describe('Each Countries subpage should be displayed and subsequently', function () {
    it('should display the headline "' + subpages.titles.p1 + '" ', function () {
      cy.openPage(subpages.links.p1)
      cy.getHeadlineH1().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p1)
      })
    })

    it('should display the headline "' + subpages.titles.p2 + '" ', function () {
      cy.openPage(subpages.links.p2)
      cy.getHeadlineH1().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p2)
      })
    })

    // 3rd level sub page, archives overview page with countries list
    it('should display the headline "' + subpages.titles.p3 + '" ', function () {
      cy.openPage(subpages.links.p3)
      cy.getHeadlineH1().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p3)
      })
    })

    // 4th level sub page - random pin-point checks on third level subpages from here on
    it('should display the headline "' + subpages.titles.p4 + '"', function () {
      cy.openPage(subpages.links.p4)
      cy.getHeadlineH1().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p4)
      })
    })

    it('should display the headline "' + subpages.titles.p5 + '" ', function () {
      cy.openPage(subpages.links.p5)
      cy.getHeadlineH1().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p5)
      })
    })

    it('should display the headline "' + subpages.titles.p6 + '" ', function () {
      cy.openPage(subpages.links.p6)
      cy.getHeadlineH1().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p6)
      })
    })
  })
})