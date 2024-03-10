/**
 * Checks departmenthistory short-history page type
 */

const Page  = require('../../pageobjects/Page'),
  SubPage = require('../../pageobjects/SubPage');

const subpages = [
  {
    name: 'p1',
    link: 'departmenthistory/short-history',
    level:'h1',
    title: 'A Short History of the Department of State'
  },
  {
    name: 'p2',
    link: 'departmenthistory/short-history/foundations',
    level:'h3',
    title: 'Foundations of Foreign Affairs, 1775-1823'
  },
  {
    name: 'p3',
    link: 'departmenthistory/short-history/origins',
    level:'h2',
    title: 'Origins of a Diplomatic Tradition'
  }
]

describe('Short-history pages: ', function () {
  // Subpage titles check
  describe('Each "Short-history" subpage', async function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', async function () {
        await Page.open(page.link);
        const title = await Page.getElementText('#content-inner ' + page.level);
        assert.equal(page.title, title);
      })  
    })
  })
})
