/**
 * Secretary Clinton opening address headline
 * @see tests/specs/conferences/prod_conferences_titles.spec.js (wdio)
 */

describe('2010 Clinton', function () {
  beforeEach(function () {
    cy.visit('conferences/2010-southeast-asia/secretary-clinton')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Opening Address by Secretary of State Hillary Rodham Clinton')
  })
})
