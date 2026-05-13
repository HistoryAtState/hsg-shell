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
      // Block image loading in the test browser. Image-heavy pages (notably
      // historicaldocuments/ebooks and conferences/2010-southeast-asia/photos)
      // can stall on the `load` event because our S3 proxy rate-limits when too
      // many image requests fire at once, causing 60s page-load timeouts in CI.
      on('before:browser:launch', (browser, launchOptions) => {
        if (browser.family === 'firefox') {
          launchOptions.preferences['permissions.default.image'] = 2;
        } else if (browser.family === 'chromium') {
          launchOptions.args.push('--blink-settings=imagesEnabled=false');
        }
        return launchOptions;
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

