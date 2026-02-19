/**
 * HSG landing page title
 */

describe('Landing title', function () {
  beforeEach(function () {
    cy.visit('')
  })

  it('should have the correct title', function () {
    cy.title().should('include', 'Office of the Historian')
  })
})
