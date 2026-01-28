/**
 * Checks search and filtering results
 *
 * Uses Cypress `qs` option for `cy.visit()` instead of concatenated query
 * strings, to keep parameter combinations legible and closer to WDIO intent.
 */

const basePath = 'search'
const baseQuery = { q: 'china' }
const queryLabel = 'search?q=china'

const sortingOptions = [
  {
    label: '&sort-by=relevance',
    qs: { 'sort-by': 'relevance' }
  },
  {
    label: '&sort-by=date-asc',
    qs: { 'sort-by': 'date-asc' }
  }
]

const validFilterOptions = [
  {
    label: '&within=entire-site', // 01. no filter
    qs: { within: 'entire-site' }
  },
  {
    label: '&within=department', // 02. filter within "Department History"
    qs: { within: 'department' }
  },
  {
    label: '&within=documents', // 03. filter within "Historical Documents"
    qs: { within: 'documents' }
  },
  {
    label: '&within=documents&start-date=1946-02-01&end-date=1946-03-31', // 04. start 1946-02-01, end 1946-03-31
    qs: {
      within: 'documents',
      'start-date': '1946-02-01',
      'end-date': '1946-03-31'
    }
  },
  {
    label: '&within=documents&start-date=1946&end-date=1946-03-31', // 05. start 1946, end 1946-03-31
    qs: {
      within: 'documents',
      'start-date': '1946',
      'end-date': '1946-03-31'
    }
  },
  {
    label: '&within=documents&start-date=1946-02&end-date=1946-03-31', // 06. start 1946-02-xx, end 1946-03-31
    qs: {
      within: 'documents',
      'start-date': '1946-02',
      'end-date': '1946-03-31'
    }
  },
  {
    label: '&within=documents&end-date=1946-01-31', // 07. end 1946-01-31
    qs: {
      within: 'documents',
      'end-date': '1946-01-31'
    }
  },
  {
    label: '&within=documents&start-date=1946-02-01&end-date=1946', // 08. start 1946-02-01, end 1946-xx-xx
    qs: {
      within: 'documents',
      'start-date': '1946-02-01',
      'end-date': '1946'
    }
  },
  {
    label: '&within=documents&start-date=1946-02-01&end-date=1946-03', // 09. start 1946-02-01, end 1946-03-xx
    qs: {
      within: 'documents',
      'start-date': '1946-02-01',
      'end-date': '1946-03'
    }
  },
  {
    label: '&within=documents&start-date=1946-01-02', // 10. start 1946-01-02, no end
    qs: {
      within: 'documents',
      'start-date': '1946-01-02'
    }
  }
]

const invalidFilterOptions = [
  {
    label: '&within=documents&start-date=1946-01-02&end-date=1945-01-01', // 11. start date > end date
    qs: {
      within: 'documents',
      'start-date': '1946-01-02',
      'end-date': '1945-01-01'
    }
  },
  {
    label: '&within=documents&start-date=1000-01-02&end-date=1000-01-01', // 12. dates out of scope
    qs: {
      within: 'documents',
      'start-date': '1000-01-02',
      'end-date': '1000-01-01'
    }
  }
  // TODO: Fix this parameter result in the app, as must should not return any results, skipping this for now
  // {
  //   label: '&within=documents&within=department&start-date=1900-01-01&end-date=2019-01-01',
  //   qs: {
  //     within: ['documents', 'department'],
  //     'start-date': '1900-01-01',
  //     'end-date': '2019-01-01'
  //   }
  // }
]

const firstResultItem = '.hsg-search-result > h3 > a' // link containing the title of the search result
const noResultsMessage = '#content-inner > section > p' // paragraph containing a static text "No results were found"

// Parameterized tests simply opening pages with valid parameters, sorted by relevance
validFilterOptions.forEach(function (filter) {
  describe('Filtering search result for query "' + queryLabel + '" with valid parameters and sorted by "' + sortingOptions[0].label + '"', function () {
    before(function () {
      cy.visit(basePath, {
        qs: {
          ...baseQuery,
          ...filter.qs,
          ...sortingOptions[0].qs
        }
      })
    })

    it('"' + filter.label + '" should return search results', function () {
      cy.get(firstResultItem).invoke('text').then((searchResult) => {
        expect(searchResult).to.exist
      })
    })
  })
})

// Parameterized tests simply opening pages with valid parameters, sorted by ascending date
validFilterOptions.forEach(function (filter) {
  describe('Filtering search result for query "' + queryLabel + '" with valid parameters and sorted by "' + sortingOptions[1].label + '"', function () {
    before(function () {
      cy.visit(basePath, {
        qs: {
          ...baseQuery,
          ...filter.qs,
          ...sortingOptions[1].qs
        }
      })
    })

    it('"' + filter.label + '" should return search results', function () {
      cy.get(firstResultItem).invoke('text').then((searchResult) => {
        expect(searchResult).to.exist
      })
    })
  })
})

// Parameterized tests simply opening pages with invalid parameters
invalidFilterOptions.forEach(function (filter) {
  describe('Filtering search result for query "' + queryLabel + '" with invalid parameters', function () {
    beforeEach(function () {
      cy.visit(basePath, {
        qs: {
          ...baseQuery,
          ...filter.qs,
          ...sortingOptions[0].qs
        }
      })
    })

    it('"' + filter.label + '" should display the search page', function () {
      cy.get('.hsg-search-section').should('exist')
    })

    // TODO: Check for notifications instead after this feature has been implemented, this is only a workaround
    it('"' + filter.label + '" should not return any search results', function () {
      cy.get('.hsg-search-section').within(function () {
        cy.contains('p', 'No results were found.').should('be.visible')
      })
    })
  })
})

// Todo 1. insert values in UI and test if they are serialized correctly
// Todo 2. insert values in UI and test form validation is working and responding with user notifications
// TODO 3. after update to WDIO 5.x Check // browser.assertRequests(), request.response.statusCode for checking http-status codes