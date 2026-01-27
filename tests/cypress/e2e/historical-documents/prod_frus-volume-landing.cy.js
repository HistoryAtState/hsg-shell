/**
 * Checks the cover image of a volume landing page
 */

const s3_Prod = 'https://static.history.state.gov'

describe('Volume landing page frus1951-54IranEd2 with a cover image', () => {
  beforeEach(() => {
    cy.visit('historicaldocuments/frus1951-54IranEd2')
    cy.get('#volume', { timeout: 10000 }).should('exist')
  })

  it('should display a cover image loaded from S3 production bucket', () => {
    cy.get('#volume #content-inner > img').invoke('attr', 'src').then((src) => {
      expect(src).to.equal(s3_Prod + '/frus/frus1951-54IranEd2/covers/frus1951-54IranEd2.jpg')
    })
  })

  it('should display a cover image with an alt text attribute', () => {
    cy.get('#volume #content-inner > img').invoke('attr', 'alt').then((alt) => {
      expect(alt).to.equal('Book Cover of Foreign Relations of the United States, 1952–1954, Iran, 1951–1954, Second Edition')
    })
  })

  it('should display a h1 heading before the image', () => {
    cy.get('#volume #content-inner > h1').invoke('text').then((title) => {
      expect(title.trim()).to.equal('Foreign Relations of the United States, 1952–1954, Iran, 1951–1954, Second Edition')
    })
  })

  it('should NOT display a h1 heading generated from TEI', () => {
    cy.get('#volume .content h1').then(($el) => {
      const display = $el.length ? window.getComputedStyle($el[0]).display : 'none'
      expect(display).to.equal('none')
    })
  })
})

describe('Volume landing page "frus1861-99Index" without a cover image', () => {
  beforeEach(() => {
    cy.visit('historicaldocuments/frus1861-99Index')
    cy.get('#content-inner, #volume', { timeout: 10000 }).should('exist')
  })

  it('should NOT display a cover image', () => {
    cy.get('#volume #content-inner > img').should('not.exist')
  })

  it('should display a h1 heading before the image', () => {
    cy.get('#content-inner > h1, #volume #content-inner > h1').first().invoke('text').then((title) => {
      expect(title.trim()).to.equal('General Index to the Published Volumes of the Diplomatic Correspondence and Foreign Relations of the United States, 1861–1899')
    })
  })

  it('should NOT display a h1 heading generated from TEI', () => {
    cy.get('body').then(($body) => {
      const $tei = $body.find('#volume .content h1, .content h1')
      const display = $tei.length ? window.getComputedStyle($tei[0]).display : 'none'
      expect(display).to.equal('none')
    })
  })
})