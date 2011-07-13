<?php

class SequelJ
{
  public $connected = false;
  public $response = '';
  public $path = '';
  public $error = '';
  public $db;

  public function __construct($db) {
    $this->db = $db;
  }

  private function render($kv=array()) {
    return array_merge(array(
      'connected' => $this->connected,
      'error'     => $this->error,
      'path'      => $this->path
    ), $kv);
  }

  public function serve_endpoint($name) {
    $resp = array();
    switch($name) :
    case 'connect' :
      $this->path = "/${name}";
      $resp = $this->connect_endpoint(); 
    break;
    case 'databases' :
      $this->path = "/${name}";
      $resp = $this->databases_endpoint();
      break;
    endswitch;

    return $this->render($resp);
  }

  public function connect_endpoint() {
    $credentials = $this->connection_details();
    $db = $this->db;
    $host =  $credentials['host'] . ( $credentials['port'] ? ':' . $credentials['port'] : '' );

    if( $db->connect( $credentials['username'], $credentials['password'], $host) ) 
    {
      $this->connected = true;
      $this->error = '';
    }
    else {
      $this->connected = false;
      $this->error = 'Could not connect to MySQL with credentials';
    }
    return array();
  }

  public function connection_details() {
    return array( 
      'host'      => $_GET['host'],
      'username'  => $_GET['username'],
      'password'  => $_GET['password'],
      'database'  => $_GET['database'],
      'port'      => $_GET['port']
    );
  }

  public function connect_to_mysql() {
    $credentials = $this->connection_details();
    $db = $this->db;

    if( !$db->connect( $credentials['username'], $credentials['password'], $credentials['host'] . ( $credentials['port'] ? ':' . $credentials['port'] : '' ) ) )
      $this->connected = false;
    else
      $this->connected = true;
    
    if( $credentials['database'] && !$db->select( $credentials['database'] ) )
      $this->connected = false;

    if ($this->connected == false) {
      return false;
    }

    $db->hide_errors();

    return $db;
  }

  public function databases_endpoint() {
    $db = $this->connect_to_mysql();
    if( !$db ){
      $this->error = 'Could not connect to MySQL with credentials';
      return array('databases' => array());
    }
	
    return array( 'databases' => $db->get_col( "SHOW DATABASES" ) );
  }
}
?>
