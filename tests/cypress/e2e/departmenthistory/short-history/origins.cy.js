/**
 * Short History – Origins headline
 */

describe('Short History Origins', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/short-history/origins')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h2').first().normalizeHeadlineText('Origins of a Diplomatic Tradition')
  })
})
