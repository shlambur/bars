<div cmptype="form" oncreate="base().REGFINISH_onCreate();" onshow="base().REGFINISH_onShow();">
    <!--
    НА ВХОД:
    DirectionID - DIRECTIONS.ID
    -->
    <div cmptype="title">Регистратура - результат записи</div>
    <component  cmptype="SubForm" path="Visit/PrintVisit"/>
	<component cmptype="DataSet" name="DSServices">
        <![CDATA[
            select ds.ID,
                   ds.SERVICE_NAME SERVICE,
                   ds.SERVICE  SERVICE_CODE,
                   ds.SERVICE_ID,
                   ds.EMPLOYER_FIO_TO EMPLOYER,
                   ds.REC_DATE,
                   CASE
                     WHEN to_char(ds.REC_DATE, 'HH24:MI') = '00:00'
                     THEN to_char(ds.REC_DATE, 'dd.mm.yyyy')
                     ELSE to_char(ds.REC_DATE, 'dd.mm.yyyy HH24:MI')
                   END || ' ' || TO_CHAR(ds.REC_DATE, 'FMDay', 'NLS_DATE_LANGUAGE = RUSSIAN') ||
                     CASE
                       WHEN ds.TICKET_N IS NOT NULL
                       THEN ' Талон № ' || ds.TICKET_N
                     END TIME_REC_DATE,
                   ds.DP_NAME||'/'||ds.CABLAB_TO_NAME DEP_CAB_NAMES,
                   (select count(1)
                      from d_v_direction_services ds1
                     where ds1.HID = ds.ID) as CN,
                   ds.ID||'|'||pmc.AGENT ID_DS_AGENT,
                   d.PATIENT PMC_ID
              from D_V_DIRECTIONS_BASE d
                   join d_v_direction_services ds on ds.PID = d.ID
                   join D_V_PERSMEDCARD_BASE pmc on pmc.ID = d.PATIENT
             where ds.PID = :DIRECTION
               and ds.hid is null
               and ds.rec_date is not null
        ]]>
		<component cmptype="Variable" name="DIRECTION" get="ID" src="DirectionID" srctype="var"/>
	</component>
	<component cmptype="DataSet" name="DSServicesSP">
        <![CDATA[
		select ds.SERVICE_NAME SERVICE,
		       ds.SERVICE SERVICE_CODE,
		       ds.HID
		  from d_v_direction_services ds
		 where ds.PID    = :DIRECTION
		   and ds.HID is not null
        ]]>
		<component cmptype="Variable" name="DIRECTION" get="ID" src="DirectionID" srctype="var"/>
	</component>
	<component cmptype="DataSet" name="DSInfo">
        <![CDATA[
		select pmc.nSEX SEX,
			   t.PATIENT,
			   t.PATIENT_ID,
               pmc.AGENT
		  from d_v_directions t,
		       d_v_persmedcard pmc
		 where t.PATIENT_ID = pmc.ID
		   and t.id=:DIRECTION
        ]]>
		<component cmptype="Variable" name="DIRECTION" get="ID" src="DirectionID" srctype="var"/>
	</component>
	<component cmptype="Action" name="GetTrueDSID" mode="post">
        <![CDATA[
			BEGIN
			    select t.SERVICE_TYPE
			      into :SE_TYPE
			      from D_V_DIRECTION_SERVICES t
			     where t.ID = :DIR_SER;
			    IF :SE_TYPE = 1 THEN
				    :HELP := D_PKG_DIRECTION_SERVICES.GET_LAST_PROC_DS(:DIR_SER, nvl(:LPU_DS,:PNLPU));
			    ELSE
				    :HELP := null;
			    END IF;
			END;
        ]]>
		<component cmptype="ActionVar" name="PNLPU"   src="LPU"             srctype="session"/>
		<component cmptype="ActionVar" name="LPU_DS"  src="LPU_DS"          srctype="var" get="v0"/>
		<component cmptype="ActionVar" name="DIR_SER" src="REP_ID"          srctype="var" get="SERV_ID"/>
		<component cmptype="ActionVar" name="HELP"    src="REPP_ID"         srctype="var" put="v1"              len="17"/>
		<component cmptype="ActionVar" name="SE_TYPE" src="SE_TYPE_ID_TEST" srctype="var" put="SE_TYPE_ID_TEST" len="10"/>
	</component>
	<component cmptype="Action" name="getContract" mode="post">
		<![CDATA[
		    begin
                select cp.PID,
                       cp.ID
                  into :CONTRACT_ID,
                       :CONTR_PAY_ID
                  from d_v_direction_services ds
                       join d_v_dir_serv_payments dsp on dsp.PID = ds.ID
                       join d_v_contract_payments cp on cp.DIR_SERV_PAYMENT = dsp.ID
                 where ds.ID = :DS_ID
                   and rownum = 1;
                exception when no_data_found then
                    :CONTRACT_ID := null;
                    :CONTR_PAY_ID := null;
		    end;
		]]>
		<component cmptype="ActionVar" name="DS_ID"        src="DS_ID"        srctype="var" get="v1"/>
		<component cmptype="ActionVar" name="CONTRACT_ID"  src="CONTRACT_ID"  srctype="var" put="p1" len="20"/>
		<component cmptype="ActionVar" name="CONTR_PAY_ID" src="CONTR_PAY_ID" srctype="var" put="p2" len="30"/>
	</component>
    <component cmptype="Action" name="getAutoAmb">
        <![CDATA[
          begin
              :AMB_DEF:=D_PKG_OPTIONS.GET('RepTAPDefaultFormat',:LPU);
          end;
        ]]>
        <component cmptype="ActionVar" name="LPU"     src="LPU"     srctype="session"/>
        <component cmptype="ActionVar" name="AMB_DEF" src="AMB_DEF" srctype="var" put="v1" len="20"/>
    </component>
	<component cmptype="Script" name="userScript">
        <![CDATA[
        Form.RecordAnotherPatient = function () {
            setVar('ParamAction', 1, 1);
            closeWindow(null, null, {'ParamAction': 1});
        }
        Form.RecordThisPatient = function () {
            setVar('ParamAction', 2, 1);
            closeWindow(null, null, {'ParamAction': 2});
        }
        Form.REGFINISH_onCreate = function () {
            setVar('ParamAction', 1, 1);
            if (empty(getVar('DirectionID'))) {
                setVar('DirectionID', getVar('DirectionID', 1));
            }
            //используется из расписания
            if (empty(getVar('PERSMEDCARD_ID'))) {
                setVar('PERSMEDCARD_ID', getVar('PERSMEDCARD_ID', 1));
            }
            if (empty(getVar('LPU_DS'))) {
                setVar('LPU_DS', getVar('LPU_DS', 1));
            }


        }

        Form.REGFINISH_onShow = function () {
            if ((getVar('printRegistryResult') || getVar('printRegistryResult', 1))
                    && (!empty(getVar('reportRegistryResult')) || !empty(getVar('reportRegistryResult', 1)))) {
                Form.printreportRegistryResult(getVar('reportRegistryResult')||getVar('reportRegistryResult', 1));
            }
        }
        Form.printreportRegistryResult = function(report){
            setVar('REP_ID', getVar('DirectionServiceID') || getVar('DirectionServiceID', 1));
            setVar('DIR_SERVICE', getVar('REP_ID'));
            setVar('REP_DS_ID', getVar('REP_ID'));
            setVar('PATIENT_ID', getVar('PERSMEDCARD_ID') || getVar('PERSMEDCARD_ID', 1));
            setVar('REP_PATIENT_ID', getVar('PATIENT_ID'));
            setVar('DS_ID',getDataSet('DSServices').data[0]['ID']);
            executeAction('getDataForCurrentRoutList', function () {
                setVar('DATE_BEGIN', getVar('ROUT_PRINT_DATE'));
                setVar('DATE_END',   getVar('ROUT_PRINT_DATE'));
                setVar('TIME_BEGIN', getVar('TIME_BEGIN'));
                setVar('TIME_END',   getVar('TIME_END'));
                setVar('THIS_SERV', 1);
                printReportByCode(report);
            });
        }
        Form.PrintContractZakazchik = function (hyperlink) {
            setVar('REP_ID', getControlValue(hyperlink));
            setVar('PATIENT_ID', getVar('PERSMEDCARD_ID'));
            executeAction('GetTrueDSID', function () {
                setVar('DS_ID', getControlValue(hyperlink));
                executeAction('getContract', function () {
                    if (!empty(getVar('REPP_ID'))) setVar('REP_ID', getVar('REPP_ID'));
                    printReportByCode('reception_contract_zakazchik');
                })
            });
        }
        Form.PrintAgreement = function (hyperlink) {
            setVar('REP_ID', getControlValue(hyperlink));
            setVar('DIR_SERVICE', getControlValue(hyperlink));
            printReportByCode('reception_agreement');
        }
        Form.PrintReceptionAgreement = function (hyperlink) {
            setVar('REP_ID', getControlValue(hyperlink));
            printReportByCode('reception_agreement_base');
        }
        Form.PrintReceptionAct = function (hyperlink) {
            setVar('REP_ID', getControlValue(hyperlink));
            printReportByCode('reception_act_base');
        }
        Form.PrintAgreementPersInfo = function (hyperlink) {
            setVar('REP_ID', getControlValue(hyperlink));
            printReportByCode('reception_agreement_personal_info');
        }
        Form.PrintAgreementOper = function (hyperlink) {
            setVar('REP_ID', getControlValue(hyperlink));
            printReportByCode('reception_agreement_oper');
        }
        Form.PrintAgreementAbort = function (hyperlink) {
            setVar('REP_ID', getControlValue(hyperlink));
            printReportByCode('agreement_abort');
        }
        Form.PrintAgreementNark = function (hyperlink) {
            setVar('PATIENT_ID', getVar('PERSMEDCARD_ID'));
            printReportByCode('patient_agreement_narkolog');
        }
        Form.PrintAgreementUZI = function (hyperlink) {
            setVar('PATIENT_ID', getVar('PERSMEDCARD_ID'));
            setVar('DIRSERV_ID', getControlValue(hyperlink));
            printReportByCode('patient_agreement_uzi');
        }
        Form.PrintAgreementZakazchik = function (hyperlink) {
            setVar('REP_ID', getControlValue(hyperlink));
            printReportByCode('reception_agreement_zakazchik');
        }
        Form.PrintListServs = function (hyperlink) {
            setVar('REP_ID', getVar('PERSMEDCARD_ID'));
            setVar('DIRSERV_ID', getControlValue(hyperlink));
            printReportByCode('ListServs');
        }
        Form.PrintTalon = function (hyperlink) {
            setVar('DS_ID', _getControlProperty(hyperlink, 'value'));
            executeAction('getDataForCurrentRoutList', function () {
                setVar('DATE_BEGIN', getVar('ROUT_PRINT_DATE'));
                setVar('DATE_END', getVar('ROUT_PRINT_DATE'));
                setVar('THIS_SERV', 1);
                printReportByCode('RoutList');
            });
        }
        Form.PrintTalon1 = function (hyperlink) {
            setVar('DS_ID', _getControlProperty(hyperlink, 'value'));
            executeAction('getDataForCurrentRoutList', function () {
                setVar('DATE_BEGIN', getVar('ROUT_PRINT_DATE'));
                setVar('DATE_END', getVar('ROUT_PRINT_DATE'));
                setVar('THIS_SERV', 1);
                printReportByCode('RoutList1');
            });
        }
        Form.PrintMassTalon = function (hyperlink) {
            setVar('sysDirectionService', _getControlProperty(hyperlink, 'value'));
            openWindow('Reg/reg_print_talon', true, 500, 180);
        }
        Form.PrintAmbTalon = function (hyperlink) {
            setVar('PatId', getVar('PERSMEDCARD_ID'));
            setVar('AmbId', '');
            printReportByCode('dispensary_report');
        }
        Form.PrintAmbTalonA5 = function (hyperlink) {
            setVar('REP_DS_ID', getControlValue(hyperlink));
            setVar('REP_PATIENT_ID', getVar('PERSMEDCARD_ID'));
            setVar('AmbId', '');
            executeAction('getAutoAmb', function () {
                if (!empty(getVar('AMB_DEF'))) {
                    _rep = 'amb_talon_' + getVar('AMB_DEF');
                    printReportByCode(_rep);
                } else {
                    openWindow('Reports/AmbReps/amb_talon_choose', true);
                }
            });
        }
        Form.PrintReceipt = function (hyperlink) {
            setVar('PATIENT_ID', getVar('PERSMEDCARD_ID'));
            setVar('DS_ID', getControlValue(hyperlink));
            executeAction('getContract', null, null, null, false, 0);
            openWindow('Reports/Reception/receipt_call', true);
        }
        Form.PrintReceiptGroup = function (hyperlink) {
            setVar('PATIENT_ID', getVar('PERSMEDCARD_ID'));
            setVar('DS_ID', getControlValue(hyperlink));
            executeAction('getContract', null, null, null, false, 0);
            openWindow('Reports/Reception/receipt_group_call', true);
        }
        Form.SERV_onRefresh = function (_domObject, args) {
            var len = args[0].length;
            setCaption('INFO', ' на услуг' + ((len == 1) ? 'у' : 'и'));
        }
        Form.DSINFO_onRefresh = function (_domObject, args) {
            if (args[0].length == 0) {
                alert('Данные не найдены. Возможно у Вас нет прав на разделы  "Направления" и "Карта пациента"');
                return;
            }
            setControlCaption(_domObject, 'Записан' + ((args[0][0]['SEX'] == '1') ? '' : 'а'));
            if (empty(getVar('PERSMEDCARD_ID')))
                setVar('PERSMEDCARD_ID', args[0][0]['PATIENT_ID']);
            setVar('AGENT_ID', args[0][0]['AGENT']);
        }
        Form.SERVonFocusContract = function (_domObject) {
            $$(_domObject);
            _setHint(_domObject, 'Печать контракта: ' + getCaption('SERV'));
            _$$();
        }
        Form.SERVonFocusTalon = function (_domObject) {
            $$(_domObject);
            _setHint(_domObject, 'Печать талона: ' + getCaption('SERV'));
            _$$();
            }
            Form.SERVonFocusTalon = function (_domObject) {
            $$(_domObject);
            _setHint(_domObject, 'Печать второго талона: ' + getCaption('SERV'));
            _$$();
            }

        Form.SERVonFocusAmbTalon = function (_domObject) {
            $$(_domObject);
            _setHint(_domObject, 'Печать амбулаторного талона: ' + getCaption('SERV'));
            _$$();
        }
        Form.SERVonFocusAgreement = function (_domObject) {
            $$(_domObject);
            _setHint(_domObject, 'Печать информированного согласия: ' + getCaption('SERV'));
            _$$();
        }
        Form.SERVonFocusAgreementPersInfo = function (_domObject) {
            $$(_domObject);
            _setHint(_domObject, 'Печать информированного согласия на обработку персональных данных');
            _$$();
        }
        Form.SERVonFocusListServs = function (_domObject) {
            $$(_domObject);
            _setHint(_domObject, 'Печать обходного листа: ' + getCaption('SERV'));
            _$$();
        }
        Form.isPaint = true;
        Form.SERVSP_onClone = function (_domObject) {
            if (Form.isPaint) _domObject.style.backgroundColor = '#F0F5F0';
            else                _domObject.style.backgroundColor = '#FFFFFF';
            Form.isPaint = !Form.isPaint;
        }
        Form.PrintDirServ = function (_domObject) {
            setVar('DIRSERV_ID', getControlValue(_domObject));
            Form.PrintVisit(null, getVar('DIRSERV_ID'), 3);
        }
        Form.PrintTalonEQ = function (hyperlink) {
            setVar('REP_ID', getControlValue(hyperlink));
            printReportByCode('RoutListElectronicQueue');
        }
        Form.PrintMassTalonEQ = function (hyperlink) {
            openD3Form('Reg/reg_print_talon_eq', true, {
                width: 500,
                height: 180,
                vars: {
                    DIR_SERV_ID : getControlValue(hyperlink)
                }
            });
        }
        ]]>
    </component>
    <component cmptype="Script" name="SERV_onCloneScript">
        <![CDATA[
            Form.SERV_onClone = function (_domObject, _dataArray) {
                getControlByName('SERVSP_CON').style.display = (_dataArray['CN'] != '0') ? '' : 'none';
                $$(_domObject);
                executeAction('isShowDirServReport', null, null, null, 0, 0);
                if (isExistsControlByName('DirServRep')) {
                    if (getVar('IS_SHOW') == 1)
                        getControlByName('DirServRep').style.display = '';
                    else
                        getControlByName('DirServRep').style.display = 'none';
                }
                _$$();
            }
        ]]>
    </component>
    <component cmptype="Script" name="PrintContract">
        <![CDATA[
            Form.PrintContract = function(hyperlink) {
                setVar('REP_ID', getControlValue(hyperlink));
                setVar('PATIENT_ID', getVar('PERSMEDCARD_ID'));
                executeAction('GetTrueDSID', function() {
                    setVar('DS_ID', getControlValue(hyperlink));
                    executeAction('getContract', function() {
                        if (!empty(getVar('REPP_ID'))) {
                            setVar('REP_ID', getVar('REPP_ID'));
                        }
                        printReportByCode('reception_contract');
                    })
                });
            }
        ]]>
    </component>
    <component cmptype="Script" name="printAnk">
        <![CDATA[
            Form.printAnk = function(hyperlink) {
                setVar('REP_ID', getVar('PERSMEDCARD_ID'));
                setVar('DIRSERV_ID', getControlValue(hyperlink));
                printReportByCode('persm_list');
            }
        ]]>
    </component>
    <component cmptype="Script" name="PrintMedCard">
        <![CDATA[
            Form.PrintMedCard = function(_domObject) {
                if(empty(getVar('PERSMEDCARD_ID'))) {
                    alert('Пациент не выбран!');
                    return;
                }
                setVar('REP_ID', getVar('PERSMEDCARD_ID'));
                setVar('DIRSERV_ID', getControlValue(_domObject));
                printReportByCode('025/y');
            }
        ]]>
    </component>
    <component cmptype="Action" name="getDataForCurrentRoutList">
        <![CDATA[
            declare
                nREG_TYPE number(1);
            begin
                :DayBgnTime := d_pkg_option_specs.get('DayBgnTime', :LPU);
                :DayEndTime := d_pkg_option_specs.get('DayEndTime', :LPU);
                select trunc(ds.REC_DATE),
                       d.PATIENT_ID,
                       ds.REG_TYPE
                 into :PRINT_DATE,
                      :PATIENT_ID,
                      nREG_TYPE
                 from d_v_direction_services ds
                      join d_v_directions d on d.ID = ds.PID
                where ds.ID = :DS_ID;
                if nREG_TYPE = 0 then
                    :DayBgnTime := '00:00';
                    :DayEndTime := '00:00';
                end if;
            end;
        ]]>
        <component cmptype="ActionVar" name="LPU"        src="LPU"             srctype="session"/>
        <component cmptype="ActionVar" name="DayBgnTime" src="TIME_BEGIN"      srctype="var" put="v0" len="10"/>
        <component cmptype="ActionVar" name="DayEndTime" src="TIME_END"        srctype="var" put="v1" len="10"/>
        <component cmptype="ActionVar" name="PRINT_DATE" src="ROUT_PRINT_DATE" srctype="var" put="v2" len="20"/>
        <component cmptype="ActionVar" name="DS_ID"      src="DS_ID"           srctype="var" get="v4"/>
        <component cmptype="ActionVar" name="PATIENT_ID" src="PATIENT_ID"      srctype="var" put="v5" len="17"/>
    </component>
    <component cmptype="Action" name="isShowDirServReport">
	    <![CDATA[
	     begin
	        -- проверка - показывать отчет с типом "Направление" или нет
	        select 1
	          into :IS_SHOW
	          from d_v_vis_template_reports t
	         where t.PID = D_PKG_VISITS.GET_TEMPLATE_INFO(:LPU, :DIR_SERVICE, 'DIRECTION_SERVICES', 0, 1)
	           and t.REP_TYPE = 3
	           and rownum = 1;
	         exception when others then
	            :IS_SHOW := 0;
	     end;
	    ]]>
		<component cmptype="ActionVar" name="LPU"         src="LPU"     srctype="session"/>
	    <component cmptype="ActionVar" name="DIR_SERVICE" src="DirRep"  srctype="ctrl" get="ds"  />
		<component cmptype="ActionVar" name="IS_SHOW"     src="IS_SHOW" srctype="var"  put="is_show" len="1"/>
	</component>
    <div dataset="DSServices" onrefresh="base().SERV_onRefresh(this,args);" name="Services"/>
    <table dataset="DSInfo" cmptype="clone" datafield="SEX" name="SEX" style="width:95%; margin:15px 25px;">
        <tr>
            <td/>
            <td style="padding-bottom:10px;">
                <component cmptype="Label" caption="Запись завершена" style="font-size:20px; font-weight:bold; color:#29518A;"/>
            </td>
            <td/>
        </tr>
        <tr>
            <td style="background-image: url(Forms/Reg/img/dg_left_bg.gif); width: 10px;">
                <img width="10" height="22" alt="" src="Forms/Reg/img/dg_left_bg.gif"/>
            </td>
            <td style="background-color:white;">
                <div style="margin:20px 30px; font-size:14px; color:#969696;">
                    <div style="float:left;">
                        <component cmptype="Label" caption="Пациент" style="font-weight:bold;" hintfield="PATIENT"/>
                        <img src="Forms/Reg/img/person.png"/>
                        <br/>
                        <component cmptype="Label" captionfield="PATIENT" hintfield="PATIENT" style="color:#333333;font-weight:bold;font-Size:12px;"/>
                        <br/>
                        <component cmptype="Label" onrefresh="base().DSINFO_onRefresh(this,args);"/>
                        <component cmptype="Label" name="INFO"/>
                    </div>
                    <div style="clear:both;"/>
                    <div repeate="0" dataset="DSServices" onclone="Form.SERV_onClone(this,_dataArray);" keyfield="ID" >
                        <table style="margin:7px;">
                            <tr cmptype="tmp" name="SERVICE_CON">
                                <td style="padding:2px 2px 2px 2px;">
                                    <component cmptype="Label" caption="Услуга:" hintfield="SERVICE_CODE"/>
                                </td>
                                <td style="padding:2px 2px 2px 2px;">
                                    <component cmptype="Label" captionfield="SERVICE" name="SERV" hintfield="SERVICE_CODE" style="margin-left:10px; color:#333333;"/>
                                </td>
                            </tr>
                            <tbody cmptype="div" name="SERVSP_CON">
                                <tr>
                                    <td style="padding:2px 0px 2px 15px;font-Size:10px;" colspan="2">
                                        <component cmptype="Label" caption="Состав услуги:"/>
                                    </td>
                                </tr>
                                <tr repeate="0" dataset="DSServicesSP" detail="true" parentfield="HID" onclone="base().SERVSP_onClone(this);">
                                    <td style="padding:2px 0px 2px 30px;font-Size:10px" colspan="2">
                                        <component cmptype="Label" captionfield="SERVICE" hintfield="SERVICE_CODE"/>
                                    </td>
                                </tr>
                            </tbody>
                            <tr>
                                <td style="padding:2px 2px 2px 2px;">
                                    <component cmptype="Label" caption="Отделение/Кабинет:"/>
                                </td>
                                <td style="padding:2px 2px 2px 2px;">
                                    <component cmptype="Label" captionfield="DEP_CAB_NAMES" hintfield="DEP_CAB_NAMES" style="margin-left:10px; color:#333333;"/>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding:2px 2px 2px 2px;">
                                    <component cmptype="Label" caption="Врач:" hintfield="EMPLOYER"/>
                                </td>
                                <td style="padding:2px 2px 2px 2px;">
                                    <component cmptype="Label" captionfield="EMPLOYER" hintfield="EMPLOYER" style="margin-left:10px; color:#333333;"/>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding:2px 2px 2px 2px;">
                                    <component cmptype="Label" caption="Дата назначения:"/>
                                </td>
                                <td style="padding:2px 2px 2px 2px;">
                                    <component cmptype="Label" captionfield="TIME_REC_DATE" name="TIME_REC_DATE" hintfield="TIME_REC_DATE" style="margin-left:10px; color:#333333;"/>
                                </td>
                            </tr>
                            <tr cmptype="tmp" name="PrintBlock">
                                <td colspan="2" style="font-size:12px;padding:2px 2px 2px 2px;">
                                    <component cmptype="Label" caption="Печать:" style="margin:0px 10px;"/>
                                    <component cmptype="HyperLink" name="AmbCard" caption="Амбулаторной карты" datafield="ID" title="Печать амбулаторной карты" onclick="base().PrintMedCard(this);"/>
                                    <component cmptype="HyperLink" name="TalonNaPriem1" caption="Талон КТ,МРТ" datafield="ID" title="Талон на  КТ,МРТ" onmouseover="base().SERVonFocusTalon(this);" onclick="base().PrintTalon1(this);"/>
                                    <span cmptype="tmp" name="DirServRep" style="display:none;">
                                        <component cmptype="Label" caption="|" style="margin:0px 10px;"/>
                                        <component cmptype="HyperLink" caption="Направления" name="DirRep" datafield="ID" title="Печать направления" onclick="base().PrintDirServ(this);"/>
                                    </span>
                                    <div cmptype="tmp" name="ContrBlock">
                                        <component cmptype="Label" caption="|" style="margin:0px 10px;"/>
                                        <span cmptype="tmp" name="UserContract">
                                            <component cmptype="HyperLink" caption="Контракта (Пациент)" datafield="ID" title="Печать контракта с Пациентом" onmouseover="base().SERVonFocusContract(this);" onclick="base().PrintContract(this);"/>
                                        </span>
                                        <component cmptype="Label" caption="|" style="margin:0px 10px;"/>
                                        <component cmptype="HyperLink" name="ZakazchickContract" caption="Контракта (Заказчик)" datafield="ID" title="Печать контракта с Заказчиком" onmouseover="base().SERVonFocusContract(this);" onclick="base().PrintContractZakazchik(this);"/>
                                    </div>
                                    <component cmptype="Label" caption="|" style="margin:0px 10px;"/>
                                    <component cmptype="HyperLink" name="TalonNaPriem" caption="Талон на приём" datafield="ID" title="Талон на приём" onmouseover="base().SERVonFocusTalon(this);" onclick="base().PrintTalon(this);"/>
                                    
                                    <component cmptype="Label" caption="|" style="margin:0px 10px;"/>
                                    <component cmptype="HyperLink" name="MassTalonNaPriem" caption="Массовая печать маршрутных талонов" datafield="ID" title="Массовая печать маршрутных талонов" onmouseover="base().SERVonFocusTalon(this);" onclick="base().PrintMassTalon(this);"/>

                                    <div style="display:inline-block;" cmptype="tmp" name="UserLinks">
                                        <component cmptype="Label" caption="|" style="margin:0px 10px;"/>
                                        <component cmptype="HyperLink" name="rep_agreement_link" caption="Информированного согласия" datafield="ID" title="Печать информированного согласия" onmouseover="base().SERVonFocusAgreement(this);" onclick="base().PrintAgreement(this);"/>
                                        <span cmptype="tmp" name="spanICinOperation">
                                            <component cmptype="Label" caption="|" style="margin:0px 10px;"/>
                                            <component cmptype="HyperLink" caption="ИС на операцию" datafield="ID" title="Печать информированного согласия" onmouseover="base().SERVonFocusAgreement(this);" onclick="base().PrintAgreementOper(this);"/>
                                        </span>
                                    </div>
                                    <div style="display:inline-block;" cmptype="tmp" name="UserLinks1">
                                        <div cmptype="tmp" name="print_ReceptionAgreementAndAct">
                                            <component cmptype="Label" caption="|" style="margin:0px 10px;"/>
                                            <component cmptype="HyperLink" name="print_ReceptionAgreement" caption="Инф. согласия на платные услуги" datafield="ID" title="Печать Инф. согласия на платные услуги" onmouseover="base().SERVonFocusAgreement(this);" onclick="base().PrintReceptionAgreement(this);"/>
                                            <component cmptype="Label" caption="|" style="margin:0px 10px;"/>
                                            <component cmptype="HyperLink" name="print_ReceptionAct" caption="Акт оказания платных услуг" datafield="ID" title="Печать Акта оказания платных услуг" onmouseover="base().SERVonFocusAgreement(this);" onclick="base().PrintReceptionAct(this);"/>
                                        </div>
                                        <component cmptype="Label" caption="|" style="margin:0px 10px;"/>
                                        <component cmptype="HyperLink" caption="Амбулаторный талон" name="AmbTalon" datafield="ID" title="Печать Амбулаторного талона" onmouseover="base().SERVonFocusAgreement(this);" onclick="base().PrintAmbTalonA5(this);"/>
                                    </div>
                                </td>
                            </tr>
                        </table>
                        <div style="width:100%;height:2px;background-Color:rgb(238,238,238);"/>
                    </div>
                </div>
                <div style="border-bottom:4px solid #80AFC1;" cmptype="bogus" name="ActionPanel">
                    <div style="margin:20px 30px; font-size:14px; color:#969696;">
                        <b>
                            <component cmptype="HyperLink" name="NewPatlink" caption="Записать нового пациента" title="Записать нового пациента" onclick="base().RecordAnotherPatient();" style="font-size:larger;"/>
                        </b>
                        <component cmptype="Label" caption="или" style="margin:0px 10px; font-size:smaller;"/>
                        <b>
                            <component cmptype="HyperLink" name="ThisPatLink" style="font-size:12px;" caption="Записать этого пациента ещё на один приём" title="Записать этого пациента ещё на один приём" onclick="base().RecordThisPatient();"/>
                        </b>
                    </div>
                </div>
            </td>
            <td style="background-image: url(Forms/Reg/img/dg_right_bg.gif); width: 10px;">
                <img width="10" height="22" alt="" src="Forms/Reg/img/dg_right_bg.gif"/>
            </td>
        </tr>
    </table>
</div>
