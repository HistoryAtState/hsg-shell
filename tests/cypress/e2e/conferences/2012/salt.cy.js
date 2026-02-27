/**
 * SALT conference landing headline
 */

describe('2012 SALT', function () {
  beforeEach(function () {
    cy.visit('conferences/2012-national-security-policy-salt')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('"National Security Policy and SALT I, 1969-1972"')
  })
})
