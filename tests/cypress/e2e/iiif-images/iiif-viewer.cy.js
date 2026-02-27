/**
 * IIIF image viewer (OpenSeadragon)
 */

describe('IIIF viewer', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments/frus1902app1/pg_11')
    cy.wait(500)
  })

  it('should be displayed in a IIIF viewer', function () {
    cy.get('.openseadragon-canvas > canvas').should('exist')
  })
})
