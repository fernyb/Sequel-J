<?php
// PHP's built-in json_encode is not very good.
// source from: http://loewald.com/blog/?p=2987

function jsencode( $obj, $json = false ){
	switch( gettype( $obj ) ){
		case 'array':
		case 'object':
			$code = array();
			// is it anything other than a simple linear array
			if( array_keys($obj) !== range(0, count($obj) - 1) ){
				foreach( $obj as $key => $val ){
					$code []= $json ?
						'"' . $key . '":' . jsencode( $val ) :
						$key . ':' . jsencode( $val );
				}
				$code = '{' . implode( ',', $code ) . '}';
			} else {
				foreach( $obj as $val ){
					$code []= jsencode( $val );
				}
				$code = '[' . implode( ',', $code ) . ']';
			}
			return $code;
			break;
		case 'boolean':
			return $obj ? 'true' : 'false' ;
			break;
		case 'integer':
		case 'double':
			return floatVal( $obj );
			break;
		case 'NULL':
		case 'resource':
		case 'unknown':
			return 'null';
			break;
		default:
			return '"' . addslashes( $obj ) . '"';
	}
}