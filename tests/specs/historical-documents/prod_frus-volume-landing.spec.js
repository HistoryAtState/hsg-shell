/**
 * Checks the cover image of a volume landing page
 */

const Page  = require('../../pageobjects/Page');

describe('Volume landing page frus1951-54IranEd2 with a cover image', () => {
  before(async () => {
    await Page.open('historicaldocuments/frus1951-54IranEd2');
  });

  it('should display a cover image loaded from S3 production bucket', async () => {
    let src = await Page.getElementAttribute('#volume #content-inner > img', 'src')
    assert.equal(src, Page.s3_Prod + '/frus/frus1951-54IranEd2/covers/frus1951-54IranEd2.jpg');
  });

  it('should display a cover image with an alt text attribute', async () => {
    let alt = await Page.getElementAttribute('#volume img', 'alt')
    assert.equal(alt, 'Book Cover of Foreign Relations of the United States, 1952-1954, Iran, 1951–1954, Second Edition');
  });

  it('should display a h1 heading before the image', async () => {
    let title = await Page.getElementText('#volume #content-inner > h1');
    assert.equal(title, 'Foreign Relations of the United States, 1952-1954, Iran, 1951–1954, Second Edition', 'No h1 rendered');
  });

  it('should NOT display a h1 heading generated from TEI', async () => {
    let teiHeading = await Page.getCssProperty('#volume .content h1', 'display');
    assert.equal(teiHeading.value, 'none', 'TEI heading is displayed');
  });
});

describe('Volume landing page "frus1861-99Index" without a cover image', () => {
  before(async () => {
    await Page.open('historicaldocuments/frus1861-99Index');
  });

  it('should NOT display a cover image', async () => {
    let nonExistingImg = await Page.getElement('#volume #content-inner > img');
    assert.equal(nonExistingImg.error.error, 'no such element');
  });

  it('should display a h1 heading before the image', async () => {
    let title = await Page.getElementText('#volume #content-inner > h1');
    assert.equal(title, 'General Index to the Published Volumes of the Diplomatic Correspondence and Foreign Relations of the United States, 1861–1899', 'No h1 rendered');
  });

  it('should NOT display a h1 heading generated from TEI', async () => {
    let teiHeading = await Page.getCssProperty('#volume .content h1', 'display');
    assert.equal(teiHeading.value, 'none', 'TEI heading is displayed');
  });
});