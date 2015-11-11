$(document).ready(function() {
    var historySupport = !!(window.history && window.history.pushState);
    var appRoot = $("html").data("app");
    
    function resize() {
        var wh = ($(window).height()) / 2;
        $(".page-nav").css("top", wh);
        $(".nav-prev").css("left", $("#content-inner").offset().left);
        $(".nav-next").css("left", $("#content-inner").offset().left + $("#content-inner").width() - 60);
        var tw = $(".toc").width();
        $(".toc").css("max-width", tw);
    }
    
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
                    if (data.breadcrumbSection) {
                        $(".breadcrumb .section").text(data.breadcrumbSection);
                    }
                    if (data.persons) {
                        $("#person-panel .list-group").replaceWith(data.persons).show();
                        initNavigation("#person-panel a");
                        $('#person-panel a').tooltip({placement: "auto top"});
                        $("#person-panel").show();
                    } else {
                        $("#person-panel").hide();
                    }
                    if (data.gloss) {
                        $("#gloss-panel .list-group").replaceWith(data.gloss);
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
                    highlightToc(data.tocCurrent);
                    if (data.next) {
                        $(".nav-next").attr("href", data.next).css("visibility", "");
                    } else {
                        $(".nav-next").css("visibility", "hidden");
                    }
                    if (data.previous) {
                        $(".nav-prev").attr("href", data.previous).css("visibility", "");
                    } else {
                        $(".nav-prev").css("visibility", "hidden");
                    }
                    showContent(container, animIn, animOut, id);
                }
            });
        });
    }
    
    function initContent() {
        $(".content .note").popover({
            html: true,
            trigger: "hover",
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
                trigger: "hover",
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
    
    function isMobile() {
      try{ document.createEvent("TouchEvent"); return true; }
      catch(e){ return false; }
    }
    
    resize();
    
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
    }).on("resize", resize);
    
    $("#collapse-sidebar").click(function(ev) {
        $("#sidebar").toggleClass("hidden");
        if ($("#sidebar").is(":visible")) {
            $("#right-panel").removeClass("col-md-12").addClass("col-md-9 col-md-offset-3");
        } else {
            $("#right-panel").addClass("col-md-12").removeClass("col-md-9 col-md-offset-3");
        }
        resize();
    });
    
    if (isMobile()) {
        $("#content-container").swipe({
            swipe: function(event, direction, distance, duration, fingerCount, fingerData) {
                var nav;
                if (direction === "left") {
                    nav = $(".nav-next").get(0);
                } else if (direction === "right") {
                    nav = $(".nav-prev").get(0);
                } else {
                    return;
                }
                var params = {
                    url: nav.pathname.replace(/^.*\/([^/]+\/[^/]+)$/, "$1") + "&" + nav.search.substring(1)
                };
                if (historySupport) {
                    history.pushState(null, null, nav.href);
                }
                load(params, nav.className.split(" ")[0]);
            },
            allowPageScroll: "vertical"
        });
    }
    
    initNavigation("#content .page-nav, .content .section-link, #toc .toc-link, #person-panel a, #gloss-panel a");
    initContent();
    
    $('[data-toggle="tooltip"]').tooltip({placement: "auto top"});
});