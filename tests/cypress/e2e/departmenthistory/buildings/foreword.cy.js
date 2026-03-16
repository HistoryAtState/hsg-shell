/**
 * Buildings – Original Foreword headline
 * @see tests/specs/departmenthistory/prod_buildings_titles.spec.js (wdio)
 */

describe('Buildings Foreword', function () {
  beforeEach(function () {
    cy.visit('departmenthistory/buildings/foreword')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h1').first().normalizeHeadlineText('Original Foreword')
  })
})
