/**
 * Checks search results
 */

const searchPhrases = ['Washington', 'United Nations']

const firstResultHeadline = '.hsg-search-result > h3 > a'

describe('Searching on home page', function () {
  before(function () {
    cy.openPage()
    cy.get('form input#search-box').type(searchPhrases[0])
    cy.get('button[type="submit"]').click()
  })

  it('should have results', function () {
    cy.getElementText(firstResultHeadline).then((searchResult) => {
      expect(searchResult).to.exist
    })
  })
})

searchPhrases.forEach(function (phrase) {
  describe('Searching for', function () {
    before(function () {
      cy.openPage('search?q=' + phrase)
    })

    it('"' + phrase + '" should have results', function () {
      cy.getElementText(firstResultHeadline).then((searchResult) => {
        expect(searchResult).to.exist
      })
    })
  })
})