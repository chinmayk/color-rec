<?php
session_start();
include("database.php");
global $conn;
$worker_id = $_SESSION['worker_id'];
$random_colors = $_SESSION['random_colors'];
$total_size = $_SESSION['total_size'];
$prev_color = $_SESSION['prev_color'];

$curr_size = sizeof($random_colors);
$color_number = $total_size - $curr_size + 1;

if ($curr_size == 0) {
	header('Location: thanks.php');
}

if(isset($_POST['submit'])) {
	$q = "INSERT INTO likability (color_id, worker_id, rating) VALUES ('$prev_color', '$worker_id', '$_POST[rating]')";
	$result = mysql_query($q,$conn);

	if (!$result) {
  		die('Error: ' . mysql_error());
	}
}

$displayed_color = $random_colors[$curr_size - 1];

$_SESSION['prev_color'] = $displayed_color['color_id'];

echo "Color $color_number of $total_size <br>";
echo "<table width='100px' height='100px'>
<tr><td bgcolor='#".$displayed_color['hex_value']."'></td></tr></table>";
array_pop($random_colors);
$_SESSION['random_colors'] = $random_colors;

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
				alert("Please rate this color.");
			}
		}
		</script>
	</head>
	<body>
		<h4>How much do you like this color?</h4>
		<form id="likability" name="likability" action="<?php echo $_SERVER['PHP_SELF'];?>" method="post">
			<table style="text-align:center">
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
					<td><input type="radio" name="rating" value="1"></td>
					<td><input type="radio" name="rating" value="2"></td>
					<td><input type="radio" name="rating" value="3"></td>
					<td><input type="radio" name="rating" value="4"></td>
					<td><input type="radio" name="rating" value="5"></td>
					<td><input type="radio" name="rating" value="6"></td>
					<td><input type="radio" name="rating" value="7"></td>
					<td>&nbsp;</td>
				</tr>
			</table>
			<input name="submit" type="submit" value="Next" onclick="validate(); return false;"/>
		</form>
		</body>
</html>