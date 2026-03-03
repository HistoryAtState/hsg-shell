/**
 * Foreign Economic Policy – Audio and Transcripts headline
 * @see tests/specs/conferences/prod_conferences_titles.spec.js (wdio)
 */

describe('2011 Audio', function () {
  beforeEach(function () {
    cy.visit('conferences/2011-foreign-economic-policy/audio-transcripts')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h3').first().normalizeHeadlineText('Audio and Transcripts')
  })
})
