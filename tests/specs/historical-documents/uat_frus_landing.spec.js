/**
 * Checks all frus subpage titles
 * and the functionality of the dropdown menu
 */

const Page  = require('../../pageobjects/Page'),
  SubPage   = require('../../pageobjects/SubPage');


const images = [
  Page.s3_UAT + '/images/alincoln.jpg',
  Page.s3_UAT + '/images/ajohnson.jpg',
  Page.s3_UAT + '/images/usgrant.jpg'
];

describe('FRUS landing page: The first 3 tiles', function () {
  let imageSrc, imageSelector;
  before(function () {
    Page.open('historicaldocuments');
  });

  /*
      images.forEach(function (image) {
          describe('Each tile on the landing page', function () {
              it('should display an image', function () {
                  imageSelector = Page.getElements('#content-inner div article a img');
                  imageSelector.value.forEach(function (elem) {
                      var imgSource = elem.elements('#content-inner div article a img').getHTML();
                      assert.include(imgSource, image);
                  });
              });
          });
      });
  */

  it('should each contain an image', function () {
    let tile0 = Page.getElementAttribute('#content-inner div article:nth-child(1) a img', 'src'),
      tile1 = Page.getElementAttribute('#content-inner div article:nth-child(2) a img', 'src'),
      tile2 = Page.getElementAttribute('#content-inner div article:nth-child(3) a img', 'src');
      assert.include(tile0, images[0]);
      assert.include(tile1, images[1]);
      assert.include(tile2, images[2]);
  });
});
