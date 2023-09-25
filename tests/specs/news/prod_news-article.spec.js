/**
 * Checks news article page, displaying one news entry
 */

const { assert } = require('chai');

const Page  = require('../../pageobjects/Page');

const newsArticles = [
 {
  type: 'twitter',
  color: '#1d9bff',
  id: 'twitter-998588428919984129',
  title: 'In #FRUS our recently digitized…',
  dateTime: '2018-05-21',
  date: 'May 05, 2018',
  furtherLink: 'https://twitter.com/HistoryAtState/status/998588428919984129',
  furtherLinkLabel: 'View Twitter Post'
 },
 {
  type: 'press',
  color: '#22711b',
  id: 'press-release-frus1977-80v09Ed2',
  title: 'Press Release',
  dateTime: '2018-05-31',
  date: 'May 31, 2018',
  thumbnail: 'https://static.history.state.gov/frus/frus1977-80v09Ed2/covers/frus1977-80v09Ed2.jpg',
  altText: 'Cover image of frus1977-80v09Ed2',
  furtherLink: 'historicaldocuments/frus1977-80v09Ed2',
  furtherLinkLabel: 'Visit Resource'
 },
 {
  type: 'carousel',
  color: '#c05600',
  id: 'carousel-113',
  title: 'Now Available: <em>Foreign Relations of the United States</em>, 1981–1988, Volume XI, START I',
  dateTime: '2021-04-22',
  date: 'Apr 22, 2021',
  thumbnail: 'https://static.history.state.gov/carousel/frus1981-88v11.jpg',
  altText: 'Book Cover of Foreign Relations of the United States, 1981–1988, Volume XI, START I',
  furtherLink: 'historicaldocuments/frus1981-88v11',
  furtherLinkLabel: 'Visit Resource'
 },
 {
  type: 'tumblr',
  color: '#3b627e',
  id: 'tumblr-136892724523',
  title: 'Remembering Ambassador&nbsp;Stephen W. Bosworth',
  dateTime: '2016-01-08',
  date: 'Jan 08, 2016',
  furtherLink: 'https://historyatstate.tumblr.com/post/136892724523',
  furtherLinkLabel: 'View Tumblr Post'
 }
];

newsArticles.forEach((article) => {
  describe('The news article with ID ' + article.id, () => {
    let fl, bt, d, dc, dt, ts, i, a;

    before(async () => {
     await Page.open('news/' + article.id);
     await Page.pause(500);
     fl = await Page.getElement('.hsg-news__more');
     bt = await $('.hsg-breadcrumb__link[aria-current="page"] > span').getHTML(false);
     d  = await Page.getElement('time.hsg-badge--' + article.type);
     dc = await Page.getCssProperty('time.hsg-badge--' + article.type, 'background-color').parsed.hex;
     dt = await Page.getElementAttribute('time.hsg-badge', 'datetime');
     ts = 'img.hsg-news__thumbnail';
    });

    // Check if types of date badges will get the correct color
    it('should have a date badge with the correct background-color "' + article.color + '"', () => {
      assert.equal(dc, article.color);
    });

    // Check if date is formatted correctly
    it('should display the date formatted in [MNn,*-3] [D01],[YYYY]', () => {
      assert.match(article.date, /^\w{3}\s\d{2},\s\d{4}$/);
    });

    it('should contain a "<time>" element with correct datetime attribute', () => {
      assert.equal(dt, article.dateTime);
    });

    // Check if thumbnail is available and displayed
    if (article.thumbnail != undefined) {
      it('should display a thumbnail if available', async () => {
        i = await Page.getElementAttribute(ts, 'src');
        a = await Page.getElementAttribute(ts, 'alt');
        assert.equal(i, article.thumbnail);
        assert.equal(a, article.altText);
      });
    }

    // Check if further links are displayed and contain expected href attribute
    it('should display a further link to "' + article.furtherLink + '"', async () => {
      let link = await Page.getElementAttribute(fl, 'href');
      assert.include(link, article.furtherLink);
    });

    // Check if breadcrumb for current level contains the headline (and keeps its formatting)
    it('should display a breadcrumb with the article title as the current level', () => {
      assert.equal(bt, article.title);
    });
  });
});
