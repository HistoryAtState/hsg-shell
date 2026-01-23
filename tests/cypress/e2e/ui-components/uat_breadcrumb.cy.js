/**
 * Checks UI component "breadcrumb"
 */

describe.skip('A breadcrumb', () => {
  before(() => {
    cy.openPage('historicaldocuments/frus-history/chapter-4')
  })

  // 1. Check, if rdf attributes render as expected
  // 1a. ol contains  vocab="http://schema.org/", typeof="BreadcrumbList", class="hsg-breadcrumb__list"
  it('should contain a list with rdf metadata', () => {
    cy.getElementAttribute('nav.hsg-breadcrumb ol', 'typeof').then((t) => {
      expect(t).to.equal('BreadcrumbList')
    })
    cy.getElementAttribute('nav.hsg-breadcrumb ol', 'vocab').then((v) => {
      expect(v).to.equal('http://schema.org/')
    })
  })

  // 1b. li contains class="hsg-breadcrumb__list-item", property="itemListElement", typeof="ListItem"
  it('should contain list-items with rdf metadata', () => {
    cy.getElementAttribute('nav.hsg-breadcrumb ol li', 'typeof').then((t) => {
      expect(t).to.equal('ListItem')
    })
    cy.getElementAttribute('nav.hsg-breadcrumb ol li', 'property').then((p) => {
      expect(p).to.equal('itemListElement')
    })
  })

  // 1c. a contains class="hsg-breadcrumb__link", property="item", typeof="WebPage"
  it('should contain links with rdf metadata', () => {
    cy.getElementAttribute('nav.hsg-breadcrumb ol li a', 'typeof').then((t) => {
      expect(t).to.equal('WebPage')
    })
    cy.getElementAttribute('nav.hsg-breadcrumb ol li a', 'property').then((p) => {
      expect(p).to.equal('item')
    })
  })

  // 2. Check, if aria attributes are rendered as expected
  // 2a. nav contains aria-label="breadcrumbs"
  it('should contain an aria-label in the nav element', () => {
    cy.getElementAttribute('nav.hsg-breadcrumb', 'aria-label').then((a) => {
      expect(a).to.equal('breadcrumbs')
    })
  })

  // 2b. link contains class="hsg-breadcrumb__link", aria-current="page"
  it('should contain an aria-current attribute in current (last) breadcrumb', () => {
    cy.get('nav.hsg-breadcrumb a[aria-current="page"]').should('exist')
  })

  // 3. Check if current page is highlightes with default text color
  it('should contain a last, current breadcrumb highlighted in normal text color #212121', () => {
    cy.getCssProperty('nav.hsg-breadcrumb a[aria-current="page"] span', 'color').then((c) => {
      expect(c.parsed.hex).to.equal('#212121')
    })
  })
})

describe.skip('A breadcrumb on small screens', () => {
  before(() => {
    cy.openPage('historicaldocuments/frus-history/chapter-4')
    cy.viewport(480, 800)
    cy.get('.hsg-breadcrumb__list-item:nth-last-child(2) .hsg-breadcrumb__link').should('be.visible')
  })

  // 4. Check, if only the parent level is rendered...
  it('should display the parent chapter breadcrumb', () => {
    cy.getElementText('.hsg-breadcrumb__list-item:nth-last-child(2) .hsg-breadcrumb__link span').then((t) => {
      expect(t).to.equal('History of the <em>Foreign Relations</em> Series')
    })
  })

  // ...with a left arrow on smaller screens.
  it('should display a "back" arrow before the parent chapter breadcrumb', () => {
    cy.getCssProperty('.hsg-breadcrumb__list-item:nth-last-child(2) .hsg-breadcrumb__link:before', '-webkit-mask').then((c) => {
      //console.log('c=', c);
      expect(c).to.equal('url(../images/arrow_back.svg) no-repeat center/contain;')
    })
  })
})