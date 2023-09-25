/**
 * Checks departmenthistory subpage type "buildings"
 */

const Page  = require('../../pageobjects/Page'),
  SubPage = require('../../pageobjects/SubPage');

const mainpage =   {
  name: 'p1',
  link: 'departmenthistory/buildings',
  title: 'Buildings of the Department of State'
}

const subpages = [
  {
    name: 'p2',
    link: 'departmenthistory/buildings/intro',
    title: 'Introduction'
  },
  {
    name: 'p3',
    link: 'departmenthistory/buildings/foreword',
    title: 'Original Foreword'
  },
  {
    name: 'p4',
    link: 'departmenthistory/buildings/section1',
    title: 'The Period of the Continental Congress'
  },
  {
    name: 'p5',
    link: 'departmenthistory/buildings/section2',
    title: 'Carpenters’ Hall, Philadelphia\nSept. 5, 1774—Oct. 26, 1774'
  },
  {
    name: 'p6',
    link: 'departmenthistory/buildings/section3',
    title: 'Pennsylvania State House (Independence Hall), Philadelphia\n' +
      'Intermittingly from May 10, 1775 to March 1, 1781'
  }
]

describe('Buildings pages: ', function () {
  it('should display the headline', async function () {
    await Page.open(mainpage.link);
    const title = await Page.getElementText(SubPage.headline_h1);
    assert.equal(mainpage.title, title);
  });

  // Subpage titles check
  describe('Each "Buildings" subpage', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', async function () {
        await Page.open(page.link);
        const title = await Page.getElementText(SubPage.headline_h1);
        assert.equal(page.title, title);
      });
    })
  })
})
