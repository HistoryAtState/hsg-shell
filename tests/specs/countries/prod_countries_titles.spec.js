/**
 * Checks departmenthistory page type
 */

const Page  = require('../../pageobjects/Page'),
    SubPage = require('../../pageobjects/SubPage'),
      regex = Page.regex;

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

  it('should display the headline', async function () {
    await Page.open(mainpage.link);
    const title = await Page.getElementText(SubPage.headline_h1)
    assert.equal(mainpage.title, title.replace(regex, ''));
  });

  // Subpage titles check
  describe('Each Countries subpage', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', async function () {
        await Page.open(page.link);
        const title = await Page.getElementText(SubPage.headline_h1)
        assert.equal(page.title, title.replace(regex, ''));
      })
    })
  });

});
