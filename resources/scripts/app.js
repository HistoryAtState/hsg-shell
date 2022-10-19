$(document).ready(function($) {
    var historySupport = !!(window.history && window.history.pushState);
    var appRoot = $("html").attr("data-app");

    var osd_viewer = $('.osd-wrapper #viewer'),
        documentId = osd_viewer.attr('data-doc-id'),
        facsId     = osd_viewer.attr('data-facs'),
        scheme     = 'http',
        server     = 'localhost:8182', // Local Cantaloupe image server for development
        debugMode  = false;


    // http://openseadragon.github.io/docs/OpenSeadragon.html#.Options
    var isConnected = $( "#viewer" ).get(0);
    //if ( $( "#viewer" ).get(0) === undefined ) { console.log('No viewer') };

    if ($("#viewer").get(0) != undefined) {
      console.log('Image URI=', scheme + '://' + server + '/iiif/3/' + documentId + '%2Ftiff%2F' + facsId + '.tif')

      var viewer = OpenSeadragon({
          id:                   "viewer",
          prefixUrl:            "resources/images/OSD-icons/",
          preserveViewport:     true,
          visibilityRatio:      1,
          //minZoomLevel:         1,
          minZoomImageRatio:    0.9,
          defaultZoomLevel:     1,
          sequenceMode:         true,
          showNavigator:        true,
          navigatorHeight:      "120px",
          navigatorWidth:       "80px",
          showSequenceControl:  false,
          debugMode:            debugMode,
          tileSources:   [{
            "@context": "http://iiif.io/api/image/3/context.json",
            "@id":      scheme + "://" + server + "/iiif/3/" + documentId + "%2Ftiff%2F" + facsId + ".tif",
            "height":   5476,
            "width":    3547,
            "maxArea":  10000000,
            "profile":  [ "http://iiif.io/api/image/2/level2.json" ],
            "protocol": "http://iiif.io/api/image",
            "tiles": [{
              "scaleFactors": [ 1, 2, 4, 8, 16, 32 ],
              "width":        512,
              "height":       512
            }]
          }]
      });
    }

    // https://github.com/uxitten/polyfill/blob/master/string.polyfill.js
    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/padStart
    if (!String.prototype.padStart) {
        String.prototype.padStart = function padStart(targetLength,padString) {
            targetLength = targetLength>>0; //truncate if number or convert non-number to 0;
            padString = String((typeof padString !== 'undefined' ? padString : ' '));
            if (this.length > targetLength) {
                return String(this);
            }
            else {
                targetLength = targetLength-this.length;
                if (targetLength > padString.length) {
                    padString += padString.repeat(targetLength/padString.length); //append to original to ensure we are longer than needed
                }
                return padString.slice(0,targetLength) + String(this);
            }
        };
    }

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
                    // Check if an image viewer is requested,
                    // needs a reload to request & initialize Openseadragon!
                    if (data.viewer) {
                      location.reload();
                    }
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
                    // FIXME: Currently not initialized fn
                    //ga('send', 'pageview');
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
        mainButton = $('.hsg-main-search-button'), // main search button
        applyFiltersButton = $('#filterApplyButton'); // apply filters button in sidebar
        applyDateFiltersButton = $('#dateApply'); // apply date filter button in sidebar

    /**
     * Submit query from navigation search form, redirect to "search/"
     * @param {Event} event
     */
    function submitNavbarSearch (event) {
        event.preventDefault();
        event.stopPropagation();
        var url = navigationSearchForm.prop("action");
        var action = navigationSearchForm.serialize();
        history.pushState({}, '', window.location.href);
        window.location.replace(url + '?' + action);
    }

    var searchInput = $('#search-box');
    var searchButton = $('#navigationSearchForm .search-button');

    if (navigationSearchForm.get(0)) {
        navigationSearchForm.on('submit', submitNavbarSearch);
        searchButton.on('click', submitNavbarSearch);

        // add "enter/return" key to trigger submitting the navbar search form

        searchInput.on('keydown', function (event) {
            var key = event.which;
            if(key == 13) {
                submitNavbarSearch(event);
            }
        });
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

    function adjustDateComponent(component, pad) {
        try {
            var c = parseInt(component);
            if (c === 0) {
                c = 1;
            }
            return c.toString().padStart(pad, '0');
        } catch(e) {
            return '01'.padStart(pad, '0');
        }
    }

    function getDateComponent(prefix) {
        var year = $('#' + prefix + '_year').val();
        if (year) {
            var month = $('#' + prefix + '_month').val();
            var day = $('#' + prefix + '_day').val();
            if (month) {
                if (day) {
                    return adjustDateComponent(year, 4) + '-' + adjustDateComponent(month, 2) + '-' +
                        adjustDateComponent(day, 2);
                } else {
                    return adjustDateComponent(year, 4) + '-' + adjustDateComponent(month, 2);
                }
            } else {
                return adjustDateComponent(year, 4);
            }
        }
        return null;
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
        var startDate = getDateComponent('start');
        if (startDate) {
            action += '&start-date=' + startDate;
        }

        var endDate = getDateComponent('end');
        if (endDate) {
            action += '&end-date=' + endDate;
        }

        var startTimePmSwitch = $('#start_time_pm').is(':checked');
        //aggregate criteria from partial time controls (hh mm) into single query param
        if ($('#start_hour').val()) {
            var startHour = parseInt($('#start_hour').val());
            if (startHour < 12 && startTimePmSwitch) { startHour+=12}
            var startTime = [
                startHour.toString().padStart(2, '0'),
                $('#start_minute').val().padStart(2, '0')
            ];
            console.log('start time ' + startTime)
            action += '&start-time=' + startTime.join(':');
        }

        var endTimePmSwitch = $('#end_time_pm').is(':checked');
        if ($('#end_hour').val()) {
            var endHour = parseInt($('#end_hour').val());
            if (endHour < 12 && endTimePmSwitch) { endHour+=12}
            var endTime = [
                endHour.toString().padStart(2, '0'),
                $('#end_minute').val().padStart(2, '0')
            ];
            action += '&end-time=' + endTime.join(':');
        }

        var currentActiveSorting = sortingForm.find('#sorting');
        action += '&sort-by=' + currentActiveSorting.prop('value');
        history.pushState({}, '', window.location.href);
        window.location.replace(url + '?' + action);
    }

    if (searchForm.get(0)) {

        //TODO refactor and cover cases of empty day/month
        //split aggregated date query and set up values for partial date controls
        var startDate = dateFilter.find('input[name="start-date"]').val();
        if(startDate) {
            var splitStartDate = startDate.split('-');
            $('#start_year').val(splitStartDate[0]);
            $('#start_month').val(splitStartDate[1]);
            $('#start_day').val(splitStartDate[2]);
        }

        var endDate = dateFilter.find('input[name="end-date"]').val();
        if(endDate) {
            var splitEndDate = endDate.split('-');
            $('#end_year').val(splitEndDate[0]);
            $('#end_month').val(splitEndDate[1]);
            $('#end_day').val(splitEndDate[2]);
        }

        var startTime = dateFilter.find('input[name="start-time"]').val();
        if(startTime) {
            var splitStartTime = startTime.split(':');
            var startHour = parseInt(splitStartTime[0]);
            if (startHour > 12) {
                startHour -= 12;
                $('#start_time_pm').prop('checked', true);
            } else {
                $('#start_time_am').prop('checked', true);
            }
            $('#start_hour').val(startHour);
            $('#start_minute').val(splitStartTime[1]);
        }

        var endTime = dateFilter.find('input[name="end-time"]').val();
        if(endTime) {
            var splitEndTime = endTime.split(':');
            var endHour = parseInt(splitEndTime[0]);
            if (endHour > 12) {
                endHour -= 12;
                $('#end_time_pm').prop('checked', true);
            } else {
                $('#end_time_am').prop('checked', true);
            }
            $('#end_hour').val(endHour);
            $('#end_minute').val(splitEndTime[1]);
        }

        // submit the search form
        applyFiltersButton.on('click', submitSearch);
        applyDateFiltersButton.on('click', submitSearch);
        mainForm.on('submit', submitSearch);
        mainButton.on('click', submitSearch);

        // add "enter/return" key to trigger submitting the search form
        $(document).on('keydown', function (event) {
            var key = event.which;
            if(key == 13) {
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
        //console.log("Date Filter", dateFilter.find("#start_hour").val());
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
            //console.log("Date: ", $('.hsg-filter-toggle').data());
        }
        else {
            toggledComponents.addClass("hsg-hidden");
            toggledComponents.removeClass("hsg-active");
            //console.log("Date: ", $('.hsg-filter-toggle').data());
        }
    }

    sectionsInputs.on('change', function() {
        toggleComponents();
    });

    /**
     *  sort-by filter
     */
    $('#sort-by li').on('click', function(ev) {
        ev.preventDefault();
        var item = $(ev.target);
        $('#sort-by-label').text(item.text());
        $('#sorting').val(item.attr('id'));
        submitSearch(ev);
    });

    /**
     * Truncate filter lists: show only 3 first inputs of a list
     * Toggle between show more / show less
     */
    var toggle  = $(".hsg-toggle");
    var link = $("div.hsg-toggle a.c-link-more");
    var toggledList = $("div.truncate-filter");

    function toggleClassNames () {
        if(toggledList.hasClass("hideContent")) {
            toggledList.removeClass("hideContent");
            toggledList.addClass("showContent");
            link.text("Show less");
            link.addClass("is-open");
        }
        else {
            toggledList.addClass("hideContent");
            toggledList.removeClass("showContent");
            link.text("Show more");
            link.removeClass("is-open");
        }
    }

    toggle.on("click", function(event) {
        toggleClassNames();
        event.preventDefault();
    });

    /**
     * Check if class hideContent is present in the filter volumes list.
     * If so, display the "show more" link, if not, hide the link
     */
    var volumeList = $('.truncate-filter');

    function toggleShowMoreLink() {
        if(volumeList.hasClass("hideContent")) {
            toggle.removeClass('hsg-hidden');
        }
        else {
            toggle.addClass('hsg-hidden');
        }
    }

    //------------------------------------------//

    function initContent() {
        window.initFootnotes();
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
        //console.log("popstate: %s", params.url);
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
    toggleShowMoreLink();
});