/**
 * Check search and filtering performance and compare with expected results
 */

const Page = require('../../pageobjects/Page'),
  SearchPage = require('../../pageobjects/SearchPage');

  
let searchCount  = '.hsg-search-section .search-count',
    searchDuration = '.hsg-search-section .search-duration';


describe('Search a keyword with filters "within=documents" and "date"', () => {
  let count, duration;

  // Keyword Indochina
  it('query "search?q=Indochina" should display the expected amount of 810 results', async () => {
    await Page.open("search?q=Indochina&within=documents&start-date=1950&end-date=1980&sort-by=date-asc");
    count = await Page.getElementText(searchCount);
    count = count.replace(/,/, '');
    console.log('count=', count);
    assert.equal(count, "4289", 'Current result did not match expected result');
  });

  it('query "search?q=Indochina" should be performed in less than 0.495 second', async () => {
    await Page.open('search?q=Indochina&within=documents&start-date=1950&end-date=1980');
    duration = await Page.getElementText(searchDuration)
    console.log('duration=', parseFloat(duration));
    assert.isTrue(parseFloat(duration) < 0.500, 'Current duration did not match expected duration');
  });

  // Keyword Sudan
  it('query "search?q=Sudan" should display the expected amount of 60 results', async () => {
    await Page.open("search?q=Sudan&within=documents&start-date=1950&end-date=1980&sort-by=date-asc");
    count = await Page.getElementText(searchCount);
    count = count.replace(/,/, '');
    console.log('count=', count);
    assert.equal(count, 1136, 'Current result did not match expected result');
  });

  it('query "search?q=Sudan" should be performed in less than 0.403 second', async () => {
    await Page.open('search?q=Sudan&within=documents&start-date=1950&end-date=1980');
    duration = await Page.getElementText(searchDuration)
    console.log('duration=', parseFloat(duration));
    assert.isTrue(parseFloat(duration) < 0.500, 'Current duration did not match expected duration');
  });

  // Keyword China
  it('query "search?q=China" should display the expected amount of 856 results', async () => {
    await Page.open("search?q=China&within=documents&start-date=1950&end-date=1980&sort-by=date-asc");
    count = await Page.getElementText(searchCount);
    count = count.replace(/,/, '');
    console.log('count=', count);
    assert.equal(count, 13775, 'Current result did not match expected result');
  });

  it('query "search?q=China" should be performed in less than 0.406 second', async () => {
    await Page.open('search?q=China&within=documents&start-date=1950&end-date=1980');
    duration = await Page.getElementText(searchDuration)
    console.log('duration=', parseFloat(duration));
    assert.isTrue(parseFloat(duration) < 0.500, 'Current duration did not match expected duration');
  });

  // Keyword Tokyo
  it('query "search?q=Tokyo" should display the expected amount of 101 results', async () => {
    await Page.open("search?q=Tokyo&within=documents&start-date=1950&end-date=1980&sort-by=date-asc");
    count = await Page.getElementText(searchCount);
    count = count.replace(/,/, '');
    console.log('count=', count);
    assert.equal(count, 3790, 'Current result did not match expected result');
  });

  it('query "search?q=Tokyo" should be performed in less than 0.474 second', async () => {
    await Page.open('search?q=Tokyo&within=documents&start-date=1950&end-date=1980');
    duration = await Page.getElementText(searchDuration)
    console.log('duration=', parseFloat(duration));
    assert.isTrue(parseFloat(duration) < 0.500, 'Current duration did not match expected duration');
  });

});

