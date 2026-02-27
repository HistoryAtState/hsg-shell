/**
 * China Cold War conference landing headline
 */

describe('2006 China', function () {
  beforeEach(function () {
    cy.visit('conferences/2006-china-cold-war')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('"Transforming the Cold War: The United States and China, 1969-1980"')
  })
})
