/**
 * Department History index headline
 * @see tests/specs/departmenthistory/prod_departmenthistory_titles.spec.js (wdio)
 */

describe('Department History', function () {
  beforeEach(function () {
    cy.visit('departmenthistory')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Department History')
  })
})
