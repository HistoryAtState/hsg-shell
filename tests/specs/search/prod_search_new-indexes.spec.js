/**
 * Check search and filtering performance and compare with expected results
 */

const Page = require('../../pageobjects/Page'),
  SearchPage = require('../../pageobjects/SearchPage');

const queries = [
    'search?q=Indochina',
    'search?q=Sudan',
    'search?q=China',
    'search?q=Tokyo'
  ],
  // results from prod server with old index conf
  expectedCount = [
    '810',
    '60',
    '856',
    '101'
  ],
  // results from prod server with old index conf
  expectedDuration = [
    '0.495',
    '0.403',
    '0.406',
    '0.474'
  ];

 const sortingOptions = [
    '&sort-by=relevance',
    '&sort-by=date-asc'
  ],

  filterWithvolumeIds = [
    '&volume-id=frus1951v05&volume-id=frus1952-54v02p2&volume-id=frus1952-54v07p1&volume-id=frus1952-54v13p1&volume-id=frus1952-54v14p1&volume-id=frus1961-63v01&volume-id=frus1977-80v22'
    ],

  filterOptions = [
    '&within=entire-site'
    ,'&within=documents'
    ,'&within=documents&start-date=1950&end-date=1980'
  ];

let searchCount  = '.hsg-search-section .search-count',
    searchDuration = '.hsg-search-section .search-duration';


describe('Search a keyword with filters "within=documents" and "date"', () => {
  let count, duration;

  // Keyword Indochina
  it('query "' + queries[0] + '" should display the expected amount of ' + expectedCount[0] + ' results', () => {
    Page.open(queries[0] + filterOptions[2] + sortingOptions[1]);
    count = Page.getElementText(searchCount);
    count = count.replace(/,/, '');
    console.log('count=', count);
    assert.isTrue(count = expectedCount[0], 'Current result did not match expected result');
  });

  it('query "' + queries[0] + '" should be performed in less than ' + expectedDuration[0] + ' second', () => {
    Page.open('search?q=Indochina&within=documents&start-date=1950&end-date=1980');
    duration = Page.getElementText(searchDuration)
    console.log('duration=', parseFloat(duration));
    assert.isTrue(parseFloat(duration) < expectedDuration[0], 'Current duration did not match expected duration');
  });

  // Keyword Sudan
  it('query "' + queries[1] + '" should display the expected amount of ' + expectedCount[1] + ' results', () => {
    Page.open(queries[1] + filterOptions[2] + sortingOptions[1]);
    count = Page.getElementText(searchCount);
    count = count.replace(/,/, '');
    console.log('count=', count);
    assert.isTrue(count = expectedCount[1], 'Current result did not match expected result');
  });

  it('query "' + queries[1] + '" should be performed in less than ' + expectedDuration[1] + ' second', () => {
    Page.open('search?q=Indochina&within=documents&start-date=1950&end-date=1980');
    duration = Page.getElementText(searchDuration)
    console.log('duration=', parseFloat(duration));
    assert.isTrue(parseFloat(duration) < expectedDuration[1], 'Current duration did not match expected duration');
  });

  // Keyword China
  it('query "' + queries[2] + '" should display the expected amount of ' + expectedCount[2] + ' results', () => {
    Page.open(queries[2] + filterOptions[2] + sortingOptions[1]);
    count = Page.getElementText(searchCount);
    count = count.replace(/,/, '');
    console.log('count=', count);
    assert.isTrue(count = expectedCount[2], 'Current result did not match expected result');
  });

  it('query "' + queries[2] + '" should be performed in less than ' + expectedDuration[2] + ' second', () => {
    Page.open('search?q=Indochina&within=documents&start-date=1950&end-date=1980');
    duration = Page.getElementText(searchDuration)
    console.log('duration=', parseFloat(duration));
    assert.isTrue(parseFloat(duration) < expectedDuration[2], 'Current duration did not match expected duration');
  });

  // Keyword Tokyo
  it('query "' + queries[3] + '" should display the expected amount of ' + expectedCount[3] + ' results', () => {
    Page.open(queries[3] + filterOptions[2] + sortingOptions[1]);
    count = Page.getElementText(searchCount);
    count = count.replace(/,/, '');
    console.log('count=', count);
    assert.isTrue(count = expectedCount[3], 'Current result did not match expected result');
  });

  it('query "' + queries[3] + '" should be performed in less than ' + expectedDuration[3] + ' second', () => {
    Page.open('search?q=Indochina&within=documents&start-date=1950&end-date=1980');
    duration = Page.getElementText(searchDuration)
    console.log('duration=', parseFloat(duration));
    assert.isTrue(parseFloat(duration) < expectedDuration[3], 'Current duration did not match expected duration');
  });

});

