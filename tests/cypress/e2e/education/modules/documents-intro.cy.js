/**
 * Documents intro module headline
 * @see tests/specs/education/prod_education_titles.spec.js (wdio)
 */

describe('Documents intro', function () {
  beforeEach(function () {
    cy.visit('education/modules/documents-intro')
  })

  it('should display the headline', function () {
    cy.get('#content-inner div:nth-child(2) h2', { timeout: 10000 }).first().normalizeHeadlineText('Introduction to Curriculum Packet on "Documents on Diplomacy: Primary Source Documents and Lessons from the World of Foreign Affairs, 1775-2011"', { stripAfter: 'Lesson Plans' })
  })
})
