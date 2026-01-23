/**
 * Checks departmenthistory subpage type "buildings"
 */

const mainpage = {
  name: 'p1',
  link: 'departmenthistory/buildings',
  title: 'Buildings of the Department of State'
}

const subpages = [
  {
    name: 'p2',
    link: 'departmenthistory/buildings/intro',
    title: 'Introduction'
  },
  {
    name: 'p3',
    link: 'departmenthistory/buildings/foreword',
    title: 'Original Foreword'
  },
  {
    name: 'p4',
    link: 'departmenthistory/buildings/section1',
    title: 'The Period of the Continental Congress'
  },
  {
    name: 'p5',
    link: 'departmenthistory/buildings/section2',
    title: 'Carpenters\' Hall, Philadelphia\nSept. 5, 1774—Oct. 26, 1774'
  },
  {
    name: 'p6',
    link: 'departmenthistory/buildings/section3',
    title: 'Pennsylvania State House (Independence Hall), Philadelphia\n' +
      'Intermittingly from May 10, 1775 to March 1, 1781'
  }
]

describe('Buildings pages: ', function () {
  it('should display the headline', function () {
    cy.visit(mainpage.link)
    cy.get('#content-inner h1').invoke('text').then((title) => {
      expect(title).to.equal(mainpage.title)
    })
  })

  // Subpage titles check
  describe('Each "Buildings" subpage', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', function () {
        cy.visit(page.link)
        cy.get('#content-inner h1').invoke('text').then((title) => {
          // For multiline titles, normalize whitespace and handle quote differences
          let normalizedActual = title.replace(/\s+/g, ' ').replace(/\n/g, ' ').trim()
          // Normalize curly quotes/apostrophes to straight ones - handle all Unicode quote variants
          normalizedActual = normalizedActual
            .replace(/[""]/g, '"')
            .replace(/['']/g, "'")
            .replace(/\u2018|\u2019/g, "'") // Left/right single quotation marks
            .replace(/\u201C|\u201D/g, '"') // Left/right double quotation marks
          let normalizedExpected = page.title.replace(/\s+/g, ' ').replace(/\n/g, ' ').trim()
          normalizedExpected = normalizedExpected
            .replace(/[""]/g, '"')
            .replace(/['']/g, "'")
            .replace(/\u2018|\u2019/g, "'")
            .replace(/\u201C|\u201D/g, '"')
          // Compare normalized versions (ignoring newline positions and quote styles)
          expect(normalizedActual).to.equal(normalizedExpected)
        })
      })
    })
  })
})