/**
 * Checks if education pages have the correct titles
 */

const pages = [
  { name: 'p1', link: 'education', title: 'Education' },
  {
    name: 'p2',
    link: 'education/modules',
    title: 'Curriculum Modules'
  }
]

const subpages = [
  {
    name: 'p3',
    link: 'education/modules/documents-intro',
    title: 'Introduction to Curriculum Packet on "Documents on Diplomacy: Primary Source Documents and Lessons from the World of Foreign Affairs, 1775-2011"'
  },
  {
    name: 'p4',
    link: 'education/modules/border-vanishes-intro',
    title: 'Introduction to Curriculum Packet on "When the Border Vanishes: Diplomacy and the Threat to our Health and Environment"'
  },
  {
    name: 'p5',
    link: 'education/modules/media-intro',
    title: 'Introduction to Curriculum Packet on "Today in Washington: The Media and Diplomacy"'
  },
  {
    name: 'p6',
    link: 'education/modules/journey-shared-intro',
    title: 'Introduction to Curriculum Packet on "A Journey Shared: The United States and China"'
  },
  {
    name: 'p7',
    link: 'education/modules/sports-intro',
    title: 'Introduction to Curriculum Packet on "Sports and Diplomacy in the Global Arena"'
  },
  {
    name: 'p8',
    link: 'education/modules/history-diplomacy-intro',
    title: 'Introduction to Curriculum Packet on "A History of Diplomacy"'
  },
  {
    name: 'p9',
    link: 'education/modules/terrorism-intro',
    title: 'Introduction to Curriculum Packet on "Terrorism: A War Without Borders"'
  }
]

describe('Education pages: ', function () {
  // page titles check
  describe('Each "Education" page should be displayed and subsequently', function () {
    pages.forEach(page => {
      it('should display the headline (' + page.name + ')', function () {
        cy.visit(page.link)
        cy.get('#content-inner h1').invoke('text').then((title) => {
          expect(title).to.equal(page.title)
        })
      })
    })
  })
  // Subpage titles check
  describe('Each "Education" subpage should be displayed and subsequently', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', function () {
        cy.visit(page.link)
        // SubPage.headline_h2 would select the title of the red alert box
        // Normalize whitespace (newlines, extra spaces) and handle quote differences
        cy.get('#content-inner div:nth-child(2) h2').invoke('text').then((title) => {
          // Normalize whitespace and remove any trailing text that might be appended
          let normalized = title.replace(/\s+/g, ' ').trim()
          // Handle curly quotes vs straight quotes - normalize to straight quotes
          normalized = normalized.replace(/[""]/g, '"').replace(/['']/g, "'")
          // Extract just the title part (before any trailing text like "Lesson Plans & Activities")
          const titleMatch = normalized.match(/^([^"]*"[^"]*")/)
          const finalTitle = titleMatch ? titleMatch[1] : normalized.split('Lesson Plans')[0].trim()
          expect(finalTitle).to.equal(page.title.replace(/[""]/g, '"').replace(/['']/g, "'"))
        })
      })
    })
  })
})