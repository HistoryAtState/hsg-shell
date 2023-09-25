/**
 * Checks if education pages have the correct titles
 */

const Page  = require('../../pageobjects/Page'),
  SubPage = require('../../pageobjects/SubPage');

const subpages = [
  { name: 'p1', link: 'education', title: 'Education' },
  {
    name: 'p2',
    link: 'education/modules',
    title: 'Curriculum Modules'
  },
  {
    name: 'p3',
    link: 'education/modules/documents-intro',
    title: 'Introduction to Curriculum Packet on “Documents on Diplomacy: Primary Source Documents and Lessons from the World of Foreign Affairs, 1775-2011”'
  },
  {
    name: 'p4',
    link: 'education/modules/border-vanishes-intro',
    title: 'Introduction to Curriculum Packet on “When the Border Vanishes: Diplomacy and the Threat to our Health and Environment”'
  },
  {
    name: 'p5',
    link: 'education/modules/media-intro',
    title: 'Introduction to Curriculum Packet on “Today in Washington: The Media and Diplomacy”'
  },
  {
    name: 'p6',
    link: 'education/modules/journey-shared-intro',
    title: 'Introduction to Curriculum Packet on “A Journey Shared: The United States and China”'
  },
  {
    name: 'p7',
    link: 'education/modules/sports-intro',
    title: 'Introduction to Curriculum Packet on “Sports and Diplomacy in the Global Arena”'
  },
  {
    name: 'p8',
    link: 'education/modules/history-diplomacy-intro',
    title: 'Introduction to Curriculum Packet on “A History of Diplomacy”'
  },
  {
    name: 'p9',
    link: 'education/modules/terrorism-intro',
    title: 'Introduction to Curriculum Packet on “Terrorism: A War Without Borders”'
  }
];

describe('Education pages: ', function () {

  // Subpage titles check
  describe('Each "Education" subpage should be displayed and subsequently', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', async function () {
        await Page.open(page.link);
        const title = await Page.getElementText(SubPage.headline_h1);
        assert.equal(page.title, title);
      })
    })
  });

});

