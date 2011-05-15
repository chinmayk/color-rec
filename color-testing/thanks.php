<?php session_start();?>
<html>
	<head>
    	<title>Thank you</title>
	</head>
	<body>
		<h1>Thanks for rating!</h1>
		<input type=button onClick="location.href='http://www.mturk.com/mturk/externalSubmit?assignmentId=<?= $_SESSION['assignment_id'] ?>&submitted=yes'" value='Done'>
	</body>
</html>