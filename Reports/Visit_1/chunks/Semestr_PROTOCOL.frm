<div cmptype="bogus" name="Form_PROTOCOL" dataset="dsVisitPROTOCOL" repeate="0" style="display:none;" 
onshow="onShowBlockInVisit('Form_PROTOCOL','Label_PROTOCOL_SIGN')">
  <component cmptype="DataSet" name="dsVisitPROTOCOL">
    select
    max (case when f.TEMPLATE_FIELD ='PPLOD' then f.STR_VALUE else null end) PPLOD,
    max (case when F.TEMPLATE_FIELD ='BRAZMER'then f.STR_VALUE else null end) BRAZMER,
    max (case when F.TEMPLATE_FIELD ='RAZZH'then f.STR_VALUE else null end) RAZZH,
    max (case when F.TEMPLATE_FIELD ='DLB'then f.STR_VALUE else null end) DLB,
    max (case when F.TEMPLATE_FIELD ='RAZP'then f.STR_VALUE else null end) RAZP,  
    max (case when F.TEMPLATE_FIELD ='SROK'then f.STR_VALUE else null end) SROK,
    max (case when F.TEMPLATE_FIELD ='MP'then f.STR_VALUE else null end) MP,        
    max (case when F.TEMPLATE_FIELD ='RP'then f.STR_VALUE else null end) RP,   
    max (case when F.TEMPLATE_FIELD ='CHSS'then f.STR_VALUE else null end) CHSS,  
    max (case when F.TEMPLATE_FIELD ='LK'then f.STR_VALUE else null end) LK,  
    max (case when F.TEMPLATE_FIELD ='TP'then f.STR_VALUE else null end) TP,
    max (case when F.TEMPLATE_FIELD ='ST'then f.STR_VALUE else null end) ST,
    max (case when F.TEMPLATE_FIELD ='KV'then f.STR_VALUE else null end) KV,
    max (case when F.TEMPLATE_FIELD ='TM'then f.STR_VALUE else null end) TM,
    max (case when F.TEMPLATE_FIELD ='DSHM'then f.STR_VALUE else null end) DSHM,
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
  <div class="TV" >Определяется один плод  в головном , тазовом положении</div>
  <div class="TV" > Положение плода :<component cmptype="Label" name="POLOZH_PLODA"  formated="true" captionfield="PPLOD"/> </div>
  <div class="TV" >Бипариенталный размер головки : <component cmptype="Label" name="BRAZMER"  formated="true" captionfield="BRAZMER"/>мм.</div>
  <div class="TV" >Размер живота : <component cmptype="Label" name="RAZZH"  formated="true" captionfield="RAZZH"/>мм.</div>
  <div class="TV" >Длинна бедра : <component cmptype="Label" name="DLB"  formated="true" captionfield="DLB"/>   мм.</div>
  <div class="TV" >Размеры : <component cmptype="Label" name="RAZP"  formated="true" captionfield="RAZP"/>
  <component cmptype="Label" name="SROK"  formated="true" captionfield="SROK"/> неделям беременности </div>
  <div class="TV" > Предпологаемая масса плода : <component cmptype="Label" name="MP"  formated="true" captionfield="MP"/>   г.</div>
  <div class="TV" > Предпологаемая рост плода : <component cmptype="Label" name="RP"  formated="true" captionfield="RP"/>   см.</div>
  <div class="TV" > Частота сердечных сокращений : <component cmptype="Label" name="CHSS"  formated="true" captionfield="CHSS"/>   уд/мин.</div>
  <div class="TV" > Локализация плаценты : <component cmptype="Label" name="LK"  formated="true" captionfield="LK"/></div>
  <div class="TV" > Толщина плаценты: <component cmptype="Label" name="TP"  formated="true" captionfield="TP"/></div>
  <div class="TV" > Структурность плаценты: <component cmptype="Label" name="ST"  formated="true" captionfield="ST"/></div>
  <div class="TV" > Колличество воды: <component cmptype="Label" name="KV"  formated="true" captionfield="KV"/></div>
  <div class="TV" > Тонус миометрия: <component cmptype="Label" name="TM"  formated="true" captionfield="TM"/></div>
  <div class="TV" > Данных о наличии уродства плода нет </div>
  <div class="TV" > Длинна шейки матки: <component cmptype="Label" name="DSHM"  formated="true" captionfield="DSHM"/> мм, канал сомкнут</div>
  <style>
   .TV
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


