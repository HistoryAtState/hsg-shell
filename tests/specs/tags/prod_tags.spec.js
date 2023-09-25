/**
 * Checks tags page type
 */

const Page  = require('../../pageobjects/Page'),
  SubPage   = require('../../pageobjects/SubPage'),
  regex     = Page.regex;

const headline = {
  1: SubPage.headline_h1,
  2: SubPage.headline_h2,
  3: SubPage.headline_h3
}
  
const mainpage = { name: 'p1', link: 'tags', title: 'Tags', h: 1 }
const subpages = [
  { name: 'p2', link: 'tags/people', title: 'People', h: 2 },
  { name: 'p3', link: 'tags/places', title: 'Places', h: 2 },
  { name: 'p4', link: 'tags/topics', title: 'Topics', h: 2 },
  { name: 'p5', link: 'tags/presidents', title: 'Presidents', h: 2 },
  { name: 'p6', link: 'tags/all', title: 'All Tags', h: 1 },
  {
    name: 'p7',
    link: 'tags/buchanan-james-p',
    title: 'Buchanan, James (P)',
    h: 2
  },
  {
    name: 'p8',
    link: 'tags/secretaries-of-state',
    title: 'Secretaries of State',
    h: 2
  },
  {
    name: 'p9',
    link: 'tags/jefferson-thomas-s',
    title: 'Jefferson, Thomas (S)',
    h: 2
  }
]

describe('On the Tag page: ', function () {

  it('should display the headline', async function () {
    Page.open(page.link);
    const title = await Page.getElementText(SubPage.headline_h1)
    assert.equal(page.title, title.replace(regex, ''));
  });

  // Subpage titles check
  describe('Each "Tags" subpage', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', async function () {
        Page.open(page.link);
        const title = await Page.getElementText(headline[page.h])
        assert.equal(page.title, title.replace(regex, ''));
      });
    })
  });

});

