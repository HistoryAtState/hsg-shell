/**
 * Checks "Open Government Initiative" pages
 */

const Page  = require('../../pageobjects/Page'),
  SubPage = require('../../pageobjects/SubPage');

const subpages = {
  links: {
    p1: 'open',               // landing
    p2: 'open/frus-metadata', // subpage
    p3: 'open/frus-latest'    // subpage
  },
  titles: {
    p1: 'Open Government Initiative', // h1
    p2: 'Bibliographic Metadata of the Foreign Relations of the United States Series',
    p3: 'Latest Volumes of Foreign Relations of the United States Series'
  }
};

describe('Open Government Initiative pages: ', function () {

  // Subpage titles check
  describe('Each "Open" page should be displayed and subsequently', function () {
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

    it('should display the headline "' + subpages.titles.p3 + '" ', function () {
      Page.open(subpages.links.p3);
      title = Page.getElementText(SubPage.headline_h1);
      assert.equal(subpages.titles.p3, title);
    });

  });

});
