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
    cy.get('#content-inner article', { timeout: 10000 }).should('have.length.at.least', 3)
  })

  images.forEach(function (image, index) {
    describe('Each tile on the landing page', function () {
      it('should display an image', function () {
        // Articles are inside #content-inner .row; use .hsg-thumbnail-wrapper and eq() for stable indexing
        cy.get('#content-inner .hsg-thumbnail-wrapper').eq(index).find('a img').invoke('attr', 'src').then((imgSrc) => {
          expect(imgSrc).to.include(image)
        })
      })
    })
  })
})