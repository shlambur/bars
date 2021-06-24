<?php

!empty($_GET) or exit('Empty request!');

$mysqli = new mysqli("localhost", "adm", "f105", "lis_inf");

$mysqli or exit('Connection error!');

$mysqli->set_charset("utf8");

$result = $mysqli->query(
	"select
		*
	from
		dataqr
	where
		obj_id = ((select
						tB.obj_id
					from (
						select
							*
						from
							dataqr
						where
							key_name = 'BARCODE'
							and value_name = '${_GET['bc']}') tB
							inner join (select
											*
										from
											dataqr
										where
											key_name = 'ID1'
											and value_name = '${_GET['id']}') tI
											on tB.obj_id = tI.obj_id))");											

$result or exit('Empty select!');

$rows = $result->fetch_all(MYSQLI_ASSOC);

$key_name = null;
$value_name = null;

$data = array();

foreach ($rows as $row) {
	
	foreach ($row as $key=>$value) {
		
		if ($key == 'key_name') {
			$key_name = $value;
		}

		if ($key == 'value_name') {
			$value_name = $value;
		}
	
	}
	
	if ($key_name <> null and $value_name <> null) {
		
		$data[$key_name] = $value_name;
		
		$key_name = null;
		$value_name = null;
	
	}
	
}

$mysqli->close();

echo json_encode($data, JSON_UNESCAPED_UNICODE);

?>