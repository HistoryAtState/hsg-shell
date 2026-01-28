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

