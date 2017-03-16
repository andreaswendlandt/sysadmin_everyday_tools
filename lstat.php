#!/usr/bin/php -q
<?php
error_reporting(0);
$lstat = $argv[1];
$base64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
$lstat = trim($lstat);
$start = 0;
for($i = $start; $i < strlen($lstat); $i++) { 
$result <<= 6; 
$result += strpos($base64, substr($lstat, $i , 1)); 
} 
echo ("$result"."\n");
?>
