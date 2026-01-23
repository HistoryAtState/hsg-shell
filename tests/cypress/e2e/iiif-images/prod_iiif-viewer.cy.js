/**
 * Checks "IIIF image viewer"
 * Current implementation: https://openseadragon.github.io
 * Needs a running local IIIF image server!
 *
 */

const p1 = 'historicaldocuments/frus1902app1/pg_11'
const p2 = 'historicaldocuments/frus1902app1/pg_12'
const p3 = 'historicaldocuments/frus1902app1/pg_13'
const i1 = 'iiif/3/frus1902app1%2Ftiff%2F0021.tif'
const i2 = 'iiif/3/frus1902app1%2Ftiff%2F0021.tif'
const i3 = 'iiif/3/frus1902app1%2Ftiff%2F0021.tif'

// TODO: Catch Cantaloupe server response for requesting tif files
// TODO: Catch server response when browsing with side navigation, if correct images are served

describe('Requesting images from an external source (S3) via a IIIF server', () => {
  before(() => {
    cy.openPage(p1)
    cy.wait(500)
  })

  it('should be displayed in a IIIF viewer', () => {
    cy.get('.openseadragon-canvas > canvas').should('exist')
  })
})