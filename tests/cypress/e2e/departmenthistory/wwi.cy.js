/**
 * World War I and the Department headline
 */

describe('WWI and the Department', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/wwi')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('World War I and the Department')
  })
})
