/**
 * Checks the cover image of a volume landing page
 */

const Page  = require('../../pageobjects/Page');

describe('The TOC of a volume', () => {
  before( () => {
    Page.open('historicaldocuments/frus1947v03/comp1');
  });

  it('should highlight the current chapter', () => {
    let currentLink = Page.getCssProperty('a.hsg-current[href*="historicaldocuments/frus1947v03/comp1"]', 'color').parsed.hex;
    assert.equal(currentLink, '#205493');
  });
});