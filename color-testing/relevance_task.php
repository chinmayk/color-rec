<?php
session_start();
include("database.php");
global $conn;
$worker_id = $_SESSION['worker_id'];
$random_categories = $_SESSION['random_categories'];
$total_size = $_SESSION['total_size'];
$prev_category = $_SESSION['prev_category'];
$prev_item = $_SESSION['prev_item'];

$curr_size = sizeof($random_categories);
$category_number = $total_size - $curr_size + 1;

if ($curr_size == 0) {
	header('Location: feedback.php');
}

if(isset($_POST['submit'])) {
	$q = "INSERT INTO relevance (prompt_category, prompt_item, worker_id, color_id) VALUES ('$prev_category', '$prev_item', '$worker_id', '$_POST[color_id]')";
	$result = mysql_query($q,$conn);
	if (!$result) {
  		die('Error: ' . mysql_error());
	}
}

$displayed_category = $random_categories[$curr_size - 1];
$color_category = $displayed_category['color_category'];
$color_item = $displayed_category['color_item'];

$_SESSION['prev_category'] = $color_category;
$_SESSION['prev_item'] = $color_item;

$category_colors_array = array();
$other_colors_array = array();

$sql = "SELECT * FROM `colors` WHERE `color_category`='$color_category' AND `color_item`='$color_item'";
$result = mysql_query($sql, $conn);
if($result) {
	if(mysql_num_rows($result) == 0) {
    	echo '<p>There are no files in the database</p>';
	} else {
		while($row = mysql_fetch_assoc($result)) {
       		array_push($category_colors_array, $row);
		}
	}
} else {
	die('Error: ' . mysql_error());
}

$sql = "SELECT * FROM `colors` WHERE `color_category`='random' ORDER BY rand() LIMIT 0, 1";

$result = mysql_query($sql, $conn);
if($result) {
	if(mysql_num_rows($result) == 0) {
    	echo '<p>There are no files in the database</p>';
	} else {
		while($row = mysql_fetch_assoc($result)) {
       		array_push($other_colors_array, $row);
		}
	}
} else {
	die('Error: ' . mysql_error());
}

$colors_array = array_merge($category_colors_array, $other_colors_array);
shuffle($colors_array);

echo "Topic $category_number of $total_size <br /><br />";
array_pop($random_categories);
$_SESSION['random_categories'] = $random_categories;

?>

<html>
	<head>
		<title>Rate Colors</title>
		<script type="text/javascript">
		function validate() {
			valid = true;
			var elems = document.relevance.elements;
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
				var form = document.getElementById("relevance");
				form.submit();
			} else {
				alert("Please choose the most relevant color.");
			}
		}
		</script>
	</head>
	<body>
		<h4>Which color is the most relevant to <b><?php echo $displayed_category['color_item'];?> (<?php echo $displayed_category['color_category'];?>)</b>?</h4>
		<form id="relevance" name="relevance" action="<?php echo $_SERVER['PHP_SELF'];?>" method="post">
			<table style="text-align:center">
				<?php
				for ($i = 0; $i < sizeof($colors_array); $i++) {
					$curr_color = $colors_array[$i];
					echo "<tr>";
					echo "<td><input type='radio' name='color_id' value='".$curr_color['color_id']."'></td>";
					echo "<td width=100px height=100px bgcolor='#".$curr_color['hex_value']."'></td>";
					echo "</tr>";
				}
				echo "<tr>";
				echo "<td><input type='radio' name='color_id' value='0'></td>";
				echo "<td width=100px height=100px'>none of the above</td>";
				echo "</tr>";
				?>
			</table>
			<input name="submit" type="submit" value="Next" onclick="validate(); return false;"/>
		</form>
<<<<<<< HEAD
	</body>
</html>
=======
		</body>
</html>
>>>>>>> 41f6c4bda37dceabe5f0f31330092487388c81c6
