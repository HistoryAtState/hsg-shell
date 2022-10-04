/**
 * Checks all frus all volumes
 */

const Page  = require('../../pageobjects/Page');

const images = [
  Page.s3_Prod + '/frus/frus1861/covers/frus1861.jpg',
  Page.s3_Prod + '/frus/frus1861-99Index/covers/frus1861-99Index.jpg',
  Page.s3_Prod + '/frus/frus1862/covers/frus1862.jpg',
];

const titles = [
  'Message of the President of the United States to the Two Houses of Congress, at the Commencement of the Second Session of the Thirty-seventh Congress',
  'General Index to the Published Volumes of the Diplomatic Correspondence and Foreign Relations of the United States, 1861–1899',
  'Papers Relating to Foreign Affairs, Accompanying the Annual Message of the President to the Third Session Thirty-seventh Congress'
];

const links = [
  'historicaldocuments/frus1861',
  '/historicaldocuments/frus1861-99Index',
  'historicaldocuments/frus1862'
];

const publishedDates = [
  'Published on May 24, 2021'
];

describe('FRUS "All Volumes" page', () => {
  let imageSrc, imageSelector;
  before( () => {
    Page.open('historicaldocuments/volume-titles');
    Page.pause(500);
  });

  it('should display a title', () => {
    let title = Page.getElementText('h1');
    assert.equal(title, 'All Titles in the Series');
  });

  it('should display a sidebar with citation option', () => {
    let sidebar = Page.getElement('hsg-cite__button--sidebar');
    assert.exists(sidebar);
  });

  it('should display a list containing a thumbnail', () => {
    let t_0 = Page.getElementAttribute('ul.hsg-list__volumes li:nth-child(1) img', 'src'),
        t_1 = Page.getElementAttribute('ul.hsg-list__volumes li:nth-child(2) img', 'src'),
        t_2 = Page.getElementAttribute('ul.hsg-list__volumes li:nth-child(3) img', 'src');
    assert.include(t_0, images[0]);
    assert.include(t_1, images[1]);
    assert.include(t_2, images[2]);
  });

  it('should display a list containing a title', () => {
    let title_0 = Page.getElementText('ul.hsg-list__volumes li:nth-child(1) h3 a'),
        title_1 = Page.getElementText('ul.hsg-list__volumes li:nth-child(2) h3 a'),
        title_2 = Page.getElementText('ul.hsg-list__volumes li:nth-child(3) h3 a');
    assert.equal(title_0, titles[0]);
    assert.equal(title_1, titles[1]);
    assert.equal(title_2, titles[2]);
  });

  it('should display a list containing a link to the volume', () => {
    let link_0 = Page.getElementAttribute('ul.hsg-list__volumes li:nth-child(1) h3 a', 'href'),
        link_1 = Page.getElementAttribute('ul.hsg-list__volumes li:nth-child(2) h3 a', 'href'),
        link_2 = Page.getElementAttribute('ul.hsg-list__volumes li:nth-child(3) h3 a', 'href');
    assert.include(link_0, links[0]);
    assert.include(link_1, links[1]);
    assert.include(link_2, links[2]);
  });

  it('should display a list containing a published status and date, if available', () => {
    let publishedDate_0 = Page.getElementText('ul.hsg-list__volumes li:nth-child(1) dl dd:nth-of-type(1)');
    assert.include(publishedDate_0, publishedDates);
  });

  it('should display a list containing download buttons, if available', () => {
    let dl = Page.getElementText('ul.hsg-list__volumes li:nth-child(1) ul.hsg-list__media__download > li > button span');
    assert.exists(dl);
  });
});
