$(document).ready ->
  $ ->
    textMatcher = (e, n, f, i, $r, c, data) ->
      e.toLowerCase() == f.toLowerCase()
    $("#candidate_list_table").tablesorter({
# https://forum.jquery.com/topic/tablesorter-filter-functions-external-select-box-to-filter-by-column

# this will apply the bootstrap theme if "uitheme" widget is included
# the widgetOptions.uitheme is no longer required to be set
      theme: "bootstrap",

      widthFixed: false,

      headerTemplate: '{content} {icon}', # new in v2.7. Needed to add the bootstrap icon!

# widget code contained in the jquery.tablesorter.widgets.js file
# use the zebra stripe widget if you plan on hiding any rows (filter widget)
      widgets: ["uitheme", "filter", "columns", "zebra"],


      sortList: [[2, 0]],
      widthFixed: false,
      widgetOptions: {
# using the default zebra striping class name, so it actually isn't included in the theme variable above
# this is ONLY needed for bootstrap theming if you are using the filter widget, because rows are hidden
        zebra: ["even", "odd"],

# class names added to columns when sorted
        columns: ["primary", "secondary", "tertiary"],

# reset filters button
        filter_reset: ".reset",

# extra css class name (string or array) added to the filter element (input or select)
        filter_cssFilter: "form-control",

# set the uitheme widget to use the bootstrap theme class names
# this is no longer required, if theme is set
# ,uitheme : "bootstrap"
        filter_columnFilters: true,
      }
    })
    init_status_filter();
    update_total_selections();
