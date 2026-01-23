/**
 * Checks search results
 */

const searchPhrases = ['Washington', 'United Nations']

describe('Searching on home page', function () {
  beforeEach(function () {
    // Use cy.visit() with relative path - baseUrl is configured in cypress.config.cjs
    cy.visit('/')
    cy.get('form input#search-box').type(searchPhrases[0])
    cy.get('button[type="submit"]').click()
  })

  it('should have results', function () {
    // Use Cypress's built-in commands directly - more idiomatic
    cy.get('.hsg-search-result > h3 > a').should('exist').and('not.be.empty')
  })
})

searchPhrases.forEach(function (phrase) {
  describe('Searching for "' + phrase + '"', function () {
    beforeEach(function () {
      // Use cy.visit() with relative path and query parameters
      // baseUrl is configured, so 'search' becomes 'http://localhost:8080/exist/apps/hsg-shell/search'
      cy.visit('search', {
        qs: { q: phrase }
      })
    })

    it('should have results', function () {
      cy.get('.hsg-search-result > h3 > a').should('exist').and('not.be.empty')
    })
  })
})