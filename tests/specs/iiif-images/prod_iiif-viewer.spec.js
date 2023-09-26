/**
 * Checks "IIIF image viewer"
 * Current implementation: https://openseadragon.github.io
 * Needs a running local IIIF image server!
 *
 */

const Page = require('../../pageobjects/Page');

const p1     = 'historicaldocuments/frus1902app1/pg_11',
      p2     = 'historicaldocuments/frus1902app1/pg_12',
      p3     = 'historicaldocuments/frus1902app1/pg_13',
      i1     = 'iiif/3/frus1902app1%2Ftiff%2F0021.tif',
      i2     = 'iiif/3/frus1902app1%2Ftiff%2F0021.tif',
      i3     = 'iiif/3/frus1902app1%2Ftiff%2F0021.tif';

// TODO: Catch Cantaloupe server response for requesting tif files
// TODO: Catch server response when browsing with side navigation, if correct images are served

describe('Requesting images from an external source (S3) via a IIIF server', () => {
  let viewer
  before(async () => {
      await Page.open(p1);
      await Page.pause(500);
      viewer = await Page.getElement('.openseadragon-canvas > canvas');
  });

  it('should be displayed in a IIIF viewer', () => {
    assert.exists(viewer);
  });
});

