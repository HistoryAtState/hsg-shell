/**
 * Checks if the scheduled Twitter task is running correctly
 */

const Page = require('../../pageobjects/Page');

describe('The Twitter job "download-recent-twitter-posts.xq"', () => {
  let state, prev, next;

  before(async () => {
    // Calling this script is forwarded by the hsg-shell controller
    await Page.open('validate-results-of-twitter-jobs.xq');
  });

  it('should return the state "NORMAL"', async () => {
    state = await Page.getElementText('#state');
    assert.equal(state, 'valid');
  });

  it('should have run within the past 10 minutes', async () => {
    prev = await Page.getElementText('#previous');
    assert.equal(prev, 'valid');
  });

  it('should start the next test run within the next 10 minutes', async () => {
    next = await Page.getElementText('#next');
    assert.equal(next, 'valid');
  });
});
