/**
 * Checks news landing page containing the news list
 */

 const { assert } = require('chai');

 const Page  = require('../../pageobjects/Page');

 const newsEntries = [
   {
    type: 'twitter',
    color: '#1d9bff',
    id: 'twitter-998588428919984129',
    label: 'In #FRUS our recently digitized…',
    dateTime: '2018-05-21',
    date: 'May 05, 2018',
    furtherLink: 'https://twitter.com/HistoryAtState/status/998588428919984129',
    furtherLinkLabel: 'View Twitter Post'
   },
   {
    type: 'press',
    color: '#22711b',
    id: 'press-release-frus1977-80v09Ed2',
    label: 'Press Release',
    dateTime: '2018-05-31',
    date: 'May 31, 2018',
    furtherLink: 'historicaldocuments/frus1977-80v09Ed2',
    furtherLinkLabel: 'Visit Resource'
  },
   {
    type: 'carousel',
    color: '#c05600',
    id: 'carousel-113',
    label: 'Now Available: <em>Foreign Relations of the United States</em>, 1981–1988, Volume XI, START I',
    dateTime: '2021-04-22',
    date: 'Apr 22, 2021',
    furtherLink: 'historicaldocuments/frus1981-88v11',
    furtherLinkLabel: 'Visit Resource'
  }
 ];

// General list tests
describe('The news list', () => {
  let lc;

  before(async () => {
    await Page.open('news');
    await Page.pause(500)
    await Page.getElements('ul.hsg-list__news li.hsg-list__item')
    lc = await Page.getElementCount('.hsg-list__news .hsg-list__item')
  });

  // Check if 20 entries are displayed
  it('should contain 20 list items on one page', () => {
    assert.equal(lc, 20 );
  });
});

describe('The pagination', () => {
  let p, a, pc;

  before(async () => {
    await Page.open('news');
    await Page.pause(500)
    p = await Page.getElement('nav ul.pagination')
    pa = await Page.getElements('nav ul.pagination a')
    pc = await Page.getElementCount('nav ul.pagination li')
  });

  // Pagination
  it('should be displayed', () => {
    assert.exists(p);
  });


  // Check if pagination is displaying more than one page
  it('should contain more than one page link', () => {
    // compares counted list elements, 4 are static elements,
    // 1 is at least the current active page, and at least one more
    // is indicating that there are more paginated elements to show => >=6
    assert.isAtLeast(pc, 6);
  });

  // check if pagination link no.2 will redirect to page showing entries 21-40
  it('should provide a link to the next 20 pages on the first news page', async () => {
    let href = await Page.getElementAttribute(pa[3], 'href');
    assert.equal(href, '?start=21');
  });
});

// News entries tests

newsEntries.forEach((newsEntry) => {
  describe('News entry with ID "' + newsEntry.id + '" of type "' + newsEntry.type + '"', () => {
    let d, dc, s, id, l, sa;

    before(async () => {
      await Page.open('news');
      await Page.pause(500)
      d  = await Page.getElement('.hsg-list__news time.hsg-badge--' + newsEntry.type);
      dc = await Page.getCssProperty('.hsg-list__news time.hsg-badge--' + newsEntry.type, 'background-color');
      s  = '.hsg-list__news .hsg-list__title .hsg-list__link[href$="' + newsEntry.id + '"]'
      id = await Page.getElement(s);
      l  = await Page.getElementText(s);
      sa  = '.hsg-list__news time.hsg-badge--' + newsEntry.type + '[dateTime="' + newsEntry.dateTime + '"] + .hsg-list__item-wrap > a.hsg-news__more'
    });

    // Check if types of date badges will get the correct color
    it('should have a date badge with the correct background-color "' + newsEntry.color + '"', () => {
      assert.equal(dc.parsed.hex, newsEntry.color);
    });

    // Check if the news entry has a headline that links to the news article
    it('should have a headline with the correct link to news article "/news/' + newsEntry.id, () => {
      assert.exists(id);
    });

    it('should contain the correct title', () => {
      assert.exists(l)
    });

    // Check if further links are displayed and contain expected href attribute
    it('should display a further link to "' + newsEntry.furtherLink + '"', async () => {
      let link = await Page.getElementAttribute(sa, 'href');
      assert.include(link, newsEntry.furtherLink);
    });
  });
});

