/**
 * Checks all frus all volumes
 */

const s3_UAT = 'https://static.test.history.state.gov'

const images = [
  s3_UAT + '/frus/frus1861/covers/frus1861.jpg',
  s3_UAT + '/frus/frus1861-99Index/covers/frus1861-99Index.jpg',
  s3_UAT + '/frus/frus1862/covers/frus1862.jpg'
]

const titles = [
  'Message of the President of the United States to the Two Houses of Congress, at the Commencement of the Second Session of the Thirty-seventh Congress',
  'General Index to the Published Volumes of the Diplomatic Correspondence and Foreign Relations of the United States, 1861–1899',
  'Papers Relating to Foreign Affairs, Accompanying the Annual Message of the President to the Third Session Thirty-seventh Congress'
]

const links = [
  'historicaldocuments/frus1861',
  '/historicaldocuments/frus1861-99Index',
  'historicaldocuments/frus1862'
]

const publishedDates = [
  'Published on May 24, 2021'
]

describe('FRUS "All Volumes" page', () => {
  before(() => {
    cy.openPage('historicaldocuments/volume-titles')
    cy.wait(500)
  })

  it('should display a title', () => {
    cy.getElementText('h1').then((title) => {
      expect(title).to.equal('All Titles in the Series')
    })
  })

  it('should display a sidebar with citation option', () => {
    cy.get('hsg-cite__button--sidebar').should('exist')
  })

  it('should display a list containing a thumbnail', () => {
    cy.getElementAttribute('ul.hsg-list__volumes li:nth-child(1) img', 'src').then((t_0) => {
      expect(t_0).to.include(images[0])
    })
    cy.getElementAttribute('ul.hsg-list__volumes li:nth-child(2) img', 'src').then((t_1) => {
      expect(t_1).to.include(images[1])
    })
    cy.getElementAttribute('ul.hsg-list__volumes li:nth-child(3) img', 'src').then((t_2) => {
      expect(t_2).to.include(images[2])
    })
  })

  it('should display a list containing a title', () => {
    cy.getElementText('ul.hsg-list__volumes li:nth-child(1) h3 a').then((title_0) => {
      expect(title_0).to.equal(titles[0])
    })
    cy.getElementText('ul.hsg-list__volumes li:nth-child(2) h3 a').then((title_1) => {
      expect(title_1).to.equal(titles[1])
    })
    cy.getElementText('ul.hsg-list__volumes li:nth-child(3) h3 a').then((title_2) => {
      expect(title_2).to.equal(titles[2])
    })
  })

  it('should display a list containing a link to the volume', () => {
    cy.getElementAttribute('ul.hsg-list__volumes li:nth-child(1) h3 a', 'href').then((link_0) => {
      expect(link_0).to.include(links[0])
    })
    cy.getElementAttribute('ul.hsg-list__volumes li:nth-child(2) h3 a', 'href').then((link_1) => {
      expect(link_1).to.include(links[1])
    })
    cy.getElementAttribute('ul.hsg-list__volumes li:nth-child(3) h3 a', 'href').then((link_2) => {
      expect(link_2).to.include(links[2])
    })
  })

  it('should display a list containing a published status and date, if available', () => {
    cy.getElementText('ul.hsg-list__volumes li:nth-child(1) dl dd:nth-of-type(1)').then((publishedDate_0) => {
      expect(publishedDate_0).to.include(publishedDates[0])
    })
  })

  it('should display a list containing download buttons, if available', () => {
    cy.getElementText('ul.hsg-list__volumes li:nth-child(1) ul.hsg-list__media__download > li > button span').then((dl) => {
      expect(dl).to.exist
    })
  })
})