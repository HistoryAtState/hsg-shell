/**
 * Checks UI component "breadcrumb"
 */

 const { assert } = require('chai');

 const Page  = require('../../pageobjects/Page');

describe('A breadcrumb', () => {
    let t, v, p, a, c, i;
    before(async () => {
        await Page.open('historicaldocuments/frus-history/chapter-4');
    });

    // 1. Check, if rdf attributes render as expected
    // 1a. ol contains  vocab="http://schema.org/", typeof="BreadcrumbList", class="hsg-breadcrumb__list"
    it('should contain a list with rdf metadata', async () => {
        t = await Page.getElementAttribute('nav.hsg-breadcrumb ol', 'typeof');
        v = await Page.getElementAttribute('nav.hsg-breadcrumb ol', 'vocab');
        assert.equal(t, 'BreadcrumbList');
        assert.equal(v, 'http://schema.org/');
    });

    // 1b. li contains class="hsg-breadcrumb__list-item", property="itemListElement", typeof="ListItem"
    it('should contain list-items with rdf metadata', async () => {
        t = await Page.getElementAttribute('nav.hsg-breadcrumb ol li', 'typeof');
        p = await Page.getElementAttribute('nav.hsg-breadcrumb ol li', 'property');
        assert.equal(t, 'ListItem');
        assert.equal(p, 'itemListElement');
    });

    // 1c. a contains class="hsg-breadcrumb__link", property="item", typeof="WebPage"
    it('should contain links with rdf metadata', async () => {
        t = await Page.getElementAttribute('nav.hsg-breadcrumb ol li a', 'typeof');
        p = await Page.getElementAttribute('nav.hsg-breadcrumb ol li a', 'property');
        assert.equal(t, 'WebPage');
        assert.equal(p, 'item');
    });

    // 2. Check, if aria attributes are rendered as expected
    // 2a. nav contains aria-label="breadcrumbs"
    it('should contain an aria-label in the nav element', async () => {
        a = await Page.getElementAttribute('nav.hsg-breadcrumb', 'aria-label');
        assert.equal(a, 'breadcrumbs');
    });

    // 2b. link contains class="hsg-breadcrumb__link", aria-current="page"
    it('should contain an aria-current attribute in current (last) breadcrumb', async () => {
        a = await Page.getElement('nav.hsg-breadcrumb a[aria-current="page"]');
        assert.exists(a);
    });

    // 3. Check if current page is highlightes with default text color
    it('should contain a last, current breadcrumb highlighted in normal text color #212121', async () => {
        c = await Page.getCssProperty('nav.hsg-breadcrumb a[aria-current="page"] span', 'color');
        assert.equal(c.parsed.hex, '#212121');
    });
});

describe.skip('A breadcrumb on small screens', () => {
    before(async () => {
        await Page.open('historicaldocuments/frus-history/chapter-4');
        await browser.setWindowSize(480, 800);
        const windowSize = await browser.getWindowSize();
        console.log(windowSize);
        await Page.waitForVisible('.hsg-breadcrumb__list-item:nth-last-child(2) .hsg-breadcrumb__link');
    });

    // 4. Check, if only the parent level is rendered...
    it('should display the parent chapter breadcrumb', async () => {
        const t = await Page.getElementText('.hsg-breadcrumb__list-item:nth-last-child(2) .hsg-breadcrumb__link span');
        assert.equal(c, 'History of the <em>Foreign Relations</em> Series');
    });

    // ...with a left arrow on smaller screens.
    it('should display a "back" arrow before the parent chapter breadcrumb', async () => {
        const c = await Page.getCssProperty('.hsg-breadcrumb__list-item:nth-last-child(2) .hsg-breadcrumb__link:before', '-webkit-mask');
        //console.log('c=', c);
        assert.equal(c, 'url(../images/arrow_back.svg) no-repeat center/contain;');
    });
});

