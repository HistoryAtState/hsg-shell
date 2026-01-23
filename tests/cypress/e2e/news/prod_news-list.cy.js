/**
 * Checks news landing page containing the news list
 */

const newsEntries = [
  {
    type: 'twitter',
    color: '#1d9bff',
    id: 'twitter-998588428919984129',
    label: 'In #FRUS our recently digitized…',
    dateTime: '2018-05-21',
    date: 'May 05, 2018',
    furtherLink: 'https://twitter.com/HistoryAtState/status/998588428919984129',
    furtherLinkLabel: 'View Twitter Post'
  },
  {
    type: 'press',
    color: '#22711b',
    id: 'press-release-frus1977-80v09Ed2',
    label: 'Press Release',
    dateTime: '2018-05-31',
    date: 'May 31, 2018',
    furtherLink: 'historicaldocuments/frus1977-80v09Ed2',
    furtherLinkLabel: 'Visit Resource'
  },
  {
    type: 'carousel',
    color: '#c05600',
    id: 'carousel-113',
    label: 'Now Available: <em>Foreign Relations of the United States</em>, 1981–1988, Volume XI, START I',
    dateTime: '2021-04-22',
    date: 'Apr 22, 2021',
    furtherLink: 'historicaldocuments/frus1981-88v11',
    furtherLinkLabel: 'Visit Resource'
  }
]

// General list tests
describe('The news list', () => {
  before(() => {
    cy.openPage('news')
    cy.wait(500)
  })

  // Check if 20 entries are displayed
  it('should contain 20 list items on one page', () => {
    cy.getElementCount('.hsg-list__news .hsg-list__item').then((lc) => {
      expect(lc).to.equal(20)
    })
  })
})

describe('The pagination', () => {
  before(() => {
    cy.openPage('news')
    cy.wait(500)
  })

  // Pagination
  it('should be displayed', () => {
    cy.get('nav ul.pagination').should('exist')
  })

  // Check if pagination is displaying more than one page
  it('should contain more than one page link', () => {
    // compares counted list elements, 4 are static elements,
    // 1 is at least the current active page, and at least one more
    // is indicating that there are more paginated elements to show => >=6
    cy.getElementCount('nav ul.pagination li').then((pc) => {
      expect(pc).to.be.at.least(6)
    })
  })

  // check if pagination link no.2 will redirect to page showing entries 21-40
  it('should provide a link to the next 20 pages on the first news page', () => {
    cy.get('nav ul.pagination a').eq(3).invoke('attr', 'href').then((href) => {
      expect(href).to.equal('?start=21')
    })
  })
})

// News entries tests
newsEntries.forEach((newsEntry) => {
  describe('News entry with ID "' + newsEntry.id + '" of type "' + newsEntry.type + '"', () => {
    before(() => {
      cy.openPage('news')
      cy.wait(500)
    })

    // Check if types of date badges will get the correct color
    it('should have a date badge with the correct background-color "' + newsEntry.color + '"', () => {
      cy.getCssProperty('.hsg-list__news time.hsg-badge--' + newsEntry.type, 'background-color').then((dc) => {
        expect(dc.parsed.hex).to.equal(newsEntry.color)
      })
    })

    // Check if the news entry has a headline that links to the news article
    it('should have a headline with the correct link to news article "/news/' + newsEntry.id, () => {
      cy.get('.hsg-list__news .hsg-list__title .hsg-list__link[href$="' + newsEntry.id + '"]').should('exist')
    })

    it('should contain the correct title', () => {
      cy.getElementText('.hsg-list__news .hsg-list__title .hsg-list__link[href$="' + newsEntry.id + '"]').then((l) => {
        expect(l).to.exist
      })
    })

    // Check if further links are displayed and contain expected href attribute
    it('should display a further link to "' + newsEntry.furtherLink + '"', () => {
      const sa = '.hsg-list__news time.hsg-badge--' + newsEntry.type + '[dateTime="' + newsEntry.dateTime + '"] + .hsg-list__item-wrap > a.hsg-news__more'
      cy.getElementAttribute(sa, 'href').then((link) => {
        expect(link).to.include(newsEntry.furtherLink)
      })
    })
  })
})