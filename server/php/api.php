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
		
		case 'schema':
			echo json_encode( sj_serve_endpoint_schema() );
			exit;
		
		case 'rows':
			echo json_encode( sj_serve_endpoint_rows() );
			exit;
		
		case 'relations':
			echo json_encode( sj_serve_endpoint_relations() );
			exit;
		
		case 'table_info':
			echo json_encode( sj_serve_endpoint_table_info() );
			exit;
		
		case 'query':
			echo json_encode( sj_serve_endpoint_query() );
			exit;
		
		case 'remove_table':
			echo json_encode( sj_serve_endpoint_remove_table() );
			exit;
		
		case 'update_table_row' :
			echo json_encode( sj_serve_endpoint_update_table_row() );
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
		return array( 'connected' => true, 'error' => '' );
	
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
		return array( 'databases' => array(), 'error' => 'Could not connect to MySQL with credentials', 'error' => '' );
	
	return array( 'databases' => $db->get_col( "SHOW DATABASES" ) );
}

function sj_serve_endpoint_tables() {

	$db = sj_connect_to_mysql_from_get();
	
	if( !$db )
		return array( 'tables' => array(), 'error' => 'Could not connect to MySQL with credentials' );
	
	return array( 'tables' => $db->get_col( 'SHOW TABLES' ), 'error' => '' );
}

function sj_serve_endpoint_schema() {
	
	$db = sj_connect_to_mysql_from_get();
	
	if( !$db || empty( $_GET['table'] ) )
		return array( 'fields' => array(), 'error' => 'Could not connect to MySQL with credentials' );
	
	$columns = $db->get_results( "SHOW COLUMNS FROM " . $_GET['table'] );
	$column_names = array();
	
	foreach( $columns as $column ) {
		
		$length = preg_match( '/\(([0-9]+)\)/', $column->Type, $length_matches );
		
		$column_names[] = array( 
			'Field' => $column->Field, 
			'Type' 	=> preg_replace( '/\(([0-9])\)/', '', $column->Type ),
			'Length'=> $length_matches ? $length_matches[1] : '',
			'Unsigned' => strpos( $column->Field, 'unsigned' ) ? true : false,
			'Zerofill' => strpos( $column->Field, 'zerofill' ) ? true : false,
			'Binary'=> false,
			'Allow Null' => $column->Null  == 'NO' ? false : true,
			'Key' 	=> $column->Key,
			'Default' => $column->Default,
			'Extra'	=> $column->Extra
		);
	}
	
	return array( 'fields' => $column_names, 'error' => '' );
	
}

function sj_serve_endpoint_rows() {
	
	$db = sj_connect_to_mysql_from_get();
	
	if( !$db || empty( $_GET['table'] ) )
		return array( 'tables' => array(), 'error' => 'Could not connect to MySQL with credentials' );
	
	if( !empty( $_GET['order_by'] ) )
		$order_by = " ORDER BY `{$_GET['order_by']}` " . ( $_GET['order'] == 'ASC' ? 'ASC' : 'DESC' );
	else
		$order_by = '';
		
	return array( 'rows' => $db->get_results( "SELECT SQL_CALC_FOUND_ROWS * FROM " . $_GET['table'] . "$order_by LIMIT " . ( isset( $_GET['offset'] ) ? (int) $_GET['offset']  : 0 ) . ", 100" ), 'total_rows' => (int) $db->get_var( "SELECT FOUND_ROWS();" ), 'error' => '' );
	
}

function sj_serve_endpoint_relations() {
	
	$db = sj_connect_to_mysql_from_get();
	
	if( !$db || empty( $_GET['table'] ) )
		return array( 'tables' => array(), 'error' => 'Could not connect to MySQL with credentials' );
	
	return array( 'relations' => array(), 'error' => '' );
	
}

function sj_serve_endpoint_table_info() {
	
	$db = sj_connect_to_mysql_from_get();
	
	if( !$db || empty( $_GET['table'] ) )
		return array( 'tables' => array(), 'error' => 'Could not connect to MySQL with credentials' );
	
	$table_info_sql = $db->get_row( "SHOW TABLE STATUS LIKE '{$_GET['table']}'" );
	
	foreach( $table_info_sql as $key => $value )
		$table_info[strtolower($key)] = $value;
		
	//encodings
	$encoding_sql = $db->get_results( "SELECT * FROM information_schema.character_sets ORDER BY character_set_name ASC" );
	foreach( $encoding_sql as $key => $row )
		$encoding[] = array( 'collation_name' => $row->CHARACTER_SET_NAME, 'collate_set_name' => $row->DEFAULT_COLLATE_NAME, 'description' => $row->DESCRIPTION );
	
	//collations
	$collations_sql = $db->get_results( "SELECT * FROM information_schema.collations WHERE character_set_name = ( SELECT CHARACTER_SET_NAME FROM information_schema.character_sets WHERE DEFAULT_COLLATE_NAME = '{$table_info['collation']}' LIMIT 0, 1 ) ORDER BY 'collation_name' ASC" );
	foreach( $collations_sql as $key => $row )
		$collations[] = array( 'collation_name' => $row->COLLATION_NAME, 'collate_set_name' => $row->CHARACTER_SET_NAME, 'id' => $row->ID );
	
	$create_table = $db->get_row( "SHOW CREATE TABLE `{$_GET['table']}`" );
	
	return array( 
		'status' 	=> $table_info, 
		'engines' 	=> $db->get_col( "SELECT Engine FROM information_schema.engines WHERE support IN ('DEFAULT', 'YES')" ),
		'encodings' => $encoding,
		'collations'=>  $collations,
		'sql'		=> end($create_table),
		'error'		=> ''
	);
	
}

function sj_serve_endpoint_query() {
	
	$db = sj_connect_to_mysql_from_get();
	
	if( !$db )
		return array( 'tables' => array(), 'error' => 'Could not connect to MySQL with credentials' );
		
	$result = $db->get_results( $_GET['query'] );
	
	if( $db->last_error )
		return array( 'query' => array(), 'error' => $db->last_error );
		
	$columns = array();
	$rows = array();
	foreach( $result as $row ) {
	
		$columns = array();
	
		foreach( $row as $col_name => $row_value ) 
			$columns[] = $col_name;

		$rows[] = array_values( (array) $row );
	}
	
	return array( 'columns' => $columns, 'results' => $result, 'error' => '' );
}

function sj_serve_endpoint_remove_table() {
	
	if( empty( $_GET['table'] ) )
		return array( 'tables' => array(), 'error' => 'A table was not specified' );
	
	$db = sj_connect_to_mysql_from_get();

	if( !$db )
		return array( 'tables' => array(), 'error' => 'Could not connect to MySQL with credentials' );
	
	$db->query( "DROP TABLE `" . $_GET['table'] . "`" );
	
	if( !$db->last_error )
		return sj_serve_endpoint_tables();
	
	return array( 'tables' => array(), 'error' => 'Unable to remove table: ' . $db->last_error );
}

function sj_serve_endpoint_update_table_row() {
	
	if( empty( $_GET['table'] ) )
		return array( 'tables' => array(), 'error' => 'A table was not specified' );
	
	if( empty( $_GET['where_fields'] ) )
		return array( 'tables' => array(), 'error' => 'No where fields specified' );
	
	$db = sj_connect_to_mysql_from_get();

	$values = array();
	$columns = array();
	foreach( $_GET['where_fields'] as $value ) {
	    $columns[] = key( $value );
	    $values[] = "'" . stripslashes( end( $value ) ) . "'";
	}
		
	if( $_GET['add_row'] == "YES" ) {

		$query = "INSERT INTO `" . $_GET['table'] . "` (" . implode( ', ', $columns ) . ") VALUES ( " . implode( ', ', $values ) . " )";
		
	} else {
		
		$where_array = array();
		foreach( $columns as $key => $column )
			$where_array[] = "`" . $column . "` = " . $values[$key];
		
		$query = "UPDATE `" . $_GET['table'] . "` SET `" . $_GET['field_name'] . "` = '" . stripslashes( $_GET['field_value'] . "' WHERE " . implode( ' AND ', $where_array ) );
		
		error_log( $query );
	
	}
	
	error_log( $query );
	
	$db->query( $query );
	
	return sj_serve_endpoint_rows();
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

	$db->hide_errors();

	return $db;
}