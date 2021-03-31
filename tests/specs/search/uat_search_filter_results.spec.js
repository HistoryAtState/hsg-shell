/**
 * Checks search and filtering results
 */

const Page = require('../../pageobjects/Page'),
  SearchPage = require('../../pageobjects/SearchPage'),
  query = 'search?q=china',
  sortingOptions = [
    '&sort-by=relevance',
    '&sort-by=date-asc'
  ],
  validFilterOptions = [
    '&within=entire-site'                                                             // 01. no filter
    ,'&within=department'                                                             // 02. filter within "Department History"
    ,'&within=documents'                                                              // 03. filter within "Historical Documents":
    ,'&within=documents&start-date=1946-02-01&end-date=1946-03-31'                    // 04. and start date 1946-02-01, end date 1946-03-31
    ,'&within=documents&start-date=1946&end-date=1946-03-31'                          // 05. or start date 1946, end date 1946-03-31
    ,'&within=documents&start-date=1946-02&end-date=1946-03-31'                       // 06. or start date 1946-02-xx, end date 1946-03-31
    ,'&within=documents&end-date=1946-01-31'                                          // 07. or start date xxxx-xx-01, end date 1946-03-31
    ,'&within=documents&start-date=1946-02-01&end-date=1946'                          // 08. or start date 1946-02-01, end date 1946-xx-xx
    ,'&within=documents&start-date=1946-02-01&end-date=1946-03'                       // 09. or start date 1946-02-01, end date 1946-03-xx
    ,'&within=documents&start-date=1946-01-02'                                        // 10. or start date 1946-02-01, end date xxxx-xx-xx
  ],

  invalidFilterOptions = [
    '&within=documents&start-date=1946-01-02&end-date=1945-01-01'                     // 11. filter within "Historical Documents" and start date > end date
    ,'&within=documents&start-date=1000-01-02&end-date=1000-01-01'                    // 12. or start date and end date out of scope
    // TODO: Fix this parameter result in the app, as must should not return any results, skipping this for now
    //,'&within=documents&within=department&start-date=1900-01-01&end-date=2019-01-01'  // 13. filter within "Historical Documents" plus valid date AND within "Department History"
  ];

let firstResultItem  = '.hsg-search-result > h3 > a',  // link containing the title of the search result
    noResultsMessage = '#content-inner > section > p'; // paragraph containing a static text "No results were found"

// Parameterized tests simply opening pages with valid parameters, sorted by relevance
validFilterOptions.forEach(function (parameters) {
  describe('Filtering search result for query "' + query + '" with valid parameters and sorted by "' + sortingOptions[0] + '"', function () {
    let searchResult;

      before(function () {
        Page.open(query + parameters + sortingOptions[0]);
        searchResult = Page.getElementText(firstResultItem);
      });

      it('"' + parameters + '" should return search results', function () {
        assert.exists(searchResult);
      });
    });
});

// Parameterized tests simply opening pages with valid parameters, sorted by ascending date
validFilterOptions.forEach(function (parameters) {
  describe('Filtering search result for query "' + query + '" with valid parameters and sorted by "' + sortingOptions[1] + '"' , function () {
    let searchResult;

      before(function () {
        Page.open(query + parameters + sortingOptions[1]);
        searchResult = Page.getElementText(firstResultItem);
      });

      it('"' + parameters + '" should return search results', function () {
        assert.exists(searchResult);
      });
    });
});

// Parameterized tests simply opening pages with invalid parameters
invalidFilterOptions.forEach(function (parameters) {

  describe('Filtering search result for query "' + query + '" with invalid parameters', function () {
    let searchResult, searchResultSection;

    before(function () {
      Page.open(query + parameters + sortingOptions[0]);
      searchResult = Page.getElementText(noResultsMessage);
      searchResultSection = Page.getElement('.hsg-search-section');
    });

    it('"' + parameters + '" should display the search page', function () {
      assert.exists(searchResultSection);
    });

    // TODO: Check for notifications instead after this feature has been implemented, this is only a workaround
    it('"' + parameters + '" should not return any search results', function () {
      assert.equal(Page.getElementText('#content-inner > section > p'), 'No results were found.', 'No results should be displayed for this search.');
    });
  });
});

// Todo 1. insert values in UI and test if they are serialized correctly
// Todo 2. insert values in UI and test form validation is working and responding with user notifications
// TODO 3. after update to WDIO 5.x Check // browser.assertRequests(), request.response.statusCode for checking http-status codes
