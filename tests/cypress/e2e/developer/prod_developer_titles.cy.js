/**
 * Checks if developer pages have the correct titles
 */

const subpages = [
  { name: 'p1', link: 'developer', title: 'Developer Resources' },
  {
    name: 'p2',
    link: 'developer/catalog',
    title: 'Office of the Historian Ebook Catalog API'
  }
]

describe('Developer pages: ', function () {
  // Subpage titles check
  describe('Each "Developer" subpage should be displayed and subsequently', function () {
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