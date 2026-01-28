/**
 * Twitter section on landing page
 */

describe('Landing twitter', function () {
  beforeEach(function () {
    cy.visit('')
  })

  it.skip('should display at least one twitter post (requires .post-list widget)', function () {
    cy.get('.post-list .post p', { timeout: 10000 }).should('have.length.at.least', 1)
  })
})
