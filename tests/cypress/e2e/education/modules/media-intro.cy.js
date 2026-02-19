/**
 * Media intro module headline
 */

describe('Media intro', function () {
  beforeEach(function () {
    cy.visit('education/modules/media-intro')
  })

  it('should display the headline', function () {
    cy.get('#content-inner div:nth-child(2) h2', { timeout: 10000 }).first().normalizeHeadlineText('Introduction to Curriculum Packet on "Today in Washington: The Media and Diplomacy"', { stripAfter: 'Lesson Plans' })
  })
})
