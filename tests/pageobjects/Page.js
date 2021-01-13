function Page() {
  this.title = 'Office of the Historian';
  this.regex = /(\<|\/)[a-z]*>/gi;
  this.s3_Prod = 'https://static.history.state.gov';
  this.s3_UAT = 'https://test.static.history.state.gov';
}

Page.prototype.setViewPortSize = function (size) {
  browser.setWindowSize(size);
};

Page.prototype.setMobileViewPortSize = function () {
  browser.setWindowSize({width: 600, height: 800});
};

Page.prototype.setDesktopViewPortSize = function () {
  browser.setWindowSize({width: 1200, height: 800});
};

Page.prototype.scroll = function (selector) {
  $(selector).scrollIntoView()
};

Page.prototype.click = function (selector) {
  $(selector).click();
};

Page.prototype.getElement = function (selector) {
  return browser.$(selector);
};

Page.prototype.getElements = function (selector) {
  return browser.$$(selector);
};

Page.prototype.isElementExisting = function (selector) {
  return $(selector).isExisting()
};

Page.prototype.isElementVisible = function (selector) {
  return browser.isVisible(selector);
};

Page.prototype.isVisibleWithinViewport = function (selector) {

  /**
   * check if section is in viewport.
   */
  var isSectionInViewport = function (selector) {
    var elem = document.querySelector(selector);
    var rect = elem.getBoundingClientRect();
    var windowHeight = (window.innerHeight || document.documentElement.clientHeight);
    var windowWidth = (window.innerWidth || document.documentElement.clientWidth);

    var vertInView = (rect.top <= windowHeight) && ((rect.top + rect.height) >= 0);
    var horInView = (rect.left <= windowWidth) && ((rect.left + rect.width) >= 0);

    return (vertInView && horInView);
  };

  return browser.execute(isSectionInViewport, selector).value;

  // buggy
  //return browser.isVisibleWithinViewport(selector);
};

Page.prototype.getTitle = function () {
  return browser.getTitle();
};

Page.prototype.getElementText = function (selector) {
  return $(selector).getText();
};

Page.prototype.getElementAttribute = function (selector, attributeName) {
  return $(selector).getAttribute(attributeName);
};

Page.prototype.getUrl = function () {
  return browser.getUrl();
};

Page.prototype.getCssProperty = function (selector, cssProperty) {
  return $(selector).getCSSProperty(cssProperty);
};

Page.prototype.openUrl = function (url) {
  browser.url(url);
};

Page.prototype.pause = function (timeInMs) {
  browser.pause(timeInMs);
};

Page.prototype.waitForVisible = function (selector, timeInMs) {
  $(selector).waitForDisplayed(timeInMs)
};

Page.prototype.waitForExist = function (selector, timeInMs) {
  browser.waitForExist(selector, timeInMs);
};

Page.prototype.getElementCount = function (selector) {
  return browser.$$(selector).value.length;
};

Page.prototype.searchAll = function (searchString) {
  browser.element('#search-box').setValue(searchString);
  browser.element('.hsg-link-button.search-button.btn').click();
};

Page.prototype.getCookie = function (name) {
  return browser.getCookie(name);
};

function serializeParameters(data) {
  var p = [];

  for (var key in data) {
    var value = data[key];
    if (Array.isArray(value)) {
      value.forEach(function (v) {
        p.push(key + '=' + encodeURIComponent(v));
      });
    }
    else {
      p.push(key + '=' + encodeURIComponent(value));
    }
  }

  // prepend ?
  if (p.length) {
    return '?' + p.join('&');
  }

  return '';
}

Page.prototype.open = function (path, data) {
  var parameters = data || {};
  var stem = path || '';
  var url = process.env.WDIO_PREFIX + stem + serializeParameters(parameters);
  console.log('Requested URI: ' + url);
  browser.url(url);
};

Page.prototype.refresh = function () {
  browser.refresh();
};

Page.prototype.getCookie = function (name) {
  return browser.getCookie(name);
};

module.exports = new Page();
