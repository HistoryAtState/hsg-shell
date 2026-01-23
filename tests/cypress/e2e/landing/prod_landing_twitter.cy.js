/**
 * Checks if twitter module is displaying tweets on landing page
 */

describe('The twitter section on the landing page', function () {
  beforeEach(function () {
    cy.visit('')
  })

  it('should display at least one twitter post', function () {
    cy.get('post-list .post:last-child p').should('exist')
  })
})