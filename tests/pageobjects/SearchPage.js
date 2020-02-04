var Page = require('./Page');
var SearchPage = Object.create(Page, {

  RESULTS_PER_PAGE: {
    get: function () {
      return 10;
    }
  },

  /**
   * define elements
   */
  searchForm: {
    get: function () {
      return Page.getElement('#navigationSearchForm');
    }
  },
  searchTextField: {
    get: function () {
      return Page.getElement('#search-box');
    }
  },
  searchButton: {
    get: function () {
      return Page.getElement('#navigationSearchForm button[type="submit"]');
    }
  },
  resultText: {
    get: function () {
      return Page.getElementText('.hsg-search-results .hsg-search-section');
    }
  },
  getResultItems: {
    get: function () {
      return Page.getElements('.hsg-search-result');
    }
  },

  /**
   * define or overwrite page methods
   */
  searchFor: {
    value: function (searchString) {
      this.searchTextField.setValue(searchString);
      this.searchButton.click();
    }
  },

  filterBy: {
    value: function (filter) {
      // click on the checkbox ist not possible.
      // click on the icon ist possible.
      // icon is sibling '+i' of the checkbox.
      Page.click.call(this, '#sectionFilter input[type="checkbox"][name="' + filter.name + '"][value="' + filter.value + '"]+i');
    }
  },

  sortBy: {
    value: function (sortBy) {
      Page.click('button.hsg-sort-button');

      Page.pause(500);
      Page.click('#' + sortBy);
    }
  },

  open: {
    value: function (data) {
      Page.open.call(this, 'search?q=', data);
    }
  }
});

module.exports = SearchPage;
