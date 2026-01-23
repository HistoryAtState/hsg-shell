/**
 * Checks departmenthistory short-history page type
 */

const subpages = [
  {
    name: 'p1',
    link: 'departmenthistory/short-history',
    level: 'h1',
    title: 'A Short History of the Department of State'
  },
  {
    name: 'p2',
    link: 'departmenthistory/short-history/foundations',
    level: 'h3',
    title: 'Foundations of Foreign Affairs, 1775-1823'
  },
  {
    name: 'p3',
    link: 'departmenthistory/short-history/origins',
    level: 'h2',
    title: 'Origins of a Diplomatic Tradition'
  }
]

describe('Short-history pages: ', function () {
  // Subpage titles check
  describe('Each "Short-history" subpage', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', function () {
        cy.visit(page.link)
        cy.get('#content-inner ' + page.level).invoke('text').then((title) => {
          // Normalize whitespace (newlines, extra spaces)
          const normalized = title.replace(/\s+/g, ' ').trim()
          expect(normalized).to.equal(page.title)
        })
      })
    })
  })
})