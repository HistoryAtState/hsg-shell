/**
 * Checks search results
 */

const searchPhrases = ['Washington', 'United Nations']

describe('Searching on home page', function () {
  before(function () {
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
  describe('Searching for', function () {
    before(function () {
      cy.visit('search?q=' + phrase)
    })

    it('"' + phrase + '" should have results', function () {
      cy.get('.hsg-search-result > h3 > a').should('exist').and('not.be.empty')
    })
  })
})