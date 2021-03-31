/**
 * Checks if developer pages have the correct titles
 */

const Page  = require('../../pageobjects/Page'),
  SubPage = require('../../pageobjects/SubPage');

const subpages = {
  links: {
    p1: 'developer',        // 1st level subpage (landing)
    p2: 'developer/catalog' // 2nd level sub page
  },
  titles: {
    p1: 'Developer Resources',  // h1
    p2: 'Office of the Historian Ebook Catalog API' // h1
  }
};

describe('Developer pages: ', function () {

  // Subpage titles check
  describe('Each "Developer" subpage should be displayed and subsequently', function () {
    let title;

    it('should display the headline "' + subpages.titles.p1 + '" ', function () {
      Page.open(subpages.links.p1);
      title = Page.getElementText(SubPage.headline_h1);
      assert.equal(subpages.titles.p1, title);
    });

    it('should display the headline "' + subpages.titles.p2 + '" ', function () {
      Page.open(subpages.links.p2);
      title = Page.getElementText(SubPage.headline_h1);
      assert.equal(subpages.titles.p2, title);
    });
  });

});

