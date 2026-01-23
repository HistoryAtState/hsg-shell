/**
 * Checks if the replication is running correctly for hsg-shell
 */

describe('The Replication test "validate-replication.xq"', () => {
  before(() => {
    // Calling this script is forwarded by the hsg-shell controller
    cy.visit('https://1861.hsg/validate-replication')
  })

  it('should show the same datetime for 1861 and 1991 server', () => {
    cy.getElementText('#replication').then((replication) => {
      expect(replication).to.equal('true')
    })
  })
})