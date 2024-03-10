function Page() {
  this.title = 'Office of the Historian';
  this.regex = /(\<|\/)[a-z]*>/gi;
  this.s3_Prod = 'https://static.history.state.gov';
  this.s3_UAT = 'https://static.test.history.state.gov';
}

Page.prototype.setViewPortSize = function (size) {
  return browser.setWindowSize(size);
};

Page.prototype.setMobileViewPortSize = function () {
  return browser.setWindowSize({width: 480, height: 740});
};

Page.prototype.setDesktopViewPortSize = function () {
  return browser.setWindowSize({width: 1200, height: 800});
};

Page.prototype.scroll = function (selector) {
  return $(selector).scrollIntoView()
};

Page.prototype.click = async function (selector) {
  return $(selector).click();
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
  return browser.url(url);
};

Page.prototype.pause = async function (timeInMs) {
  return browser.pause(timeInMs);
};

Page.prototype.waitForVisible = function (selector, timeInMs) {
  return $(selector).waitForDisplayed(timeInMs)
};

Page.prototype.waitForExist = function (selector, timeInMs) {
  return browser.waitForExist(selector, timeInMs);
};

Page.prototype.getElementCount = function (selector) {
  return browser.$$(selector).length;
};

Page.prototype.searchAll = async function (searchString) {
  await browser.element('#search-box').setValue(searchString);
  await browser.element('.hsg-link-button.search-button.btn').click();
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
  // console.log('Requested URI: ' + url);
  return browser.url(url);
};

Page.prototype.refresh = function () {
  return browser.refresh();
};

Page.prototype.getCookie = function (name) {
  return browser.getCookie(name);
};

module.exports = new Page();
