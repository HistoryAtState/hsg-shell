/**
 * Checks departmenthistory page type
 */

const regex = /(\<|\/)[a-z]*>/gi

const mainpage = { name: 'p1', link: 'countries', title: 'Countries' }

const subpages = [
  {
    name: 'p2',
    link: 'countries/archives',
    title: 'World Wide Diplomatic Archives Index'
  },
  {
    name: 'p3',
    link: 'countries/archives/all',
    title: 'All Countries'
  },
  {
    name: 'p4',
    link: 'countries/archives/afghanistan',
    title: 'World Wide Diplomatic Archives Index: Afghanistan'
  },
  {
    name: 'p5',
    link: 'countries/archives/bahamas',
    title: 'World Wide Diplomatic Archives Index: Bahamas'
  },
  {
    name: 'p6',
    link: 'countries/archives/zimbabwe',
    title: 'World Wide Diplomatic Archives Index: Zimbabwe'
  }
]

describe('On the Countries page ', function () {
  it('should display the headline', function () {
    cy.openPage(mainpage.link)
    cy.getHeadlineH1().then((title) => {
      expect(title.replace(regex, '')).to.equal(mainpage.title)
    })
  })

  // Subpage titles check
  describe('Each Countries subpage', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', function () {
        cy.openPage(page.link)
        cy.getHeadlineH1().then((title) => {
          expect(title.replace(regex, '')).to.equal(page.title)
        })
      })
    })
  })
})