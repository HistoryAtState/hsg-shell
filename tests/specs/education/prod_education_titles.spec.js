/**
 * Checks if education pages have the correct titles
 */

const Page  = require('../../pageobjects/Page'),
  SubPage = require('../../pageobjects/SubPage');

const subpages = {
  links: {
    p1: 'education',                                // 1st level subpage (landing)
    p2: 'education/modules',                        // 2nd level sub page and modules landing page
    p3: 'education/modules/documents-intro',        // 3rd level sub page (1. module detail)
    p4: 'education/modules/border-vanishes-intro',  // 3nd level sub page (2. module detail, PDF landing) TODO: Check PDF download
    p5: 'education/modules/media-intro',            // 3nd level sub page (3. module detail) TODO: Check PDF download
    p6: 'education/modules/journey-shared-intro',   // 3nd level sub page (3. module detail) TODO: Check PDF download
    p7: 'education/modules/sports-intro',           // 3nd level sub page (3. module detail) TODO: Check PDF download
    p8: 'education/modules/history-diplomacy-intro',// 3nd level sub page (3. module detail) TODO: Check PDF download
    p9: 'education/modules/terrorism-intro'         // 3nd level sub page (3. module detail) TODO: Check PDF download
  },
  titles: {
    p1: 'Education',
    p2: 'Curriculum Modules',
    p3: 'Introduction to Curriculum Packet on “Documents on Diplomacy: Primary Source Documents and Lessons from the World of Foreign Affairs, 1775-2011”',
    p4: 'Introduction to Curriculum Packet on “When the Border Vanishes: Diplomacy and the Threat to our Health and Environment”',
    p5: 'Introduction to Curriculum Packet on “Today in Washington: The Media and Diplomacy”',
    p6: 'Introduction to Curriculum Packet on “A Journey Shared: The United States and China”',
    p7: 'Introduction to Curriculum Packet on “Sports and Diplomacy in the Global Arena”',
    p8: 'Introduction to Curriculum Packet on “A History of Diplomacy”',
    p9: 'Introduction to Curriculum Packet on “Terrorism: A War Without Borders”'
  }
};

describe('Education pages: ', function () {

  // Subpage titles check
  describe('Each "Education" subpage should be displayed and subsequently', function () {
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
      title = Page.getElementText('#volume div + div > h2');
      assert.equal(subpages.titles.p3, title);
    });

    it('should display the headline "' + subpages.titles.p4 + '" ', function () {
      Page.open(subpages.links.p4);
      title = Page.getElementText('#volume div + div > h2');
      assert.equal(subpages.titles.p4, title);
    });

    it('should display the headline "' + subpages.titles.p5 + '" ', function () {
      Page.open(subpages.links.p5);
      title = Page.getElementText('#volume div + div > h2');
      assert.equal(subpages.titles.p5, title);
    });

    it('should display the headline "' + subpages.titles.p6 + '" ', function () {
      Page.open(subpages.links.p6);
      title = Page.getElementText('#volume div + div > h2');
      assert.equal(subpages.titles.p6, title);
    });

    it('should display the headline "' + subpages.titles.p7 + '" ', function () {
      Page.open(subpages.links.p7);
      title = Page.getElementText('#volume div + div > h2');
      assert.equal(subpages.titles.p7, title);
    });

    it('should display the headline "' + subpages.titles.p8 + '" ', function () {
      Page.open(subpages.links.p8);
      title = Page.getElementText('#volume div + div > h2');
      assert.equal(subpages.titles.p8, title);
    });

    it('should display the headline "' + subpages.titles.p9 + '" ', function () {
      Page.open(subpages.links.p9);
      title = Page.getElementText('#volume div + div > h2');
      assert.equal(subpages.titles.p9, title);
    });
  });

});

