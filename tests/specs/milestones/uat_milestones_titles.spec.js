/**
 * Checks milestones pages
 */

const Page  = require('../../pageobjects/Page'),
  SubPage = require('../../pageobjects/SubPage');

const subpages = {
  links: {
    p1: 'milestones',     // landing
    p2: 'milestones/all', // landing subpage containing TOC
    p3: 'milestones/1750-1775', // milestone subpage 2nd level
    p4: 'milestones/1750-1775/foreword' // milestone subpage 3rd level
  },
  titles: {
    p1: 'Milestones in the History of U.S. Foreign Relations', // h1
    p2: 'All Milestones',
    p3: 'Milestones in the History of U.S. Foreign Relations',
    p4: '1750–1775: Diplomatic Struggles in the Colonial Period'
  }
};

describe('Milestones pages: ', function () {

  // Subpage titles check
  describe('Each "Milestones" subpage should be displayed and subsequently', function () {
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

    it('should display the headline "' + subpages.titles.p4 + '" ', function () {
      Page.open(subpages.links.p4);
      title = Page.getElementText(SubPage.headline_h1);
      assert.equal(subpages.titles.p4, title);
    });
  });

});
