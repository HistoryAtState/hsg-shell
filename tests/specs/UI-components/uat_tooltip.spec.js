/**
 * Checks UI component "tooltip"
 */

const { assert } = require('chai');

const Page  = require('../../pageobjects/Page');

let tooltips = [
  {
    type: 'persons',
    pageURL: 'historicaldocuments/frus1981-88v13/d200',
    triggerSelector: '#person-panel a[href="persons#p_RDR_1"]',
    triggerLabel: 'Robinson, Davis R.',
    tooltipContent: 'Legal Adviser of the Department of State from July 30, 1981'
  },
  {
    type: 'terms',
    pageURL: 'historicaldocuments/frus1981-88v13/d200',
    triggerSelector: '#gloss-panel a[href="terms#t_AFB_1"]',
    triggerLabel: 'AFB',
    tooltipContent: 'Air Force Base'
  }
]



tooltips.forEach((tooltip) => {
  describe('Tooltip type: "' + tooltip.type + '" , label: "' + tooltip.triggerLabel + '"', () => {
    let hasTabindex, hasRole, el, tooltipLink;

    before(() => {
      Page.open(tooltip.pageURL);
      console.log('URL=', Page.getUrl());
      el = 'div[data-template="frus:facets"] ' + tooltip.triggerSelector
      hasTabindex = Page.getElementAttribute(el, 'tabindex')

    });

    // Check if tooltip trigger has tabindex
    it('should contain attribute tabindex="0" for the tooltip trigger link', () => {
      assert.equal(hasTabindex, '0');
    });

    // Check if tooltip opens on hover
    it('should display on hovering the trigger link', () => {
      tooltipLink = Page.getElement(el);
      tooltipSelector = '.tooltip';
      assert.equal(Page.getElement(tooltipSelector).isDisplayed(), false);
      tooltipLink.scrollIntoView();
      tooltipLink.moveTo(1,1)
      assert.equal(Page.getElement(tooltipSelector).isDisplayed(), true);
    });

    // Check if tooltip content is identical with the trigger title content
    // Check if tooltip contains role "tooltip"
    // Check if USWDS css properties are applied
  });
});