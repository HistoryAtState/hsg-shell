/**
 * Conference main page headline
 * @see tests/specs/conferences/prod_conferences_titles.spec.js (wdio)
 */

describe('Conferences', function () {
  beforeEach(function () {
    cy.visit('conferences')
  })

  it('should display the headline', function () {
    cy.contains('#content-inner h1', 'Conferences')
  })
})
