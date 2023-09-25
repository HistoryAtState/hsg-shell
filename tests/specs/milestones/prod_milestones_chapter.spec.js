/**
 * Checks milestones chapter pages
 */

const Page  = require('../../pageobjects/Page');
const red = 'rgba(169,68,66,1)';

describe('Milestones chapter- and their sub pages: ', function () {
  it('should display a red alert note to readers', async function () {
    await Page.open('milestones/1750-1775/parliamentary-taxation');
    let note = await Page.getElement('#content-inner div.alert.alert-danger'),
      textColor = await Page.getCssProperty('#content-inner div.alert.alert-danger', 'color')

    assert.exists(note);
    assert.equal(textColor.value, red)
  });
});
