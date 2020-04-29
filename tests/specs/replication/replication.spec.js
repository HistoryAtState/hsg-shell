/**
 * Checks if the replication is running correctly for hsg-shell
 */

const Page = require('../../pageobjects/Page');

describe('The Replication test "validate-replication.xq"', () => {
  let replication;

  before(() => {
    // Calling this script is forwarded by the hsg-shell controller
    Page.openUrl('https://1861.history.state.gov/validate-replication');
  });

  it('should show the same datetime for 1861 and 1991 server', () => {
    replication = Page.getElementText('#replication');
    assert.equal(replication, 'true');
  });
});
