<div cmptype="bogus" oncreate="base().OnCreate();" onshow="base().OnShow();">
<component cmptype="ProtectedBlock" alert="true" modcode="Cdl">
    <div cmptype="title">Журнал пациентов</div>
    <component cmptype="Script">
    Form.OnCreate=function()
    {

    }
    Form.OnShow=function()
    {
        executeAction('GoDate', function () {
            setValue('rec_time_b', getVar('surrdate'));
            setValue('rec_time_end', getVar('surrdate'));
            base().Refresh();
        });
    }
    Form.GoNext=function(go)
    {
		setControlProperty('rec_time_b', 'date', incrementDate(getControlProperty('rec_time_b', 'date'), go));
		setControlProperty('rec_time_end', 'date', incrementDate(getControlProperty('rec_time_end', 'date'), go));
		base().Refresh();
    }
    Form.Refresh=function()
    {
            refreshDataSet('DS_PATJOUR');
    }
    Form.Clear=function()
    {
        clearControl('SURNAME','FIRSTNAME','LASTNAME','EMPLOYER_FIO')
            setValue('ANALYSE','-1');
            setValue('DEP','-1');
            setValue('ANALYSE_TYPE','-1');
            setValue('PAYMENT_KIND','-1');
    }
    Form.patjour_form=function()
    {
            setVar('PATJOUR',getValue('LABMED_PATJOUR'));
            openWindow({name:'UniversalComposition/UniversalComposition',unit:'LABMED_RSRCH_JOURSP',
                                            composition:'GRID',parent_var:'PATJOUR'},true,935, 426)
            .addListener('onclose',function(){
                            refreshDataSet('DS_PATJOUR',true,1);
                    },
                    null,
                    false);
    }
    Form.Search = function()
    {
            refreshDataSet('DS_PATJOUR');
    }

    Form.onPopupPatJour = function()
    {
            var _dataArray = getControlProperty('GRID_PATJOUR','data');
            PopUpItem_SetHide(getControlByName('pPATJOUR'), 'pCONFIRM_CLOSE', !Number(_dataArray['IS_OPEN']));
            PopUpItem_SetHide(getControlByName('pPATJOUR'), 'pOPEN_ANALYSE', Number(_dataArray['IS_OPEN']));
            PopUpItem_SetHide(getControlByName('pPATJOUR'), 'pCANC', !Number(_dataArray['IS_OPEN']));
            setControlProperty('pPATJOUR','hideitem','pCANCEL');
            setControlProperty('pPATJOUR','hideitem','pREPEATE');
            setControlProperty('pPATJOUR','hideitem','pNORMA');
            if(!empty(_dataArray['ID']))
            {
                    if(parseInt(_dataArray['IS_REPEAT']) > 0)
                    {
                            setControlProperty('pPATJOUR','showitem','pCANCEL');
                            setControlProperty('pPATJOUR','showitem','pREPEATE');
                    }
                    else
                    {
                            setControlProperty('pPATJOUR','hideitem','pCANCEL');
                            setControlProperty('pPATJOUR','showitem','pREPEATE');
                    }
                     setControlProperty('pPATJOUR','showitem','pNORMA');
            }
            base().onPopupAN();
    }
    Form.SetRepeate=function(_state)
    {
            if(_state==1)
            {
                    setVar('PRIMARY',getValue('GRID_PATJOUR'));
                    openWindow('Labmed/patient_journal/reason',true,443,133).addListener('onclose',function(){
                            if(getVar('ModalResult',1)==1)
                            {
                                    base(1).OnSetRepeate();
                            }
                    });
            }
            else
            {
                    setVar('IS_REPEAT',0);
                    setVar('REPEAT_REASON','');
                    executeAction('SET_REPAETE',base().OnSetRepeate);
            }
    }
    Form.OnSetRepeate = function()
    {
            setControlProperty('GRID_PATJOUR','locate',getValue('GRID_PATJOUR'));
            refreshDataSet('DS_PATJOUR');
    }
    Form.SetParams = function()
    {
        var data = getControlProperty('GRID_PATJOUR','data');
            if(data['ANALYZ_IS_MICROBIO'] == 1)
            {
                alert('Результат анализа возможно внести только через модуль "Бактериология"');
                return;
            }
            executeAction('CheckClose', function()
                {
                    if (getVar('CLOSE')==1)
                    {
                        alert(' Невозможно отредактировать показатели у закрытого анализа');
                    }
                    else
                    {
                        setVar('DIR_SERV_LABMED', data['DIRECTION_SERVICE']);
                        setVar('PATJOUR_ID_LABMED', getValue('GRID_PATJOUR'));
                        setVar('TITLE_RES', data['PATIENT'] + ': ' + data['ANALYSE']);
                    openWindow('Labmed/all_rsrch_joursp', true)
                            .addListener('onclose',function(){
                                            base(1).OnSetRepeate();
                            });

                    }

                });
    }
    Form.onClonePatJour = function(_dom,_dataArray)
    {
            var repeate=getControlByName('repeate');
            var closed=getControlByName('closed');
            if(_dataArray['SERV_STATUS'] == 2) setDomVisible(getControlByName('vis_status'),1); //Неявка
            else setDomVisible(getControlByName('vis_status'),0);
            if(_dataArray['NOT_ANALYSED_REASON'] == '1')
                {   
                    closed.style.display='';
                    repeate.style.display='none';
                }
             else
                {
                    if(parseInt(_dataArray['IS_REPEAT'])>0)
                         {
                            repeate.style.display='';
                        }
                    else repeate.style.display='none';
                    closed.style.display='none';
                 }

            var norma=getControlByName('norma');
            if(parseInt(_dataArray['IS_NORMA'])>0)
            {
                 norma.style.display='';
            }
            else norma.style.display='none';

            var patalogy=getControlByName('patalogy');
            if(_dataArray['IS_PATALOGY']=='1')
            {
                 patalogy.style.display='';
            }
            else patalogy.style.display='none';
            var lock= getControlByName('lock');
            if(parseInt(_dataArray['IS_OPEN']) == 0)
            {
               lock.style.display=''
            }
            else
            {
                lock.style.display='none'
            }
    }
    Form.onClonePatJourSp = function(_dom,_dataArray)
    {
            var repeate=getControlByName('repeatesp');
            var closed=getControlByName('closedsp');
            if(getControlProperty('GRID_PATJOUR','data')['NOT_ANALYSED_REASON'] == '1')
                {   
                    closed.style.display='';
                    repeate.style.display='none';
                }
             else
                {
                    if(parseInt(_dataArray['IS_REPEAT'])>0)
                         {
                            repeate.style.display='';
                        }
                    else repeate.style.display='none';
                    closed.style.display='none';
                 }

            var norma=getControlByName('normasp');
            if(_dataArray['IS_NORMA']=='0')
            {
                    norma.style.display='';
            }
            else norma.style.display='none';
            var patalogy=getControlByName('patalogysp');
            if(_dataArray['IS_NORMA']=='1')
            {
                 patalogy.style.display='';
            }
            else patalogy.style.display='none';

    }
    Form.SetValResult = function()
    {
           if(empty(getVar('ValResult'))) return;
           setVar('VAL_RESULT',getVar('ValResult'));

           if(!empty(getValue('GRID_PATJOUR_SelectList')))
           {
                setVar('PATJOUR_ID',getValue('GRID_PATJOUR_SelectList'));
           }
           else
           {
                setVar('PATJOUR_ID',getValue('GRID_PATJOUR'));
           }
           if(!empty(getVar('PATJOUR_ID')) &amp;&amp; !empty(getVar('VAL_RESULT')))
           {
                executeAction('SET_VAL_RESULT_ANALYZE',
                    function(){
                        setControlProperty('GRID_PATJOUR','locate',getValue('GRID_PATJOUR'));
                        refreshDataSet('DS_PATJOUR');
                    });
           }
    }
    Form.OpenSetNorm = function()
    {
        openWindow('Labmed/set_norm',true, 200,120)
        .addListener('onclose',function()
        {
           if(getVar('ModalResult',1)==1)
           {
                base(1).SetValResult();
           }
        },
         null,
         false);
    }
    Form.SHOWHIST=function()
    {
        setVar('LOC',getValue('GRID_PATJOUR'));
        var p_array = getControlProperty('GRID_PATJOUR','data');
        setVar('SYS_DIR_SERVICE', p_array['DIRECTION_SERVICE']);
        setVar('PatientID',p_array['PATIENT_ID']);
        setVar('PatientFIO',p_array['PATIENT']);
        openWindow('DiseaseCase/diseasecase',true,1000,700)
          .addListener('onclose',
                 function ()
                 {
                                 setControlProperty('GRID_PATJOUR','locate',getVar('LOC',1),1);
                             refreshDataSet('DS_PATJOUR',true,1);
                 },
                 null,
                 false, 1);

    }
    Form.CancelResearch = function()
        {
           if(!confirm('Вы действительно хотите отменить все выбранные исследования?'))return;
           
                    executeAction('CancelResearch', function(){
                        if (getVar('err')){alert (getVar('err'))}
                        else {  refreshDataSet('DS_PATJOURSP')}

                    });
        }
        Form.OpenAnalyse = function () {
            executeAction('OpenAnalyze', function () {
                setControlProperty('GRID_PATJOUR', 'locate', getValue('GRID_PATJOUR'));
                startMultiDataSetsGroup();
                    refreshDataSet('DS_PATJOUR');
                    refreshDataSet('DS_PATJOURSP');
                endMultiDataSetsGroup();
            });
        };
        Form.ConfirmAndClose = function () {
            openWindow('Labmed/close_analyse_all', true, 200, 100)
                .addListener('onclose', function () {
                             setVar('CREATE_AT', 0);
                             setVar('SIGN_DOC', 0);
                             executeAction('CloseAnalyse', function () {
                                 setControlProperty('GRID_PATJOUR', 'locate', getValue('GRID_PATJOUR'), 1);
                                 startMultiDataSetsGroup(1);
                                     refreshDataSet('DS_PATJOUR', 1);
                                     refreshDataSet('DS_PATJOURSP', 1);
                                 endMultiDataSetsGroup(1);
                             }, null, null, false, 1);

                },
                null, false);
        };
        Form.openPar=function(){
            openWindow({name:'Labmed/addict_set_params',
                        vars:{DC_ID:getControlProperty('GRID_PATJOUR','data')['IDD'],
                              SERVICE_ID:getControlProperty('GRID_PATJOUR','data')['SERVICE_ID']
                             }
            }, true);
        }
        Form.PrintRezRsrch=function()
        {
            var data = getControlProperty('GRID_PATJOUR','data');
            setVar('SHOW_EHR_SIGN', 1);
            setVar('EHR_AUTO_SIGN', 1);
            setVar('EHR_UNIT', 'VISITS');
            setVar('EHR_UNIT_ID', data['VISIT_ID']);

            if(getControlProperty('GRID_PATJOUR','data')['ANALYZ_IS_MICROBIO'] == 1)
            {
                setVar('ID', getControlProperty('GRID_PATJOUR','data')['ID']);
                setVar('ID_TYPE', 1);
                if(getControlProperty('GRID_PATJOUR' ,'data')['IS_OPEN'] != '0')
                    setVar('NO_CLOSED', '1');
                else setVar('NO_CLOSED', '');
                printReportByCode('labmed_microorgs');
                return;
            }

            setVar('DIRSERV_ID',data['DIRECTION_SERVICE']);
            executeAction('CheckReportAnalyze', function(){
		    printReportByCode(getVar('RES_REP'));
            });
        }
        <![CDATA[
        Form.onPopupAN=function(){
            if(empty(getValue('GRID_PATJOUR'))){
                PopUpItem_SetHide(getControlByName('pPATJOUR'),'pSHOW_PAR',true);
                 PopUpItem_SetHide(getControlByName('pPATJOUR'),'pREP',true);
            }else{
                setVar('S_ID',getControlProperty('GRID_PATJOUR','data')['LPU_SERVICE_ID']);
                executeAction('checkAdPar', function(){
                    if(getVar('O_W')<1){
                        PopUpItem_SetHide(getControlByName('pPATJOUR'),'pSHOW_PAR',true);
                    }else{
                        PopUpItem_SetHide(getControlByName('pPATJOUR'),'pSHOW_PAR',false);
                    }
                });
                if (getControlProperty('GRID_PATJOUR','data')['SERV_STATUS'] == 1)
                    PopUpItem_SetHide(getControlByName('pPATJOUR'),'pREP',false);
                else 
                    PopUpItem_SetHide(getControlByName('pPATJOUR'),'pREP',true);
            }
            
        }
        Form.printFew = function(){
            var dirs_list =  getValue('GRID_PATJOUR_SelectList');
            if (!empty(dirs_list)){
                if (getValue('GRID_PATJOUR_SelectList').split(';').length <= 10){ //Число выбранных строк для печати должно быть не более 10
                        executeAction('GET_DS_LIST', function(){
                                setVar('DIRS_ID', getVar('DS_LIST'));
                                printReportByCode('labmed_easy_few'); //массовый отчет
                        });
                } else {
                        alert('Вы выбрали слишком много анализов. Распечатать можно не более 10-ти результатов за один раз.');
                }
            } else {
                    alert('Не выбрано ни одного анализа для распечатки результатов')
            }
        };

Form.printFewCOV = function(){
            var dirs_list =  getValue('GRID_PATJOUR_SelectList');
            if (!empty(dirs_list)){
                if (getValue('GRID_PATJOUR_SelectList').split(';').length <= 10){ //Число выбранных строк для печати должно быть не более 10
                        executeAction('GET_DS_LIST', function(){
                                setVar('DIRS_ID', getVar('DS_LIST'));
                                printReportByCode('labmed_easy_fewCOV'); //массовый отчет
                        });
                } else {
                        alert('Вы выбрали слишком много анализов. Распечатать можно не более 10-ти результатов за один раз.');
                }
            } else {
                    alert('Не выбрано ни одного анализа для распечатки результатов')
            }
        };


        Form.OpenEhrs = function(){
            openWindow({name:'Labmed/patient_journal/patjour_ehrs',
                vars:{EHR_UNIT_ID:getValue('GRID_PATJOUR'),
                      EHR_UNIT:'LABMED_PATJOUR'}}, true);
            getValue('GRID_PATJOUR')
        };
        ]]>
    </component>
    <component cmptype="SubForm" path="Labmed/SubForms/ActionDefaultReport"/>
    <component cmptype="Action" name="checkAdPar">
            <![CDATA[
                begin
                    select count (lap.ID)
                    into :O_W
                    from D_V_LABMED_ANALYZE la,
                              D_V_LABMED_ANALYZE_PARAMS lap
                    where la.LPU_SERVICE_ID=:LPU_SERVICE_ID
                    and   la.LPU=:LPU
                    and   lap.PID=la.ID;
                end;
            ]]>
            <component cmptype="ActionVar" name="LPU" src="LPU" srctype="session"/>
            <component cmptype="ActionVar" name="LPU_SERVICE_ID" src="S_ID" srctype="var" get="ag2"/>
            <component cmptype="ActionVar" name="O_W" src="O_W" srctype="var" put="ag2" len="3"/>
        </component>
        <component cmptype="Action" name="CancelResearch">
            declare
                cur  d_v_labmed_rsrch_jour%rowtype;
		    begin

                 FOR cur in (select  * from  d_v_labmed_rsrch_jour  t where t.PATJOUR = :PATJOUR)
                 LOOP
                    begin
			            d_pkg_labmed_rsrch_jour.cancel_research(pnid => cur.ID,
                                                               pnlpu => :LPU);
                        exception when others then  :err := SUBSTR(SQLERRM, 1, 1000);
                    end;
                 END LOOP;
		    end;
		    <component cmptype="ActionVar" name="LPU" src="LPU" srctype="session"/>
            <component cmptype="ActionVar" name="PATJOUR" srctype="ctrl" src="GRID_PATJOUR" get="v1"/>
		    <component cmptype="ActionVar" name="err"     src="err"     srctype="var" put="err" len ="2000"/>
	    </component>
        <component cmptype="Action" name="OpenAnalyze">

                 declare
                    cur  d_v_labmed_rsrch_jour%rowtype;
                    is_an number;
                 begin
                      select t1.IS_ANALYSED
                        into is_an
                        from d_v_labmed_patjour t1
                       where t1.ID = :PATJOUR;
        
                         d_pkg_labmed_patjour.open_analyse(pnid => :PATJOUR,
                                        pnlpu => :PNLPU);

                 FOR cur in (select  * from  d_v_labmed_rsrch_jour  t where t.PATJOUR = :PATJOUR)
                 LOOP
                    begin
                      if cur.CONFIRM_EMP_ID is not null then
                            d_pkg_labmed_rsrch_jour.set_confirm_emp(pnid => cur.ID,
                                          pnlpu => :PNLPU,
                                          pnconfirm_emp => null);

                          end if;
                      end;
                   END LOOP;
                 end;
		<component cmptype="ActionVar" name="PNLPU" srctype="session" src="LPU"/>
                <component cmptype="ActionVar" name="err"     src="err"     srctype="var" put="err" len ="100"/>
                <component cmptype="ActionVar" name="PATJOUR" srctype="ctrl" src="GRID_PATJOUR" get="v1"/>
	</component>

        <component cmptype="Action" name="CloseAnalyse">
                declare
                    nIS_ANALYSED NUMBER(1);
                    cur  d_v_labmed_rsrch_jour%rowtype;
                begin


                    FOR cur in (select  * from  d_v_labmed_rsrch_jour  t where t.PATJOUR = :PATJOUR)
                     LOOP
                    begin
                         d_pkg_labmed_rsrch_jour.set_confirm_emp(pnid => cur.ID,
                                          pnlpu => :LPU,
                                          pnconfirm_emp => d_pkg_employers.get_id(:LPU));
                    end;
                 END LOOP;
                 select t.IS_ANALYSED
                       into nIS_ANALYSED
                       from D_V_LABMED_PATJOUR t
                      where t.LPU = :LPU
                        and t.ID  = :PATJOUR;
                      if nIS_ANALYSED != 1 then
                            d_pkg_labmed_patjour.close_analyse(pnid => :PATJOUR,
                                     pnlpu => :LPU,
                                     pncreate_at => :pncreate_at,
                                     pnsign_doc => :pnsign_doc,
                                     pnraise => :pnraise);
                      end if;
                  
		end;
		<component cmptype="ActionVar" name="LPU" src="LPU" 	srctype="session"/>
		<component cmptype="ActionVar" name="ID"  src="MAIN_ID" srctype="var" get="v1"/>       
		<component cmptype="ActionVar" name="PATJOUR" srctype="ctrl" src="GRID_PATJOUR" get="v1"/>
		<component cmptype="ActionVar" name="pncreate_at" srctype="var" src="CREATE_AT" get="pncreate_at"/>
		<component cmptype="ActionVar" name="pnsign_doc" srctype="var" src="SIGN_DOC" get="pnsign_doc"/>
		<component cmptype="ActionVar" name="pnraise" srctype="const" src="1" get="pnraise"/>
	</component>
        <component cmptype="Action" name="CheckClose">
            begin
                   select t.IS_ANALYSED
                        into :close
                       from D_V_LABMED_PATJOUR t
                      where t.LPU = :LPU
                        and t.ID  = :PATJOUR;
            end;
          <component cmptype="ActionVar" name="PATJOUR" srctype="ctrl" src="GRID_PATJOUR" get="v1"/>
          <component cmptype="ActionVar" name="LPU" src="LPU" 	srctype="session"/>
          <component cmptype="ActionVar" name="close" srctype="var" src="CLOSE" put="close"/>
        </component>

    <component cmptype="DataSet" name="DS_PATJOUR" activateoncreate="false" mode="Range" compile="true">
    <![CDATA[
            select  t.ID,t.SERVICE_ID,t1.ID IDD,t.LPU_SERVICE_ID,
                            t.CROCKERY, /*||' - '||to_char(t.PICK_DATE,'DD.MM.YYYY hh24:mi:ss') --Посуда*/
                            t.PATIENT_ID,   --Пациент
                            t.PATIENT,   --Пациент
                            t.NOT_ANALYSED_REASON,
                            1 - t.IS_ANALYSED IS_OPEN, -- Открыт ли анализ
                            t.SURNAME||' '||t.FIRSTNAME||' '||t.LASTNAME||' д.р.'||t.PATIENT_BIRTHDATE PATIENT_FIO,
                            t.ANALYSE,   --Анализ
                            t.DIRECTION_SERVICE,
                            replace(t1.PAYMENT_KIND_NAME||', '||t1.EMPLOYER_FIO_TO||', '||t1.REC_DATE,', ,','') ANALYSE_HINT,
                            t1.PAYMENT_KIND_NAME,
                            (select count(1)
                             from d_v_labmed_rsrch_jour j
                             where j.PATJOUR=t.ID  and j.IS_REPEAT = 1)  IS_REPEAT, --Нужно ли проводить повтороно
                            (select case when 
                                      instr(d_stragg(case when 
                                                      (rv.REF_TYPE=0 and ((js.RESULT_TYPE=0 and js.RES_VALUE between rv.REF_VALUE_FROM and rv.REF_VALUE_TO) or (js.RESULT_TYPE=1 and js.RES_VALUE=rv.REF_VALUE))) 
                                                       or (rv.REF_TYPE=1 and (js.RESULT_TYPE=0 and js.RES_VALUE not between rv.REF_VALUE_FROM and rv.REF_VALUE_TO) or (js.RESULT_TYPE=1 and js.RES_VALUE!=rv.REF_VALUE))
                                                     then 0 else 1 end),'1')>0 
                                    then 1 else 0 end
                             from d_v_labmed_rsrch_joursp js,
                                  d_v_labmed_rsrch_jour j,
                                  D_V_LABMED_RSRCH_RES_REFS rv 
                             where j.PATJOUR=t.ID
                                 and j.ID = js.PID
                                 and js.RSRCH_RES_REF = rv.ID)  IS_PATALOGY, --Есть ли патологии
                            (select case when 
                                      instr(d_stragg(case when 
                                                      (rv.REF_TYPE=0 and ((js.RESULT_TYPE=0 and js.RES_VALUE between rv.REF_VALUE_FROM and rv.REF_VALUE_TO) or (js.RESULT_TYPE=1 and js.RES_VALUE=rv.REF_VALUE))) 
                                                       or (rv.REF_TYPE=1 and ((js.RESULT_TYPE=0 and js.RES_VALUE not between rv.REF_VALUE_FROM and rv.REF_VALUE_TO) or (js.RESULT_TYPE=1 and js.RES_VALUE!=rv.REF_VALUE)))
                                                     then 0 else 1 end),'1')=0 
                                    then 1 else 0 end
                             from d_v_labmed_rsrch_joursp js,
                                  d_v_labmed_rsrch_jour j,
                                  D_V_LABMED_RSRCH_RES_REFS rv 
                             where j.PATJOUR=t.ID
                                 and j.ID = js.PID
                                 and js.RSRCH_RES_REF = rv.ID)  IS_NORMA, --Есть ли норма
                            t2.ANALYZ_IS_MICROBIO,
                            t1.SERV_STATUS,
                            d.REG_EMPLOYER_FIO,
                            t1.DP_NAME,
                            v.ID VISIT_ID
            from d_v_labmed_patjour t,
                 d_v_direction_services t1,
                 d_v_labmed_analyze t2,
		 D_V_DIRECTIONS      d,
        	 D_V_EMPLOYERS       e,
        	 D_V_VISITS v
            where   t.LPU  = :LPU
                    and t1.ID = t.DIRECTION_SERVICE
                    and v.PID(+) = t1.ID
                    and t.ANALYSE_ID = t2.ID
                    and t.PICK_DATE >= to_date(:rec_time_b) 
                    and t.PICK_DATE < (to_date(:rec_time_end) + 1)
                    and t1.PID = d.ID
                    and d.REG_EMPLOYER_ID = e.ID
                    @if(:SURNAME){
                        and upper(t.SURNAME) like upper(:SURNAME)||'%'
                    @}
                    @if(:FIRSTNAME){
                        and upper(t.FIRSTNAME) like upper(:FIRSTNAME)||'%'
                    @}
                    @if(:LASTNAME){
                        and upper(t.LASTNAME) like upper(:LASTNAME)||'%'
                    @}
                    @if(:ANALYSE<>'-1'){
                       and t.ANALYSE_ID = :ANALYSE
                    @}
                    @if(:ANALYSE_TYPE<>'-1'){
                       and t2.ANALYZ_TYPE_ID = :ANALYSE_TYPE
                    @}
                    @if(:PAYMENT_KIND <>'-1'){
                        and t1.PAYMENT_KIND_ID = :PAYMENT_KIND
                    @}
                    @if(:EMPLOYER_FIO){
                        and upper(d.REG_EMPLOYER_FIO) like upper(:EMPLOYER_FIO)||'%'
                    @}
                    @if(:DEP <>'-1'){
                        and t1.DP_ID = :DEP
                    @}
                    @if(:OPEN_ANALYSIS == 1){
                        and (select decode(t3.IS_OPEN, 1, 1, 0) from D_V_LABMED_RSRCH_JOUR t3 where t3.PATJOUR = t.ID and rownum = 1) = 1
                    @}
                    @if(:OPEN_ANALYSIS == 2){
                        and (select decode(t3.IS_OPEN, 1, 1, 0) from D_V_LABMED_RSRCH_JOUR t3 where t3.PATJOUR = t.ID and rownum = 1) = 0
                    @}
]]>
            <component cmptype="Variable" name="LPU" srctype="session" src="LPU"/>
            <component cmptype="Variable" name="rec_time_b" srctype="ctrl" src="rec_time_b" get="rec_time_b"/>
            <component cmptype="Variable" name="rec_time_end" srctype="ctrl" src="rec_time_end" get="rec_time_end"/>
            <component cmptype="Variable" name="SURNAME" srctype="ctrl" src="SURNAME" get="SURNAME"/>
            <component cmptype="Variable" name="FIRSTNAME" srctype="ctrl" src="FIRSTNAME" get="FIRSTNAME"/>
            <component cmptype="Variable" name="LASTNAME" srctype="ctrl" src="LASTNAME" get="LASTNAME"/>
            <component cmptype="Variable" name="ANALYSE" srctype="ctrl" src="ANALYSE" get="ANALYSE"/>
            <component cmptype="Variable" name="ANALYSE_TYPE" srctype="ctrl" src="ANALYSE_TYPE" get="ANALYSE_TYPE"/>
            <component cmptype="Variable" name="PAYMENT_KIND" srctype="ctrl" src="PAYMENT_KIND" get="PAYMENT_KIND"/>
            <component cmptype="Variable" name="EMPLOYER_FIO" srctype="ctrl" src="EMPLOYER_FIO" get="EMPLOYER_FIO"/>
            <component cmptype="Variable" name="DEP" srctype="ctrl" src="DEP" get="DEP"/>
            <component cmptype="Variable" name="OPEN_ANALYSIS" srctype="ctrl" src="OPEN_ANALYSIS" get="OPEN_ANALYSIS"/>
            <component cmptype="Variable" type="start" srctype="var" src="r1s" default="1"/>
            <component cmptype="Variable" type="count" srctype="var" src="r1c" default="10"/>
    </component>
    <component cmptype="DataSet" name="DS_DEPS">
		SELECT t.ID, t.DP_NAME
		from D_V_DEPS t
		where t.LPU = :LPU
    <component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
    </component>
    <component cmptype="Action" name="GET_DS_LIST">
		begin
			select d_stragg(t.DIRECTION_SERVICE)
			  into :DS_LIST
			  from d_v_labmed_patjour t
			 where (';'||upper(:PJ)||';'  like '%;'||upper(t.ID)||';%');
			 exception when no_data_found then :DS_LIST := null;
		end;
		<component cmptype="ActionVar" name="PJ"      src="GRID_PATJOUR_SelectList" srctype="ctrl" get="gvar1"/>
		<component cmptype="ActionVar" name="DS_LIST" src="DS_LIST"                 srctype="var"  put="pvar1" len="4000"/>
    </component>
    <component cmptype="DataSet" name="DS_PATJOURSP" activateoncreate="false" mode="Range">
            select
                    t1.ID,
                    t1.RESULT,     --Исследование
                    t.RESEARCH_DATE,      --Дата исследования
                    t.EQUIPMENT_NAME,     --Оборудование
                    t.RESEARCH_STATUS_MNEMO, --Проведен/Не проведен
                    t.RESEARCH_STATUS,
                    case
                             when t1.NUM_VALUE is not null then
                              rtrim(to_char(t1.NUM_VALUE, 'fm'||rpad('9', 30, '9')||'0d'||
                              case when t1.NUM_PRECISION is not null then rpad('0',t1.NUM_PRECISION,'0')
                                    else rpad('9',30,'9')
                              end
                                ), '.,') || ' ' ||
                              t1.MEASURE
                             when t1.RES_VALUE is not null then
                              t1.STR_VALUE || ' ' || t1.MEASURE
                             else
                              null
                    end RES_VALUE, --Результат
                    decode(t1.CALC_TYPE,0,'прямой',1,'расчитываемый') CALC_TYPE, --Признак расчета результата (0-прямой, 1-расчитываемый)
                    decode(t1.RESULT_TYPE,0,'число',1,'строка') RESULT_TYPE,-- 0 число , 1 строка
                    t.IS_REPEAT							IS_REPEAT,--Нужно ли проводить повтороно
                    (select case when ((t3.REF_TYPE=0 and ((t1.RESULT_TYPE=0 and t1.RES_VALUE between t3.REF_VALUE_FROM and t3.REF_VALUE_TO) or (t1.RESULT_TYPE=1 and t1.RES_VALUE=t3.REF_VALUE))) 
                                   or (t3.REF_TYPE=1 and ((t1.RESULT_TYPE=0 and t1.RES_VALUE not between t3.REF_VALUE_FROM and t3.REF_VALUE_TO) or (t1.RESULT_TYPE=1 and t1.RES_VALUE=t3.REF_VALUE)))) and t3.ID is not null 
                            then 0 else 1 end 
                       from D_V_LABMED_RSRCH_RES_REFS t3 
                      where t1.RSRCH_RES_REF = t3.ID(+)) IS_NORMA,--Есть ли патологии
					d_pkg_labmed_rsrch_joursp.get_ref_value(t1.ID,:LPU, 0)
										REFS,
                   t1.ORDER_NUMB
            from
                    d_v_labmed_rsrch_jour t,
                    d_v_labmed_rsrch_joursp t1,
                    d_v_labmed_rsrch_res_refs t3
             where t.ID(+) = t1.PID
               and t1.RSRCH_RES_REF = t3.ID(+)
               and t.PATJOUR = :PATJOUR
			
            <component cmptype="Variable" name="LPU" srctype="session" src="LPU"/>
            <component cmptype="Variable" name="PATJOUR" srctype="ctrl" src="GRID_PATJOUR" get="pid"/>
            <component cmptype="Variable" type="start" srctype="var" src="r2s" default="1"/>
            <component cmptype="Variable" type="count" srctype="var" src="r2c" default="10"/>
    </component>
    <component cmptype="Action" name="SET_REPAETE" mode="post">
            begin
              d_pkg_labmed_patjour.set_is_repeat(pnid => :pnID,
                                                 pnlpu => :pnLPU,
                                                 pnis_repeat => :pnIS_REPEAT,
                                                 psrepeat_reason => :psREPEAT_REASON);
            end;
            <component cmptype="ActionVar" name="pnID" get="v0" src="GRID_PATJOUR" srctype="ctrl"/>
            <component cmptype="ActionVar" name="pnLPU" get="v1" src="LPU" srctype="session"/>
            <component cmptype="ActionVar" name="pnIS_REPEAT" get="v1" src="IS_REPEAT" srctype="var"/>
            <component cmptype="ActionVar" name="psREPEAT_REASON" get="v2" src="REPEAT_REASON" srctype="var"/>
    </component>
    <component cmptype="Action" name="SET_VAL_RESULT_ANALYZE" unit="LABMED_RSRCH_JOURSP" action="SET_VAL_RESULTA" method="post">
            <component cmptype="ActionVar" name="~pnPATJOUR" get="v0" src="PATJOUR_ID" srctype="var"/>
            <component cmptype="ActionVar" name="pnLPU" get="v1" src="LPU" srctype="session"/>
            <component cmptype="ActionVar" name="pnVAL_RESULT" put="v1" src="VAL_RESULT" srctype="var"/>
    </component>

    <component cmptype="DataSet" name="ANALYSE">
            select t.id, t.la_name
            from d_v_labmed_analyze t 
            where t.LPU=:LPU
            order by t.la_name
        <component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
    </component>
    <component cmptype="DataSet" name="DS_ANALYZ_TYPES">
            select t.ID, t.AT_NAME
            from D_V_LABMED_ANALYZ_TYPES t
            where t.LPU = :LPU
        <component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
    </component>
    <component cmptype="Action" name="GoDate">
            begin
                    select to_char(sysdate,'DD.MM.YYYY') into :surrdate from dual;
            end;
            <component cmptype="ActionVar" name="surrdate" srctype="var" src="surrdate" put="surrdate" len="32"/>
    </component>
              <!-- DataSet видов оплаты с вытаскиванием соотв. атрибутов -->
  <component cmptype="DataSet" name="DSGlobalPaymentKinds">
		select pk.ID,
			pk.PK_NAME
		from d_v_payment_kind pk order by pk.PK_NAME
    <component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
  </component>

    <table style="margin:2px 5px;">
            <tr>
                    <td colspan="3">
                            <component cmptype="Label" caption="Дата забора:"/>
                    </td>
                    <td>
                            <component cmptype="Label" caption="Врач:"/>
                    </td>
                    <td>
                            <component cmptype="Label" caption="Отделение:"/>
                    </td>
                    <td>
                            <component cmptype="Label" caption="Фамилия:"/>
                    </td>
                    <td>
                            <component cmptype="Label" caption="Имя:"/>
                    </td>
                    <td>
                            <component cmptype="Label" caption="Отчество:"/>
                    </td>
                    <td>
                            <component cmptype="Label" caption="Тип анализа:"/>
                    </td>
                    <td>
                            <component cmptype="Label" caption="Анализ:"/>
                    </td>
                    <td>
                            <component cmptype="Label" caption="Вид оплаты:"/>
                    </td>
            </tr>
            <tr>
                    <td>
						<component cmptype="Label" caption="Дата с:"/>
						<component cmptype="DateEdit" name="rec_time_b" onkeypress="onEnter(function (){refreshDataSet('DS_PATJOUR')});"/>
						<component cmptype="Label" caption="по:"/>
						<component cmptype="DateEdit" name="rec_time_end" onkeypress="onEnter(function (){refreshDataSet('DS_PATJOUR')});"/>
                    </td>
                    <td style="padding-left:3pt;padding-right:1pt">
                            <component cmptype="Button" type="small" icon="Icons/control_l" title="Назад"  onclick="base().GoNext(-1);"/>
                    </td>
                    <td style="padding-left:1pt;padding-right:3pt">
                            <component cmptype="Button" type="small" icon="Icons/control_r" title="Вперёд" onclick="base().GoNext(1);"/>
                    </td>
                    <td>
                            <component cmptype="Edit" name="EMPLOYER_FIO" onkeypress="onEnter(base().Search);"/>
                    </td>
                    <td>
                            <component cmptype="ComboBox" name="DEP">
                                    <component cmptype="ComboItem" value="-1" caption="Не выбрано"/>
                                    <component cmptype="ComboItem" datafield="ID" captionfield="DP_NAME" repeate="0" dataset="DS_DEPS"/>
                            </component>
                    </td>
                    <td>
                            <component cmptype="Edit" name="SURNAME" onkeypress="onEnter(base().Search);"/>
                    </td>
                    <td>
                            <component cmptype="Edit" name="FIRSTNAME" onkeypress="onEnter(base().Search);"/>
                    </td>
                    <td>
                            <component cmptype="Edit" name="LASTNAME" onkeypress="onEnter(base().Search);"/>
                    </td>
                    <td>
                            <component cmptype="ComboBox" name="ANALYSE_TYPE">
					<component cmptype="ComboItem" value="-1" caption="Не выбрано"/>
					<component cmptype="ComboItem" datafield="ID" captionfield="AT_NAME" repeate="0" dataset="DS_ANALYZ_TYPES"/>
                            </component>
                    </td>
                    <td>
                            <component cmptype="ComboBox" name="ANALYSE">
                                    <component cmptype="ComboItem" value="-1" caption="Не выбран"/>
                                    <component cmptype="ComboItem" datafield="ID" captionfield="LA_NAME" repeate="0" dataset="ANALYSE"/>
                            </component>
                    </td>
                    <td>
                            <component cmptype="ComboBox" name="PAYMENT_KIND">
                                    <component cmptype="ComboItem" value="-1" caption="Не выбран"/>
                                    <component cmptype="ComboItem" datafield="ID" captionfield="PK_NAME" repeate="0" dataset="DSGlobalPaymentKinds"/>
                            </component>
                    </td>
                    <td>
                            <component cmptype="Button" style="width:80px" caption="Поиск" onclick="base().Refresh();"/>
                    </td>
                    <td>
                            <component cmptype="Button" style="width:80px" caption="Очистить" onclick="base().Clear();"/>
                    </td>
            </tr>
    </table>
    <br/>
    <br/>
    <hr/>
    <br/>
    <table width="100%">
            <tr>
                 <td>
                 <component cmptype="Button" style="width:80px; margin-bottom: 10px;" caption="Распечатать результаты COVID" onclick="base().printFewCOV();"/><br/>
                    <component cmptype="Button" style="width:80px; margin-bottom: 10px;" caption="Распечатать результаты" onclick="base().printFew();"/><br/>
                     <label>
                         <component cmptype="ComboBox" name="OPEN_ANALYSIS"  onchange="base().Refresh();">
                             <component cmptype="ComboItem" value="0" caption="Все"/>
                             <component cmptype="ComboItem" value="1" caption="Открытые"/>
                             <component cmptype="ComboItem" value="2" caption="Закрытые"/>
                         </component>
                     </label>
                </td>
            </tr>
            <tr>
                    <td width="50%">
                    <div style="oveflow:auto;height:500px;">
                            <component cmptype="Grid" name="GRID_PATJOUR" grid_caption="Журнал пациентов"
                                    height="100%" dataset="DS_PATJOUR" field="ID" style="width:100%" afterrefresh="refreshDataSet('DS_PATJOURSP');" selectlist="ID"
                                    onchange="refreshDataSet('DS_PATJOURSP');" onclone="base().onClonePatJour(this,_dataArray);">
                                    <component cmptype="Column" caption="Посуда" field="CROCKERY" sort="CROCKERY" width="25%"/>
                                    <component cmptype="Column" caption="Пациент" sort="PATIENT" width="30%">
                                        <div class="column_btn" style="float: left;"><img name="pat_img" cmptype="img" src="Icons/result" title="История заболеваний и результаты исследований" onclick="base().SHOWHIST();"/></div>
                                        <component cmptype="Label" captionfield="PATIENT" hintfield="PATIENT_FIO" style="padding-left: 5px"/>
                                        <div class="column_btn" style="float: right;"><img cmptype="HyperLink" name="lock"  src="Images/lock.png" style="width:15px; height:15px; padding-top: 2px" title="Анализ закрыт"/></div>
                                    </component>
                                    <component cmptype="Column" caption="Отделение" field="DP_NAME" sort="DP_NAME" width="40%">
						<component cmptype="Label" captionfield="DP_NAME"/>
                                    </component>
                                    <component cmptype="Column" caption="Врач" field="REG_EMPLOYER_FIO" sort="REG_EMPLOYER_FIO" width="40%">
                                                    <component cmptype="Label" captionfield="REG_EMPLOYER_FIO"/>
                                    </component>
                                    <component cmptype="Column" caption="Анализ" field="ANALYSE" sort="ANALYSE" width="40%" name="AA">
                                            <component cmptype="Label" captionfield="ANALYSE" hintfield="ANALYSE_HINT"/>
                                    </component>
                                    <component cmptype="Column" caption="&#160;&#160;&#160;&#160;&#160;" field="IS_REPEAT" align="center" width="20px">
                                            <img cmptype="HyperLink" name="repeate" src="Images/warning/red-reload.jpg" style="cursor:pointer;" width="16px" height="16px" title="Необходимо повторить анализ!"/>
                                            <img cmptype="HyperLink" name="closed" src="Images/img2/off.gif" style="cursor:pointer;" width="16px" height="16px" title="Отменен лабароторией"/>
                                    </component>
                                    <component cmptype="Column" caption="&#160;&#160;&#160;&#160;&#160;" field="IS_NORMA" align="center" width="20px">
                                            <img cmptype="HyperLink" name="patalogy" src="Images/warning/exclamation.jpg" style="cursor:pointer;" width="16px" height="16px" title="Есть отклонения от нормы!"/>
                                            <img cmptype="HyperLink" name="norma" src="Images/img2/ok-confirm.png" style="cursor:pointer;" width="16px" height="16px" title="Норма"/>
                                            <component cmptype="Image" src="Images/Icons/delete" name="vis_status" title="Неявка"/>
                                    </component> 
                                    <component cmptype="GridFooter">
                                            <component cmptype="Range" insteadrefresh="InsteadRefresh(this);" id="range1" count="20" varstart="r1s" varcount="r1c" valuecount="20" valuestart="1" />
                                    </component>
                            </component>
                             <component cmptype="Popup" name="pPATJOUR" popupobject="GRID_PATJOUR" onpopup="base().onPopupPatJour();">
                                    <component cmptype="PopupItem" name="pREFRESH_PATJOUR" caption="Обновить" onclick="setControlProperty('GRID_PATJOUR','locate',getValue('GRID_PATJOUR'));refreshDataSet('DS_PATJOUR');" cssimg="refresh"/>
                                    <component cmptype="PopupItem" name="pSEPARETE" caption="-"/>
                                    <component cmptype="PopupItem" name="pPARAMS" caption="Заполнить параметры" onclick="base().SetParams();" cssimg="insert"/>
                                    <component cmptype="PopupItem" name="pSHOW_PAR"  caption="Открыть доп параметры"          onclick="base().openPar();"/>
                                    <component cmptype="PopupItem" name="pREPEATE" caption="Повторить (Указать причину повтора)" onclick="base().SetRepeate(1);" cssimg="insert"/>
                                    <component cmptype="PopupItem" name="pCANCEL" caption="Отменить повтор" onclick="base().SetRepeate(0);" cssimg="delete"/>
                                    <component cmptype="PopupItem" name="pSEPARETE" caption="-"/>
                                    <component cmptype="PopupItem" name="pNORMA" caption="Установить норму/патологию" onclick="base().OpenSetNorm();" cssimg="ok-confirm"/>
                                    <component cmptype="PopupItem" name="pSEP" caption="-"/>
                                    <component cmptype="PopupItem" name="pCONFIRM_CLOSE" caption="Закрыть" onclick="base().ConfirmAndClose();" cssimg="off"/>
                                    <component cmptype="PopupItem" name="pOPEN_ANALYSE" caption="Открыть" onclick="base().OpenAnalyse();" cssimg="edit"/>
		                    <component cmptype="PopupItem" name="pCANC" caption="Отменить исследование(-я)" onclick="base().CancelResearch();" cssimg="delete"/>
                                    <component cmptype="PopupItem" name="pSEP" caption="-"/>
                                    <component cmptype="PopupItem" name="pREP" caption="Отчет: Результаты исследования" onclick="base().PrintRezRsrch();" cssimg="print"/>
                                    <component cmptype="PopupItem" name="pDOCS" caption="Документы" onclick="base().OpenEhrs();" cssimg="print"/>
                             </component>
                             <component cmptype="AutoPopupMenu" unit="LABMED_PATJOUR" all="true" join_menu="pPATJOUR" popupobject="GRID_PATJOUR"/>
                     </div>
                    </td>
                    <td width="50%">
                            <div style="oveflow:auto;height:500px;">
                            <component cmptype="Grid" name="GRID_PATJOURSP" grid_caption="Результаты параметров исследования" height="100%" dataset="DS_PATJOURSP" field="ID" style="width:100%" onclone="base().onClonePatJourSp(this,_dataArray);">
                                    <component cmptype="Column" caption="Показатель" field="RESULT" sort="RESULT" filter="RESULT" width="45%"/>
                                    <component cmptype="Column" caption="Результат" field="RES_VALUE" sort="RES_VALUE" filter="RES_VALUE" align="center" width="25%">
                                            <component cmptype="Label" captionfield="RES_VALUE"/>
                                    </component>

                                    <component cmptype="Column" caption="&#160;&#160;&#160;&#160;&#160;" field="IS_REPEAT" align="center" width="20px">
                                            <img cmptype="HyperLink" name="repeatesp" src="Images/warning/red-reload.jpg" style="cursor:pointer;" width="16px" height="16px" title="Необходимо повторить анализ!"/>
                                            <img cmptype="HyperLink" name="closedsp" src="Images/img2/off.gif" style="cursor:pointer;" width="16px" height="16px" title="Отменен лабароторией"/>
                                    </component>
                                      <component cmptype="Column" caption="&#160;&#160;&#160;&#160;&#160;" field="IS_NORMA" align="center" width="20px">
                                            <img cmptype="HyperLink" name="patalogysp" src="Images/warning/exclamation.jpg" style="cursor:pointer;" width="16px" height="16px" title="Есть отклонения от нормы!"/>
                                            <img cmptype="HyperLink" name="normasp" src="Images/img2/ok-confirm.png" style="cursor:pointer;" width="16px" height="16px" title="Норма"/>
                                    </component>
                                    <component cmptype="Column" caption="Норма" field="REFS" sort="REFS" filter="REFS" align="center" width="25%"/>
                                    <component cmptype="Column" caption="№" field="ORDER_NUMB" sort="ORDER_NUMB" sortorder="1" align="center" width="20"/>
                                   <component cmptype="GridFooter">
                                            <component cmptype="Range" insteadrefresh="InsteadRefresh(this);" id="range2" count="20" varstart="r2s" varcount="r2c" valuecount="20" valuestart="1" />
                                    </component>
                            </component>
                             <component cmptype="Popup" name="pPATJOURSP" popupobject="GRID_PATJOURSP">
                                    <component cmptype="PopupItem" name="pREFRESH_PATJOURSP" caption="Обновить" onclick="setControlProperty('GRID_PATJOURSP','locate',getValue('GRID_PATJOURSP')); refreshDataSet('DS_PATJOURSP');" cssimg="refresh"/>
                                    <component cmptype="PopupItem" name="pSEPARETE" caption="-"/>
                             </component>
                             <component cmptype="AutoPopupMenu" unit="LABMED_RSRCH_JOURSP" all="true" join_menu="pPATJOURSP" popupobject="GRID_PATJOURSP"/>
                            </div>
                    </td>
            </tr>
    </table>
</component>
</div>