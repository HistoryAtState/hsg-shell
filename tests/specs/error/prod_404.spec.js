/**
 * Checks 404 error page
 */

const Page = require('../../pageobjects/Page');
//const assert = require('assert')
const { assert } = require('chai');

describe('Requesting a non existing page', () => {
  it('should redirect to the 404 error page', () => {
    Page.open('asdfg');
    assert.include(Page.getTitle(), 'Page Not found');
    console.log("Hallo")
  });
});
