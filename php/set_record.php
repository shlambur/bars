<?php

!empty($_POST) or exit('Empty request!');

$json_data = $_POST['data'];

$data = json_decode($json_data, true);

$mysqli = new mysqli("localhost", "adm", "f105", "lis_inf");

$mysqli or exit('Connection error!');

$mysqli->set_charset("utf8");

$result = $mysqli->query("select * from dataqr where obj_id = '${data['id']}'");

!$result or exit('Success select!');

$stmt = $mysqli->prepare('insert into dataqr (obj_id, key_name, value_name) value (?, ?, ?)');

foreach ($data['obj'] as $key => $value) {
	
	$stmt->bind_param('iss', $data['id'], $key, $value);
	
	$stmt->execute();
	
}

$stmt->close();

$mysqli->close();

echo 'Success insert!';

?>