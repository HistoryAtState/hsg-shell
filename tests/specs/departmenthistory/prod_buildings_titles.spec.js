/**
 * Checks departmenthistory subpage type "buildings"
 */

const Page  = require('../../pageobjects/Page'),
  SubPage = require('../../pageobjects/SubPage');

const subpages = {
  links: {
    p1: 'departmenthistory/buildings',
    p2: 'departmenthistory/buildings/intro',
    p3: 'departmenthistory/buildings/foreword',
    p4: 'departmenthistory/buildings/section1',
    p5: 'departmenthistory/buildings/section2', // TODO: Check footnotes and references
    p6: 'departmenthistory/buildings/section3'
  },
  titles: {
    p1: 'Buildings of the Department of State', // h1
    p2: 'Introduction',
    p3: 'Original Foreword',
    p4: 'The Period of the Continental Congress',
    p5: "Carpenters’ Hall, Philadelphia\nSept. 5, 1774—Oct. 26, 1774",
    p6: 'Pennsylvania State House (Independence Hall), Philadelphia\nIntermittingly from May 10, 1775 to March 1, 1781'
  }
};

describe('Buildings pages: ', function () {

  // Subpage titles check
  describe('Each "Buildings" subpage should be displayed and subsequently', function () {
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

    it('should display the headline "' + subpages.titles.p5 + '" ', function () {
      Page.open(subpages.links.p5);
      title = Page.getElementText(SubPage.headline_h1);
      assert.equal(subpages.titles.p5, title);
    });

    it('should display the headline "' + subpages.titles.p6 + '" ', function () {
      Page.open(subpages.links.p6);
      title = Page.getElementText(SubPage.headline_h1);
      assert.equal(subpages.titles.p6, title);
    });
  });

});
