/**
 * Checks tags page type
 */

const Page  = require('../../pageobjects/Page'),
  SubPage   = require('../../pageobjects/SubPage'),
  regex     = Page.regex;

const subpages = {
  links: {
    p1: 'tags',                      // 1st level subpage (landing)
    p2: 'tags/people',               // 2nd level sub page
    p3: 'tags/places',
    p4: 'tags/topics',
    p5: 'tags/presidents',
    p6: 'tags/all',
    p7: 'tags/buchanan-james-p',     // 2nd level sub page hidden in link list on landing page!
    p8: 'tags/secretaries-of-state', // 2nd level sub page hidden in text link on tags/people page!
    p9: 'tags/jefferson-thomas-s'    // 2nd level sub page hidden in link list on tags/secretaries-of-state page!
  },
  titles: {
    p1: 'Tags',                 // h1
    p2: 'People',               // h2
    p3: 'Places',               // h2
    p4: 'Topics',               // h2
    p5: 'Presidents',           // h2
    p6: 'All Tags',             // h1
    p7: 'Buchanan, James (P)',  // h2
    p8: 'Secretaries of State', // h2
    p9: 'Jefferson, Thomas (S)' // h2
  }
};

describe('Tags pages: ', function () {

  // Subpage titles check
  describe('Each "Tags" subpage should be displayed and subsequently', function () {
    let title;

    it('should display the headline "' + subpages.titles.p1 + '" ', function () {
      Page.open(subpages.links.p1);
      title = Page.getElementText(SubPage.headline_h1).replace(regex, '');
      assert.equal(subpages.titles.p1, title);
    });

    it('should display the headline "' + subpages.titles.p2 + '" ', function () {
      Page.open(subpages.links.p2);
      title = Page.getElementText(SubPage.headline_h2).replace(regex, '');
      assert.equal(subpages.titles.p2, title);
    });

    it('should display the headline "' + subpages.titles.p3 + '" ', function () {
      Page.open(subpages.links.p3);
      title = Page.getElementText(SubPage.headline_h2).replace(regex, '');
      assert.equal(subpages.titles.p3, title);
    });

    it('should display the headline "' + subpages.titles.p4 + '"', function () {
      Page.open(subpages.links.p4);
      title = Page.getElementText(SubPage.headline_h2).replace(regex, '');
      assert.equal(subpages.titles.p4, title);
    });

    it('should display the headline "' + subpages.titles.p5 + '"', function () {
      Page.open(subpages.links.p5);
      title = Page.getElementText(SubPage.headline_h2).replace(regex, '');
      assert.equal(subpages.titles.p5, title);
    });

    it('should display the headline "' + subpages.titles.p6 + '" ', function () {
      Page.open(subpages.links.p6);
      title = Page.getElementText(SubPage.headline_h1).replace(regex, '');
      assert.equal(subpages.titles.p6, title);
    });

    // 2nd level sub page hidden in link list on landing page!
    // random check for the first subpage here of of a long list of names
    it('should display the headline "' + subpages.titles.p7 + '" ', function () {
      Page.open(subpages.links.p7);
      title = Page.getElementText(SubPage.headline_h2).replace(regex, '');
      assert.equal(subpages.titles.p7, title);
    });

    // 2nd level sub page hidden in text link on tags/people page!
    it('should display the headline "' + subpages.titles.p8 + '" ', function () {
      Page.open(subpages.links.p8);
      title = Page.getElementText(SubPage.headline_h2).replace(regex, '');
      assert.equal(subpages.titles.p8, title);
    });

    // 2nd level sub page hidden in link list on tags/secretaries-of-state page!
    it('should display the headline "' + subpages.titles.p9 + '" ', function () {
      Page.open(subpages.links.p9);
      title = Page.getElementText(SubPage.headline_h2).replace(regex, '');
      assert.equal(subpages.titles.p9, title);
    });
  });

});

