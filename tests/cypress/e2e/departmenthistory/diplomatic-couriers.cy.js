/**
 * U.S. Diplomatic Couriers headline
 * @see tests/specs/departmenthistory/prod_departmenthistory_titles.spec.js (wdio)
 */

describe('Diplomatic Couriers', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/diplomatic-couriers')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('U.S. Diplomatic Couriers')
  })
})
