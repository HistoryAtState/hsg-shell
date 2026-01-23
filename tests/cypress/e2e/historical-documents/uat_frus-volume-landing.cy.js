/**
 * Checks the cover image of a volume landing page
 */

const s3_UAT = 'https://static.test.history.state.gov'

describe('Volume landing page frus1951-54IranEd2 with a cover image', () => {
  before(() => {
    cy.openPage('historicaldocuments/frus1951-54IranEd2')
  })

  it('should display an cover image loaded from S3 test bucket', () => {
    cy.getElementAttribute('#volume #content-inner > img', 'src').then((src) => {
      expect(src).to.equal(s3_UAT + '/frus/frus1951-54IranEd2/covers/frus1951-54IranEd2.jpg')
    })
  })

  it('should display an cover image with an alt text attribute', () => {
    cy.getElementAttribute('#volume img', 'alt').then((alt) => {
      expect(alt).to.equal('Book Cover of Foreign Relations of the United States, 1952-1954, Iran, 1951–1954, Second Edition')
    })
  })

  it('should display a h1 heading before the image', () => {
    cy.getElementText('#volume #content-inner > h1').then((title) => {
      expect(title).to.equal('Foreign Relations of the United States, 1952-1954, Iran, 1951–1954, Second Edition', 'No h1 rendered')
    })
  })

  it('should NOT display a h1 heading generated from TEI', () => {
    cy.getCssProperty('#volume .content h1', 'display').then((teiHeading) => {
      expect(teiHeading.value).to.equal('none', 'TEI heading is displayed')
    })
  })
})

describe('Volume landing page "frus1861-99Index" without a cover image', () => {
  before(() => {
    cy.openPage('historicaldocuments/frus1861-99Index')
  })

  it('should NOT display an cover image', () => {
    cy.get('#volume #content-inner > img').should('not.exist')
  })

  it('should display a h1 heading before the image', () => {
    cy.getElementText('#volume #content-inner > h1').then((title) => {
      expect(title).to.equal('General Index to the Published Volumes of the Diplomatic Correspondence and Foreign Relations of the United States, 1861–1899', 'No h1 rendered')
    })
  })

  it('should NOT display a h1 heading generated from TEI', () => {
    cy.getCssProperty('#volume .content h1', 'display').then((teiHeading) => {
      expect(teiHeading.value).to.equal('none', 'TEI heading is displayed')
    })
  })
})