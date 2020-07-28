	<div>
<div cmptype="tr" name="DS_HOSPHISTORY" dataset="DS_HOSPHISTORY_HEAD"  repeat="1"
	     onafter_clone="Form.prepareBarcodeData(clone, data);" onafter_refresh="Form.getBarcodes();">
	


<div class="main-div">
  <div class="box1">

  </div>
  <div class="box2">
    <p> ФГБУ ФНКЦ ФХМ ФМБА России</p>
	 
	 <p> Клиническая больница №123</p>
	 <p>  Приёмное отделение</p>
	  <p>  ТАЛОН АМБУЛАТОРНОГО ПАЦИЕНТА</p>
	
  </div>
  <div class="box3">
  	<p><b> <cmpLabel data="caption:SURNAME" /></b></p>
	<p><cmpLabel data="caption:FIRSTNAME" /> <cmpLabel data="caption:LASTNAME" /></p>
	<p><cmpLabel data="caption:BIRTHDATE" /></p>

  </div>
   <div class="box4">

	<p> Журнал: <cmpLabel data="caption:HP_NAME" /></p>
	<p> Зарегистрирован: <cmpLabel data="caption:REGISTER_DATE" /></p>
	<p> Источник: <cmpLabel data="caption:PAYMENT_KIND_NAME" /></p>
	
   
 </div>
   <div class="box5">
   	
<cmpImage name="Barcode" src="" visible="false" style="margin-top:4mm;width:60mm;height:30mm;"/>
   
 </div>

                 
</div></div>


<style>
        .report-form {
            /*padding: 5pt 10pt;*/
        }
        .main-div {
            width: 80mm;
            height: 160mm;
            white-space: nowrap;
            font-size: 10pt;
            /*padding-left:0.5em;*/
			text-align: center;
		

        }
		.box1{
		width: 80mm;
		height:35mm;
		/*background-color:red;*/
		line-height: 0.5;
		float: left;
		
		}
		
		.box2{
		width: 80mm;
		height:30mm;
		/*background-color:gray;*/
	line-height: 0.5;
		float: left;
		}
		.box3{
		width: 80mm;
		height:25mm;
		line-height: 0.2;
		/*background-color:green;*/
	font-size: 14pt;
		float: left;
		}
		
		.box4{
		width: 80mm;
		height:30mm;
		/*background-color:blue;*/
	padding-top:10 mm;
		float: left;
		}
		
		.box5{
		width: 80mm;
		height:40mm;
		/*background-color:gray;*/
	img-align: center;
		float: left;
		
		}
		
      
@media print {
  html, body {
    width: 80mm;
    height: 160mm;
  }  
}
    </style>
</div>