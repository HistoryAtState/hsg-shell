/**
 * Checks all frus subpage titles
 * and the functionality of the dropdown menu
 */

const s3_UAT = 'https://static.test.history.state.gov'

const images = [
  s3_UAT + '/images/alincoln.jpg',
  s3_UAT + '/images/ajohnson.jpg',
  s3_UAT + '/images/usgrant.jpg'
]

describe('FRUS landing page: The first 3 tiles', function () {
  before(function () {
    cy.openPage('historicaldocuments')
  })

  it('should each contain an image', function () {
    cy.getElementAttribute('#content-inner div article:nth-child(1) a img', 'src').then((tile0) => {
      expect(tile0).to.include(images[0])
    })
    cy.getElementAttribute('#content-inner div article:nth-child(2) a img', 'src').then((tile1) => {
      expect(tile1).to.include(images[1])
    })
    cy.getElementAttribute('#content-inner div article:nth-child(3) a img', 'src').then((tile2) => {
      expect(tile2).to.include(images[2])
    })
  })
})