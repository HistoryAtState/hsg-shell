/**
 * Check search and filtering performance and compare with expected results
 */

const searchCount = '.hsg-search-section .search-count'
const searchDuration = '.hsg-search-section .search-duration'

describe('Search a keyword with filters "within=documents" and "date"', () => {
  // Keyword Indochina
  it('query "search?q=Indochina" should display the expected number of results', () => {
    cy.visit('search?q=Indochina&within=documents&start-date=1940&end-date=1960&sort-by=date-asc')
    cy.getElementText(searchCount).then((count) => {
      const countNum = count.replace(/,/, '')
      console.log('count=', countNum)
      expect(countNum).to.equal('4512', 'Current result did not match expected result')
    })
  })

  it('query "search?q=Indochina" should be performed within expected duration', () => {
    cy.visit('search?q=Indochina&within=documents&start-date=1940&end-date=1960')
    cy.getElementText(searchDuration).then((duration) => {
      const durationNum = parseFloat(duration)
      console.log('duration=', durationNum)
      expect(durationNum).to.be.below(1.000, 'Current duration did not match expected duration')
    })
  })

  // Keyword Sudan
  it('query "search?q=Sudan" should display the expected number of results', () => {
    cy.visit('search?q=Sudan&within=documents&start-date=1940&end-date=1960&sort-by=date-asc')
    cy.getElementText(searchCount).then((count) => {
      const countNum = count.replace(/,/, '')
      console.log('count=', countNum)
      expect(countNum).to.equal('723', 'Current result did not match expected result')
    })
  })

  it('query "search?q=Sudan" should be performed within expected duration', () => {
    cy.visit('search?q=Sudan&within=documents&start-date=1940&end-date=1960')
    cy.getElementText(searchDuration).then((duration) => {
      const durationNum = parseFloat(duration)
      console.log('duration=', durationNum)
      expect(durationNum).to.be.below(1.000, 'Current duration did not match expected duration')
    })
  })

  // Keyword China
  it('query "search?q=China" should display the expected number of results', () => {
    cy.visit('search?q=China&within=documents&start-date=1940&end-date=1960&sort-by=date-asc')
    cy.getElementText(searchCount).then((count) => {
      const countNum = count.replace(/,/, '')
      console.log('count=', countNum)
      expect(countNum).to.equal('20712', 'Current result did not match expected result')
    })
  })

  it('query "search?q=China" should be performed within expected duration', () => {
    cy.visit('search?q=China&within=documents&start-date=1940&end-date=1960')
    cy.getElementText(searchDuration).then((duration) => {
      const durationNum = parseFloat(duration)
      console.log('duration=', durationNum)
      expect(durationNum).to.be.below(1.000, 'Current duration did not match expected duration')
    })
  })

  // Keyword Tokyo
  it('query "search?q=Tokyo" should display the expected amount of 101 results', () => {
    cy.visit('search?q=Tokyo&within=documents&start-date=1940&end-date=1960&sort-by=date-asc')
    cy.getElementText(searchCount).then((count) => {
      const countNum = count.replace(/,/, '')
      console.log('count=', countNum)
      expect(countNum).to.equal('5090', 'Current result did not match expected result')
    })
  })

  it('query "search?q=Tokyo" should be performed within expected duration', () => {
    cy.visit('search?q=Tokyo&within=documents&start-date=1940&end-date=1960')
    cy.getElementText(searchDuration).then((duration) => {
      const durationNum = parseFloat(duration)
      console.log('duration=', durationNum)
      expect(durationNum).to.be.below(1.000, 'Current duration did not match expected duration')
    })
  })
})