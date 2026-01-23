/**
 * Checks if education pages have the correct titles
 */

const subpages = {
  links: {
    p1: 'education', // 1st level subpage (landing)
    p2: 'education/modules', // 2nd level sub page and modules landing page
    p3: 'education/modules/documents-intro', // 3rd level sub page (1. module detail)
    p4: 'education/modules/border-vanishes-intro', // 3nd level sub page (2. module detail, PDF landing) TODO: Check PDF download
    p5: 'education/modules/media-intro', // 3nd level sub page (3. module detail) TODO: Check PDF download
    p6: 'education/modules/journey-shared-intro', // 3nd level sub page (3. module detail) TODO: Check PDF download
    p7: 'education/modules/sports-intro', // 3nd level sub page (3. module detail) TODO: Check PDF download
    p8: 'education/modules/history-diplomacy-intro', // 3nd level sub page (3. module detail) TODO: Check PDF download
    p9: 'education/modules/terrorism-intro' // 3nd level sub page (3. module detail) TODO: Check PDF download
  },
  titles: {
    p1: 'Education', // h1
    p2: 'Curriculum Modules', // h1
    p3: 'Introduction', // h1
    p4: 'Introduction', // h1
    p5: 'Introduction', // h1
    p6: 'Introduction', // h1
    p7: 'Introduction', // h1
    p8: 'Introduction', // h1
    p9: 'Introduction' // h1
  }
}

describe('Education pages: ', function () {
  // Subpage titles check
  describe('Each "Education" subpage should be displayed and subsequently', function () {
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

    it('should display the headline "' + subpages.titles.p7 + '" ', function () {
      cy.openPage(subpages.links.p7)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p7)
      })
    })

    it('should display the headline "' + subpages.titles.p8 + '" ', function () {
      cy.openPage(subpages.links.p8)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p8)
      })
    })

    it('should display the headline "' + subpages.titles.p9 + '" ', function () {
      cy.openPage(subpages.links.p9)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p9)
      })
    })
  })
})