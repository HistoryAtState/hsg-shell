/**
 * Checks milestones chapter pages
 */

const Page  = require('../../pageobjects/Page');

describe('Milestones chapter- and their sub pages: ', function () {
  it('should display a red alert note to readers', function () {
    Page.open('milestones/1750-1775/parliamentary-taxation');
    let note = Page.getElement('#content-inner div.alert.alert-danger'),
      textColor = Page.getCssProperty('#content-inner div.alert.alert-danger', 'color'),
      isRed = 'rgba(169,68,66,1)';
    assert.exists(note);
    assert.equal(textColor.value, isRed)
  });
});
