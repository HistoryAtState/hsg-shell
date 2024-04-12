/**
 * Checks the cover image of a volume landing page
 */

const Page  = require('../../pageobjects/Page');

describe('The TOC of a volume', () => {
  before(async () => {
    await Page.open('historicaldocuments/frus1947v03/comp1');
  });

  it('should highlight the current chapter', async () => {
    let currentLink = await Page.getCssProperty('a.hsg-current[href*="historicaldocuments/frus1947v03/comp1"]', 'color')
    const color = currentLink.parsed.hex;
    assert.equal(color, '#205493');
  });
});