<?php
require_once 'ez_sql/ez_sql_core.php';
require_once 'ez_sql/ez_sql_mysql.php';
require_once 'SequelJ.php';

$db = new ezSQL_mysql;

$app = new SequelJ($db);
$resp = $app->serve_endpoint($_GET['endpoint']);

echo json_encode($resp);
