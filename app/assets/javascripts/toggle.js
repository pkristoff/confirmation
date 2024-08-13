/**
 * Created by paulkristoff on 9/1/16.
 */

update_completed_date = function (my_id) {
    var comp_id = my_id.replace('verified', 'completed_date'),
        input_element = document.getElementById(comp_id),
        current_value = input_element.value;
    if (!current_value || 0 === current_value.length) {
        var date = new Date(),
            day = date.getDate(),
            month = date.getMonth() + 1,
            year = date.getFullYear();

        if (month < 10) month = "0" + month;
        if (day < 10) day = "0" + day;

        document.getElementById(comp_id).value = year + "-" + month + "-" + day;
    }
};

select_all_none = function (id) {
    var check_all = document.getElementById(id).checked,
        checkboxes = document.querySelectorAll('tr[class="odd"]>td>input[type=checkbox]');
    for (let i = 0, len = checkboxes.length; i < len; i++) {
        checkboxes[i].checked = check_all;
    }
    checkboxes = document.querySelectorAll('tr[class="even"]>td>input[type=checkbox]');
    for (let i = 0, len = checkboxes.length; i < len; i++) {
        checkboxes[i].checked = check_all;
    }
    update_total_selections();
};

update_total_selections = function () {
    let checkboxes = document.querySelectorAll('tbody>tr>td>input[type=checkbox]'),
        count = 0;
    for (i = 0, len = checkboxes.length; i < len; i++) {
        if (checkboxes[i].checked) {
            count++;
        }
    }
    let x = document.querySelector('input[id=total_selected]');
    if (x) {
        x.value = count;
    }
};

column_sorting = function () {
    let is_column_sorting = false;
    return function (do_what) {
        switch (do_what) {
            case 'reset':
                is_column_sorting = false;
                // console.log('reset')
                break;
            case 'sort_starting':
                // console.log('sort_starting')
                break;
            case 'sort_happening':
                is_column_sorting = true;
                // console.log('sorting happening:'.concat(is_column_sorting.toString()))
                break;
            case 'sort_finished':
                if (is_column_sorting) {
                    // console.log('sorting finished:  '.concat('true'))
                    let ans = generate_filter();
                    update_filters(ans)
                } else {
                    // console.log('sorting finished:  '.concat('false'))
                }
                column_sorting('reset')
                break;
        }
    }
}
()

setup_filter = function () {
    // $("table").bind("sortStart",function() {
    $("#candidate_list_table").bind("sortStart", function () {
        column_sorting('sort_started');
    }).bind("sortEnd", function (event, ui) {
        column_sorting('sort_finished');
    });
    $("#candidate_list_table") .on('filterEnd', function () {
        let ans = generate_filter();
        update_filters(ans);
    })
}

save_filters_and_sorting = function (){
    console.log('saving filters to admin')
    console.log('implement me.')
}

update_filters = function (columns) {

    columns.forEach(myFunction);

    // generate_filter();

    function myFunction(column_info, index, array) {
        let column_name = column_info['column_name'];
        let filter = column_info['filter'];
        let data_column_offset = column_info['data_column_offset'];
        let column_sort = column_info['Sort'] || column_info['sort'];
        update_filter(data_column_offset, column_name, filter, column_sort)
    }
}

generate_filter = function () {
    let candidate_list_table = $("#candidate_list_table")
    let th_class;
    let th;
    let thprime;
    if (candidate_list_table.length > 0) {

        let ths = candidate_list_table.find("th");
        let ans = [];
        for (let i = 0; i < ths.length; i++) {
            th = ths[i];

            // console.log(th)
            th_class = th.getAttribute('class');
            // console.log(th_class)
            // console.log(th.getAttribute('aria-label').includes('sorting is disabled'));
            if (! th.getAttribute('aria-label').includes('sorting is disabled')) {
                column_name = th.getElementsByClassName("tablesorter-header-inner")[0].textContent
                thprime = candidate_list_table.find("th:contains(".concat(column_name).concat(")"))

                let entry = {}
                ans.push(entry);
                entry["column_name"] = column_name;
                entry['data_column_offset'] = th.getAttribute('data-column')
                let sort = th.getAttribute('aria-sort')
                entry['sort'] = sort;
                let statusColumnInput = document.querySelector('thead>tr>td>input[data-column="'.concat(entry['data_column_offset']).concat('"]'));
                entry['filter'] = statusColumnInput.value
            }
        }
        // aaa = ths[1].getElementsByClassName("tablesorter-header-inner")[0].textContent
        console.log('ans');
        console.log(ans);
        let statusColumnInput = document.querySelector('thead>tr>td>input[data-column="'.concat("1").concat('"]'));
        console.log(statusColumnInput.value);
        return ans
    } else {
        console.log('candidate list table does not exist now')
    }
}

update_filter = function (data_column_offset, column_name, filter, column_sort) {
    // console.log(document.cookies['x']);
    let candidate_list_table = $("#candidate_list_table")
    if (candidate_list_table.length > 0) {
        console.log('candidate list table exists now')
        if (column_sort === 'des') {
            candidate_list_table.find("th:contains(".concat(column_name).concat(")")).trigger("sort");
            candidate_list_table.find("th:contains(".concat(column_name).concat(")")).trigger("sort");
        }
        if (column_sort === 'asc') {
            x = candidate_list_table.find("th:contains(".concat(column_name).concat(")"));
            x.trigger("sort")
        }
        let statusColumnInput = document.querySelector('thead>tr>td>input[data-column="'.concat(data_column_offset).concat('"]'));
        statusColumnInput.value = filter;
        // table.config.widgetOptions.filter_initialized
        $('table')[0].config.widgetOptions.filter_initialized = true
        candidate_list_table.trigger('search', [filter]);
    } else {
        console.log('candidate list table does not exist now')
    }
    ;
}

confirmation_toggle = function () {

    function instructions( e ) {
        e.preventDefault();
        // expand/collapse
        let div = $('#instructions');
        div.is(':hidden') ? div.show() : div.hide();
        // change icon
        let span = $('#insturction-toggle-span'),
            right_div = $('#right-col'),
            left_div = $('#left-col');
        if (div.is(':hidden')) {
            span.removeClass('glyphicon-minus');
            span.addClass('glyphicon-plus');
            right_div.width('0%');
            left_div.width('100%');
        } else {
            span.removeClass('glyphicon-plus');
            span.addClass('glyphicon-minus');
            right_div.width('50%');
            left_div.width('50%');
        }
    }

    function instructionText(id) {
        let divInst = $(id);
        if (divInst.hasClass('hide-div')) {
            divInst.removeClass('hide-div');
            divInst.addClass('show-div');
        } else {
            divInst.removeClass('show-div');
            divInst.addClass('hide-div');
        }
    }

    function sidebar(e, self) {
        e.preventDefault();
        // toggle the sidebar
        $("#wrapper").toggleClass("toggled");
        // change icon
        if ($(self).data('name') === 'show') {
            $('#menu-toggle-span').replaceWith('<span id="menu-toggle-span">&raquo;</span>');
            $(self).data('name', 'hide')
        } else {
            $('#menu-toggle-span').replaceWith('<span id="menu-toggle-span">&laquo;</span>');
            $(self).data('name', 'show')
        }
    }

    function toggle_top(id, doWhat, id2 = '') {
        let div = $(id);
        let div2 = id2 = '' ? nil : $(id2)
        if (doWhat === 'toggle') {
            div.is(':hidden') ? div.show() : div.hide();
            div2.is(':hidden') ? div2.show() : div2.hide();
        } else if (doWhat === 'hide') {
            div.hide();
        } else if (doWhat === 'show') {
            div.show()
        } else {
            alert('Unknown doWhat = ' + doWhat)
        }
    }

    function update_show_empty_radio(for_type) {
        let ele = document.getElementsByName('candidate[baptismal_certificate_attributes][show_empty_radio]')[0];
        console.log('show_empty_radio before=' + ele.value)
        if (for_type === 'baptism') {
            switch (ele.value) {
                case '0':
                case '1':
                    ele.value = '1';
                    break;
                case '2':
                    ele.value = '1';
                    break;
                default:
                    console.log('Toggle.js Unknown for show_empty_radio' + ele.value)
            }
        } else if (for_type === 'catholic') {
            switch (ele.value) {
                case '0':
                case '1':
                    ele.value = '2';
                    break;
                case '2':
                    ele.value = '2';
                    break;
                default:
                    console.log('Toggle.js Unknown for show_empty_radio' + ele.value)
            }
        } else {
            console.log('Toggle.js Unknown for_type=' + for_type)
        }

        console.log('show_empty_radio after=' + ele.value)

    }

    function update_church_default_values(use_home_parish) {
        var name_dv = use_home_parish ? document.getElementById('dv-home-parish').value : ""
        var street_1_dv = use_home_parish ? document.getElementById('dv-street_1').value : ""
        var street_2_dv = use_home_parish ? document.getElementById('dv-street_2').value : ""
        var city_dv = use_home_parish ? document.getElementById('dv-city').value : ""
        var state_dv = use_home_parish ? document.getElementById('dv-state').value : ""
        var zip_code_dv = use_home_parish ? document.getElementById('dv-zip_code').value : ""
        // document.getElementById("candidate_baptismal_certificate_attributes_church_name").defaultValue = name_dv;
        document.getElementById("candidate_baptismal_certificate_attributes_church_name").value = name_dv;
        document.getElementById("candidate_baptismal_certificate_attributes_church_address_attributes_street_1").value = street_1_dv;
        document.getElementById("candidate_baptismal_certificate_attributes_church_address_attributes_street_2").value = street_2_dv;
        document.getElementById("candidate_baptismal_certificate_attributes_church_address_attributes_city").value = city_dv;
        document.getElementById("candidate_baptismal_certificate_attributes_church_address_attributes_state").value = state_dv;
        document.getElementById("candidate_baptismal_certificate_attributes_church_address_attributes_zip_code").value = zip_code_dv;
    }

    function baptized_yes() {
        // just checked "baptized_at_home_parish_yes_checked"
        toggle_top('#baptized-at-home-parish-info', 'show')
        toggle_top('#baptized-catholic-radios-fieldset', 'hide')
        toggle_top('#baptized-catholic-info', 'show')
        toggle_top('#profession-of-faith-info', 'hide')
        update_show_empty_radio('baptism');
        update_church_default_values(true);
    }

    function baptized_no() {
        // just checked "baptized_at_home_parish_no_checked"
        toggle_top('#baptized-at-home-parish-info', 'show')
        toggle_top('#baptized-catholic-info', 'show')
        toggle_top('#baptized-catholic-radios-fieldset ', 'show')
        if ($('#candidate_baptismal_certificate_attributes_baptized_catholic_1')[0].checked) {
            baptized_catholic_yes();
        } else if ($('#candidate_baptismal_certificate_attributes_baptized_catholic_0')[0].checked) {
            baptized_catholic_no();
        }
        update_show_empty_radio('baptism');
        update_church_default_values(false);
    }

    function baptized_catholic_yes() {
        // just checked "baptized_catholic_yes_checked"
        toggle_top('#baptized-catholic-info', 'show')
        toggle_top('#profession-of-faith-info', 'hide');
        update_show_empty_radio('catholic');
    }

    function baptized_catholic_no() {
        // just checked "baptized_catholic_no_checked"
        toggle_top('#baptized-catholic-info', 'hide')
        toggle_top('#profession-of-faith-info', 'show');
        update_show_empty_radio('catholic');
    }

    function remove_scanned_image(remove_id, root) {
        toggle_top('#scanned-image-' + root, 'hide');
        document.getElementById(remove_id).value = 'Remove';
        toggle_top('#replace-' + root, 'show');
        toggle_top('#remove-' + root, 'hide');
    }

    function replace_scanned_image(remove_id, root) {
        toggle_top('#scanned-image-' + root, 'show');
        document.getElementById(remove_id).value = '';
        toggle_top('#replace-' + root, 'hide');
        toggle_top('#remove-' + root, 'show');
    }

    function scanned_image_chosen(remove_id, root) {
        toggle_top('#scanned-image-' + root, 'hide');
        document.getElementById(remove_id).value = 'Chosen';
        toggle_top('#replace-' + root, 'hide');
        toggle_top('#remove-' + root, 'hide');
    }

    function clear_attached_file() {
        $('#attach-file-container').html($('#attach-file-container').html());
    }

    return {
        baptized_no: baptized_no,
        baptized_yes: baptized_yes,
        baptized_catholic_yes: baptized_catholic_yes,
        baptized_catholic_no: baptized_catholic_no,
        clear_attached_file: clear_attached_file,
        instructions: instructions,
        instructionText: instructionText,
        remove_scanned_image: remove_scanned_image,
        replace_scanned_image: replace_scanned_image,
        scanned_image_chosen: scanned_image_chosen,
        sidebar: sidebar,
        toggle_top: toggle_top
    }
};
