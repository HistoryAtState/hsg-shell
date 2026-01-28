/**
 * Border Vanishes intro module headline
 */

describe('Border Vanishes intro', function () {
  beforeEach(function () {
    cy.visit('education/modules/border-vanishes-intro')
  })

  it('should display the headline', function () {
    cy.get('#content-inner div:nth-child(2) h2', { timeout: 10000 }).first().normalizeHeadlineText('Introduction to Curriculum Packet on "When the Border Vanishes: Diplomacy and the Threat to our Health and Environment"', { stripAfter: 'Lesson Plans' })
  })
})
