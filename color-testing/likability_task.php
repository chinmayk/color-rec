<?php
session_start();
include("database.php");
global $conn;
$worker_id = $_SESSION['worker_id'];
$random_categories = $_SESSION['random_categories'];
$total_size = $_SESSION['total_size'];
$prev_category = $_SESSION['prev_category'];

$curr_size = sizeof($random_categories);
$category_number = $total_size - $curr_size + 1;

if ($curr_size == 0) {
	?>
	<meta HTTP-EQUIV="REFRESH" content="0; url=feedback.php">
	<?php
}

if(isset($_POST['submit'])) {
	$q = "INSERT INTO likability (palette_id, worker_id, rating) VALUES ('$_POST[frequency_palette]', '$worker_id', '$_POST[frequency_rating]')";
	$result = mysql_query($q,$conn);
	if (!$result) {
  		die('Error: ' . mysql_error());
	}
	$q = "INSERT INTO likability (palette_id, worker_id, rating) VALUES ('$_POST[saturation_palette]', '$worker_id', '$_POST[saturation_rating]')";
	$result = mysql_query($q,$conn);
	if (!$result) {
  		die('Error: ' . mysql_error());
	}
	$q = "INSERT INTO likability (palette_id, worker_id, rating) VALUES ('$_POST[random_palette]', '$worker_id', '$_POST[random_rating]')";
	$result = mysql_query($q,$conn);
	if (!$result) {
  		die('Error: ' . mysql_error());
	}
	$q = "INSERT INTO likability (palette_id, worker_id, rating) VALUES ('$_POST[distance_palette]', '$worker_id', '$_POST[distance_rating]')";
	$result = mysql_query($q,$conn);
	if (!$result) {
  		die('Error: ' . mysql_error());
	}
	$q = "INSERT INTO likability (palette_id, worker_id, rating) VALUES ('$_POST[random_protovis_palette]', '$worker_id', '$_POST[random_protovis_rating]')";
	$result = mysql_query($q,$conn);
	if (!$result) {
  		die('Error: ' . mysql_error());
	}
}

$displayed_category = $random_categories[$curr_size - 1];

$_SESSION['prev_category'] = $displayed_category['color_category'];

echo "Category $category_number of $total_size <br>";

array_pop($random_categories);
$_SESSION['random_categories'] = $random_categories;

$source_order = array();
$frequency_html;
$saturation_html;
$random_html;
$distance_html;
$random_protovis_html;

$sql = "SELECT * FROM `palettes` WHERE `color_category`='$displayed_category[color_category]' AND `algorithm`='frequency'";
$result = mysql_query($sql, $conn);
if($result) {
	if(mysql_num_rows($result) == 0) {
    	echo '<p>There are no files in the database - frequency</p>';
	} else {
		while($row = mysql_fetch_assoc($result)) {
       		$frequency_html = "<table style='text-align:center'><tr>";
			$frequency_html .= "<td width=100px height=100px bgcolor='#".$row['hex1']."'></td>";
			$frequency_html .= "<td width=100px height=100px bgcolor='#".$row['hex2']."'></td>";
			$frequency_html .= "<td width=100px height=100px bgcolor='#".$row['hex3']."'></td>";
			$frequency_html .= "<td width=100px height=100px bgcolor='#".$row['hex4']."'></td>";
			$frequency_html .= "</tr><tr>";
			$frequency_html .= "<td>".$row['color_item1']."</td>";
			$frequency_html .= "<td>".$row['color_item2']."</td>";
			$frequency_html .= "<td>".$row['color_item3']."</td>";
			$frequency_html .= "<td>".$row['color_item4']."</td>";
			$frequency_html .= "</tr></table>";
			$frequency_html .= "<table style='text-align:center'>
					<tr>
						<td>Strong dislike</td>
						<td>1</td>
						<td>2</td>
						<td>3</td>
						<td>4</td>
						<td>5</td>
						<td>6</td>
						<td>7</td>
						<td>Strong like</td>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<input type='hidden' name='frequency_palette' value='".$row['palette_id']."' />
						<td><input type='radio' name='frequency_rating' value='1'></td>
						<td><input type='radio' name='frequency_rating' value='2'></td>
						<td><input type='radio' name='frequency_rating' value='3'></td>
						<td><input type='radio' name='frequency_rating' value='4'></td>
						<td><input type='radio' name='frequency_rating' value='5'></td>
						<td><input type='radio' name='frequency_rating' value='6'></td>
						<td><input type='radio' name='frequency_rating' value='7'></td>
						<td>&nbsp;</td>
					</tr>
				</table>";
		}
	}
} else {
	die('Error: ' . mysql_error());
}

$sql = "SELECT * FROM `palettes` WHERE `color_category`='$displayed_category[color_category]' AND `algorithm`='saturation'";
$result = mysql_query($sql, $conn);
if($result) {
	if(mysql_num_rows($result) == 0) {
    	echo '<p>There are no files in the database - saturation</p>';
	} else {
		while($row = mysql_fetch_assoc($result)) {
       		$saturation_html = "<table style='text-align:center'><tr>";
			$saturation_html .= "<td width=100px height=100px bgcolor='#".$row['hex1']."'></td>";
			$saturation_html .= "<td width=100px height=100px bgcolor='#".$row['hex2']."'></td>";
			$saturation_html .= "<td width=100px height=100px bgcolor='#".$row['hex3']."'></td>";
			$saturation_html .= "<td width=100px height=100px bgcolor='#".$row['hex4']."'></td>";
			$saturation_html .= "</tr><tr>";
			$saturation_html .= "<td>".$row['color_item1']."</td>";
			$saturation_html .= "<td>".$row['color_item2']."</td>";
			$saturation_html .= "<td>".$row['color_item3']."</td>";
			$saturation_html .= "<td>".$row['color_item4']."</td>";
			$saturation_html .= "</tr></table>";
			$saturation_html .= "<table style='text-align:center'>
					<tr>
						<td>Strong dislike</td>
						<td>1</td>
						<td>2</td>
						<td>3</td>
						<td>4</td>
						<td>5</td>
						<td>6</td>
						<td>7</td>
						<td>Strong like</td>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<input type='hidden' name='saturation_palette' value='".$row['palette_id']."' />
						<td><input type='radio' name='saturation_rating' value='1'></td>
						<td><input type='radio' name='saturation_rating' value='2'></td>
						<td><input type='radio' name='saturation_rating' value='3'></td>
						<td><input type='radio' name='saturation_rating' value='4'></td>
						<td><input type='radio' name='saturation_rating' value='5'></td>
						<td><input type='radio' name='saturation_rating' value='6'></td>
						<td><input type='radio' name='saturation_rating' value='7'></td>
						<td>&nbsp;</td>
					</tr>
				</table>";
		}
	}
} else {
	die('Error: ' . mysql_error());
}

$sql = "SELECT * FROM `palettes` WHERE `color_category`='$displayed_category[color_category]' AND `algorithm`='random'";
$result = mysql_query($sql, $conn);
if($result) {
	if(mysql_num_rows($result) == 0) {
    	echo '<p>There are no files in the database - random</p>';
	} else {
		while($row = mysql_fetch_assoc($result)) {
       		$random_html = "<table style='text-align:center'><tr>";
			$random_html .= "<td width=100px height=100px bgcolor='#".$row['hex1']."'></td>";
			$random_html .= "<td width=100px height=100px bgcolor='#".$row['hex2']."'></td>";
			$random_html .= "<td width=100px height=100px bgcolor='#".$row['hex3']."'></td>";
			$random_html .= "<td width=100px height=100px bgcolor='#".$row['hex4']."'></td>";
			$random_html .= "</tr><tr>";
			$random_html .= "<td>".$row['color_item1']."</td>";
			$random_html .= "<td>".$row['color_item2']."</td>";
			$random_html .= "<td>".$row['color_item3']."</td>";
			$random_html .= "<td>".$row['color_item4']."</td>";
			$random_html .= "</tr></table>";
			$random_html .= "<table style='text-align:center'>
					<tr>
						<td>Strong dislike</td>
						<td>1</td>
						<td>2</td>
						<td>3</td>
						<td>4</td>
						<td>5</td>
						<td>6</td>
						<td>7</td>
						<td>Strong like</td>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<input type='hidden' name='random_palette' value='".$row['palette_id']."' />
						<td><input type='radio' name='random_rating' value='1'></td>
						<td><input type='radio' name='random_rating' value='2'></td>
						<td><input type='radio' name='random_rating' value='3'></td>
						<td><input type='radio' name='random_rating' value='4'></td>
						<td><input type='radio' name='random_rating' value='5'></td>
						<td><input type='radio' name='random_rating' value='6'></td>
						<td><input type='radio' name='random_rating' value='7'></td>
						<td>&nbsp;</td>
					</tr>
				</table>";
		}
	}
} else {
	die('Error: ' . mysql_error());
}

$color_item1;
$color_item2;
$color_item3;
$color_item4; 

$sql = "SELECT * FROM `palettes` WHERE `color_category`='$displayed_category[color_category]' AND `algorithm`='distance'";
$result = mysql_query($sql, $conn);
if($result) {
	if(mysql_num_rows($result) == 0) {
    	echo '<p>There are no files in the database - distance</p>';
	} else {
		while($row = mysql_fetch_assoc($result)) {
       		$color_item1 = $row['color_item1'];
			$color_item2 = $row['color_item2'];
			$color_item3 = $row['color_item3'];
			$color_item4 = $row['color_item4'];

			$distance_html = "<table style='text-align:center'><tr>";
			$distance_html .= "<td width=100px height=100px bgcolor='#".$row['hex1']."'></td>";
			$distance_html .= "<td width=100px height=100px bgcolor='#".$row['hex2']."'></td>";
			$distance_html .= "<td width=100px height=100px bgcolor='#".$row['hex3']."'></td>";
			$distance_html .= "<td width=100px height=100px bgcolor='#".$row['hex4']."'></td>";
			$distance_html .= "</tr><tr>";
			$distance_html .= "<td>".$row['color_item1']."</td>";
			$distance_html .= "<td>".$row['color_item2']."</td>";
			$distance_html .= "<td>".$row['color_item3']."</td>";
			$distance_html .= "<td>".$row['color_item4']."</td>";
			$distance_html .= "</tr></table>";
			$distance_html .= "<table style='text-align:center'>
					<tr>
						<td>Strong dislike</td>
						<td>1</td>
						<td>2</td>
						<td>3</td>
						<td>4</td>
						<td>5</td>
						<td>6</td>
						<td>7</td>
						<td>Strong like</td>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<input type='hidden' name='distance_palette' value='".$row['palette_id']."' />
						<td><input type='radio' name='distance_rating' value='1'></td>
						<td><input type='radio' name='distance_rating' value='2'></td>
						<td><input type='radio' name='distance_rating' value='3'></td>
						<td><input type='radio' name='distance_rating' value='4'></td>
						<td><input type='radio' name='distance_rating' value='5'></td>
						<td><input type='radio' name='distance_rating' value='6'></td>
						<td><input type='radio' name='distance_rating' value='7'></td>
						<td>&nbsp;</td>
					</tr>
				</table>";
		}
	}
} else {
	die('Error: ' . mysql_error());
}

$sql = "SELECT * FROM `palettes` WHERE `algorithm`='random-protovis' ORDER BY rand() LIMIT 0,1";
$result = mysql_query($sql, $conn);
if($result) {
	if(mysql_num_rows($result) == 0) {
    	echo '<p>There are no files in the database - random-protovis</p>';
	} else {
		while($row = mysql_fetch_assoc($result)) {
       		$random_protovis_html = "<table style='text-align:center'><tr>";
			$random_protovis_html .= "<td width=100px height=100px bgcolor='#".$row['hex1']."'></td>";
			$random_protovis_html .= "<td width=100px height=100px bgcolor='#".$row['hex2']."'></td>";
			$random_protovis_html .= "<td width=100px height=100px bgcolor='#".$row['hex3']."'></td>";
			$random_protovis_html .= "<td width=100px height=100px bgcolor='#".$row['hex4']."'></td>";
			$random_protovis_html .= "</tr><tr>";
			$random_protovis_html .= "<td>".$color_item1."</td>";
			$random_protovis_html .= "<td>".$color_item2."</td>";
			$random_protovis_html .= "<td>".$color_item3."</td>";
			$random_protovis_html .= "<td>".$color_item4."</td>";
			$random_protovis_html .= "</tr></table>";
			$random_protovis_html .= "<table style='text-align:center'>
					<tr>
						<td>Strong dislike</td>
						<td>1</td>
						<td>2</td>
						<td>3</td>
						<td>4</td>
						<td>5</td>
						<td>6</td>
						<td>7</td>
						<td>Strong like</td>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<input type='hidden' name='random_protovis_palette' value='".$row['palette_id']."' />
						<td><input type='radio' name='random_protovis_rating' value='1'></td>
						<td><input type='radio' name='random_protovis_rating' value='2'></td>
						<td><input type='radio' name='random_protovis_rating' value='3'></td>
						<td><input type='radio' name='random_protovis_rating' value='4'></td>
						<td><input type='radio' name='random_protovis_rating' value='5'></td>
						<td><input type='radio' name='random_protovis_rating' value='6'></td>
						<td><input type='radio' name='random_protovis_rating' value='7'></td>
						<td>&nbsp;</td>
					</tr>
				</table>";
		}
	}
} else {
	die('Error: ' . mysql_error());
}

array_push($source_order, $frequency_html);
array_push($source_order, $saturation_html);
array_push($source_order, $random_html);
array_push($source_order, $distance_html);
array_push($source_order, $random_protovis_html);
shuffle($source_order);
?>

<html>
	<head>
		<title>Rate Colors</title>
		<script type="text/javascript">
		function validate() {
			valid = true;
			var elems = document.likability.elements;
			var name;
			var checkCount = 0;
			for (var i = 0; i < elems.length - 1; i++) {
				var type = elems[i].type;
				name = elems[i].name;	
				if (type == "radio") {
					var nextName = elems[i+1].name;
					if (name == nextName) {
						if (elems[i].checked || elems[i+1].checked) {
							checkCount++;
						}
					} else {
						if (checkCount == 0) {
							valid = false;
						}
						checkCount = 0;
					}
				}
			}
			if (valid) {
				var form = document.getElementById("likability");
				form.submit();
			} else {
				alert("Please rate this color palette.");
			}
		}
		</script>
	</head>
	<body>
		<h3>How much do you like each color palette for <b><?php echo $displayed_category['color_category']?></b>?</h3>
		<form id="likability" name="likability" action="<?php echo $_SERVER['PHP_SELF'];?>" method="post">
			<?php
			for ($i = 0; $i < sizeof($source_order); ++$i) {
				echo $source_order[$i];
			}
			?>
			<input name="submit" type="submit" value="Next" onclick="validate(); return false;"/>
		</form>
		</body>
</html>