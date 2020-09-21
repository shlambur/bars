<div cmptype="bogus" name="Form_PROTOCOL" dataset="dsVisitPROTOCOL" repeate="1" style="display:none;" 
onshow="onShowBlockInVisit('Form_PROTOCOL','Label_PROTOCOL_SIGN')">
    
    <component cmptype="DataSet" name="dsVisitPROTOCOL">
  select
   round((0.56*sqrt(TJC))+(0.28*sqrt(SJC))+(0.7*ln(SOE)+0.017*VASH),2)DAS28,
   SOE,
   VASH,
   TJC,
   SJC,
   r.description DESCRIPTION

from (
    select 
      count( case when  num_value = 1 and f.template_field in 
     ('Z1','Z2','Z3','Z4','Z5',
     'RZ1','RZ2','RZ3','RZ4','RZ5',
     'F1','F2','F3','F4','F5',
     'RF1','RF2','RF3','RF4','RF5',
     'PL_LEFT','PL_RIGHT','LO_LEFT','LO_RIGHT','ZP_LEFT','ZP_RIGHT','KO_LEFT','KO_RIGHT')
      then 1 end) as TJC,

      count( case when  num_value = 1 and template_field in 
   ('SZ1','SZ2','SZ3','SZ4','SZ5',
   'SRZ1','SRZ2','SRZ3','SRZ4','SRZ5', 
   'SF1','SF2','SF3','SF4','SF5',
   'SRF1','SRF2','SRF3','SRF4','SRF5',
   'SPL_LEFT','SPL_RIGHT','SLO_LEFT','SLO_RIGHT','SZP_LEFT','SZP_RIGHT','SKO_LEFT','SKO_RIGHT') 
     then 1 end) as SJC,
--
      max (case when F.TEMPLATE_FIELD ='PL_LEFT' then f.NUM_VALUE else null end)   PL_LEFT ,
      max (case when F.TEMPLATE_FIELD ='PL_RIGHT' then f.NUM_VALUE else null end)  PL_RIGHT,
      max (case when F.TEMPLATE_FIELD ='LO_LEFT' then f.NUM_VALUE else null end)   LO_LEFT,
      max (case when F.TEMPLATE_FIELD ='LO_RIGHT' then f.NUM_VALUE else null end)  LO_RIGHT,
      max (case when F.TEMPLATE_FIELD ='ZP_LEFT' then f.NUM_VALUE else null end)  ZP_LEFT,
      max (case when F.TEMPLATE_FIELD ='ZP_RIGHT' then f.NUM_VALUE else null end)  ZP_RIGHT,
       max (case when F.TEMPLATE_FIELD ='KO_LEFT' then f.NUM_VALUE else null end)  KO_LEFT,
       max (case when F.TEMPLATE_FIELD ='KO_RIGHT' then f.NUM_VALUE else null end)  KO_RIGHT,
        max (case when F.TEMPLATE_FIELD ='Z1' then f.NUM_VALUE else null end)  Z1,
        max (case when F.TEMPLATE_FIELD ='Z2' then f.NUM_VALUE else null end)  Z2,
        max (case when F.TEMPLATE_FIELD ='Z3' then f.NUM_VALUE else null end)  Z3,
        max (case when F.TEMPLATE_FIELD ='Z4' then f.NUM_VALUE else null end)  Z4,
        max (case when F.TEMPLATE_FIELD ='Z5' then f.NUM_VALUE else null end)  Z5,
         max (case when F.TEMPLATE_FIELD ='RZ1' then f.NUM_VALUE else null end)  RZ1,
         max (case when F.TEMPLATE_FIELD ='RZ2' then f.NUM_VALUE else null end)  RZ2,
         max (case when F.TEMPLATE_FIELD ='RZ3' then f.NUM_VALUE else null end)  RZ3,
         max (case when F.TEMPLATE_FIELD ='RZ4' then f.NUM_VALUE else null end)  RZ3,
         max (case when F.TEMPLATE_FIELD ='RZ5' then f.NUM_VALUE else null end)  RZ5,
        
            max (case when F.TEMPLATE_FIELD ='F1' then f.NUM_VALUE else null end)  F1,
            max (case when F.TEMPLATE_FIELD ='F2' then f.NUM_VALUE else null end)  F2,
            max (case when F.TEMPLATE_FIELD ='F3' then f.NUM_VALUE else null end)  F3,
            max (case when F.TEMPLATE_FIELD ='F4' then f.NUM_VALUE else null end)  F4,
            max (case when F.TEMPLATE_FIELD ='F5' then f.NUM_VALUE else null end)  F5,
                max (case when F.TEMPLATE_FIELD ='RF1' then f.NUM_VALUE else null end)  RF1,
                max (case when F.TEMPLATE_FIELD ='RF2' then f.NUM_VALUE else null end)  RF2,
                max (case when F.TEMPLATE_FIELD ='RF3' then f.NUM_VALUE else null end)  RF3,
                max (case when F.TEMPLATE_FIELD ='RF4' then f.NUM_VALUE else null end)  RF4,
                max (case when F.TEMPLATE_FIELD ='RF5' then f.NUM_VALUE else null end)  RF5,
            
            
      max (case when F.TEMPLATE_FIELD ='SPL_LEFT' then f.NUM_VALUE else null end)   SPL_LEFT ,
      max (case when F.TEMPLATE_FIELD ='SPL_RIGHT' then f.NUM_VALUE else null end)  SPL_RIGHT,
      max (case when F.TEMPLATE_FIELD ='SLO_LEFT' then f.NUM_VALUE else null end)   SLO_LEFT,
      max (case when F.TEMPLATE_FIELD ='SLO_RIGHT' then f.NUM_VALUE else null end)  SLO_RIGHT,
      max (case when F.TEMPLATE_FIELD ='SZP_LEFT' then f.NUM_VALUE else null end)   SZP_LEFT,
      max (case when F.TEMPLATE_FIELD ='SZP_RIGHT' then f.NUM_VALUE else null end)  SZP_RIGHT,
      max (case when F.TEMPLATE_FIELD ='SKO_RIGHT' then f.NUM_VALUE else null end)  SKO_LEFT,
      max (case when F.TEMPLATE_FIELD ='SKO_RIGHT' then f.NUM_VALUE else null end)  SKO_RIGHT,
      
      
        max (case when F.TEMPLATE_FIELD ='SZ1' then f.NUM_VALUE else null end)  SZ1,
        max (case when F.TEMPLATE_FIELD ='SZ2' then f.NUM_VALUE else null end)  SZ2,
        max (case when F.TEMPLATE_FIELD ='SZ3' then f.NUM_VALUE else null end)  SZ3,
        max (case when F.TEMPLATE_FIELD ='SZ4' then f.NUM_VALUE else null end)  SZ4,
        max (case when F.TEMPLATE_FIELD ='SZ5' then f.NUM_VALUE else null end)  SZ5,
        
         max (case when F.TEMPLATE_FIELD ='SRZ1' then f.NUM_VALUE else null end)  SRZ1,
         max (case when F.TEMPLATE_FIELD ='SRZ2' then f.NUM_VALUE else null end)  SRZ2,
         max (case when F.TEMPLATE_FIELD ='SRZ3' then f.NUM_VALUE else null end)  SRZ3,
         max (case when F.TEMPLATE_FIELD ='SRZ4' then f.NUM_VALUE else null end)  SRZ4,
         max (case when F.TEMPLATE_FIELD ='SRZ5' then f.NUM_VALUE else null end)  SRZ5,
        
            
            max (case when F.TEMPLATE_FIELD ='SF1' then f.NUM_VALUE else null end)  SF1,
            max (case when F.TEMPLATE_FIELD ='SF2' then f.NUM_VALUE else null end)  SF2,
            max (case when F.TEMPLATE_FIELD ='SF3' then f.NUM_VALUE else null end)  SF3,
            max (case when F.TEMPLATE_FIELD ='SF4' then f.NUM_VALUE else null end)  SF4,
            max (case when F.TEMPLATE_FIELD ='SF5' then f.NUM_VALUE else null end)  SF5,
            
             max (case when F.TEMPLATE_FIELD ='SRF1' then f.NUM_VALUE else null end)  SRF1,
             max (case when F.TEMPLATE_FIELD ='SRF2' then f.NUM_VALUE else null end)  SRF2,
             max (case when F.TEMPLATE_FIELD ='SRF3' then f.NUM_VALUE else null end)  SRF3,
             max (case when F.TEMPLATE_FIELD ='SRF4' then f.NUM_VALUE else null end)  SRF4,
             max (case when F.TEMPLATE_FIELD ='SRF5' then f.NUM_VALUE else null end)  SRF5,
            
            
                 max (case when F.TEMPLATE_FIELD ='SOE' then f.NUM_VALUE else null end)  SOE,
                 max (case when F.TEMPLATE_FIELD ='VASH' then f.NUM_VALUE else null end)  VASH
                   
                             from D_V_VISIT_FIELDS F
                             where f.PID =:VISIT), D_V_USR_FNKC_CALC_RA R
        where round((0.56*sqrt(TJC))+(0.28*sqrt(SJC))+(0.7*ln(SOE)+0.017*VASH),2) BETWEEN R.MIN_VALUE AND R.MAX_VALUE
 
 
    
	
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
    <td class="RK"> СОЭ :</td>
  <td class="RK"> <component cmptype="Label"   captionfield="SOE"/>mm\hr </td>
  </tr>
  <tr>
    <td class="RK"> Визуалбно аналогавая шкала:</td>
  <td class="RK"> <component cmptype="Label"   captionfield="VASH"/>   Point </td>
  </tr>
<tr>
  <td class="RK"> Tender Joint Count :</td>
<td class="RK"> <component cmptype="Label"   captionfield="TJC"/> </td>
</tr>
<tr>
  <td class="RK"> Swollen Joint Count </td>
<td class="RK"><component cmptype="Label"   captionfield="SJC"/>  </td>
</tr>
<tr>
  <td class="RK"> DAS28 = <component cmptype="Label"   captionfield="DAS28"/></td>
  <td class="RK"><component cmptype="Label"   captionfield="DESCRIPTION"/></td>
</tr>
</table>

<DIV style="height: 20PX;"></DIV>

 <table style="margin-left:80px;">
  <TR>
   <td class="VA">10</td>
   <td class="VA"></td>
   <td class="VA"></td>
   <td class="VA"></td>
   <td class="VA"></td>
   <td class="VA"></td>
   <td class="VA"></td>
   <td class="VA"></td>
   <td class="VA"></td>
   <td style="width: 1px;">100</td>
  </TR>
    <TR>
      <td class=""> НЕТ БОЛИ </td>
      <td class=""></td>
      <td class=""></td>
      <td class=""></td>
      <td class=""></td>
      <td class=""></td>
      <td class=""></td>
      <td class=""></td>
      <td class=""></td>
      <td style="width: 1px;">НЕ СТЕРПИМАЯ БОЛЬ</td>
    </TR>

 </table>

 <table style="margin-left:80px; width: 600px;">
   <tr>
     <td style="font-weight: 600; padding: 15px;">  Примечания:</td>
   </tr>
   <tr><td  > 
     <li>Суставы кистей рук, которые включены в оценку: с первого по пятый пястно-фаланговые суставы, межфаланговый сустав большого пальца и со второго по пятый проксимальные межфаланговые суставы.</li>
     <li>Оценка GH или Общая оценка здоровья (Global Health) представляет собой самостоятельную оценку пациентом активности заболевания по шкале от 0 до 100, где 100 означает максимальную активность.</li>
    <li>Снижение DAS-28 на 0,6 означает умеренное улучшение. Снижение более чем на 1,2 означает значительное улучшение.</li>
  </td>
   </tr>
 </table>




 
  
  <style>


    .VA
    {
  border-bottom: 1px solid;
  width: 1cm;
   }


    .RK
    {
      
      text-align: left;
      width: px;
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


