<?php
require dirname(__FILE__) . "/../SequelJ.php";

class SequelJTest extends PHPUnit_Framework_TestCase
{
  private $app;

  public function setUp() {
    $_GET['host'] = '';
    $_GET['username'] ='';
    $_GET['password'] = '';
    $_GET['database'] = '';
    $_GET['port'] = '';
  }

  public function testShouldConnectEndpoint() {
    $db = $this->getMock('ezSQL_mysql', array('connect'));
    $db->expects($this->any())
      ->method('connect')
      ->will($this->returnValue(true));

    $app = new SequelJ($db);
    $resp = $app->serve_endpoint('connect');

    $this->assertEquals($resp['connected'], true);
    $this->assertEquals($resp['path'], '/connect');
    $this->assertEquals($resp['error'], '');
  }

  public function testFailsToConnectEndpoint() {
    $db = $this->getMock('ezSQL_mysql', array('connect'));
    $db->expects($this->any())
      ->method('connect')
      ->will($this->returnValue(false));

    $app = new SequelJ($db);
    $resp = $app->serve_endpoint('connect');

    $this->assertEquals($resp['connected'], false);
    $this->assertEquals($resp['path'], '/connect');
    $this->assertEquals($resp['error'], 'Could not connect to MySQL with credentials');
  }

  public function testDatabasesEndpoint() {
    $_GET['database'] = 'fake_names';
    $dblist = array('dbname1', 'dbname2', 'dbname3');

    $db = $this->getMock('ezSQL_mysql', array('connect', 'select', 'hide_errors', 'get_col'));
    $db->expects($this->any())
      ->method('connect')
      ->will($this->returnValue(true));

    $db->expects($this->any())
      ->method('select')
      ->with($_GET['database'])
      ->will($this->returnValue(true));

    $db->expects($this->once())
      ->method('get_col')
      ->with('SHOW DATABASES')
      ->will($this->returnValue($dblist));

    $app = new SequelJ($db);
    $resp = $app->serve_endpoint('databases');
    
    $this->assertEquals($resp['connected'], true);
    $this->assertEquals($resp['path'], '/databases');
    $this->assertEquals($resp['error'], '');
    $this->assertEquals(sizeof($resp['databases']), 3);

    for($i=0; $i<sizeof($resp['databases']); $i++) {
      $this->assertEquals($resp['databases'][$i], $dblist[$i]);
    }
  }
}
