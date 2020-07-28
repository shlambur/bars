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
<div>
	<p> Журнал: <cmpLabel data="caption:HP_NAME" /></p>
	<p> Зарегистрирован: <cmpLabel data="caption:REGISTER_DATE" /></p>
	<p> Источник: <cmpLabel data="caption:PAYMENT_KIND_NAME" /></p>

	<p> Назначения: </p>
	<p> &#10065;&#8195;Процедурный кабинет &#8195; &#10065;&#8195;Рентген </p>
	<p> &#10065;&#8195;УЗИ &#8195; &#10065;&#8195;ЭКГ</p>
	

 </div>
 
</div>
   <div class="box5">
   	
<cmpImage name="Barcode" src="" visible="false"/>
   
 </div>

                 
</div></div>


<style>
        .report-form {
            /*padding: 5pt 10pt;*/
        }
        .main-div {
            width: 80mm;
            height: 160mm;
            font-size: 10pt;
           text-align: center;
		  
        }
		
		.box1{
		width: 80mm;
		height:1mm;
		/*background-color:red;*/
		line-height: 0.5;
		float: left;
		background-color:red;
		
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
		height:60mm;
		/*background-color:blue;*/
		
		float: left;
		}
		
		.box4 div{
	
		/*background-color:blue;*/
	padding-left:10mm;
		
		text-align:left;
		
		}
		
		.box5{
		width: 80mm;
		height:30mm;
		/*background-color:gray;*/
	img-align: center;
		float: left;
		
		}
	.box5 img{

width:75mm;
height:30mm;
	
		}
		
      
@media print {
  html, body {
    width: 80mm;
    height: 160mm;
  }  
}
    </style>
</div>