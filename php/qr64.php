<?php

require_once __DIR__ . '\\phpqrcode\\qrlib.php';

$LIT =
  "(DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = Lithium)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl.kb123.ru)
    )
  )";


    $conn = oci_connect('lisul', 'lisul', $LIT, 'AL32UTF8');



if (!$conn) {
    $e = oci_error();
    trigger_error(htmlentities($e['message'], ENT_QUOTES), E_USER_ERROR);
    exit('oci_sosi');
}

$sql = <<<'SQL_TEXT'
select
t2.ID1,
to_char(t3.ddate,'DD.MM.YYYY hh24:mi:ss') datereg,
t6.NAMEPACIENT ,
t6.NAME1       ,
t6.NAME2       ,
t5.NAMEKLIENT  ,
t2.barcode,
to_char(t3.dateverif,'DD.MM.YYYY hh24:mi:ss') date_valid,
t3.REZULT,     
t2.id


          
          from  tests t4
          left join soderpaket t3 on  t3.numtesta= t4.numtest
          left join pecientinworklist t2 on t2.id = t3.IDPACIENTINWORKLIST
          left join KLIENTS t5 on t5.id= t2.client_id
          left join Pacients t6 on t6.numpacient = t3.numpacient
         
          where t2.barcode = :barcode
          and  t6.numpacient = :numpacient
          
SQL_TEXT;

$stmt = oci_parse($conn, $sql);

oci_bind_by_name($stmt, 'barcode', $_GET['bc']);
oci_bind_by_name($stmt, 'numpacient', $_GET['np']);

$r = oci_execute($stmt);

$nrows = oci_fetch_all($stmt, $res,  null, null, OCI_FETCHSTATEMENT_BY_ROW);
 
if (empty($res)) exit('Empty select!');

$data = array();
$data['obj'] = array();
foreach ($res[0] as $key => $value) {
    if ($key=='ID') {
      $data['id'] = $value;
    } else{
      $data['obj'] [$key] = $value; 
    }
  } 

 $data ['obj'] ['NAMEPACIENT'] =substr($data['obj']['NAMEPACIENT'],0,1).str_repeat('*',(strlen($data['obj'] ['NAMEPACIENT'])-2)).substr($data['obj'] ['NAMEPACIENT'],-1);
 $data ['obj'] ['NAME1'] = substr($data['obj']['NAME1'],0,1);
 $data ['obj'] ['NAME2'] = substr($data['obj']['NAME2'],0,1);  /*преобразование  ФИО в звездочки */

$POST = json_encode($data, JSON_PRETTY_PRINT+JSON_UNESCAPED_UNICODE);

$ch = curl_init("http://192.168.108.202:8006/set_record.php");

curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, 'data=' . $POST);

$result = curl_exec($ch); 
if (strpos ($result, 'Success') === false) exit ($result);
curl_close($ch);
 
QRcode::png('https://www.kb123.ru/qr-code-verification/?id=' . $res[0]['ID1'] . '&bc=' . $_GET['bc'], __DIR__ . '/tmp.png');

echo 'data:image/png;base64,' . base64_encode(file_get_contents(__DIR__ . '/tmp.png'));
  
		
?>