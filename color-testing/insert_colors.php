<?php
include("database.php");
global $conn;

$q = "INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('3D8B37', 'fruits', 'apple', 'auto')";
$result = mysql_query($q,$conn);
if (!$result) {
	die('Error: ' . mysql_error());
}

INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('355A12', 'fruits', 'apple', 'auto');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('E1E0CF', 'fruits', 'banana', 'auto');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('CCC1B9', 'fruits', 'strawberry', 'auto');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('6E6A6C', 'fruits', 'pear', 'auto');

INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('7E130D', 'fruits', 'apple', 'auto-human');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('B5A123', 'fruits', 'banana', 'auto-human');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('9A1C0E', 'fruits', 'strawberry', 'auto-human');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('7A9241', 'fruits', 'pear', 'auto-human');

INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('C01A30', 'fruits', 'apple', 'expert');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('EEC84D', 'fruits', 'banana', 'expert');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('D1071D', 'fruits', 'strawberry', 'expert');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('AEB833', 'fruits', 'pear', 'expert');

INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('D01813', 'sodas', 'coca-cola', 'auto');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('113260', 'sodas', 'pepsi', 'auto');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('90BE70', 'sodas', 'sprite', 'auto');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('AD8A67', 'sodas', 'root beer', 'auto');

INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('D01813', 'sodas', 'coca-cola', 'auto-human');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('113260', 'sodas', 'pepsi', 'auto-human');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('90BE70', 'sodas', 'sprite', 'auto-human');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('341F14', 'sodas', 'root beer', 'auto-human');

INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('B82424', 'sodas', 'coca-cola', 'expert');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('005181', 'sodas', 'pepsi', 'expert');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('00854E', 'sodas', 'sprite', 'expert');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('4F2A17', 'sodas', 'root beer', 'expert');

INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('020205', 'superheroes', 'batman', 'auto');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('DECDBC', 'superheroes', 'superman', 'auto');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('10151B', 'superheroes', 'spiderman', 'auto');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('366313', 'superheroes', 'green lantern', 'auto');

INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('020205', 'superheroes', 'batman', 'auto-human');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('3A5B76', 'superheroes', 'superman', 'auto-human');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('6E0B0A', 'superheroes', 'spiderman', 'auto-human');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('366313', 'superheroes', 'green lantern', 'auto-human');

INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('141C40', 'superheroes', 'batman', 'expert');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('0069B3', 'superheroes', 'superman', 'expert');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('D20D14', 'superheroes', 'spiderman', 'expert');
INSERT INTO `colors` (hex_value, color_category, color_item, source) VALUES ('029453', 'superheroes', 'green lantern', 'expert');

?>