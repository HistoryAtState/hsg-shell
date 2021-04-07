/**
 * Checks if the replication is running correctly for hsg-shell
 */

const Page = require('../../pageobjects/Page');

describe('The Replication test "validate-replication.xq"', () => {
  let replication;

  before(() => {
    // Calling this script is forwarded by the hsg-shell controller
    Page.openUrl( Page.DOMAIN_1861_PROD + '/validate-replication');
  });

  it('should show the same datetime for 1861 and 1991 server', () => {
    replication = Page.getElementText('#replication');
    assert.equal(replication, 'true');
  });
});
