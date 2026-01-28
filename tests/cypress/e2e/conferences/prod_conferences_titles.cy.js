/**
 * Checks if conference pages have the correct titles
 */

const page = { link: 'conferences', title: 'Conferences', h: 1 }
const headline = {
  1: '#content-inner h1',
  2: '#content-inner h2',
  3: '#content-inner h3'
}

const subpages = [
  // 1. conference landing
  {
    name: 'p2',
    link: 'conferences/2012-national-security-policy-salt',
    title: '"National Security Policy and SALT I, 1969-1972"',
    h: 1
  },
  // 2. conference landing
  {
    name: 'p3',
    link: 'conferences/2011-foreign-economic-policy',
    title: '"Foreign Economic Policy, 1973-1976"',
    h: 1
  },
  // 2nd level
  {
    name: 'p4',
    link: 'conferences/2011-foreign-economic-policy/audio-transcripts',
    title: 'Audio and Transcripts',
    h: 3
  },
  // 3rd level, 1st "subpage" of videos-transcripts but is not represented in the URL!
  {
    name: 'p5',
    link: 'conferences/2011-foreign-economic-policy/opening-remarks-and-editors-talk',
    title: 'Opening Remarks and Editor\'s Talk on Foreign Economic Policy, 1973-1976',
    h: 2
  },
  // 3rd level, 2nd "subpage" of audio-transcripts but is not represented in the URL! Hidden in page navigation (-> next)
  {
    name: 'p6',
    link: 'conferences/2011-foreign-economic-policy/panel',
    title: 'Panel Discussion',
    h: 2
  },
  // 3. conference landing page
  {
    name: 'p7',
    link: 'conferences/2010-southeast-asia',
    title: 'Program',
    h: 1
  },
  // 3rd level TODO: Check images
  {
    name: 'p8',
    link: 'conferences/2010-southeast-asia/photos',
    title: 'Vietnam Photo Gallery',
    h: 1
  },
  // 3rd level TODO: Check video embedding
  {
    name: 'p9',
    link: 'conferences/2010-southeast-asia/videos-transcripts',
    title: 'Videos and Transcripts',
    h: 3
  },
  // 4th level 1st "subpage" of videos-transcripts but is not represented in the URL!
  {
    name: 'p10',
    link: 'conferences/2010-southeast-asia/secretary-clinton',
    title: 'Opening Address by Secretary of State Hillary Rodham Clinton',
    h: 2
  },
  // 3rd level
  {
    name: 'p11',
    link: 'conferences/2010-southeast-asia/background-materials',
    title: 'Background Materials',
    h: 3
  },
  // 4th level TODO: Check images (wdio uses p11 for both background-materials and maps)
  {
    name: 'p11',
    link: 'conferences/2010-southeast-asia/maps',
    title: 'Maps',
    h: 2
  },
  // 4. conference landing
  {
    name: 'p13',
    link: 'conferences/2007-detente',
    title: 'Schedule',
    h: 1
  },
  // 2nd level
  {
    name: 'p14',
    link: 'conferences/2007-detente/roundtable1',
    title: 'Introduction to Roundtable Discussion of Former Government Officials',
    h: 1
  },
  // 5. conference landing
  {
    name: 'p15',
    link: 'conferences/2006-china-cold-war',
    title: '"Transforming the Cold War: The United States and China, 1969-1980"',
    h: 1
  },
  // 2nd level
  {
    name: 'p16',
    link: 'conferences/2006-china-cold-war/susser',
    title: 'Introductions',
    h: 2
  }
]

describe('The conference page', function () {
  it('should display the headline', function () {
    cy.visit(page.link)
    cy.get('#content-inner h1').first().normalizeHeadlineText(page.title)
  })

  // Subpage titles check
  describe('Each "Conference" subpage should be displayed and subsequently', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', function () {
        cy.visit(page.link)
        cy.get(headline[page.h]).first().normalizeHeadlineText(page.title)
      })
    })
  })
})
