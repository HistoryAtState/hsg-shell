/**
 * Checks all frus subpage titles
 * and the functionality of the dropdown menu
 */

const Page  = require('../../pageobjects/Page')

const images = [
  Page.s3_Prod + '/images/alincoln.jpg',
  Page.s3_Prod + '/images/ajohnson.jpg',
  Page.s3_Prod + '/images/usgrant.jpg'
];

describe('FRUS landing page: The first 3 tiles', function () {
  before(function () {
    Page.open('historicaldocuments');
  });

  images.forEach(function (image, index) {
      describe('Each tile on the landing page', function () {
          it('should display an image', async function () {
              const imgSrc = Page.getElementAttribute('#content-inner div article:nth-child(' + (index + 1) + ') a img', 'src');
              assert.include(tile0, image);
          });
      });
  });
});
