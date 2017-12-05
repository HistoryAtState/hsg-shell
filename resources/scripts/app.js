$(document).ready(function() {
    var historySupport = !!(window.history && window.history.pushState);
    var appRoot = $("html").attr("data-app");

    //make sure the mobile menu is hidden when window is resized
    $( window ).resize(function() {
        $( ".collapse").collapse("hide");
    });

    function getFontSize() {
        var size = $("#content-inner").css("font-size");
        return parseInt(size.replace(/^(\d+)px/, "$1"));
    }

    function load(params, direction, id) {
        var animOut = direction == "nav-next" ? "fadeOutLeft" : (direction == "nav-prev" ? "fadeOutRight" : "fadeOut");
        var animIn = direction == "nav-next" ? "fadeInRight" : (direction == "nav-prev" ? "fadeInLeft" : "fadeIn");
        var container = $("#content-container");
        container.addClass("animated " + animOut)
            .one("webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend", function() {
            $.ajax({
                url: appRoot + "/modules/frus-ajax.xql",
                dataType: "json",
                data: params,
                error: function(xhr, status) {
                    alert("Not found: " + params);
                    showContent(container, animIn, animOut);
                },
                success: function(data) {
                    if (data.error) {
                        alert(data.error);
                        showContent(container, animIn, animOut);
                        return;
                    }
                    $(".content").replaceWith(data.content);
                    initContent();
                    if (data.title) {
                        $("#navigation-title").text(data.title);
                    }
                    if (data.windowTitle) {
                        $("html head title").text(data.windowTitle);
                    }
                    if (data.breadcrumbSection) {
                        $(".breadcrumb .section-breadcrumb").remove();
                        $(".breadcrumb").append(data.breadcrumbSection);
                        // $(".breadcrumb .section").html(data.breadcrumbSection);
                    }
                    if (data.persons) {
                        $("#person-panel .hsg-list-group").replaceWith(data.persons).show();
                        initNavigation("#person-panel a");
                        $('#person-panel a').tooltip({placement: "auto top"});
                        $("#person-panel").show();
                    } else {
                        $("#person-panel").hide();
                    }
                    if (data.gloss) {
                        $("#gloss-panel .hsg-list-group").replaceWith(data.gloss);
                        initNavigation("#gloss-panel a");
                        $('#gloss-panel a').tooltip({placement: "auto top"});
                        $("#gloss-panel").show();
                    } else {
                        $("#gloss-panel").hide();
                    }
                    if (data.toc) {
                        $("#toc").addClass("animated fadeOut")
                            .one("webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend", function() {
                                $("#toc .toc-inner").empty().append(data.toc);
                                initNavigation("#toc .toc-link");
                                showContent($(this), "fadeIn", "fadeOut");
                            });
                    }
                    if (data.pdf) {
                        $("#media-download .hsg-link-button").attr("href", data.pdf);
                    }
                    highlightToc(data.tocCurrent);
                    if (data.next) {
                        var root = $(".nav-next").attr("href").replace(/^(.*)\/[^\/]+$/, "$1");
                        $(".nav-next").attr("href", root + "/" + data.next).css("visibility", "");
                    } else {
                        $(".nav-next").css("visibility", "hidden");
                    }
                    if (data.previous) {
                        var root = $(".nav-prev").attr("href").replace(/^(.*)\/[^\/]+$/, "$1");
                        $(".nav-prev").attr("href", root + "/" + data.previous).css("visibility", "");
                    } else {
                        $(".nav-prev").css("visibility", "hidden");
                    }
                    showContent(container, animIn, animOut, id);
                    ga('send', 'pageview');
                }
            });
        });
    }

    //-------------- Search Filters and Forms--------------//

    var mainForm = $('form.main-form'), // search bar inputs and submit buttons
        searchForm = $('#searchForm'), // main searchbar form
        navigationSearchForm = $('#navigationSearchForm'), // searchbar form in navigation bar
        formFilters = $('form.filter-form'), // all filter forms
        sortingForm = $('.sorting'), // "sort-by" filter form
        queryForm = $('#queryFilters'), // "refine-by" filter form
        sectionFilter = $('#sectionFilter'), // "by-sections" filter form
        dateFilter = $('#dateFilter'), // "by-date" filter form
        dateFilterInputs = dateFilter.find('input[type=number]'), // inputs in "by-date" filter form
        administrationsFilter = $('#administrationsFilter'), // "by-administrations" filter form
        volumesFilter = $('#volumesFilter'), // "by-volumes" filter form
        mainButton = $('.hsg-main-search-button'); // main search button

    /**
     * Submit query from navigation search form, redirect to "search/"
     * @param {Event} event
     */
    function submitNavbarSearch (event) {
        event.preventDefault();
        var url = navigationSearchForm.prop("action");
        var action = navigationSearchForm.serialize();
        window.location.replace(url + '?' + action);
    }

    var searchBarForm = document.getElementById('#navigationSearchForm');
    var searchInput = document.getElementById('#search-box');
    var searchButton = $('#navigationSearchForm .search-button');

    if (navigationSearchForm.get(0)) {
        navigationSearchForm.on('submit', submitNavbarSearch);
        searchButton.on('click', submitNavbarSearch);

        // add "enter/return" key to trigger submitting the navbar search form
/*
        searchInput.addEventListener('keydown', function (event) {
            var key = event.which;
            if(key == 13){
                submitNavbarSearch(event);
            }
        });
*/
    }

    /**
     * return serialized values of checked filters with name
     * @param {String} name
     * @returns {String}
     */
    function serializeFiltersByName (form, name) {
        var filter = form.serialize();
        if (filter === '') { return ''; }
        return '&' + filter;
    }

    /**
     * reload page with all filters added as GET-parameters
     * @param {Event} event
     */
    function submitSearch (event) {
        event.preventDefault();
        var url = event.target.form ? event.target.form.action : '';
        var action = searchForm.serialize();
        if (administrationsFilter && administrationsFilter.serialize().length) {
            action += '&' + administrationsFilter.serialize();
        }
        if (volumesFilter && volumesFilter.serialize().length) {
            action += '&' + volumesFilter.serialize();
        }
        action += serializeFiltersByName(queryForm, 'match');
        action += serializeFiltersByName(sectionFilter, 'within');

        //aggregate criteria from partial date controls (month day year) into single query param
        if ($('#start_year').val()) {
            var startDate = [
                $('#start_year').val().padStart(4, '0'),
                $('#start_month').val().padStart(2, '0'),
                $('#start_day').val().padStart(2, '0')
            ];
            action += '&start_date=' + startDate.join('-');
        }
        if ($('#end_year').val()) {
            var endDate = [
                $('#end_year').val().padStart(4, '0'),
                $('#end_month').val().padStart(2, '0'),
                $('#end_day').val().padStart(2, '0')];
            action += '&end_date=' + endDate.join('-');
        }
        
        //aggregate criteria from partial time controls (hh mm) into single query param
        if ($('#start_hour').val()) {
            var startTime = [
                $('#start_hour').val().padStart(2, '0'),
                $('#start_minute').val().padStart(2, '0')
            ];
            console.log('start time ' + startTime)
            action += '&start_time=' + startTime.join(':');
        }
        if ($('#end_hour').val()) {
            var endTime = [
                $('#end_hour').val().padStart(2, '0'),
                $('#end_minute').val().padStart(2, '0')
            ];
            action += '&end_time=' + endTime.join(':');
        }

        var currentActiveSorting = sortingForm.find('.active');
        if (currentActiveSorting && currentActiveSorting.attr('id')) {
            action += '&sort-by=' + currentActiveSorting.attr('id');
        }
        window.location.replace(url + '?' + action);
    }

    if (mainForm.get(0)) {

        //TODO refactor and cover cases of empty day/month
        //split aggregated date query and set up values for partial date controls
        var startDate = dateFilter.find('input[name="start_date"]').val();
        if(startDate) {
            var splitStartDate = startDate.split('-');
            $('#start_year').val(splitStartDate[0]);
            $('#start_month').val(splitStartDate[1]);
            $('#start_day').val(splitStartDate[2]);
        }

        var endDate = dateFilter.find('input[name="end_date"]').val();
        if(endDate) {
            var splitEndDate = endDate.split('-');
            $('#end_year').val(splitEndDate[0]);
            $('#end_month').val(splitEndDate[1]);
            $('#end_day').val(splitEndDate[2]);
        }

        var startTime = dateFilter.find('input[name="start_time"]').val();
        if(startTime) {
            var splitStartTime = startTime.split(':');
            $('#start_hour').val(splitStartTime[0]);
            $('#start_minute').val(splitStartTime[1]);
        }
        
        var endTime = dateFilter.find('input[name="end_time"]').val();
        if(endTime) {
            var splitEndTime = endTime.split(':');
            $('#end_hour').val(splitEndTime[0]);
            $('#end_minute').val(splitEndTime[1]);
        }


        // submit the search form
        mainForm.on('submit', submitSearch);
        mainButton.on('click', submitSearch);

        // add "enter/return" key to trigger submitting the search form
        document.addEventListener('keydown', function (event) {
        var key = event.which;
            if(key == 13){
                submitSearch(event);
            }
        });
    }

    // Reset filters (checkboxes)
    var filterInputs = formFilters.find('input'),
        dateReset = formFilters.find('#dateReset'),
        filterReset = formFilters.find('#filterResetButton');

    /**
     * Reset all filters in filter form
     */
    function resetFilter (event) {
        event.preventDefault();
        filterInputs.attr('checked', false);
        console.log("Date Filter", dateFilter.find("#start_hour").val());
        dateFilterInputs.val(' ');
    }
    filterReset.on('click', resetFilter);

    /**
     * Toggle activation of options "search entire site" or selected "sections"
     */
    var global = $('.global'),
        sections = $('.section');

    global.on("change", function() {
        toggleAllSections(this.checked);
    });

    sections.on("change", function() {
        if (allSelected()) {
            global.prop('checked', true);
            toggleAllSections(true);
            return
        }
        global.prop('checked', false);
    });

    function toggleAllSections(state) {
        sections.prop("checked", !state);
    }

    function allSelected() {
        return sections.filter(':checked').size() === sections.size();
    }

    // Return all filters unchecked except for input "Historical Documents"
    function allSelectedButDocuments() {
        return sections.not(documentsInput).filter(':checked').size() === 0;
    }

    /**
     * Toggle visibility of date/administrations/volumes components,
     * if sections input "Historical Documents" is checked or not
     */
    var documentsInput = $('input#documents'), // "Historical Documents" input in "filter by section"
        sectionsInputs = $('#sectionFilter input'), // all inputs in "filter by section"
        toggledComponents = $('.hsg-filter-toggle'); // components to be toggled

    function toggleComponents () {
        if (documentsInput.is( ":checked" ) && allSelectedButDocuments()) {
            toggledComponents.removeClass("hsg-hidden");
            toggledComponents.addClass("hsg-active");
            console.log("Date: ", $('.hsg-filter-toggle').data());
        }
        else {
            toggledComponents.addClass("hsg-hidden");
            toggledComponents.removeClass("hsg-active");
            console.log("Date: ", $('.hsg-filter-toggle').data());
        }
    }

    sectionsInputs.on('change', function() {
        toggleComponents();
    });

    //------------------------------------------//

    function initContent() {
        $(".content .note").popover({
            html: true,
            trigger: "hover click",
            placement: "auto bottom",
            viewport: "#content-container",
            content: function() {
                var fn = document.getElementById(this.hash.substring(1));
                return $(fn).find(".fn-content").html();
            }
        });
        $(".content .note, .content .fn-back").click(function(ev) {
            ev.preventDefault();
            var fn = document.getElementById(this.hash.substring(1));
            fn.scrollIntoView();
        });
        $(".content .alternate").each(function() {
            $(this).popover({
                content: $(this).find(".altcontent").html(),
                trigger: "hover click",
                html: true
            });
        });
        initNavigation(".content .section-link");
    }

    function initNavigation(selector) {
        // click on page navigation previous/next buttons
        $(selector).click(function(ev) {
            ev.preventDefault();
            var params = {
                url: this.pathname.replace(new RegExp("^" + appRoot + "(.*)$"), "$1")
                // TODO?: figure out how to pass publication-id back to frus-ajax.xql
            };
            if (historySupport) {
                history.pushState(null, null, this.href);
            }
            load(params, this.className.split(" ")[0], this.hash);
        });
    }

    function highlightToc(activeId) {
        $("#toc li a").removeClass("highlight");
        $("#toc-" + activeId).addClass("highlight");
    }

    function showContent(container, animIn, animOut, id) {
        if (!id) {
            window.scrollTo(0,0);
        }
        container.removeClass("animated " + animOut);
        container.addClass("animated " + animIn).one("webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend", function() {
            $(this).removeClass("animated " + animIn);
            if (id) {
                var target = document.getElementById(id.substring(1));
                target && target.scrollIntoView();
            }
        });
    }

    // select volume or administration from dropdown
    $("#select-volume, #select-administration, #select-country, #select-chapter").change(function(ev) {
        window.location = $(this).val();
    });

    $("#zoom-in").click(function(ev) {
        ev.preventDefault();
        var size = getFontSize();
        $("#content-inner").css("font-size", (size + 1) + "px");
    });
    $("#zoom-out").click(function(ev) {
        ev.preventDefault();
        var size = getFontSize();
        $("#content-inner").css("font-size", (size - 1) + "px");
    });

    $(window).on("popstate", function(ev) {
        var params = {
            url: window.location.pathname.replace(new RegExp("^" + appRoot + "(.*)$"), "$1")
        };
        console.log("popstate: %s", params.url);
        load(params);
    });

    $("#collapse-sidebar").click(function(ev) {
        $("#sidebar").toggleClass("hidden");
        if ($("#sidebar").is(":visible")) {
            $("#right-panel").removeClass("col-md-12").addClass("col-md-9 col-md-offset-3");
        } else {
            $("#right-panel").addClass("col-md-12").removeClass("col-md-9 col-md-offset-3");
        }
    });

    initNavigation("#content .page-nav, .content .section-link, #toc .toc-link, #person-panel a, #gloss-panel a");
    initContent();

    $('[data-toggle="tooltip"]').tooltip({placement: "auto top"});
    toggleComponents();
});
