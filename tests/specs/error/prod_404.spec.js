/**
 * Checks 404 error page
 */

const Page = require('../../pageobjects/Page');

describe('Requesting a non existing page', () => {
  it('should redirect to the 404 error page', async () => {
    await Page.open('asdfg');
    assert.include(await Page.getTitle(), 'Page Not found - Office of the Historian');
  });
});
