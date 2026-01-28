/**
 * Checks UI component "breadcrumb"
 */

describe('A breadcrumb', () => {
  beforeEach(() => {
    cy.visit('historicaldocuments/frus-history/chapter-4')
  })

  // 1. Check, if rdf attributes render as expected
  // 1a. ol contains  vocab="http://schema.org/", typeof="BreadcrumbList", class="hsg-breadcrumb__list"
  it('should contain a list with rdf metadata', () => {
    cy.get('nav.hsg-breadcrumb ol')
      .should('have.attr', 'typeof', 'BreadcrumbList')
      .and('have.attr', 'vocab', 'http://schema.org/')
  })

  // 1b. li contains class="hsg-breadcrumb__list-item", property="itemListElement", typeof="ListItem"
  it('should contain list-items with rdf metadata', () => {
    cy.get('nav.hsg-breadcrumb ol li')
      .first()
      .should('have.attr', 'typeof', 'ListItem')
      .and('have.attr', 'property', 'itemListElement')
  })

  // 1c. a contains class="hsg-breadcrumb__link", property="item", typeof="WebPage"
  it('should contain links with rdf metadata', () => {
    cy.get('nav.hsg-breadcrumb ol li a')
      .first()
      .should('have.attr', 'typeof', 'WebPage')
      .and('have.attr', 'property', 'item')
  })

  // 2. Check, if aria attributes are rendered as expected
  // 2a. nav contains aria-label="breadcrumbs"
  it('should contain an aria-label in the nav element', () => {
    cy.get('nav.hsg-breadcrumb')
      .should('have.attr', 'aria-label', 'breadcrumbs')
  })

  // 2b. link contains class="hsg-breadcrumb__link", aria-current="page"
  it('should contain an aria-current attribute in current (last) breadcrumb', () => {
    cy.get('nav.hsg-breadcrumb a[aria-current="page"]').should('exist')
  })

  // 3. Check if current page is highlightes with default text color
  it('should contain a last, current breadcrumb highlighted in normal text color #212121', () => {
    // #212121 → rgb(33, 33, 33)
    cy.get('nav.hsg-breadcrumb a[aria-current="page"] span')
      .should('have.css', 'color', 'rgb(33, 33, 33)')
  })
})

describe.skip('A breadcrumb on small screens', () => {
  beforeEach(() => {
    cy.visit('historicaldocuments/frus-history/chapter-4')
    cy.viewport(480, 800)
    cy.get('.hsg-breadcrumb__list-item:nth-last-child(2) .hsg-breadcrumb__link').should('be.visible')
  })

  // 4. Check, if only the parent level is rendered...
  it('should display the parent chapter breadcrumb', () => {
    cy.get('.hsg-breadcrumb__list-item:nth-last-child(2) .hsg-breadcrumb__link span')
      .invoke('html')
      .then((html) => {
        expect(html).to.equal('History of the <em>Foreign Relations</em> Series')
      })
  })

  // ...with a left arrow on smaller screens.
  it('should display a "back" arrow before the parent chapter breadcrumb', () => {
    cy.get('.hsg-breadcrumb__list-item:nth-last-child(2) .hsg-breadcrumb__link').then(($el) => {
      const style = window.getComputedStyle($el[0], '::before')
      const mask = style.getPropertyValue('-webkit-mask') || style.getPropertyValue('mask')
      expect(mask).to.contain('arrow_back.svg')
    })
  })
})