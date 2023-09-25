/**
 * Checks departmenthistory short-history page type
 */

const Page  = require('../../pageobjects/Page'),
  SubPage = require('../../pageobjects/SubPage');

const subpages = [
  {
    name: 'p1',
    link: 'departmenthistory/short-history',
    title: 'A Short History of the Department of State'
  },
  {
    name: 'p2',
    link: 'departmenthistory/short-history/foundations',
    title: 'Foundations of Foreign Affairs, 1775-1823'
  },
  {
    name: 'p3',
    link: 'departmenthistory/short-history/origins',
    title: 'Origins of a Diplomatic Tradition'
  }
]

describe('Short-history pages: ', function () {
  // Subpage titles check
  describe('Each "Short-history" subpage', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', async function () {
        await Page.open(page.link);
        const title = await Page.getElementText(SubPage.headline_h1);
        assert.equal(page.title, title);
      })  
    })
  })
})
