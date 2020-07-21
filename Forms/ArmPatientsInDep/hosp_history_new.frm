<div cmptype="form" oncreate="base().OnCreate();" onshow="base().OnShow();" style="width:100%;" window_size="1000x650">
    <title cmptype="title">История болезни</title>
    <component cmptype="SubForm" path="Visit/PrintVisit"/>
    <style>
        span.linklike
        {
            cursor:pointer;
            text-decoration:underline;
        }
        .linklike:hover
        {
            cursor:pointer;
            text-decoration:none;
        }
        div.time_div
        {
            height:100px;
            border-radius: 4px 4px 4px 4px;
                border-top: 1px solid #ffffff;
            box-shadow: 1px 1px 4px 0 #BBBBBB;
            vertical-align:middle;
            white-space: nowrap;
            text-overflow:ellipsis;
            overflow: hidden;
            width: 100%;
        }
        .bckgrnd
        {
            background: -moz-linear-gradient(#FFFFFF, #EDEDED);
            background: -webkit-gradient(linear, left top, left bottom, from(#FFFFFF), to(#EDEDED));
        }
        .bckgrnd:hover
        {
            background: -moz-linear-gradient(#D7E8EF, #B1DEEF);
            background: -webkit-gradient(linear, left top, left bottom, from(#D7E8EF), to(#B1DEEF));
        }
        .bckgrnd_top
        {
            background: -moz-linear-gradient(#D7E8EF, #B1DEEF);
            background: -webkit-gradient(linear, left top, left bottom, from(#C0E0ED), to(#8ED7F2));
        }
        .bckgrnd_top:hover
        {
            background: -moz-linear-gradient(#AADAED, #70CDEF);
            background: -webkit-gradient(linear, left top, left bottom, from(#AADAED), to(#70CDEF));
        }
        .bold {
          font-weight: bold;
        }
    </style>
    <component cmptype="Script">
        <![CDATA[
        Form.OnCreate = function () {
            setVar('ModalResult', 0, 1);
            setVar('HH_ID', getVar('HH_ID', 1));
            setVar('HH_DEP_ID', getVar('HH_DEP_ID',1));
            setVar('HH_VIEW_MODE', getVar('VIEW_MODE', 1)); //VIEW_MODE = 'PREVIEW' скрывает контролы в Form.disableControlsInPreviewMode
        }
        Form.OnShow = function () {
            executeAction("selectAction", base().afterSelect);
        }
        Form.getKSGInformation = function () {
            executeAction('getKSGInformation', function () {
                setControlProperty('DEP_LIST', 'hint', getVar('KSG'));
            });
        }
        Form.openKSGDep = function () {
            if (empty(getValue('DEP_LIST')))
                showAlert('Отделение не выбрано', 'Сообщение системы', 200, 120);
            else {
                setVar('HH_DEP_FOR_ACT', getValue('DEP_LIST'));
                executeAction('getDepInformation', null, null, 0, 0);
                setVar('PATIENT_ID', getVar('PERSMEDCARD'));
                if (getVar('LASTDEP') >= 1) {
                    setVar('windowMode', 'edit');
                    var form = openWindow('ArmPatientsInDep/SubForms/hh_deps_edit', true);
                    form.addListener('onafterclose',
                            function () {
                                if (getVar('ModalResult') == 1)
                                    setVar('ModalResult', '1', 1)
                            }, null, false);
                }
                else {
                    var form = openWindow('ArmPatientsInDep/SubForms/closed_hh_deps_edit', true);
                }
                Form.disableControlsInPreviewMode(form);
            }
        }
        Form.afterSelect = function () {
            executeAction('CheckDepBed');
            setControlProperty('MES', 'hint', getVar('MES_NAME'));
            setControlProperty('MES_LABEL', 'hint', getVar('MES_NAME'));
            setWindowCaption('История болезни № ' + getCaption('HH_PREF_NUMB') + ' - ' + getCaption('PAT_FIO'));
            var windowCaption = ' № ' + getCaption('HH_PREF_NUMB') + ' - ' + getCaption('PAT_FIO');
            switch (getVar('HH_TYPE')) {
                case '1'://история родов
                    setWindowCaption("История родов" + windowCaption);
                    setCaption('TYPE_HISTORY', 'История родов')
                    getControlByName('newborns').style.display = '';
                    break;
                case '2'://карта новорожденного
                    setWindowCaption("История новорожденного" + windowCaption);
                    setCaption('TYPE_HISTORY', 'История новорожденного')
                    break;
                case '4':
                    if(getVar('SPEC_LPU_TYPE') == '1'){
                        getControlByName('psy_first_block').style.display = '';
                        getControlByName('psy_second_block').style.display = '';
                        getControlByName('print_block').setAttribute('colspan', 1);
                    }
                    break;
                default://история болезни
                    setWindowCaption("История болезни" + windowCaption);
                    setCaption('TYPE_HISTORY', 'История болезни')
            }
            if (!empty(getVar('DEADDATA'))) {
                getControlByName('dead_data').style.display = '';

            }
            var pregnancy = getCaption('PREGNANCY');
            if (!empty(pregnancy) && parseToJSFloat(pregnancy) > 0)
                getControlByName('PREGNANCY_DISPLAY').style.display = '';
            if (!empty(getVar('RELATIVE_HH_ID'))) getControlByName('relative_hh_block').style.display = '';
            executeAction('actionCounts');
            setValue('DEP_LIST', getVar('HH_DEP_ID'));
            setVar('HH_DEP_LYING', getVar('HH_DEP_ID'))
            if (empty(getCaption('MES')))setControlProperty('MES_BUTTON', 'enabled', false);
            base().getKSGInformation();
            if (getVar('IS_IN_NOS_RIGISTRS') == 1) {
                getControlByName('TR_NOS_REGISTRS').style.display = '';
            }
        }
        Form.onChangeDepList = function () {
            setVar('HH_DEP_ID', getValue('DEP_LIST'));
            startActionsGroup();
            executeAction('actionCounts');
            executeAction('resetDiagnoses');
            executeAction('CheckDepBed');
            endActionsGroup();
            base().getKSGInformation();
        }
        Form.onButtonFacialAcc = function () {

            setVar('PERSMEDCARD', getVar('PERSMEDCARD', 1));  /* на форму ИБдля вызова ЛС*/
                setVar('AGENT', getVar('AGENT', 1));

            openWindow('PersonalAccount/patient_contracts', true, 1222, 684);
        }
        //по ссылкам
        Form.showPatientPregnancy = function () {
            openWindow({
                name: 'ArmPatientsInDep/patient_pregnancy',
                vars: {PERSMEDCARD: getVar('PERSMEDCARD'), FIO: getCaption('PAT_FIO')}
            }, true)
                    .addListener('onafterclose', function () {
                        var preg = getVar('patient_pregnancy_activ');
                        if (!empty(preg)) setCaption('PREGNANCY', preg);
                    });
        }
        Form.showPatientWarnings = function () {
            var form = openWindow('ArmPatientsInDep/patients_warnings', true)
            form.addListener('onafterclose', function () {
                executeAction('getSignalInfo');
            });

            Form.disableControlsInPreviewMode(form);
        }
        Form.showDiseaseCasesList = function () {
            setVar('PatientID', getVar('PERSMEDCARD'));
            setVar('PatientFIO', getCaption('PAT_FIO'));
            openWindow('DiseaseCase/diseasecase', true, 1000, 700);
        }
        Form.showPatientsInfo = function () {
            var form = openWindow('ArmPatientsInDep/patients_information', true);

            Form.disableControlsInPreviewMode(form);
        }
        Form.openOnLinkWindow = function (_wrapper)//
        {
            setVar('HH_CHANGE', 0);//Проверка изменения основных данных ИБ(отделений, диагнозов) требующих полного обновления данных

            var form = openWindow({
                    name: 'ArmPatientsInDep/Wrappers/' + _wrapper,
                    vars: {
                        DISEASE_HISTORY_PK_ID: getVar('PAYMENT_KIND_ID'),
						HH_TYPE: getVar('HH_TYPE'),
                        FROM_HH: 1
                    }
                },
                true
            );

            form.addListener('onafterclose', function () {
                if (getVar('HH_CHANGE') == 1) {
                    refreshDataSet('DS_DEP_LIST');
                } else {
                    executeAction('actionCounts');
                }
                if (getVar('ModalResult') == 1) {
                    setVar('ModalResult', 1, 1)
                }

                if(_wrapper == 'direction_observations') {
                    executeAction('resetDiagnoses');
                }
            });

            Form.disableControlsInPreviewMode(form);
        }
        /*Заменять вызовы окон со старого способа на новый*/
        Form.openForm = function (_wrapper) {
            setVar('HH_CHANGE', 0);//Проверка изменения основных данных ИБ(отделений, диагнозов) требующих полного обновления данных
            openWindow({
                name: 'ArmPatientsInDep/Wrappers/' + _wrapper,
                vars: {
                    PARENT_ID: getVar('HH_ID'),
                    RELATIVE_HH_ID: getVar('RELATIVE_HH_ID')
                }
            }, true)
                    .addListener('onafterclose', function () {
                        if (getVar('HH_CHANGE') == 1) {
                            refreshDataSet('DS_DEP_LIST');
                        } else {
                            executeAction('actionCounts');
                        }
                        if (getVar('ModalResult') == 1)
                            setVar('ModalResult', '1', 1)
                    });
        }
        Form.refreshDEP_LIST = function () {
            if (getVar('HH_CHANGE') == 1)
                Form.OnShow();
        }
        Form.showHospHistDiagnoses = function () {
            /*openWindow('ArmPatientsInDep/patient_diagnoses',true)
             .addListener('onafterclose', function()
             {
             if(getVar('ModalResult') == 1){
             setVar('ModalResult', 1, 1);
             executeAction('resetDiagnoses', function() {
             if(empty(getCaption('MES'))) {
             setControlProperty('MES_BUTTON', 'enabled', false);
             } else {
             setControlProperty('MES_BUTTON', 'enabled', true);
             }
             });
             }
             });*/
            var form = openWindow({
                name: 'ArmPatientsInDep/hosp_diagnosis/hh_diagnosis',
                vars: {HH_ID: getVar('HH_ID'), HH_DEP_ID: getValue('DEP_LIST'), HH_TYPE: getVar('HH_TYPE')}
            }, true)
            form.addListener('onafterclose', function () {
                if (getVar('ModalResult') == 1) {
                    setVar('ModalResult', 1, 1);
                    executeAction('resetDiagnoses', function () {
                        if (empty(getCaption('MES'))) {
                            setControlProperty('MES_BUTTON', 'enabled', false);
                        } else {
                            setControlProperty('MES_BUTTON', 'enabled', true);
                        }
                    });
                }
            });

            Form.disableControlsInPreviewMode(form);
        }
        Form.showDopParams = function () {
            var form = openWindow('ArmPatientsInDep/hosp_history_dop_params', true)
            form.addListener('onafterclose', function () {
                if (getVar('ModalResult') == 1)
                    setVar('ModalResult', '1', 1);
            });

            Form.disableControlsInPreviewMode(form);
        }
        Form.selectMes = function () {
            if (!empty(getVar('MKB_FINAL_ID')))
                setVar('MES_MKB_ID', getVar('MKB_FINAL_ID'));
            else if (!empty(getVar('MKB_CLINIC_ID')))
                setVar('MES_MKB_ID', getVar('MKB_CLINIC_ID'));
            else if (!empty(getVar('MKB_RECEIVE_ID')))
                setVar('MES_MKB_ID', getVar('MKB_RECEIVE_ID'));
            else if (!empty(getVar('MKB_SEND_ID')))
                setVar('MES_MKB_ID', getVar('MKB_SEND_ID'));

            if (empty(getVar('MES_MKB_ID'))) {
                alert('Не указан диагноз!');
                return;
            }
            setVar('HH_DATE_IN', getCaption('HH_DATE_IN'));
            setVar('PATIENT_ID', getVar('PERSMEDCARD'));
            //openWindow('MES/meses_for_diseasecase', true)
            var form = openWindow('MES/mes_standard', true)
            form.addListener('onafterclose', function () {
                if (getVar('ModalResult') == 1)
                    executeAction('getOnlyMesInformation', function () {
                        setControlProperty('MES', 'hint', getVar('MES_NAME'));
                        setControlProperty('MES_LABEL', 'hint', getVar('MES_NAME'));
                        if (empty(getCaption('MES'))) {
                            setControlProperty('MES_BUTTON', 'enabled', false);
                        } else {
                            setControlProperty('MES_BUTTON', 'enabled', true);
                        }
                        executeAction('actionCounts');
                    });
            });
            Form.disableControlsInPreviewMode(form);
        }
        //отчеты
        Form.printHospHistory = function () {
            setVar('DIS_ID', getVar('DISEASECASE'));
            openWindow({
                name: 'ArmPatientsInDep/hosp_history_rep_services',
                vars: {
                    'TYPE_HISTORY': getCaption('TYPE_HISTORY'),
                    LOAD_DEATH: getVar('DEADDATA'),
                    HH_ID: getVar('HH_ID')
                }
            }, true);
        }
        Form.printHospSpr = function () {
            printReportByCode('spravka_hospital');
        }
        Form.selectNewPlanDateOut = function () {
            setVar('return_din', null);
            setVar('return_value', null);
            var form = openWindow({
                name: 'UniversalForms/date_edit',
                vars: {window_caption: 'Планируемая дата', in_value: getCaption('PLAN_DATE_OUT')}
            }, true)
            form.addListener('onafterclose', function () {
                if (getVar('ModalResult') == 1) {
                    executeAction('setNewPlanDate', function () {
                        setCaption('PLAN_DATE_OUT', getVar('return_value'));
                    })
                }
            });
            Form.disableControlsInPreviewMode(form);
        };
        Form.selectNewPlanDateIn = function () {
            setVar('return_din', null);
            setVar('return_tin', null);
            setVar('return_value', null);
            var form = openWindow({
                name: 'ArmPatientsInDep/hosp_history_date_in_edit',
                vars: {HH_ID: getVar('HH_ID')}
            }, true)
            form.addListener('onafterclose', function () {
                if (getVar('ModalResult') == 1) {
                    executeAction('setNewPlanDate', function () {
                        setCaption('HH_DATE_IN', getVar('return_din'));
                        setCaption('HH_TIME_IN', getVar('return_tin'));
                    })
                }
            });
            Form.disableControlsInPreviewMode(form);
        }
        Form.showMes = function () {
            openWindow('MES/meses_control', 1, 1000, 600);
        }
        Form.printDeath = function (_dom) {
            if (!empty(getControlValue(_dom)))
                Form.PrintVisit(getControlValue(_dom), null, 0);
        }
        Form.openNosRegistrs = function () {
            var form = openWindow({
                name: 'NosRegistrs/nos_registrs_favor',
                vars: {
                    AGENT: getVar('AGENT'),
                    AGN_NAME: getCaption('PAT_FIO'),
                    DIAGNOZ: getVar("MKB_FINAL_ID"),
                    VISIT: getVar("VISIT"),
                    SEX: getVar('NSEX')
                }
            }, true, 700, 300);

            Form.disableControlsInPreviewMode(form);
        };
        Form.disableControlsInPreviewMode = function (form) {
            if (getVar('HH_VIEW_MODE') == 'PREVIEW') {
                form.addListener('onshow', function () {
                    var buttons = getPage(0).form.containerForm.querySelectorAll('[cmptype="Button"], img');

                    Array.prototype.forEach.call(buttons, function (btn) {
                        if (btn.getAttribute('name') != 'closeButton') {
                            btn.onclick = null;
                            if (btn.tagName != 'IMG') btn.className = "btn-disable"
                        }
                    });

                    var popups = getPage(0).form.containerForm.querySelectorAll('[cmptype="Popup"]');

                    Array.prototype.forEach.call(popups, function (p) {
                        destructPopUpMenu(p);
                    });
                });
            }
        }

        Form.openPsyAnam = function() {
            openD3Form('MentalHistory/subforms_view/psy_anamn_ft', true, {
                width: 970,
                height: 600,
                vars: {
                    AGENT: getVar('AGENT_ID'),
                    PSY_ANAMNESIS: getVar("PSY_ANAMNESIS"),
                    SELF: 1,
                    UNIT: 'HH'
                },
                onclose: function(mod) {
                    executeAction('actionCounts');
                }
            });
        }

        Form.openTHolidays = function() {
            openD3Form('MentalHistory/subforms_view/t_holidays', true, {
                width: 1200,
                height: 600,
                vars: {
                    AGENT: getVar('AGENT'),
                    HH_ID: getVar('HH_ID'),
                    HH_DEP_ID: getVar('HH_DEP_ID'),
                    SELF: 1,
                    UNIT: 'HH'
                },
                onclose: function(mod) {
                    executeAction('actionCounts');
                }
            });
        }

        Form.openTWorkshop = function() {
            openD3Form('MentalHistory/subforms_view/ther_workshop', true, {
                width: 800,
                height: 600,
                vars: {
                        AGENT: getVar('AGENT'),
                        HH_ID: getVar('HH_ID'),
                        SELF: 1,
                        UNIT: 'HH'
                },
                onclose: function(mod) {
                    executeAction('actionCounts');
                }
            });
        }

        Form.openPsyBFeatures = function() {
            openD3Form('MentalHistory/psy_bfeatures/psy_bfeatures', true, {
                width: 800,
                height: 600,
                vars: {
                    AGENT: getVar('AGENT_ID'),
                    UNIT: 'HH'
                }
            });
        };
        ]]>
    </component>

    <component cmptype="Action" name="CheckDepBed">
        <![CDATA[
            begin
                select coalesce(max(case when hhd.IS_LAST = 1 and hdb.DATE_OUT <= trunc(sysdate) then 0 else 1 end) keep(dense_rank first order by hdb.DATE_OUT desc nulls first),0)
                  into :DEP_BED
                  from D_V_HOSP_HISTORY_DEPS_BASE hhd
                       join D_V_HH_DEP_BEDS hdb on hdb.PID = hhd.ID
                 where hhd.ID = :HH_DEP_ID;
            end;
        ]]>
        <component cmptype="ActionVar" name="HH_DEP_ID" src="HH_DEP_ID" srctype="var" get="g0"/>
        <component cmptype="ActionVar" name="DEP_BED"   src="DEP_BED"   srctype="var" put="p0" len="1"/>
    </component>
    <component cmptype="Action" name="setNewPlanDate" compile="true">
        begin
            for x in (select t.*
                        from D_V_HOSP_HISTORIES t
                       where t.ID = :HH_ID ) loop
                d_pkg_hosp_histories.upd(pnid => :HH_ID,
                                        pnlpu => :LPU,
                           pnhpk_plan_journal => x.HPK_PLAN_JOURNAL,
                                    pnpatient => x.PATIENT_ID,
                                    pshh_pref => x.HH_PREF,
                                    pshh_numb => x.HH_NUMB,
                             pshh_numb_altern => x.HH_NUMB_ALTERN,
                                pnhosp_reason => x.HOSP_REASON_ID,
                              pnreception_emp => x.RECEPTION_EMP,
            @if(:NEW_DATE_IN){
                                    pddate_in => to_date(:NEW_DATE_IN || ' ' || :NEW_TIME_IN, 'dd.mm.yyyy hh24:mi'),
            @}else{
                                    pddate_in => x.DATE_IN,
            @}
            @if(:PLAN_DATE_OUT){
                              pdplan_date_out => to_date(:PLAN_DATE_OUT, 'dd.mm.yyyy'),
            @}else{
                              pdplan_date_out => null,
            @}
                                   pddate_out => x.DATE_OUT,
                       pnhospitalization_type => x.HOSPITALIZATION_TYPE_ID,
                        pntransportation_kind => x.TRANSPORTATION_KIND_ID,
                                   pnlpu_from => x.LPU_FROM_ID,
                                   pnmkb_send => x.MKB_SEND_ID,
                             psmkb_send_exact => x.MKB_SEND_EXACT,
                                 pnmkb_clinic => x.MKB_CLINIC_ID,
                           psmkb_clinic_exact => x.MKB_CLINIC_EXACT,
                            pdmkb_clinic_date => x.MKB_CLINIC_DATE,
                                  pnmkb_final => x.MKB_FINAL_ID,
                            psmkb_final_exact => x.MKB_FINAL_EXACT,
                               pnmkb_fin_comp => x.MKB_FIN_COMP_ID,
                         psmkb_fin_comp_exact => x.MKB_FIN_COMP_EXACT,
                                pnmkb_fin_add => x.MKB_FIN_ADD_ID,
                          psmkb_fin_add_exact => x.MKB_FIN_ADD_EXACT,
                                 pnhosp_times => x.HOSP_TIMES,
                                pnhosp_result => x.HOSP_RESULT_ID,
                                pnmkb_receive => x.MKB_RECEIVE_ID,
                          psmkb_receive_exact => x.MKB_RECEIVE_EXACT,
                                   pnrelative => x.RELATIVE_ID,
                             pndiscard_status => x.DISCARD_STATUS,
                         pnis_well_timed_hosp => x.IS_WELL_TIMED_HOSP,
                           pnis_enough_volume => x.IS_ENOUGH_VOLUME,
                         pnis_correct_healing => x.IS_CORRECT_HEALING,
                              pnis_same_diagn => x.IS_SAME_DIAGN,
                                  pnhosp_hour => x.HOSP_HOUR_ID,
                               pnhosp_outcome => x.HOSP_OUTCOME_ID,
                              psOTHER_THERAPY => x.OTHER_THERAPY,
                             pnABILITY_STATUS => x.ABILITY_STATUS_ID,
                                   psFEATURES => x.FEATURES,
                             pdDATE_DEPARTURE => x.DATE_DEPARTURE,
                                pnRELATIVE_HH => x.RELATIVE_HH,
                                pnABANDONMENT => x.ABANDONMENT,
                                 pnDEATH_CAME => x.DEATH_CAME_ID,
								  pnNOVOR_NUM => x.NOVOR_NUM);
            end loop;
        end;
        <component cmptype="ActionVar" name="LPU"           src="LPU"          srctype="session"/>
        <component cmptype="ActionVar" name="PLAN_DATE_OUT" src="return_value" srctype="var" get="v1"/>
        <component cmptype="ActionVar" name="NEW_DATE_IN"   src="return_din"   srctype="var" get="din"/>
        <component cmptype="ActionVar" name="NEW_TIME_IN"   src="return_tin"   srctype="var" get="tin"/>
        <component cmptype="ActionVar" name="HH_ID"         src="HH_ID"        srctype="var" get="v2"/>
    </component>
    <component cmptype="Action" name="getKSGInformation">
        begin
            select case when t.ksg is not null
                          then '' || t.ksg || ' - ' || t2.ksg_name
                        else 'Укажите код КСГ'
                   end
             into :KSG
             from d_v_hosp_history_deps t
                  left join d_v_ksgcodes t2 on t2.ID = t.KSG_ID
            where t.ID = :HH_DEP_ID;
            exception when NO_DATA_FOUND then
                :KSG := 'Укажите код КСГ';
        end;
        <component cmptype="ActionVar" name="HH_DEP_ID" src="DEP_LIST" srctype="ctrl" get="g0"/>
        <component cmptype="ActionVar" name="KSG"       src="KSG"      srctype="var"  put="p0" len="500"/>
    </component>
    <component cmptype="Action" name="getDepInformation">
          begin
                select (
                        select count(1)
                          from d_v_hosp_history_deps hhd1
                         where hhd1.ID = t.ID
                           and hhd1.DATE_IN in (select max(hhd2.DATE_IN)
                                                  from d_v_hosp_history_deps hhd2
                                                 where hhd2.pid = t.PID)
                       ) LASTDEP
                  into :LASTDEP
                  from d_v_hosp_history_deps t
                 where t.ID = :HH_DEP_ID;
                exception when NO_DATA_FOUND then
                    :LASTDEP := null;
          end;
        <component cmptype="ActionVar" name="HH_DEP_ID" src="DEP_LIST" srctype="ctrl" get="g0"/>
        <component cmptype="ActionVar" name="LASTDEP"   src="LASTDEP"  srctype="var"  put="p0" len="10"/>
    </component>
    <component cmptype="Action" name="getOnlyMesInformation">
        begin
            select t.MES,
                   t.MES_NAME
              into :MES,
                   :MES_NAME
              from D_V_DISEASECASES t
             where t.ID = :DISEASECASE;
             exception when NO_DATA_FOUND then
                    :MES := null;
                    :MES_NAME := 'Выберите стандарт лечения';
        end;
        <component cmptype="ActionVar" name="DISEASECASE" src="DISEASECASE" srctype="var"         get="v1"/>
        <component cmptype="ActionVar" name="MES"         src="MES"         srctype="ctrlcaption" put="v2" len="400"/>
        <component cmptype="ActionVar" name="MES_NAME"    src="MES_NAME"    srctype="var"         put="v3" len="500"/>
    </component>
    <component cmptype="Action" name="resetDiagnoses">
    declare nHH_DEP NUMBER(17);
    begin
        if :HH_DEP_ID is null then
          select ID
            into nHH_DEP
            from D_V_HOSP_HISTORY_DEPS t
           where t.pid=:HH_ID
            and t.IS_LAST=1;
            else nHH_DEP:=:HH_DEP_ID;
         end if;

         begin
            select t.MKB_ID, t.MKB||' - '||t.MKB_NAME, t.MKB_EXACT
              into :MKB_DEP_ID,:MKB_DEP,:MKB_DEP_EXACT
           from D_V_HOSP_HISTORY_DIAGNS t
           where t.pid=:HH_ID
            and t.HH_DEP=nHH_DEP
            and t.HOSP_DIAGN_TYPE_ID=0;
         exception when no_data_found then
          :MKB_DEP_ID := null;
          :MKB_DEP := null;
          :MKB_DEP_EXACT := null;
        end;
         begin
            select t.MKB_ID, t.MKB||' - '||t.MKB_NAME, t.MKB_EXACT
              into :MKB_CLINIC_ID,:MKB_CLINIC,:MKB_CLINIC_EXACT
           from D_V_HOSP_HISTORY_DIAGNS t
           where t.pid=:HH_ID
            and t.HOSP_DIAGN_TYPE_ID=0
            and t.IS_MAIN=1;
         exception when no_data_found then
          :MKB_CLINIC_ID := null;
          :MKB_CLINIC := null;
          :MKB_CLINIC_EXACT := null;
        end;

            select hh.MKB_FINAL_ID,
                   hh.MKB_RECEIVE_ID,
                   hh.MKB_SEND_ID
              into :MKB_FINAL_ID,
                   :MKB_RECEIVE_ID,
                   :MKB_SEND_ID
              from d_v_hosp_histories hh
             where hh.ID = :HH_ID;

            select t.MES
              into :MES
              from D_V_DISEASECASES t
             where t.ID = :DISEASECASE;
    end;
        <component cmptype="ActionVar" name="HH_ID"             src="HH_ID"            srctype="var"         get="v1"/>
        <component cmptype="ActionVar" name="HH_DEP_ID"         src="DEP_LIST"         srctype="ctrl"        get="g0"/>
        <component cmptype="ActionVar" name="MKB_DEP"           src="MKB_DEP"          srctype="ctrlcaption" put="v2d" len="550"/>
        <component cmptype="ActionVar" name="MKB_CLINIC"        src="MKB_CLINIC"       srctype="ctrlcaption" put="v2"  len="550"/>
        <component cmptype="ActionVar" name="MKB_DEP_EXACT"     src="MKB_DEP_EXACT"    srctype="ctrlcaption" put="v3d" len="4000"/>
        <component cmptype="ActionVar" name="MKB_CLINIC_EXACT"  src="MKB_CLINIC_EXACT" srctype="ctrlcaption" put="v3"  len="4000"/>
        <component cmptype="ActionVar" name="MKB_FINAL_ID"      src="MKB_FINAL_ID"     srctype="var"         put="v4"  len="17"/>
        <component cmptype="ActionVar" name="MKB_DEP_ID"        src="MKB_DEP_ID"       srctype="var"         put="v5d" len="17"/>
        <component cmptype="ActionVar" name="MKB_CLINIC_ID"     src="MKB_CLINICP_ID"   srctype="var"         put="v5"  len="17"/>
        <component cmptype="ActionVar" name="MKB_RECEIVE_ID"    src="MKB_RECEIVE_ID"   srctype="var"         put="v6"  len="17"/>
        <component cmptype="ActionVar" name="MKB_SEND_ID"       src="MKB_SEND_ID"      srctype="var"         put="v7"  len="17"/>
        <component cmptype="ActionVar" name="DISEASECASE"       src="DISEASECASE"      srctype="var"         get="v8"/>
        <component cmptype="ActionVar" name="MES"               src="MES"              srctype="ctrlcaption" put="v9"  len="400"/>
    </component>
    <component cmptype="Action" name="getSignalInfo">
        <![CDATA[
        declare nAA  VARCHAR2(1500);
                nCC  VARCHAR2(1500);
                nPA  VARCHAR2(1500);
                sFEATURES VARCHAR(2000);
        begin
            begin
                select hh.FEATURES
                  into sFEATURES
                  from D_V_HOSP_HISTORIES hh
                 where hh.ID = :HH_ID;
             exception when NO_DATA_FOUND then sFEATURES := null;
             end;
            nAA :=D_pkg_AGENT_ALLERG_ANAMNESIS.GET_BY_STRING(:AGENT, sysdate) ;
            nCC := null;
                        if :HH_TYPE != 4 or :HH_TYPE is null then /*для психов соп. заболевания не показываем*/
                            for cur in
                                    (select t.*
                               from d_v_agent_comp_diseases  t
                              where t.PID = :AGENT
                                and (t.DATE_END >= trunc(sysdate) or t.DATE_END is null)) loop
                                            nCC := nCC||', '||cur.COMP_DISEASE;
                            end loop;
                            nCC := substr(nCC,3);
                        end if;
            if :HH_TYPE = 4 and D_PKG_OPTIONS.GET('SpecLpuType', :LPU) = 1 then /*для психов соп. заболевания не показываем*/
                begin
                    select ID
                      into nPA
                      from D_V_AGENT_PSY_ANAMNESIS
                     where PID = :AGENT;
                 exception when NO_DATA_FOUND then nPA := null;
                end;
            end if;

            select decode(nCC,null,null,' Соп. забол.: '||nCC||'. ')||decode(nAA,null,null,'Аллерг. анамнез: '||nAA||'. ')||decode(sFEATURES, null, null, 'Особые отметки: '||sFEATURES)
              into :SIGNAL_INFO
              from dual;
            if :SIGNAL_INFO is not null then
                :SIGNAL_INFO := substr(:SIGNAL_INFO, 1, 100)||'...';
                :SIGNAL_INFO_LINK := 'Подробнее';
            else
                :SIGNAL_INFO_LINK := 'Добавить';
            end if;
        end;
        ]]>
        <component cmptype="ActionVar" name="LPU"               src="LPU"              srctype="session" />
        <component cmptype="ActionVar" name="HH_ID"             src="HH_ID"            srctype="var"          get="HH_ID"/>
        <component cmptype="ActionVar" name="AGENT"             src="AGENT"            srctype="var"          get="v1"/>
        <component cmptype="ActionVar" name="SIGNAL_INFO"       src="SIGNAL_INFO"      srctype="ctrlcaption"  put="v2" len="4000"/>
        <component cmptype="ActionVar" name="SIGNAL_INFO_LINK"  src="SIGNAL_INFO_LINK" srctype="ctrlcaption"  put="v3" len="50"/>
        <component cmptype="ActionVar" name="HH_TYPE"           src="HH_TYPE"          srctype="var"          get="gHH_TYPE"/>
    </component>
    <component cmptype="Action" name="selectAction" mode="Post">
        <![CDATA[
        declare nAA VARCHAR2(1500);
                nCC VARCHAR2(1500);
                nPA VARCHAR2(1500);
                pregnancy float;
                dHH_DATE_OUT    DATE;
				sFEATURES VARCHAR(2000);
        begin
            begin
              :SPEC_LPU_TYPE := D_PKG_OPTIONS.GET(psSO_CODE => 'SpecLpuType', pnLPU => :LPU);
              exception when others then :SPEC_LPU_TYPE := null;
            end;
            select hh.PATIENT_FIO,
                   pmc.SEX,
                   pmc.nSEX,
                   pmc.BIRTHDATE,
                   d_pkg_dat_tools.full_years(sysdate,pmc.BIRTHDATE),
                   hh.HH_NUMB_FULL,
                   trunc(hh.DATE_IN),
                   to_char(hh.DATE_IN, 'hh24:mi') TIME_IN,
                   trunc(hh.DATE_OUT),
                   trunc(hh.PLAN_DATE_OUT),
                   D_PKG_HOSP_HISTORIES.GET_FACT_DAYS(hh.ID,hh.LPU) ||' дней',
                   hh.DISEASECASE,
                   hh.MKB_FINAL_ID,
                   hh.MKB_RECEIVE_ID,
                   hh.MKB_SEND_ID,
                   hh.PATIENT_ID,
                   hh.PATIENT_AGENT,
                   hh.HH_TYPE,
                   hh.DATE_OUT,
				   hh.FEATURES,
				   pa.id
              into :PAT_FIO,
                   :SEX,
                   :NSEX,
                   :BIRTHDATE,
                   :PAT_YEARS,
                   :HH_PREF_NUMB,
                   :DATE_IN,
                   :TIME_IN,
                   :DATE_OUT,
                   :PLAN_DATE_OUT,
                   :HOSP_DAYS,
                   :DISEASECASE,
                   :MKB_FINAL_ID,
                   :MKB_RECEIVE_ID,
                   :MKB_SEND_ID,
                   :PERSMEDCARD,
                   :AGENT_ID,
                   :HH_TYPE,
                   dHH_DATE_OUT,
				   sFEATURES,
				   :PSY_ANAMNESIS
              from D_V_HOSP_HISTORIES hh
                   join D_V_PERSMEDCARD_FIO pmc on pmc.ID = hh.PATIENT_ID
                   left join d_v_agent_psy_anamnesis pa ON pa.pid = pmc.AGENT
             where hh.ID = :HH_ID;
            begin
                  select h.ID
                    into :RELATIVE_HH_ID
                    from D_V_HOSP_HISTORIES_RELATIVE h
                   where h.RELATIVE_HH=:HH_ID
                     and (h.DATE_OUT is null or h.DATE_OUT=dHH_DATE_OUT);
                   exception when NO_DATA_FOUND then :RELATIVE_HH_ID:=null;
            end;
            --болк HH_DEP
            begin
                if(:NSEX = 0) then
                    pregnancy := d_pkg_agent_pregnancy.GET_TERM(:LPU, :AGENT_ID, sysdate);
                    if pregnancy > 0 and pregnancy < 43 then
                        :PREGNANCY := pregnancy;
                    end if;
                end if;
            end;
            begin
                select nvl(to_char(b5.DATE_OUT,'dd.mm.yyyy hh24:mi'), :DATE_OUT),
                       t.FIO,
                       t.PAYMENT_KIND_NAME,
                       t.PAYMENT_KIND_ID,
                       t.ID,
                       t.MKB_ID, t.MKB||' - '||t.MKB_NAME, t.MKB_EXACT
                  into :DATE_OUT,
                       :HEALING_EMPLOYER,
                       :PAYMENT_KIND,
                       :PAYMENT_KIND_ID,
                       :HH_DEP_ID,
                       :MKB_DEP_ID,:MKB_DEP,:MKB_DEP_EXACT
                  from d_v_hosp_history_deps t
                       join D_V_HOSP_HISTORIES_BASE b5 on b5.ID = t.PID
                 where t.DATE_IN in (select max(t1.DATE_IN)
                                       from d_v_hosp_history_deps t1
                                      where t1.PID=:HH_ID)
                   and t.PID = :HH_ID;
         exception when NO_DATA_FOUND then
                        :DATE_IN := null;
                        :DATE_OUT := null;
                   when TOO_MANY_ROWS then
                        D_P_EXC('Ошибка с историей болезни! Одинаковые даты поступления.');
            end;
            begin
                select t.MKB_ID,
                       t.MKB||' - '||t.MKB_NAME,
                       t.MKB_EXACT
                  into :MKB_CLINIC_ID,
                       :MKB_CLINIC,
                       :MKB_CLINIC_EXACT
                  from D_V_HOSP_HISTORY_DIAGNS t
                 where t.pid=:HH_ID
                   and t.HOSP_DIAGN_TYPE_ID=0
                   and t.IS_MAIN=1;
        exception when no_data_found then
                :MKB_CLINIC_ID := null;
                :MKB_CLINIC := null;
                :MKB_CLINIC_EXACT := null;
            end;
            :DATE_OUT := nvl (:DATE_OUT, 'не выписан');

            select t.MES,
                   t.MES_NAME
              into :MES,
                   :MES_NAME
              from D_V_DISEASECASES t
             where t.ID = :DISEASECASE;

            if :MES_NAME is null then
                :MES_NAME := 'Выберите стандарт лечения';
            end if;

			--сигнальная инфо
			nAA :=D_pkg_AGENT_ALLERG_ANAMNESIS.GET_BY_STRING(:AGENT_ID, sysdate) ;
			nCC := null;
			if :HH_TYPE != 4 or :HH_TYPE is null then /*для психов соп. заболевания не показываем*/
				for cur in
					(select t.*
					   from d_v_agent_comp_diseases  t
					  where t.PID = :AGENT_ID
						and (t.DATE_END >= trunc(sysdate) or t.DATE_END is null)) loop
					nCC := nCC||', '||cur.COMP_DISEASE;
				end loop;
				nCC := substr(nCC,3);
			end if;

            if :HH_TYPE = 4 and :SPEC_LPU_TYPE is null then
                begin
                    select t.ID
                      into nPA
                      from D_V_AGENT_PSY_ANAMNESIS t
                     where t.PID = :AGENT_ID;
                 exception when NO_DATA_FOUND then nPA := null;
                end;
            end if;

			select decode(nCC,null,null,' Соп. забол.: '||nCC||'. ')||decode(nAA,null,null,'Аллерг. анамнез: '||nAA||'. ')||decode(sFEATURES, null, null, 'Особые отметки: '||sFEATURES)
			  into :SIGNAL_INFO
			  from dual;
			if :SIGNAL_INFO is not null then
				:SIGNAL_INFO := substr(:SIGNAL_INFO, 1, 100)||'...';
				:SIGNAL_INFO_LINK := 'Подробнее';
			else
				:SIGNAL_INFO_LINK := 'Добавить';
			end if;
			select t.LPUDICT_ID
			  into :LPUDICT_ID
			  from D_V_LPU t
			 where t.ID = :LPU;
		 	begin
				select ab.DEATHDATE
				  into :DEADDATA
				  from D_V_AGENTS_BASE ab
				  where ab.id=:AGENT_ID;
		 exception when NO_DATA_FOUND then
				:DEADDATA:=null;
			end;
		 	if :DEADDATA is null then
				begin
					select drj.ID
					  into :DEADDATA
					  from D_V_DEAD_REG_ISSUE_JOUR drj
					 where drj.HOSP_HISTORY_ID=:HH_ID;
			exception when NO_DATA_FOUND then
					:DEADDATA:=null;
				 end;
		 	end if;
			-- Проверка есть ли пациент в ноз.регистрах
			select count(1)
			  into :IS_IN_NOS_RIGISTRS
			  from D_V_NR_PATIENTS t
			 where t.AGENT_ID = :AGENT_ID
			   and rownum = 1;

			:OPER_ANEST_CODE := D_PKG_OPTION_SPECS.GET('OperAnestServiceCode', :LPU);
        	:SYS_OPT_DEP_BED := D_PKG_OPTIONS.GET('CheckDepBed_HospHistory', :LPU);
		end;
		]]>
		<component cmptype="ActionVar" name="LPU"                src="LPU"                  srctype="session"/>
		<component cmptype="ActionVar" name="HH_ID"              src="HH_ID"                srctype="var"           get="v1"/>
		<!-- put section -->
		<component cmptype="ActionVar" name="PAT_FIO"            src="PAT_FIO"              srctype="ctrlcaption"   put="v2"   len="200"/>
		<component cmptype="ActionVar" name="SEX"                src="PAT_SEX"              srctype="ctrlcaption"   put="v3"   len="20"/>
		<component cmptype="ActionVar" name="NSEX"               src="NSEX"                 srctype="var"           put="v3_1" len="1"/>
		<component cmptype="ActionVar" name="BIRTHDATE"          src="PAT_BDATE"            srctype="ctrlcaption"   put="v4"   len="20"/>
		<component cmptype="ActionVar" name="PAT_YEARS"          src="PAT_YEARS"            srctype="ctrlcaption"   put="v5"   len="10"/>
		<component cmptype="ActionVar" name="HH_PREF_NUMB"       src="HH_PREF_NUMB"         srctype="ctrlcaption"   put="v6"   len="50"/>
		<component cmptype="ActionVar" name="DATE_IN"            src="HH_DATE_IN"           srctype="ctrlcaption"   put="v7"   len="20"/>
		<component cmptype="ActionVar" name="TIME_IN"            src="HH_TIME_IN"           srctype="ctrlcaption"   put="v7t"  len="8"/>
		<component cmptype="ActionVar" name="DATE_OUT"           src="HH_DATE_OUT"          srctype="ctrlcaption"   put="v8"   len="20"/>
		<component cmptype="ActionVar" name="PLAN_DATE_OUT"      src="PLAN_DATE_OUT"        srctype="ctrlcaption"   put="v9"   len="20"/>
		<component cmptype="ActionVar" name="HOSP_DAYS"          src="HOSP_DAYS"            srctype="ctrlcaption"   put="v10"  len="12"/>
		<component cmptype="ActionVar" name="HH_DEP_ID"          src="HH_DEP_ID"            srctype="var"           put="v11"  len="17"/>
		<component cmptype="ActionVar" name="HEALING_EMPLOYER"   src="HEALING_EMPLOYER"     srctype="ctrlcaption"   put="v12"  len="100"/>
		<component cmptype="ActionVar" name="PAYMENT_KIND"       src="PAYMENT_KIND"         srctype="ctrlcaption"   put="v13"  len="50"/>
		<component cmptype="ActionVar" name="MES"                src="MES"                  srctype="ctrlcaption"   put="v14"  len="30"/>
		<component cmptype="ActionVar" name="DISEASECASE"        src="DISEASECASE"          srctype="var"           put="v15"  len="17"/>
		<component cmptype="ActionVar" name="MKB_DEP"            src="MKB_DEP"              srctype="ctrlcaption"   put="v16d" len="550"/>
		<component cmptype="ActionVar" name="MKB_CLINIC"         src="MKB_CLINIC"           srctype="ctrlcaption"   put="v16"  len="550"/>
		<component cmptype="ActionVar" name="MKB_DEP_EXACT"      src="MKB_DEP_EXACT"        srctype="ctrlcaption"   put="v17d" len="4000"/>
		<component cmptype="ActionVar" name="MKB_CLINIC_EXACT"   src="MKB_CLINIC_EXACT"     srctype="ctrlcaption"   put="v17"  len="4000"/>
		<component cmptype="ActionVar" name="PERSMEDCARD"        src="PERSMEDCARD"          srctype="var"           put="v18"  len="17"/>
		<component cmptype="ActionVar" name="AGENT_ID"              src="AGENT_ID"                srctype="var"           put="v19"  len="17"/>
		<component cmptype="ActionVar" name="SIGNAL_INFO"        src="SIGNAL_INFO"          srctype="ctrlcaption"   put="v20"  len="4000"/>
		<component cmptype="ActionVar" name="SIGNAL_INFO_LINK"   src="SIGNAL_INFO_LINK"     srctype="ctrlcaption"   put="v21"  len="50"/>
		<component cmptype="ActionVar" name="PAYMENT_KIND_ID"    src="PAYMENT_KIND_ID"      srctype="var"           put="v22"  len="17"/>
		<component cmptype="ActionVar" name="LPUDICT_ID"         src="LPUDICT_ID"           srctype="var"           put="v23"  len="17"/>
		<component cmptype="ActionVar" name="MKB_FINAL_ID"       src="MKB_FINAL_ID"         srctype="var"           put="v24"  len="17"/>
		<component cmptype="ActionVar" name="MKB_DEP_ID"         src="MKB_DEP_ID"           srctype="var"           put="v25d" len="17"/>
		<component cmptype="ActionVar" name="MKB_CLINIC_ID"      src="MKB_CLINIC_ID"        srctype="var"           put="v25"  len="17"/>
		<component cmptype="ActionVar" name="MKB_RECEIVE_ID"     src="MKB_RECEIVE_ID"       srctype="var"           put="v26"  len="17"/>
		<component cmptype="ActionVar" name="MKB_SEND_ID"        src="MKB_SEND_ID"          srctype="var"           put="v27"  len="17"/>
        <component cmptype="ActionVar" name="PREGNANCY"          src="PREGNANCY"            srctype="ctrlcaption"   put="v28"  len="4"/>
        <component cmptype="ActionVar" name="HH_TYPE"            src="HH_TYPE"              srctype="var"           put="v29"  len="17"/>
        <component cmptype="ActionVar" name="MES_NAME"           src="MES_NAME"             srctype="var"           put="v30"  len="500"/>
        <component cmptype="ActionVar" name="DEADDATA"           src="DEADDATA"             srctype="var"           put="v31"  len="22"/>
        <component cmptype="ActionVar" name="RELATIVE_HH_ID"     src="RELATIVE_HH_ID"       srctype="var"           put="v32"  len="17"/>
        <component cmptype="ActionVar" name="IS_IN_NOS_RIGISTRS" src="IS_IN_NOS_RIGISTRS"   srctype="var"           put="v33"  len="1"/>
        <component cmptype="ActionVar" name="OPER_ANEST_CODE" 	 src="OPER_ANEST_CODE" 		srctype="var"   		put="v34"  len="4000"/>
        <component cmptype="ActionVar" name="SYS_OPT_DEP_BED" 	 src="SYS_OPT_DEP_BED" 		srctype="var"   		put="v35"  len="1"/>
        <component cmptype="ActionVar" name="PSY_ANAMNESIS" 	 src="PSY_ANAMNESIS" 		srctype="var"   		put="v39"  len="17"/>
        <component cmptype="ActionVar" name="SPEC_LPU_TYPE" 	 src="SPEC_LPU_TYPE"        srctype="var"           put="v40"  len="4000"/>
	</component>
	<component cmptype="Action" name="actionCounts" compile="true">
        <![CDATA[
		declare nDS_COUNT          NUMBER(4);
			    nMP_COUNT          NUMBER(4);
			    nDIROBS_COUNT      NUMBER(4);
			    nDIROPS_COUNT      NUMBER(4);
			    nLABMED_COUNT      NUMBER(4);
			    nPREVHOSPS_COUNT   NUMBER(4);
			    nHH_DEPS_COUNT     NUMBER(4);
			    nHH_DEP_BEDS_COUNT NUMBER(4);
			    nBL_COUNT          NUMBER(4);
                nMEAS_COUNT        NUMBER(4);
                nCOUNT             NUMBER(4);
                nTW_COUNT          NUMBER(4);
                nTH_COUNT          NUMBER(4);
		begin
			--направления на услуги
			select count(1)
			  into nDS_COUNT
			  from d_v_direction_services t
				   join d_v_directions_base t2 on t2.ID = t.PID
				   join d_v_Hosp_History_Deps hh on hh.ID = t.HH_DEP
			 where t.lpu = :LPU
			   and t.HID is null
			   and t.SERV_STATUS != 2
			   and (:HH_DEP_ID = t.HH_DEP or :HH_DEP_ID is null)
			   and t.SERVICE_TYPE not in (2,4,6,8)
			   and hh.PID = :HH_ID;
			if nDS_COUNT > 0 then
				:DIRECTION_SERVICES_COUNT := ' ('||nDS_COUNT||')';
			else :DIRECTION_SERVICES_COUNT :=null;
			end if;
			--назначения
			select count(1)
			  into nMP_COUNT
			  from d_v_mp_prescribes mpp
				   join (select min(ps.PLAN_DATE) m,
		                        ps.pid
		                   from d_v_mp_prescribe_specs ps
		               group by ps.pid) y on y.PID = mpp.ID
			 where mpp.DISEASECASE = :DISEASECASE
			   and mpp.MP_TYPE_CODE in (1,2)
			   and (:HH_DEP_ID = mpp.HH_DEP or :HH_DEP_ID is null)
			   and mpp.MP_CONDITION_CODE not in (3,4);
			if nMP_COUNT > 0 then
				   :MP_PRESCRIBES_COUNT := ' ('||nMP_COUNT||')';
			else :MP_PRESCRIBES_COUNT :=null;
			end if;
			--осмотры
			select count(1)
			  into nDIROBS_COUNT
			  from d_v_direction_services t
				   join d_v_hosp_history_deps t1 on t1.ID = t.HH_DEP
				   join d_v_directions_base t2 on t2.ID = t.PID
			 where t1.PID = :HH_ID
			   and t.lpu = :LPU
			   and t.SERVICE_TYPE in (3,4)
			   and t.SERV_STATUS != 2
			   and (:HH_DEP_ID = t.HH_DEP or :HH_DEP_ID is null);
			if nDIROBS_COUNT > 0 then
				:DIRECTION_OBSERVATIONS_COUNT := ' ('||nDIROBS_COUNT||')';
            else :DIRECTION_OBSERVATIONS_COUNT :=null;
			end if;
			--операции
			select count(1)
			  into nDIROPS_COUNT
			  from d_v_direction_services t
				   join d_v_hosp_history_deps t1 on t1.ID = t.HH_DEP
				   join d_v_directions_base t2 on t2.ID = t.PID
			 where t1.PID = :HH_ID
			   and t.lpu = :LPU
			   and t.SERV_STATUS != 2
		   @if(:OPER_ANEST_CODE){
		       and (t.SERVICE_TYPE in (2, 6) or /*t.SERVICE = :OPER_ANEST_CODE*/ instr(:OPER_ANEST_CODE || ';', t.SERVICE || ';') > 0)
		   @} else {
		   	   and t.SERVICE_TYPE in (2, 6)
		   @}
			   and (:HH_DEP_ID = t.HH_DEP or :HH_DEP_ID is null);
			if nDIROPS_COUNT > 0 then
				:DIRECTION_OPERATIONS_COUNT := ' ('||nDIROPS_COUNT||')';
			else :DIRECTION_OPERATIONS_COUNT :=null;
			end if;
			--лаб.иссл-ия
			select count(1)
			  into nLABMED_COUNT
			  from d_v_direction_services t
				   join d_v_directions_base t2 on t2.ID = t.PID
			 where t.DISEASECASE = :DISEASECASE
			   and t.lpu = :LPU
			   and t.SERVICE_TYPE = 8
			   and t.SERV_STATUS != 2
               and t.HID is null
			   and (:HH_DEP_ID = t.HH_DEP or :HH_DEP_ID is null);
			if nLABMED_COUNT > 0 then
				:ANALYSES_COUNT := ' ('||nLABMED_COUNT||')';
			else :ANALYSES_COUNT :=null;
			end if;
			--предыдущие госпитализации
			select count(1)
			  into nPREVHOSPS_COUNT
			  from D_V_HOSP_HISTORIES    hh
				   join D_V_HOSP_HISTORY_DEPS hhd
		             on hhd.PID = hh.ID
		                and hhd.DATE_IN   = (select max(DATE_IN)
		                                       from d_v_hosp_history_deps
		                                      where pid = hhd.PID)
			 where hh.LPU = :LPU
			   and hh.PATIENT_ID = :PERSMEDCARD
			   and hh.DATE_OUT is not null
			   and hh.ID != :HH_ID;
			if nPREVHOSPS_COUNT > 0 then
				:PREVIOUS_HOSPS_COUNT := ' ('||nPREVHOSPS_COUNT||')';
			else :PREVIOUS_HOSPS_COUNT :=null;
			end if;
			--перемещения по отделениям
			select count(1)
			  into nHH_DEPS_COUNT
			  from d_v_hosp_history_deps t
			 where t.PID = :HH_ID;
			if nHH_DEPS_COUNT > 0 then
				:HH_DEPS_COUNT := ' ('||nHH_DEPS_COUNT||')';
					   else :HH_DEPS_COUNT :=null;
			end if;
			--перемещение по койкам
			select count(1)
			  into nHH_DEP_BEDS_COUNT
			  from d_v_hh_dep_beds t
			 where t.HOSP_HISTORY = :HH_ID;
			if nHH_DEP_BEDS_COUNT > 0 then
				:HH_DEP_BEDS_COUNT := ' ('||nHH_DEP_BEDS_COUNT||')';
			else :HH_DEP_BEDS_COUNT :=null;
			end if;
			--больничные
			select count(1)
			  into nBL_COUNT
			  from d_v_bj_bulletin_contents t
			 where t.HOSP_HISTORY = :HH_ID;
			if nBL_COUNT > 0 then
				:BULLETIN_CONTENTS_COUNT := ' ('||nBL_COUNT||')';
			else :BULLETIN_CONTENTS_COUNT :=null;
			end if;
            --журнал измерений
            select count(1)
              into nMEAS_COUNT
              from D_V_HP_MEAS_PRESCS meas
                   join d_v_hosp_history_deps t1 on t1.ID = meas.HH_DEP
             where t1.PID = :HH_ID
               and meas.lpu = :LPU
               and (:HH_DEP_ID = meas.HH_DEP or :HH_DEP_ID is null);
             if nMEAS_COUNT > 0 then
                :MEAS_COUNT := ' ('||nMEAS_COUNT||')';
             else :MEAS_COUNT :=null;
             end if;
            --Принудительное лечение
            select count(t1.ID)
              into nCOUNT
              from D_V_AGENT_PSY_ANAMNESIS t
                   join D_V_AGENT_PSY_ANAMN_FT t1 on t1.PID = t.ID
             where t.PID = :AGENT;
            if nCOUNT > 0 then
                :PSYANAMN_COUNT := ' ('||nCOUNT||')';
            else
                :PSYANAMN_COUNT := null;
            end if;
            --Работа в ЛТМ
            select count(1)
              into nTW_COUNT
              from D_V_PST_WORKSHOPS t
             where t.HOSP_HISTORY_ID = :HH_ID;
            if nTW_COUNT > 0 then
                :TWORKSHOP_COUNT := ' ('||nTW_COUNT||')';
            else
                :TWORKSHOP_COUNT := null;
            end if;
            select count(1)
                into nTH_COUNT
                from D_V_HH_DEP_THOLIDAYS t
            where t.PID = :HH_DEP_ID;
            if nTH_COUNT > 0 then
                :THOLIDAYS_COUNT := ' ('||nTH_COUNT||')';
            else
                :THOLIDAYS_COUNT := null;
            end if;
		end;
        ]]>
		<component cmptype="ActionVar" name="HH_DEP_ID"                     src="HH_DEP_ID"                     srctype="var"          get="v1"/>
		<component cmptype="ActionVar" name="HH_ID"                         src="HH_ID"                         srctype="var"          get="v2"/>
		<component cmptype="ActionVar" name="DISEASECASE"                   src="DISEASECASE"                   srctype="var"          get="v3"/>
		<component cmptype="ActionVar" name="PERSMEDCARD"                   src="PERSMEDCARD"                   srctype="var"          get="v4"/>
		<component cmptype="ActionVar" name="OPER_ANEST_CODE"               src="OPER_ANEST_CODE"               srctype="var"          get="v5"/>
        <component cmptype="ActionVar" name="AGENT"                         src="AGENT"                         srctype="var"          get="v6"/>
        <component cmptype="ActionVar" name="LPU"                           src="LPU"                           srctype="session"/>
		<!-- put section -->
		<component cmptype="ActionVar" name="DIRECTION_SERVICES_COUNT"      src="DIRECTION_SERVICES_COUNT"      srctype="ctrlcaption"   put="v5"  len="10"/>
		<component cmptype="ActionVar" name="MP_PRESCRIBES_COUNT"           src="MP_PRESCRIBES_COUNT"           srctype="ctrlcaption"   put="v6"  len="10"/>
		<component cmptype="ActionVar" name="DIRECTION_OBSERVATIONS_COUNT"  src="DIRECTION_OBSERVATIONS_COUNT"  srctype="ctrlcaption"   put="v7"  len="10"/>
		<component cmptype="ActionVar" name="DIRECTION_OPERATIONS_COUNT"    src="DIRECTION_OPERATIONS_COUNT"    srctype="ctrlcaption"   put="v8"  len="10"/>
		<component cmptype="ActionVar" name="ANALYSES_COUNT"                src="ANALYSES_COUNT"                srctype="ctrlcaption"   put="v9"  len="10"/>
		<component cmptype="ActionVar" name="PREVIOUS_HOSPS_COUNT"          src="PREVIOUS_HOSPS_COUNT"          srctype="ctrlcaption"   put="v10" len="10"/>
		<component cmptype="ActionVar" name="HH_DEPS_COUNT"                 src="HH_DEPS_COUNT"                 srctype="ctrlcaption"   put="v11" len="10"/>
		<component cmptype="ActionVar" name="HH_DEP_BEDS_COUNT"             src="HH_DEP_BEDS_COUNT"             srctype="ctrlcaption"   put="v12" len="10"/>
		<component cmptype="ActionVar" name="BULLETIN_CONTENTS_COUNT"       src="BULLETIN_CONTENTS_COUNT"       srctype="ctrlcaption"   put="v13" len="10"/>
        <component cmptype="ActionVar" name="MEAS_COUNT"                    src="MEAS_COUNT"                    srctype="ctrlcaption"   put="v14" len="10"/>
        <component cmptype="ActionVar" name="PSYANAMN_COUNT"                src="PSYANAMN_COUNT"                srctype="ctrlcaption"   put="v18" len="10"/>
        <component cmptype="ActionVar" name="TWORKSHOP_COUNT"               src="TWORKSHOP_COUNT"               srctype="ctrlcaption"   put="v19" len="10"/>
        <component cmptype="ActionVar" name="THOLIDAYS_COUNT"               src="THOLIDAYS_COUNT"               srctype="ctrlcaption"   put="v17" len="10"/>
	</component>
	<component cmptype="DataSet" name="DS_DEP_LIST">
		select t.ID,
		       t.DATE_IN,
		       t.DATE_OUT,
		       t.DEP DEP_ID,
		       t.DEP||' ('||to_char(t.DATE_IN,'dd.mm.yyyy hh24:mi')||decode(t.DATE_OUT,null,')',' - '||to_char(t.DATE_OUT,'dd.mm.yyyy hh24:mi')||')') INFO
		from d_v_hosp_history_deps t
		where t.PID=:HH_ID
		order by 2 desc
		<component cmptype="Variable" name="HH_ID" src="HH_ID" srctype="var" get="v1"/>
	</component>
	<table class="form-table" style="width:100%;">
		<colgroup>
			<col width="33%"/>
			<col width="33%"/>
			<col width="34%"/>
		</colgroup>
		<tr>
    		<td style="padding:4px 4px 4px 0;">
    			<div class="time_div bckgrnd_top">
    				<table style="width:100%;table-layout:fixed;">
    					<colgroup>
    					    <col width="25%"/>
    					    <col width="75%"/>
    					</colgroup>
    					<tr>
    						<td style="padding-left:6px;">
    							<component cmptype="Label" caption="Пациент: "/>
    						</td>
    						<td>
    							<b>
									<component cmptype="Label" name="PAT_FIO"/>
								</b>
    						</td>
    					</tr>
    					<tr>
    						<td style="padding-left:6px;">
    							<component cmptype="Label" caption="Пол: "/>
    						</td>
    						<td>
    							<b>
									<component cmptype="Label" name="PAT_SEX"/>
								</b>
    						</td>
    					</tr>
    					<tr>
    						<td style="padding-left:6px;">
    							<component cmptype="Label" caption="Возраст: "/>
    						</td>
    						<td>
    							<b>
									<component cmptype="Label" name="PAT_BDATE"/>
    								<component cmptype="Label" caption="("/>
									<component cmptype="Label" name="PAT_YEARS"/>
									<component cmptype="Label" caption=")"/>
								</b>
    						</td>
    					</tr>
    					<tr>
    						<td style="padding-left:6px;">
    							<component cmptype="Label" caption="ИБ №: "/>
    						</td>
    						<td>
    							<b>
									<component cmptype="Label" name="HH_PREF_NUMB"/>
								</b>
    						</td>
    					</tr>
    				</table>
    			</div>
    		</td>
    		<td style="padding:4px;">
    			<div class="time_div bckgrnd_top">
    				<table style="width:100%">
    					<colgroup>
    					    <col width="50%"/>
    					    <col width="50%"/>
    					</colgroup>
    					<tr>
    						<td style="padding-left:6px;">
    							<component cmptype="Label" caption="Дата поступления: " class="linklike" onclick="base().selectNewPlanDateIn();"/>
    						</td>
    						<td>
    							<b>
									<component cmptype="Label" name="HH_DATE_IN"/>
									<component cmptype="Label" name="HH_TIME_IN"/>
								</b>
    						</td>
    					</tr>
    					<tr>
    						<td style="padding-left:6px;">
    							<component cmptype="Label" caption="Дата выписки план: " class="linklike" onclick="base().selectNewPlanDateOut();"/>
    						</td>
    						<td>
    							<b>
									<component cmptype="Label" name="PLAN_DATE_OUT"/>
								</b>
    						</td>
    					</tr>
    					<tr>
    						<td style="padding-left:6px;">
    							<component cmptype="Label" caption="Дата выписки факт: "/>
    						</td>
    						<td>
    							<b>
									<component cmptype="Label" name="HH_DATE_OUT"/>
								</b>
    						</td>
    					</tr>
    					<tr>
    						<td style="padding-left:6px;">
    						</td>
    						<td style="text-align:center;">
    							<b>
									<component cmptype="Label" style="font-size:15px;" name="HOSP_DAYS"/>
								</b>
    						</td>
    					</tr>
    				</table>
    			</div>
    		</td>
    		<td style="padding:4px 0 4px 4px;">
    			<div class="time_div bckgrnd_top">
    				<table style="width:100%">
    					<colgroup>
    					    <col width="40%"/>
    					    <col width="60%"/>
    					</colgroup>
    					<tr>
    						<td style="padding-left:6px;">
    							<component cmptype="Label" caption="Отделение:" class="linklike" onclick="base().openKSGDep();"/>
    						</td>
    						<td style="padding-top:2px;padding-right:2px;" colspan="2">
    							<component cmptype="ComboBox" name="DEP_LIST" width="100%" onchange="base().onChangeDepList();">
    								<component cmptype="ComboItem" value="" caption="Все отделения"/>
    								<component cmptype="ComboItem" dataset="DS_DEP_LIST" captionfield="INFO" datafield="ID" repeate="0" afterrefresh="base().refreshDEP_LIST();"/>
    							</component>
    						</td>
    					</tr>
    					<tr>
    						<td style="padding-left:6px;">
    							<component cmptype="Label" caption="Вид оплаты: "/>
    						</td>
    						<td colspan="2">
    							<b><component cmptype="Label" name="PAYMENT_KIND"/></b>
    						</td>
    					</tr>
    					<tr>
    						<td style="padding-left:6px;">
    							<component cmptype="Label" caption="Лечащий врач: "/>
    						</td>
    						<td colspan="2">
    							<b><component cmptype="Label" name="HEALING_EMPLOYER"/></b>
    						</td>
    					</tr>
    					<tr>
    						<td style="padding-left:6px;">
    							<component cmptype="Label" name="MES_LABEL" caption="Стандарт:" class="linklike" onclick="base().selectMes();"/>
    						</td>
    						<td>
    							<b><component cmptype="Label" name="MES"/></b>
    						</td>
    						<td>
    						</td>
    					</tr>
    				</table>
    			</div>
    		</td>
		</tr>
		<tr>
			<td colspan="3" style="padding:4px 0;">
				<div class="time_div bckgrnd" style="height:100px;">
					<table style="width:100%;table-layout:fixed;">
						<colgroup>
							<col width="220px"/>
							<col/>
						</colgroup>
						<tr>
							<td style="padding-left:6px;">
								<component cmptype="Label" caption="Клинический диагноз: "/>
							</td>
							<td>
								<b>
									<component cmptype="Label" name="MKB_CLINIC"/>
								</b>
							</td>
						</tr>
						<tr>
							<td style="padding-left:6px;">
								<component cmptype="Label" caption="Уточненный клинический диагноз: "/>
							</td>
							<td>
								<b>
									<component cmptype="Label" name="MKB_CLINIC_EXACT"/>
								</b>
							</td>
						</tr>
						<tr>
							<td style="padding-left:6px;">
								<component cmptype="Label" caption="Диагноз отделения: "/>
							</td>
							<td>
								<b>
									<component cmptype="Label" name="MKB_DEP"/>
								</b>
							</td>
						</tr>
						<tr>
							<td style="padding-left:6px;">
								<component cmptype="Label" caption="Уточненный диагноз отделения: "/>
							</td>
							<td>
								<b>
									<component cmptype="Label" name="MKB_DEP_EXACT"/>
								</b>
							</td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
		<tr>
			<td style="padding:4px 4px 4px 0;">
				<div class="time_div bckgrnd">
					<table style="width:100%">
						<colgroup>
							<col width="100%"/>
						</colgroup>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="Общие сведения" onclick="base().showPatientsInfo();"/>
								</b>
							</td>
						</tr>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="Диагнозы" onclick="base().showHospHistDiagnoses();"/>
								</b>
							</td>
						</tr>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="Осмотры" onclick="base().openOnLinkWindow('direction_observations');"/>
									<component cmptype="Label" name="DIRECTION_OBSERVATIONS_COUNT"/>
								</b>
							</td>
						</tr>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="Операции" onclick="base().openOnLinkWindow('direction_operations');"/>
									<component cmptype="Label" name="DIRECTION_OPERATIONS_COUNT"/>
								</b>
							</td>
						</tr>
					</table>
				</div>
			</td>
			<td style="padding:4px;">
				<div class="time_div bckgrnd">
					<table style="width:100%">
						<colgroup>
							<col width="100%"/>
						</colgroup>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="Направления на услуги" onclick="base().openOnLinkWindow('direction_services');"/>
									<component cmptype="Label" name="DIRECTION_SERVICES_COUNT"/>
								</b>
							</td>
						</tr>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="Назначения медикаментов" onclick="base().openOnLinkWindow('hh_mp_prescribes');"/>
									<component cmptype="Label" name="MP_PRESCRIBES_COUNT"/>
								</b>
							</td>
						</tr>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="Услуги, оказанные в других ЛПУ" onclick="base().openOnLinkWindow('other_lpu_services');"/>
									<component cmptype="Label" name="OTHER_LPU_SERVS_COUNT"/>
								</b>
							</td>
						</tr>
					</table>
				</div>
			</td>
			<td style="padding:4px 0 4px 4px;">
				<div class="time_div bckgrnd">
					<table style="width:100%; table-layout:fixed;">
						<colgroup>
							<col width="100%"/>
						</colgroup>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" caption="Сигнальная информация: "/>
								</b>
							</td>
						</tr>
						<tr>
							<td style="padding-left:6px;">
								<component style="color:red;white-space: normal;" cmptype="Label" name="SIGNAL_INFO"/>
								<component cmptype="Label" class="linklike" name="SIGNAL_INFO_LINK" title="Подробнее" onclick="base().showPatientWarnings();"/>
							</td>
						</tr>
						<tr>
							<td cmptype="tmp" name="PREGNANCY_DISPLAY" style="padding-left:6px; display: none;">
								<b>
									<component cmptype="Label" caption="Беременности (недель): "/>
								</b>
								<component cmptype="Label" name="PREGNANCY"/>
								<component cmptype="Label" class="linklike" caption="Подробнее" onclick="base().showPatientPregnancy();"/>
							</td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
		<tr>
			<td style="padding:4px 4px 4px 0;">
				<div class="time_div bckgrnd" style="height: 110px">
					<table style="width:100%">
						<colgroup>
							<col width="100%"/>
						</colgroup>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="Лабораторные исследования" onclick="base().openOnLinkWindow('analyses');"/>
									<component cmptype="Label" name="ANALYSES_COUNT"/>
								</b>
							</td>
						</tr>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" name="label_hp_meas_prescs" caption="Журнал измерений" onclick="base().openOnLinkWindow('hp_meas_prescs');"/>
                                    <component cmptype="Label" name="MEAS_COUNT"/>
								</b>
							</td>
						</tr>
						<tr name="hh_dietary_tr">
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="Режим и питание" onclick="base().openOnLinkWindow('hh_dietary');"/>
								</b>
							</td>
						</tr>

					</table>
				</div>
			</td>
			<td style="padding:4px;">
				<div class="time_div bckgrnd" style="height: 110px">
					<table style="width:100%">
						<colgroup>
							<col width="100%"/>
						</colgroup>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="История предыдущих госпитализаций" onclick="base().openOnLinkWindow('previous_hosps');"/>
									<component cmptype="Label" name="PREVIOUS_HOSPS_COUNT"/>
								</b>
							</td>
						</tr>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="История заболеваний" onclick="base().showDiseaseCasesList();"/>
								</b>
							</td>
						</tr>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="Листки нетрудоспособности" onclick="base().openOnLinkWindow('bj_bulletin_conts');"/>
									<component cmptype="Label" name="BULLETIN_CONTENTS_COUNT"/>
								</b>
							</td>
						</tr>
						<tr cmptype ="tmp" name="newborns" style="display: none">
							<td style="padding-left:6px; ">
								<b>
									<component cmptype="Label" class="linklike" caption="Истории новорожденных" onclick="base().openOnLinkWindow('newborns_stories');"/>
								</b>
							</td>
						</tr>
						<tr cmptype ="tmp" name="relative_hh_block" style="display: none">
							<td style="padding-left:6px; ">
								<b>
									<component cmptype="Label" class="linklike" caption="Сопровождающее лицо" onclick="base().openForm('relative_hh');"/>
								</b>
							</td>
						</tr>
						<tr cmptype ="tmp" name="dead_data" style="display: none">
							<td style="padding-left:6px; ">
								<b>
									<component cmptype="Label" class="linklike" caption="Данные о смерти" onclick="base().openForm('dead_data');"/>
								</b>
							</td>
						</tr>
					</table>
				</div>
			</td>
			<td style="padding:4px 0 4px 4px;">
				<div class="time_div bckgrnd" style="height: 110px">
					<table style="width:100%">
						<colgroup>
							<col width="100%"/>
						</colgroup>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="Перемещение по отделениям" onclick="base().openOnLinkWindow('hh_deps');"/>
									<component cmptype="Label" name="HH_DEPS_COUNT"/>
								</b>
							</td>
						</tr>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="Перемещение по койкам" onclick="base().openOnLinkWindow('hh_dep_beds');"/>
									<component cmptype="Label" name="HH_DEP_BEDS_COUNT"/>
								</b>
							</td>
						</tr>
						<tr>
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="Дополнительно" onclick="base().showDopParams();"/>
								</b>
							</td>
						</tr>
						<tr cmptype="tmp" name="TR_NOS_REGISTRS" style="display:none;">
							<td style="padding-left:6px;">
								<b>
									<component cmptype="Label" class="linklike" caption="Нозологические регистры" onclick="base().openNosRegistrs();"/>
								</b>
							</td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
		<tr cmptype="tmp" name="TR_ADD_INSANE_INFO">
      <td style="padding:4px 4px 4px 0;display: none;" cmptype="Base" name="psy_first_block">
        <div class="time_div bckgrnd" style="height: 110px">
          <table style="width:100%">
            <colgroup>
              <col width="100%"/>
            </colgroup>
            <tr>
              <td style="padding-left:6px;">
                <component
                  cmptype="Label"
                  caption="Психиатрический анамнез"
                  onclick="base().openMentalHistory();"
                  class="linklike bold"/>
                <component cmptype="Script">
                  <![CDATA[
                    Form.openMentalHistory = function(){
                      openD3Form('MentalHistory/mental_history',
                        true,
                        {
                          vars:{
                            AGENT: getVar('AGENT_ID'),
                            PSY_ANAMNESIS: getVar('PSY_ANAMNESIS')
                          }
                        }
                      );
                    };
                  ]]>
                </component>
              </td>
            </tr>
            <tr>
              <td style="padding-left: 6px;">
                <b>
                  <component cmptype="Label" class="linklike" caption="Особенности поведения"
                             onclick="base().openPsyBFeatures();"/>
                </b>
              </td>
            </tr>
          </table>
        </div>
      </td >
      <td style="padding:4px;display: none;" cmptype="Base" name="psy_second_block" >
        <div class="time_div bckgrnd" style="height: 110px">
          <table style="width:100%">
            <colgroup>
              <col width="100%"/>
            </colgroup>
            <tr>
              <td style="padding-left:6px;">
                <b>
                  <component cmptype="Label" class="linklike" caption="Принудительное лечение" onclick="base().openPsyAnam();"/>
                  <component cmptype="Label" name="PSYANAMN_COUNT"/>
                </b>
              </td>
            </tr>
            <tr>
              <td style="padding-left:6px;">
                <b>
                  <component cmptype="Label" class="linklike" caption="Лечебные отпуска" onclick="base().openTHolidays();"/>
                  <component cmptype="Label" name="THOLIDAYS_COUNT"/>
                </b>
              </td>
            </tr>
            <tr>
              <td style="padding-left:6px; ">
                <b>
                  <component cmptype="Label" class="linklike" caption="Работа в ЛТМ" onclick="base().openTWorkshop();"/>
                  <component cmptype="Label" name="TWORKSHOP_COUNT"/>
                </b>
              </td>
            </tr>
            <tr>
              <td style="padding-left:6px;">
                <b>
                  <component cmptype="Label" caption="Реабилитационные мероприятия" onclick="base().openWinPSY_ANAMN_REHAB();" class="linklike"/>
                  <component cmptype="Script">
                    <![CDATA[
                        Form.openWinPSY_ANAMN_REHAB = function(){
                            openD3Form(
                              'MentalHistory/subforms_view/psy_anamn_rehab',
                              true,
                              {
                                width: 800,
                                height: 600,
                                vars:{
                                 'HH_ID':getVar('HH_ID'),
                                 'PSY_ANAMNESIS':getVar('PSY_ANAMNESIS')
                              }
                            });
                        }
                    ]]>
                  </component>
                </b>
              </td>
            </tr>
          </table>
        </div>
      </td>
			<td style="padding:4px 0 4px 4px;" colspan="3" cmptype="Base" name="print_block">
				<div class="time_div bckgrnd" style="height: 110px" cmptype="tmp" name="docs_hh">
					<table>
						<colgroup>
							<col width="100%"/>
						</colgroup>
						<tr>
							<td style="padding-left:6px;">
								<b><component cmptype="Label" caption="Печать: "/></b>
							</td>
						</tr>
						<tr>
							<td style="padding-left:6px;">
								<component name="TYPE_HISTORY" cmptype="HyperLink" caption="История болезни" onclick="base().printHospHistory();"/>
							</td>
						</tr>
						<tr name="sprvk_hospital">
							<td style="padding-left:6px;">
								<component cmptype="HyperLink" name="spravka_hospital" caption="Справка о госпитализации" onclick="base().printHospSpr();"/>
							</td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
	</table>
    <div style="height: 40px;">
        <div class="formBackground form_footer">
            <component cmptype="Button" caption="Стандарт" onclick="base().showMes();" name="MES_BUTTON"/>
            <component cmptype="Button" caption="Лицевой счет" name="FACIAL_ACC_BUTTON" onclick="base().onButtonFacialAcc();"/>
            <component cmptype="Button" caption="Ок" name="OK_BUTTON" onclick="closeWindow();"/>
            <component cmptype="Button" caption="Отмена" onclick="closeWindow();"/>
            <component cmptype="SubForm" path="footerStyle"/>
        </div>
    </div>
</div>
