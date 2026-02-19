/**
 * Southeast Asia – Videos and Transcripts headline
 */

describe('2010 Videos', function () {
  beforeEach(function () {
    cy.visit('conferences/2010-southeast-asia/videos-transcripts')
  })

  it('should display the headline', function () {
    cy.get('#content-inner h3').first().normalizeHeadlineText('Videos and Transcripts')
  })
})
