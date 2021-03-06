<div cmptype="bogus" name="Form_PROTOCOL" dataset="dsVisitPROTOCOL" repeate="0" style="display:none;" 
onshow="onShowBlockInVisit('Form_PROTOCOL','Label_PROTOCOL_SIGN')">
  <component cmptype="DataSet" name="dsVisitPROTOCOL">
   select  
   f1.ROST,
   f1.VES,
    ROUND(VES / power(ROST,2),1) as TOTAL,
	HEARTSCORE, 
	BODYWEIGHT
	
from 
(
    select 
      max (case when F.TEMPLATE_FIELD ='ROST' then f.NUM_VALUE else null end)  ROST ,
      max (case when F.TEMPLATE_FIELD ='VES' then f.NUM_VALUE else null end)  VES  
    from D_V_VISIT_FIELDS f
    where f.PID = :VISIT 
	) f1,
D_V_USR_FNKC_CALC_BMI d
	where  

	ROUND(VES / power(ROST,2),1) BETWEEN d.MIN_VALUE AND d.MAX_VALUE
	
    <component cmptype="Variable" name="VISIT" src="VISIT" srctype="var" get="v0"/>
  
  </component>







  <component cmptype="DataSet" name="dsVisitImages">
      select vfc.BLOB_VALUE         IMAGE_ID
        from D_V_VISIT_FIELD_CONTS vfc
       where vfc.PID = :VISIT
         and vfc.TEMP_CON_FIELD = 'RES_IMAGE_4UZ'
    <component cmptype="Variable" name="VISIT" src="VISIT" srctype="var" get="v0"/>
  </component>
  
  <div style="display:none">
        <component cmptype="Label" name="Label_PROTOCOL_SIGN" captionfield="SIGN"/>
  </div>
  
  <div class="TV" >Рост : <component cmptype="Label" name="ROST"  captionfield="ROST"/></div>
  <div class="TV" >Вес : <component cmptype="Label" name="VES"  captionfield="VES"/></div>
  <div class="TV" >ИНДЕКС МАССЫ ТЕЛА : <component cmptype="Label" name="TOTAL" captionfield="TOTAL"/></div>
    <div class="TV" >РИСК ССЗ : <component cmptype="Label" name="HEARTSCORE" captionfield="HEARTSCORE"/></div>
	  <div class="TV" > МАССА ТЕЛА : <component cmptype="Label" name="BODYWEIGHT" captionfield="BODYWEIGHT"/></div>
  <div class="TV" ><component cmptype="Image" src="Shkala/$lpu$/Sh_Ketle.png" width="700px" height="300"/> </div>
  


 
  
  <style>
   .TV
    {
    width:600px;
    margin-left:80px;
	font-weight: 600; 
    border: 0px double black; /* Параметры границы */
    --background: #fc3; /* Цвет фона */
    padding: 0px; /* Поля вокруг текста */
   }
   .RZ1
    {
    width:70px;
    margin-left:80px;
    float: left;
    list-style: none;
    border: 0px double black; /* Параметры границы */
    --background: #dc4; /* Цвет фона */
    padding: 0px; /* Поля вокруг текста */
   }
  .RZ2
    {
    width:30px;
    --margin-left:80px;
    float: left;
    list-style: none;
    border: 0px double black; /* Параметры границы */
    --background: #fc3; /* Цвет фона */
    padding: 0px; /* Поля вокруг текста */
   }
  </style>
  <div>
    <br/>
    <component cmptype="Image" datafield="IMAGE_ID" unit="BLOB_STORE" field="BLOB_DATA" dataset="dsVisitImages" name="Image" repeate="0" style="display: inline-block;max-width:62mm;padding-right:2mm;padding-top:2mm; padding-bottom:2mm;vertical-align:top;"/>
  </div>
</div>


