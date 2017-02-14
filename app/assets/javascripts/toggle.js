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
    document.querySelector( 'input[id=total_selected]' ).value = count;
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

    function toggle_top( id ) {
        var div = $( id );
        div.is( ':hidden' ) ? div.show() : div.hide();
    }

    return {
        instructions: instructions,
        sidebar:      sidebar,
        toggle_top:   toggle_top
    }
};