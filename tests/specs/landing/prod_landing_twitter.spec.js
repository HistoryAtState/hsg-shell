/**
 * Checks if twitter module is displaying tweets on landing page
 */

const Page = require('../../pageobjects/Page');

describe('The twitter section on the landing page', function () {
  it('should display at least one twitter post', async function () {
    await Page.open();
    let content = await Page.getElement('post-list .post:last-child p');
    assert.exists(content);
  });
});

