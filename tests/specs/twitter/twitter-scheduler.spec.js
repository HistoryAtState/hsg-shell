/**
 * Checks if the scheduled Twitter task is running correctly
 */

const Page = require('../../pageobjects/Page');

describe('The Twitter job "download-recent-twitter-posts.xq"', () => {
  let state, prev, next;

  before(() => {
    Page.open('verify-results-of-twitter-jobs.xq');
  });

  it('should return the state "NORMAL"', () => {
    state = Page.getElementText('#state');
    assert.equal(state, 'valid');
  });

  it('should have run within the past 10 minutes', () => {
    prev = Page.getElementText('#previous');
    assert.equal(prev, 'valid');
  });

  it('should start the next test run within the next 10 minutes', () => {
    next = Page.getElementText('#next');
    assert.equal(next, 'valid');
  });
});
