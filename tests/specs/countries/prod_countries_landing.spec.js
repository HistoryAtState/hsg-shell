/**
 * Checks departmenthistory page type
 */

const Page  = require('../../pageobjects/Page'),
  SubPage   = require('../../pageobjects/SubPage');

const subpages = {
  links: {
    p1: 'countries' // 1st level subpage (landing)
  },
  titles: {
    p1: 'Countries'
  }
};

describe('The "Countries" landing page', function () {
  it('should display a select input for choosing countries', function () {
    Page.open(subpages.links.p1);
    let select = Page.getElement('select[data-template="countries:load-countries"]');
    assert.exists(select);
  });

  // TODO: Check interacting with select input and choose countries
  // TODO: Check sidebar
});
