/**
 * Created by paulkristoff on 9/1/16.
 */

update_completed_date = function ( my_id ) {
    var comp_id       = my_id.replace( 'verified', 'completed_date' ),
        input_element = document.getElementById( comp_id ),
        current_value = input_element.value;
    if ( !current_value || 0 === current_value.length ) {
        var date  = new Date(),
            day   = date.getDate(),
            month = date.getMonth() + 1,
            year  = date.getFullYear();

        if ( month < 10 ) month = "0" + month;
        if ( day < 10 ) day = "0" + day;

        document.getElementById( comp_id ).value = year + "-" + month + "-" + day;
    }
};

select_all_none = function ( id ) {
    var check_all  = document.getElementById( id ).checked,
        checkboxes = document.querySelectorAll( 'tr[class="odd"]>td>input[type=checkbox]' );
    for ( var i = 0, len = checkboxes.length; i < len; i++ ) {
        checkboxes[ i ].checked = check_all;
    }
    checkboxes = document.querySelectorAll( 'tr[class="even"]>td>input[type=checkbox]' );
    for ( i = 0, len = checkboxes.length; i < len; i++ ) {
        checkboxes[ i ].checked = check_all;
    }
    update_total_selections();
};

update_total_selections = function () {
    var checkboxes = document.querySelectorAll( 'tbody>tr>td>input[type=checkbox]' ),
        count      = 0;
    for ( i = 0, len = checkboxes.length; i < len; i++ ) {
        if ( checkboxes[ i ].checked ) {
            count++;
        }
    }
    var x = document.querySelector( 'input[id=total_selected]' );
    if ( x ) {
        x.value = count;
    }
};

confirmation_toggle = function () {

    function instructions( e ) {
        e.preventDefault();
        // expand/collapse
        var div = $( '#instructions' );
        div.is( ':hidden' ) ? div.show() : div.hide();
        // change icon
        var span      = $( '#insturction-toggle-span' ),
            right_div = $( '#right-col' ),
            left_div  = $( '#left-col' );
        if ( div.is( ':hidden' ) ) {
            span.removeClass( 'glyphicon-minus' );
            span.addClass( 'glyphicon-plus' );
            right_div.width( '0%' );
            left_div.width( '100%' );
        }
        else {
            span.removeClass( 'glyphicon-plus' );
            span.addClass( 'glyphicon-minus' );
            right_div.width( '50%' );
            left_div.width( '50%' );
        }
    }

    function instructionText( id ) {
        var divInst = $( id );
        // console.log('id=' + id);
        if ( divInst.hasClass( 'hide-div' ) ) {
            divInst.removeClass( 'hide-div' );
            divInst.addClass( 'show-div' );
        }
        else {
            divInst.removeClass( 'show-div' );
            divInst.addClass( 'hide-div' );
        }
    }

    function sidebar( e, self ) {
        e.preventDefault();
        // toggle the sidebar
        $( "#wrapper" ).toggleClass( "toggled" );
        // change icon
        if ( $( self ).data( 'name' ) === 'show' ) {
            $( '#menu-toggle-span' ).replaceWith( '<span id="menu-toggle-span">&raquo;</span>' );
            $( self ).data( 'name', 'hide' )
        }
        else {
            $( '#menu-toggle-span' ).replaceWith( '<span id="menu-toggle-span">&laquo;</span>' );
            $( self ).data( 'name', 'show' )
        }
    }

    function toggle_top( id, doWhat, id2 = '' ) {
        var div = $( id );
        var div2 = id2 = '' ? nil : $( id2 )
        if ( doWhat === 'toggle' ) {
            div.is( ':hidden' ) ? div.show() : div.hide();
            div2.is( ':hidden' ) ? div2.show() : div2.hide();
        }
        else if ( doWhat === 'hide' ) {
            div.hide();
        }
        else if ( doWhat === 'show' ) {
            div.show()
        }
        else {
            alert( 'Unknown doWhat = ' + doWhat )
        }
    }

    function update_show_empty_radio( for_type ) {
        var ele = document.getElementsByName( 'candidate[baptismal_certificate_attributes][show_empty_radio]' )[ 0 ];
        if ( for_type === 'baptism' ) {
            if ( ele.value === '0' ) {
                ele.value = '1';
            }
            else if ( ele.value === '1' ) {
                ele.value = '2';
            }
        }
        else {
            console.log( 'Toggle.js Unknown for_type=' + for_type )
        }

        console.log( 'show_empty_radio after=' + ele.value )

    }

    function baptized_yes() {
        toggle_top( '#baptized-at-home-parish-info', 'show' )
        toggle_top( '#baptized-catholic-radios', 'hide' )
        toggle_top( '#baptized-catholic-info', 'hide' )
        toggle_top( '#profession-of-faith-info', 'hide' )
        update_show_empty_radio( 'baptism' );
    }

    function baptized_no() {
        toggle_top( '#baptized-at-home-parish-info', 'show' )
        toggle_top( '#baptized-catholic-radios', 'show' )
        if ( $( '#candidate_baptismal_certificate_attributes_baptized_catholic_1' )[0].checked ) {
            baptized_catholic_yes();
        }
        else if ( $( '#candidate_baptismal_certificate_attributes_baptized_catholic_0' )[0].checked ) {
            baptized_catholic_no();
        }
        update_show_empty_radio( 'baptism' );
    }

    function baptized_catholic_yes() {
        toggle_top( '#baptized-catholic-info', 'show' )
        toggle_top( '#profession-of-faith-info', 'hide' );
        update_show_empty_radio( 'baptism' );
    }

    function baptized_catholic_no() {
        toggle_top( '#baptized-catholic-info', 'hide' )
        toggle_top( '#profession-of-faith-info', 'show' );
        update_show_empty_radio( 'baptism' );
    }

    function remove_scanned_image( remove_id, root ) {
        toggle_top( '#scanned-image-' + root, 'hide' );
        document.getElementById( remove_id ).value = 'Remove';
        toggle_top( '#replace-' + root, 'show' );
        toggle_top( '#remove-' + root, 'hide' );
    }

    function replace_scanned_image( remove_id, root ) {
        toggle_top( '#scanned-image-' + root, 'show' );
        document.getElementById( remove_id ).value = '';
        toggle_top( '#replace-' + root, 'hide' );
        toggle_top( '#remove-' + root, 'show' );
    }

    function scanned_image_chosen( remove_id, root ) {
        toggle_top( '#scanned-image-' + root, 'hide' );
        document.getElementById( remove_id ).value = 'Chosen';
        toggle_top( '#replace-' + root, 'hide' );
        toggle_top( '#remove-' + root, 'hide' );
    }

    function clear_attached_file() {
        $( '#attach-file-container' ).html( $( '#attach-file-container' ).html() );
    }

    return {
        baptized_no:           baptized_no,
        baptized_yes:          baptized_yes,
        baptized_catholic_yes: baptized_catholic_yes,
        baptized_catholic_no:  baptized_catholic_no,
        clear_attached_file:   clear_attached_file,
        instructions:          instructions,
        instructionText:       instructionText,
        remove_scanned_image:  remove_scanned_image,
        replace_scanned_image: replace_scanned_image,
        scanned_image_chosen:  scanned_image_chosen,
        sidebar:               sidebar,
        toggle_top:            toggle_top
    }
};
