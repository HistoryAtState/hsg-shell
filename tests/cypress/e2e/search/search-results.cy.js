/**
 * Search results by phrase
 */

const searchPhrases = ['Washington', 'United Nations']

searchPhrases.forEach(function (phrase) {
  describe('Search results: ' + phrase, function () {
    beforeEach(function () {
      cy.visit('search', { qs: { q: phrase } })
    })

    it('should have results', function () {
      cy.get('.hsg-search-result > h3 > a').should('exist').and('not.be.empty')
    })
  })
})
