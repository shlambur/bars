<div cmptype="Form" oncreate="Form.onCreate();" window_size="1024x512">
<div cmptype="title">Квитанции</div>
<component cmptype="Script">
	Form.onCreate = function(){
		setVar('PATIENT_ID', getVar('PATIENT_ID', 1));
		setVar('CONTRACT_ID', getVar('CONTRACT_ID', 1));
		setVar('AGENT_ID', getVar('AGENT', 1));
	}
    //Добавить услугу в договор
    Form.onButtonOk = function(){
	    if(!empty(getValue('GRID_RECEIPTS_SelectList'))){
		    setVar('CONTR_PAY_ID', getValue('GRID_RECEIPTS_SelectList'));
	    }
	    else
		    setVar('CONTR_PAY_ID', getControlProperty('GRID_RECEIPTS', 'data')['ID']);
	    printReportByCode('Kvitantsiya_kassa_n');
    }
</component>
<component cmptype="DataSet" name="DS_ALL_SERVICES" mode="Range">
  <![CDATA[
	  select ds.REC_DATE,
	         ds.ID DIRECTION_SERVICE,
	         t.ID,
	         t.SERVICE_NAME,
	         t.PRICE,
	         t.QUANT,
	         t.DIR_SUMM - t.DISCOUNT_SUMM  SUMM,
	         ds.CABLAB_TO_NAME
	    from d_v_contracts c,
	         d_v_contract_payments t,
	         d_v_dir_serv_payments dsp,
	         d_v_direction_services ds
	    where c.ID = :CONTRACT_ID
	      and t.PID = c.ID
	      and t.PRICE > 0
	      and dsp.ID(+) = t.DIR_SERV_PAYMENT
	      and ds.ID(+) = dsp.PID
	      and t.PATIENT_ID = :PATIENT_ID
  ]]>
  <component cmptype="Variable" name="CONTRACT_ID" get="contr" src="CONTRACT_ID" srctype="var"/>
  <component cmptype="Variable" name="PATIENT_ID" get="pat" src="PATIENT_ID" srctype="var"/>
  <component cmptype="Variable" type="count" srctype="var" src="r1c"/>
  <component cmptype="Variable" type="start" srctype="var" src="r1s"/>
</component>
<component cmptype="Grid" name="GRID_RECEIPTS" dataset="DS_ALL_SERVICES" field="ID" returnfield="ID" grid_caption="Список услуг по договору"  hide_filter="true" selectlist="ID" height="426px">
	<component cmptype="Column" caption="Дата назначения" field="REC_DATE" sort="REC_DATE" align="center" sortorder="-1"/>
	<component cmptype="Column" caption="Услуга" field="SERVICE_NAME"  sort="SERVICE_NAME"/>
	<component cmptype="Column" caption="Кабинет" field="CABLAB_TO_NAME" sort="CABLAB_TO_NAME"/>
    <component cmptype="Column" caption="Кол-во" field="QUANT" align="right"/>
    <component cmptype="Column" caption="Цена" field="PRICE" align="right"/>
    <component cmptype="Column" caption="Сумма" field="SUMM" align="right"/>
    <component cmptype="GridFooter">
        <component cmptype="Range" insteadrefresh="InsteadRefresh(this);" count="15" varstart="r1s" varcount="r1c" valuecount="15" valuestart="1" />
    </component>
</component>
<component cmptype="FormButtons" style="text-align:right;">
    <component cmptype="But" name="ButtonOk" onclick="base().onButtonOk();" caption="Печать"/>
	
    <component cmptype="But" onclick="closeWindow();" caption="Отмена"/>
</component>
</div>