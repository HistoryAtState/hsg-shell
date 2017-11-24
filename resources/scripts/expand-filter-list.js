(function($) {
    var ExpandFilterList = function(elem, config){
        this.config = config;
        this.element = elem;
        this.$element = $(elem);
    };

    ExpandFilterList.DEFAULTS = {
        showItems: 3,
        maxItems: 100,
        listSpeed: 200,
        listChildren: '.c-checkbox',
        dataMoreText: 'Show more',
        dataLessText: 'Show less',
        moreHTML: '<a href="#"><span class="glyphicon glyphicon-chevron-down"/></a>', // requires class and child <a>
        moreClass: 'c-link-more',
        openClass: 'is-open'
    };

    ExpandFilterList.prototype.init = function() {
        var that = this;
        that.listLength = that.$element.children(that.config.listChildren).length;
        that.$moreHtml = $(that.config.moreHTML).addClass(that.config.moreClass);
        that.speedForItem = 0;

        // Item speed.
        if (that.listLength > 0 && that.config.listSpeed > 0){
            that.speedForItem = Math.round(that.config.listSpeed / that.listLength);
            if (that.speedForItem < 1) {
                that.speedForItem = 1;
            }
        }

        if ((that.listLength > 0) && (that.listLength > that.config.showItems) && (that.listLength > that.config.maxItems)) {
            that.$element.children(that.config.listChildren).each(function(i) {
                if ((i + 1) > that.config.showItems) {
                    $(this).hide();
                } else {
                    $(this).show();
                }
            });
            var howManyMore = that.listLength - that.config.showItems,
                newMoreText = that.$element.data('expandfilter-more') ? that.$element.data('expandfilter-more') : that.config.dataMoreText,
                newLessText = that.$element.data('expandfilter-less') ? that.$element.data('expandfilter-less') : that.config.dataLessText;

            if (howManyMore > 0) {
                newMoreText = newMoreText.replace("[COUNT]", howManyMore);
                newLessText = newLessText.replace("[COUNT]", howManyMore);
            }

            if (that.$element.next(that.config.moreClass).length > 0) {
                $element.next(that.config.moreClass).show();
            } else {
                that.$element.after(that.$moreHtml);
            }

            that.$moreHtml
                .html(newMoreText)
                .off('click')
                .on('click', function(e){
                    var $theLink = $(this),
                        listElements = that.$element.children(that.config.listChildren);

                    listElements = listElements.slice(that.config.showItems);

                    if ($theLink.html() == newMoreText){
                        $theLink.html(newLessText).addClass(that.config.openClass);
                        var i = 0;
                        (function() {
                            $(listElements[i++] || []).slideToggle(that.speedForItem, arguments.callee);
                        })();
                    } else {
                        $theLink.html(newMoreText).removeClass(that.config.openClass);
                        var i = listElements.length - 1;
                        (function() {
                            $(listElements[i--] || []).slideToggle(that.speedForItem, arguments.callee);
                        })();
                    }
                    e.preventDefault();
                });
        }
    };

    $.fn.expandFilterList = function(option) {
        return this.each(function() {
            var $that = $(this),
                thatData = $that.data('hsg:expand-filter-list'),
                options = $.extend({}, ExpandFilterList.DEFAULTS, $that.data(), typeof option == 'object' && option);
            if (!thatData) {
                $that.data('hsg:expand-filter-list', (thatData = new ExpandFilterList(this, options)));
                thatData.init();
            }
        });
    };
})(jQuery);
