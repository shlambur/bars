<div cmptype="bogus" name="Form_PROTOCOL" dataset="dsVisitPROTOCOL" repeate="0" style="display:none;" 
onshow="onShowBlockInVisit('Form_PROTOCOL','Label_PROTOCOL_SIGN')">
  <component cmptype="DataSet" name="dsVisitPROTOCOL">
      Select
      (IM1+IM2+IM3+IM4+IM5+IM6+IM7+IM8+IM9+IM10+IM11+IM12+IM13) AS TOTAL,
      i.DESCRIPTIONS,
      IM1,
      IM2,
      IM3,
      IM4,
      IM5,
      IM6,
      IM7,
      IM8,
      IM9,
      IM10,
      IM11,
      IM12,
      IM13
      from (SELECT
      max (case when F.TEMPLATE_FIELD ='IM1' then f.NUM_VALUE  else null end)                   IM1,
      replace(max (case when F.TEMPLATE_FIELD ='IM2' then f.NUM_VALUE  else null end),1,2.5)    IM2,
      replace(max (case when F.TEMPLATE_FIELD ='IM3' then f.NUM_VALUE  else null end),1,2.5)    IM3,
      max (case when F.TEMPLATE_FIELD ='IM4' then f.NUM_VALUE  else null end)                   IM4,
      replace(max (case when F.TEMPLATE_FIELD ='IM5' then f.NUM_VALUE  else null end),1,1.5)    IM5,
      replace(max (case when F.TEMPLATE_FIELD ='IM6' then f.NUM_VALUE  else null end),1,3.5)    IM6,
      replace(max (case when F.TEMPLATE_FIELD ='IM7' then f.NUM_VALUE  else null end),1,2)      IM7,
      replace(max (case when F.TEMPLATE_FIELD ='IM8' then f.NUM_VALUE  else null end),1,2)      IM8,
      replace(max (case when F.TEMPLATE_FIELD ='IM9' then f.NUM_VALUE  else null end),1,2)      IM9,
      replace(max (case when F.TEMPLATE_FIELD ='IM10' then f.NUM_VALUE  else null end),1,2.5)  IM10,
      replace(max (case when F.TEMPLATE_FIELD ='IM11' then f.NUM_VALUE  else null end),1,4)    IM11,
      replace(max (case when F.TEMPLATE_FIELD ='IM12' then f.NUM_VALUE  else null end),1,4)    IM12,
      replace(max (case when F.TEMPLATE_FIELD ='IM13' then f.NUM_VALUE  else null end),1,4.5)  IM13
      FROM D_V_VISIT_FIELDS f
      where f.PID = :VISIT), D_V_USR_FNKC_CALC_IMPROVE i
     where  (IM1+IM2+IM3+IM4+IM5+IM6+IM7+IM8+IM9+IM10+IM11+IM12+IM13) BETWEEN i.min_value and i.max_value


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
  
 <table border="0" style="margin-left:100px;">
  <tr>
    <td class="RK" style="text-align:center;">Фактор риска</td><td class="RT">Баллы  </td>
  </tr>
  <tr>
    <td class="RK">Умеренная почечная недостаточность, СКФ 30-59 мл/мин/м2 </td><td class="RT"><component cmptype="Label" name="IM1"  captionfield="IM1"/>  </td>
  </tr>
  <tr>
    <td class="RK">Тяжелая почечная недостаточность, СКФ   &#60; 30 мл/мин/м2</td><td class="RT"><component cmptype="Label" name="IM2"  captionfield="IM2"/>  </td>
  </tr>
  <tr>
    <td class="RK">Печеночная недостаточность (МНО 	&#62; 1,5) </td><td class="RT"><component cmptype="Label" name="IM3"  captionfield="IM3"/>  </td>
  </tr>

  <tr>
    <td class="RK">Мужской пол </td><td class="RT"><component cmptype="Label" name="IM4"  captionfield="IM4"/>  </td>
  </tr>
  <tr>
    <td class="RK">Возраст 40-84 лет</td><td class="RT"><component cmptype="Label" name="IM5"  captionfield="IM5"/>  </td>
  </tr>
  <tr>
    <td class="RK">Возраст 	&#62; 85 лет</td><td class="RT"><component cmptype="Label" name="IM6"  captionfield="IM6"/>  </td>
  </tr>
  <tr>
    <td class="RK">Активный рак</td><td class="RT"><component cmptype="Label" name="IM7"  captionfield="IM7"/>  </td>
  </tr>
     <tr>
         <td class="RK">Ревматические заболевания</td><td class="RT"><component cmptype="Label" name="IM8"  captionfield="IM8"/>  </td>
     </tr>
     <tr>
         <td class="RK">Центральный венозный катетер</td><td class="RT"><component cmptype="Label" name="IM9"  captionfield="IM9"/>  </td>
     </tr>
     <tr>
         <td class="RK">Пребывание в отделении интенсивной терапии в период госпитализации</td><td class="RT"><component cmptype="Label" name="IM10"  captionfield="IM10"/>  </td>
     </tr>
     <tr>
         <td class="RK">Тромбоциты 	&#60; 50* 109 /л</td><td class="RT"><component cmptype="Label" name="IM11"  captionfield="IM11"/>  </td>
     </tr>
     <tr>
         <td class="RK">Кровотечение в последние 3 месяца</td><td class="RT"><component cmptype="Label" name="IM12"  captionfield="IM12"/>  </td>

     </tr>
     <tr>
         <td class="RK">Активная язва желудка или двенадцатиперстной кишки</td><td class="RT"><component cmptype="Label" name="IM13"  captionfield="IM13"/>  </td>

     </tr>

</table>
  
  <div style="height:20px"></div>
  <div class="TV" > Всего балов: <component cmptype="Label" name="TOTAL" captionfield="TOTAL" caption="Всего балов"/> </div>
  <div class="TV" > Интерпритация риска кровоточения: <component cmptype="Label" name="DESCRIPTIONS" captionfield="DESCRIPTIONS" caption="Всего балов"/></div>
     <div style="height:20px"></div>

<!--
  <div class="TV" ><component cmptype="Image" src="Shkala/$lpu$/Sh_TIMI.jpg" width="700px" height="300"/> </div>
-->
 
  
  <style>
    .RK
    {
      
      text-align: left;
      width: 500px;
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
    width:600px;
    margin-left:90px;
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


