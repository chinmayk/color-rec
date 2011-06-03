<?php
session_start(); 
include("database.php");
global $conn;

if(isset($_POST['submit'])) {
	//$conn;
	$worker_id = $_POST['worker_id'];
	$q = "SELECT * FROM `relevance` WHERE `worker_id` = '$worker_id'";
	$result = mysql_query($q, $conn);
	if (mysql_num_rows($result)) {
		?>
		<meta HTTP-EQUIV="REFRESH" content="0; url=sorry.php">
		<?php
	} else {
		$_SESSION['worker_id'] = $worker_id;
		$assignment_id = $_POST['assignment_id'];
		$_SESSION['assignment_id'] = $assignment_id;
		// Query for a list of all colors
		$sql = "SELECT DISTINCT `color_category`, `color_item` FROM `colors` WHERE `source`='weighted_distance' ORDER BY rand()";
		$result = mysql_query($sql, $conn);

		// Check if it was successful
		if($result) {
    		// Make sure there are some files in there
    		if(mysql_num_rows($result) == 0) {
        		echo '<p>There are no files in the database</p>';
    		} else {
	   			$category_array = array();
    			while($row = mysql_fetch_assoc($result)) {
            		if($row['color_category'] != 'none') {
						if($row['color_category'] != 'random') {
							array_push($category_array, $row);
						}
					}
    			}
        		$_SESSION['random_categories'] = $category_array;
        		$_SESSION['total_size'] = sizeof($category_array);
			?>
       		<meta HTTP-EQUIV="REFRESH" content="0; url=relevance_task.php"> 	
			<?php
    		}
		} else {
			die('Error: ' . mysql_error());
		}
	}
} else {

?>

<html>
	<head>
		<title>Rate Colors</title>
		
		<script type="text/javascript">
		function accepted() {
			valid = true;
			var elems = document.turkInfo.elements;
			var name;
			var checkCount = 0;
			for (var i = 0; i < elems.length - 1; i++) {
				var type = elems[i].type;
				name = elems[i].name;	
				if (type == "hidden") {
					if (elems[i].value == "") {
						valid = false;
					}
				}
			}
			if (valid) {
				var form = document.getElementById("turkInfo");
				form.submit();
			} else {
				alert("Please accept this HIT.");
			}
		}
		</script>
	</head>
	<body>
		<h3>You will see a series of topics. <br />Your task is to decide which color is most relevant to the topic. <br /><br />The task should take about 5 minutes.</h3>
		<form name="turkInfo" action="<?php echo $_SERVER['PHP_SELF'];?>" method="post">
			<input name="worker_id" type="hidden" value="<?= $_REQUEST['workerId']?>" />
			<input name="assignment_id" type="hidden" value="<?= $_REQUEST['assignmentId']?>" />
			<input name="submit" type="submit" value="Next" onclick="accepted(); return false;" />
		</form>
	</body>
</html>

<? } ?>