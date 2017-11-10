$(document).ready ->
  $ ->
    textMatcher = (e, n, f, i, $r, c, data) ->
      e.toLowerCase() == f.toLowerCase()
    $.extend $.tablesorter.defaults,
      widgets: [
        "zebra"
        "columns"
        "filter"
      ]
    $("#candidate_list_table").tablesorter({
      sortList: [[2, 0]],
      theme: 'blue',
      headerTemplate: '{content}{icon}',
      widthFixed: false,
      widgetOptions: {

# extra css class applied to the table row containing the filters & the inputs within that row
        filter_cssFilter: '',

# If there are child rows in the table (rows with class name from "cssChildRow" option)
# and this option is true and a match is found anywhere in the child row, then it will make that row
# visible; default is false
        filter_childRows: false,

# if true, filters are collapsed initially, but can be revealed by hovering over the grey bar immediately
# below the header row. Additionally, tabbing through the document will open the filter row when an input gets focus
        filter_hideFilters: false,

# Set this option to false to make the searches case sensitive
        filter_ignoreCase: true,

# jQuery selector string of an element used to reset the filters
        filter_reset: '.reset',

# Use the $.tablesorter.storage utility to save the most recent filters
        filter_saveFilters: false,

# Delay in milliseconds before the filter widget starts searching; This option prevents searching for
# every character while typing and should make searching large tables faster.
        filter_searchDelay: 300,

# Set this option to true to use the filter to find text from the start of the column
# So typing in "a" will find "albert" but not "frank", both have a's; default is false
        filter_startsWith: false

      }
    })
    update_total_selections()

    return