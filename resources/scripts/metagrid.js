$(document).ready(function () {

    var personId = window.location.href.match(/\/departmenthistory\/people\/([^/#]+)$/i);
    if (!personID) {
        return;
    };

    $.getJSON('https://api.metagrid.ch/widget/history-state/person/' + personId[1] + '.json?lang=en&include=true&jsoncallback=?', function (data) {
        if (data[0]) {
            $("#metagrid-wrapper").html('<div id="metagrid" class="hsg-panel">' +
                '<div class="hsg-panel-heading">' +
                '<h2 id="metagrid-headline" class="hsg-sidebar-title">Links from Metagrid.ch (beta)</h2>' +
                '</div>' +
                '<ul id="metagrid-container" class="hsg-list-group"></ul>' +
                '</div>');

            $.each(data[0], function (index, value) {
                $('<li><span class="hsg-external-link" aria-hidden="true"></span>').attr({
                    class: 'metagrid hsg-list-group-item'
                }).append('<a>').appendTo('#metagrid-container');
                $('#metagrid-container li:last-child a').attr({
                    title: value.short_description,
                    href: value.url,
                    target: '_blank'
                }).text(index);
            });
        }
    });
});
