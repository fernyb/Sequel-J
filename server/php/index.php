<?php
$_ENV['SLIM_MODE'] = 'development';

require 'json.php';
require 'Slim/Slim.php';
Slim::init();

function params($name) {
  return Slim::request()->params($name);
}

function path() {
  return Slim::request()->getResourceUri();
}

Slim::get('/', function () {
  echo 'Hello World';
});

Slim::get('/connect', function () {
  $resp = array('connected' => true, 'error' => '', 'path' => path());
  $body = jsencode($resp);
  
  Slim::response()->body($body);
});

Slim::get('/databases', function () {
  
});

Slim::get('/tables', function () {
  
});

Slim::get('/columns/:table', function ($table) {
  
});

Slim::get('/header_names/:table', function ($table) {
  
});

Slim::get('/rows/:table', function ($table) {
  
});

Slim::get('/schema/:table', function ($table) {
  
});

Slim::get('/indexes/:table', function ($table) {
  
});

Slim::get('/relations/:table', function ($table) {
  
});

Slim::get('/show_create_table/:table', function ($table) {
  
});

Slim::get('/table_info/:table', function ($table) {
  
});

Slim::get('/query/:table', function ($table) {
  
});

Slim::run();