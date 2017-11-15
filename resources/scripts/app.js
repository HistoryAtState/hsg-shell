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

    var searchForm = $('#searchForm');
    var queryForm = $('#queryFilters');

    /**
     * return serialized values of checked filters in filterForm with name
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
        var action = searchForm.serialize();
        action += serializeFiltersByName(queryForm, 'match');
        window.location.replace('?' + action);
    }

    if (searchForm.get(0)) {
        searchForm.on('submit', submitSearch);
        queryForm.find('input').on('change', submitSearch);
    }

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
});
