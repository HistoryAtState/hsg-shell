/**
 * Checks departmenthistory page type
 */

const subpages = {
  links: {
    p1: 'departmenthistory',
    p2: 'departmenthistory/timeline',
    p3: 'departmenthistory/people/secretaries',
    p4: 'departmenthistory/people/principals-chiefs',
    p5: 'departmenthistory/travels/secretary',
    p6: 'departmenthistory/travels/president',
    p7: 'departmenthistory/visits',
    p8: 'departmenthistory/wwi',
    p9: 'departmenthistory/buildings',
    p10: 'departmenthistory/diplomatic-couriers'
  },
  titles: {
    p1: 'Department History',
    p2: 'Administrative Timeline of the Department of State',
    p3: 'Biographies of the Secretaries of State',
    p4: 'Principal Officers and Chiefs of Mission',
    p5: 'Travels Abroad of the Secretary of State',
    p6: 'Travels Abroad of the President',
    p7: 'Visits by Foreign Leaders',
    p8: 'World War I and the Department',
    p9: 'Buildings of the Department of State',
    p10: 'U.S. Diplomatic Couriers'
  }
}

describe('Department History pages: ', function () {
  // Subpage titles check
  describe('Each "Department History" subpage should be displayed and subsequently', function () {
    it('should display the headline "' + subpages.titles.p1 + '" ', function () {
      cy.openPage(subpages.links.p1)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p1)
      })
    })

    it('should display the headline "' + subpages.titles.p2 + '" ', function () {
      cy.openPage(subpages.links.p2)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p2)
      })
    })

    it('should display the headline "' + subpages.titles.p3 + '" ', function () {
      cy.openPage(subpages.links.p3)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p3)
      })
    })

    it('should display the headline "' + subpages.titles.p4 + '" ', function () {
      cy.openPage(subpages.links.p4)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p4)
      })
    })

    it('should display the headline "' + subpages.titles.p5 + '" ', function () {
      cy.openPage(subpages.links.p5)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p5)
      })
    })

    it('should display the headline "' + subpages.titles.p6 + '" ', function () {
      cy.openPage(subpages.links.p6)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p6)
      })
    })

    it('should display the headline "' + subpages.titles.p7 + '" ', function () {
      cy.openPage(subpages.links.p7)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p7)
      })
    })

    it('should display the headline "' + subpages.titles.p8 + '" ', function () {
      cy.openPage(subpages.links.p8)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p8)
      })
    })

    it('should display the headline "' + subpages.titles.p9 + '" ', function () {
      cy.openPage(subpages.links.p9)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p9)
      })
    })

    it('should display the headline "' + subpages.titles.p10 + '" ', function () {
      cy.openPage(subpages.links.p10)
      cy.getHeadlineH1().then((title) => {
        expect(title).to.equal(subpages.titles.p10)
      })
    })
  })
})