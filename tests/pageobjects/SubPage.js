/**
 * Sub Pages (FRUS, Department History, ...)
 */

const Page = require('./Page');

const SubPage = Object.create(Page, {

  /**
   * define elements
   */

  headline_h1: {
    get: function () {
      return '#content-inner h1';
    }
  },

  headline_h2: {
    get: function () {
      return '#content-inner h2';
    }
  },

  headline_h3: {
    get: function () {
      return '#content-inner h3';
    }
  },

  /**
   * define or overwrite page methods
   */
  getHeadline_h1: {
    value: function () {
      Page.getElementText(this.headline_h1);
    }
  }
});

module.exports = SubPage;
