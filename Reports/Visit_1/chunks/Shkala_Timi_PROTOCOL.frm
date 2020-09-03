<div cmptype="bogus" name="Form_PROTOCOL" dataset="dsVisitPROTOCOL" repeate="0" style="display:none;" 
onshow="onShowBlockInVisit('Form_PROTOCOL','Label_PROTOCOL_SIGN')">
  <component cmptype="DataSet" name="dsVisitPROTOCOL">
Select
RISK_DEAD ,
RISK_POINT,
CB1,
CB2,
CB3,
CB4,
CB5,
CB6,
CB7,
CB1+CB2+CB3+CB4+CB5+CB6+CB7 as ALLCHEK,
CB1_NAME,
CB2_NAME,
CB3_NAME,
CB4_NAME,
CB5_NAME,
CB6_NAME,
CB7_NAME

from (
    select 
      max (case when F.TEMPLATE_FIELD ='CB1' then f.NUM_VALUE else null end)  CB1,
      max (case when F.TEMPLATE_FIELD ='CB2' then f.NUM_VALUE else null end)  CB2,
      max (case when F.TEMPLATE_FIELD ='CB3' then f.NUM_VALUE else null end)  CB3,
      max (case when F.TEMPLATE_FIELD ='CB4' then f.NUM_VALUE else null end)  CB4,
      max (case when F.TEMPLATE_FIELD ='CB5' then f.NUM_VALUE else null end)  CB5,
      max (case when F.TEMPLATE_FIELD ='CB6' then f.NUM_VALUE else null end)  CB6,
      max (case when F.TEMPLATE_FIELD ='CB7' then f.NUM_VALUE else null end)  CB7,
     max (case when F.TEMPLATE_FIELD ='CB1' then f.TEMPLATE_FIELD_NAME else null end)  CB1_NAME,
     max (case when F.TEMPLATE_FIELD ='CB2' then f.TEMPLATE_FIELD_NAME else null end)  CB2_NAME,
     max (case when F.TEMPLATE_FIELD ='CB3' then f.TEMPLATE_FIELD_NAME else null end)  CB3_NAME,
     max (case when F.TEMPLATE_FIELD ='CB4' then f.TEMPLATE_FIELD_NAME else null end)  CB4_NAME,
     max (case when F.TEMPLATE_FIELD ='CB5' then f.TEMPLATE_FIELD_NAME else null end)  CB5_NAME,
     max (case when F.TEMPLATE_FIELD ='CB6' then f.TEMPLATE_FIELD_NAME else null end)  CB6_NAME,
     max (case when F.TEMPLATE_FIELD ='CB7' then f.TEMPLATE_FIELD_NAME else null end)  CB7_NAME
    from D_V_VISIT_FIELDS f
    where f.PID = :VISIT
    and   num_value = 1),D_V_USR_FNKC_CALC_TIMI t
    
     WHERE CB1+CB2+CB3+CB4+CB5+CB6+CB7 = t.RISK_POINT
	
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
  
  
<table border="0" style="margin-left:120px;">
  <tr>
    <td class="RK"><component cmptype="Label" name="CB1_NAME"  captionfield="CB1_NAME"/>:</td><td><component cmptype="Label" name="CB1"  captionfield="CB1"/>  </td>
  </tr>
  <tr>
    <td class="RK"><component cmptype="Label" name="CB2_NAME"  captionfield="CB2_NAME"/> :</td><td><component cmptype="Label" name="CB2"  captionfield="CB2"/>  </td>
  </tr>
  <tr>
    <td class="RK"><component cmptype="Label" name="CB3_NAME"  captionfield="CB3_NAME"/> :</td><td><component cmptype="Label" name="CB3"  captionfield="CB3"/>  </td>
  </tr>
  <tr>
    <td class="RK"><component cmptype="Label" name="CB3_NAME"  captionfield="CB3_NAME"/> :</td><td><component cmptype="Label" name="CB3"  captionfield="CB3"/>  </td>
  </tr>
  <tr>
    <td class="RK"><component cmptype="Label" name="CB4_NAME"  captionfield="CB4_NAME"/> :</td><td><component cmptype="Label" name="CB4"  captionfield="CB4"/>  </td>
  </tr>
  <tr>
    <td class="RK"><component cmptype="Label" name="CB5_NAME"  captionfield="CB5_NAME"/> :</td><td><component cmptype="Label" name="CB5"  captionfield="CB5"/>  </td>
  </tr>
  <tr>
    <td class="RK"><component cmptype="Label" name="CB6_NAME"  captionfield="CB6_NAME"/> :</td><td><component cmptype="Label" name="CB6"  captionfield="CB6"/>  </td>
  </tr>
  <tr>
    <td class="RK"><component cmptype="Label" name="CB7_NAME"  captionfield="CB7_NAME"/> :</td><td><component cmptype="Label" name="CB7"  captionfield="CB7"/>  </td>
  </tr>
</table>
  
  
  <div class="TV" > Всего балов <component cmptype="Label" name="ALLCHEK" captionfield="ALLCHEK" caption="Всего балов"/> </div>
  <div class="TV" > Риск <component cmptype="Label" name="RISK_DEAD" captionfield="RISK_DEAD" caption="Всего балов"/> </div>
    


  <div class="TV" ><component cmptype="Image" src="Shkala/$lpu$/Sh_TIMI.jpg" width="700px" height="300"/> </div>
  


 
  
  <style>
    .RK
    {
      border-bottom:0px solid ;
      text-align: center;
      width: 500px;
      font-weight: 600;
      padding: 5px;
    }
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


