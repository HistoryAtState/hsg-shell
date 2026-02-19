/**
 * Volume landing without cover image (frus1861-99Index)
 */

describe('Volume without cover', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments/frus1861-99Index')
    cy.get('#content-inner, #volume', { timeout: 10000 }).should('exist')
  })

  it('should NOT display a cover image', function () {
    cy.get('#volume #content-inner > img').should('not.exist')
  })

  it('should display a h1 heading', function () {
    cy.get('#content-inner > h1, #volume #content-inner > h1').first().invoke('text').then((title) => {
      expect(title.trim()).to.equal('General Index to the Published Volumes of the Diplomatic Correspondence and Foreign Relations of the United States, 1861–1899')
    })
  })

  it('should NOT display a h1 heading generated from TEI', function () {
    cy.get('body').then(($body) => {
      const $tei = $body.find('#volume .content h1, .content h1')
      const display = $tei.length ? window.getComputedStyle($tei[0]).display : 'none'
      expect(display).to.equal('none')
    })
  })
})
