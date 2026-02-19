/**
 * Search form – submit and results
 */

describe('Search form', function () {
  it('should have results after searching', function () {
    cy.visit('/')
    cy.get('form input#search-box').type('Washington')
    cy.get('button[type="submit"]').click()
    cy.get('.hsg-search-result > h3 > a').should('exist').and('not.be.empty')
  })
})
