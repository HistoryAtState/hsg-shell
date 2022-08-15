const { assert, expect } = require('chai');
const Page  = require('../../pageobjects/Page')


describe('test chart',() => {
    before(() => {
        Page.open('historicaldocuments/frus-history/appendix-a');
    })

    it('should load the chart with title & labels',() => {
        const chart = Page.getElement('#graph');
        assert.exists(chart)
        let title = Page.getElementText('#graph div.dygraph-label.dygraph-title');
        let yLabel = Page.getElementText('#graph div.dygraph-label.dygraph-ylabel');
        let y2Label = Page.getElementText('#graph div.dygraph-label.dygraph-y2label');

        expect(title).to.be.equal('Foreign Relations Series: Production & Timeliness, 1861-2015')
        expect(yLabel).to.be.equal('Production (Volumes)')
        expect(y2Label).to.be.equal('Lag (Years)')
    })

    it('should be able to select data',() => {
        const chart = Page.getElement('#graph');
        Page.click(chart);
        // get the selected charts
        let legend = Page.getElementText('#graph > div > div.dygraph-legend')
        // this will ensure the Annual FRUS Production && Average FRUS Lag are selected
        expect(legend).to.contain('Production')
        expect(legend).to.contain('Average Lag')
        expect(legend).to.not.contain('Regular Lag')
        // reverse the selection
        Page.click('#content-container > div > div > div.bordered > div:nth-child(2) > p > label:nth-child(9)') //select the Regular Lag
        Page.click('#content-container > div > div > div.bordered > div:nth-child(2) > p > label:nth-child(3)') // un select the production
        Page.click('#content-container > div > div > div.bordered > div:nth-child(2) > p > label:nth-child(6)') // un select the average

        //get the new legend
        Page.click(chart);
        legend = Page.getElementText('#graph > div > div.dygraph-legend')
        // assert the correct data is selected
        expect(legend).to.not.contain('Production')
        expect(legend).to.not.contain('Average Lag')
        expect(legend).to.contain('Regular Lag')
    })

    it.only('should drag',() => {
        const chart = Page.getElement('#graph');
        const drag = Page.getElement('#graph > div > img:nth-child(5)')
        Page.pause(1000)
        drag.moveTo({ xOffset: 1 , yOffset: 1})

        Page.pause(60000)
    })
})