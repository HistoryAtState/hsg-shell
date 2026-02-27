/**
 * Search count and duration (expected indexes)
 */

const searchCount = '.hsg-search-section .search-count'
const searchDuration = '.hsg-search-section .search-duration'

const baseQs = { within: 'documents', 'start-date': '1940', 'end-date': '1960' }

describe('Search Indochina', function () {
  it('should display expected number of results', function () {
    cy.visit('search', { qs: { q: 'Indochina', ...baseQs, 'sort-by': 'date-asc' } })
    cy.get(searchCount).invoke('text').then((count) => {
      expect(count.replace(/,/, '')).to.equal('4512')
    })
  })

  it('should be performed within expected duration', function () {
    cy.visit('search', { qs: { q: 'Indochina', ...baseQs } })
    cy.get(searchDuration).invoke('text').then((duration) => {
      expect(parseFloat(duration)).to.be.below(1.000)
    })
  })
})

describe('Search Sudan', function () {
  it('should display expected number of results', function () {
    cy.visit('search', { qs: { q: 'Sudan', ...baseQs, 'sort-by': 'date-asc' } })
    cy.get(searchCount).invoke('text').then((count) => {
      expect(count.replace(/,/, '')).to.equal('723')
    })
  })

  it('should be performed within expected duration', function () {
    cy.visit('search', { qs: { q: 'Sudan', ...baseQs } })
    cy.get(searchDuration).invoke('text').then((duration) => {
      expect(parseFloat(duration)).to.be.below(1.000)
    })
  })
})

describe('Search China', function () {
  it('should display expected number of results', function () {
    cy.visit('search', { qs: { q: 'China', ...baseQs, 'sort-by': 'date-asc' } })
    cy.get(searchCount).invoke('text').then((count) => {
      expect(count.replace(/,/, '')).to.equal('20712')
    })
  })

  it('should be performed within expected duration', function () {
    cy.visit('search', { qs: { q: 'China', ...baseQs } })
    cy.get(searchDuration).invoke('text').then((duration) => {
      expect(parseFloat(duration)).to.be.below(1.000)
    })
  })
})

describe('Search Tokyo', function () {
  it('should display expected number of results', function () {
    cy.visit('search', { qs: { q: 'Tokyo', ...baseQs, 'sort-by': 'date-asc' } })
    cy.get(searchCount).invoke('text').then((count) => {
      expect(count.replace(/,/, '')).to.equal('5090')
    })
  })

  it('should be performed within expected duration', function () {
    cy.visit('search', { qs: { q: 'Tokyo', ...baseQs } })
    cy.get(searchDuration).invoke('text').then((duration) => {
      expect(parseFloat(duration)).to.be.below(1.000)
    })
  })
})
