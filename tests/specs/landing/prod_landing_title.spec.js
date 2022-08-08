/**
 * Checks if landing page has the correct title
 */

const Page = require('../../pageobjects/Page');

describe('HSG landing page', function () {
  it('should have the correct title', function () {
    Page.open();
    console.log('url=', Page.getUrl());
    console.log('title=', Page.getTitle());
    assert.include(Page.getTitle(), 'Office of the Historian');
  });
});
