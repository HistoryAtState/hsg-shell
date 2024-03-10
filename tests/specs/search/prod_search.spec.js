/**
 * Checks search results
 */

const Page = require('../../pageobjects/Page'),
  searchPhrases = ['Washington', 'United Nations'];

let firstResultHeadline = '.hsg-search-result > h3 > a';
let searchResult;

describe('Searching on home page', function () {
  let searchInput, submitButton;

  before(async function () {
    await Page.open();
    searchInput = await Page.getElement('form input#search-box');
    await searchInput.setValue(searchPhrases[0]);
    submitButton = await Page.getElement('button[type="submit"]');
    submitButton.click();
  });

  it('should have results', async function () {
    searchResult = await Page.getElementText(firstResultHeadline);
    assert.exists(searchResult);
  });
});

searchPhrases.forEach(function (phrase) {
  describe('Searching for', function () {

    before(async function () {
      await Page.open('search?q=' + phrase);
    });

    it('"' + phrase + '" should have results', async function () {
      searchResult = await Page.getElementText(firstResultHeadline);
      assert.exists(searchResult);
    });
  });
});
