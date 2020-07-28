	<div>
<div cmptype="tr" name="DS_HOSPHISTORY" dataset="DS_HOSPHISTORY_HEAD"  repeat="1"
	     onafter_clone="Form.prepareBarcodeData(clone, data);" onafter_refresh="Form.getBarcodes();">
	


<div class="main-div">
  <div class="box1"></div>
  <div class="box2">
    <p> ФГБУ ФНКЦ ФХМ ФМБА России</p>
	 <p> Клиника </p>
	 <p> персональной медицины</p>
  </div>
  <div class="box3">
  	<p><b> <cmpLabel data="caption:SURNAME" /></b></p>
	<p><cmpLabel data="caption:FIRSTNAME" /> <cmpLabel data="caption:LASTNAME" /></p>
	<p><cmpLabel data="caption:BIRTHDATE" /></p>
	<p><cmpLabel data="caption:DEP" />	</p>
  </div>
   <div class="box4">

	<cmpImage name="Barcode" src="" visible="false" style="margin-top:4mm;width:40mm;height:15mm;"/>
   
 </div>
   <div class="box5">
   	
   
 </div>

                 
</div></div>


<style>
        .report-form {
            /*padding: 5pt 10pt;*/
        }
        .main-div {
            width: 279mm;
            height: 25mm;
            white-space: nowrap;
            font-size: 8pt;
            /*padding-left:0.5em;*/
			text-align: center;
		

        }
		.box1{
		width: 45mm;
		height:25mm;
		/*background-color:red;*/
		line-height: 0.5;
		float: left;
		}
		
		.box2{
		width: 42mm;
		height:25mm;
		/*background-color:gray;*/
	line-height: 0.5;
		float: left;
		}
		.box3{
		width: 43mm;
		height:25mm;
		line-height: 0.2;
		/*background-color:green;*/
	
		float: left;
		}
		
		.box4{
		width: 50mm;
		height:25mm;
		/*background-color:blue;*/
	padding-top:10 mm;
		float: left;
		}
		
		.box5{
		width: 69mm;
		height:25mm;
		/*background-color:gray;*/
	img-align: center;
		float: left;
		
		}
		
        .main-div > div { /* PDF fix */
            overflow: hidden;
        }
        .main-div table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
            font-size: 10pt;
        }
        .main-div table td {
            overflow: hidden;
            white-space: nowrap;
        }
        .main-div table td span.caption {
            padding-left: 2px;
        }
        .header-table {
            padding-top: 30pt;
        }
        .header-table > tbody > tr > td:first-child {
            padding-right: 10pt;
            width: 35%;
            white-space: normal;
            height: 100%;
            overflow: visible;
        }
        .header-table > tbody > tr > td:first-child .field {
            height: 100%;
            line-height: normal;
        }
        .header-table > tbody > tr > td:last-child {
            width: 50%;
        }
        .title {
            text-align: center;
            padding-top: 15pt;
            padding-bottom: 5pt;
            font-weight: bold;
            position: relative;
            width: 100%;
        }
        .main-div div {
            margin: 0;
            position: relative;
        }
        .main-div div.sign {
            text-align: center;
            font-size: 8pt;
            line-height: 8pt;
        }
        .main-div span.text {
            position: absolute;
            white-space: normal;
            width: 100%;
            top: 1.5pt;
            left: 0;
            font-weight: bold;
            line-height: 15pt;
        }
        .diag-table {
            border-bottom: 1px solid #000;
        }
        .diag-table > tbody > tr > td:first-child {
            border-right: 1px solid #000;
        }
        .diag-table > tbody > tr > td:last-child > p:first-child {
            text-align: center;
        }
        .diag-table table > tbody > tr > td:first-child {
            width: 65%;
        }
        .field {
            border-bottom: 1px solid #000;
            padding: 0 2px;
            display: inline-block;
            vertical-align: text-bottom;
            height: 14pt;
            line-height: 18pt;
            width: 100%;
            font-weight: bold;
        }
        .notnowrap {
            white-space: normal;
        }
        .underlined {
            border-bottom: 1px solid #000;
            padding: 0 2px;
        }
        .text1 {
            white-space: normal;
            font-weight: bold;
            border-bottom: 1px solid #000;
            line-height: 15pt;
        }
		
		
@media print {
  html, body {
    width: 279mm;
    height: 25mm;
  }  
}
    </style>
</div>