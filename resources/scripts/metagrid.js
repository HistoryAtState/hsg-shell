$(document).ready(function () {

    // perhaps the regexp could be more strict and accept only lowercase characters and hyphen?
    // something like:
    // var personId = window.location.href.match(/\/departmenthistory\/people\/([a-z\-]+)$/i);
    var personId = window.location.href.match(/\/departmenthistory\/people\/([^/#]+)$/i);

    $.getJSON('https://api.metagrid.ch/widget/history-state/person/' + personId[1] + '.json?lang=en&include=true&jsoncallback=?', function (data) {
        if (data[0]) {
            $("#metagrid").show();

            $.each(data[0], function (index, value) {
                $('<li>').attr({
                    class: 'metagrid hsg-list-group-item'
                }).append('<a>').appendTo('#metagrid-container');
                $('#metagrid-container li:last-child a').attr({
                    title: value.short_description, href: value.url
                }).text(index);
            });
        }
    });
});