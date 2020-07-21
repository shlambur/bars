<div cmptype="bogus" name="Form_PROTOCOL" dataset="dsVisitPROTOCOL" repeate="0" style="display:none;" 
onshow="onShowBlockInVisit('Form_PROTOCOL','Label_PROTOCOL_SIGN')">
  <component cmptype="DataSet" name="dsVisitPROTOCOL">
    select
    max(case when f.TEMPLATE_FIELD = 'PROTOCOL' then f.STR_VALUE else null end) PROTOCOL,
    max (case when F.TEMPLATE_FIELD ='004'then f.STR_VALUE else null end) APARAT,
    max (case when F.TEMPLATE_FIELD ='003'then f.NUM_VALUE else null end) DOZA,
    max (case when F.TEMPLATE_FIELD ='001'then f.NUM_VALUE else null end) KOL,
    max (case when F.TEMPLATE_FIELD ='002'then f.NUM_VALUE else null end) RAZMER1,
    max (case when F.TEMPLATE_FIELD ='007'then f.NUM_VALUE else null end) RAZMER2,
    decode(max(case when f.TEMPLATE_FIELD in ('PROTOCOL') then trim(f.STR_VALUE) else null end),
    null, 0, 1) SIGN
    
    from D_V_VISIT_FIELDS f
    where f.PID = :VISIT     
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
  <div class="TP" >Протокол исследования :<component cmptype="Label" name="TEXT_PROTOCOL"  formated="true" captionfield="PROTOCOL"/></div>
  <div class="TP" >Исследование провендено на : <component cmptype="Label" name="TEXT_APARAT"  formated="true" captionfield="APARAT"/></div>
  <div class="TP" >Доза : <component cmptype="Label" name="TEXT_DOZA"  formated="true" captionfield="DOZA"/></div>
  <div class="TP" >Количество плёнки : <component cmptype="Label" name="TEXT_KOL"  formated="true" captionfield="KOL"/></div>
  <div class="RZ1" >Размер : <component cmptype="Label" name="TEXT_RAZMER1"  formated="true" captionfield="RAZMER1"/></div>
  <div class="RZ2" >X <component cmptype="Label" name="TEXT_RAZMER2"  formated="true" captionfield="RAZMER2"/></div>
  <style>
   .TP
    {
    width:600px;
    margin-left:80px;
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


