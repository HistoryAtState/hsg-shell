/**
 * Search filter and sort options (parameterized)
 */

const basePath = 'search'
const baseQuery = { q: 'china' }
const sortingOptions = [
  { label: 'relevance', qs: { 'sort-by': 'relevance' } },
  { label: 'date-asc', qs: { 'sort-by': 'date-asc' } }
]

const validFilterOptions = [
  { label: 'entire-site', qs: { within: 'entire-site' } },
  { label: 'department', qs: { within: 'department' } },
  { label: 'documents', qs: { within: 'documents' } },
  { label: 'documents+dates', qs: { within: 'documents', 'start-date': '1946-02-01', 'end-date': '1946-03-31' } },
  { label: 'documents+year', qs: { within: 'documents', 'start-date': '1946', 'end-date': '1946-03-31' } },
  { label: 'documents+month', qs: { within: 'documents', 'start-date': '1946-02', 'end-date': '1946-03-31' } },
  { label: 'documents+end', qs: { within: 'documents', 'end-date': '1946-01-31' } },
  { label: 'documents+range', qs: { within: 'documents', 'start-date': '1946-02-01', 'end-date': '1946' } },
  { label: 'documents+range-month', qs: { within: 'documents', 'start-date': '1946-02-01', 'end-date': '1946-03' } },
  { label: 'documents+start-only', qs: { within: 'documents', 'start-date': '1946-01-02' } }
]

const invalidFilterOptions = [
  { label: 'start-gt-end', qs: { within: 'documents', 'start-date': '1946-01-02', 'end-date': '1945-01-01' } },
  { label: 'dates-out-of-scope', qs: { within: 'documents', 'start-date': '1000-01-02', 'end-date': '1000-01-01' } }
]

const firstResultItem = '.hsg-search-result > h3 > a'

validFilterOptions.forEach(function (filter) {
  sortingOptions.forEach(function (sort) {
    describe('Filter ' + filter.label + ' sort ' + sort.label, function () {
      beforeEach(function () {
        cy.visit(basePath, { qs: { ...baseQuery, ...filter.qs, ...sort.qs } })
      })

      it('should return search results', function () {
        cy.get(firstResultItem).invoke('text').then((searchResult) => {
          expect(searchResult).to.exist
        })
      })
    })
  })
})

invalidFilterOptions.forEach(function (filter) {
  describe('Invalid filter ' + filter.label, function () {
    beforeEach(function () {
      cy.visit(basePath, { qs: { ...baseQuery, ...filter.qs, 'sort-by': 'relevance' } })
    })

    it('should display the search page', function () {
      cy.get('.hsg-search-section').should('exist')
    })

    it('should not return any search results', function () {
      cy.get('.hsg-search-section').within(function () {
        cy.contains('p', 'No results were found.').should('be.visible')
      })
    })
  })
})
