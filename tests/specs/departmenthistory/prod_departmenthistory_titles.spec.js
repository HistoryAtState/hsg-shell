/**
 * Checks departmenthistory page type
 */

const Page  = require('../../pageobjects/Page'),
    SubPage = require('../../pageobjects/SubPage');

const subpages = [
  {
    name: 'p1',
    link: 'departmenthistory',
    title: 'Department History'
  },
  {
    name: 'p2',
    link: 'departmenthistory/timeline',
    title: 'Administrative Timeline of the Department of State'
  },
  {
    name: 'p3',
    link: 'departmenthistory/people/secretaries',
    title: 'Biographies of the Secretaries of State'
  },
  {
    name: 'p4',
    link: 'departmenthistory/people/principals-chiefs',
    title: 'Principal Officers and Chiefs of Mission'
  },
  {
    name: 'p5',
    link: 'departmenthistory/travels/secretary',
    title: 'Travels Abroad of the Secretary of State'
  },
  {
    name: 'p6',
    link: 'departmenthistory/travels/president',
    title: 'Travels Abroad of the President'
  },
  {
    name: 'p7',
    link: 'departmenthistory/visits',
    title: 'Visits by Foreign Leaders'
  },
  {
    name: 'p8',
    link: 'departmenthistory/wwi',
    title: 'World War I and the Department'
  },
  {
    name: 'p9',
    link: 'departmenthistory/buildings',
    title: 'Buildings of the Department of State'
  },
  {
    name: 'p10',
    link: 'departmenthistory/diplomatic-couriers',
    title: 'U.S. Diplomatic Couriers'
  }
]

describe('Department History pages: ', function () {

  // Subpage titles check
  describe('Each "Department History" subpage', function () {
    subpages.forEach(page => {
      it('should display the headline (' + page.name + ')', async function () {
        await Page.open(page.link);
        const title = await Page.getElementText(SubPage.headline_h1);
        assert.equal(page.title, title);
      })  
    })
  })
})
