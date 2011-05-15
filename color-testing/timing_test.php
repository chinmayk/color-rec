<?php
if(isset($_POST['submit'])) {
	$start = $_POST['start'];
	$end = gettimeofday(true);
	$elapsed = $end - $start;
	
	echo "$start $end $elapsed";
	
} else {
	$start_t = gettimeofday(true);
?>

<html>
	<head>
		<title>Timing</title>
	</head>
	<body>
		<form id="time" name="time" action="<?php echo $_SERVER['PHP_SELF'];?>" method="POST">
			<input name="start" type="hidden" value="<?=$start_t?>" />
			<input name="submit" type="submit" value="Next" />
		</form>
	</body>
</html>

<?php
}
?>