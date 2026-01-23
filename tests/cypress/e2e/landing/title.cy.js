/**
 * HSG landing page title
 * @see tests/specs/landing/prod_landing_title.spec.js (wdio)
 */

describe('Landing title', function () {
  beforeEach(function () {
    cy.visit('')
  })

  it('should have the correct title', function () {
    cy.title().should('include', 'Office of the Historian')
  })
})
