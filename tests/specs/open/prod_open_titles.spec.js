/**
 * Checks "Open Government Initiative" pages
 */

const Page  = require('../../pageobjects/Page'),
  SubPage = require('../../pageobjects/SubPage');

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

  it('should display the headline', async function () {
    await Page.open(mainpage.link);
    assert.equal(mainpage.title, await Page.getElementText(SubPage.headline_h1));
  });

  // Subpage titles check
  describe('Each subpage', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', async function () {
        await Page.open(page.link);
        const title = await Page.getElementText(SubPage.headline_h1)
        assert.equal(page.title, title.replace(regex, ''));
      })
    })
  });

});
