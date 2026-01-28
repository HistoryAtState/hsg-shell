/**
 * Opening Remarks and Editor's Talk headline
 */

describe('2011 Opening Remarks', function () {
  beforeEach(function () {
    cy.visit('conferences/2011-foreign-economic-policy/opening-remarks-and-editors-talk')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText("Opening Remarks and Editor's Talk on Foreign Economic Policy, 1973-1976")
  })
})
