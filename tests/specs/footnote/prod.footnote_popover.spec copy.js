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
        browser.execute(function() {
          $('#touch-detector').hide();
        });
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
    it('footnote popover should not have the "back" link', function () {
      const footnoteLink = Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]');
      assert.equal(Page.getElement('.popover').isDisplayed(), false);
      footnoteLink.scrollIntoView();
      footnoteLink.moveTo();
      Page.waitForVisible('.popover');
      assert.equal(Page.getElement('.popover .footnote-body a.fn-back').isExisting(), true);
      assert.equal(Page.getElement('.popover .footnote-body a.fn-back').isDisplayed(), false);
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
  describe('footnote popover looks and behavior on touch devices', function () {
    this.beforeEach(function() {
      Page.open('historicaldocuments/frus-history/introduction');
      return Page.getElement('#touch-detector').then(function () {
        browser.execute(function() {
          $('#touch-detector').show();
        });
      });
    });
    it('footnote popover should appear on tap', function () {
      const footnoteLink = Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]');
      assert.equal(Page.getElement('#footnote-modal').isDisplayed(), false);
      footnoteLink.scrollIntoView();
      footnoteLink.click();
      Page.waitForVisible('#footnote-modal');
      assert.equal(Page.getElement('#footnote-modal').isDisplayed(), true);
    });
    it('footnote popover should not have the "back" link', function () {
      const footnoteLink = Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]');
      assert.equal(Page.getElement('#footnote-modal').isDisplayed(), false);
      footnoteLink.scrollIntoView();
      footnoteLink.click();
      Page.waitForVisible('#footnote-modal');
      assert.equal(Page.getElement('#footnote-modal .modal-body #footnote a.fn-back').isExisting(), true);
      assert.equal(Page.getElement('#footnote-modal .modal-body #footnote a.fn-back').isDisplayed(), false);
    });
    it('footnote popover should disappear when the user taps outside of it', function () {
      assert.equal(Page.getElement('#footnote-modal').isDisplayed(), false);
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView();
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').click();
      Page.waitForVisible('#footnote-modal');
      assert.equal(Page.getElement('#footnote-modal').isDisplayed(), true);
      Page.getElement('body').click({ x: 5, y: 5 });
      Page.pause(200);
      assert.equal(Page.getElement('#footnote-modal').isDisplayed(), false);
    });
    it('footnote popover should disappear when the user taps on the close button', function () {
      assert.equal(Page.getElement('#footnote-modal').isDisplayed(), false);
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView();
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').click();
      Page.waitForVisible('#footnote-modal');
      assert.equal(Page.getElement('#footnote-modal').isDisplayed(), true);
      Page.getElement('#footnote-modal .modal-header button.close').click();
      Page.pause(200);
      assert.equal(Page.getElement('#footnote-modal').isDisplayed(), false);
    });
    it('footnote popover should disappear when the user taps on "View footnotes"', function () {
      let footnote = Page.getElement('.footnotes');
      assert.equal(Page.getElement('#footnote-modal').isDisplayed(), false);
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView();
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').click();
      Page.pause(200);
      assert.equal(Page.getElement('#footnote-modal').isDisplayed(), true);
      Page.getElement('#footnote-modal .modal-body #link a').click();
      Page.pause(200);
      assert.equal(Page.getElement('#footnote-modal').isDisplayed(), false);
    });
    it('page should scroll to the footnotes section when the user taps on "View footnotes"', function () {
      let footnote = Page.getElement('.footnotes');
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView();
      assert.equal(footnote.isDisplayedInViewport(), false);
      Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]').click();
      Page.pause(200);
      Page.getElement('#footnote-modal .modal-body #link a').click();
      assert.equal(footnote.isDisplayedInViewport(), true);
    });
  });
});

