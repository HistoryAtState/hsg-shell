/**
 * Checks all frus subpage titles
 * and the functionality of the dropdown menu
 */

const subpages = {
  titles: {
    p1: 'Historical Documents',
    p2: 'About the Foreign Relations of the United States Series',
    p3: 'Status of the Foreign Relations of the United States Series',
    p4: '', // h1 currently is empty - only a subtitle h2 is present
    p5: 'Ebooks',
    p6: 'Quarterly Releases',
    p7: 'Citing the Foreign Relations series' // pagelink is hidden in sidebar!
  },
  links: {
    p1: 'historicaldocuments',
    p2: 'historicaldocuments/about-frus',
    p3: 'historicaldocuments/status-of-the-series',
    p4: 'historicaldocuments/frus-history',
    p5: 'historicaldocuments/ebooks',
    p6: 'historicaldocuments/quarterly-releases',
    p7: 'historicaldocuments/citing-frus' // pagelink is hidden in sidebar!
  }
}

describe('FRUS pages: ', function () {
  before(function () {
    cy.openPage('historicaldocuments')
  })

  // Dropdown check
  describe('Checking the dropdown menu: Clicking the first dropdown item', function () {
    before(function () {
      cy.get('ul.nav.navbar-nav li:nth-child(2) > a').click()
      cy.waitForVisible('ul.dropdown-menu li:nth-child(2)', 300)
      cy.get('ul.dropdown-menu li:nth-child(1) a').click()
    })

    it('should open the FRUS landing page with headline "' + subpages.titles.p1 + '" ', function () {
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p1)
      })
    })
  })

  // Subpage titles check
  describe('Each FRUS subpage should be displayed and subsequently', function () {
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

    it('should display the headline "' + subpages.titles.p4 + '" (h1 is currently empty) ', function () {
      cy.openPage(subpages.links.p4)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p4)
      })
    })

    it('should display the headline "' + subpages.titles.p5 + '" ', function () {
      cy.openPage(subpages.links.p5)
      cy.getHeadlineH2().then((title) => {
        expect(title).to.equal(subpages.titles.p5)
      })
    })

    it('should display the headline "' + subpages.titles.p6 + '" ', function () {
      cy.openPage(subpages.links.p6)
      cy.getHeadlineH2().then((title) => {
        expect(title).to.equal(subpages.titles.p6)
      })
    })

    // pagelink is hidden in sidebar!
    it('should display the headline "' + subpages.titles.p7 + '" ', function () {
      cy.openPage(subpages.links.p7)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p7)
      })
    })
  })
})