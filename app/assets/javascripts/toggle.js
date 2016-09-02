/**
 * Created by paulkristoff on 9/1/16.
 */

confirmation_toggle = function () {

    function instructions( e ) {
        e.preventDefault();
        // expand/collapse
        var div = $( '#instructions' );
        div.is( ':hidden' ) ? div.show() : div.hide();
        // change icon
        var span = $( '#insturction-toggle-span' ),
            right_div = $( '#right-col' ),
            left_div = $( '#left-col' );
        if ( div.is( ':hidden' ) ) {
            span.removeClass( 'glyphicon-minus' );
            span.addClass( 'glyphicon-plus' );
            right_div.width('0%');
            left_div.width('100%');
        }
        else {
            span.removeClass( 'glyphicon-plus' );
            span.addClass( 'glyphicon-minus' );
            right_div.width('50%');
            left_div.width('50%');
        }
    }

    function sidebar( e, self ) {
        e.preventDefault();
        // toggle the sidebar
        $( "#wrapper" ).toggleClass( "toggled" );
        // change icon
        if ( $( self ).data( 'name' ) == 'show' ) {
            $( '#menu-toggle-span' ).replaceWith( '<span id="menu-toggle-span">&raquo;</span>' );
            $( self ).data( 'name', 'hide' )
        }
        else {
            $( '#menu-toggle-span' ).replaceWith( '<span id="menu-toggle-span">&laquo;</span>' );
            $( self ).data( 'name', 'show' )
        }
    }

    function toggle_top(id) {
        var div = $( id );
        div.is( ':hidden' ) ? div.show() : div.hide();
    }

    // function initialize() {
    //     $( "menu-toggle" ).click( sidebar );
    //     $( "insturction" ).click( instructions );
    // }
    //
    // initialize();

    return {
        instructions:                 instructions,
        sidebar:                      sidebar,
        toggle_top: toggle_top
    }
};