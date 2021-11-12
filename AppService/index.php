<!DOCTYPE html>
<html>
<head>
	<title>Test CyberMSI SDLC</title>
</head>
<body>
	<form method="post">
		<h2>Search</h2>
		<input type="text" name="search">
		<input type="submit" name="submit">
	</form>
</body>
</html>

<?php
	$con = new PD("mysql:host=localhost;dbname=TestTable",'root','');
		if (isset($_POST["submit"])) {
			$str = $_POST["search"];
			$sth = $con->prepare("SELECT * FROM 'search' WHERE Name = '$str'");
			$sth->setFetchMode(PDO:: FETCH_OBJ);
			$sth -> execute();
			if ($row = $sth->fetch()) { 
?>
			<br><br>
			<table>
				<tr>
					<th>Name</th>
					<th>Description</th>
				</tr>
				<tr>
					<th><?php echo $row->Name;?></th>
					<th><?php echo $row->Description;?></th>
				</tr>
			</table>
<?php
		}
			else {
				echo "No Results Found";
			}
		}
?>





