/**
 * Table of contents listings (toc:table-of-contents)
 *
 * Regression tests for the sitewide TOC component shared by all publications.
 * A change intended to suppress the TOC for anticipated (not-yet-published)
 * FRUS volumes also suppressed it for every publication whose TEI carries no
 * tei:revisionDesc/@status — Milestones, FAQ, HAC, and Short History — leaving
 * their landing pages without any listing of articles/sections. These tests
 * assert the listings are present, and that the FRUS suppression still works.
 */

describe('Table of contents listings', function () {
  it('Milestones chapter page lists its articles', function () {
    cy.visit('milestones/1750-1775')
    cy.get('#content-inner .toc a.toc-link').should('have.length.at.least', 5)
    cy.get('#content-inner .toc a.toc-link[href$="milestones/1750-1775/french-indian-war"]').should('exist')
  })

  it('FAQ page lists its sections', function () {
    cy.visit('about/faq')
    cy.get('#content-inner .toc a.toc-link').should('have.length.at.least', 5)
    cy.get('#content-inner .toc a.toc-link[href$="about/faq/what-is-frus"]').should('exist')
  })

  it('HAC page lists its sections', function () {
    cy.visit('about/hac')
    cy.get('#content-inner .toc a.toc-link').should('have.length.at.least', 5)
    cy.get('#content-inner .toc a.toc-link[href$="about/hac/members"]').should('exist')
  })

  it('Short History page lists its chapters', function () {
    cy.visit('departmenthistory/short-history')
    cy.get('#content-inner .toc a.toc-link').should('have.length.at.least', 5)
    cy.get('#content-inner .toc a.toc-link[href$="departmenthistory/short-history/origins"]').should('exist')
  })

  it('Published FRUS volume landing page shows its table of contents', function () {
    cy.visit('historicaldocuments/frus1947v03')
    cy.get('.hsg-frus__toc a.toc-link').should('have.length.at.least', 5)
    cy.get('.hsg-frus__toc a.toc-link[href$="historicaldocuments/frus1947v03/comp1"]').should('exist')
  })

  it('Anticipated (not yet published) FRUS volume landing page suppresses its table of contents', function () {
    // frus1981-88v16 has revisionDesc/@status "being-cleared" as of 2026-07;
    // if this volume is published, replace it with another anticipated volume
    cy.visit('historicaldocuments/frus1981-88v16')
    cy.get('a.toc-link').should('not.exist')
  })
})
