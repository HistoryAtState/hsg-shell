/**
 * Checks UI component "tooltip"
 */

 const { assert } = require('chai');

 const Page  = require('../../pageobjects/Page');

 // These are currently the only occurrences of a tooltip in the project:
 const tooltips = [
   {
     type: 'persons',
     pageURL: 'historicaldocuments/frus1981-88v13/d200',
     triggerSelector: 'a[href="persons#p_BLH_1"]',
     triggerLabel: 'Brown, Leslie H.'
   },
   {
     type: 'persons',
     pageURL: 'historicaldocuments/frus1981-88v13/d200',
     triggerSelector: 'a[href="persons#p_ELS_1"]',
     triggerLabel: 'Eagleburger, Lawrence S.'
   },
   {
     type: 'persons',
     pageURL: 'historicaldocuments/frus1981-88v13/d200',
     triggerSelector: 'a[href="persons#p_FDE_1"]',
     triggerLabel: 'Brown, Leslie H.'
   },
   {
     type: 'terms',
     pageURL: 'historicaldocuments/frus1981-88v13/d200',
     triggerSelector: 'a[href="terms#t_AFB_1"]',
     triggerLabel: 'AFB'
   }
 ]

 tooltips.forEach((tooltip) => {
   describe('A link with tooltip type: "' + tooltip.type + '" , label: "' + tooltip.triggerLabel + '"', () => {
     let hasTabindex, hasRole, el, ttLink, tt, title, ttContent;

     before(() => {
       Page.pause(1500);
       Page.open(tooltip.pageURL);
       el = 'div[data-template="frus:facets"] ' + tooltip.triggerSelector
       hasTabindex = Page.getElementAttribute(el, 'tabindex');
       ttLink = Page.getElement(el);
       title = Page.getElementAttribute(el, 'data-original-title');
       ttSelector = '.tooltip';
       Page.pause(1000);
     });

     // Check if tooltip trigger has tabindex
     it('should contain attribute tabindex="0"', () => {
       assert.equal(hasTabindex, '0');
     });

     // Check if tooltip opens on hover
     it('should display a tooltip on hovering the element', () => {
       assert.equal(Page.getElement(ttSelector).isDisplayed(), false);
       ttLink.scrollIntoView({behavior: "smooth", block: "center", inline: "center"});
       Page.pause(1500);
       ttLink.moveTo(1,1)
       Page.pause(1500);
       tt = Page.getElement(ttSelector);
       assert.equal(tt.isDisplayed(), true);
     });

     // Check if tooltip content is identical with the trigger title content
     it('should display its title as the tooltip content', () => {
       ttContent = Page.getElementText(tt);
       assert.equal(ttContent, title);
     });

     // Check if tooltip contains role="tooltip"
     it('should display a tooltip with attribute "role=tooltip"', () => {
       hasRole = Page.getElementAttribute(tt, 'role');
       assert.equal(hasRole, 'tooltip');
     });

     // Check if USWDS css properties are applied (== Bootstrap overrides)
      it('should display a tooltip with correct USWDS CSS properties', () => {
       ttSelector = '.tooltip-inner';
       assert.equal(Page.getCssProperty(ttSelector, 'color').value, 'rgba(240,240,240,1)');
       assert.equal(Page.getCssProperty(ttSelector, 'background-color').value, 'rgba(27,27,27,1)');
       assert.equal(Page.getCssProperty(ttSelector, 'font-size').value, '16.5px');
       assert.equal(Page.getCssProperty(ttSelector, 'padding').value, '8px');
     });
   });
 });