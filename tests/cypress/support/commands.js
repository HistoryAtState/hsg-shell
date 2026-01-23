// ***********************************************
// Custom Cypress commands for hsg-shell
// ***********************************************
//
// NOTE:
// - All migrated specs currently use native Cypress APIs directly
//   (cy.visit, cy.get, cy.contains, cy.viewport, etc.).
// - This file is intentionally minimal and kept as a stub so that
//   future helpers can be added without changing cypress.config.cjs.
//
// If you add commands here, prefer patterns that do NOT mask what the
// test is doing. For example, avoid thin wrappers around:
//   - cy.visit()
//   - cy.get().invoke('text')
//   - cy.get().should('have.css', ...)
// Instead, use those primitives directly in tests so failures produce
// clear, actionable error messages.

const TAG_REGEX = /(\<|\/)[a-z]*>/gi

/**
 * Normalize headline text for comparison: strip HTML tags, collapse whitespace,
 * trim, and normalize Unicode curly/smart quotes to straight quotes.
 * @param {string} str - Raw text (e.g. from textContent)
 * @returns {string} Normalized string
 */
function normalizeHeadlineText (str) {
  if (str == null || typeof str !== 'string') return ''
  let s = str.replace(TAG_REGEX, '').replace(/\s+/g, ' ').trim()
  return s
    .replace(/[""]/g, '"')
    .replace(/['']/g, "'")
    .replace(/\u2018|\u2019/g, "'")
    .replace(/\u201C|\u201D/g, '"')
}

/**
 * Asserts that the first element in the subject has headline text equal to
 * expectedTitle after normalization (strip tags, whitespace, Unicode quotes).
 * Chain after cy.get(selector).first()
 *
 * @param {string} expectedTitle - Expected headline text (will be normalized)
 * @param {object} [options] - Optional. stripAfter: string to trim actual text before this substring (e.g. 'Lesson Plans')
 * @example
 *   cy.get('#content-inner h2').first().normalizeHeadlineText('Opening Remarks')
 *   cy.get('#content-inner div:nth-child(2) h2').first().normalizeHeadlineText('Introduction...', { stripAfter: 'Lesson Plans' })
 */
Cypress.Commands.add('normalizeHeadlineText', { prevSubject: true }, (subject, expectedTitle, options) => {
  const $el = subject.first()
  const raw = $el[0].textContent || $el[0].innerText || ''
  let normalized = normalizeHeadlineText(raw)
  if (options && options.stripAfter && normalized.includes(options.stripAfter)) {
    normalized = normalized.split(options.stripAfter)[0].trim()
  }
  const expected = normalizeHeadlineText(expectedTitle)
  expect(normalized).to.equal(expected)
})

