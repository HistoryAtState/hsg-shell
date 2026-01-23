/**
 * Checks footnote popover
 */

function escape (value) {
  return value.replace(/([\.:])/g, '\\$1')
}

describe('footnote popover', function () {
  describe('footnote popover looks and behavior on desktop', function () {
    beforeEach(function () {
      cy.openPage('historicaldocuments/frus-history/introduction')
      cy.window().then((win) => {
        win.$('#touch-detector').hide()
      })
    })

    it('should have a footnote', function () {
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').then(($footnoteLink) => {
        expect($footnoteLink.text()).to.equal('1')
        const href = $footnoteLink.attr('href')
        cy.get(escape(href)).then(($footnote) => {
          expect($footnote.attr('value')).to.equal('1')
          expect($footnote.attr('class')).to.include('footnote')
        })
      })
    })

    it('footnote popover should appear on hover', function () {
      cy.get('.popover').should('not.be.visible')
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' })
      cy.wait(2000)
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').trigger('mouseenter', { force: true })
      cy.wait(2000)
      cy.get('.popover').should('be.visible')
    })

    it('footnote popover should not have the "back" link', function () {
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' })
      cy.get('.popover').should('not.be.visible')
      cy.wait(2000)
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').trigger('mouseenter', { force: true })
      cy.wait(2000)
      cy.get('.popover').should('be.visible')
      cy.get('.popover .footnote-body a.fn-back').should('not.be.visible')
    })

    it('footnote popover should not disappear with the cursor on it', function () {
      cy.get('.popover').should('not.be.visible')
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' })
      cy.wait(2000)
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').trigger('mouseenter', { force: true })
      cy.wait(2000)
      cy.get('.popover').should('be.visible')
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').trigger('mousemove', { offsetX: 1, offsetY: 10 })
      cy.wait(2000)
      cy.get('.popover').should('be.visible')
    })

    it('footnote popover should disappear when the cursor leaves', function () {
      cy.get('.popover').should('not.be.visible')
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' })
      cy.wait(2000)
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').trigger('mouseenter', { force: true })
      cy.get('.popover').should('be.visible')
      cy.wait(100)
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').trigger('mouseleave')
      cy.wait(2000)
      cy.get('.popover').should('not.be.visible')
    })

    it('footnote popover should not disappear when the cursor leaves for a brief moment', function () {
      cy.get('.popover').should('not.be.visible')
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' })
      cy.wait(1000)
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').trigger('mouseenter', { force: true })
      cy.get('.popover').should('be.visible')
      cy.wait(100)
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').trigger('mouseleave')
      cy.wait(200)
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').trigger('mouseenter', { force: true })
      cy.wait(1000)
      cy.get('.popover').should('be.visible')
    })

    it('footnote popover should disappear when the user clicks outside', function () {
      cy.get('.popover').should('not.be.visible')
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' })
      cy.wait(1000)
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').trigger('mouseenter', { force: true })
      cy.wait(1000)
      cy.get('.popover').should('be.visible')
      cy.wait(100)
      cy.get('body').click(100, 100)
      cy.wait(200)
      cy.get('.popover').should('not.be.visible')
    })

    it.skip('footnote popover should not disappear when the user clicks on it', function () {
      cy.get('.popover').should('not.be.visible')
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' })
      cy.wait(1000)
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').trigger('mouseenter', { force: true })
      cy.get('.popover').should('be.visible')
      cy.wait(1000)
      cy.get('.popover').click()
      cy.wait(1000)
      cy.get('.popover').should('be.visible')
    })

    it.skip('footnote popover should disappear when another one appears', function () {
      cy.get('.popover').should('not.be.visible')
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').should('have.length.at.least', 2)
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').first().scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' })
      cy.wait(1000)
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').first().trigger('mouseenter', { force: true })
      cy.get('.popover').should('be.visible')
      cy.get('.popover').invoke('text').then((popoverText1) => {
        cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').eq(1).scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' })
        cy.wait(1000)
        cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').eq(1).trigger('mouseenter', { force: true })
        cy.wait(100)
        cy.get('.popover').should('be.visible')
        cy.get('.popover').invoke('text').then((popoverText2) => {
          expect(popoverText2).to.not.equal(popoverText1)
        })
      })
    })

    it.skip('footnote popover should disappear when the user clicks on its link', function () {
      cy.get('.popover').should('not.be.visible')
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' })
      cy.wait(1000)
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').trigger('mouseenter', { force: true })
      cy.get('.popover').should('be.visible')
      cy.wait(100)
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').click()
      cy.wait(200)
      cy.get('.popover').should('not.be.visible')
    })

    it('page should scroll to a footnote when the user clicks on its link', function () {
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').then(($footnoteLink) => {
        const href = $footnoteLink.attr('href')
        cy.get(escape(href)).then(() => {
          cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' })
          cy.wait(1000)
          cy.isVisibleWithinViewport(escape(href)).then((isVisible) => {
            expect(isVisible).to.be.false
          })
          cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').click()
          cy.isVisibleWithinViewport(escape(href)).then((isVisible) => {
            expect(isVisible).to.be.true
          })
        })
      })
    })
  })

  describe('footnote popover looks and behavior on touch devices', function () {
    beforeEach(function () {
      cy.openPage('historicaldocuments/frus-history/introduction')
      cy.window().then((win) => {
        win.$('#touch-detector').show()
      })
    })

    it('footnote popover should appear on tap', function () {
      cy.get('#footnote-modal').should('not.be.visible')
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView()
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').click()
      cy.get('#footnote-modal').should('be.visible')
    })

    it('footnote popover should not have the "back" link', function () {
      cy.get('#footnote-modal').should('not.be.visible')
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView()
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').click()
      cy.get('#footnote-modal').should('be.visible')
      cy.get('#footnote-modal .modal-body #footnote a.fn-back').should('exist')
      cy.get('#footnote-modal .modal-body #footnote a.fn-back').should('not.be.visible')
    })

    it('footnote popover should disappear when the user taps outside of it', function () {
      cy.get('#footnote-modal').should('not.be.visible')
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView()
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').click()
      cy.get('#footnote-modal').should('be.visible')
      cy.get('body').click(5, 5)
      cy.wait(200)
      cy.get('#footnote-modal').should('not.be.visible')
    })

    it('footnote popover should disappear when the user taps on the close button', function () {
      cy.get('#footnote-modal').should('not.be.visible')
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView()
      cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').click()
      cy.get('#footnote-modal').should('be.visible')
      cy.get('#footnote-modal .modal-header button.close').click()
      cy.wait(200)
      cy.get('#footnote-modal').should('not.be.visible')
    })

    it('footnote popover should disappear when the user taps on "View footnotes"', function () {
      cy.get('.footnotes').then(() => {
        cy.get('#footnote-modal').should('not.be.visible')
        cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView()
        cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').click()
        cy.wait(200)
        cy.get('#footnote-modal').should('be.visible')
        cy.get('#footnote-modal .modal-body #link a').click()
        cy.wait(200)
        cy.get('#footnote-modal').should('not.be.visible')
      })
    })

    it('page should scroll to the footnotes section when the user taps on "View footnotes"', function () {
      cy.get('.footnotes').then(() => {
        cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').scrollIntoView()
        cy.isVisibleWithinViewport('.footnotes').then((isVisible) => {
          expect(isVisible).to.be.false
        })
        cy.get('#content-inner a.note[href^="#fn\\:"][rel=footnote]').click()
        cy.wait(200)
        cy.get('#footnote-modal .modal-body #link a').click()
        cy.isVisibleWithinViewport('.footnotes').then((isVisible) => {
          expect(isVisible).to.be.true
        })
      })
    })
  })
})