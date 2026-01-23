/**
 * Checks UI component "tooltip"
 */

// These are currently the only occurrences of a tooltip in the project:
const tooltips = [
  {
    type: 'persons',
    pageURL: 'historicaldocuments/frus1981-88v13/d200',
    triggerSelector: 'a[href="persons#p_BLH_1"]',
    triggerLabel: 'Brown, Leslie H.'
  },
  {
    type: 'persons',
    pageURL: 'historicaldocuments/frus1981-88v13/d200',
    triggerSelector: 'a[href="persons#p_ELS_1"]',
    triggerLabel: 'Eagleburger, Lawrence S.'
  },
  {
    type: 'persons',
    pageURL: 'historicaldocuments/frus1981-88v13/d200',
    triggerSelector: 'a[href="persons#p_FDE_1"]',
    triggerLabel: 'Brown, Leslie H.'
  },
  {
    type: 'terms',
    pageURL: 'historicaldocuments/frus1981-88v13/d200',
    triggerSelector: 'a[href="terms#t_AFB_1"]',
    triggerLabel: 'AFB'
  }
]

tooltips.forEach((tooltip) => {
  describe('A link with tooltip type: "' + tooltip.type + '" , label: "' + tooltip.triggerLabel + '"', () => {
    const el = 'div[data-template="frus:facets"] ' + tooltip.triggerSelector
    const ttSelector = '.tooltip'

    before(() => {
      cy.wait(1500)
      cy.openPage(tooltip.pageURL)
      cy.wait(1000)
    })

    // Check if tooltip trigger has tabindex
    it('should contain attribute tabindex="0"', () => {
      cy.getElementAttribute(el, 'tabindex').then((hasTabindex) => {
        expect(hasTabindex).to.equal('0')
      })
    })

    // Check if tooltip opens on hover
    it('should display a tooltip on hovering the element', () => {
      cy.get(ttSelector).should('not.be.visible')
      cy.get(el).scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' })
      cy.wait(1500)
      cy.get(el).trigger('mouseenter', { force: true })
      cy.wait(1500)
      cy.get(ttSelector).should('be.visible')
    })

    // Check if tooltip content is identical with the trigger title content
    it('should display its title as the tooltip content', () => {
      cy.getElementAttribute(el, 'data-original-title').then((title) => {
        cy.getElementText(ttSelector).then((ttContent) => {
          console.log('ttContent: ', ttContent)
          expect(ttContent).to.equal(title)
        })
      })
    })

    // Check if tooltip contains role="tooltip"
    it('should display a tooltip with attribute "role=tooltip"', () => {
      cy.getElementAttribute(ttSelector, 'role').then((hasRole) => {
        expect(hasRole).to.equal('tooltip')
      })
    })

    // Check if USWDS css properties are applied (== Bootstrap overrides)
    it('should display a tooltip with correct USWDS CSS properties', () => {
      const ttInnerSelector = '.tooltip-inner'
      cy.getCssProperty(ttInnerSelector, 'color').then((color) => {
        expect(color.value).to.equal('rgba(240,240,240,1)')
      })
      cy.getCssProperty(ttInnerSelector, 'background-color').then((background) => {
        expect(background.value).to.equal('rgba(27,27,27,1)')
      })
      cy.getCssProperty(ttInnerSelector, 'font-size').then((fontSize) => {
        expect(fontSize.value).to.equal('16.5px')
      })
      cy.getCssProperty(ttInnerSelector, 'padding').then((padding) => {
        expect(padding.value).to.equal('8px')
      })
    })
  })
})