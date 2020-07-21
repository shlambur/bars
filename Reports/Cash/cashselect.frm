<div cmptype="bogus" oncreate="base().onCreate();" onshow="base().onShow();" window_size="autox210">
<component cmptype="Script">
	Form.onCreate = function() 
	{
		setVar('REPORT_B',getVar('REPORT_B',1));
		setVar('REPORT_E',getVar('REPORT_E',1));
	}
	Form.onShow=function()
	{
		var wincap="Касса";
		executeAction('getDefSection',function()
		{
			if(getVar('F')=='1')
                        {
				setValue('DATE_B',getVar('REPORT_B'));
				setValue('DATE_E',getVar('REPORT_E'));
			}
		});
		setWindowCaption(wincap);
	}
	Form.onChange = function()
        {
		if(getValue('GROUP')!=0)
                {
			setControlProperty('ORDER', 'enabled', false);
		}
		else if(getValue('GROUP')==0)
                {
			setControlProperty('ORDER', 'enabled', true);
		}
	}
	Form.OnButtonOk = function()
	{
		setVar('DATE_B', getValue('DATE_B'));
		setVar('DATE_E', getValue('DATE_E'));
		setVar('CASH_SECTION', getValue('CASH_SECT'));
		setVar('CASH_SECT', getValue('CASH_SECT'));
		setVar('DEP', getValue('DEP'));
		
		setVar('rep_paramdate_s', getValue('DATE_B'));
		setVar('rep_paramdate_po', getValue('DATE_E'));
		setVar('rep_paramid', getValue('CASH_SECT'));
				
		if(getValue('GROUP')==0)
		{
			if(getValue('ORDER')==0)
                        {
				printReportByCode('sys_cash_web');
			}
			else if(getValue('ORDER')==1)
                        {
				printReportByCode('sys_cash_order_by_contract_web');
			}				
		}	
		else if(getValue('GROUP')==1)
		{
			printReportByCode('sys_cash_patient_web');
		}
		else if(getValue('GROUP')==2)
		{
			printReportByCode('sys_cash_service_web');
		}
		else if(getValue('GROUP')==3)
                {
			printReportByCode('sys_cash_day_service_web');
		}
	}
</component>
<component cmptype="DepControls" requireds="DATE_B;DATE_E" dependents="ButtonOk"/>
<component cmptype="Action" name="getDefSection">
	begin
		:CASH_SECT := nvl(d_pkg_cash_sections.get_section(:CABLAB,:LPU),'-1');
		if :REPORT_B is null and :REPORT_E is null then
		:SYSDATE := to_char(to_date(sysdate, 'dd.mm.yyyy'));
		else 
		:F :=1;
		end if;
	end;
	<component cmptype="ActionVar" name="LPU" src="LPU" srctype="session"/>
	<component cmptype="ActionVar" name="CABLAB" src="CABLAB" srctype="session"/>
	<component cmptype="ActionVar" name="CASH_SECT" src="CASH_SECT" srctype="ctrl" put="CASH_SECT" len="17"/>
	<component cmptype="ActionVar" name="SYSDATE" put="p0" len="20" src="DATE_B" srctype="ctrl"/>
	<component cmptype="ActionVar" name="SYSDATE" put="p1" len="20" src="DATE_E" srctype="ctrl"/>
	<component cmptype="ActionVar" name="REPORT_B" get="v0" src="REPORT_B" srctype="var"/>
	<component cmptype="ActionVar" name="REPORT_E" get="v1" src="REPORT_E" srctype="var"/>
	<component cmptype="ActionVar" name="F" put="p2" src="F" srctype="var" len="1"/>
</component>
<component cmptype="DataSet" name="DS_CASH_SECTIONS">
	select t.ID,
		t.CS_NAME CODE
	from d_v_cash_sections t
	where t.LPU = :LPU
        order by t.CS_NAME
	<component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
</component>
<component cmptype="DataSet" name="DS_CASH_DEPS">
	select t.ID, t.CD_NAME
        from D_V_CASH_DEPS t
	where t.LPU = :LPU
        order by t.CD_NAME
	<component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
</component>
<table style="width:100%;min-width:400px;" class="form-table">
<tbody style="width:100%">
<tr>
	<td>
		Период с:
	</td>
	<td>
		<component cmptype="DateEdit" name="DATE_B" emptyMask="true" typeMask="date"/>
	</td>
	<td>
		по:
	</td>
	<td style="text-align:right;">
		<component cmptype="DateEdit" name="DATE_E" emptyMask="true" typeMask="date"/>
	</td>
</tr>
<tr>
	<td>
		Секция кассы:
	</td>
	<td colspan="3">
		<component cmptype="ComboBox" name="CASH_SECT" width="100%">
			<component cmptype="ComboItem" caption="Все" value="-1"/>
			<component cmptype="ComboItem" dataset="DS_CASH_SECTIONS" repeate="0" captionfield="CODE" datafield="ID"/>
		</component>
	</td>
</tr>
<tr>
	<td>
		Кассовый отдел:
	</td>
	<td colspan="3">
		<component cmptype="ComboBox" name="DEP" width="100%">
			<component cmptype="ComboItem" caption="Все" value=""/>
			<component cmptype="ComboItem" dataset="DS_CASH_DEPS" repeate="0" captionfield="CD_NAME" datafield="ID"/>
		</component>
	</td>
</tr>
<tr>
	<td>
		Группировка:
	</td>
	<td  colspan="3">
		<component cmptype="ComboBox" name="GROUP" width="100%" onchange="base().onChange();">
			<component cmptype="ComboItem" caption="Нет" value="0" activ="true" enabled="false" name="item_no"/>
			<component cmptype="ComboItem" caption="По пациенту" value="1" name="item_by_pat"/>
			<component cmptype="ComboItem" caption="По услуге" value="2" name="item_by_service"/>
			<component cmptype="ComboItem" caption="По услуге и дате" value="3" name="item_by_serv_date"/>
		</component>
	</td>
</tr>
<tr>
	<td>
		Сортировка:
	</td>
	<td colspan="3">
		<component cmptype="ComboBox" name="ORDER" width="100%">
			<component cmptype="ComboItem" caption="По ФИО пациента" value="0" activ="true"/>
			<component cmptype="ComboItem" caption="По Номеру договора" value="1" name="sort_by_contr"/>
		</component>
	</td>
</tr>
</tbody>
</table>
<component cmptype="MaskInspector" effectControls="ButtonOk" controls="DATE_B;DATE_E"/>
<component cmptype="FormButtons">
        <component cmptype="But" name="ButtonOk" onclick="base().OnButtonOk();" caption="Печать" />
        <component cmptype="But" onclick="closeWindow();" caption="Отмена" />
</component>
</div>