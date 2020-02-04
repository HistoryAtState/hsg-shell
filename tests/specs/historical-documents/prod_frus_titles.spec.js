/**
 * Checks all frus subpage titles
 * and the functionality of the dropdown menu
 */

const Page  = require('../../pageobjects/Page'),
  SubPage   = require('../../pageobjects/SubPage');

const subpages = {
  titles: {
    p1: 'Historical Documents',
    p2: 'About the Foreign Relations of the United States Series',
    p3: 'Status of the Foreign Relations of the United States Series',
    p4: '', // h1 currently is empty - only a subtitle h2 is present
    p5: 'Ebooks',
    p6: 'Quarterly Releases',
    p7: 'Citing the Foreign Relations series' // pagelink is hidden in sidebar!

  },
  links: {
    p1: 'historicaldocuments',
    p2: 'historicaldocuments/about-frus',
    p3: 'historicaldocuments/status-of-the-series',
    p4: 'historicaldocuments/frus-history',
    p5: 'historicaldocuments/ebooks',
    p6: 'historicaldocuments/quarterly-releases',
    p7: 'historicaldocuments/citing-frus' // pagelink is hidden in sidebar!
  }
};

describe('FRUS pages: ', function () {

  before(function () {
    Page.open('historicaldocuments');
  });

  // Dropdown check
  describe('Checking the dropdown menu: Clicking the first dropdown item', function () {
    let title, rawTitle;
    before(function () {
      Page.click('ul.nav.navbar-nav li:nth-child(2) > a');
      Page.waitForVisible('ul.dropdown-menu li:nth-child(2)', 300);
      Page.click('ul.dropdown-menu li:nth-child(1) a');
    });

    it('should open the FRUS landing page with headline "' + subpages.titles.p1 + '" ', function () {
      title = Page.getElementText(SubPage.headline_h1);
      assert.equal(subpages.titles.p1, title);
    });
  });

  // Subpage titles check
  describe('Each FRUS subpage should be displayed and subsequently', function () {
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

    it('should display the headline "' + subpages.titles.p4 + '" (h1 is currently empty) ', function () {
      Page.open(subpages.links.p4);
      title = Page.getElementText(SubPage.headline_h1);
      assert.equal(subpages.titles.p4, title);
    });

    it('should display the headline "' + subpages.titles.p5 + '" ', function () {
      Page.open(subpages.links.p5);
      title = Page.getElementText(SubPage.headline_h2);
      assert.equal(subpages.titles.p5, title);
    });

    it('should display the headline "' + subpages.titles.p6 + '" ', function () {
      Page.open(subpages.links.p6);
      title = Page.getElementText(SubPage.headline_h2);
      assert.equal(subpages.titles.p6, title);
    });

    // pagelink is hidden in sidebar!
    it('should display the headline "' + subpages.titles.p7 + '" ', function () {
      Page.open(subpages.links.p7);
      title = Page.getElementText(SubPage.headline_h1);
      assert.equal(subpages.titles.p7, title);
    });
  });
});
