/**
 * Checks if the replication is running correctly for hsg-shell
 */

const Page = require('../../pageobjects/Page');

describe('The Replication test "validate-replication.xq"', () => {
  let replication;

  before(async () => {
    // Calling this script is forwarded by the hsg-shell controller
    await Page.openUrl('https://1861.hsg/validate-replication');
  });

  it('should show the same datetime for 1861 and 1991 server', async () => {
    replication = await Page.getElementText('#replication');
    assert.equal(replication, 'true');
  });
});
