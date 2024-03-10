/**
 * Checks milestones pages
 */

const Page  = require('../../pageobjects/Page'),
  SubPage = require('../../pageobjects/SubPage');

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

  it('should display the headline', async function () {
    await Page.open(mainpage.link);
    assert.equal(mainpage.title, await Page.getElementText(SubPage.headline_h1));
  });

  // Subpage titles check
  describe('Each "Milestones" subpage', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', async function () {
        await Page.open(page.link);
        const title = await Page.getElementText(SubPage.headline_h1)
        assert.equal(page.title, title);
      })
    })
  })
})
