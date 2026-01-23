/**
 * Checks all frus subpage titles
 * and the functionality of the dropdown menu
 */

const s3_Prod = 'https://static.history.state.gov'

const images = [
  s3_Prod + '/images/alincoln.jpg',
  s3_Prod + '/images/ajohnson.jpg',
  s3_Prod + '/images/usgrant.jpg'
]

describe('FRUS landing page: The first 3 tiles', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments')
  })

  it('should each contain an image', function () {
    cy.getElementAttribute('#content-inner div article:nth-child(1) a img', 'src').then((imgSrc0) => {
      expect(imgSrc0).to.include(images[0])
    })
    cy.getElementAttribute('#content-inner div article:nth-child(2) a img', 'src').then((imgSrc1) => {
      expect(imgSrc1).to.include(images[1])
    })
    cy.getElementAttribute('#content-inner div article:nth-child(3) a img', 'src').then((imgSrc2) => {
      expect(imgSrc2).to.include(images[2])
    })
  })
})