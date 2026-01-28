/**
 * Terrorism intro module headline
 */

describe('Terrorism intro', function () {
  beforeEach(function () {
    cy.visit('education/modules/terrorism-intro')
  })

  it('should display the headline', function () {
    cy.get('#content-inner div:nth-child(2) h2', { timeout: 10000 }).first().normalizeHeadlineText('Introduction to Curriculum Packet on "Terrorism: A War Without Borders"', { stripAfter: 'Lesson Plans' })
  })
})
