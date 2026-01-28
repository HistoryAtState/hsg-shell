const { defineConfig } = require('cypress');
const glob = require('glob');

module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      on('task', {
        findFiles({ pattern }) {
          // Use glob.sync to get the files synchronously
          return glob.sync(pattern, { nodir: true });
        }
      });
      return config;
    },
    baseUrl: 'http://localhost:8080/exist/apps/hsg-shell',
    viewportWidth: 1280,
    viewportHeight: 720,
    trashAssetsBeforeRuns: true,
    includeShadowDom: true,
    retries: 1,
    supportFile: 'tests/cypress/support/e2e.js', 
    specPattern: [
      'tests/cypress/e2e/**/*.cy.js',
    ],
    screenshotsFolder: 'tests/cypress/screenshots',
    videosFolder: 'tests/cypress/videos',
    fixturesFolder: 'tests/cypress/fixtures',
    downloadsFolder: 'tests/cypress/downloads'
  },
});

