/**
 * Checks departmenthistory page type
 */

const mainpage = {
  link: 'countries', // 1st level subpage (landing)
  title: 'Countries'
}

describe('The "Countries" landing page', function () {
  it('should display a select input for choosing countries', function () {
    cy.openPage(mainpage.link)
    cy.get('select[data-template="countries:load-countries"]').should('exist')
  })

  // TODO: Check interacting with select input and choose countries
  // TODO: Check sidebar
})