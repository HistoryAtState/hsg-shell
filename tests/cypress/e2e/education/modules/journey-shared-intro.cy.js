/**
 * Journey Shared intro module headline
 */

describe('Journey Shared intro', function () {
  beforeEach(function () {
    cy.visit('education/modules/journey-shared-intro')
  })

  it('should display the headline', function () {
    cy.get('#content-inner div:nth-child(2) h2', { timeout: 10000 }).first().normalizeHeadlineText('Introduction to Curriculum Packet on "A Journey Shared: The United States and China"', { stripAfter: 'Lesson Plans' })
  })
})
