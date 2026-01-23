/**
 * Checks milestones pages
 */

const mainpage = {
  name: 'p1',
  link: 'milestones',
  title: 'Milestones in the History of U.S. Foreign Relations'
}

const subpages = [
  { name: 'p2', link: 'milestones/all', title: 'All Milestones' },
  {
    name: 'p3',
    link: 'milestones/1750-1775',
    title: 'Milestones in the History of U.S. Foreign Relations'
  },
  {
    name: 'p4',
    link: 'milestones/1750-1775/foreword',
    title: '1750–1775: Diplomatic Struggles in the Colonial Period'
  }
]

describe('on the Milestone page', function () {
  it('should display the headline', function () {
    cy.openPage(mainpage.link)
    cy.getHeadlineH1().then((title) => {
      expect(title).to.equal(mainpage.title)
    })
  })

  // Subpage titles check
  describe('Each "Milestones" subpage', function () {
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