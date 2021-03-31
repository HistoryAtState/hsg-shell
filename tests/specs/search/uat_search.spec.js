/**
 * Checks search results
 */

const Page = require('../../pageobjects/Page'),
  SearchPage = require('../../pageobjects/SearchPage'),
  searchPhrases = ['Washington', 'United Nations'];

let firstResultHeadline = '.hsg-search-result > h3 > a';
let searchResult;

describe('Searching on home page', function () {
  let searchInput, submitButton;

  before(function () {
    Page.open();
    searchInput = Page.getElement('form input#search-box');
    searchInput.setValue(searchPhrases[0]);
    submitButton = Page.getElement('button[type="submit"]');
    submitButton.click();
  });

  it('should have results', function () {
    searchResult = Page.getElementText(firstResultHeadline);
    assert.exists(searchResult);
  });
});

searchPhrases.forEach(function (phrase) {
  describe('Searching for', function () {

    before(function () {
      Page.open('search?q=' + phrase);
    });

    it('"' + phrase + '" should have results', function () {
      searchResult = Page.getElementText(firstResultHeadline);
      assert.exists(searchResult);
    });
  });
});
