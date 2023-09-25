/**
 * Checks tags page type
 */

const { assert } = require('chai');

const Page  = require('../../pageobjects/Page');
function escape(value) {
  return value.replace(/([\.:])/g, '\\$1');
}

describe('footnote popover', function () {
  let footnoteLink, popover;
  async function prepareBeforeEach() {
    await Page.open('historicaldocuments/frus-history/introduction');
    const touchDetector = await Page.getElement('#touch-detector')
    await touchDetector.hide();
    footnoteLink = await Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]')
    popover = await Page.getElement('.popover')
  }

  describe('footnote popover look and behavior on desktop', function () {
    beforeEach(prepareBeforeEach)

    it('should have a footnote', async function () {
      assert.equal(footnoteLink.getText(), '1');
      const footnote = await Page.getElement(escape(footnoteLink.getAttribute('href')));
      assert.equal(footnote.getAttribute('value'), '1');
      assert.equal(footnote.getAttribute('class'), 'footnote');
    })

    it('footnote popover should appear on hover', async function () {
      assert.isFalse(popover.isDisplayed());

      footnoteLink.scrollIntoView();
      footnoteLink.moveTo();

      await Page.waitForVisible('.popover');
      assert.isTrue(popover.isDisplayed());
    });

    it('footnote popover should not have the "back" link', async function () {
      assert.isFalse(popover.isDisplayed());
      footnoteLink.scrollIntoView();
      footnoteLink.moveTo();
      await Page.waitForVisible('.popover');

      const fnBack = await Page.getElement('.popover .footnote-body a.fn-back')
      assert.isTrue(fnBack.isExisting());
      assert.isFalse(fnBack.isDisplayed());
    });
    it('footnote popover should not disappear with the cursor on it', async function () {
      assert.isFalse(popover.isDisplayed());
      footnoteLink.scrollIntoView();
      footnoteLink.moveTo();
      await Page.waitForVisible('.popover');
      assert.isTrue(popover.isDisplayed());

      popover.scrollIntoView();
      popover.moveTo();
      await Page.pause(1000);
      assert.isTrue(popover.isDisplayed());
    });
    it('footnote popover should disappear when the cursor leaves', async function () {
      assert.isFalse(popover.isDisplayed());
      footnoteLink.scrollIntoView();
      footnoteLink.moveTo();
      await Page.waitForVisible('.popover');
      assert.isTrue(popover.isDisplayed());

      await Page.pause(100);
      footnoteLink.scrollIntoView();
      footnoteLink.moveTo(100, 100);
      await Page.pause(1000);
      assert.isFalse(popover.isDisplayed());
    });
    it('footnote popover should not disappear when the cursor leaves for a brief moment', async function () {
      assert.isFalse(popover.isDisplayed());
      footnoteLink.scrollIntoView();
      footnoteLink.moveTo();
      await popover.waitForDisplayed();
      assert.isTrue(popover.isDisplayed());

      await Page.pause(100);
      footnoteLink.scrollIntoView();
      footnoteLink.moveTo(100, 100);
      await Page.pause(200);
      footnoteLink.scrollIntoView();
      footnoteLink.moveTo();
      await Page.pause(1000);
      assert.isTrue(popover.isDisplayed());
    });
    it('footnote popover should disappear when the user clicks outside', async function () {
      assert.isFalse(popover.isDisplayed());
      footnoteLink.scrollIntoView();
      footnoteLink.moveTo();
      await popover.waitForDisplayed();
      assert.isTrue(popover.isDisplayed());
      Page.pause(100);
      await Page.click('body');
      Page.pause(200);
      assert.isFalse(popover.isDisplayed());
    });
    it('footnote popover should not disappear when the user clicks on it', async function () {
      assert.isFalse(popover.isDisplayed());
      footnoteLink.scrollIntoView();
      footnoteLink.moveTo();
      await popover.waitForDisplayed();
      assert.isTrue(popover.isDisplayed());
      await Page.pause(100);
      await Page.click('.popover');
      await Page.pause(200);
      assert.isTrue(popover.isDisplayed());
    });
    it('footnote popover should disappear when another one appears', async function () {
      assert.isFalse(popover.isDisplayed());
      const footnotes = Page.getElements('#content-inner a.note[href^="#fn\\:"][rel=footnote]');
      assert.equal(footnotes.length, 2);
      footnotes[0].scrollIntoView();
      footnotes[0].scrollIntoView();
      footnotes[0].moveTo();
      await popover.waitForDisplayed();
      const popoverText = await popover.getText();
      assert.isTrue(popover.isDisplayed());
      footnotes[1].scrollIntoView();
      footnotes[1].moveTo();
      await Page.pause(100);
      assert.isTrue(popover.isDisplayed());
      assert.notEqual(popoverText, await popover.getText());
    });
    it('footnote popover should disappear when the user clicks on its link', async function () {
      assert.isFalse(popover.isDisplayed());
      footnoteLink.scrollIntoView();
      footnoteLink.moveTo();
      await popover.waitForDisplayed();
      assert.isTrue(popover.isDisplayed());
      await Page.pause(100);
      await footNote.click('#content-inner a.note[href^="#fn\\:"][rel=footnote]');
      await Page.pause(200);
      assert.equal(Page.getElement('.popover').isDisplayed(), false);
    });
    it('page should scroll to a footnote when the user clicks on its link', function () {
      let footnote = Page.getElement(escape(footnoteLink.getAttribute('href')));
      footnoteLink.scrollIntoView();
      assert.isFalse(footnote.isDisplayedInViewport());
      footnoteLink.click();
      assert.isTrue(footnote.isDisplayedInViewport());
    });
  });

  describe('footnote popover look and behavior on touch devices', function () {
    let footnoteLink, footnoteModal, backlink;

    beforeEach(async function() {
      await Page.open('historicaldocuments/frus-history/introduction');
      let touchDetector = await Page.getElement('#touch-detector')
      await touchDetector.show();
      footnoteLink = await Page.getElement('#content-inner a.note[href^="#fn\\:"][rel=footnote]')
      footnoteModal = await Page.getElement('#footnote-modal')
      backlink = await Page.getElement('#footnote-modal .modal-body #footnote a.fn-back')
    });

    it('footnote popover should appear on tap', async function () {
      assert.isFalse(footnoteModal.isDisplayed());
      footnoteLink.scrollIntoView();
      footnoteLink.click();
      footnoteModal.waitForDisplayed()
      assert.isTrue(footnoteModal.isDisplayed());
    });
    it('footnote popover should not have the "back" link', function () {
      assert.isFalse(footnoteModal.isDisplayed());
      footnoteLink.scrollIntoView();
      footnoteLink.click();
      footnoteModal.waitForDisplayed()
      assert.isTrue(backlink.isExisting());
      assert.isFalse(backlink.isDisplayed());
    });
    it('footnote popover should disappear when the user taps outside of it', async function () {
      assert.isFalse(footnoteModal.isDisplayed());
      footnoteLink.scrollIntoView();
      footnoteLink.click();
      footnoteModal.waitForDisplayed()
      assert.isTrue(footnoteModal.isDisplayed());
      const body = await Page.getElement('body')
      await b.click({ x: 5, y: 5 });
      await Page.pause(200);
      assert.isFalse(footnoteModal.isDisplayed());
    });
    it('footnote popover should disappear when the user taps on the close button', async function () {
      assert.isFalse(footnoteModal.isDisplayed());
      footnoteLink.scrollIntoView();
      footnoteLink.click();
      footnoteModal.waitForDisplayed()
      assert.isTrue(footnoteModal.isDisplayed());
      const close = await Page.getElement('#footnote-modal .modal-header button.close')
      await close.click();
      await Page.pause(200);
      assert.isFalse(footnoteModal.isDisplayed());
    });
    it('footnote popover should disappear when the user taps on "View footnotes"', async function () {
      assert.isFalse(footnoteModal.isDisplayed());
      footnoteLink.scrollIntoView();
      footnoteLink.click();
      await Page.pause(200);
      assert.isFalse(footnoteModal.isDisplayed());
      const modalLink = await Page.getElement('#footnote-modal .modal-body #link a')
      modalLink.click();
      await Page.pause(200);
      assert.isFalse(footnoteModal.isDisplayed());
    });
    it('page should scroll to the footnotes section when the user taps on "View footnotes"', async function () {
      let footnote = Page.getElement('.footnotes');
      footnoteLink.scrollIntoView();
      assert.isFalse(footnote.isDisplayedInViewport());
      await footnoteLink.click();
      await Page.pause(200);
      const link = await Page.getElement('#footnote-modal .modal-body #link a')
      await link.click();
      assert.isTrue(footnote.isDisplayedInViewport());
    });
  });
});

