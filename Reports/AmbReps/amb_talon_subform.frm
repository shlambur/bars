<div>
<!--    Begin Script    -->
<component cmptype="Script">
<![CDATA[
    Form.EMPTY_VAR_ACTION = {
        'getDefaultValues':{'VARS':'','TYPE':'','DS':''},
        'getLpuInfo':{'VARS':'','TYPE':'','DS':''},
        'getPMCInfo':{'VARS':'REP_PATIENT_ID','TYPE':'','DS':''},
        'getAmbTalonData':{'VARS':'REP_AMB_TALON_ID','TYPE':'','DS':''},
        'getAmbTalonMKBData':{'VARS':'REP_AMB_TALON_ID','TYPE':'','DS':''},
        'getDataByDS':{'VARS':'REP_DS_ID','TYPE':'','DS':''},
        'getDirectionFromHC':{'VARS':'REP_HC_ID','TYPE':'','DS':''},
        'getHCData':{'VARS':'REP_HC_ID','TYPE':'','DS':''}
    }
    Form.SetAcion = function(name,set_ds,func){
        var arr = Form.EMPTY_VAR_ACTION[name]['VARS'].split(';');
        var vars = 0;
        for(var i = 0,len = arr.length; i < len;i++){
            if(arr[i] == '' && arr.length == 1){
                vars = arr.length;
                break;
            } else {
                if(Form.empty(getVar(arr[i]))){

                    if(Form.EMPTY_VAR_ACTION[name]['TYPE'] == 'or'){
                        vars = arr.length;
                        break;
                    } else {
                        ++vars;
                    }
                }
                if(Form.EMPTY_VAR_ACTION[name]['TYPE'] == 'and'){
                    vars = 0;
                    break;
                }
            }
        }
        
        if(vars === arr.length){
            executeAction(name,function(){
                if(set_ds === true){
                    startMultiDataSetsGroup();
                        Form.EMPTY_VAR_ACTION[name]['VARS']['DS'].split(';').forEach(function(e){
                            refreshDataSet(e)
                        })
                    endMultiDataSetsGroup();
                }
                if(typeof func == 'function'){
                    func();
                }
            })
        }
    }
    Form.empty = function(name){
        if((typeof name == 'string' && name != 'null' && name != 'undefined' && name != '') || (typeof name == 'undefined') ){
            return true
        }
        else{
            return false
        }
    }
    Form.OnCreate=function()
    {
        setVar('REP_DS_ID', $_GET['REP_DS_ID']);
        setVar('REP_PATIENT_ID', $_GET['REP_PATIENT_ID']);
        setVar('REP_AMB_TALON_ID', $_GET['REP_AMB_TALON_ID']);
        setVar('REP_HC_ID', $_GET['REP_HC_ID']);
        setVar('REP_VISIT_ID', $_GET['REP_VISIT_ID']);
        // для печати с визита
        if(Form.empty(getVar('REP_VISIT_ID')))
        {
            if((typeof getVar('REP_VISIT_ID') == 'string' && (getVar('REP_VISIT_ID') == 'null' || getVar('REP_VISIT_ID') == 'undefined' && getVar('REP_VISIT_ID') == ''))){
                setVar('REP_VISIT_ID', $_GET['VISIT']);
            }
            Form.SetAcion('getDefaultValues',false,function(){
                Form.getData('AMB_TALON');
            })
        }
        else if(Form.empty(getVar('REP_HC_ID')))
        {
            Form.SetAcion('getDirectionFromHC',false,function(){
                Form.SetAcion('getDefaultValues',false,function(){
                    Form.getData('HOME_CALL');
                })
            })
        }else{
            Form.SetAcion('getDefaultValues',false,function(){
                Form.getData();
            })
        }
    }
    /*
        CUSTOM_DATE:
            для ТАП: D_AMB_TALONS.AT_DATE
            для регистрации вызова: D_HOME_CALL_JOUR.REG_TIME
            для направления: D_DIRECTIONS.REG_DATE
            иначе: sysdate
    */
    Form.setRefreshDataSets = function(){
        startMultiDataSetsGroup();
            refreshDataSet('DS_PMC_FEDERAL_PRIVS');
            refreshDataSet('DS_VIS_EMPLOYERS');
            refreshDataSet('DS_VIS_SERVICES');
            refreshDataSet('DS_AMB_SOP_MKBS');
            refreshDataSet('DS_AMB_OPERATIONS');
            refreshDataSet('DS_AMB_MANIPULATIONS');
            refreshDataSet('DS_AMB_RECIPES');
            refreshDataSet('DS_REZ');
            refreshDataSet('DS_AMB_BULLETINS');
            refreshDataSet('DS_AMB_BULL_CONTS');
            refreshDataSet('DS_AMB_TALON_VISITS');
        endMultiDataSetsGroup();
    }
    Form.getData = function(_source)
    {
        Form.SetAcion('getLpuInfo',false,function(){
            if(!empty(getVar('REP_HC_ID'))){
               setTimeout(function(){
                   window.status = "PRINT";
               }, 1000);
            }
        });

        if(_source == 'AMB_TALON'){
            Form.SetAcion('getAmbTalonData',false,function(){
                Form.setRefreshDataSets();
                Form.SetAcion('getPMCInfo',false);
            });
        } else if(_source == 'HOME_CALL') {
            Form.SetAcion('getHCData',false);
        } else {
            Form.SetAcion('getDataByDS',false);
        }

        Form.SetAcion('getAmbTalonMKBData',false);
        if(empty(getVar('REP_AMB_TALON_ID'))){
            setTimeout(function(){
               Form.SetAcion('getPMCInfo',false);
           }, 1000);
        }
        if(Form.empty(getVar('REP_HC_ID')))
        {
            Form.SetAcion('getPMCInfo',false);
            startMultiDataSetsGroup();
                refreshDataSet('DS_PMC_FEDERAL_PRIVS');
                refreshDataSet('DS_VIS_EMPLOYERS');
                refreshDataSet('DS_VIS_SERVICES');
            endMultiDataSetsGroup();
        }else{
            if(Form.empty(getVar('REP_DS_ID')) || Form.empty(getVar('REP_PATIENT_ID'))){
                if(empty(getVar('PatId')) || !empty(getVar('REP_PATIENT_ID'))){
                    setVar('PatId', getVar('REP_PATIENT_ID'));
                }
                if(Form.empty(getVar('REP_DS_ID'))){
                    startMultiDataSetsGroup();
                        refreshDataSet('DS_PMC_FEDERAL_PRIVS');
                        refreshDataSet('DS_VIS_EMPLOYERS');
                        refreshDataSet('DS_VIS_SERVICES');
                    endMultiDataSetsGroup();
                } 
            }
        }
        if(!Form.empty(getVar('REP_HC_ID')) && !Form.empty(getVar('REP_DS_ID')) && !Form.empty(getVar('REP_PATIENT_ID')) && !Form.empty(getVar('REP_AMB_TALON_ID'))){
            Form.afterRefreshDataset('DS_PMC_FEDERAL_PRIVS', 'inline');
            Form.afterRefreshDataset('DS_VIS_EMPLOYERS');
            Form.afterRefreshDataset('DS_VIS_SERVICES');
        }
    }
    Form.showEmptyGraphs = function()
    {
        Form.afterRefreshDataset('DS_AMB_SOP_MKBS');
        Form.afterRefreshDataset('DS_AMB_OPERATIONS');
        Form.afterRefreshDataset('DS_AMB_MANIPULATIONS');
        Form.afterRefreshDataset('DS_AMB_RECIPES');
         Form.afterRefreshDataset('DS_REZ');
        Form.afterRefreshDataset('DS_AMB_BULLETINS');
        Form.afterRefreshDataset('DS_AMB_TALON_VISITS')
    }
    Form.onCloneAmbTalonVisits = function(_data)
    {
        var ds = getDataSet('DS_AMB_TALON_VISITS').data;

        if(_data['PAGE'] > 0)
        {
            getControl('AMB_VIS_HEADER').style.display = 'none';
        }

        if(ds.length > 7)
        {
            getControl('AMB_VIS_HEADER').rowSpan = 2;
        }
    }
    Form.afterRefreshAmbTalonVisits = function()
    {
        if(typeof getDataSet('DS_AMB_TALON_VISITS').data == 'undefined' || (getDataSet('DS_AMB_TALON_VISITS').data.length == 0))
        {

            getControl('DS_AMB_TALON_VISITS_DUMMY').style.display = '';
        }
        else
        {
            getControl('DS_AMB_TALON_VISITS_DUMMY').style.display = 'none';
            var ds = getDataSet('DS_AMB_TALON_VISITS').data;
            _dom = document.querySelector('#amb_talon_visits_table');

            if(ds.length < 8)
            {
                // fill first row
                _dom = _dom.querySelectorAll('tr')[0];

                while(_dom.childElementCount < 8)
                {
                    var td = document.createElement('td');
                    _dom.appendChild(td);
                }

                // add and fill second row
                var tr = document.createElement('tr');
                _dom.parentNode.appendChild(tr);

                document.querySelectorAll('[name="AMB_VIS_HEADER"]')[0].rowSpan = 2;

                while(tr.childElementCount < 7)
                {
                    var td = document.createElement('td');
                    tr.appendChild(td);
                }
            }

            // fill second row
            if(ds.length > 7 && ds.length < 14)
            {
                _dom = _dom.querySelectorAll('tr')[1];

                while(_dom.childElementCount < 8)
                {
                    var td = document.createElement('td');
                    _dom.appendChild(td);
                }
            }
        }
    }
    Form.onCloneDatasetRow = function(_data, _num_clone,_clone)
    {
        if(_data['R_NUM'] != 1)
        {
            setCaption(_num_clone, '');
        }
    }
    Form.afterRefreshDataset = function(_dataset, _style)
    {
        _style = _style||'';
        if(typeof getDataSet(_dataset).data == 'undefined' || (getDataSet(_dataset).data.length == 0))
        {
            getControl(_dataset + '_DUMMY').style.display = _style;
           // getControl(_dataset).style.display = 'none';
           // console.log(getControl(_dataset))
        }
    }
]]>
</component>
<!--    End Script    -->

<!--    Begin Actions    -->
<component cmptype="Action" name="getDefaultValues">
    begin
        :DATE_RB_RE_CONS := d_pkg_option_specs.get('RecipsDateRbReConsider', :LPU);
        :VISIT_PLACE_HC_OPTION := d_pkg_option_specs.get('VisitPlaceForCallToHome', :LPU);
        :PAYMENT_KIND_HC_OPTION := d_pkg_option_specs.get('PaymentKindForCallToHome', :LPU);
        :CUSTOM_DATE := sysdate;
        :REP_DS_ID := :REP_DS_ID;
        if :REP_PATIENT_ID = 'null' then
            :REP_PATIENT_ID := null;
        else
            :REP_PATIENT_ID := :REP_PATIENT_ID;
        end if;


        if :REP_VISIT_ID is not null and :REP_VISIT_ID != 'null' then
            begin
                select t.PID,
                       coalesce(t2.PATIENT_ID,to_number(:REP_PATIENT_ID))
                  into :REP_DS_ID,
                       :REP_PATIENT_ID
                  from D_V_VISITS t,
                       D_V_DIRECTION_SERVICES t1,
                       D_V_DIRECTIONS t2
                 where t.PID = t1.ID
                   and t1.PID = t2.ID
                   and t.ID = :REP_VISIT_ID;
           end;
        end if;

        if :REP_DS_ID is not null and :REP_DS_ID != 'null' then
            if :REP_AMB_TALON_ID_IN is null or :REP_AMB_TALON_ID_IN = 'null' then
                :REP_AMB_TALON_ID := D_PKG_AMB_TALONS.GET_AMB_TALON(:LPU,:REP_DS_ID);
            else
                :REP_AMB_TALON_ID := :REP_AMB_TALON_ID_IN;
            end if;
        else
            :REP_AMB_TALON_ID := :REP_AMB_TALON_ID_IN;
        end if;
    end;
    <component cmptype="ActionVar" name="LPU" src="LPU" srctype="session" get="v0"/>
    <component cmptype="ActionVar" name="REP_DS_ID" src="REP_DS_ID" srctype="var" get="vREP_DS_ID"/>
    <component cmptype="ActionVar" name="REP_PATIENT_ID" src="REP_PATIENT_ID" srctype="var" get="vREP_PATIENT_ID"/>
    <component cmptype="ActionVar" name="DATE_RB_RE_CONS" src="DATE_RB_RE_CONS" srctype="var" put="v1" len="10"/>
    <component cmptype="ActionVar" name="CUSTOM_DATE" src="CUSTOM_DATE" srctype="var" put="v2" len="20"/>
    <component cmptype="ActionVar" name="VISIT_PLACE_HC_OPTION" src="VISIT_PLACE_HC_OPTION" srctype="var" put="v3" len="10"/>
    <component cmptype="ActionVar" name="PAYMENT_KIND_HC_OPTION" src="PAYMENT_KIND_HC_OPTION" srctype="var" put="v4" len="10"/>
    <component cmptype="ActionVar" name="REP_AMB_TALON_ID_IN" src="REP_AMB_TALON_ID" srctype="var" get="v5"/>
    <component cmptype="ActionVar" name="REP_VISIT_ID" src="REP_VISIT_ID" srctype="var" get="v6"/>
    <component cmptype="ActionVar" name="REP_AMB_TALON_ID" src="REP_AMB_TALON_ID" srctype="var" put="v7" len="17"/>
    <component cmptype="ActionVar" name="REP_DS_ID" src="REP_DS_ID" srctype="var" put="v8"  len="17"/>
    <component cmptype="ActionVar" name="REP_PATIENT_ID" src="REP_PATIENT_ID" srctype="var" put="v9"  len="17"/>
</component>

<component cmptype="Action" name="getLpuInfo">
        begin
        if :REP_HC_ID is not null and :REP_HC_ID != 'null' then
            select t2.FULLNAME,
                   t2.FULLADDRESS
           into :FULLNAME,
                :FULLADDRESS
              from D_V_HOME_CALL_JOUR t,
                   D_V_LPU t2
             where t.id = :REP_HC_ID
               and t2.id = t.lpu;
        else
            select d.FULLNAME,
                   d.FULLADDRESS
              into :FULLNAME,
                   :FULLADDRESS
              from D_V_LPU d
             where d.ID = :LPU;
        end if;
        end;
    <component cmptype="ActionVar" name="LPU" src="LPU" srctype="session"/>
    <component cmptype="ActionVar" name="REP_HC_ID" src="REP_HC_ID" srctype="var" get="g0"/>
    <component cmptype="ActionVar" name="FROM_HC" src="FROM_HC" srctype="var" get="g1"/>
    <component cmptype="ActionVar" name="FULLNAME" src="FULLNAME:caption" srctype="ctrl" put="p3" len="500"/>
    <component cmptype="ActionVar" name="FULLADDRESS" src="FULLADDRESS:caption" srctype="ctrl" put="p4" len="500"/>
</component>

<component cmptype="Action" name="getPMCInfo">
    <![CDATA[
    declare
        sSOC_STATES_WO_CODE VARCHAR2(4000);
    begin
        begin
            select t.CARD_NUMB,
                   D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, 0, 'P_SER'),
                   D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, 0, 'P_NUM'),
                   nvl(t2.S_NAME, t2.IC_NAME),
                   t.SNILS,
                   t.SURNAME,
                   t.FIRSTNAME,
                   t.LASTNAME,
                   case when t.NSEX = 1 then 'муж - 1'
                        when t.NSEX = 0 then 'жен - 2'
                   end,
                   to_char(t.BIRTHDATE, 'dd'),
                   D_PKG_DAT_TOOLS.DATE_TO_CHAR(t.BIRTHDATE, 'MONTH'),
                   to_char(t.BIRTHDATE, 'yyyy'),
                   D_PKG_AGENT_PERSDOCS.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, 'PD_TYPE_NAME'),
                   D_PKG_AGENT_PERSDOCS.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, 'PD_SER'),
                   D_PKG_AGENT_PERSDOCS.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, 'PD_NUMB'),
                   D_PKG_AGENT_ADDRS.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, 1, 'FULL'),
                   D_PKG_AGENT_CONTACTS.GET_ACTUAL_PHONE(t.AGENT, 'PHONE', 2) PHONE,
                   case when D_PKG_AGENT_ADDRS.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, 1, 'IS_CITIZEN') = 1 then 'городская – 1'
                        when D_PKG_AGENT_ADDRS.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, 1, 'IS_CITIZEN') = 0 then 'сельская – 2'
                   end,
                   case when D_PKG_AGENT_SOCIAL_STATES.GET_ACTUAL_ON_DATE(t.AGENT,  to_date(sysdate), 'SOCIAL_CATEGORY') = 0  then 'работает'
                            when D_PKG_AGENT_SOCIAL_STATES.GET_ACTUAL_ON_DATE(t.AGENT,  to_date(sysdate), 'SOCIAL_CATEGORY') = 1  then 'не работает'
                            when D_PKG_AGENT_SOCIAL_STATES.GET_ACTUAL_ON_DATE(t.AGENT,  to_date(sysdate), 'SOCIAL_CATEGORY') = 2  then 'учащийся'
                   end SOC_STATES,

                   (select d_stragg(v3.DD_NAME)
                      from D_V_AGENT_SOCIAL_STATES v,
                           D_V_SOCIALSTATES v2,
                           D_V_DIRECTORIES_FN_DATA v3
                     where v.PID = t.AGENT
                       and v2.ID = v.SOCIAL_STATE_ID
                       and v3.DD_CODE = v2.SOC_FCODE
                       and v3.DIR = '41'
                       and v.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'AGENT_SOCIAL_STATES')
                       and v2.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'SOCIALSTATES')
                       and v3.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DIRECTORIES_FN_DATA')) SOC_STATES_WO_CODE,
                   nvl(D_PKG_AGENT_WORK_PLACES.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, 'WORK_PLACE_NAME'),
                       D_PKG_AGENT_WORK_PLACES.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, 'WORK_PLACE_HAND'))||
                       D_PKG_AGENT_WORK_PLACES.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, ', JOBTITLE_TITLE') WORK_PLACE,
                   case when D_PKG_AGENT_INABILITIES.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, 'INABILITY_STATUS_CODE') = 2 then 'установлена  впервые – 1'
                        when D_PKG_AGENT_INABILITIES.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, 'INABILITY_STATUS_CODE') = 1 then 'повторно – 2'
                   end,
                   D_PKG_AGENT_INABILITIES.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, 'INABILITY_GROUP'),
                   case when D_PKG_AGENT_INABILITIES.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, 'INABILITY_TYPE_CODE') = 1 then 'да - 1'
                        else 'нет - 2'
                   end,
                   D_PKG_DAT_TOOLS.FULL_YEARS(:CUSTOM_DATE, t.BIRTHDATE)
              into :CARD_NUMB,
                   :P_SER,
                   :P_NUM,
                   :P_WHO,
                   :SNILS,
                   :SURNAME,
                   :FIRSTNAME,
                   :LASTNAME,
                   :SEX,
                   :BIRTHDATE_DAY,
                   :BIRTHDATE_MONTH,
                   :BIRTHDATE_YEAR,
                   :PD_TYPE_NAME,
                   :PD_SER,
                   :PD_NUMB,
                   :PMC_FULL_ADDR,
                   :PMC_PHONES,
                   :IS_CITIZEN,
                   :SOC_STATES,
                   sSOC_STATES_WO_CODE,
                   :WORK_PLACE,
                   :INABILITY_STATUS,
                   :INABILITY_GROUP,
                   :INABILITY_TYPE,
                   :AGE
              from D_V_PERSMEDCARD t
         left join D_V_INSURANCE_COMPANIES t2
                on t2.ID = D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(t.AGENT, :CUSTOM_DATE, 0, 'P_WHO')
             where t.ID = :REP_PATIENT_ID;
        exception when no_data_found then
            null;
        end;

        if :AGE < 18 then
            :WORK_PLACE := sSOC_STATES_WO_CODE;
            :SOC_STATES := null;
        end if;
    end;
    ]]>
    <component cmptype="ActionVar" name="LPU" src="LPU" srctype="session" get="LPU"/>
    <component cmptype="ActionVar" name="REP_PATIENT_ID" src="REP_PATIENT_ID" srctype="var" get="v0"/>
    <component cmptype="ActionVar" name="CUSTOM_DATE" src="CUSTOM_DATE" srctype="var" get="v1"/>
    <component cmptype="ActionVar" name="CARD_NUMB" src="CARD_NUMB:caption" srctype="ctrl" put="v2" len="50"/>
    <component cmptype="ActionVar" name="P_SER" src="P_SER:caption" srctype="ctrl" put="v3" len="50"/>
    <component cmptype="ActionVar" name="P_NUM" src="P_NUM:caption" srctype="ctrl" put="v4" len="50"/>
    <component cmptype="ActionVar" name="P_WHO" src="P_WHO:caption" srctype="ctrl" put="v5" len="2000"/>
    <component cmptype="ActionVar" name="SNILS" src="SNILS:caption" srctype="ctrl" put="v6" len="11"/>
    <component cmptype="ActionVar" name="SURNAME" src="SURNAME:caption" srctype="ctrl" put="v7" len="40"/>
    <component cmptype="ActionVar" name="FIRSTNAME" src="FIRSTNAME:caption" srctype="ctrl" put="v8" len="40"/>
    <component cmptype="ActionVar" name="LASTNAME" src="LASTNAME:caption" srctype="ctrl" put="v9" len="40"/>
    <component cmptype="ActionVar" name="SEX" src="SEX:caption" srctype="ctrl" put="v10" len="7"/>
    <component cmptype="ActionVar" name="BIRTHDATE_DAY" src="BIRTHDATE_DAY:caption" srctype="ctrl" put="v11" len="2"/>
    <component cmptype="ActionVar" name="BIRTHDATE_MONTH" src="BIRTHDATE_MONTH:caption" srctype="ctrl" put="v12" len="20"/>
    <component cmptype="ActionVar" name="BIRTHDATE_YEAR" src="BIRTHDATE_YEAR:caption" srctype="ctrl" put="v13" len="4"/>
    <component cmptype="ActionVar" name="PD_TYPE_NAME" src="PD_TYPE_NAME:caption" srctype="ctrl" put="v14" len="160"/>
    <component cmptype="ActionVar" name="PD_SER" src="PD_SER:caption" srctype="ctrl" put="v15" len="50"/>
    <component cmptype="ActionVar" name="PD_NUMB" src="PD_NUMB:caption" srctype="ctrl" put="v16" len="50"/>
    <component cmptype="ActionVar" name="PMC_FULL_ADDR" src="PMC_FULL_ADDR:caption" srctype="ctrl" put="v17" len="4000"/>
    <component cmptype="ActionVar" name="PMC_PHONES" src="PMC_PHONES:caption" srctype="ctrl" put="v18" len="4000"/>
    <component cmptype="ActionVar" name="IS_CITIZEN" src="IS_CITIZEN:caption" srctype="ctrl" put="v19" len="100"/>
    <component cmptype="ActionVar" name="SOC_STATES" src="SOC_STATES:caption" srctype="ctrl" put="v20" len="4000"/>
    <component cmptype="ActionVar" name="WORK_PLACE" src="WORK_PLACE:caption" srctype="ctrl" put="v21" len="4000"/>
    <component cmptype="ActionVar" name="INABILITY_STATUS" src="INABILITY_STATUS:caption" srctype="ctrl" put="v22" len="100"/>
    <component cmptype="ActionVar" name="INABILITY_GROUP" src="INABILITY_GROUP:caption" srctype="ctrl" put="v23" len="50"/>
    <component cmptype="ActionVar" name="INABILITY_TYPE" src="INABILITY_TYPE:caption" srctype="ctrl" put="v24" len="50"/>
    <component cmptype="ActionVar" name="AGE" src="AGE" srctype="var" put="v25" len="5"/>
</component>

<component cmptype="Action" name="getAmbTalonData">
    declare
        dAMB_DATE_END DATE;
    begin
        begin 
            select 
                  t.PERSMEDCARD,
                   t.AT_DATE,
                   to_char(t2.VIS_DATE, 'dd'),
                   D_PKG_DAT_TOOLS.DATE_TO_CHAR(t2.VIS_DATE, 'MONTH'),
                   to_char(t2.VIS_DATE, 'yyyy'),
                   (select d_stragg(v.DD_NAME ||' - '|| v.DD_CODE)
                      from D_V_DIRECTORIES_FN_DATA v
                     where v.DD_CODE = t2.MED_CARE_KIND
                       and v.DIR = '42'
                       and v.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DIRECTORIES_FN_DATA')),
                   case when t2.VIS_PLACE_FCODE = 1 then 'поликлиника – 1'
                        when t2.VIS_PLACE_FCODE = 2 then 'на дому – 2'
                        else
                            case when t3.DP_TYPE = 9 then 'центр здоровья – 3'
                            else 'иные медицинские организации – 4'
                            end
                   end,
                   case when t2.VIS_PURPOSE_TYPE = 1 then 'по заболеваниям (коды A00-T98) – 1'
                        when t2.VIS_PURPOSE_TYPE = 2 then 'с профилактической и иными целями (коды Z00-Z99) – 2'
                   end,
                   (select d_stragg(v.DD_NAME ||' - '|| v.DD_CODE)
                      from D_V_DIRECTORIES_FN_DATA v,
                           D_V_VISITPURPOSES v2
                     where v.DD_CODE = v2.VP_FCODE
                       and v2.ID = t2.VIS_PURPOSE_ID
                       and v.DIR = '43'
                       and v.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DIRECTORIES_FN_DATA')
                       and v2.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'VISITPURPOSES')),
                   case when t2.VIS_PURPOSE_TYPE = 1 then 'по заболеваниям (коды A00-T98) – 1'
                        when t2.VIS_PURPOSE_TYPE = 2 then 'с профилактической и иными целями (коды Z00-Z99) – 2'
                   end,
                   case when t.DC_IS_CLOSE = 0 then 'нет - 2'
                        when t.DC_IS_CLOSE = 1 then 'да - 1'
                   end,
                   case when t2.VIS_IS_PRIMARY = 1 then 'первичное - 1'
                        when t2.VIS_IS_PRIMARY = 2 then 'повторное - 2'
						
                   end,
                   (select d_stragg(v.DD_NAME ||' - '|| v.DD_CODE)
                      from D_V_DIRECTORIES_FN_DATA v,
                           D_V_VISITRESULTS v2
                     where v.DD_CODE = v2.VR_FCODE
                       and v2.ID = t4.VIS_RESULT_ID
                       and v.DIR = '44'
                       and v.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DIRECTORIES_FN_DATA')
                       and v2.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'VISITRESULTS')),
                   (select d_stragg(v.DD_NAME ||' - '|| v.DD_CODE)
                      from D_V_DIRECTORIES_FN_DATA v,
                           D_V_REFERENCE_RESULTS v2
                     where v.DD_CODE = v2.RR_FCODE
                       and v2.ID = t4.VIS_REF_RESULT_ID
                       and v.DIR = '45'
                       and v.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DIRECTORIES_FN_DATA')
                       and v2.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'REFERENCE_RESULTS')),
                   (select d_stragg(v.DD_NAME ||' - '|| v.DD_CODE)
                      from D_V_DIRECTORIES_FN_DATA v,
                           D_V_PAYMENT_KIND v2
                     where v.DD_CODE = v2.PK_FCODE
                       and v2.ID = t2.VIS_PAYMENT_KIND_ID
                       and v.DIR = '46'
                       and v.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DIRECTORIES_FN_DATA')
                       and v2.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'PAYMENT_KIND'))
              into :REP_PATIENT_ID,
                   :CUSTOM_DATE,
                   :REG_DATE_DAY,
                   :REG_DATE_MONTH,
                   :REG_DATE_YEAR,
                   :MED_CARE_KINDS,
                   :VIS_PLACE,
                   :VIS_PURPOSE,
                   :VIS_PURPOSE_DETAIL,
                   :VIS_PURPOSE_2,
                   :DC_IS_CLOSE,
                   :VIS_IS_PRIMARY,
                   :VIS_RESULTS,
                   :VIS_REF_RESULTS,
                   :VIS_PAYMENT_KINDS
                  
              from D_V_AMB_TALONS t
        left join D_V_AMB_TALON_VISITS t4 -- последний визит
               on t4.PID = t.ID 
                  and t4.IS_LAST in (3,4)
        left join D_V_AMB_TALON_VISITS t2 -- первый визит
               on t2.PID = t.ID
                  and (t2.IS_FIRST in (3, 4) and rownum = 1)
                  left join D_V_DEPS t3
                         on t3.ID = t2.VIS_DEP_ID
             where t.ID = :REP_AMB_TALON_ID;
        exception when no_data_found then
            null;
        end;

        begin
            select case when t.IS_CLOSE = 1 then t.END_DATE else null end
              into dAMB_DATE_END
              from D_V_AMB_TALONS t
             where t.ID = :REP_AMB_TALON_ID;
        exception when no_data_found then
            null;
        end;

        if dAMB_DATE_END is not null then
            :AMB_DATE_END_DAY := to_char(dAMB_DATE_END, 'dd');
            :AMB_DATE_END_MONTH := D_PKG_DAT_TOOLS.DATE_TO_CHAR(dAMB_DATE_END, 'MONTH');
            :AMB_DATE_END_YEAR := to_char(dAMB_DATE_END, 'yyyy');

            begin
                select t2.SURNAME || ' ' || t2.FIRSTNAME || ' ' || t2.LASTNAME
                  into :AMB_TALON_EMPLOYER
                  from D_V_AMB_TALON_VISITS t,
                       D_V_EMPLOYERS t2
                 where t.PID = :REP_AMB_TALON_ID
                   and t2.ID = t.VIS_EMPLOYER_ID
                   and t.IS_LAST in (3,4);
            exception when no_data_found then
                :AMB_TALON_EMPLOYER := null;
            end;
        end if;
    end;
    <component cmptype="ActionVar" name="LPU" src="LPU" srctype="session" get="LPU"/>
    <component cmptype="ActionVar" name="REP_AMB_TALON_ID" src="REP_AMB_TALON_ID" srctype="var" get="v0"/>
    <component cmptype="ActionVar" name="REG_DATE_DAY" src="REG_DATE_DAY:caption" srctype="ctrl" put="v1" len="2"/>
    <component cmptype="ActionVar" name="REG_DATE_MONTH" src="REG_DATE_MONTH:caption" srctype="ctrl" put="v2" len="20"/>
    <component cmptype="ActionVar" name="REG_DATE_YEAR" src="REG_DATE_YEAR:caption" srctype="ctrl" put="v3" len="4"/>
    <component cmptype="ActionVar" name="REP_PATIENT_ID" src="REP_PATIENT_ID" srctype="var" put="v4" len="17"/>
    <component cmptype="ActionVar" name="CUSTOM_DATE" src="CUSTOM_DATE" srctype="var" put="v5" len="20"/>
    <component cmptype="ActionVar" name="MED_CARE_KINDS" src="MED_CARE_KINDS:caption" srctype="ctrl" put="v6" len="4000"/>
    <component cmptype="ActionVar" name="VIS_PLACE" src="VIS_PLACE:caption" srctype="ctrl" put="v7" len="40"/>
    <component cmptype="ActionVar" name="VIS_PURPOSE" src="VIS_PURPOSE:caption" srctype="ctrl" put="v8" len="100"/>
    <component cmptype="ActionVar" name="VIS_PURPOSE_DETAIL" src="VIS_PURPOSE_DETAIL:caption" srctype="ctrl" put="v9" len="4000"/>
    <component cmptype="ActionVar" name="VIS_PURPOSE_2" src="VIS_PURPOSE_2:caption" srctype="ctrl" put="v10" len="100"/>
    <component cmptype="ActionVar" name="DC_IS_CLOSE" src="DC_IS_CLOSE:caption" srctype="ctrl" put="v11" len="50"/>
    <component cmptype="ActionVar" name="VIS_IS_PRIMARY" src="VIS_IS_PRIMARY:caption" srctype="ctrl" put="v12" len="50"/>
    <component cmptype="ActionVar" name="VIS_RESULTS" src="VIS_RESULTS:caption" srctype="ctrl" put="v13" len="4000"/>
    <component cmptype="ActionVar" name="VIS_REF_RESULTS" src="VIS_REF_RESULTS:caption" srctype="ctrl" put="v14" len="4000"/>
    <component cmptype="ActionVar" name="VIS_PAYMENT_KINDS" src="VIS_PAYMENT_KINDS:caption" srctype="ctrl" put="v15" len="4000"/>
    <component cmptype="ActionVar" name="AMB_DATE_END_DAY" src="AMB_DATE_END_DAY:caption" srctype="ctrl" put="v16" len="2"/>
    <component cmptype="ActionVar" name="AMB_DATE_END_MONTH" src="AMB_DATE_END_MONTH:caption" srctype="ctrl" put="v17" len="20"/>
    <component cmptype="ActionVar" name="AMB_DATE_END_YEAR" src="AMB_DATE_END_YEAR:caption" srctype="ctrl" put="v18" len="4"/>
    <component cmptype="ActionVar" name="AMB_TALON_EMPLOYER" src="AMB_TALON_EMPLOYER:caption" srctype="ctrl" put="v19" len="150"/>
</component>

<component cmptype="Action" name="getAmbTalonMKBData">
    begin
        begin
            select t.MKB_NAME,
                   t.MKB,
                   t.EX_CAUSE_MKB_NAME,
                   t.EX_CAUSE_MKB
              into :PRE_MKB_NAME,
                   :PRE_MKB,
                   :PRE_EX_CAUSE_MKB_NAME,
                   :PRE_EX_CAUSE_MKB
	      from (select t.MKB_NAME,
			   t.MKB,
			   t.EX_CAUSE_MKB_NAME,
			   t.EX_CAUSE_MKB,
			   ROW_NUMBER() over (partition by t.PID order by t3.VISIT_DATE) RN
		      from D_V_AMB_TALON_MKBS t
			   join D_V_VIS_DIAGNOSISES t2
			     on t2.ID = t.DIAGNOSIS
			        and t2.STAGE = 2
			        join D_V_VISITS_BASE t3
				  on t2.PID = t3.ID
		     where t.PID = :REP_AMB_TALON_ID) t
	     where t.RN = 1;
        exception when no_data_found then
            null;
        end;

        begin
            select t.MKB_NAME,
                   t.MKB,
                   t.EX_CAUSE_MKB_NAME,
                   t.EX_CAUSE_MKB,
                   t2.DT_NAME,
                   case when t3.COC_TYPE = 1 then 'состоит – 1'
                        when t3.COC_TYPE = 2 then 'взят – 2'
                        when t3.COC_TYPE = 3 then 'снят – 3'
                   end,
                   (select d_stragg(v.DD_NAME ||' - '|| v.DD_CODE)
                      from D_V_DIRECTORIES_FN_DATA v,
                           D_V_CL_OBSERV_CATEGORIES v2
                     where v.DD_CODE = v2.COC_FCODE
                       and v2.ID = t.CL_OBSERV_CATEGORY_ID
                       and v.DIR = '47'
                       and t3.COC_TYPE = 3
                       and v.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DIRECTORIES_FN_DATA')
                       and v2.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'CL_OBSERV_CATEGORIES')),
                   (select d_stragg(v.DD_NAME ||' - '|| v.DD_CODE)
                      from D_V_DIRECTORIES_FN_DATA v,
                           D_V_INJURE_KINDS v2
                     where v.DD_CODE = v2.IK_FCODE
                       and v2.ID = t.INJURE_KIND_ID
                       and v.DIR = '48'
                       and v.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DIRECTORIES_FN_DATA')
                       and v2.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'INJURE_KINDS'))
              into :FIN_DIAG_NAME,
                   :FIN_DIAG,
                   :FIN_EX_CAUSE_MKB_NAME,
                   :FIN_EX_CAUSE_MKB,
                   :FIN_DT_NAME,
                   :COC_TYPE,
                   :COC_TYPE_DATA,
                   :INJURE_KIND_DATA
              from D_V_AMB_TALON_MKBS t
         left join D_V_DISEASECHARACTERS t2
                on t2.ID = t.DIS_CHARACTER_ID
         left join D_V_CL_OBSERV_CATEGORIES t3
                on t3.ID = t.CL_OBSERV_CATEGORY_ID
             where t.PID = :REP_AMB_TALON_ID
               and t.IS_MAIN_ID = 0
               and t.IS_VISIBLE = 1;
        exception when no_data_found then
            null;
        end;
    end;
    <component cmptype="ActionVar" name="LPU" src="LPU" srctype="session" get="LPU"/>
    <component cmptype="ActionVar" name="REP_AMB_TALON_ID" src="REP_AMB_TALON_ID" srctype="var" get="v0"/>
    <component cmptype="ActionVar" name="PRE_MKB_NAME" src="PRE_MKB_NAME:caption" srctype="ctrl" put="v1" len="500"/>
    <component cmptype="ActionVar" name="PRE_MKB" src="PRE_MKB:caption" srctype="ctrl" put="v2" len="10"/>
    <component cmptype="ActionVar" name="PRE_EX_CAUSE_MKB_NAME" src="PRE_EX_CAUSE_MKB_NAME:caption" srctype="ctrl" put="v3" len="500"/>
    <component cmptype="ActionVar" name="PRE_EX_CAUSE_MKB" src="PRE_EX_CAUSE_MKB:caption" srctype="ctrl" put="v4" len="10"/>
    <component cmptype="ActionVar" name="FIN_DIAG_NAME" src="FIN_DIAG_NAME:caption" srctype="ctrl" put="v5" len="500"/>
    <component cmptype="ActionVar" name="FIN_DIAG" src="FIN_DIAG:caption" srctype="ctrl" put="v6" len="10"/>
    <component cmptype="ActionVar" name="FIN_EX_CAUSE_MKB_NAME" src="FIN_EX_CAUSE_MKB_NAME:caption" srctype="ctrl" put="v7" len="500"/>
    <component cmptype="ActionVar" name="FIN_EX_CAUSE_MKB" src="FIN_EX_CAUSE_MKB:caption" srctype="ctrl" put="v8" len="10"/>
    <component cmptype="ActionVar" name="FIN_DT_NAME" src="FIN_DT_NAME:caption" srctype="ctrl" put="v9" len="160"/>
    <component cmptype="ActionVar" name="COC_TYPE" src="COC_TYPE:caption" srctype="ctrl" put="v10" len="150"/>
    <component cmptype="ActionVar" name="COC_TYPE_DATA" src="COC_TYPE_DATA:caption" srctype="ctrl" put="v11" len="4000"/>
    <component cmptype="ActionVar" name="INJURE_KIND_DATA" src="INJURE_KIND_DATA:caption" srctype="ctrl" put="v12" len="4000"/>
</component>

<component cmptype="Action" name="getDataByDS">
    begin
        select t.PATIENT,
               t2.REG_DATE,
               to_char(t2.REG_DATE, 'dd'),
               D_PKG_DAT_TOOLS.DATE_TO_CHAR(t2.REG_DATE, 'MONTH'),
               to_char(t2.REG_DATE, 'yyyy'),
               case when dc.IS_CLOSE = 1 then 'да - 1' else 'нет – 2' end,
               case when t3.VP_TYPE = 1 then 'по заболеванию (коды A00-T98) – 1'
                    when t3.VP_TYPE = 2 then 'с профилактической целью (коды Z00-Z99) – 2'
               end,
               case when t.IS_PRIMARY = 1 then 'первичное – 1'
                    when t.IS_PRIMARY = 0 then 'повторное – 2'
               end,
               case when t3.VP_TYPE = 1 then 'по заболеваниям (коды A00-T98) – 1'
                    when t3.VP_TYPE = 2 then 'с профилактической и иными целями (коды Z00-Z99) – 2'
               end,
               (select d_stragg(v.DD_NAME ||' - '|| v.DD_CODE)
                  from D_V_DIRECTORIES_FN_DATA v,
                       D_V_VISITPURPOSES v2
                 where v.DD_CODE = v2.VP_FCODE
                   and v2.ID = t.VISIT_PURPOSE_ID
                   and v.DIR = '43'
                   and v.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DIRECTORIES_FN_DATA')
                   and v2.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'VISITPURPOSES')),
               (select d_stragg(v.DD_NAME ||' - '|| v.DD_CODE)
                  from D_V_DIRECTORIES_FN_DATA v,
                       D_V_PAYMENT_KIND v2
                 where v.DD_CODE = v2.PK_FCODE
                   and v2.ID = t.PAYMENT_KIND_ID
                   and v.DIR = '46'
                   and v.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DIRECTORIES_FN_DATA')
                   and v2.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'PAYMENT_KIND'))
          into :REP_PATIENT_ID,
               :CUSTOM_DATE,
               :REG_DATE_DAY,
               :REG_DATE_MONTH,
               :REG_DATE_YEAR,
               :DC_IS_CLOSE,
               :VIS_PURPOSE_2,
               :VIS_IS_PRIMARY,
               :VIS_PURPOSE,
               :VIS_PURPOSE_DETAIL,
               :VIS_PAYMENT_KINDS
          from D_V_DIRECTIONS t2,
               D_V_DIRECTION_SERVICES t
     left join D_V_VISITPURPOSES t3
            on t3.ID = t.VISIT_PURPOSE_ID
     left join D_V_DISEASECASES dc on dc.ID = t.DISEASECASE
          where t.ID = :REP_DS_ID
            and t2.ID = t.PID;
    end;
    <component cmptype="ActionVar" name="LPU" src="LPU" srctype="session" get="LPU"/>
    <component cmptype="ActionVar" name="REP_DS_ID" src="REP_DS_ID" srctype="var" get="v0"/>
    <component cmptype="ActionVar" name="REG_DATE_DAY" src="REG_DATE_DAY:caption" srctype="ctrl" put="v1" len="2"/>
    <component cmptype="ActionVar" name="REG_DATE_MONTH" src="REG_DATE_MONTH:caption" srctype="ctrl" put="v2" len="20"/>
    <component cmptype="ActionVar" name="REG_DATE_YEAR" src="REG_DATE_YEAR:caption" srctype="ctrl" put="v3" len="4"/>
    <component cmptype="ActionVar" name="REP_PATIENT_ID" src="REP_PATIENT_ID" srctype="var" put="v4" len="17"/>
    <component cmptype="ActionVar" name="CUSTOM_DATE" src="CUSTOM_DATE" srctype="var" put="v5" len="20"/>
    <component cmptype="ActionVar" name="DC_IS_CLOSE" src="DC_IS_CLOSE:caption" srctype="ctrl" put="v6" len="10"/>
    <component cmptype="ActionVar" name="VIS_PURPOSE_2" src="VIS_PURPOSE_2:caption" srctype="ctrl" put="v7" len="100"/>
    <component cmptype="ActionVar" name="VIS_IS_PRIMARY" src="VIS_IS_PRIMARY:caption" srctype="ctrl" put="v8" len="100"/>
    <component cmptype="ActionVar" name="VIS_PURPOSE" src="VIS_PURPOSE:caption" srctype="ctrl" put="v9" len="100"/>
    <component cmptype="ActionVar" name="VIS_PURPOSE_DETAIL" src="VIS_PURPOSE_DETAIL:caption" srctype="ctrl" put="v10" len="4000"/>
    <component cmptype="ActionVar" name="VIS_PAYMENT_KINDS" src="VIS_PAYMENT_KINDS:caption" srctype="ctrl" put="v11" len="4000"/>
</component>

<component cmptype="Action" name="getDirectionFromHC">
    begin
        select t.DIRECTION_SERVICE_ID,
               t.PATIENT_ID
          into :REP_DS_ID,
               :PATIENT_ID
          from D_V_HOME_CALL_JOUR t
         where t.id = :REP_HC_ID;
    end;
    <component cmptype="ActionVar" name="REP_HC_ID"  src="REP_HC_ID" srctype="var" get="v0"/>
    <component cmptype="ActionVar" name="REP_DS_ID"  src="REP_DS_ID" srctype="var" put="v1" len="17"/>
    <component cmptype="ActionVar" name="PATIENT_ID" src="REP_PATIENT_ID" srctype="var" put="v2" len="17"/>
</component>

<component cmptype="Action" name="getHCData">
    begin
        select t.PATIENT_ID,
               t.REG_TIME,
               to_char(t.REG_TIME, 'dd'),
               D_PKG_DAT_TOOLS.DATE_TO_CHAR(t.REG_TIME, 'MONTH'),
               to_char(t.REG_TIME, 'yyyy'),
               case when :VISIT_PLACE_HC_OPTION = 1 then 'поликлиника – 1'
                    when :VISIT_PLACE_HC_OPTION = 2 then 'на дому – 2'
                    else 'иные медицинские организации – 4'
               end,
               case when dc.IS_CLOSE = 1 then 'да - 1' else 'нет – 2' end,
               (select d_stragg(v.DD_NAME ||' - '|| v.DD_CODE)
                  from D_V_DIRECTORIES_FN_DATA v,
                       D_V_PAYMENT_KIND v2
                 where v.DD_CODE = v2.PK_CODE
                   and v2.PK_CODE = :PAYMENT_KIND_HC_OPTION
                   and v.DIR = '46'
                   and v.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DIRECTORIES_FN_DATA')
                   and v2.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'PAYMENT_KIND')),
                case when vp.VP_TYPE = 1 then 'по заболеваниям (коды A00-T98) – 1'
                     when vp.VP_TYPE = 2 then 'с профилактической и иными целями (коды Z00-Z99) – 2'
                     else '' end,
                (select d_stragg(v.DD_NAME ||' - '|| v.DD_CODE)
                      from D_V_DIRECTORIES_FN_DATA v,
                           D_V_VISITPURPOSES v2
                     where v.DD_CODE = v2.VP_FCODE
                       and v2.ID = t.VISIT_PURPOSE_ID
                       and v.DIR = '43'
                       and v.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DIRECTORIES_FN_DATA')
                       and v2.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'VISITPURPOSES'))
          into :REP_PATIENT_ID,
               :CUSTOM_DATE,
               :REG_DATE_DAY,
               :REG_DATE_MONTH,
               :REG_DATE_YEAR,
               :VIS_PLACE,
               :DC_IS_CLOSE,
               :VIS_PAYMENT_KINDS,
               :VIS_PURPOSE_TYPE,
               :PURPOSE_FN_DATA
          from D_V_HOME_CALL_JOUR t
               left join D_V_VISITPURPOSES vp
                      on vp.ID = t.VISIT_PURPOSE_ID
               left join D_V_DISEASECASES dc on dc.ID = t.DISEASECASE_ID
          where t.ID = :REP_HC_ID;
    end;
    <component cmptype="ActionVar" name="LPU" src="LPU" srctype="session" get="LPU"/>
    <component cmptype="ActionVar" name="REP_HC_ID" src="REP_HC_ID" srctype="var" get="v0"/>
    <component cmptype="ActionVar" name="REG_DATE_DAY" src="REG_DATE_DAY:caption" srctype="ctrl" put="v1" len="2"/>
    <component cmptype="ActionVar" name="REG_DATE_MONTH" src="REG_DATE_MONTH:caption" srctype="ctrl" put="v2" len="20"/>
    <component cmptype="ActionVar" name="REG_DATE_YEAR" src="REG_DATE_YEAR:caption" srctype="ctrl" put="v3" len="4"/>
    <component cmptype="ActionVar" name="REP_PATIENT_ID" src="REP_PATIENT_ID" srctype="var" put="v4" len="17"/>
    <component cmptype="ActionVar" name="CUSTOM_DATE" src="CUSTOM_DATE" srctype="var" put="v5" len="20"/>
    <component cmptype="ActionVar" name="VISIT_PLACE_HC_OPTION" src="VISIT_PLACE_HC_OPTION" srctype="var" get="v6"/>
    <component cmptype="ActionVar" name="VIS_PLACE" src="VIS_PLACE:caption" srctype="ctrl" put="v7" len="100"/>
    <component cmptype="ActionVar" name="DC_IS_CLOSE" src="DC_IS_CLOSE:caption" srctype="ctrl" put="v8" len="10"/>
    <component cmptype="ActionVar" name="PAYMENT_KIND_HC_OPTION" src="PAYMENT_KIND_HC_OPTION" srctype="var" get="v9"/>
    <component cmptype="ActionVar" name="VIS_PAYMENT_KINDS" src="VIS_PAYMENT_KINDS:caption" srctype="ctrl" put="v10" len="4000"/>
    <component cmptype="ActionVar" name="VIS_PURPOSE_TYPE" src="VIS_PURPOSE:caption" srctype="ctrl"  put="v11" len="4000"/>
    <component cmptype="ActionVar" name="VIS_PURPOSE_TYPE" src="VIS_PURPOSE_2:caption" srctype="ctrl"  put="v12" len="4000"/>
    <component cmptype="ActionVar" name="PURPOSE_FN_DATA" src="VIS_PURPOSE_DETAIL:caption" srctype="ctrl"  put="v13" len="4000"/>
</component>
<!--    End Actions    -->

<!--    Begin Datasets    -->
<component cmptype="DataSet" name="DS_AMB_TALON_VISITS" activateoncreate="false">
    <![CDATA[
    select trunc((ROWNUM - 1) / 7) PAGE,
           VIS_DATE
    from(
        select t.ID,
               t.VIS_DATE
        from D_V_AMB_TALON_VISITS t
        where t.PID = :REP_AMB_TALON_ID
        and t.ROW_TYPE = 0
        order by t.VIS_DATE)
    ]]>
    <component cmptype="DataSetVar" name="REP_AMB_TALON_ID" src="REP_AMB_TALON_ID" srctype="var" get="g0"/>
</component>

<component cmptype="DataSet" name="DS_PMC_FEDERAL_PRIVS" activateoncreate="false">
    <![CDATA[
    select v.*,
           case when R_NUM = 1 then ' ' else to_char(R_NUM) end R_NUM
    from(
    select ROWNUM R_NUM,
           case when :DATE_RB_RE_CONS = 0 then t.NSU_END else t.PRIV_END end PRIV_END,
           t.PR_CODE PRIV
      from table (cast (d_pkg_flr.get_fedd_privs((select t2.SNILS from d_v_persmedcard t2 where t2.ID = :REP_PATIENT_ID), :LPU, :CUSTOM_DATE) as D_CL_FED_PRIVS)) t
     where t.IS_MAIN = 1

    union all

    select ROWNUM R_NUM,
           t.PRIV_END,
           t.PRIV
      from d_v_agent_federal_privs t,
           d_v_persmedcard t2
     where t2.AGENT = t.pid
       and t2.ID = :REP_PATIENT_ID
       and t.IS_CANCELED = 0
       and trunc(t.PRIV_BEGIN) <= :CUSTOM_DATE
       and (trunc(t.PRIV_END) >= :CUSTOM_DATE or t.PRIV_END is null)
       and t.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'AGENT_FEDERAL_PRIVS')
    ) v
    ]]>
    <component cmptype="DataSetVar" name="LPU" src="LPU" srctype="session" get="v0"/>
    <component cmptype="DataSetVar" name="REP_PATIENT_ID" src="REP_PATIENT_ID" srctype="var" get="v1"/>
    <component cmptype="DataSetVar" name="CUSTOM_DATE" src="CUSTOM_DATE" srctype="var" get="v2"/>
    <component cmptype="DataSetVar" name="DATE_RB_RE_CONS" src="DATE_RB_RE_CONS" srctype="var" get="v3"/>
</component>

<component cmptype="DataSet" name="DS_VIS_EMPLOYERS" activateoncreate="false" compile="true">
    <![CDATA[
    @if(:REP_AMB_TALON_ID && :REP_AMB_TALON_ID != 'null'){
        select ROW_NUMBER() over (order by t.VIS_DATE) R_NUM,
               t.VIS_EMPLOYER_SPEC_NAME,
               t.VIS_EMPLOYER_NAME,
               t.VIS_EMPLOYER
          from D_V_AMB_TALON_VISITS t
         where t.PID = :REP_AMB_TALON_ID
         order by t.VIS_DATE
    @}else if (:REP_HC_ID != 'null'){
        select ROWNUM R_NUM,
               t2.SPECIALITY VIS_EMPLOYER_SPEC_NAME,
               t2.SURNAME || ' ' || t2.FIRSTNAME || ' ' || t2.LASTNAME VIS_EMPLOYER_NAME,
               t2.KOD_VRACHA VIS_EMPLOYER
          from D_V_HOME_CALL_JOUR t,
               D_V_EMPLOYERS t2
         where t.ID = :REP_HC_ID
           and t2.ID = t.EMPLOYER_ID
    @}else if (:REP_DS_ID != null){
        select ROWNUM R_NUM,
               t2.SPECIALITY VIS_EMPLOYER_SPEC_NAME,
               t2.SURNAME || ' ' || t2.FIRSTNAME || ' ' || t2.LASTNAME VIS_EMPLOYER_NAME,
               t2.KOD_VRACHA VIS_EMPLOYER
        from D_V_DIRECTION_SERVICES t,
             D_V_EMPLOYERS t2
        where t.ID = :REP_DS_ID
        and t2.ID = t.EMPLOYER_TO
    @}
    ]]>
    <component cmptype="DataSetVar" name="REP_AMB_TALON_ID" src="REP_AMB_TALON_ID" srctype="var" get="v0"/>
    <component cmptype="DataSetVar" name="FROM_HC" src="FROM_HC" srctype="var" get="v1"/>
    <component cmptype="DataSetVar" name="REP_HC_ID" src="REP_HC_ID" srctype="var" get="v2"/>
    <component cmptype="DataSetVar" name="REP_DS_ID" src="REP_DS_ID" srctype="var" get="v3"/>
</component>

<component cmptype="DataSet" name="DS_VIS_SERVICES" activateoncreate="false" compile="true">
    <![CDATA[
    @if(:REP_AMB_TALON_ID && :REP_AMB_TALON_ID != 'null'){
        select ROW_NUMBER() over (order by t.VIS_DATE) R_NUM,
               t.SERVICE_NAME,
               t.SERVICE
          from D_V_AMB_TALON_VISITS t
         where t.PID = :REP_AMB_TALON_ID
         order by t.VIS_DATE
    @}else if (:REP_HC_ID != 'null'){
        select ROWNUM R_NUM,
               t2.SE_NAME SERVICE_NAME,
               t2.SE_CODE SERVICE
          from D_V_HOME_CALL_JOUR t,
               D_V_SERVICES t2
         where t.ID = :REP_HC_ID
           and t2.ID = t.SERVICE_ID
    @}else if (:REP_DS_ID){
        select ROWNUM,
               t.SERVICE_NAME,
               t.SERVICE
        from D_V_DIRECTION_SERVICES t
        where t.ID = :REP_DS_ID
    @}
    ]]>
    <component cmptype="DataSetVar" name="REP_AMB_TALON_ID" src="REP_AMB_TALON_ID" srctype="var" get="v0"/>
    <component cmptype="DataSetVar" name="FROM_HC" src="FROM_HC" srctype="var" get="v1"/>
    <component cmptype="DataSetVar" name="REP_HC_ID" src="REP_HC_ID" srctype="var" get="v2"/>
    <component cmptype="DataSetVar" name="REP_DS_ID" src="REP_DS_ID" srctype="var" get="v3"/>
</component>

<component cmptype="DataSet" name="DS_AMB_SOP_MKBS" activateoncreate="false">
    <![CDATA[
    select ROWNUM R_NUM,
           t.MKB_NAME SOP_MKB_NAME,
           t.MKB SOP_MKB
    from D_V_AMB_TALON_MKBS t
    where t.PID = :REP_AMB_TALON_ID
    and t.IS_MAIN_ID = 2
    and t.IS_VISIBLE = 1
    ]]>
    <component cmptype="DataSetVar" name="REP_AMB_TALON_ID" src="REP_AMB_TALON_ID" srctype="var" get="g0"/>
</component>

<component cmptype="DataSet" name="DS_AMB_OPERATIONS" activateoncreate="false">
    <![CDATA[
    select v.*,
           case when R_NUM = 1 then ' ' else to_char(R_NUM) end R_NUM
    from (
    select ROW_NUMBER() over (order by t.VIS_DATE) R_NUM,
           t.SERVICE_NAME OPERATION_NAME,
           t.SERVICE OPERATION,
           case when t.ANEST_TYPE is not null then t.ANEST_TYPE_NAME || ' - ' || t.ANEST_TYPE end ANEST_TYPE,
           (select d_stragg(v.DD_NAME ||' - '|| v.DD_CODE)
              from D_V_DIRECTORIES_FN_DATA v
             where v.DD_CODE = t.APP_KIND
               and v.DIR = '49'
               and v.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DIRECTORIES_FN_DATA')) APP_KIND,
           t.VIS_EMPLOYER_SPEC_NAME,
           t.VIS_EMPLOYER_NAME,
           t.VIS_EMPLOYER
    from D_V_AMB_TALON_VISITS t
    where t.ROW_TYPE = 2
    and t.PID = :REP_AMB_TALON_ID
    order by t.VIS_DATE
    ) v
    ]]>
    <component cmptype="DataSetVar" name="LPU" src="LPU" srctype="session" get="LPU"/>
    <component cmptype="DataSetVar" name="REP_AMB_TALON_ID" src="REP_AMB_TALON_ID" srctype="var" get="g0"/>
</component>

<component cmptype="DataSet" name="DS_AMB_MANIPULATIONS" activateoncreate="false">
    <![CDATA[
    select ROW_NUMBER() over (order by t.VIS_DATE) R_NUM,
           t.SERVICE_NAME,
           t.SERVICE,
           t.SER_COUNT,
           t.VIS_EMPLOYER_SPEC_NAME,
           t.VIS_EMPLOYER_NAME,
           t.VIS_EMPLOYER
    from D_V_AMB_TALON_VISITS t
    where t.ROW_TYPE = 1
    and t.PID = :REP_AMB_TALON_ID
    order by t.VIS_DATE
    ]]>
    <component cmptype="DataSetVar" name="LPU" src="LPU" srctype="session" get="LPU"/>
    <component cmptype="DataSetVar" name="REP_AMB_TALON_ID" src="REP_AMB_TALON_ID" srctype="var" get="g0"/>
</component>

                                                            <!-- моя заплаткая  Результат обращения*/ -->
<component cmptype="DataSet" name="DS_REZ" activateoncreate="false">
    <![CDATA[
    select v.VR_NAME 
              from  D_V_VISITRESULTS v 
                 join D_V_AMB_TALONS at on at.REF_RESULT_ID = v.id
                  join D_V_AMB_TALON_VISITS t4 on t4.pid =at.id
               where t4.VISIT = :REP_VISIT_ID
    ]]>
    <component cmptype="DataSetVar" name="LPU" src="LPU" srctype="session" get="LPU"/>
    <component cmptype="DataSetVar" name="REP_VISIT_ID" src="REP_VISIT_ID" srctype="var" get="g0"/>
    <component cmptype="DataSetVar" name="REP_AMB_TALON_ID" src="REP_AMB_TALON_ID" srctype="var" get="g1"/>
</component>

<component cmptype="DataSet" name="DS_AMB_RECIPES" activateoncreate="false">
    <![CDATA[
    select t2.REC_DATE,
           t2.REC_SERNUMB,
           t2.REC_NUMB,
           t2.PRIVPERCENT,
           t2.DISEASE,
           t2.EMPLOYER,
           t3.MNN_FED_PRIV_RUS,
           t3.MEDFORM,
           t3.DOSE || ' ' || t4.MNEMOCODE DOSE,
           t3.PACK_COUNT
    from D_V_AMB_TALON_VISITS t,
         D_V_RECIPS t2,
         D_V_RECIPE_SPECS t3
    left join D_V_DOSE_MEASURES t4
           on t4.ID = t3.DOSE_MEAS
    where t.PID = :REP_AMB_TALON_ID
    and t2.VISIT = t.VISIT
    and t3.PID = t2.ID
    order by t2.REC_DATE
    ]]>
    <component cmptype="DataSetVar" name="REP_AMB_TALON_ID" src="REP_AMB_TALON_ID" srctype="var" get="g0"/>
</component>

<component cmptype="DataSet" name="DS_AMB_BULLETINS" activateoncreate="false">
    <![CDATA[
    select v.*,
           case when R_NUM = 1 then ' ' else to_char(R_NUM) end R_NUM
    from (
    select ROW_NUMBER() over (order by t2.DATE_BEGIN) R_NUM,
           t2.ID,
           (select d_stragg(v.DD_NAME ||' - '|| v.DD_CODE || case when v.DD_CODE = 2 then ' (ФИО'||' '||t3.FULLNAME||')' end)
              from D_V_DIRECTORIES_FN_DATA v,
                   D_V_DISABILITY_TYPES v2
             where v.DD_CODE = v2.DT_FCODE
               and v2.ID = t2.DISABILITY_TYPE_ID
               and v.DIR = '50'
               and v.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DIRECTORIES_FN_DATA')
               and v2.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DISABILITY_TYPES')) DIS_TYPES,
           to_char(t2.DATE_BEGIN, 'dd') DATE_BEGIN_DAY,
           D_PKG_DAT_TOOLS.DATE_TO_CHAR(t2.DATE_BEGIN, 'MONTH') DATE_BEGIN_MONTH,
           to_char(t2.DATE_BEGIN, 'yyyy') DATE_BEGIN_YEAR,
           to_char(t2.DATE_END, 'dd') DATE_END_DAY,
           D_PKG_DAT_TOOLS.DATE_TO_CHAR(t2.DATE_END, 'MONTH') DATE_END_MONTH,
           to_char(t2.DATE_END, 'yyyy') DATE_END_YEAR
      from D_V_AMB_TALON_VISITS t,
           D_V_BJ_BULLETIN_CONTENTS t2
    left join D_V_BJ_BULL_CONT_CARES t3
           on t3.PID = t2.ID
     where t.PID = :REP_AMB_TALON_ID
       and t2.VISIT = t.VISIT
       and t2.MAIN_BULL_ID is null
       and t2.HID is null
       and t2.BULL_STATE = 0
     order by t2.DATE_BEGIN
    ) v
    ]]>
    <component cmptype="DataSetVar" name="LPU" src="LPU" srctype="session" get="LPU"/>
    <component cmptype="DataSetVar" name="REP_AMB_TALON_ID" src="REP_AMB_TALON_ID" srctype="var" get="g0"/>
</component>

<component cmptype="DataSet" name="DS_AMB_BULL_CONTS" activateoncreate="false">
    <![CDATA[
    select v.ID,
           v.CONT_DATE
      from(
    select t2.ID,
           t3.ID EXT_ID,
           t3.DATE_FROM CONT_DATE,
           t2.DATE_BEGIN
      from D_V_AMB_TALON_VISITS t,
           D_V_BJ_BULLETIN_CONTENTS t2,
           D_V_BJ_BULL_CONT_EXTS t3
     where t.PID = :REP_AMB_TALON_ID
       and t2.VISIT = t.VISIT
       and t2.MAIN_BULL_ID is null
       and t2.HID is null
       and t2.BULL_STATE = 0
       and t3.PID = t2.ID

     union all

     select t2.ID,
            t3.ID EXT_ID,
            t3.DATE_TO CONT_DATE,
            t2.DATE_BEGIN
      from D_V_AMB_TALON_VISITS t,
           D_V_BJ_BULLETIN_CONTENTS t2,
           D_V_BJ_BULL_CONT_EXTS t3
     where t.PID = :REP_AMB_TALON_ID
       and t2.VISIT = t.VISIT
       and t2.MAIN_BULL_ID is null
       and t2.HID is null
       and t2.BULL_STATE = 0
       and t3.PID = t2.ID
       ) v
     where rownum < 7
     order by v.DATE_BEGIN, v.EXT_ID, v.CONT_DATE
    ]]>
    <component cmptype="DataSetVar" name="LPU" src="LPU" srctype="session" get="LPU"/>
    <component cmptype="DataSetVar" name="REP_AMB_TALON_ID" src="REP_AMB_TALON_ID" srctype="var" get="g0"/>
</component>
<!--    End Datasets    -->
</div>