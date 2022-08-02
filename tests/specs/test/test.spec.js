/**
 * Checks tags page type
 */

const { assert } = require('chai');

const Page  = require('../../pageobjects/Page');
function escape(value) {
  return value.replace(/([\.:])/g, '\\$1');
}

describe('footnote popover', function () {

  describe('footnote popover looks and behavior on desktop', function () {
    this.beforeEach(function() {
      Page.open('historicaldocuments/frus-history/introduction');
      return Page.getElement('#touch-detector').then(function () {
        browser.execute('$(\'#touch-detector\').hide()');
      });
    });
    it('should have a footnote', function () {
      const footnoteLink = Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]');
      assert.equal(footnoteLink.getText(), '1');
      const footnote = Page.getElement(escape(footnoteLink.getAttribute('href')));
      assert.equal(footnote.getAttribute('value'), '1');
      assert.equal(footnote.getAttribute('class'), 'footnote');
    });
    it('footnote popover should appear on hover', function () {
      const footnoteLink = Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]');
      assert.equal(Page.getElement('.popover').isDisplayed(), false);
      footnoteLink.scrollIntoView();
      footnoteLink.moveTo();
      Page.waitForVisible('.popover');
      assert.equal(Page.getElement('.popover').isDisplayed(), true);
    });
    it('footnote popover should not disappear with the cursor on it', function () {
      assert.equal(Page.getElement('.popover').isDisplayed(), false);
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView();
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').moveTo();
      Page.waitForVisible('.popover');
      assert.equal(Page.getElement('.popover').isDisplayed(), true);
      Page.getElement('.popover').scrollIntoView();
      Page.getElement('.popover').moveTo();
      Page.pause(1000);
      assert.equal(Page.getElement('.popover').isDisplayed(), true);
    });
    it('footnote popover should disappear when the cursor leaves', function () {
      assert.equal(Page.getElement('.popover').isDisplayed(), false);
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView();
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').moveTo();
      Page.waitForVisible('.popover');
      assert.equal(Page.getElement('.popover').isDisplayed(), true);
      Page.pause(100);
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView();
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').moveTo(100, 100);
      Page.pause(1000);
      assert.equal(Page.getElement('.popover').isDisplayed(), false);
    });
    it('footnote popover should not disappear when the cursor leaves for a brief moment', function () {
      assert.equal(Page.getElement('.popover').isDisplayed(), false);
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView();
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').moveTo();
      Page.waitForVisible('.popover');
      assert.equal(Page.getElement('.popover').isDisplayed(), true);
      Page.pause(100);
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView();
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').moveTo(100, 100);
      Page.pause(200);
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView();
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').moveTo();
      Page.pause(1000);
      assert.equal(Page.getElement('.popover').isDisplayed(), true);
    });
    it('footnote popover should disappear when the user clicks outside', function () {
      assert.equal(Page.getElement('.popover').isDisplayed(), false);
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView();
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').moveTo();
      Page.waitForVisible('.popover');
      assert.equal(Page.getElement('.popover').isDisplayed(), true);
      Page.pause(100);
      Page.click('body');
      Page.pause(200);
      assert.equal(Page.getElement('.popover').isDisplayed(), false);
    });
    it('footnote popover should not disappear when the user clicks on it', function () {
      assert.equal(Page.getElement('.popover').isDisplayed(), false);
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView();
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').moveTo();
      Page.waitForVisible('.popover');
      assert.equal(Page.getElement('.popover').isDisplayed(), true);
      Page.pause(100);
      Page.click('.popover');
      Page.pause(200);
      assert.equal(Page.getElement('.popover').isDisplayed(), true);
    });
    it('footnote popover should disappear when another one appears', function () {
      assert.equal(Page.getElement('.popover').isDisplayed(), false);
      const footnotes = Page.getElements('#content-inner a.note[href^="#fn\\:"][rel=footnote]');
      assert.equal(footnotes.length, 2);
      footnotes[0].scrollIntoView();
      footnotes[0].scrollIntoView();
      footnotes[0].moveTo();
      Page.waitForVisible('.popover');
      const popoverText = Page.getElementText('.popover');
      assert.equal(Page.getElement('.popover').isDisplayed(), true);
      footnotes[1].scrollIntoView();
      footnotes[1].moveTo();
      Page.pause(100);
      assert.equal(Page.getElement('.popover').isDisplayed(), true);
      assert.notEqual(popoverText, Page.getElementText('.popover'));
    });
    it('footnote popover should disappear when the user clicks on its link', function () {
      assert.equal(Page.getElement('.popover').isDisplayed(), false);
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView();
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').moveTo();
      Page.waitForVisible('.popover');
      assert.equal(Page.getElement('.popover').isDisplayed(), true);
      Page.pause(100);
      Page.click('#content-inner a.note[href^="#fn\\:"][rel=footnote]');
      Page.pause(200);
      assert.equal(Page.getElement('.popover').isDisplayed(), false);
    });
    it('page should scroll to a footnote when the user clicks on its link', function () {
      const footnoteLink = Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]');
      let footnote = Page.getElement(escape(footnoteLink.getAttribute('href')));
      footnoteLink.scrollIntoView();
      assert.equal(footnote.isDisplayedInViewport(), false);
      footnoteLink.click();
      assert.equal(footnote.isDisplayedInViewport(), true);
    });
  });
});

