/**
 * Principal Officers and Chiefs of Mission headline
 * @see tests/specs/departmenthistory/prod_departmenthistory_titles.spec.js (wdio)
 */

describe('Principals and Chiefs', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/people/principals-chiefs')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Principal Officers and Chiefs of Mission')
  })
})
