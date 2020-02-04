/**
 * Checks 404 error page
 */

const Page = require('../../pageobjects/Page');

describe('Requesting a non existing page', function () {
  it('should redirect to the 404 error page', function () {
    Page.open('asdfg');
    assert.include(Page.getTitle(), 'Page Not found');
  });
});




