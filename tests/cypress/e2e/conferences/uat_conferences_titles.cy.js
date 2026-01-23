/**
 * Checks if conference pages have the correct titles
 */

const regex = /(\<|\/)[a-z]*>/gi

const subpages = {
  links: {
    p1: 'conferences',
    p2: 'conferences/2012-national-security-policy-salt', // 1. conference landing
    p3: 'conferences/2011-foreign-economic-policy', // 2. conference landing
    p4: 'conferences/2011-foreign-economic-policy/audio-transcripts', // 2nd level
    p5: 'conferences/2011-foreign-economic-policy/opening-remarks-and-editors-talk', // 3rd level, 1st "subpage" of videos-transcripts but is not represented in the URL!
    p6: 'conferences/2011-foreign-economic-policy/panel', // 3rd level, 2nd "subpage" of audio-transcripts but is not represented in the URL! Hidden in page navigation (-> next)
    p7: 'conferences/2010-southeast-asia', // 3. conference landing page
    p8: 'conferences/2010-southeast-asia/photos', // 3rd level TODO: Check images
    p9: 'conferences/2010-southeast-asia/videos-transcripts', // 3rd level TODO: Check video embedding
    p10: 'conferences/2010-southeast-asia/secretary-clinton', // 4th level 1st "subpage" of videos-transcripts but is not represented in the URL!
    p11: 'conferences/2010-southeast-asia/background-materials', // 3rd level
    p12: 'conferences/2010-southeast-asia/maps', // 4th level TODO: Check images
    p13: 'conferences/2007-detente', // 4. conference landing
    p14: 'conferences/2007-detente/roundtable1', // 2nd level
    p15: 'conferences/2006-china-cold-war', // 5. conference landing
    p16: 'conferences/2006-china-cold-war/susser' // 2nd level
  },
  titles: {
    p1: 'Conferences', // h1
    p2: '"National Security Policy and SALT I, 1969-1972"', // h1
    p3: '"Foreign Economic Policy, 1973-1976"', // h1
    p4: 'Audio and Transcripts', // h3
    p5: 'Opening Remarks and Editor\'s Talk on Foreign Economic Policy, 1973-1976', // h2
    p6: 'Panel Discussion', // h2
    p7: 'Program', // h1
    p8: 'Vietnam Photo Gallery', // h1
    p9: 'Videos and Transcripts', // h3
    p10: 'Opening Address by Secretary of State Hillary Rodham Clinton', // h2
    p11: 'Background Materials', // h3
    p12: 'Maps', // h2
    p13: 'Schedule', // h1
    p14: 'Introduction to Roundtable Discussion of Former Government Officials', // h1
    p15: '"Transforming the Cold War: The United States and China, 1969-1980"', // h1
    p16: 'Introductions' // h2
  }
}

describe('Conference pages: ', function () {
  // Subpage titles check
  describe('Each "Conference" subpage should be displayed and subsequently', function () {
    it('should display the headline "' + subpages.titles.p1 + '" ', function () {
      cy.openPage(subpages.links.p1)
      cy.getHeadlineH1().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p1)
      })
    })

    it('should display the headline "' + subpages.titles.p2 + '" ', function () {
      cy.openPage(subpages.links.p2)
      cy.getHeadlineH1().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p2)
      })
    })

    it('should display the headline "' + subpages.titles.p3 + '" ', function () {
      cy.openPage(subpages.links.p3)
      cy.getHeadlineH1().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p3)
      })
    })

    it('should display the headline "' + subpages.titles.p4 + '" ', function () {
      cy.openPage(subpages.links.p4)
      cy.getHeadlineH3().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p4)
      })
    })

    it('should display the headline "' + subpages.titles.p5 + '" ', function () {
      cy.openPage(subpages.links.p5)
      cy.getHeadlineH2().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p5)
      })
    })

    it('should display the headline "' + subpages.titles.p6 + '" ', function () {
      cy.openPage(subpages.links.p6)
      cy.getHeadlineH2().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p6)
      })
    })

    it('should display the headline "' + subpages.titles.p7 + '" ', function () {
      cy.openPage(subpages.links.p7)
      cy.getHeadlineH1().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p7)
      })
    })

    it('should display the headline "' + subpages.titles.p8 + '" ', function () {
      cy.openPage(subpages.links.p8)
      cy.getHeadlineH1().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p8)
      })
    })

    it('should display the headline "' + subpages.titles.p9 + '" ', function () {
      cy.openPage(subpages.links.p9)
      cy.getHeadlineH3().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p9)
      })
    })

    it('should display the headline "' + subpages.titles.p10 + '" ', function () {
      cy.openPage(subpages.links.p10)
      cy.getHeadlineH2().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p10)
      })
    })

    it('should display the headline "' + subpages.titles.p11 + '" ', function () {
      cy.openPage(subpages.links.p11)
      cy.getHeadlineH3().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p11)
      })
    })

    it('should display the headline "' + subpages.titles.p12 + '" ', function () {
      cy.openPage(subpages.links.p12)
      cy.getHeadlineH2().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p12)
      })
    })

    it('should display the headline "' + subpages.titles.p13 + '" ', function () {
      cy.openPage(subpages.links.p13)
      cy.getHeadlineH1().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p13)
      })
    })

    it('should display the headline "' + subpages.titles.p14 + '" ', function () {
      cy.openPage(subpages.links.p14)
      cy.getHeadlineH1().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p14)
      })
    })

    it('should display the headline "' + subpages.titles.p15 + '" ', function () {
      cy.openPage(subpages.links.p15)
      cy.getHeadlineH1().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p15)
      })
    })

    it('should display the headline "' + subpages.titles.p16 + '" ', function () {
      cy.openPage(subpages.links.p16)
      cy.getHeadlineH2().then((title) => {
        expect(title.replace(regex, '')).to.equal(subpages.titles.p16)
      })
    })
  })
})