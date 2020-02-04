var Page = require('./Page');
var NavigationPage = Object.create(Page, {

  /**
   * define elements
   */

  topMenuItems: {
    get: function () {
      return Page.getElements('ul.nav.navbar-nav li.dropdown');
    }
  },
  subMenuItems: {
    get: function () {
      return Page.getElements('ul.nav.navbar-nav ul.dropdown-menu li');
    }
  },

  /**
   * define or overwrite page methods
   */

  open: {
    value: function (item) {
      this.click(item);
    }
  }
});

module.exports = NavigationPage;
