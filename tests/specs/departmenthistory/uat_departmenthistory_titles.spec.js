/**
 * Checks departmenthistory page type
 */

const Page  = require('../../pageobjects/Page'),
    SubPage = require('../../pageobjects/SubPage');

const subpages = {
  links: {
    p1: 'departmenthistory',
    p2: 'departmenthistory/timeline',
    p3: 'departmenthistory/people/secretaries',
    p4: 'departmenthistory/people/principals-chiefs',
    p5: 'departmenthistory/travels/secretary',
    p6: 'departmenthistory/travels/president',
    p7: 'departmenthistory/visits',
    p8: 'departmenthistory/wwi',
    p9: 'departmenthistory/buildings',
    p10: 'departmenthistory/diplomatic-couriers'
  },
  titles: {
    p1: 'Department History',
    p2: 'Administrative Timeline of the Department of State',
    p3: 'Biographies of the Secretaries of State',
    p4: 'Principal Officers and Chiefs of Mission',
    p5: 'Travels Abroad of the Secretary of State',
    p6: 'Travels Abroad of the President',
    p7: 'Visits by Foreign Leaders',
    p8: 'World War I and the Department',
    p9: 'Buildings of the Department of State',
    p10: 'U.S. Diplomatic Couriers'
  }
};

describe('Department History pages: ', function () {

  // Subpage titles check
  describe('Each "Department History" subpage should be displayed and subsequently', function () {
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

    it('should display the headline "' + subpages.titles.p7 + '" ', function () {
      Page.open(subpages.links.p7);
      title = Page.getElementText(SubPage.headline_h1);
      assert.equal(subpages.titles.p7, title);
    });

    it('should display the headline "' + subpages.titles.p8 + '" ', function () {
      Page.open(subpages.links.p8);
      title = Page.getElementText(SubPage.headline_h1);
      assert.equal(subpages.titles.p8, title);
    });

    it('should display the headline "' + subpages.titles.p9 + '" ', function () {
      Page.open(subpages.links.p9);
      title = Page.getElementText(SubPage.headline_h1);
      assert.equal(subpages.titles.p9, title);
    });

    it('should display the headline "' + subpages.titles.p10 + '" ', function () {
      Page.open(subpages.links.p10);
      title = Page.getElementText(SubPage.headline_h1);
      assert.equal(subpages.titles.p10, title);
    });
  });

});
