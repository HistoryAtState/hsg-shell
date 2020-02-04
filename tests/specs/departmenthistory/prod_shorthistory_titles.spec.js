/**
 * Checks departmenthistory short-history page type
 */

const Page  = require('../../pageobjects/Page'),
  SubPage = require('../../pageobjects/SubPage');

const subpages = {
  links: {
    p1: 'departmenthistory/short-history',
    p2: 'departmenthistory/short-history/foundations',
    p3: 'departmenthistory/short-history/origins'
  },
  titles: {
    p1: 'A Short History of the Department of State',
    p2: 'Foundations of Foreign Affairs, 1775-1823',
    p3: 'Origins of a Diplomatic Tradition'
  }
};

describe('Short-history pages: ', function () {

  // Subpage titles check
  describe('Each "Short-history" subpage should be displayed and subsequently', function () {
    let title;

    it('should display the headline "' + subpages.titles.p1 + '" ', function () {
      Page.open(subpages.links.p1);
      title = Page.getElementText(SubPage.headline_h1);
      assert.equal(subpages.titles.p1, title);
    });

    it('should display the headline "' + subpages.titles.p2 + '" ', function () {
      Page.open(subpages.links.p2);
      title = Page.getElementText(SubPage.headline_h3);
      assert.equal(subpages.titles.p2, title);
    });

    it('should display the headline "' + subpages.titles.p3 + '" ', function () {
      Page.open(subpages.links.p3);
      title = Page.getElementText(SubPage.headline_h2);
      assert.equal(subpages.titles.p3, title);
    });

  });

});
