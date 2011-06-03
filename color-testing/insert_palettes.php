<?php
include("database.php");
global $conn;

$rand_color_array = array();
$q = "SELECT * FROM `colors` WHERE `source`='protovis' ORDER BY rand() LIMIT 0,4";
$result = mysql_query($q, $conn);
if ($result) {
	while($row = mysql_fetch_assoc($result)) {
		$color = $row['hex_value'];
		array_push($rand_color_array, $color);
	}
}
$q = "INSERT INTO palettes (hex1, color_item1, hex2, color_item2, hex3, color_item3, hex4, color_item4, color_category, algorithm) VALUES ('$rand_color_array[0]', 'none', '$rand_color_array[1]', 'none', '$rand_color_array[2]', 'none', '$rand_color_array[3]', 'none', 'none', 'random-protovis')";
$result = mysql_query($q,$conn);
if (!$result) {
	die('Error: ' . mysql_error());
}
?>