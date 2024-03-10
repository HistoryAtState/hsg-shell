/**
 * Checks departmenthistory page type
 */

const Page  = require('../../pageobjects/Page')
const mainpage = { 
  link: 'countries', // 1st level subpage (landing)
  title: 'Countries'
};

describe('The "Countries" landing page', function () {
  it('should display a select input for choosing countries', async function () {
    await Page.open(mainpage.link);
    let select = await $('select[data-template="countries:load-countries"]');
    assert.exists(select);
  });

  // TODO: Check interacting with select input and choose countries
  // TODO: Check sidebar
});
