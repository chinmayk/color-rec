<?php
session_start(); 
include("database.php");
global $conn;

if(isset($_POST['submit'])) {
	//$conn;
	$worker_id = $_POST['worker_id'];
	$q = "SELECT * FROM `likability` WHERE `worker_id` = '$worker_id'";
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
		$sql = "SELECT `color_id`, `hex_value` FROM `colors` ORDER BY rand()";
		$result = mysql_query($sql, $conn);

		// Check if it was successful
		if($result) {
    		// Make sure there are some files in there
    		if(mysql_num_rows($result) == 0) {
        		echo '<p>There are no files in the database</p>';
    		} else {
	   			$color_array = array();
    			while($row = mysql_fetch_assoc($result)) {
            		if ($row['hex_value']) {
            			array_push($color_array, $row);
        			}
    			}
        		$_SESSION['random_colors'] = $color_array;
        		$_SESSION['total_size'] = sizeof($color_array);
			?>
       		<meta HTTP-EQUIV="REFRESH" content="0; url=likability_task.php"> 	
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
	</head>
	<body>
		<h3>Your task is to rate a series of colors based on how much you like the color. <br />You will judge how well you like the color on a scale from 1 (Strong dislike) to 7 (Strong like). <br /><br />The task should take about ????????????????? minutes.</h3>
		<form action="<?php echo $_SERVER['PHP_SELF'];?>" method="post">
			<!-- <input name="worker_id" type="hidden" value="<?= $_REQUEST['workerId']?>" />
						<input name="assignment_id" type="hidden" value="<?= $_REQUEST['assignmentId']?>" /> -->
			<input name="worker_id" type="hidden" value="<?= $_GET['workerId']?>" />
			<input name="assignment_id" type="hidden" value="<?= $_GET['assignmentId']?>" />
			<input name="submit" type="submit" value="Next" />
		</form>
	</body>
</html>

<? } ?>