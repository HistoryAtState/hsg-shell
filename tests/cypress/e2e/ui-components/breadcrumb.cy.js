/**
 * Breadcrumb UI component (rdf, aria, styling)
 */

describe('Breadcrumb', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments/frus-history/chapter-4')
  })

  it('should contain a list with rdf metadata', function () {
    cy.get('nav.hsg-breadcrumb ol')
      .should('have.attr', 'typeof', 'BreadcrumbList')
      .and('have.attr', 'vocab', 'http://schema.org/')
  })

  it('should contain list-items with rdf metadata', function () {
    cy.get('nav.hsg-breadcrumb ol li')
      .first()
      .should('have.attr', 'typeof', 'ListItem')
      .and('have.attr', 'property', 'itemListElement')
  })

  it('should contain links with rdf metadata', function () {
    cy.get('nav.hsg-breadcrumb ol li a')
      .first()
      .should('have.attr', 'typeof', 'WebPage')
      .and('have.attr', 'property', 'item')
  })

  it('should contain an aria-label in the nav element', function () {
    cy.get('nav.hsg-breadcrumb').should('have.attr', 'aria-label', 'breadcrumbs')
  })

  it('should contain an aria-current attribute in current breadcrumb', function () {
    cy.get('nav.hsg-breadcrumb a[aria-current="page"]').should('exist')
  })

  it('should highlight current breadcrumb in normal text color', function () {
    cy.get('nav.hsg-breadcrumb a[aria-current="page"] span')
      .should('have.css', 'color', 'rgb(33, 33, 33)')
  })
})

describe.skip('Breadcrumb on small screens', function () {
  beforeEach(function () {
    cy.visit('historicaldocuments/frus-history/chapter-4')
    cy.viewport(480, 800)
    cy.get('.hsg-breadcrumb__list-item:nth-last-child(2) .hsg-breadcrumb__link').should('be.visible')
  })

  it('should display the parent chapter breadcrumb', function () {
    cy.get('.hsg-breadcrumb__list-item:nth-last-child(2) .hsg-breadcrumb__link span')
      .invoke('html')
      .then((html) => {
        expect(html).to.equal('History of the <em>Foreign Relations</em> Series')
      })
  })

  it('should display a "back" arrow before the parent chapter breadcrumb', function () {
    cy.get('.hsg-breadcrumb__list-item:nth-last-child(2) .hsg-breadcrumb__link').then(($el) => {
      const style = window.getComputedStyle($el[0], '::before')
      const mask = style.getPropertyValue('-webkit-mask') || style.getPropertyValue('mask')
      expect(mask).to.contain('arrow_back.svg')
    })
  })
})
