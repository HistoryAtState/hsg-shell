/**
 * Checks all frus subpage titles
 * and the functionality of the dropdown menu
 */

const Page  = require('../../pageobjects/Page'),
  SubPage   = require('../../pageobjects/SubPage');

const mainpage = {
  name: 'p1',
  link: 'historicaldocuments',
  title: 'Historical Documents'
}

const subpages = [
  {
    name: 'p2',
    link: 'historicaldocuments/about-frus',
    title: 'About the Foreign Relations of the United States Series'
  },
  {
    name: 'p3',
    link: 'historicaldocuments/status-of-the-series',
    title: 'Status of the Foreign Relations of the United States Series'
  },
  { name: 'p4', link: 'historicaldocuments/frus-history', title: '' },
  { name: 'p5', link: 'historicaldocuments/ebooks', title: 'Ebooks' },
  {
    name: 'p6',
    link: 'historicaldocuments/quarterly-releases',
    title: 'Quarterly Releases'
  },
  {
    name: 'p7',
    link: 'historicaldocuments/citing-frus',
    title: 'Citing the Foreign Relations series'
  }
]

describe('FRUS pages: ', function () {

  before(async function () {
    await Page.open('historicaldocuments');
  });

  // Dropdown check
  describe('Checking the dropdown menu: Clicking the first dropdown item', function () {
    before(async function () {
      const link = await Page.getElement('ul.nav.navbar-nav li:nth-child(2) > a')
      await link.click('ul.nav.navbar-nav li:nth-child(2) > a');
      const li = await Page.getElement('ul.dropdown-menu li:nth-child(2)')
      li.waitForDisplayed(300);
      await Page.click('ul.dropdown-menu li:nth-child(1) a');
    });

    it('should open the FRUS landing page with headline', async function () {
      const title = await Page.getElementText(SubPage.headline_h1);
      assert.equal(mainpage.title, title);
    });
  });

  // Subpage titles check
  describe('Each FRUS subpage should be displayed and subsequently', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', async function () {
        await Page.open(page.link);
        const title = await Page.getElementText(SubPage.headline_h1)
        assert.equal(page.title, title.replace(regex, ''));
      })
    })
  });
});
