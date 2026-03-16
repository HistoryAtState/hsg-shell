// ***********************************************************
// This example support/e2e.js is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

// Import commands.js
require('./commands')

// Import chai for assertions (matching wdio setup)
const { expect, assert } = require('chai')

// Make assert available globally (matching wdio setup)
global.assert = assert