/**
 * Buildings – Original Foreword headline
 */

describe('Buildings Foreword', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/buildings/foreword')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Original Foreword')
  })
})
