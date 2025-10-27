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
                } else {
                }
                column_sorting('reset')
                break;
        }
    }
}()


setup_filter_and_sort_binding = function () {
    let candidate_list_table = $("#candidate_list_table")
    candidate_list_table.bind("sortStart", function () {
            column_sorting('sort_started');
        }).bind("sortEnd", function (event, ui) {
            column_sorting('sort_finished');
            console.log('sort_finished');
            let table_info_arr = generate_filter();
            save_filters_and_sorting(table_info_arr,
                function (response) {
                    console.log('success')
                },
                function (response) {
                    console.log('error')
                });
        });
    candidate_list_table.on('filterEnd', function () {
        console.log('filterEnd');
        save_filters_and_sorting(generate_filter(),
            function (response) {
                console.log('success')
            },
            function (response) {
                console.log('error')
            }
        )
    })
}

save_filters_and_sorting = function (table_info_arr, success, error) {
    console.log(table_info_arr);
    let table_info_str = JSON.stringify(table_info_arr)

    let div_admin_id = document.getElementById("admin_id").innerText
    let url = '/admins/'.concat(div_admin_id, '/update_filter_and_sorting')

    $.ajax({
        url: url,
        type: 'PUT',
        data: {
            admin: {
                id: $("#admin_id")[0].innerText,
                table_filter_and_sorting_columns: table_info_str
            }
        },
        success: function (response) {
            console.log('success');
            div_text = document.getElementById("table_filter_and_sorting_columns_id")
            div_text.innerText = table_info_str;
        },
        error: error
    });
}

initialize_sorting_and_filters = function (columns) {

    columns.forEach(update_column);

    function update_column(column_info) {
        let column_name = column_info['column_name'];
        let filter = column_info['filter'];
        let offset_table_name = document.getElementById("offset_id").innerText
        console.log('Column_name='.concat(column_name))
        let data_column_offset_lu = column_offset(column_name, offset_table_name);
        console.log(' ,data_column_offset LU:  ('.concat(')').concat(data_column_offset_lu))
        let data_column_offset_old = column_info['data_column_offset'];
        console.log('   data_column_offset old: '.concat(data_column_offset_old))
        let column_sort = column_info['Sort'] || column_info['sort'];
        update_column_sorting_and_filters(data_column_offset_lu, column_name, filter, column_sort)
    }
}

function column_offset(column_name, table_name) {
    if (table_name.includes('adhoc_offset')) {
        return adhoc_offset[column_name];
    } else if (table_name.includes('candidates_offset')) {
        return candidates_offset[column_name];
    } else if (table_name.includes('monthly_offset') ){
        return adhoc_offset[column_name];
    } else {
       throw new Error('Unknown column offset table'.concat(table_name))
    }
}

generate_filter = function () {
    let candidate_list_table = $("#candidate_list_table")
    let th_class;
    let th;
    let th_prime;
    if (candidate_list_table.length > 0) {

        let ths = candidate_list_table.find("th");
        let table_info_arr = [];
        for (let i = 0; i < ths.length; i++) {
            th = ths[i];

            th_class = th.getAttribute('class');
            if (!th.getAttribute('aria-label').includes('sorting is disabled')) {
                let column_name = th.getElementsByClassName("tablesorter-header-inner")[0].textContent
                th_prime = candidate_list_table.find("th:contains(".concat(column_name).concat(")"))

                let entry = {}
                table_info_arr.push(entry);
                entry["column_name"] = column_name;
                entry['data_column_offset'] = th.getAttribute('data-column')
                entry['sort'] = th.getAttribute('aria-sort');
                let statusColumnInput = document.querySelector('thead>tr>td>input[data-column="'.concat(entry['data_column_offset']).concat('"]'));
                entry['filter'] = statusColumnInput.value
            }
        }
        // aaa = ths[1].getElementsByClassName("tablesorter-header-inner")[0].textContent
        console.log('table_info_arr');
        console.log(table_info_arr);
        let statusColumnInput = document.querySelector('thead>tr>td>input[data-column="'.concat("1").concat('"]'));
        console.log(statusColumnInput.value);
        return table_info_arr
    } else {
        console.log('candidate list table does not exist now')
    }
}


var candidates_offset = {}
candidates_offset["Status "] = '1'
candidates_offset["Last name "] = '4'
candidates_offset["First name "] = '5'
candidates_offset["Grade "] = '6'
candidates_offset["Program Year "] = '7'
candidates_offset["Attending "] = '8'
candidates_offset["Covenant Agreement "] = '9'
candidates_offset["Information Sheet "] = '10'
candidates_offset["Baptismal Certificate "] = '11'
candidates_offset["Sponsor's Covenant "] = '12'
candidates_offset["Sponsor's Eligibility "] = '13'
candidates_offset["Confirmation Name "] = '14'
candidates_offset["Christian Ministry "] = '15'
candidates_offset["Attend Retreat "] = '16'
candidates_offset["Parent Information Meeting "] = '17'
candidates_offset["Account Confirmed "] = '18'
candidates_offset["Password Changed "] = '19'

var adhoc_offset = {}
adhoc_offset["Status "] = '1'
adhoc_offset["Last name "] = '2'
adhoc_offset["First name "] = '3'
adhoc_offset["Grade "] = '4'
adhoc_offset["Program Year "] = '5'
adhoc_offset["Attending "] = '6'
adhoc_offset["Covenant Agreement "] = '7'
adhoc_offset["Information Sheet "] = '8'
adhoc_offset["Baptismal Certificate "] = '9'
adhoc_offset["Sponsor's Covenant "] = '10'
adhoc_offset["Sponsor's Eligibility "] = '11'
adhoc_offset["Confirmation Name "] = '12'
adhoc_offset["Christian Ministry "] = '13'
adhoc_offset["Attend Retreat "] = '14'
adhoc_offset["Parent Information Meeting "] = '15'
adhoc_offset["Account Confirmed "] = '16'
adhoc_offset["Password Changed "] = '17'
adhoc_offset["Attend Retreat "] = '18'

var monthly_offset = {}
monthly_offset["Status "] = '1'
monthly_offset["Last name "] = '2'
monthly_offset["First name "] = '3'
monthly_offset["Grade "] = '4'
monthly_offset["Program Year "] = '5'
monthly_offset["Attending "] = '6'
monthly_offset["Covenant Agreement "] = '7'
monthly_offset["Information Sheet "] = '8'
monthly_offset["Baptismal Certificate "] = '9'
monthly_offset["Sponsor's Covenant "] = '10'
monthly_offset["Sponsor's Eligibility "] = '11'
monthly_offset["Confirmation Name "] = '12'
monthly_offset["Christian Ministry "] = '13'
monthly_offset["Attend Retreat "] = '14'
monthly_offset["Parent Information Meeting "] = '15'
monthly_offset["Account Confirmed "] = '16'
monthly_offset["Password Changed "] = '17'
monthly_offset["Attend Retreat "] = '18'

update_column_sorting_and_filters = function (data_column_offset, column_name, filter, column_sort) {
    // console.log(document.cookies['x']);
    let candidate_list_table = $("#candidate_list_table")
    if (candidate_list_table.length > 0) {
        console.log('candidate list table exists now')
        if (column_sort === 'descending') {
            candidate_list_table.find("th:contains(".concat(column_name).concat(")")).trigger("sort");
            candidate_list_table.find("th:contains(".concat(column_name).concat(")")).trigger("sort");
        }
        if (column_sort === 'ascending') {
            x = candidate_list_table.find("th:contains(".concat(column_name).concat(")"));
            x.trigger("sort")
        }
        let statusColumnInput = document.querySelector('thead>tr>td>input[data-column="'.concat(data_column_offset).concat('"]'));
        if (statusColumnInput != null){
            statusColumnInput.value = filter;
            // table.config.widgetOptions.filter_initialized
            $('table')[0].config.widgetOptions.filter_initialized = true
            candidate_list_table.trigger('search', [filter]);
        }
    } else {
        console.log('candidate list table does not exist now')
    }
}

confirmation_toggle = function () {

    function instructions(e) {
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
