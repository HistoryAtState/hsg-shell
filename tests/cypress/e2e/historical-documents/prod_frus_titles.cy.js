/**
 * Checks all frus subpage titles
 * and the functionality of the dropdown menu
 */

const mainpage = {
  name: 'p1',
  link: 'historicaldocuments',
  title: 'Historical Documents'
}

const subpages = [
  {
    name: 'p2',
    link: 'historicaldocuments/about-frus',
    title: 'About the Foreign Relations of the United States Series',
    level: 'h1'
  },
  {
    name: 'p3',
    link: 'historicaldocuments/status-of-the-series',
    title: 'Status of the Foreign Relations of the United States Series',
    level: 'h1'
  },
  {
    name: 'p4',
    link: 'historicaldocuments/frus-history',
    title: '',
    level: 'h1'
  },
  {
    name: 'p5',
    link: 'historicaldocuments/ebooks',
    title: 'Ebooks',
    level: 'h2'
  },
  {
    name: 'p6',
    link: 'historicaldocuments/quarterly-releases',
    title: 'Quarterly Releases',
    level: 'h2'
  },
  {
    name: 'p7',
    link: 'historicaldocuments/citing-frus',
    title: 'Citing the Foreign Relations series',
    level: 'h1'
  }
]

describe('FRUS pages: ', function () {
  before(function () {
    cy.visit('historicaldocuments')
  })

  // Dropdown check
  describe('Checking the dropdown menu: Clicking the first dropdown item', function () {
    before(function () {
      cy.get('ul.nav.navbar-nav li:nth-child(2) > a').first().click()
      cy.get('ul.dropdown-menu li:nth-child(2)').should('be.visible')
      cy.get('ul.dropdown-menu li:nth-child(1) a').first().click()
    })

    it('should open the FRUS landing page with headline', function () {
      cy.get('#content-inner h1').invoke('text').then((title) => {
        expect(title).to.equal(mainpage.title)
      })
    })
  })

  // Subpage titles check
  describe('Each FRUS subpage should be displayed and subsequently', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', function () {
        cy.visit(page.link)
        cy.get('#content-inner ' + page.level).invoke('text').then((title) => {
          // Normalize whitespace (newlines, extra spaces)
          const normalized = title.replace(/\s+/g, ' ').trim()
          expect(normalized).to.equal(page.title || '')
        })
      })
    })
  })
})