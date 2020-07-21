<div cmptype="Form" class="report_main_div" oncreate="Form.onCreate();"  window_size="210mmx297mm">
 <span style="display:none;" id="PrintSetup" ps_paperData="9" ps_orientation="landscape"></span>
<component cmptype="Script">
  <![CDATA[
  Form.onCreate = function() {
     setVar('DATE_BEGIN', $_GET['DATE_BEGIN']);
      
       setVar('DATE_END', $_GET['DATE_END']);
       
    setVar('DEP_ID', !empty($_GET['DEP_ID']) ? $_GET['DEP_ID'] : 1);
    executeAction('getHeaderInfo');
  };
  ]]>
</component>

<component cmptype="Action" name="getHeaderInfo">
  <![CDATA[
    begin
      SELECT to_char(SYSDATE, 'dd.mm.yyyy')
      INTO :REP_DATE
      FROM dual;
    end;
  ]]>
  <component cmptype="ActionVar" name="LPU" src="LPU" srctype="session" get="g0"/>
  <component cmptype="ActionVar" name="REP_DATE" src="REP_DATE" srctype="ctrlcaption" put="p1" len="20"/> 
  <component cmptype="ActionVar" name="DATE_BEGIN" get="v0" src="DATE_BEGIN" srctype="var" />
    <component cmptype="ActionVar" name="DATE_END" get="v1" src="DATE_END" srctype="var" />    
</component>



<component cmptype="DataSet" name="DS_MAIN" compile="true">
  <![CDATA[
  SELECT d.doc_fio,
         d.patient_fio,
         d.dep_name,
         d.chamber_code,
         d.payment_kind_name,
         d.dep_osm_cnt,
         d.plan_date_out,
         d.days_in,
         d.dep_id,
         (d.dep_osm_cnt)-(d.days_in)  OSM
  FROM d_v_rep_stat_empwork d
       JOIN d_v_deps t1
         ON t1.ID = d.DEP_ID
  @if (:DEP_ID != 1){
    WHERE d.dep_id = :DEP_ID
  @} else {
    WHERE t1.LPU = :LPU
  @}
  ORDER BY d.doc_fio, d.patient_fio
  ]]>
  <component cmptype="Variable" name="LPU"    src="LPU"    srctype="session"/>
  <component cmptype="Variable" name="DEP_ID" src="DEP_ID" srctype="var" get="g0"/>
</component>
<div dataset="DS_MAIN" repeate="0" distinct="DEP_ID" keyfield="DEP_ID" detail="true">
<div style="padding-bottom:50px">
  <div style="text-align:center;font-size:12pt;">
    Работа врачей отделения <component class="header-field" style="text-decoration:underline;" cmptype="Label" captionfield="DEP_NAME"/> 
    на <component class="header-field" cmptype="Label" name="REP_DATE"/>
  </div>
  <br/>
  <br/>
  <table class="table_data">
    <colgroup>
      <col style="width:15mm"/>
      <col style="width:90mm"/>
      <col style="width:20mm"/>
      <col style="width:20mm"/>
      <col style="width:10mm"/>
      <col style="width:10mm"/>
      <col style="width:20mm"/>
      <col style="width:20mm"/>
    </colgroup>
    <thead>
      <tr>
        <td>Палата</td>
        <td>ФИО пациента</td>
        <td>Вид оплаты</td>
        <td>Количество осмотров</td>
        <td>Дней в отделении</td>
        <td>Разница</td>
        <td>Выписка плановая</td>
        <td>Выписка фактич.</td>
      </tr>
    </thead>
    <tbody dataset="DS_MAIN" repeate="0" keyfield="DOC_FIO" distinct="DOC_FIO" parentfield="DEP_ID" detail="true">
      <tr>
        <td class="doc-header" colspan="7">ФИО Леч. врача: <component cmptype="Label" captionfield="DOC_FIO"/></td>
      </tr>
      <tr dataset="DS_MAIN" repeate="0" keyfield="PATIENT_FIO" detail="true" parentfieldsdata="{0:'DOC_FIO', 1:'DEP_ID'}" >
        <td><component cmptype="Label" captionfield="CHAMBER_CODE"/></td>
        <td><component cmptype="Label" captionfield="PATIENT_FIO"/></td>
        <td><component cmptype="Label" captionfield="PAYMENT_KIND_NAME"/></td>
        <td><component cmptype="Label" captionfield="DEP_OSM_CNT"/></td>
        <td><component cmptype="Label" captionfield="DAYS_IN"/></td>
        <td><component cmptype="Label" captionfield="OSM"/></td>
        <td><component cmptype="Label" captionfield="PLAN_DATE_OUT"/></td>
        <td></td>
      </tr>
    </tbody>
  </table>
</div>
</div>
<style>
  table.table_data {
    width:100%;
  }
  table.table_data td {
    padding:3px;
    text-align: center;
    vertical-align: middle;
    /*border: 1px solid black;*/
  }
  td.doc-header {
    text-align: left !important;
    border-bottom: 1px solid black;
    font-weight: bold;
  }
  table.table_data tr.tr_data td {
    text-align: left;
    vertical-align: top;
  }
  .header-field {
    font-size:12pt !important;
  }
</style>

</div>