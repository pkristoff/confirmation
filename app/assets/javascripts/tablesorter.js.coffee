$(document).ready ->
  $ ->
    $.extend $.tablesorter.defaults,
      widgets: [
        "zebra"
        "columns"
      ]
    $("#candidate_list_table").tablesorter({
      sortList:[[1,0]],
      theme: 'bootstrap',
      headerTemplate: '{content}{icon}',
      theme: 'blue'
    })

    return