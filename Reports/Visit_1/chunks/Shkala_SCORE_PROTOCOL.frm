<div cmptype="bogus" name="Form_PROTOCOL" dataset="dsVisitPROTOCOL" repeate="1" style="display:none;" 
onshow="onShowBlockInVisit('Form_PROTOCOL','Label_PROTOCOL_SIGN')">
    
    <component cmptype="DataSet" name="dsVisitPROTOCOL">
   
 
  
 select 
       case MALE_FAMLE when 'M' then ' Мужской' when 'F' then 'Женский' end MALE_FAMLE
      ,case SMOK_NOSMOKE when '0' then 'Не курит' when '1' then 'Курит' end SMOK_NOSMOKE
      ,AGE
      ,AD
      ,XOL
      ,S.Score Score

 from 
 (
                             select 
                            
                                      max (case when F.TEMPLATE_FIELD ='AGE' then f.NUM_value else null end) AGE,
                                      max (case when F.TEMPLATE_FIELD ='AD' then f.NUM_value else null end) AD,
                                      max (case when F.TEMPLATE_FIELD ='XOL' then f.NUM_value else null end) Xol,
                                      max (case when F.TEMPLATE_FIELD ='SMOK_NOSMOKE' then f.str_value else null end) SMOK_NOSMOKE,
                                      max (case when F.TEMPLATE_FIELD ='MALE_FAMLE' then f.str_value else null end) MALE_FAMLE
                                  
                             from D_V_VISIT_FIELDS f
                             where f.PID = :VISIT
    ) f1,D_V_USR_FNKC_CALC_SCORE s
WHERE
   
                 AGE = s.old
        and      AD = s.pressure
        and      XOL = s.cholesterol
        and      MALE_FAMLE = s.SEX
        and      SMOK_NOSMOKE = s.smoker   
       
    
    
	
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

  
  

  
     

<table border="0" style="margin-left:80px;">
<tr>
  <td class="RK"> ПОЛ :
 
</td>
<td class="RK">
  <component cmptype="Label"   captionfield="MALE_FAMLE"/> 
</td>
</tr>
<tr>
  <td class="RK"> Возраст, лет :

</td>
<td class="RK">
  <component cmptype="Label"   captionfield="AGE"/>  
</td>
</tr>

<tr>
  <td class="RK"> Статус :

</td>
<td class="RK">
  <component cmptype="Label"   captionfield="SMOK_NOSMOKE"/>  
</td>
</tr>
<tr>
  <td class="RK"> Сист.АД,мм.рт.ст. :

</td>
<td class="RK">
  <component cmptype="Label"   captionfield="AD"/>  
</td>
</tr>
<tr>
  <td class="RK"> Холестерин, ммоль/л :

</td>
<td class="RK">
  <component cmptype="Label"   captionfield="XOL"/>  
</td>
</tr>
<tr>
  <td class="RK">  Риск Score

</td>
<td class="RK">
  <component cmptype="Label"   captionfield="SCORE"/>  
</td>
</tr>
<tr><td>&#160;</td></tr>
<tr>
  <td colspan="2">
    Шкала SCORE не используется, если у пациента:
<li>
  сердечно-сосудистые заболевания, в основе которых атеросклероз сосудов
</li>
<li>
  сахарный диабет I и II типа
</li>
<li>
  очень высокие уровни артериального давления и/или общего холестерина
</li>
<li>
  хроническая болезнь почек
</li>
  </td>
</tr>
</table>


  <div class="TV" ><component cmptype="Image" src="Shkala/$lpu$/Sh_SCORE.jpg" width="600x" height="400"/> </div>

 
  
  <style>
    .RK
    {
      
      text-align: left;
      width: 290px;
      font-weight: 600;
      padding: 5px;
    border: 1px solid;
    }
    
   .RT
   {
   border: 1px solid;
   text-align: center;
      width: 100px;
      font-weight: 600;
      padding: 5px;
   }
   .TV
    {
    width:400px;
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
    border: 0px double black; 
    --background: #dc4; 
    padding: 0px; 
   }
  .RZ2
    {
    width:30px;
    --margin-left:80px;
    float: left;
    list-style: none;
    border: 0px double black; 
    --background: #fc3; 
    padding: 0px; 
   }
  </style>
  <div>
    <br/>
    <component cmptype="Image" datafield="IMAGE_ID" unit="BLOB_STORE" field="BLOB_DATA" dataset="dsVisitImages" name="Image" repeate="0" style="display: inline-block;max-width:62mm;padding-right:2mm;padding-top:2mm; padding-bottom:2mm;vertical-align:top;"/>
  </div>
</div>


