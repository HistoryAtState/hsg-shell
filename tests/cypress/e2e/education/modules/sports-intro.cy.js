/**
 * Sports intro module headline
 */

describe('Sports intro', function () {
  beforeEach(function () {
    cy.visit('education/modules/sports-intro')
  })

  it('should display the headline', function () {
    cy.get('#content-inner div:nth-child(2) h2', { timeout: 10000 }).first().normalizeHeadlineText('Introduction to Curriculum Packet on "Sports and Diplomacy in the Global Arena"', { stripAfter: 'Lesson Plans' })
  })
})
