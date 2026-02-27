/**
 * Volume landing with cover image (frus1951-54IranEd2)
 */

const s3_Prod = 'https://static.history.state.gov'

describe('Volume with cover', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments/frus1951-54IranEd2')
    cy.get('#volume', { timeout: 10000 }).should('exist')
  })

  it('should display a cover image loaded from S3', function () {
    cy.get('#volume #content-inner > img').invoke('attr', 'src').then((src) => {
      expect(src).to.equal(s3_Prod + '/frus/frus1951-54IranEd2/covers/frus1951-54IranEd2.jpg')
    })
  })

  it('should display a cover image with an alt text attribute', function () {
    cy.get('#volume #content-inner > img').invoke('attr', 'alt').then((alt) => {
      expect(alt).to.equal('Book Cover of Foreign Relations of the United States, 1952–1954, Iran, 1951–1954, Second Edition')
    })
  })

  it('should display a h1 heading before the image', function () {
    cy.get('#volume #content-inner > h1').invoke('text').then((title) => {
      expect(title.trim()).to.equal('Foreign Relations of the United States, 1952–1954, Iran, 1951–1954, Second Edition')
    })
  })

  it('should NOT display a h1 heading generated from TEI', function () {
    cy.get('#volume .content h1').then(($el) => {
      const display = $el.length ? window.getComputedStyle($el[0]).display : 'none'
      expect(display).to.equal('none')
    })
  })
})
