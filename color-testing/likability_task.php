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
	header('Location: thanks.php');
}

if(isset($_POST['submit'])) {
	$q = "INSERT INTO likability (color_category, source, worker_id, rating) VALUES ('$prev_category', 'expert', '$worker_id', '$_POST[expert_rating]')";
	$result = mysql_query($q,$conn);
	if (!$result) {
  		die('Error: ' . mysql_error());
	}
	$q = "INSERT INTO likability (color_category, source, worker_id, rating) VALUES ('$prev_category', 'auto', '$worker_id', '$_POST[auto_rating]')";
	$result = mysql_query($q,$conn);
	if (!$result) {
  		die('Error: ' . mysql_error());
	}
	$q = "INSERT INTO likability (color_category, source, worker_id, rating) VALUES ('$prev_category', 'auto-human', '$worker_id', '$_POST[auto_human_rating]')";
	$result = mysql_query($q,$conn);
	if (!$result) {
  		die('Error: ' . mysql_error());
	}
	$q = "INSERT INTO likability (color_category, source, worker_id, rating) VALUES ('$prev_category', 'random', '$worker_id', '$_POST[random_rating]')";
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

$source_order = rand(0,5);
$expert_colors_array = array();
$auto_colors_array = array();
$auto_human_colors_array = array();
$random_colors_array = array();

$sql = "SELECT * FROM `colors` WHERE `color_category`='$displayed_category[color_category]' AND `source`='expert' ORDER BY rand()";
$result = mysql_query($sql, $conn);
if($result) {
	if(mysql_num_rows($result) == 0) {
    	echo '<p>There are no files in the database - expert</p>';
	} else {
		while($row = mysql_fetch_assoc($result)) {
       		array_push($expert_colors_array, $row);
		}
	}
} else {
	die('Error: ' . mysql_error());
}

$sql = "SELECT * FROM `colors` WHERE `color_category`='$displayed_category[color_category]' AND `source`='auto' ORDER BY rand()";
$result = mysql_query($sql, $conn);
if($result) {
	if(mysql_num_rows($result) == 0) {
    	echo '<p>There are no files in the database - auto</p>';
	} else {
		while($row = mysql_fetch_assoc($result)) {
       		array_push($auto_colors_array, $row);
		}
	}
} else {
	die('Error: ' . mysql_error());
}

$sql = "SELECT * FROM `colors` WHERE `color_category`='$displayed_category[color_category]' AND `source`='auto-human' ORDER BY rand()";
$result = mysql_query($sql, $conn);
if($result) {
	if(mysql_num_rows($result) == 0) {
    	echo '<p>There are no files in the database - auto</p>';
	} else {
		while($row = mysql_fetch_assoc($result)) {
       		array_push($auto_human_colors_array, $row);
		}
	}
} else {
	die('Error: ' . mysql_error());
}

$sql = "SELECT * FROM `colors` WHERE `color_category`<>'$displayed_category[color_category]' ORDER BY rand() LIMIT 0, 4";
$result = mysql_query($sql, $conn);
if($result) {
	if(mysql_num_rows($result) == 0) {
    	echo '<p>There are no files in the database - random</p>';
	} else {
		while($row = mysql_fetch_assoc($result)) {
       		array_push($random_colors_array, $row);
		}
	}
} else {
	die('Error: ' . mysql_error());
}

$html_expert;
$html_auto;
$html_auto_human;
$html_random;

$html_expert = "<table style='text-align:center'><tr>";
for ($i = 0; $i < sizeof($expert_colors_array); $i++) {
	$curr_color = $expert_colors_array[$i];
	$html_expert .= "<td width=100px height=100px bgcolor='#".$curr_color['hex_value']."'></td>";
}
$html_expert .= "</tr></table>";
$html_expert .= "<table style='text-align:center'>
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
			<td><input type='radio' name='expert_rating' value='1'></td>
			<td><input type='radio' name='expert_rating' value='2'></td>
			<td><input type='radio' name='expert_rating' value='3'></td>
			<td><input type='radio' name='expert_rating' value='4'></td>
			<td><input type='radio' name='expert_rating' value='5'></td>
			<td><input type='radio' name='expert_rating' value='6'></td>
			<td><input type='radio' name='expert_rating' value='7'></td>
			<td>&nbsp;</td>
		</tr>
	</table>";
$html_auto = "<table style='text-align:center'><tr>";
for ($i = 0; $i < sizeof($auto_colors_array); $i++) {
	$curr_color = $auto_colors_array[$i];
	$html_auto .= "<td width=100px height=100px bgcolor='#".$curr_color['hex_value']."'></td>";
}
$html_auto .= "</tr></table>";
$html_auto .= "<table style='text-align:center'>
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
			<td><input type='radio' name='auto_rating' value='1'></td>
			<td><input type='radio' name='auto_rating' value='2'></td>
			<td><input type='radio' name='auto_rating' value='3'></td>
			<td><input type='radio' name='auto_rating' value='4'></td>
			<td><input type='radio' name='auto_rating' value='5'></td>
			<td><input type='radio' name='auto_rating' value='6'></td>
			<td><input type='radio' name='auto_rating' value='7'></td>
			<td>&nbsp;</td>
		</tr>
	</table>";
$html_auto_human = "<table style='text-align:center'><tr>";
for ($i = 0; $i < sizeof($auto_human_colors_array); $i++) {
	$curr_color = $auto_human_colors_array[$i];
	$html_auto_human .= "<td width=100px height=100px bgcolor='#".$curr_color['hex_value']."'></td>";
}
$html_auto_human .= "</tr></table>";
$html_auto_human .= "<table style='text-align:center'>
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
			<td><input type='radio' name='auto_human_rating' value='1'></td>
			<td><input type='radio' name='auto_human_rating' value='2'></td>
			<td><input type='radio' name='auto_human_rating' value='3'></td>
			<td><input type='radio' name='auto_human_rating' value='4'></td>
			<td><input type='radio' name='auto_human_rating' value='5'></td>
			<td><input type='radio' name='auto_human_rating' value='6'></td>
			<td><input type='radio' name='auto_human_rating' value='7'></td>
			<td>&nbsp;</td>
		</tr>
	</table>";
$html_random = "<table style='text-align:center'><tr>";
for ($i = 0; $i < sizeof($random_colors_array); $i++) {
	$curr_color = $random_colors_array[$i];
	$html_random .= "<td width=100px height=100px bgcolor='#".$curr_color['hex_value']."'></td>";
}
$html_random .= "</tr></table>";
$html_random .= "<table style='text-align:center'>
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
			switch($source_order) {
				case 0:
					echo $html_random;
					echo $html_expert;
					echo $html_auto;
					echo $html_auto_human;
					break;
				case 1:
					echo $html_random;
					echo $html_auto;
					echo $html_expert;
					echo $html_auto_human;
					break;
				case 2:
					echo $html_expert;
					echo $html_random;
					echo $html_auto;
					echo $html_auto_human;
					break;
				case 3:
					echo $html_expert;
					echo $html_auto;
					echo $html_random;
					echo $html_auto_human;
					break;
				case 4:
					echo $html_auto;
					echo $html_random;
					echo $html_expert;
					echo $html_auto_human;
					break;
				case 5:
					echo $html_auto;
					echo $html_expert;
					echo $html_random;
					echo $html_auto_human;
					break;
			}
			?>
			<input name="submit" type="submit" value="Next" onclick="validate(); return false;"/>
		</form>
		</body>
</html>