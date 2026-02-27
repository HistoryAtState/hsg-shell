/**
 * FRUS landing – tiles and dropdown headline
 */

describe('FRUS landing', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments')
  })

  it('should have at least 3 article tiles', function () {
    cy.get('#content-inner article', { timeout: 10000 }).should('have.length.at.least', 3)
  })

  it('should display tile 0 image', function () {
    cy.get('#content-inner .hsg-thumbnail-wrapper').eq(0).find('a img').invoke('attr', 'src').then((imgSrc) => {
      expect(imgSrc).to.include('https://static.history.state.gov/images/alincoln.jpg')
    })
  })

  it('should display tile 1 image', function () {
    cy.get('#content-inner .hsg-thumbnail-wrapper').eq(1).find('a img').invoke('attr', 'src').then((imgSrc) => {
      expect(imgSrc).to.include('https://static.history.state.gov/images/ajohnson.jpg')
    })
  })

  it('should display tile 2 image', function () {
    cy.get('#content-inner .hsg-thumbnail-wrapper').eq(2).find('a img').invoke('attr', 'src').then((imgSrc) => {
      expect(imgSrc).to.include('https://static.history.state.gov/images/usgrant.jpg')
    })
  })

  it('should open FRUS landing with headline after dropdown navigation', function () {
    cy.get('ul.nav.navbar-nav li:nth-child(2) > a').first().click()
    cy.get('ul.dropdown-menu li:nth-child(2)').should('be.visible')
    cy.get('ul.dropdown-menu li:nth-child(1) a').first().click()
    cy.get('#content-inner h1').invoke('text').then((title) => {
      expect(title).to.equal('Historical Documents')
    })
  })
})
