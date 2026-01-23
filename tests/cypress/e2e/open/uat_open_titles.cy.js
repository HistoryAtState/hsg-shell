/**
 * Checks "Open Government Initiative" pages
 */

const mainpage = { name: 'p1', link: 'open', title: 'Open Government Initiative' }

const subpages = [
  {
    name: 'p2',
    link: 'open/frus-metadata',
    title: 'Bibliographic Metadata of the Foreign Relations of the United States Series'
  },
  {
    name: 'p3',
    link: 'open/frus-latest',
    title: 'Latest Volumes of Foreign Relations of the United States Series'
  }
]

describe('On Open Government Initiative page', function () {
  it('should display the headline', function () {
    cy.openPage(mainpage.link)
    cy.getHeadlineH1().then((title) => {
      expect(title).to.equal(mainpage.title)
    })
  })

  // Subpage titles check
  describe('Each subpage', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', function () {
        cy.openPage(page.link)
        cy.getHeadlineH1().then((title) => {
          expect(title).to.equal(page.title)
        })
      })
    })
  })
})