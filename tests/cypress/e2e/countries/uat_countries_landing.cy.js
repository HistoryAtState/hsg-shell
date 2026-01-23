/**
 * Checks departmenthistory page type
 */

const subpages = {
  links: {
    p1: 'countries' // 1st level subpage (landing)
  },
  titles: {
    p1: 'Countries'
  }
}

describe('The "Countries" landing page', function () {
  it('should display a select input for choosing countries', function () {
    cy.openPage(subpages.links.p1)
    cy.get('select[data-template="countries:load-countries"]').should('exist')
  })

  // TODO: Check interacting with select input and choose countries
  // TODO: Check sidebar
})