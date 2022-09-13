/**
 * Checks if landing page has the correct title
 */

const Page = require('../../pageobjects/Page');

describe('HSG landing page', function () {
  it('should have the correct title', function () {
    Page.open();
    assert.include(Page.getTitle(), 'Latest News - Office of the Historian');
  });
});
