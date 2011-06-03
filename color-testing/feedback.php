<?php
session_start();
include("database.php");
global $conn;
$worker_id = $_SESSION['worker_id'];

if(isset($_POST['submit'])) {
	$feedback = mysql_real_escape_string($_POST['feedback']);
	$q = "INSERT INTO feedback (worker_id, task_type, feedback) VALUES ('$worker_id', 'likability', '$feedback')";
	$result = mysql_query($q,$conn);
	if (!$result) {
  		die('Error: ' . mysql_error());
	}
	header('Location: thanks.php');
}
?>

<html>
	<head>
		<title>Rate Colors</title>
		<script type="text/javascript">
			var worker_id = <?php echo $worker_id ?>;
			var _gaq = _gaq || [];
			_gaq.push(['_setAccount', 'UA-23572690-1']);
			_gaq.push(['_setCustomVar', 1, 'worker_id', worker_id]);
			_gaq.push(['_trackPageview']);
			(function() {
				var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
				ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
				var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
			})();
		</script>
	</head>
	<body>
		<h4>What did you think of this HIT? Please provide feedback below.</h4>
		<form id="feedback_form" name="feedback_form" action="<?php echo $_SERVER['PHP_SELF'];?>" method="post">
			<textarea name="feedback" cols=40 rows=6></textarea><br />
			<input name="submit" type="submit" value="Next" />
		</form>
	</body>
</html>