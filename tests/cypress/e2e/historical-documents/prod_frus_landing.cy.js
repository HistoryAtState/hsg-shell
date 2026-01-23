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
  before(function () {
    cy.openPage('historicaldocuments')
  })

  images.forEach(function (image, index) {
    describe('Each tile on the landing page', function () {
      it('should display an image', function () {
        cy.getElementAttribute('#content-inner div article:nth-child(' + (index + 1) + ') a img', 'src').then((imgSrc) => {
          expect(imgSrc).to.include(image)
        })
      })
    })
  })
})