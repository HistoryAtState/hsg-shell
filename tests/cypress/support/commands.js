// ***********************************************
// Custom Cypress commands converted from WebdriverIO Page Objects
// ***********************************************
//
// IMPORTANT: Cypress Best Practices
//
// 1. Use cy.visit() directly in beforeEach hooks, not custom commands:
//    ✅ beforeEach(() => { cy.visit('/path') })
//    ❌ beforeEach(() => { cy.openPage('path') })
//
// 2. Use Cypress built-in commands directly:
//    ✅ cy.get(selector).invoke('text')
//    ✅ cy.get(selector).invoke('attr', 'href')
//    ✅ cy.get(selector).scrollIntoView()
//    ❌ cy.getElementText(selector)
//    ❌ cy.getElementAttribute(selector, 'href')
//    ❌ cy.scrollIntoView(selector) // ERROR: scrollIntoView is already a Cypress command
//
// 3. Use baseUrl from cypress.config.cjs:
//    - baseUrl: 'http://localhost:8080/exist/apps/hsg-shell'
//    - cy.visit('/') → visits baseUrl
//    - cy.visit('search') → visits baseUrl + '/search'
//    - cy.visit('/search') → visits http://localhost:8080/search (absolute, wrong!)
//
// 4. Chain assertions for better readability:
//    ✅ cy.get('.result').should('exist').and('not.be.empty')
//    ❌ cy.get('.result').should('exist'); cy.get('.result').should('not.be.empty')
//
// These custom commands are kept for backward compatibility but should be
// gradually replaced with idiomatic Cypress patterns in new tests.

/**
 * Serialize parameters object to query string
 */
function serializeParameters(data) {
  const params = []
  for (const key in data) {
    const value = data[key]
    if (Array.isArray(value)) {
      value.forEach((v) => {
        params.push(key + '=' + encodeURIComponent(v))
      })
    } else {
      params.push(key + '=' + encodeURIComponent(value))
    }
  }
  if (params.length) {
    return '?' + params.join('&')
  }
  return ''
}

/**
 * Open a page with optional query parameters
 * Uses baseUrl from cypress.config.cjs, so just pass the path
 * Example: cy.visit('/exist/apps/hsg-shell/') or cy.visit('/exist/apps/hsg-shell/search?q=test')
 * For query params, use: cy.visit('/exist/apps/hsg-shell/search', { qs: { q: 'test' } })
 * 
 * This command is kept for backward compatibility but consider using cy.visit() directly
 */
Cypress.Commands.add('openPage', (path = '', data = {}) => {
  const prefix = Cypress.env('prefix') || '/exist/apps/hsg-shell/'
  const url = prefix + path + serializeParameters(data)
  cy.visit(url)
})

/**
 * Get element text
 * Note: Prefer using cy.get(selector).invoke('text') or cy.get(selector).should('have.text', ...) directly
 * This is kept for backward compatibility
 */
Cypress.Commands.add('getElementText', (selector) => {
  return cy.get(selector).invoke('text')
})

/**
 * Get element attribute
 * Note: Prefer using cy.get(selector).invoke('attr', name) directly
 * This is kept for backward compatibility
 */
Cypress.Commands.add('getElementAttribute', (selector, attributeName) => {
  return cy.get(selector).invoke('attr', attributeName)
})

/**
 * Get CSS property value
 * Equivalent to Page.getCssProperty(selector, cssProperty)
 */
Cypress.Commands.add('getCssProperty', (selector, cssProperty) => {
  return cy.get(selector).then(($el) => {
    const computedStyle = window.getComputedStyle($el[0])
    // Try both kebab-case and camelCase
    let value = computedStyle.getPropertyValue(cssProperty)
    if (!value) {
      // Convert kebab-case to camelCase
      const camelCase = cssProperty.replace(/-([a-z])/g, (g) => g[1].toUpperCase())
      value = computedStyle[camelCase] || computedStyle.getPropertyValue(cssProperty)
    }
    
    // Convert rgb/rgba to hex if needed
    let hex = value
    if (value && value.match(/^rgba?\(/)) {
      const rgb = value.match(/\d+/g)
      if (rgb && rgb.length >= 3) {
        hex = '#' + rgb.slice(0, 3).map(x => {
          const hex = parseInt(x).toString(16)
          return hex.length === 1 ? '0' + hex : hex
        }).join('')
      }
    }
    
    return { value, parsed: { hex: hex || value } }
  })
})

/**
 * Check if element is visible within viewport
 * Equivalent to Page.isVisibleWithinViewport(selector)
 */
Cypress.Commands.add('isVisibleWithinViewport', (selector) => {
  return cy.get(selector).then(($el) => {
    const rect = $el[0].getBoundingClientRect()
    const windowHeight = window.innerHeight || document.documentElement.clientHeight
    const windowWidth = window.innerWidth || document.documentElement.clientWidth

    const vertInView = (rect.top <= windowHeight) && ((rect.top + rect.height) >= 0)
    const horInView = (rect.left <= windowWidth) && ((rect.left + rect.width) >= 0)

    return vertInView && horInView
  })
})

/**
 * Search functionality
 * Equivalent to Page.searchAll(searchString)
 */
Cypress.Commands.add('searchAll', (searchString) => {
  cy.get('#search-box').type(searchString)
  cy.get('.hsg-link-button.search-button.btn').click()
})

/**
 * Set mobile viewport size
 * Equivalent to Page.setMobileViewPortSize()
 */
Cypress.Commands.add('setMobileViewport', () => {
  cy.viewport(480, 740)
})

/**
 * Set desktop viewport size
 * Equivalent to Page.setDesktopViewPortSize()
 */
Cypress.Commands.add('setDesktopViewport', () => {
  cy.viewport(1200, 800)
})

// Note: scrollIntoView is already a Cypress command, use cy.get(selector).scrollIntoView() directly

/**
 * Wait for element to be visible (with timeout)
 * Equivalent to Page.waitForVisible(selector, timeInMs)
 */
Cypress.Commands.add('waitForVisible', (selector, timeout = 10000) => {
  cy.get(selector, { timeout }).should('be.visible')
}, { prevSubject: false })

/**
 * Get element count
 * Equivalent to Page.getElementCount(selector)
 */
Cypress.Commands.add('getElementCount', (selector) => {
  return cy.get(selector).then(($el) => $el.length)
})

// SearchPage commands

/**
 * Search for a term
 * Equivalent to SearchPage.searchFor(searchString)
 */
Cypress.Commands.add('searchFor', (searchString) => {
  cy.get('#search-box').type(searchString)
  cy.get('#navigationSearchForm button[type="submit"]').click()
})

/**
 * Filter search results
 * Equivalent to SearchPage.filterBy(filter)
 */
Cypress.Commands.add('filterBy', (filter) => {
  // Click on the icon (sibling '+i' of the checkbox)
  cy.get(`#sectionFilter input[type="checkbox"][name="${filter.name}"][value="${filter.value}"]+i`).click()
})

/**
 * Sort search results
 * Equivalent to SearchPage.sortBy(sortBy)
 */
Cypress.Commands.add('sortBy', (sortBy) => {
  cy.get('button.hsg-sort-button').click()
  cy.wait(500)
  cy.get(`#${sortBy}`).click()
})

// SubPage commands

/**
 * Get H1 headline text
 * Equivalent to SubPage.getHeadline_h1()
 */
Cypress.Commands.add('getHeadlineH1', () => {
  return cy.get('#content-inner h1').invoke('text')
})

/**
 * Get H2 headline text
 */
Cypress.Commands.add('getHeadlineH2', () => {
  return cy.get('#content-inner h2').invoke('text')
})

/**
 * Get H3 headline text
 */
Cypress.Commands.add('getHeadlineH3', () => {
  return cy.get('#content-inner h3').invoke('text')
})

// NavigationPage commands

/**
 * Get top menu items
 * Equivalent to NavigationPage.topMenuItems
 */
Cypress.Commands.add('getTopMenuItems', () => {
  return cy.get('ul.nav.navbar-nav li.dropdown')
})

/**
 * Get sub menu items
 * Equivalent to NavigationPage.subMenuItems
 */
Cypress.Commands.add('getSubMenuItems', () => {
  return cy.get('ul.nav.navbar-nav ul.dropdown-menu li')
})