/**
 * Checks if developer pages have the correct titles
 */

const Page  = require('../../pageobjects/Page'),
  SubPage = require('../../pageobjects/SubPage');

const subpages = [
  { name: 'p1', link: 'developer', title: 'Developer Resources' },
  {
    name: 'p2',
    link: 'developer/catalog',
    title: 'Office of the Historian Ebook Catalog API'
  }
];

describe('Developer pages: ', function () {

  // Subpage titles check
  describe('Each "Developer" subpage should be displayed and subsequently', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', async function () {
        await Page.open(page.link);
        const title = await Page.getElementText(SubPage.headline_h1);
        assert.equal(page.title, title);
      })  
    })
  })
})

