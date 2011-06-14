<?php

require_once( 'ez_sql/ez_sql_core.php' );
require_once( 'ez_sql/ez_sql_mysql.php' );

function sj_serve_api_request() {

	if( empty( $_GET['endpoint'] ) )
		return sj_error_object( "No endpoint specified" );
	
	switch( $_GET['endpoint'] ) :
		
		case 'connect':
			echo json_encode( sj_serve_endpoint_connect() );
			exit;
		
		case 'databases':
			echo json_encode( sj_serve_endpoint_databases() );
			exit;
		
		case 'tables':
			echo json_encode( sj_serve_endpoint_tables() );
			exit;
		
		case 'header_names':
			echo json_encode( sj_serve_endpoint_header_names() );
			exit;
		
		case 'rows':
			echo json_encode( sj_serve_endpoint_rows() );
			exit;
			
	endswitch;

}

sj_serve_api_request();

/**
 * Handles the "connect" endpoint.
 * 
 * @return array
 */
function sj_serve_endpoint_connect() {
	
	$credentials = sj_get_connection_details_from_get();
	$db = new ezSQL_mysql;
	
	if( $db->connect( $credentials['username'], $credentials['password'], $credentials['host'] . ( $credentials['port'] ? ':' . $credentials['port'] : '' ) ) )
		return array( 'connected' => true );
	
	else
		return array( 'connected' => false, 'error' => 'Could not connect to MySQL with credentials' );
}

/**
 * Handles the databases ("SHOW DATABASES") api call.
 * 
 * @return array
 */
function sj_serve_endpoint_databases() {
	
	$db = sj_connect_to_mysql_from_get();
	
	if( !$db )
		return array( 'databases' => array(), 'error' => 'Could not connect to MySQL with credentials' );
	
	return array( 'databases' => $db->get_col( "SHOW DATABASES" ) );
}

function sj_serve_endpoint_tables() {

	$db = sj_connect_to_mysql_from_get();
	
	if( !$db )
		return array( 'tables' => array(), 'error' => 'Could not connect to MySQL with credentials' );
	
	return array( 'tables' => $db->get_col( 'SHOW TABLES' ) );
}

function sj_serve_endpoint_header_names() {
	
	$db = sj_connect_to_mysql_from_get();
	
	if( !$db || empty( $_GET['table'] ) )
		return array( 'tables' => array(), 'error' => 'Could not connect to MySQL with credentials' );
	
	return array( 'header_names' => $db->get_col( "SHOW COLUMNS FROM " . $_GET['table'] ) );
	
}

function sj_serve_endpoint_rows() {
	
	$db = sj_connect_to_mysql_from_get();
	
	if( !$db || empty( $_GET['table'] ) )
		return array( 'tables' => array(), 'error' => 'Could not connect to MySQL with credentials' );
	
	return array( 'rows' => $db->get_results( "SELECT * FROM " . $_GET['table'] . " LIMIT 0, 100" ) );
	
}

/* Helper Functions */

function sj_error_array( $error_message ) {
	
	
}

function sj_get_connection_details_from_get() {
	
	return array( 
		'host' => $_GET['host'],
		'username' => $_GET['username'],
		'password' => $_GET['password'],
		'database' => $_GET['database'],
		'port' => (int) $_GET['port']
	);
}

function sj_connect_to_mysql_from_get() {
	
	$credentials = sj_get_connection_details_from_get();
	$db = new ezSQL_mysql;
	
	if( !$db->connect( $credentials['username'], $credentials['password'], $credentials['host'] . ( $credentials['port'] ? ':' . $credentials['port'] : '' ) ) )
		return false;
	
	if( $credentials['database'] && !$db->select( $credentials['database'] ) )
		return false;
	
	return $db;
}