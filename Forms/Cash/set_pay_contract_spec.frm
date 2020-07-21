<div cmptype="FORM" oncreate="base().OnCreate();" onshow="base().OnShow();">
<div cmptype="title">Оплатить услугу</div>
<!--         Begin Script Actions        -->
<component cmptype="Script">
    Form.OnCreate = function()
    {
		setVar('SUMM_TO_PAY', getVar('SUMM_TO_PAY', 1));
		setVar('CONTR_PAY_ID', getVar('CONTR_PAY_ID', 1));
		setValue('GET_BACK_REASON', getVar('PAY_REASON', 1));
		setVar('ModalResult', 0, 1);
		if (empty(getVar('DOC_TYPE_GET',1)) == false){
			setValue('DOC_TYPE',getVar('DOC_TYPE_GET',1));
		}
    }

    Form.OnShow = function()
    {
        executeAction('GET_SYSDATE', function(){refreshDataSet('DS_CASH_DEPS');});
		setValue('PAY_SUMM', getVar('SUMM_TO_PAY'));
		InitDepControl('Depends');
		base().OnCheckSysOpt();
    }
	
    Form.OnButtonOk = function()
    {
        setVar('PAY_DATE',getValue('PAY_DATE')+' '+getValue('PAY_DATE_TIME'))
        executeAction("actionSetPaid", base().OnSuccessAddUpdate);
    }
	
    Form.OnCheckSysOpt = function()
    {
		if (empty(getValue('DOC_TYPE')) == true){
			AddReqControl(getControlByName('Depends'), 'DOC_NUMB');
			AddReqControl(getControlByName('Depends'), 'DOC_DATE');
		}else{
                        setValue('DOC_NUMB','');
			setValue('DOC_DATE','');
			DelReqControl(getControlByName('Depends'), 'DOC_NUMB');
			DelReqControl(getControlByName('Depends'), 'DOC_DATE');
		}
	}

    Form.OnSuccessAddUpdate = function ()
    {
		setVar("ModalResult",1,1);
		closeWindow();
    }
</component>
	<component cmptype="Action" name="actionSetPaid">
		begin
			 D_PKG_CONTRACT_PAYMENTS.set_paid(pnid => :pnid,
                                   pnlpu => :LPU,
                                   pnpay_summ => :pnpay_summ,
                                   pncurrency => :pncurrency,
                                   pnemployer => d_pkg_employers.get_id(:LPU),
                                   pnpayment_method => :pnpayment_method,
                                   pnpayment_type => 0,
                                   pnoper_type => 0,
                                   pdpay_date => to_date(:pdpay_date,'dd.mm.yyyy hh24:MI'),
                                   pncash_section => d_pkg_cash_sections.get_section(:CABLAB,:LPU),
                                   pncash_dep => :pncash_dep,
                                   psagent_fio => :psagent_fio,
                                   pndoc_type => :pndoc_type,
                                   psdoc_numb => :psdoc_numb,
                                   pddoc_date => :pddoc_date,
                                   pncancel_payment => 0,
                                   pspayment_reason => :pspayment_reason,
                                   psreciept => :psreciept);
		end;
		<component cmptype="ActionVar" name="LPU"				src="LPU"			  srctype="session"/>
		<component cmptype="ActionVar" name="CABLAB"			src="CABLAB"		  srctype="session"/>
		<component cmptype="ActionVar" name="pnid"				src="CONTR_PAY_ID"	  srctype="var"   get="v1"/>
		<component cmptype="ActionVar" name="pnpay_summ"		src="PAY_SUMM"		  srctype="ctrl"  get="v2"/>
		<component cmptype="ActionVar" name="pncurrency"		src="PAY_CURR"		  srctype="ctrl"  get="v3"/>
		<component cmptype="ActionVar" name="pnpayment_method"	src="PAY_METHOD"	  srctype="ctrl"  get="v4"/>
		<component cmptype="ActionVar" name="pdpay_date"		src="PAY_DATE"		  srctype="var"   get="v7"/>
		<component cmptype="ActionVar" name="pncash_dep"		src="CASH_DEP"		  srctype="ctrl"  get="v9"/>
		<component cmptype="ActionVar" name="psagent_fio"		src="PAID_AGENT_H"	  srctype="ctrl"  get="v11"/>
		<component cmptype="ActionVar" name="pndoc_type"		src="DOC_TYPE"		  srctype="ctrl"  get="v12"/>
		<component cmptype="ActionVar" name="psdoc_numb"		src="DOC_NUMB"		  srctype="ctrl"  get="v13"/>
		<component cmptype="ActionVar" name="pddoc_date"		src="DOC_DATE"		  srctype="ctrl"  get="v14"/>
		<component cmptype="ActionVar" name="pspayment_reason"	src="GET_BACK_REASON" srctype="ctrl"  get="v16"/>
        <component cmptype="ActionVar" name="psreciept"	        src="CHECK_NUM"       srctype="ctrl"  get="v17"/>
	</component>
	<component cmptype="Action" name="GET_SYSDATE">
		begin
			SELECT TO_CHAR(sysdate,'dd.mm.yyyy'),
				TO_CHAR(sysdate,'dd.mm.yyyy'),
                                TO_CHAR(sysdate,'hh24:mi')
			INTO :today,
				:today_th,
                                :sys_time
			FROM DUAL;

			:result := D_PKG_CURRENCIES.get_main(:pnlpu);

			SELECT t.DEPARTMENT_ID
			INTO :DEP_ID
			FROM D_V_EMPLOYERS t
			WHERE t.ID = D_PKG_EMPLOYERS.get_id(:pnlpu);

            :check_num := d_pkg_payment_journal.generation_check_number(pncon_pay => :contr_pay_id);
		end;
        <component cmptype="ActionVar" name="contr_pay_id" get="CONTR_PAY_ID" src="CONTR_PAY_ID" srctype="var"/>
        <component cmptype="ActionVar" name="check_num"  put="check_num" src="CHECK_NUM" srctype="ctrl" len="100"/>
		<component cmptype="ActionVar" name="today"    put="day"    src="DOC_DATE" srctype="var" len="20"/>
		<component cmptype="ActionVar" name="pnlpu"    src="LPU" srctype="session"/>
		<component cmptype="ActionVar" name="today_th" put="day_th" src="PAY_DATE" srctype="ctrl" len="20"/>
		<component cmptype="ActionVar" name="sys_time" put="time_now" src="PAY_DATE_TIME" srctype="ctrl" len="20"/>
		<component cmptype="ActionVar" name="result"  put="result" src="PAY_CURR" srctype="ctrl" len="20"/>
		<component cmptype="ActionVar" name="DEP_ID"  put="DEP_ID" src="DEP_ID_FOR_CD" srctype="var" len="17"/>
	</component>
	<component cmptype="DataSet" name="DS_DOC_TYPES_DOC">
		SELECT t.ID,
             t.DT_NAME,
			 t.DT_CODE
		FROM D_V_DOC_TYPES t,
			D_V_DOC_ACCESSORIES d
		WHERE t.VERSION = D_PKG_VERSIONS.get_version_by_lpu(0,:LPU,'DOC_TYPES')
		  and d.DOC_TYPE = t.ID and d.UNITCODE='PAYMENT_JOURNAL' and d.DOC_KIND = 0
                  and d.LPU=:LPU
		<component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
	</component>
	<component cmptype="DataSet" name="DS_CURRENCIES">
		SELECT t.ID,
             t.CURNAME,
			 t.CURCODE
		FROM D_V_CURRENCIES t
		WHERE t.VERSION = D_PKG_VERSIONS.get_version_by_lpu(0,:LPU,'CURRENCIES')
		<component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
	</component>
	<component cmptype="DataSet" name="DS_PAYMENT_METHODS">
		SELECT t.ID,
             t.PM_NAME,
			 t.PM_TYPE
		FROM D_V_PAYMENT_METHODS t
		WHERE t.LPU = :LPU
		 ORDER BY DECODE(t.PM_CODE, D_PKG_OPTION_SPECS.get('CashPaymentMethod',:LPU), 0, 1) desc
		<component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
	</component>
	<component cmptype="DataSet" name="DS_CASH_DEPS" activateoncreate="false">
			SELECT t3.ID, 
				t3.CD_NAME, 
				t3.CD_CODE 			
			FROM 
			((SELECT t.ID as ID,
				t.CD_NAME as CD_NAME,
				t.CD_CODE as CD_CODE
			FROM D_V_CASH_DEPS t
			WHERE :DEP_ID is null
				and t.LPU = :LPU)
			UNION ALL
			(SELECT t2.ID as ID,
				 t2.CD_NAME as CD_NAME,
				 t2.CD_CODE as CD_CODE
			FROM D_V_CASH_DEPS t2,
				D_V_CD_DEPS t1
			WHERE :DEP_ID is not null
				 and t1.PID = t2.ID
				 and t2.LPU = :LPU
				 and t1.dep_id = :DEP_ID)
			UNION ALL
			(SELECT null as ID,
				 null as CD_NAME,
				 '-1' as CD_CODE
			FROM dual)) t3
			ORDER BY DECODE(t3.CD_CODE, D_PKG_OPTION_SPECS.get('UserCashDep',:LPU), 0, 1) desc
		<component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
		<component cmptype="Variable" name="DEP_ID" src="DEP_ID_FOR_CD" srctype="var" get="v1"/>
	</component>
<table style="width:100%;">
    <tbody>
        <tr>
            <td>
                <table class="form-table" style="width:100%;">
                    <tr>
                        <td>Сумма:</td>
                        <td>
                            <component cmptype="Edit" name="PAY_SUMM" width="100%" />
                        </td>
                        <td>Валюта:</td>
                        <td>
                            <component cmptype="ComboBox" name="PAY_CURR" width="100%">
                                <component cmptype="ComboItem" caption="" value="" />
                                <component cmptype="ComboItem" repeate="0" DataSet="DS_CURRENCIES" datafield="ID" captionfield="CURCODE" />
                            </component>
                        </td>
                    </tr>
                    <tr>
                        <td>Дата платежа:</td>
                        <td>
                            <component cmptype="DateEdit" name="PAY_DATE" />
                            <component cmptype="Edit" name="PAY_DATE_TIME" epmtyMask="true" templateMask="99:99" regularMask="^([0-1][0-9]|[2][0-3]):([0-5][0-9])" width="50"/>
                        </td>
                        <td>Способ оплаты:</td>
                        <td>
                            <component cmptype="ComboBox" name="PAY_METHOD" width="100%">
                                <component cmptype="ComboItem" repeate="0" DataSet="DS_PAYMENT_METHODS" datafield="ID" captionfield="PM_NAME" />
                            </component>
                        </td>
                    </tr>
                    <tr>
                        <td>Оплативший контрагент:</td>
                        <td colspan="3">
                            <component cmptype="Edit" name="PAID_AGENT_H" width="100%" />
                        </td>
                    </tr>
                    <tr>
                        <td>Кассовый отдел:</td>
                        <td>
                            <component cmptype="ComboBox" name="CASH_DEP" width="100%">
                                <component cmptype="ComboItem" repeate="0" DataSet="DS_CASH_DEPS" datafield="ID" captionfield="CD_NAME" />
                            </component>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <hr />
                        </td>
                    </tr>
                    <tr>
                        <td>Тип документа:</td>
                        <td>
                            <component cmptype="ComboBox" name="DOC_TYPE" style="width:100%" onchange="base().OnCheckSysOpt();">
                                <component cmptype="ComboItem" caption="" value="" />
                                <component cmptype="ComboItem" repeate="0" DataSet="DS_DOC_TYPES_DOC" datafield="ID" captionfield="DT_NAME" />
                            </component>
                        </td>
                        <td>Чек №:</td>
                        <td>
                            <component cmptype="Edit" name="CHECK_NUM" width="100%" />    <!--readonly="true"-->
                        </td>
                    </tr>
                    <tr>
                        <td>Номер:</td>
                        <td>
                            <component cmptype="Edit" name="DOC_NUMB" width="100%" />
                        </td>
                        <td>Дата:</td>
                        <td>
                            <component cmptype="DateEdit" name="DOC_DATE" />
                        </td>
                    </tr>
                    <tr>
                        <td>Основание платежа:</td>
                        <td colspan="3">
                            <component cmptype="Edit" name="GET_BACK_REASON" width="100%" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <component cmptype="FormButtons">
                                <component cmptype="But" name="BUTTON_OK" onclick="base().OnButtonOk();" caption="ОК" />
                                <component cmptype="But" onclick="base().OnSuccessAddUpdate();" caption="Отмена" />
                            </component>
                            <component cmptype="DepControls" name="Depends" requireds="PAY_DATE;PAY_SUMM;PAY_CURR;PAY_METHOD;PAY_DATE_TIME" dependents="BUTTON_OK" auto_init="0" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </tbody>
</table>
<component cmptype="MaskInspector" name="MainMaskInspector" effectControls="BUTTON_OK" controls="PAY_DATE_TIME"/>
</div>