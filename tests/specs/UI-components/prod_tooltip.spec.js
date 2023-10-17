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
     let hasTabindex, hasRole, el, ttLink, tt, title;

     before(async () => {
       Page.pause(1500);
       await Page.open(tooltip.pageURL);
       el = 'div[data-template="frus:facets"] ' + tooltip.triggerSelector
       hasTabindex = await Page.getElementAttribute(el, 'tabindex');
       ttLink = await Page.getElement(el);
       title = await Page.getElementAttribute(el, 'data-original-title');
       
       Page.pause(1000);
     });

     // Check if tooltip trigger has tabindex
     it('should contain attribute tabindex="0"', () => {
       assert.equal(hasTabindex, '0');
     });

     // Check if tooltip opens on hover
     it('should display a tooltip on hovering the element', async () => {
        let ttSelector = '.tooltip';
        let ttS = await Page.getElement(ttSelector);
        assert.equal(await ttS.isDisplayed(), false);
        ttLink.scrollIntoView({behavior: "smooth", block: "center", inline: "center"});
        Page.pause(1500);
        ttLink.moveTo(1,1)
        Page.pause(1500);
        let tt = await Page.getElement(ttSelector);
        assert.equal(await tt.isDisplayed(), true);
     });

     // Check if tooltip content is identical with the trigger title content
     it('should display its title as the tooltip content', async () => {       
       let ttContent = await Page.getElementText('.tooltip');
       console.log("ttContent: ", ttContent);
       assert.equal(ttContent, title);
     });

     // Check if tooltip contains role="tooltip"
     it('should display a tooltip with attribute "role=tooltip"', async () => {
       hasRole = await Page.getElementAttribute(tt, 'role');
       assert.equal(hasRole, 'tooltip');
     });

     // Check if USWDS css properties are applied (== Bootstrap overrides)
      it('should display a tooltip with correct USWDS CSS properties', async () => {
        let ttSelector = '.tooltip-inner';
        let color  = await Page.getCssProperty(ttSelector, 'color');
        assert.equal(color.value, 'rgba(240,240,240,1)');
        let background = await Page.getCssProperty(ttSelector, 'background-color');
        assert.equal(background.value, 'rgba(27,27,27,1)');
        let fontSize = await Page.getCssProperty(ttSelector, 'font-size');
        assert.equal(fontSize.value, '16.5px');
        let padding = await Page.getCssProperty(ttSelector, 'padding'); 
        assert.equal(padding.value, '8px');
     });
   });
 });