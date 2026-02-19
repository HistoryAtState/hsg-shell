/**
 * History of Diplomacy intro module headline
 */

describe('History Diplomacy intro', function () {
  beforeEach(function () {
    cy.visit('education/modules/history-diplomacy-intro')
  })

  it('should display the headline', function () {
    cy.get('#content-inner div:nth-child(2) h2', { timeout: 10000 }).first().normalizeHeadlineText('Introduction to Curriculum Packet on "A History of Diplomacy"', { stripAfter: 'Lesson Plans' })
  })
})
