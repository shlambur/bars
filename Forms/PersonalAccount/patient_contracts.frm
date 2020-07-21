<div cmptype="tmp" oncreate="base().OnCreate();" onshow="base().OnShow();"  window_size="1200x700">
    <component cmptype="ProtectedBlock" modcode="PaidServices">
        <div cmptype="title">Лицевой счет</div>
        <component cmptype="Script" name="Script">
            Form.OnCreate = function () {
                setVar('PERSMEDCARD', getVar('PERSMEDCARD', 1));
                setVar('AGENT', getVar('AGENT', 1));
                if (empty(getVar('AGENT', 1)) || empty(getVar('PERSMEDCARD', 1))) {
                    alert('Для нормальной работы формы нужны переменные AGENT и PERSMEDCARD с предыдущего окна.');
                    //closeWindow();
                }
                executeAction('GET_SYS_YEAR', function () {
                    setValue('DS_CONTRACTS_GRID_DOC_DATE_FilterItem_BEGIN', '01.01.' + getVar('YEAR'));
                    setValue('DS_CONTRACTS_GRID_DOC_DATE_FilterItem_END', '31.12.' + getVar('YEAR'));
                });
            }
            Form.OpenPersmedcard = function () {
                openWindow('Persmedcard/persmedcard_edit', true, 800, 580)
                        .addListener('onclose', function () {
                            if (getVar('ModalResult', 1) == 1) {
                                base(1).refreshPatient();
                            }
                        });
            }
            Form.refreshPatient = function () {
                executeAction('GET_SYS_YEAR', function () {
                    setValue('DS_CONTRACTS_GRID_DOC_DATE_FilterItem_BEGIN', '01.01.' + getVar('YEAR'));
                    setValue('DS_CONTRACTS_GRID_DOC_DATE_FilterItem_END', '31.12.' + getVar('YEAR'));
                });
            }
            Form.OnShow = function () {
                //setValue('DISEASECASE_TYPE','0');
                if (empty(getVar('AGENT', 1)) || empty(getVar('PERSMEDCARD', 1))) {
                    //alert('Для нормальной работы формы нужны переменные AGENT и PERSMEDCARD с предыдущего окна.');
                    closeWindow();
                }
                else {
                    refreshDataSet('DS_DISEASECASES');
                }
            }
            Form.OnFilter = function () {
                startMultiDataSetsGroup();
                refreshDataSet('DS_CONTRACTS');
                refreshDataSet('DS_PAYMENT_JOURNAL');
                refreshDataSet('DS_RENDERING_JOURNAL');
                endMultiDataSetsGroup();
            }

            Form.OnChangeContracts = function () {
                if (!empty(getValue('GRID_CONTRACTS'))) {
                    setVar('AMI_ID', getControlProperty('GRID_CONTRACTS', 'data')['AMI_ID']);
                    setVar('CONTRACT_ID', getControlProperty('GRID_CONTRACTS', 'data')['ID']);
                }
                startMultiDataSetsGroup();
                refreshDataSet('DS_CONTRACT_PAYMENTS');
                if (getValue('PAY_KIND_CHECK') == 0) {
                    refreshDataSet('DS_RENDERING_JOURNAL');
                    setVar('PAYMENT_KIND_ID', null);
                }
                else {
                    setVar('PAYMENT_KIND_ID', getCaption('GRID_CONTRACTS'));
                }
                setVar('SELECTED_PAYMENT_TYPE', getCaption('GRID_CONTRACTS'));
                endMultiDataSetsGroup();
                executeAction('GET_AGENT_SUMM', function () {
                    if (parseToJSFloat(getVar('DIR_SUMM')) > 0) {
                        setCaption('LAB_DIR_SUMM', 'Неоказанных услуг в договорах:');
                    }
                    else {
                        setCaption('LAB_DIR_SUMM', 'Оказано без договора:');
                        setVar('DIR_SUMM', (getVar('DIR_SUMM') * (-1)));
                    }
                    setCaption('DIR_SUMM', getVar('DIR_SUMM'));
                });
            }
            <![CDATA[
            Form.fi_create = function (_dom) {
                var _ctrlname = getProperty(_dom, 'name', '');
                var _ds = getProperty(_dom, 'refreshdatasets', '');

                var _fieldname = _fieldname = '_f[' + getProperty(_dom, 'field', '');
                var _fkind = getProperty(_dom, 'filterkind', '');

                if (_fkind == 'perioddate') _fieldname += ';' + 'D' + ';' + _ctrlname;
                _fieldname += ']';

                var dss_arr = _ds.split(";");

                for (var i = 0; i < dss_arr.length; i++) {
                    addSystemInfo(dss_arr[i], {get: _fieldname, srctype: 'ctrl', src: _ctrlname, ignorenull: false});
                }
            }

            Form.fi_refresh = function (_dom) {
                var _ds = getProperty(_dom, 'refreshdatasets', '');
                var dss_arr = _ds.split(";");
                for (var i = 0; i < dss_arr.length; i++) {
                    refreshDataSet(dss_arr[i]);
                }
            }
            ]]>
        </component>
        <component cmptype="Action" name="GET_SYS_YEAR">
            begin
                    select to_char(sysdate,'yyyy'), to_char(sysdate,'dd.mm.yyyy')
                    into :YEAR, :SYSDATE
                    from dual;
                    select
                    d_pkg_str_tools.fio(t.SURNAME, t.FIRSTNAME, t.LASTNAME)||', '||
                           decode(substr(to_char(D_PKG_DAT_TOOLS.FULL_YEARS(sysdate,t.BIRTHDATE)),-1,1),
                           '1',D_PKG_DAT_TOOLS.FULL_YEARS(sysdate,t.BIRTHDATE)||' год.',
                           '2',D_PKG_DAT_TOOLS.FULL_YEARS(sysdate,t.BIRTHDATE)||' года.',
                           '3',D_PKG_DAT_TOOLS.FULL_YEARS(sysdate,t.BIRTHDATE)||' года.',
                           '4',D_PKG_DAT_TOOLS.FULL_YEARS(sysdate,t.BIRTHDATE)||' года.',
                           D_PKG_DAT_TOOLS.FULL_YEARS(sysdate,t.BIRTHDATE)||' лет.')
                    into :PATIENT_INFO
                    from d_v_agents t
                    where t.ID=:AGENT;
            end;
            <component cmptype="ActionVar" name="YEAR"         put="year"    src="YEAR"         srctype="var"         len="4"/>
            <component cmptype="ActionVar" name="SYSDATE"      put="sysdate" src="SYSDATE"      srctype="var"         len="15"/>
            <component cmptype="ActionVar" name="PATIENT_INFO" put="patinfo" src="PatientLabel" srctype="ctrlcaption" len="200"/>
            <component cmptype="ActionVar" name="AGENT"        get="v0"      src="AGENT"        srctype="var" />
        </component>

        <table class="form-table" style="table-layout:fixed;height:100%;width:100%;">
            <tbody style="height:100%;">
                <tr>
                    <td colspan="2" style="width:100%;">
                        <table class="form-table-splice" width="100%">
                            <tr>
                                <td style="padding-left: 8px;">
                                    <component cmptype="Label" caption="Пациент:"/>
                                </td>
                                <td style="text-align:left;">
                                    <b>
                                        <component cmptype="HyperLink" name="PatientLabel" onclick="base().OpenPersmedcard();"/>
                                    </b>
                                </td>
                                <td>
                                    <b>
                                        <component cmptype="Label" name="LABEL_DEBT"/>
                                    </b>
                                </td>
                                <td></td>
                                <td>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding-left: 8px;" colspan="5">
                                    <component cmptype="Label" caption="Всего оказано: "/>
                                    <component cmptype="Label" name="RENDER_SUMM"/>
                                    &#160;|
                                    <component cmptype="Label" caption="Оплачено: "/>
                                    <component cmptype="Label" name="PAY_SUMM"/>
                                    &#160;|
                                    <component cmptype="Label" caption="Возвраты: "/>
                                    <component cmptype="Label" name="RETURN_SUMM"/>
                                    &#160;|
                                    <component cmptype="Label" name="LAB_DIR_SUMM"/>
                                    <component cmptype="Label" name="DIR_SUMM"/>
                                </td>
                                <component cmptype="Action" name="GET_AGENT_SUMM">
                                    <![CDATA[
                                        begin
                                              d_pkg_facial_accounts.get_agent_summs(pnagent => :AGENT,
                                                                                      pnlpu => :LPU,
                                                                              pnrender_summ => :RENDER_SUMM, -- Оказано
                                                                                 pnpay_summ => :PAY_SUMM,-- Оплачено
                                                                              pnreturn_summ => :RETURN_SUMM,-- Возврат
                                                                                 pndir_summ => :DIR_SUMM,-- Назначено и не оказано
                                                                                    pdbegin => :DATE_BEGIN,
                                                                                      pdend => :DATE_END,
                                                                             pnpayment_kind => :PAYMENT_KIND,
                                                                              pndiseasecase => :DISEASECASE,
                                                                         pndiseasecase_type => :DISEASECASE_TYPE);


                                              select case when nvl(sum(t.DEBT_SUMM),0) > 0
                                                                then 'Долг пациента: '||abs(sum(t.DEBT_SUMM))
                                                          when nvl(sum(t.DEBT_SUMM),0) = 0
                                                                then 'Задолженности нет.'
                                                          when nvl(sum(t.DEBT_SUMM),0) < 0
                                                                then 'Долг перед пациентом: '||abs(sum(t.DEBT_SUMM))
                                                     end LABEL
                                               into :LABEL_DEBT
                                               from D_V_FACIAL_ACCOUNTS t
                                              where t.AGENT_ID = :AGENT
                                                and t.LPU=:LPU;
                                        end;
                                    ]]>
                                    <component cmptype="ActionVar" name="AGENT"            src="AGENT"                                       srctype="var"         get="v0"/>
                                    <component cmptype="ActionVar" name="LPU"              src="LPU"                                         srctype="session"/>
                                    <component cmptype="ActionVar" name="RENDER_SUMM"      src="RENDER_SUMM"                                 srctype="ctrlcaption" put="render_summ" len="20" />
                                    <component cmptype="ActionVar" name="PAY_SUMM"         src="PAY_SUMM"                                    srctype="ctrlcaption" put="pay_summ" len="20" />
                                    <component cmptype="ActionVar" name="RETURN_SUMM"      src="RETURN_SUMM"                                 srctype="ctrlcaption" put="return_summ" len="20" />
                                    <component cmptype="ActionVar" name="DIR_SUMM"         src="DIR_SUMM"                                    srctype="var"         put="dir_summ" len="20"/>
                                    <component cmptype="ActionVar" name="LABEL_DEBT"       src="LABEL_DEBT"                                  srctype="ctrlcaption" put="label_debt" len="160"/>
                                    <component cmptype="ActionVar" name="PAYMENT_KIND"     src="PAYMENT_KIND_ID"                             srctype="var"         get="v1"/>

                                    <component cmptype="ActionVar" name="DISEASECASE"      src="DISEASECASES"                                srctype="ctrl"        get="v2"/>
                                    <component cmptype="ActionVar" name="DISEASECASE_TYPE" src="DISEASECASE_TYPE"                            srctype="ctrl"        get="v3"/>
                                    <component cmptype="ActionVar" name="DATE_BEGIN"       src="DS_CONTRACTS_GRID_DOC_DATE_FilterItem_BEGIN" srctype="ctrl"        get="v4"/>
                                    <component cmptype="ActionVar" name="DATE_END"         src="DS_CONTRACTS_GRID_DOC_DATE_FilterItem_END"   srctype="ctrl"        get="v5"/>
                                </component>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="2" style="width:100%;">
                        <table class="form-table" width="100%">
                            <tr>
                                <td>
                                    <component cmptype="CheckBox" name="IS_ACTIVE_CONTRACT" caption="Действующие договора"  valuechecked="1" valueunchecked="0" activ="true" onchange="refreshDataSet('DS_CONTRACTS');"/>
                                    &#160;|
                                </td>
                                <td>
                                    <component cmptype="Label" caption="Документы с"/>
                                </td>
                                <td>
                                    <component cmptype="DateEdit" name="DS_CONTRACTS_GRID_DOC_DATE_FilterItem_BEGIN" field="DOC_DATE" filterkind="perioddate"
                                                onkeypress="onEnter(function(){base().fi_refresh(this);},this);" oncreate="base().fi_create(this);" refreshdatasets="DS_CONTRACTS;DS_PAYMENT_JOURNAL"/>
                                </td>
                                <td>
                                    <component cmptype="Label" caption="по"/>
                                </td>
                                <td>
                                    <component cmptype="DateEdit" name="DS_CONTRACTS_GRID_DOC_DATE_FilterItem_END" field="DOC_DATE" filterkind="perioddate"
                                                onkeypress="onEnter(function(){base().fi_refresh(this);},this);" oncreate="base().fi_create(this);" refreshdatasets="DS_CONTRACTS;DS_PAYMENT_JOURNAL"/>
                                </td>
                                <td>
                                    <component cmptype="Button" caption="Отобрать" onclick="base().OnFilter();"/>
                                </td>
                                <td>
                                    <component cmptype="Label" caption="Случай заболевания"/>
                                </td>
                                <td>
                                    <component cmptype="ComboBox" name="DISEASECASE_TYPE" onchange="refreshDataSet('DS_DISEASECASES');" width="120">
                                        <component cmptype="ComboItem" caption="Все" value=""/>
                                        <component cmptype="ComboItem" dataset="DS_DISEASECASE_TYPES" captionfield="DCT_NAME" datafield="DCT_CODE" repeate="0"/>
                                        <component cmptype="ComboItem" caption="Без случая" value="-1"/>
                                    </component>
                                </td>
                                <td>
                                    <component cmptype="ComboBox" name="DISEASECASES" onchange="base().OnFilter();" width="280">
                                        <component cmptype="ComboItem" caption="Все" value=""/>
                                        <component cmptype="ComboItem" dataset="DS_DISEASECASES" captionfield="DC_CONTENT" datafield="ID" repeate="0" afterrefresh="base().OnFilter();"/>
                                    </component>
                                    <component cmptype="DataSet" name="DS_DISEASECASES" activateoncreate="false" compile="true">
                                            select t.DC_CONTENT,
                                                   t.ID,
                                                   t.DC_OPENDATE
                                              from d_v_diseasecases t
                                             where t.PATIENT_ID = :PERSMEDCARD
                                            @if (:DISEASECASE_TYPE){
                                               and t.DC_TYPE=:DISEASECASE_TYPE
                                            @}
                                          order by t.DC_OPENDATE
                                        <component cmptype="Variable" name="PERSMEDCARD"      src="PERSMEDCARD"      srctype="var"  get="pc"/>
                                        <component cmptype="Variable" name="DISEASECASE_TYPE" src="DISEASECASE_TYPE" srctype="ctrl" get="dc_type"/>
                                    </component>
                                    <component cmptype="DataSet" name="DS_DISEASECASE_TYPES">
                                        select t.DCT_CODE,
                                               t.DCT_NAME
                                          from d_v_diseasecase_types t
                                    </component>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td style="width:60%;height:100%;">
                        <component cmptype="DataSet" name="DS_CONTRACTS" mode="Range" activateoncreate="false" compile="true">
                            <![CDATA[
                                select t.ID,
                                        nvl(t.AMI_ID,t.ID) PRIMARY,
                                        t.CID,
                                        t.SIS_OPEN,
                                        t.AMI_ID,
                                        t.AMI_SUMM,
                                        t.PAYMENT_KIND_ID,
                                        t.PAYMENT_KIND_NAME,
                                        t.DOC_PREF_NUMB,
                                        t.DOC_DATE,
                                        t.AGENT_ID,
                                        t.AGENT_NAME,
                                        t.CONTRACT_SUMM,
                                        t.DEBT_SUMM,
                                        t.DATE_BEGIN,
                                        t.DATE_END,
                                        decode(t.AMI_ID,null,0,1) AMI_FLAG,
                                        t.CONTRACT_TYPE
                                  from D_V_PFA_CONTRACTS t
                                 where (t.PATIENT = :PATIENT_ID or t.AGENT_ID = :AGENT_ID)
                                @if (:IS_ACTIVE==1){
                                   and (t.DATE_END >= sysdate or t.DATE_END is null)
                                   and (t.AMI_STATUS = 1 or t.AMI_STATUS is null)
                                @}
                                   and t.LPU = :LPU
                                @if(:DISEASECASE){
                                   and t.DISEASECASE = :DISEASECASE
                                @}
                                @if (:DISEASECASE_TYPE==-1){
                                   and t.DISEASECASE is null
                                @}else if (:DISEASECASE_TYPE){
                                   and t.DISEASECASE_TYPE = :DISEASECASE_TYPE
                                @}
                              group by t.ID,
                                       t.CID,
                                       t.SIS_OPEN,
                                       t.AMI_ID,
                                       t.AMI_SUMM,
                                       t.PAYMENT_KIND_ID,
                                       t.PAYMENT_KIND_NAME,
                                       t.DOC_PREF_NUMB,
                                       t.DOC_DATE,
                                       t.AGENT_ID,
                                       t.AGENT_NAME,
                                       t.CONTRACT_SUMM,
                                       t.DEBT_SUMM,
                                       t.DATE_BEGIN,
                                       t.DATE_END,
                                       t.CONTRACT_TYPE
                                having :IS_ACTIVE * decode(count(1)- sum(nvl(t.STATUS,-1)),0,1,0) = 0
                            ]]>
                            <component cmptype="Variable" name="LPU"              src="LPU"                srctype="session"/>
                            <component cmptype="Variable" name="PATIENT_ID"       src="PERSMEDCARD"        srctype="var"  get="v0"/>
                            <component cmptype="Variable" name="AGENT_ID"         src="AGENT"              srctype="var"  get="v4"/>
                            <component cmptype="Variable" name="IS_ACTIVE"        src="IS_ACTIVE_CONTRACT" srctype="ctrl" get="v1"/>
                            <component cmptype="Variable" name="DISEASECASE"      src="DISEASECASES"       srctype="ctrl" get="v2"/>
                            <component cmptype="Variable" name="DISEASECASE_TYPE" src="DISEASECASE_TYPE"   srctype="ctrl" get="v3"/>
                            <component cmptype="Variable" type="count"            src="r1c"                srctype="var"  default="10"/>
                            <component cmptype="Variable" type="start"            src="r1s"                srctype="var"  default="1"/>
                        </component>
                        <component cmptype="Grid" name="GRID_CONTRACTS" dataset="DS_CONTRACTS" field="PRIMARY" returnfield="PAYMENT_KIND_ID"
                            calc_height="parent" white_space_nowrap="true" grid_caption="Договора и направления пациента" onchange="base().OnChangeContracts();" hide_filter="true">
                            <component cmptype="Column" caption="Контрагент" field="AGENT_NAME"  sort="AGENT_NAME" width="300" filter="AGENT_NAME"/>
                            <component cmptype="Column" caption="Номер" field="DOC_PREF_NUMB" sort="DOC_PREF_NUMB" width="100" filter="DOC_PREF_NUMB" align="right"/>
                            <component cmptype="Column" caption="Дата" field="DOC_DATE" sort="DOC_DATE" sortorder="-1" align="center"/>
                            <component cmptype="Column" caption="Вид оплаты" field="PAYMENT_KIND_NAME" sort="PAYMENT_KIND_NAME" filter="PAYMENT_KIND_ID" filterkind="cmb_unit" funit="PAYMENT_KIND" fmethod="LIST"/>
                            <component cmptype="Column" caption="Действует с" field="DATE_BEGIN"/>
                            <component cmptype="Column" caption="Действует по" field="DATE_END"/>
                            <component cmptype="Column" caption="Сумма" field="CONTRACT_SUMM" align="right"/>
                            <component cmptype="Column" caption="Лимит" field="AMI_SUMM" align="right"/>
                            <component cmptype="Column" caption="К оплате" field="DEBT_SUMM" align="right"/>
                            <component cmptype="Column" caption="Статус" field="SIS_OPEN" filter="SIS_OPEN" filterkind="cmbo" fcontent="Закрыт|Закрыт;Открыт|Открыт;Не активно|Не активно;Активно|Активно"/>
                            <component cmptype="GridFooter">
                                <component cmptype="Range" insteadrefresh="InsteadRefresh(this);" id="range1" count="10" varstart="r1s" varcount="r1c" valuecount="10" valuestart="1" />
                            </component>
                        </component>
                        <component cmptype="Popup" name="pCONTRACTS" popupobject="GRID_CONTRACTS" onpopup="base().onPopupContracts();">
                            <component cmptype="PopupItem" name="pREFRESH_CONTRACTS" caption="Обновить" onclick="setControlProperty('GRID_CONTRACTS','locate',getValue('GRID_CONTRACTS'));refreshDataSet('DS_CONTRACTS');" cssimg="refresh"/>
                            <component cmptype="PopupItem" name="pSEPARETE"          caption="-"/>
                            <component cmptype="PopupItem" name="pADD_CONTRACT"      caption="Добавить договор" onclick="base().AddContract();" cssimg="insert"/>
                            <component cmptype="PopupItem" name="pADD_DMS_DIRECTION" caption="Добавить направление ДМС" onclick="base().AddDmsDirection();" cssimg="insert"/>
                            <component cmptype="PopupItem" name="pADD_DIRECTION"     caption="Добавить направление от юр.лица" onclick="base().AddDirection();" cssimg="insert"/>
                            <component cmptype="PopupItem" name="pEDIT_CONTRACT"     caption="Редактировать" onclick="base().EditContract();" cssimg="edit"/>
                            <component cmptype="PopupItem" name="pDEL_CONTRACT"      caption="Удалить" onclick="base().DelAmiOrContract();" cssimg="delete"/>

                            <component cmptype="PopupItem" name="pSEPARETERep"       caption="-"/>
                            <component cmptype="PopupItem" name="pContrPatient"      caption="Печать контракта (Пациент)"  onclick="base().PrintContract()" cssimg="print"/>
                            <component cmptype="PopupItem" name="pContr"             caption="Печать контракта (Заказчик)"  onclick="base().PrintContractZakazchik()" cssimg="print"/>
                            <component cmptype="PopupItem" name="pInf"               caption="Печать информационного согласия" onclick="base().PrintAgreement();" cssimg="print"/>
                            <component cmptype="PopupItem" name="pContrOper"         caption="Печать контракта на операцию" onclick="base().PrintContractOper();" cssimg="print"/>
                            <component cmptype="PopupItem" name="pPrintTalon"        caption="Талон медосмотра" onclick="base().PrintTalon();" cssimg="print"/>
                            <component cmptype="PopupItem" name="pListServs"         caption="Печать обходного листа" onclick="base().PrintListServs();" cssimg="print"/>
                            <component cmptype="PopupItem" name="pPrintReceipt"      caption="Квитанция" onclick="base().PrintReceipt();" cssimg="print"/>
                            <component cmptype="PopupItem" name="pPrintReceipt1"      caption="Квитанция  1 ой поликлиники" onclick="base().PrintReceipt1();" cssimg="print"/>

                            <component cmptype="PopupItem" name="pSEPARETENull"        caption="-"/>
                            <component cmptype="PopupItem" name="pCLOSE_CONTRACT"      caption="Закрыть" onclick="base().CloseAmiOrContract();"  cssimg="stop"/>
                            <component cmptype="PopupItem" name="pNULL_CONTRACT"       caption="Аннулировать" onclick="base().NullContract();"  cssimg="off"/>
                            <component cmptype="PopupItem" name="pCANCELNULL_CONTRACT" caption="Отменить аннулирование" onclick="base().CancelNullContract();" hide="true"  cssimg="off"/>
                            <component cmptype="PopupItem" name="pPAY_CONTRACT"        caption="Оплатить" onclick="base().PayContract();" cssimg="pay"/>
                            <component cmptype="PopupItem" name="pPrintTaxNote"        caption="Справка в налоговую" onclick="base().PrintTaxNote();" cssimg="print"/>
                            <component cmptype="PopupItem" unitbp="LOG_ABLE_TO_VIEW"   caption="Логи" name="popup_logs"
                                onclick="setVar('TABLENAME','CONTRACTS');setVar('PRIMARY',getControlProperty('GRID_CONTRACTS', 'value'));openWindow('Log/log_record',true);" cssimg="report"/>
                            <component cmptype="PopupItem" name="pEXP"                 caption="Выгрузить" unitbp="EI_EMETHODS_ABLE_TO_EXP" onclick="if(!empty(getValue('GRID_CONTRACTS'))){setVar('UNIT','CONTRACTS'); setVar('PRIMARY',getValue('GRID_CONTRACTS'));setVar('FILENAME',getCaption('GRID_CONTRACTS')); openWindow('UnitExportImport/export',true);}" cssimg="up"/>
                            <component cmptype="PopupItem" name="pIMP"                 caption="Загрузить" unitbp="EI_IMETHODS_ABLE_TO_IMP" onclick="setVar('UNIT','CONTRACTS'); openWindow('UnitExportImport/import',true);" cssimg="down"/>
                        </component>
                        <component cmptype="AutoPopupMenu" unit="CONTRACTS" all="true" join_menu="pCONTRACTS" popupobject="GRID_CONTRACTS"/>
                        <component cmptype="Script">
                            <![CDATA[
                            Form.PrintContract = function () {
                                var data = getControlProperty('GRID_CONTRACTS', 'data');
                                setVar('REP_ID', data['ID']);
                                setVar('FLAG', 'CONTR');
                                setVar('PATIENT_ID', getVar('PERSMEDCARD'));
                                setVar('CONTRACT_ID', data['ID']);
                                setVar('AGENT_ID', getVar('AGENT'));
                                printReportByCode('reception_contract');
                            }
                            Form.PrintContractZakazchik = function () {
                                var data = getControlProperty('GRID_CONTRACTS', 'data');
                                setVar('REP_ID', data['ID']);
                                setVar('ID', data['ID']);
                                setVar('FLAG', 'CONTR');
                                setVar('AGENT_ID', getVar('AGENT'));
                                setVar('PATIENT_ID', getVar('PERSMEDCARD'));
                                setVar('CONTRACT_ID', data['ID']);
                                setVar('CONTR_PAY_ID', getValue('GRID_CONTRACT_PAYMENTS'));
                                printReportByCode('reception_contract_zakazchik');
                            }
                            Form.PrintAgreement = function () {
                                var data = getControlProperty('GRID_CONTRACTS', 'data');
                                setVar('ID', data['ID']);
                                setVar('AGENT_ID', getVar('AGENT'));
                                setVar('FLAG', 'CONTR');
                                printReportByCode('patient_agreement_cont_web');
                            }
                            Form.PrintTalon = function () {
                                setVar('PAT_ID', getVar('PERSMEDCARD'));
                                printReportByCode('amb_talon');
                            }
                            Form.PrintContractOper = function () {
                                setVar('REP_ID', getControlProperty('GRID_CONTRACTS', 'data')['ID']);
                                printReportByCode('contract_operation_cont_web');
                            }

                            Form.PrintListServs = function () //метка
                            {
                                setVar('REP_ID', getVar('PERSMEDCARD'));
                                setVar('AMI_DIRECTION', getControlProperty('GRID_CONTRACTS', 'data')['AMI_ID']);
                                if (!empty(getVar('AMI_DIRECTION')))
                                    printReportByCode('ListServs');
                            }
                            Form.PrintReceipt = function () {
                                setVar('PATIENT_ID', getVar('PERSMEDCARD'));
                                setVar('CONTRACT_ID', getControlProperty('GRID_CONTRACTS', 'data')['ID']);
                                openWindow('Reports/Reception/receipt_call', true);
                            }
                            Form.PrintReceipt1 = function () {
                                setVar('PATIENT_ID', getVar('PERSMEDCARD'));
                                setVar('CONTRACT_ID', getControlProperty('GRID_CONTRACTS', 'data')['ID']);
                                openWindow('Reports/Reception/receipt_call1', true);
                            }
                            Form.PrintTaxNote = function () {
                                setVar('CONTRACT_ID', getControlProperty('GRID_CONTRACTS', 'data')['ID']);
                                openWindow('Reports/Tax/tax_note_call', true);
                            }
                            Form.onPopupContracts = function () {
                                var data = getControlProperty('GRID_CONTRACTS', 'data');
                                if (data && !empty(data['ID'])) {
                                    setControlProperty('pCONTRACTS', 'showitem', 'pEDIT_CONTRACT');
                                    setControlProperty('pCONTRACTS', 'showitem', 'pDEL_CONTRACT');
                                    setControlProperty('pCONTRACTS', 'showitem', 'pCLOSE_CONTRACT');
                                    setControlProperty('pCONTRACTS', 'showitem', 'pPrintTaxNote');
                                    setControlProperty('pCONTRACTS', 'showitem', 'pPrintReceipt');
                                    

                                    if (data['AMI_FLAG'] == 1) {//направление
                                        setControlProperty('pCONTRACTS', 'hideitem', 'pNULL_CONTRACT');
                                        setControlProperty('pCONTRACTS', 'hideitem', 'pPAY_CONTRACT');
                                        setControlProperty('pCONTRACTS', 'hideitem', 'pCANCELNULL_CONTRACT');
                                        setControlProperty('pCONTRACTS', 'hideitem', 'pContrPatient');
                                        setControlProperty('pCONTRACTS', 'hideitem', 'pContrOper');
                                        setControlProperty('pCONTRACTS', 'hideitem', 'pSEPARETERep');
                                        setControlProperty('pCONTRACTS', 'hideitem', 'pSEPARETENull');
                                        setControlProperty('pCONTRACTS', 'showitem', 'pListServs');
                                    }
                                    else {
                                        if (data['IS_OPEN'] == 1) {
                                            setControlProperty('pCONTRACTS', 'hideitem', 'pNULL_CONTRACT');
                                            setControlProperty('pCONTRACTS', 'showitem', 'pCANCELNULL_CONTRACT');
                                            setControlProperty('pCONTRACTS', 'showitem', 'pSEPARETENull');
                                        }
                                        else {
                                            setControlProperty('pCONTRACTS', 'showitem', 'pNULL_CONTRACT');
                                            setControlProperty('pCONTRACTS', 'hideitem', 'pCANCELNULL_CONTRACT');
                                            setControlProperty('pCONTRACTS', 'showitem', 'pSEPARETENull');
                                        }
                                        if (parseToJSFloat(data['DEBT_SUMM']) &gt; 0) {
                                            setControlProperty('pCONTRACTS', 'showitem', 'pPAY_CONTRACT');
                                            setControlProperty('pCONTRACTS', 'showitem', 'pSEPARETENull');
                                        }
                                        else setControlProperty('pCONTRACTS', 'hideitem', 'pPAY_CONTRACT');
                                        setControlProperty('pCONTRACTS', 'showitem', 'pContrPatient');
                                        setControlProperty('pCONTRACTS', 'showitem', 'pInf');
                                        setControlProperty('pCONTRACTS', 'showitem', 'pContrOper');
                                        setControlProperty('pCONTRACTS', 'showitem', 'pSEPARETERep');
                                        setControlProperty('pCONTRACTS', 'hideitem', 'pListServs');
                                    }
                                }
                                else {
                                    setControlProperty('pCONTRACTS', 'hideitem', 'pEDIT_CONTRACT');
                                    setControlProperty('pCONTRACTS', 'hideitem', 'pDEL_CONTRACT');
                                    setControlProperty('pCONTRACTS', 'hideitem', 'pCLOSE_CONTRACT');
                                    setControlProperty('pCONTRACTS', 'hideitem', 'pListServs');

                                    setControlProperty('pCONTRACTS', 'hideitem', 'pNULL_CONTRACT');
                                    setControlProperty('pCONTRACTS', 'hideitem', 'pCANCELNULL_CONTRACT');
                                    setControlProperty('pCONTRACTS', 'hideitem', 'pPAY_CONTRACT');
                                    setControlProperty('pCONTRACTS', 'hideitem', 'pContrPatient');
                                    setControlProperty('pCONTRACTS', 'hideitem', 'pInf');
                                    setControlProperty('pCONTRACTS', 'hideitem', 'pContrOper');
                                    setControlProperty('pCONTRACTS', 'hideitem', 'pSEPARETERep');
                                    setControlProperty('pCONTRACTS', 'hideitem', 'pSEPARETENull');
                                    setControlProperty('pCONTRACTS', 'hideitem', 'pPrintTaxNote');
                                    setControlProperty('pCONTRACTS', 'hideitem', 'pPrintReceipt');
                                }
                            }
                            Form.AddContract = function () {
                                setVar('PRIMARY', null);
                                setVar('CONTRACTS_ID', null);
                                setVar('AGENT_ID', getVar('AGENT'));
                                setVar('CONTRACT_TYPE_CODE', 1);
                                openWindow('Contracts/contracts_edit', true)
                                        .addListener('onclose',
                                                function () {
                                                    if (getVar('ModalResult', 1) == 1) {
                                                        setControlProperty('GRID_CONTRACTS', 'locate', getVar("newid", 1), 1);
                                                        refreshDataSet('DS_CONTRACTS', true, 1);
                                                    }
                                                },
                                                null,
                                                false);
                            }
                            Form.AddDmsDirection = function () {
                                setVar('JIRIC_FLAG', 0);
                                setVar('AMI_DIR_ID', null); //
                                setVar('PATIENT', getVar('PERSMEDCARD'));
                                openWindow('Directions/select_patient_ami_direct_edit', true, 475, 328)
                                        .addListener('onclose',
                                                function () {
                                                    if (getVar('ModalResult', 1) == 1) {
                                                        setControlProperty('GRID_CONTRACTS', 'locate', getVar("newid", 1), 1);
                                                        refreshDataSet('DS_CONTRACTS', true, 1);
                                                    }
                                                },
                                                null,
                                                false);
                            }
                            Form.AddDirection = function () {
                                setVar('JIRIC_FLAG', 1);
                                var data = getControlProperty('GRID_CONTRACTS', 'data');
                                setVar('PATIENT', getVar('PERSMEDCARD'));
                                setVar('AMI_DIR_ID', null);
                                openWindow('Directions/select_patient_ami_direct_edit', true, 475, 328)
                                        .addListener('onclose',
                                                function () {
                                                    if (getVar('ModalResult', 1) == 1) {
                                                        setControlProperty('GRID_CONTRACTS', 'locate', getVar("newid", 1), 1);
                                                        refreshDataSet('DS_CONTRACTS', true, 1);
                                                    }
                                                },
                                                null,
                                                false);
                            }
                            Form.EditContract = function () {
                                setVar('LOCATE', getValue('GRID_CONTRACTS'));
                                var data = getControlProperty('GRID_CONTRACTS', 'data');
                                if (data['AMI_FLAG'] == 1) { //направление
                                    setVar('JIRIC_FLAG', 0);
                                    if (data['CONTRACT_TYPE'] == 2)setVar('JIRIC_FLAG', 1);
                                    setVar('CONTR_AMI_DIRECTS_ID', data['AMI_ID']);
                                    setVar('AMI_DIR_ID', data['AMI_ID']);
                                    setVar('PMC_AGENT_ID', getVar('AGENT')); // копия переменной для формы contr_ami_directs_edit
                                    openWindow('Contracts/contr_ami_directs/contr_ami_directs_edit', true, 455, 328)
                                            .addListener('onclose',
                                                    function () {
                                                        if (getVar('ModalResult', 1) == 1) {
                                                            setControlProperty('GRID_CONTRACTS', 'locate', getVar("LOCATE", 1), 1);
                                                            refreshDataSet('DS_CONTRACTS', true, 1);
                                                        }
                                                        setVar('CONTR_AMI_DIRECTS_ID', null, 1);
                                                    },
                                                    null,
                                                    false);
                                }
                                else {
                                    //договор
                                    setVar('PRIMARY', getValue('GRID_CONTRACTS'));
                                    setVar('CONTRACT_TYPE_CODE', data['CONTRACT_TYPE']);
                                    openWindow('Contracts/contracts_edit', true)
                                            .addListener('onclose',
                                                    function () {
                                                        if (getVar('ModalResult', 1) == 1) {
                                                            setControlProperty('GRID_CONTRACTS', 'locate', getVar("LOCATE", 1), 1);
                                                            refreshDataSet('DS_CONTRACTS', true, 1);
                                                        }
                                                        setVar('PRIMARY', null, 1);
                                                        setVar('CONTRACT_TYPE_CODE', null, 1);
                                                    },
                                                    null,
                                                    false);
                                }
                            }
                            Form.DelAmiOrContract = function () {
                                if (confirm('Вы действительно хотите удалить запись?')) {
                                    var data = getControlProperty('GRID_CONTRACTS', 'data');
                                    if (data['AMI_FLAG'] == 1) {
                                        setVar('AMI_ID', data['AMI_ID']);
                                        executeAction('DEL_AMI_DIRECTS', function () {
                                            refreshDataSet('DS_CONTRACTS');
                                        });
                                    }
                                    else {
                                        executeAction('DEL_CONTRACTS', function () {
                                            refreshDataSet('DS_CONTRACTS');
                                        });
                                    }
                                }
                            }
                            Form.CloseAmiOrContract = function () {
                                setVar('DATE', getVar('SYSDATE'));
                                setVar('LOCATE', getValue('GRID_CONTRACTS'));
                                openWindow('PersonalAccount/select_date', true, 260, 100)
                                        .addListener('onclose',
                                                function () {
                                                    if (getVar('DateModalResult', 1) == 1) {
                                                        var data = getControlProperty('GRID_CONTRACTS', 'data', 1);
                                                        if (data['AMI_FLAG'] == 1) { //Закрыть на направлении
                                                            setVar('AMI_ID', data['AMI_ID']);
                                                            base(1).CloseAmi();
                                                        }
                                                        else //Закрыть на договоре
                                                        {
                                                            base(1).CloseContract();
                                                        }
                                                    }
                                                },
                                                null,
                                                false);
                            }
                            Form.CloseAmi = function () {
                                setVar('IS_ACTIVE', 0);
                                setVar('LOCATE', getValue('GRID_CONTRACTS'));
                                executeAction('AMI_CLOSE_DIRECT', function () {
                                    if (getValue('IS_ACTIVE_CONTRACT') == 0)setControlProperty('GRID_CONTRACTS', 'locate', getVar("LOCATE"));
                                    refreshDataSet('DS_CONTRACTS');
                                });
                            }
                            Form.CloseContract = function () {
                                setVar('LOCATE', getValue('GRID_CONTRACTS'));
                                executeAction('CONTRACT_CLOSE', function () {
                                    if (getValue('IS_ACTIVE_CONTRACT') == 0)setControlProperty('GRID_CONTRACTS', 'locate', getVar("LOCATE"));
                                    refreshDataSet('DS_CONTRACTS');
                                });
                            }

                            Form.NullContract = function () {
                                setVar('CONTRACT_STATUS', 1);
                                setVar('LOCATE', getValue('GRID_CONTRACTS'));
                                executeAction('CONTRACT_NULL', function () {
                                    if (getValue('IS_ACTIVE_CONTRACT') == 0)setControlProperty('GRID_CONTRACTS', 'locate', getVar("LOCATE"));
                                    refreshDataSet('DS_CONTRACTS');
                                });
                            }
                            Form.CancelNullContract = function () {
                                setVar('CONTRACT_STATUS', 0);
                                setVar('LOCATE', getValue('GRID_CONTRACTS'));
                                executeAction('CONTRACT_NULL', function () {
                                    setControlProperty('GRID_CONTRACTS', 'locate', getVar("LOCATE"));
                                    refreshDataSet('DS_CONTRACTS');
                                });
                            }

                            Form.PayContract = function () {
                                var data = getControlProperty('GRID_CONTRACTS', 'data');
                                setVar('SUMM_TO_PAY_CONTR', data['DEBT_SUMM']);
                                setVar('CONTARCT_ID', getValue('GRID_CONTRACTS'));
                                openWindow('Cash/set_pay_contract', true, 654, 247)
                                        .addListener('onclose',
                                                function () {
                                                    if (getVar('ModalResult', 1) == 1) {
                                                        setControlProperty('GRID_CONTRACTS', 'locate', getVar("CONTARCT_ID", 1), 1);
                                                        refreshDataSet('DS_CONTRACTS', true, 1);
                                                        refreshDataSet('DS_PAYMENT_JOURNAL', true, 1);
                                                    }
                                                },
                                                null,
                                                false);
                            }
                            ]]>
                        </component>
                        <component cmptype="Action" name="DEL_CONTRACTS" unit="CONTRACTS" action="DELETE">
                            <component cmptype="ActionVar" name="PNLPU" src="LPU" srctype="session"/>
                            <component cmptype="ActionVar" name="PNID" src="GRID_CONTRACTS" srctype="ctrl" get="var1"/>
                        </component>
                        <component cmptype="Action" name="DEL_AMI_DIRECTS" unit="CONTR_AMI_DIRECTS" action="DELETE">
                            <component cmptype="ActionVar" name="PNLPU" src="LPU" srctype="session"/>
                            <component cmptype="ActionVar" name="PNID" src="AMI_ID" srctype="var" get="var1"/>
                        </component>
                        <!--	Закрыть направление	-->
                        <component cmptype="Action" name="AMI_CLOSE_DIRECT" unit="CONTR_AMI_DIRECTS" action="CLOSE_DIRECT">
                            <component cmptype="ActionVar" name="pnLPU" src="LPU" srctype="session"/>
                            <component cmptype="ActionVar" name="pnID" src="AMI_ID" srctype="var" get="var1"/>
                            <component cmptype="ActionVar" name="pdEND_DATE" src="DATE" srctype="var" get="var2"/>
                            <component cmptype="ActionVar" name="pnIS_ACTIVE" src="IS_ACTIVE" srctype="var" get="var3"/>
                        </component>
                        <!--	Закрыть договор	-->
                        <component cmptype="Action" name="CONTRACT_CLOSE" unit="CONTRACTS" action="SET_END_DATE">
                            <component cmptype="ActionVar" name="pnID" src="GRID_CONTRACTS" srctype="ctrl" get="var1"/>
                            <component cmptype="ActionVar" name="pnLPU" src="LPU" srctype="session"/>
                            <component cmptype="ActionVar" name="PDDATE_END" src="DATE" srctype="var" get="var2"/>
                        </component>
                        <!--	Аннулировать договор	-->
                        <component cmptype="Action" name="CONTRACT_NULL" unit="CONTRACTS" action="SET_STATUS">
                            <component cmptype="ActionVar" name="pnID" src="GRID_CONTRACTS" srctype="ctrl" get="var1"/>
                            <component cmptype="ActionVar" name="pnLPU" src="LPU" srctype="session"/>
                            <component cmptype="ActionVar" name="pnSTATUS" src="CONTRACT_STATUS" srctype="var" get="var2"/>
                        </component>
                    </td>
                    <td style="width:40%;height:100%;" colspan="2">
                        <component cmptype="DataSet" name="DS_CONTRACT_PAYMENTS" activateoncreate="false" mode="Range" compile="true">
                            <![CDATA[
                            select t.CP_ID,
                                   t.SIS_OPEN,
                                   t.AMI_ID,
                                   t.AMI_STATUS,
                                   t.AMI_SUMM,
                                   t.PAYMENT_KIND_ID,
                                   t.PAYMENT_KIND_NAME,
                                   t.DOC_PREF_NUMB,
                                   t.DOC_DATE,
                                   t.AGENT_ID,
                                   t.AGENT_NAME,
                                   t.CONTRACT_SUMM,
                                   t.DEBT_SUMM,
                                   t.DATE_BEGIN,
                                   t.DATE_END,
                                   t.CONTRACT_TYPE,
                                   t.DIR_SERV_PAYMENT,
                                   t.SERVICE,
                                   t.PRICE,
                                   t.QUANT,
                                   t.PATIENT,
                                   t.CP_DEBT_SUMM,
                                   t.PAID_SUMM,
                                   t.STATUS,
                                   t.SSTATUS,
                                   t.SUMM,
                                   t.DISEASECASE,
                                   t.DISEASECASE_TYPE,
                                   t.RJ_STATUS,
                                   t.sRJ_STATUS,
                                   t.NRJ_STATUS,
                                   t.SE_CODE SERVICE_CODE,
                                   t.SE_NAME SERVICE_NAME,
                                   t.ID CONTRACT_ID
                              from D_V_PFA_CONTRACTS t
                             where t.ID = :ID
                               and t.PATIENT = :PATIENT_ID
                            @if (:IS_ACTIVE == 1){
                               and t.STATUS = 0
                            @}
                            @if (:DISEASECASE ){
                               and t.DISEASECASE = :DISEASECASE
                            @}
                            @if (:DISEASECASE_TYPE==-1){
                                and t.DISEASECASE is null
                            @}else if (:DISEASECASE_TYPE){
                                and t.DISEASECASE_TYPE = :DISEASECASE_TYPE
                            @}
                               and (t.AMI_ID = :AMI_ID or t.AMI_ID is null)
                               and t.CP_ID is not null
                            ]]>
                            <component cmptype="Variable" name="PATIENT_ID"       src="PERSMEDCARD"        srctype="var"  get="patient"/>
                            <component cmptype="Variable" name="ID"               src="CONTRACT_ID"        srctype="var"  get="contract_id"/>
                            <component cmptype="Variable" name="AMI_ID"           src="AMI_ID"             srctype="var"  get="ami_id"/>
                            <component cmptype="Variable" name="DISEASECASE"      src="DISEASECASES"       srctype="ctrl" get="diseasecase"/>
                            <component cmptype="Variable" name="DISEASECASE_TYPE" src="DISEASECASE_TYPE"   srctype="ctrl" get="diseasecase_type"/>
                            <component cmptype="Variable" name="IS_ACTIVE"        src="IS_ACTIVE_CONTRACT" srctype="ctrl" get="is_active"/>
                            <component cmptype="Variable" type="count"            src="r1c"                srctype="var"  default="10"/>
                             <component cmptype="Variable" type="start"           src="r1s"                srctype="var"  default="1"/>
                        </component>
                        <component cmptype="Grid" name="GRID_CONTRACT_PAYMENTS" dataset="DS_CONTRACT_PAYMENTS" field="CP_ID" selectlist="CP_ID"
                                    calc_height="parent" returnfield="CP_ID" white_space_nowrap="true" grid_caption="Услуги в договоре" hide_filter="true" onclone="base().PaintOnClone(_dataArray,this);" ondblclick="base().setPositionGridContarcts();">
                            <component cmptype="Column" name="SER_CODE" caption="Услуга" field="SERVICE_CODE" sort="SERVICE_CODE" width="60" filter="SERVICE_CODE"/>
                            <component cmptype="Column" name="SER" caption="&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;Наименование&#160;услуги&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;" field="SERVICE_NAME" sort="SERVICE_NAME" width="200" filter="SERVICE_NAME"/>
                            <component cmptype="Column" name="ctrlPRICE" caption="Цена" field="PRICE" sort="PRICE" width="100" align="right"/>
                            <component cmptype="Column" name="ctrlQUANT" caption="Кол-во" field="QUANT" sort="QUANT" width="100" align="right"/>
                            <component cmptype="Column" name="ctrlSUMM" caption="Сумма" field="SUMM" align="right"/>
                            <component cmptype="Column" caption="К&#160;оплате" field="CP_DEBT_SUMM" align="right"/>
                            <component cmptype="Column" caption="Оплачено" field="PAID_SUMM" align="right"/>>
                            <!--0, 'Не оказана', 1, 'Оказана', 2, 'Отменена', null, 'Нет связи'-->
                            <component cmptype="Column" caption="Статус" field="SRJ_STATUS" filter="NRJ_STATUS" filterkind="cmbo" fcontent="0|Не оказана;1|Оказана;2|Отменена;-1|Нет связи"/>

                            <component cmptype="Column" caption="Аннулировано" field="SSTATUS" filter="STATUS" filterkind="cmbo" fcontent="1|Аннулирован;0|Не аннулирован"/>
                            <component cmptype="GridFooter">
                                <component cmptype="Range" insteadrefresh="InsteadRefresh(this);" id="range1" count="10" varstart="r1s" varcount="r1c" valuecount="10" valuestart="1" />
                            </component>
                        </component>
                        <component cmptype="Popup" name="pCONTRACT_PAYMENTS" popupobject="GRID_CONTRACT_PAYMENTS" onpopup="base().onPopupContractsPayments();">
                            <component cmptype="PopupItem" name="pREFRESH_CONTRACT_PAYMENTS" caption="Обновить" onclick="setControlProperty('GRID_CONTRACT_PAYMENTS','locate',getValue('GRID_CONTRACT_PAYMENTS'));refreshDataSet('DS_CONTRACT_PAYMENTS');" cssimg="refresh"/>
                            <component cmptype="PopupItem" name="pSEPARETE" caption="-"/>
                            <component cmptype="PopupItem" name="pADD_CONTRACT_PAYMENT" caption="Добавить" onclick="base().AddContractPayments();" cssimg="insert"/>
                            <component cmptype="PopupItem" name="pADD_CONTRACT_PAYMENT" caption="Массовое добавление" onclick="base().AddServ();" cssimg="insert"/>
                            <component cmptype="PopupItem" name="pEDIT_CONTRACT_PAYMENT" caption="Редактировать" onclick="base().EditContractPayments();" cssimg="edit"/>
                            <component cmptype="PopupItem" name="pDEL_CONTRACT_PAYMENT" caption="Удалить" onclick="base().DelContractPayments();" cssimg="delete"/>

                            <component cmptype="PopupItem" name="pSEPARETERep" caption="-"/>
                            <component cmptype="PopupItem" name="pContrPay" caption="Печать контракта"  onclick="base().PrintContractPay()" cssimg="print"/>
                            <component cmptype="PopupItem" name="pContrOper" caption="Печать контракта на операцию"  onclick="base().PrintContractOperPay()" cssimg="print"/>
                            <component cmptype="PopupItem" name="pInfPay"  caption="Печать информационного согласия" onclick="base().PrintAgreementPay();" cssimg="print"/>

                            <component cmptype="PopupItem" name="pSEPARETENull" caption="-"/>
                            <component cmptype="PopupItem" name="pPAY_CONTRACT_PAYMENT" caption="Оплатить услугу" onclick="base().PayContractPayments();" cssimg="insert"/>
                            <component cmptype="PopupItem" name="pRETERN_CONTRACT_PAYMENT"  caption="Вернуть деньги" onclick="base().GetBackPayContractPayments();" cssimg="insert"/>
                            <component cmptype="PopupItem" name="pMOVE_CONTRACT_PAYMENT" caption="Переместить из договора" onclick="base().MoveContractPayments();" cssimg="move"/>
                            <component cmptype="PopupItem" name="pMOVE_OUT_CONTRACT_PAYMENT" caption="Переместить в договор" onclick="base().MoveOutContractPayments();" cssimg="move"/>
                            <component cmptype="PopupItem" name="pNULL_CONTRACT_PAYMENT"  caption="Аннулировать" onclick="base().NullContractPayments();" cssimg="off"/>
                            <component cmptype="PopupItem" name="pCANCELNULL_CONTRACT_PAYMENT" caption="Отменить аннулирование" onclick="base().CancelNullContractPayments();" cssimg="off"/>
                        </component>
                        <component cmptype="AutoPopupMenu" unit="CONTRACT_PAYMENTS" all="true" join_menu="pCONTRACT_PAYMENTS" popupobject="GRID_CONTRACT_PAYMENTS"/>
                        <component cmptype="Action" name="findPositionRendering" mode="post">
                            begin
                                select t.PID
                                  into :FAC_ACCOUNT_ID
                                  from D_V_RJ_FACC_PAYMENTS t
                                 where t.CONTRACT_PAYMENT  = :CP;
                                exception when OTHERS then
                                  :FAC_ACCOUNT_ID :=null;
                            end;
                            <component cmptype="ActionVar" name="FAC_ACCOUNT_ID" src="FAC_ACCOUNT_ID"         srctype="var"  put="v3" len="20"/>
                            <component cmptype="ActionVar" name="CP"             src="GRID_CONTRACT_PAYMENTS" srctype="ctrl" get="v1"/>
                        </component>
                        <component cmptype="Action" name="findPositionPayment" mode="post">
                            begin
                                select min(t.PID)
                                  into :PAY_JOURNAL_ID
                                  from D_V_PJ_CON_PAYMENTS t
                                 where t.CONTRACT_PAYMENT = :CP;
                                exception when NO_DATA_FOUND then
                                  :PAY_JOURNAL_ID := null;
                            end;
                            <component cmptype="ActionVar" name="PAY_JOURNAL_ID" src="PAY_JOURNAL_ID"         srctype="var"  put="v3" len="20"/>
                            <component cmptype="ActionVar" name="CP"             src="GRID_CONTRACT_PAYMENTS" srctype="ctrl" get="v1"/>
                        </component>
                        <component cmptype="Script">
                            Form.onCLoseContractPayment = function () {
                                if (getVar('ModalResult') == 1) {
                                    setControlProperty('GRID_CONTRACT_PAYMENTS', 'locate', getVar('C_P_EDIT_ID'));
                                    refreshDataSet('DS_CONTRACT_PAYMENTS');
                                }
                            }
                            Form.FixSummContractPayments = function () {
                                setVar('CONTR_PAY_ID', getValue('GRID_CONTRACT_PAYMENTS'));
                                setVar('PATIENT_ID', getVar('PERSMEDCARD', 1));
                                openWindow('Cash/fix_summ', true, 540, 193)
                                        .addListener('onclose',
                                                function () {
                                                    if (getVar('ModalResult', 1) == 1) {
                                                        setControlProperty('GRID_CONTRACT_PAYMENTS', 'locate', getVar('newid', 1), 1);
                                                        base(1).RefreshContractsPaymentDataSets();
                                                    }
                                                },
                                                null,
                                                false);
                            }
                            Form.setPositionGridContarcts = function () {
                                if (!empty(getValue('GRID_RENDERING_JOURNAL'))) {
                                    executeAction('findPositionRendering', function () {
                                        if (empty(getVar('FAC_ACCOUNT_ID')))return;
                                        setControlProperty('GRID_RENDERING_JOURNAL', 'locate', getVar('FAC_ACCOUNT_ID'));
                                        refreshDataSet('DS_RENDERING_JOURNAL');
                                    });
                                }
                                //оплаты
                                if (!empty(getValue('GRID_PAYMENT_JOURNAL'))) {
                                    executeAction('findPositionPayment', function () {
                                        if (empty(getVar('PAY_JOURNAL_ID')))return;
                                        setControlProperty('GRID_PAYMENT_JOURNAL', 'locate', getVar('PAY_JOURNAL_ID'));
                                        refreshDataSet('DS_PAYMENT_JOURNAL');
                                    });
                                }
                            }
                            Form.PrintContractPay = function () {
                                var data = getControlProperty('GRID_CONTRACT_PAYMENTS', 'data');
                                setVar('REP_ID', data['CP_ID']);
                                setVar('ID', data['CP_ID']);
                                setVar('FLAG', 'CP');
                                printReportByCode('patient_contract_pay_web');
                            }
                            Form.PrintAgreementPay = function () {
                                var data = getControlProperty('GRID_CONTRACT_PAYMENTS', 'data');
                                setVar('ID', data['CP_ID']);
                                printReportByCode('patient_agreement_pay_web');
                            }
                            Form.PrintAgreement = function () {
                                var data = getControlProperty('GRID_RENDERING_JOURNAL', 'data');
                                setVar('REP_ID', data['DIRECTION_SERVICE']);
                                setVar('AGENT_ID', getVar('AGENT'));
                                setVar('PAT_ID', getVar('PERSMEDCARD'));
                                printReportByCode('reception_agreement');
                            }
                            Form.PrintContractOperPay = function () {
                                setVar('REP_ID', getControlProperty('GRID_CONTRACT_PAYMENTS', 'data')['CP_ID']);
                                printReportByCode('contract_operation_pay_web');
                            }
                            Form.PaintOnClone = function (_dataArray, _activRow) {
                                var _domObject = _activRow;
                                if (_dataArray['SRJ_STATUS'] == 'Нет связи') {
                                    getControlByName('SER').style.backgroundColor = '#FFFF99';
                                    getControlByName('SER_CODE').style.backgroundColor = '#FFFF99';
                                }
                                else {
                                    getControlByName('SER').style.backgroundColor = '';
                                    getControlByName('SER_CODE').style.backgroundColor = '';
                                }
                            }
                            Form.onPopupContractsPayments = function () {
                                var data_contr;
                                if (!empty(getValue('GRID_CONTRACT_PAYMENTS'))) {
                                    setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pContrPay');
                                    setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pInfPay');
                                    setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pContrOper');
                                    setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pSEPARETERep');

                                    setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pEDIT_CONTRACT_PAYMENT');
                                    setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pDEL_CONTRACT_PAYMENT');
                                    setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pSEPARETENull');
                                    var data = getControlProperty('GRID_CONTRACT_PAYMENTS', 'data');
                                    if (data['STATUS'] == 1) {
                                        setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pNULL_CONTRACT_PAYMENT');
                                        setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pCANCELNULL_CONTRACT_PAYMENT');
                                    }
                                    else {
                                        setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pNULL_CONTRACT_PAYMENT');
                                        setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pCANCELNULL_CONTRACT_PAYMENT');
                                    }
                                    if (parseToJSFloat(data['PAID_SUMM']) &gt; 0) {
                                        setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pRETERN_CONTRACT_PAYMENT');
                                        if (parseToJSFloat(data['CP_DEBT_SUMM']) &gt; 0)setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pPAY_CONTRACT_PAYMENT');
                                        else setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pPAY_CONTRACT_PAYMENT');
                                    }
                                    else {
                                        setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pRETERN_CONTRACT_PAYMENT');
                                        setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pPAY_CONTRACT_PAYMENT');
                                    }
                                    if (parseToJSFloat(data['SUMM']) == 0) {
                                        setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pPAY_CONTRACT_PAYMENT');
                                    }
                                    if (!empty(getVar('CONTRACT_PAY_ID_FOR_MOVE')) &amp;&amp; getVar('CONTRACT_FOR_MOVE_PAYMENT_KIND') == getVar('SELECTED_PAYMENT_TYPE')) {
                                        setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pMOVE_CONTRACT_PAYMENT');
                                        setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pMOVE_OUT_CONTRACT_PAYMENT');
                                    }
                                    else {
                                        setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pMOVE_CONTRACT_PAYMENT');
                                        setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pMOVE_OUT_CONTRACT_PAYMENT');
                                    }
                                }
                                else {
                                    setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pContrPay');
                                    setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pInfPay');
                                    setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pContrOper');
                                    setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pSEPARETERep');

                                    setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pEDIT_CONTRACT_PAYMENT');
                                    setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pDEL_CONTRACT_PAYMENT');

                                    setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pPAY_CONTRACT_PAYMENT');
                                    setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pRETERN_CONTRACT_PAYMENT');
                                    setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pMOVE_CONTRACT_PAYMENT');
                                    setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pSEPARETENull');
                                    if (empty(getVar('CONTRACT_PAY_ID_FOR_MOVE'))) {
                                        setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pMOVE_OUT_CONTRACT_PAYMENT');
                                    } else {
                                        setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pMOVE_OUT_CONTRACT_PAYMENT');
                                    }
                                    setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pNULL_CONTRACT_PAYMENT');
                                    setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pCANCELNULL_CONTRACT_PAYMENT');
                                }
                                if (!empty(getValue('GRID_CONTRACTS'))) {
                                    setControlProperty('pCONTRACT_PAYMENTS', 'showitem', 'pADD_CONTRACT_PAYMENT');
                                    data_contr = getControlProperty('GRID_CONTRACTS', 'data');
                                    if (data_contr['AMI_FLAG'] == 1) {
                                        // setControlProperty('pCONTRACT_PAYMENTS','hideitem','pMOVE_OUT_CONTRACT_PAYMENT');
                                        // setControlProperty('pCONTRACT_PAYMENTS','hideitem','pMOVE_CONTRACT_PAYMENT');
                                        // setControlProperty('pCONTRACT_PAYMENTS','hideitem','pPAY_CONTRACT_PAYMENT');
                                    }
                                } else {
                                    setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pADD_CONTRACT_PAYMENT');
                                    setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pMOVE_OUT_CONTRACT_PAYMENT');
                                    setControlProperty('pCONTRACT_PAYMENTS', 'hideitem', 'pMOVE_CONTRACT_PAYMENT');
                                }
                            }
                            Form.AddContractPayments = function () {
                                var data = getControlProperty('GRID_CONTRACTS', 'data');
                                setVar('C_P_PID', data['ID']);
                                setVar('C_P_EDIT_ID', null);
                                setVar('CONTR_TYPE_ID', data['CONTRACT_TYPE']);
                                setVar('P_K_ID', data['PAYMENT_KIND_ID']); //Вид оплаты
                                setVar('AMI_DIR_ID', data['AMI_ID']);
                                if (data['AMI_ID']) setVar('AGENT_AMI', data['AGENT_ID']);
                                else setVar('AGENT_AMI', null);
                                setVar('DISEASECASE', getValue('DISEASECASES'));
                                //openWindow('PersonalAccount/for_search_contract_payments_edit', true, 540,193)
                                openWindow('ContractPayments/contract_payments_edit', true, 590, 471)
                                        .addListener('onclose',
                                                function () {
                                                    if (getVar('ModalResult', 1) == 1) {
                                                        setVar('Save', null);
                                                        setControlProperty('GRID_CONTRACT_PAYMENTS', 'locate', getVar('newid', 1), 1);
                                                        base(1).RefreshContractsPaymentDataSets();
                                                    }
                                                    setVar('DISEASECASE', null);
                                                },
                                                null,
                                                false);
                            }
                            Form.EditContractPayments = function () {
                                var data = getControlProperty('GRID_CONTRACTS', 'data');
                                setVar('C_P_PID', data['ID']);
                                setVar('C_P_EDIT_ID', getValue('GRID_CONTRACT_PAYMENTS'));

                                var data = getControlProperty('GRID_CONTRACT_PAYMENTS', 'data');
                                setVar('CONTR_TYPE_ID', data['CONTRACT_TYPE']);
                                setVar('P_K_ID', data['PAYMENT_KIND_ID']);
                                setVar('AMI_DIR_ID', data['AMI_ID']);
                                if (data['AMI_ID']) setVar('AGENT_AMI', data['AGENT_ID']);
                                else setVar('AGENT_AMI', null);

                                //openWindow('PersonalAccount/for_search_contract_payments_edit', true, 540,193)
                                openWindow('ContractPayments/contract_payments_edit', true, 590, 471)
                                        .addListener('onclose',
                                                function () {
                                                    if (getVar('ModalResult', 1) == 1) {
                                                        setVar('Save', null);
                                                        setControlProperty('GRID_CONTRACT_PAYMENTS', 'locate', getValue('GRID_CONTRACT_PAYMENTS', 1), 1);
                                                        base(1).RefreshContractsPaymentDataSets();
                                                    }
                                                },
                                                null,
                                                false);
                            }
                            Form.RefreshContractsPaymentDataSets = function () {
                                setControlProperty('GRID_CONTRACTS', 'locate', getValue("GRID_CONTRACTS"));
                                refreshDataSet('DS_CONTRACTS');
                                refreshDataSet('DS_PAYMENT_JOURNAL');
                            }

                            Form.DelContractPayments = function () {
                                if (confirm('Вы действительно хотите удалить запись?')) {
                                    if (!empty(getValue('GRID_CONTRACT_PAYMENTS_SelectList'))) {
                                        setVar('CONTRACT_PAYMENTS_ID', getValue('GRID_CONTRACT_PAYMENTS_SelectList'));
                                    }
                                    else {
                                        setVar('CONTRACT_PAYMENTS_ID', getValue('GRID_CONTRACT_PAYMENTS'));
                                    }
                                    executeAction('DEL_CONTRACT_PAYMENTS', function () {
                                        setControlProperty('GRID_CONTRACTS', 'locate', getValue("GRID_CONTRACTS"));
                                        //setControlProperty('GRID_PAYMENT_JOURNAL','locate',getValue("GRID_PAYMENT_JOURNAL"));
                                        refreshDataSet('DS_CONTRACTS');
                                        refreshDataSet('DS_PAYMENT_JOURNAL');
                                        SelectList_uncheckItems('GRID_CONTRACT_PAYMENTS_SelectList');
                                    });
                                }
                            }
                            Form.PayContractPayments = function () {
                                var data = getControlProperty('GRID_CONTRACT_PAYMENTS', 'data');
                                setVar('SUMM_TO_PAY', data['CP_DEBT_SUMM']);
                                setVar('CONTR_PAY_ID', getValue('GRID_CONTRACT_PAYMENTS'));
                                setVar('PAY_REASON', data['SERVICE_NAME']); //Код_Услуги Название услуги

                                openWindow('Cash/set_pay_contract_spec', true, 608, 290)
                                        .addListener('onclose',
                                                function () {
                                                    if (getVar('ModalResult', 1) == 1) {
                                                        setControlProperty('GRID_CONTRACT_PAYMENTS', 'locate', getValue('GRID_CONTRACT_PAYMENTS', 1), 1);
                                                        base(1).RefreshContractsPaymentDataSets();
                                                    }
                                                },
                                                null,
                                                false);
                            }
                            Form.GetBackPayContractPayments = function () {
                                //Показывается если оплачено > 0
                                var data = getControlProperty('GRID_CONTRACT_PAYMENTS', 'data');
                                setVar('PAID_SUMM', data['PAID_SUMM']);

                                setVar('CONTR_PAY_ID', getValue('GRID_CONTRACT_PAYMENTS'));
                                setVar('PAY_REASON', data['SERVICE_NAME']); //Код_Услуги Название услуги

                                openWindow('Cash/get_back_pay_cs', true, 608, 290)
                                        .addListener('onclose',
                                                function () {
                                                    if (getVar('ModalResult', 1) == 1) {
                                                        setControlProperty('GRID_CONTRACT_PAYMENTS', 'locate', getValue('GRID_CONTRACT_PAYMENTS', 1), 1);
                                                        base(1).RefreshContractsPaymentDataSets();
                                                    }
                                                },
                                                null,
                                                false);
                            }
                            Form.MoveContractPayments = function () {
                                setVar('CONTRACT_PAY_ID_FOR_MOVE', (getValue('GRID_CONTRACT_PAYMENTS_SelectList') == '' ) ? getValue('GRID_CONTRACT_PAYMENTS') : getValue('GRID_CONTRACT_PAYMENTS_SelectList'));
                                var data = getControlProperty('GRID_CONTRACT_PAYMENTS', 'data');
                                setVar('CONTRACT_FOR_MOVE_PAYMENT_KIND', data['PAYMENT_KIND_ID']);
                                setVar('CONTRACT_FOR_MOVE_EXCLUDE_AMI', data['AMI_ID']);

                            }
                            Form.MoveOutContractPayments = function () {
                                if (!empty(getVar('CONTRACT_PAY_ID_FOR_MOVE'))) {
                                    var data = getControlProperty('GRID_CONTRACTS', 'data');
                                    if (data['AMI_FLAG'] == 1) {
                                        setVar('PATIENT', getVar('PERSMEDCARD'));
                                        setVar('PK_ID', getCaption('GRID_CONTRACTS'));
                                        setVar('PAT_AG_ID', getVar('AGENT'));
                                        setVar('moveCONTRACT_ID', data['ID']);
                                        openWindow("PersonalAccount/select_patient_ami_directs", true, 500, 450).addListener('onclose', function () {
                                            if (getVar('ModalResult', 1) == 1) {
                                                setVar('ami_direction', getVar('return_id', 1), 1);
                                                executeAction('ChangeContractAmiDir', function () {
                                                    refreshDataSet('DS_CONTRACT_PAYMENTS', 1);
                                                    setVar('CONTRACT_PAY_ID_FOR_MOVE', null);
                                                }, 0, 0, 1, 1);
                                            }
                                        });
                                    } else {
                                        setControlProperty('GRID_CONTRACT_PAYMENTS', 'locate', getValue('GRID_CONTRACT_PAYMENTS'));
                                        executeAction('CHANGE_CONTRACT', base().RefreshContractsPaymentDataSets);
                                        setVar('CONTRACT_PAY_ID_FOR_MOVE', null);
                                    }
                                    SelectList_uncheckItems('GRID_CONTRACT_PAYMENTS_SelectList', 0)
                                    setValue('GRID_CONTRACT_PAYMENTS_SelectList', null)
                                }
                            }
                            Form.NullContractPayments = function () {
                                setVar('CONTRACT_PAYMENT_STATUS', 1);
                                setControlProperty('GRID_CONTRACT_PAYMENTS', 'locate', getValue('GRID_CONTRACT_PAYMENTS'));
                                executeAction('CONTRACT_PAYMENTS_SET_STATUS', base().RefreshContractsPaymentDataSets);
                            }
                            Form.CancelNullContractPayments = function () {//Отменить анулирование
                                setVar('CONTRACT_PAYMENT_STATUS', 0);
                                setControlProperty('GRID_CONTRACT_PAYMENTS', 'locate', getValue('GRID_CONTRACT_PAYMENTS'));
                                executeAction('CONTRACT_PAYMENTS_SET_STATUS', base().RefreshContractsPaymentDataSets);
                            }
                        </component>
                        <component cmptype="Action" name="DEL_CONTRACT_PAYMENTS" unit="CONTRACT_PAYMENTS" action="DELETE">
                            <component cmptype="ActionVar" name="PNLPU" src="LPU" srctype="session"/>
                            <component cmptype="ActionVar" name="~PNID" src="CONTRACT_PAYMENTS_ID" srctype="var" get="var1"/>
                        </component>
                        <component cmptype="Action" name="ChangeContractAmiDir" object_name="D_PKG_CONTRACT_PAYMENTS.CHANGE_CONTRACT_AMI_DIR">
                            <component cmptype="ActionVar" name="~pnID" src="CONTRACT_PAY_ID_FOR_MOVE" srctype="var" get="id" />
                            <component cmptype="ActionVar" name="pnLPU" src="LPU" srctype="session" get="lpu" />
                            <component cmptype="ActionVar" name="pnCONTRACT" src="moveCONTRACT_ID" srctype="var" get="contract" />
                            <component cmptype="ActionVar" name="pnAMI_DIRECTION" src="ami_direction" srctype="var" get="ami_dir" />
                            <component cmptype="ActionVar" name="pnNEW_ID" src="NEW_ID" srctype="var" put="var3" len="17"/>
                        </component>

                        <!--Аннулировать договор / Отменить анулирование-->
                        <component cmptype="Action" name="CONTRACT_PAYMENTS_SET_STATUS" unit="CONTRACT_PAYMENTS" action="SET_STATUS">
                            <component cmptype="ActionVar" name="pnID" src="GRID_CONTRACT_PAYMENTS" srctype="ctrl" get="var1"/>
                            <component cmptype="ActionVar" name="pnLPU" src="LPU" srctype="session"/>
                            <component cmptype="ActionVar" name="pnSTATUS" src="CONTRACT_PAYMENT_STATUS" srctype="var" get="var2"/>
                        </component>
                        <!--Переместить из договора-->
                        <component cmptype="Action" name="CHANGE_CONTRACT" unit="CONTRACT_PAYMENTS" action="CHANGE_CONTRACT">
                            <component cmptype="ActionVar" name="~pnID" src="CONTRACT_PAY_ID_FOR_MOVE" srctype="var" get="var1"/>
                            <component cmptype="ActionVar" name="pnLPU" src="LPU" srctype="session"/>
                            <component cmptype="ActionVar" name="pnCONTRACT" src="CONTRACT_ID" srctype="var" get="contr_id"/>
                            <component cmptype="ActionVar" name="pnNEW_ID" src="NEW_ID" srctype="var" put="var3" len="17"/>
                        </component>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <component cmptype="PageControl" name="ServPayments" mode="gorizontal">
                            <component cmptype="TabSheet" caption="Назначенные услуги" activ="true">
                                <component cmptype="DataSet" name="DS_RENDERING_JOURNAL" activateoncreate="false" mode="Range" compile="true">
                                    <![CDATA[
                                        select t.ID,
                                               t.SUMM,
                                               t.PRICE,
                                               t.QUANT,
                                               t.VISIT_DATE,
                                               t.VIS_REC_DATE,
                                               t.DISEASECASE,
                                               t.STATUS,
                                               t.SSTATUS,
                                               t.CONTR_SUM,
                                               t.PAYMENT_KIND_NAME,
                                               t.AGENT,
                                               t.PAYMENT_KIND,
                                               t.DC_CONTENT,
                                               t.SERVICE_NAME,
                                               CASE
                                                 WHEN t.SERVICE_NAME is null THEN null
                                                 WHEN length(t.SERVICE_NAME)>70
                                                   THEN substr(t.SERVICE_NAME, 1, 70)||'...'
                                                 ELSE t.SERVICE_NAME
                                               END SERVICE_NAME_SHORT,
                                               t.EMPLOYER_TO_FIO,
                                               t.CABLAB_TO_NAME,
                                               t.DP_NAME,
                                               t.DIRECTION,
                                               decode(:OPT,
                                                0,to_char(t.REC_DATE,'dd.mm.yyyy hh24:mi'),
                                                nvl((select to_char(t.REC_DATE,'dd.mm.yyyy')||' '||to_char(p.OPER_ORDER) from d_v_operations_info p where p.ID = t.DIRECTION_SERVICE), to_char(t.REC_DATE,'dd.mm.yyyy hh24:mi'))
                                                ) DATE1,
                                               t.DIRECTION_SERVICE,
                                               t.REC_DATE
                                         from D_V_PFA_RENDERING_JOURNALS t
                                        where t.AGENT = :AGENT
                                          and t.LPU = :LPU
                                          and t.PAT_LPU = :LPU
                                          and t.FA_LPU = :LPU
                                          and t.FA_AGENT = :AGENT
                                        @if(:PAY_KIND_CHECK == 0){
                                          and t.PAYMENT_KIND = :PAYMENT_KIND_ID
                                        @}
                                        @if (:DATE_BEGIN && :DATE_END){
                                          and (t.VIS_REC_DATE >= :DATE_BEGIN and t.VIS_REC_DATE <=:DATE_END)
                                        @} else  if (:DATE_BEGIN){
                                          and t.VIS_REC_DATE >= :DATE_BEGIN
                                        @}else if (:DATE_END){
                                          and  t.VIS_REC_DATE <=:DATE_END
                                        @}
                                        @if (:DISEASECASE ){
                                          and t.DISEASECASE = :DISEASECASE
                                        @}
                                        @if (:DISEASECASE_TYPE==-1){
                                          and t.DISEASECASE is null
                                        @}else if (:DISEASECASE_TYPE){
                                          and t.DC_TYPE = :DISEASECASE_TYPE
                                        @}

                                    ]]>
                                    <component cmptype="Variable" name="LPU"              src="LPU"                                         srctype="session"/>
                                    <component cmptype="Variable" name="AGENT"            src="AGENT"                                       srctype="var"         get="v0"/>
                                    <component cmptype="Variable" name="IS_ACTIVE"        src="IS_ACTIVE_CONTRACT"                          srctype="ctrl"        get="v1"/>
                                    <component cmptype="Variable" name="DISEASECASE"      src="DISEASECASES"                                srctype="ctrl"        get="v2"/>
                                    <component cmptype="Variable" name="DISEASECASE_TYPE" src="DISEASECASE_TYPE"                            srctype="ctrl"        get="v3"/>
                                    <component cmptype="Variable" name="PAYMENT_KIND_ID"  src="GRID_CONTRACTS"                              srctype="ctrlcaption" get="v4"/>
                                    <component cmptype="Variable" name="PAY_KIND_CHECK"   src="PAY_KIND_CHECK"                              srctype="ctrl"        get="v5"/>
                                    <component cmptype="Variable" name="DATE_BEGIN"       src="DS_CONTRACTS_GRID_DOC_DATE_FilterItem_BEGIN" srctype="ctrl"        get="v6"/>
                                    <component cmptype="Variable" name="DATE_END"         src="DS_CONTRACTS_GRID_DOC_DATE_FilterItem_END"   srctype="ctrl"        get="v7"/>
                                    <component cmptype="Variable" name="OPT"              src="1"                                           srctype="const"       get="opt"/>
                                    <component cmptype="Variable" type="count"            src="r1c"                                         srctype="var"         default="10"/>
                                    <component cmptype="Variable" type="start"            src="r1s"                                         srctype="var"         default="1"/>
                                </component>
                                <component cmptype="CheckBox" name="PAY_KIND_CHECK" caption="Не учитывать вид оплаты" valuechecked="1" valueunchecked="0" onchange="refreshDataSet('DS_RENDERING_JOURNAL');"/>

                                <component cmptype="Grid" name="GRID_RENDERING_JOURNAL"
                                            onclone="base().RenderingJournalPaintOnClone(_dataArray,this);" dataset="DS_RENDERING_JOURNAL" field="ID" returnfield="ID"
                                            width="100%" height="260px" grid_caption="Назначенные услуги"  hide_filter="true">
                                    <component cmptype="Column" caption="Вид&#160;оплаты"
                                                    field="PAYMENT_KIND_NAME" sort="PAYMENT_KIND_NAME" filter="PAYMENT_KIND" filterkind="cmb_unit" funit="PAYMENT_KIND" fmethod="LIST"/>
                                    <component cmptype="Column" name="RJ_SERV" caption="Услуга" field="SERVICE_NAME_SHORT"  sort="SERVICE_NAME"/>
                                    <component cmptype="Column" caption="Случай&#160;заболевания" field="DC_CONTENT"  sort="DC_CONTENT"/>
                                    <component cmptype="Column" caption="Врач" field="EMPLOYER_TO_FIO" sort="EMPLOYER_TO_FIO" width="100" filter="EMPLOYER_TO_FIO"/>
                                    <component cmptype="Column" caption="Кабинет" field="CABLAB_TO_NAME"  sort="CABLAB_TO_NAME"/>
                                    <component cmptype="Column" caption="Статус" field="SSTATUS" filter="STATUS" filterkind="cmbo" fcontent="0|Не оказана;1|Оказана;2|Отменена"/>
                                    <component cmptype="Column" caption="Дата оказания" field="VIS_REC_DATE" sort="VIS_REC_DATE" sortorder="-1" align="center"/>
                                    <component cmptype="Column" caption="Кратность" field="QUANT" align="right"/>
                                    <component cmptype="Column" caption="Цена" field="PRICE" align="right"/>
                                    <component cmptype="Column" caption="Сумма" field="SUMM" align="right"/>
                                    <component cmptype="Column" caption="Сумма, не вкл. в договор" field="CONTR_SUM" name="RJ_CONTR_SUM" align="right"/>
                                    <component cmptype="Column" caption="Отделение" field="DP_NAME" />
                                    <component cmptype="GridFooter">
                                        <component cmptype="Range" insteadrefresh="InsteadRefresh(this);" id="range1" count="10" varstart="r1s" varcount="r1c" valuecount="10" valuestart="1" />
                                    </component>
                                </component>

                                <component cmptype="Popup" name="pRENDERING_JOURNAL" popupobject="GRID_RENDERING_JOURNAL" onpopup="base().OnPopupRenderingJournal();">
                                    <component cmptype="PopupItem" name="pREFRESH_RENDERING_JOURNAL" caption="Обновить" onclick="setControlProperty('GRID_RENDERING_JOURNAL','locate',getValue('GRID_RENDERING_JOURNAL'));refreshDataSet('DS_RENDERING_JOURNAL');" cssimg="refresh"/>
                                    <component cmptype="PopupItem" name="pSEPARETE" caption="-"/>
                                    <component cmptype="PopupItem" name="pADD_LINK_RENDERING_JOURNAL" unitbp="RJ_FACC_PAYMENTS_LINK" caption="Связать с услугой в договоре" onclick="base().AddLinkRenderingJournals();" cssimg="move"/>
                                    <component cmptype="PopupItem" name="pDEL_LINK_RENDERING_JOURNAL" unitbp="RJ_FAC_ACCOUNTS_DEL_LINK" caption="Удалить связь с услугой в договоре" onclick="base().DelLinkRenderingJournals();" cssimg="delete"/>
                                    <component cmptype="PopupItem" name="pADD_SERVICE_RENDERING_JOURNAL" caption="Добавить услугу в договор/направление" onclick="base().AddServRenderingJournal();" cssimg="insert"/>
                                    <component cmptype="PopupItem" name="pPrintAgree" caption="Печать информированного согласия" onclick="base().PrintAgreement();" cssimg="print"/>
                                </component>

                                <component cmptype="AutoPopupMenu" unit="RENDERING_JOURNAL" all="true" join_menu="pRENDERING_JOURNAL" popupobject="GRID_RENDERING_JOURNAL"/>
                                <component cmptype="Script">
                                    Form.RenderingJournalPaintOnClone = function (_dataArray, _activRow) {
                                        var _domObject = _activRow;
                                        if (parseToJSFloat(_dataArray['CONTR_SUM']) &gt; 0) {
                                            getControlByName('RJ_SERV').style.backgroundColor = '#FFFF99';
                                            getControlByName('RJ_CONTR_SUM').style.backgroundColor = '#FFFF99';
                                        }
                                        else {
                                            getControlByName('RJ_SERV').style.backgroundColor = '';
                                            getControlByName('RJ_CONTR_SUM').style.backgroundColor = '';
                                        }
                                    }
                                    Form.OnPopupRenderingJournal = function () {
                                        var data = getControlProperty('GRID_RENDERING_JOURNAL', 'data');
                                        if (!empty(getValue('GRID_RENDERING_JOURNAL'))) {
                                            if (parseToJSFloat(data['CONTR_SUM']) &gt; 0) {
                                                if (!empty(getValue('GRID_CONTRACT_PAYMENTS'))) {
                                                    setControlProperty('pRENDERING_JOURNAL', 'showitem', 'pADD_LINK_RENDERING_JOURNAL');
                                                }
                                                else {
                                                    setControlProperty('pRENDERING_JOURNAL', 'hideitem', 'pADD_LINK_RENDERING_JOURNAL');
                                                    setControlProperty('pRENDERING_JOURNAL', 'hideitem', 'pDEL_LINK_RENDERING_JOURNAL');
                                                }
                                                setControlProperty('pRENDERING_JOURNAL', 'hideitem', 'pDEL_LINK_RENDERING_JOURNAL');
                                                setControlProperty('pRENDERING_JOURNAL', 'showitem', 'pADD_SERVICE_RENDERING_JOURNAL');
                                            }
                                            else {
                                                setControlProperty('pRENDERING_JOURNAL', 'hideitem', 'pADD_LINK_RENDERING_JOURNAL');
                                                setControlProperty('pRENDERING_JOURNAL', 'showitem', 'pDEL_LINK_RENDERING_JOURNAL');
                                                setControlProperty('pRENDERING_JOURNAL', 'hideitem', 'pADD_SERVICE_RENDERING_JOURNAL');
                                            }
                                        }
                                        else {
                                            setControlProperty('pRENDERING_JOURNAL', 'hideitem', 'pADD_LINK_RENDERING_JOURNAL');
                                            setControlProperty('pRENDERING_JOURNAL', 'hideitem', 'pDEL_LINK_RENDERING_JOURNAL');
                                            setControlProperty('pRENDERING_JOURNAL', 'hideitem', 'pADD_SERVICE_RENDERING_JOURNAL');
                                        }
                                    }

                                    //Связать с услугой в договоре
                                    Form.AddLinkRenderingJournals = function () {
                                        var data = getControlProperty('GRID_RENDERING_JOURNAL', 'data');
                                        setVar('RJ_FAC_ACCOUNTS_ID', data['ID']);
                                        executeAction('RJ_LINK', function () {
                                            setVar('LOCATE_RJ', getVar('NEW_ID'));
                                            setVar('NEW_ID', null);
                                            base().RefreshRenderingJournal();
                                        });
                                    }

                                    //Удалить связь с услугой в договоре
                                    Form.DelLinkRenderingJournals = function () {
                                        setVar('LOCATE_RJ', getValue('GRID_RENDERING_JOURNAL'));
                                        var data = getControlProperty('GRID_RENDERING_JOURNAL', 'data');
                                        setVar('RJ_FAC_ACCOUNTS_ID', data['ID']);
                                        executeAction('RJ_DEL_LINK', function () {
                                            base().RefreshRenderingJournal();
                                        });
                                    }

                                    //Добавить услугу в договор
                                    Form.AddServRenderingJournal = function () {
                                        var data1 = getControlProperty('GRID_CONTRACT_PAYMENTS', 'data');

                                        setVar('AMI_DIRECTION', data1['AMI_ID']);
                                        setVar('LOCATE_RJ', getValue('GRID_RENDERING_JOURNAL'));

                                        var data = getControlProperty('GRID_RENDERING_JOURNAL', 'data');
                                        setVar('RJ_FAC_ACCOUNTS_ID', data['ID']);

                                        executeAction('RJ_CREATE_CONTRACT', function () {
                                            base().RefreshRenderingJournal();
                                        });
                                    }
                                    Form.RefreshRenderingJournal = function () {
                                        setControlProperty('GRID_CONTRACTS', 'locate', getValue("GRID_CONTRACTS"));
                                        setControlProperty('GRID_PAYMENT_JOURNAL', 'locate', getValue('GRID_PAYMENT_JOURNAL'));
                                        setControlProperty('GRID_RENDERING_JOURNAL', 'locate', getVar('LOCATE_RJ'));

                                        startMultiDataSetsGroup();
                                        refreshDataSet('DS_CONTRACTS');
                                        refreshDataSet('DS_RENDERING_JOURNAL');
                                        refreshDataSet('DS_PAYMENT_JOURNAL');
                                        endMultiDataSetsGroup();
                                    }

                                    Form.AddServ = function () {
                                        var data = getControlProperty('GRID_CONTRACTS', 'data');
                                        setVar('C_P_PID', data['ID']);
                                        setVar('AMI_DIRECTION', data['AMI_ID']);
                                        openWindow({
                                            name: 'UniversalComposition/UniversalComposition',
                                            unit: 'LPU_SERVICES',
                                            composition: 'SERVICE_ID',
                                            multisel: 'true'
                                        }, true, 920, 470)
                                                .addListener("onclose",
                                                        function () {
                                                            if (getVar("ModalResult", 1) == 1) {
                                                                setVar('SERVICES_ID', getVar('return_id', 1), 1);
                                                                base(1).AddServAction();
                                                            }
                                                        },
                                                        null,
                                                        false);
                                    }
                                    Form.AddServAction = function () {
                                        executeAction("ADDCONTRACTPAYMEBTS", function () {
                                            refreshDataSet("DS_CONTRACT_PAYMENTS", true);
                                        });
                                    }
                                </component>
                                <component cmptype="Action" name="ADDCONTRACTPAYMEBTS" unit="CONTRACT_PAYMENTS" action="INSERT">
                                    <component cmptype="ActionVar" name="pnD_INSERT_ID"      put="v0" len="17"    src="NEW_ID"           srctype="var"/>
                                    <component cmptype="ActionVar" name="pnLPU"                                   src="LPU"              srctype="session"/>
                                    <component cmptype="ActionVar" name="~pnSERVICE"         get="v2"             src="SERVICES_ID"      srctype="var"/>
                                    <component cmptype="ActionVar" name="pnPID" 		     get="varPID"         src="C_P_PID"          srctype="var"/>
                                    <component cmptype="ActionVar" name="PNPATIENT" 	     get="PATI"           src="PERSMEDCARD"      srctype="var"/>
                                    <component cmptype="ActionVar" name="PNDIR_SUMM" 	     get="DIRS"           src="DIR_SUMM_CP"      srctype="var"/>
                                    <component cmptype="ActionVar" name="PNTAXGR" 		     get="TAXG"           src="TAXGR"            srctype="var"/>
                                    <component cmptype="ActionVar" name="PNNDS_SUMM" 	     get="NDSS"           src="NDS_SUMM"         srctype="var"/>
                                    <component cmptype="ActionVar" name="PNPRICE" 		     get="PRIC"           src="PRICE"            srctype="var"/>
                                    <component cmptype="ActionVar" name="PNQUANT" 		     get="QUAN"           src="1"                srctype="const"/>
                                    <component cmptype="ActionVar" name="PNDIR_SERV_PAYMENT" get="DISEPA"         src="DIR_SERV_PAYMENT" srctype="var"/>
                                    <component cmptype="ActionVar" name="PNAMI_DIRECTION"    get="AMI_DIRECTION"  src="AMI_DIRECTION"    srctype="var"/>
                                    <component cmptype="ActionVar" name="PNDISCOUNT_SUMM"    get="DISSUMM"        src="DISCOUNT_SUMM"    srctype="var"/>
                                    <component cmptype="ActionVar" name="pnDISEASECASE" 	 get="DISEASECASE"    src="DISEASECASE"      srctype="var"/>
                                </component>
                                <!--Связать с услугой в договоре-->
                                <component cmptype="Action" name="RJ_DEL_LINK" unit="RJ_FACC_PAYMENTS" action="DEL_LINK">
                                    <component cmptype="ActionVar" name="pnLPU" src="LPU"                srctype="session"/>
                                    <component cmptype="ActionVar" name="pnPID" src="RJ_FAC_ACCOUNTS_ID" srctype="var" get="var0" len="17"/>
                                </component>
                                <!--Удалить связь с услугой в договоре-->
                                <component cmptype="Action" name="RJ_LINK" unit="RJ_FACC_PAYMENTS" action="LINK">
                                    <component cmptype="ActionVar" name="pnD_INSERT_ID" src="NEW_ID" srctype="var" put="var1" len="17"/>
                                    <component cmptype="ActionVar" name="pnLPU" src="LPU" srctype="session"/>
                                    <component cmptype="ActionVar" name="pnCONTRACT_PAYMENT" src="GRID_CONTRACT_PAYMENTS" srctype="ctrl" get="var2"/>
                                    <component cmptype="ActionVar" name="pnPID" src="RJ_FAC_ACCOUNTS_ID" srctype="var" get="rj_id"/>
                                </component>
                                <!--Добавить услугу в договор-->
                                <component cmptype="Action" name="RJ_CREATE_CONTRACT" unit="RJ_FAC_ACCOUNTS" action="CREATE_CONTRACT_PAY">
                                    <component cmptype="ActionVar" name="pnID" src="RJ_FAC_ACCOUNTS_ID" srctype="var" get="rj_id"/>
                                    <component cmptype="ActionVar" name="pnLPU" src="LPU" srctype="session"/>
                                    <component cmptype="ActionVar" name="pnCONTRACT" src="CONTRACT_ID" srctype="var" get="contr_id"/>
                                    <component cmptype="ActionVar" name="pnAMI_DIRECTION" src="AMI_DIRECTION" srctype="var" get="var3"/>
                                </component>
                            </component>
                            <component cmptype="TabSheet" caption="Оплаты">
                                <component cmptype="DataSet" name="DS_PAYMENT_JOURNAL" activateoncreate="false" mode="Range" compile="true">
                                    <![CDATA[
                                            select t.ID,
                                                   t.AGENT,
                                                   t.PAY_DATE,
                                                   t.PAYMENT_METHOD_NAME,
                                                   t.PAYMENT_METHOD_ID,
                                                   t.PAYMENT_REASON_SHORT,
                                                   t.DOC,
                                                   t.sPAY_SUMM,
                                                   t.DISEASESCASES,
                                                   t.PAY_DATE DOC_DATE,
                                                   t.FA_ID,
                                                   D_PKG_PAYMENT_JOURNAL.GET_SUMM(t.ID,:LPU,1) 	NE_ZACHETENO
                                              from D_V_PFA_PAYMENT_JOURNALS t
                                             where t.AGENT       = :AGENT
                                               and t.LPU         = :LPU
                                            @if (:DISEASESCASE ){
                                               and  ( ';'||t.DISEASESCASES||';' like '%;'||to_char(:DISEASESCASE)||';%')
                                            @}
                                            @if (:DISEASECASE_TYPE==-1){
                                               and t.DISEASESCASES is null
                                            @}else if (:DISEASECASE_TYPE){
                                               and ';'||t.DISEASESCASES_TYPES||';' like '%;'||to_char(:DISEASECASE_TYPE)||';%'
                                            @}
                                    ]]>
                                    <component cmptype="Variable" name="AGENT"            src="AGENT"            srctype="var"  get="v0"/>
                                    <component cmptype="Variable" name="LPU"              src="LPU"              srctype="session"/>
                                    <component cmptype="Variable" name="DISEASESCASE"     src="DISEASECASES"     srctype="ctrl" get="v2"/>
                                    <component cmptype="Variable" name="DISEASECASE_TYPE" src="DISEASECASE_TYPE" srctype="ctrl" get="v3"/>
                                    <component cmptype="Variable" type="count"            src="r1c"              srctype="var"  default="10"/>
                                    <component cmptype="Variable" type="start"            src="r1s"              srctype="var"  default="1"/>
                                </component>
                                <component cmptype="Grid" name="GRID_PAYMENT_JOURNAL" dataset="DS_PAYMENT_JOURNAL" field="ID" returnfield="ID"
                                     white_space_nowrap="true" width="1140px" height="272px" grid_caption="Оплаты"  hide_filter="true">
                                    <component cmptype="Column" caption="Дата оплаты" field="PAY_DATE" sort="PAY_DATE" filterkind="perioddate" filter="PAY_DATE" align="center" sortorder="-1"/>
                                    <component cmptype="Column" caption="Сумма" field="SPAY_SUMM" align="right"/>
                                    <component cmptype="Column" caption="Не зачтено" field="NE_ZACHETENO" align="right"/>
                                    <component cmptype="Column" caption="Способ&#160;оплаты" field="PAYMENT_METHOD_NAME" filter="PAYMENT_METHOD_ID" filterkind="cmb_unit" funit="PAYMENT_METHODS" fmethod="LIST"/>
                                    <component cmptype="Column" caption="Документ" field="DOC" sort="DOC"/>
                                    <component cmptype="Column" caption="Основание&#160;платежа" field="PAYMENT_REASON_SHORT"  sort="PAYMENT_REASON_SHORT" filter="PAYMENT_REASON_SHORT"/>
                                    <component cmptype="GridFooter">
                                        <component cmptype="Range" insteadrefresh="InsteadRefresh(this);" id="range1" count="10" varstart="r1s" varcount="r1c" valuecount="10" valuestart="1" />
                                    </component>
                                </component>
                                <component cmptype="Popup" name="pPAYMENT_JOURNAL" popupobject="GRID_PAYMENT_JOURNAL" onpopup="base().OnPopupRaymentJournal();">
                                    <component cmptype="PopupItem" name="pREFRESH_PAYMENT_JOURNAL" caption="Обновить" onclick="setControlProperty('GRID_PAYMENT_JOURNAL','locate',getValue('GRID_PAYMENT_JOURNAL'));refreshDataSet('DS_PAYMENT_JOURNAL');" cssimg="refresh"/>
                                    <component cmptype="PopupItem" name="pSEPARETE" caption="-"/>
                                    <component cmptype="PopupItem" name="pADD_PAYMENT_JOURNAL" unitbp="PAYMENT_JOURNAL_INSERT" caption="Добавить платеж" onclick="base().AddRaymentJournal();" cssimg="insert"/>
                                    <component cmptype="PopupItem" name="pEDIT_PAYMENT_JOURNAL" unitbp="PAYMENT_JOURNAL_UPDATE" caption="Редактировать платеж" onclick="base().EditRaymentJournal();" cssimg="edit"/>
                                    <component cmptype="PopupItem" name="pDEL_PAYMENT_JOURNAL"  unitbp="PAYMENT_JOURNAL_DELETE" caption="Удалить платеж" onclick="base().DelRaymentJournal();" cssimg="delete"/>
                                    <component cmptype="PopupItem" name="pSEPARETE" caption="-"/>
                                    <component cmptype="PopupItem" name="pSETPAY_PAYMENT_JOURNAL" caption="Связать с договором" onclick="base().SetPayidContract();" cssimg="insert"/>

                                    <component cmptype="PopupItem" name="pLINK_PAYMENT_JOURNAL" caption="Связать с услугой в договоре" onclick="base().LinkPayJournal();" cssimg="insert"/>
                                    <component cmptype="PopupItem" name="pDEL_LINK_PAYMENT_JOURNAL" caption="Удалить связь с услугой в договоре" onclick="base().DelLinkPayJournal();" cssimg="delete"/>
                                </component>
                                <component cmptype="AutoPopupMenu" unit="PAYMENT_JOURNAL" all="true" join_menu="pPAYMENT_JOURNAL" popupobject="GRID_PAYMENT_JOURNAL"/>
                                <component cmptype="Script">
                                    Form.OnPopupRaymentJournal = function () {
                                        var data = getControlProperty('GRID_CONTRACTS', 'data');
                                        var data0 = getControlProperty('GRID_PAYMENT_JOURNAL', 'data');
                                        if (!empty(data['ID']) &amp;&amp; parseToJSFloat(data['DEBT_SUMM']) &gt; 0 &amp;&amp; parseToJSFloat(data0['NE_ZACHETENO']) &gt; 0) {
                                            setControlProperty('pPAYMENT_JOURNAL', 'showitem', 'pSETPAY_PAYMENT_JOURNAL');
                                        }
                                        else {
                                            setControlProperty('pPAYMENT_JOURNAL', 'hideitem', 'pSETPAY_PAYMENT_JOURNAL');
                                        }
                                        var data1 = getControlProperty('GRID_CONTRACT_PAYMENTS', 'data');
                                        if (!empty(getValue('GRID_CONTRACT_PAYMENTS')) &amp;&amp; parseToJSFloat(data1['CP_DEBT_SUMM']) &gt; 0 &amp;&amp; parseToJSFloat(data0['NE_ZACHETENO']) &gt; 0 &amp;&amp; empty(data['AMI_ID'])) {

                                            setControlProperty('pPAYMENT_JOURNAL', 'showitem', 'pLINK_PAYMENT_JOURNAL');
                                            setControlProperty('pPAYMENT_JOURNAL', 'hideitem', 'pDEL_LINK_PAYMENT_JOURNAL');

                                        }
                                        else {
                                            setControlProperty('pPAYMENT_JOURNAL', 'hideitem', 'pLINK_PAYMENT_JOURNAL');
                                            setControlProperty('pPAYMENT_JOURNAL', 'showitem', 'pDEL_LINK_PAYMENT_JOURNAL');
                                        }
                                        if (!empty(getValue('GRID_PAYMENT_JOURNAL'))) {
                                            setControlProperty('pPAYMENT_JOURNAL', 'showitem', 'pEDIT_PAYMENT_JOURNAL');
                                            setControlProperty('pPAYMENT_JOURNAL', 'showitem', 'pDEL_PAYMENT_JOURNAL');
                                            var data = getControlProperty('GRID_PAYMENT_JOURNAL', 'data');
                                            if (!empty(data['FA_ID'])) {
                                                setControlProperty('pPAYMENT_JOURNAL', 'showitem', 'pADD_PAYMENT_JOURNAL');
                                            }
                                            else {
                                                setControlProperty('pPAYMENT_JOURNAL', 'showitem', 'pADD_PAYMENT_JOURNAL');
                                            }
                                        }
                                        else {
                                            setControlProperty('pPAYMENT_JOURNAL', 'showitem', 'pADD_PAYMENT_JOURNAL');
                                            setControlProperty('pPAYMENT_JOURNAL', 'hideitem', 'pEDIT_PAYMENT_JOURNAL');
                                            setControlProperty('pPAYMENT_JOURNAL', 'hideitem', 'pDEL_PAYMENT_JOURNAL');
                                        }

                                    }
                                    //Связать с услугой в договоре
                                    Form.LinkPayJournal = function () {
                                        setVar('LOCATE_RJ', getValue('GRID_PAYMENT_JOURNAL'));
                                        var data = getControlProperty('GRID_CONTRACT_PAYMENTS', 'data');
                                        setVar('PAY_SUMM', data['CP_DEBT_SUMM']);
                                        executeAction('ActionLinkPayJournal', function () {
                                            setControlProperty('GRID_PAYMENT_JOURNAL', 'locate', getVar('LOCATE_RJ'));
                                            refreshDataSet('DS_PAYMENT_JOURNAL');
                                        });
                                    }
                                    //Удалить с услугой в договоре
                                    Form.DelLinkPayJournal = function () {
                                        executeAction('ActionFindLinkPayJournal', function () {
                                            if (empty(getVar('PJ_CON_PAYMENT_ID'))) return;
                                            executeAction('ActionDelLinkPayJournal', function () {
                                                refreshDataSet('DS_PAYMENT_JOURNAL');
                                            });
                                        })


                                    }
                                    //Связать с договором
                                    Form.SetPayidContract = function () {
                                        setVar('LOCATE_RJ', getValue('GRID_PAYMENT_JOURNAL'));
                                        executeAction('ActionSetPayidContract', function () {
                                            setControlProperty('GRID_PAYMENT_JOURNAL', 'locate', getVar('LOCATE_RJ'));
                                            refreshDataSet('DS_PAYMENT_JOURNAL');
                                        });
                                    }
                                    //Удалить платеж
                                    Form.DelRaymentJournal = function () {
                                        if (confirm('Вы действительно хотите удалить платеж?')) {
                                            executeAction('DELETE_PJ', function () {
                                                refreshDataSet('DS_PAYMENT_JOURNAL');
                                            });
                                        }
                                    }
                                    //Добавить платеж
                                    Form.AddRaymentJournal = function () {
                                        if (empty(getValue('GRID_CONTRACTS')))return;
                                        var data = getControlProperty('GRID_CONTRACTS', 'data');
                                        setVar('PAYMENT_KIND_ID', data['PAYMENT_KIND_ID']);
                                        setVar('PJ_ID_VAR', null);
                                        openWindow('Contracts/actions/edit_payment_journal', true, 828, 410)
                                                .addListener('onclose',
                                                        function () {
                                                            if (getVar('ModalResult', 1) == 1) {
                                                                setControlProperty('GRID_PAYMENT_JOURNAL', 'locate', getVar("newid", 1), 1);
                                                                refreshDataSet('DS_PAYMENT_JOURNAL', true, 1);
                                                            }
                                                        },
                                                        null,
                                                        false);

                                    }
                                    //Редактировать платеж
                                    Form.EditRaymentJournal = function () {
                                        setVar('PJ_ID_VAR', getValue('GRID_PAYMENT_JOURNAL'));

                                        openWindow('Contracts/actions/edit_payment_journal', true, 828, 410)
                                                .addListener('onclose',
                                                        function () {
                                                            if (getVar('ModalResult', 1) == 1) {
                                                                setControlProperty('GRID_PAYMENT_JOURNAL', 'locate', getVar("PJ_ID_VAR", 1), 1);
                                                                refreshDataSet('DS_PAYMENT_JOURNAL', true, 1);
                                                            }
                                                        },
                                                        null,
                                                        false);
                                    }
                                </component>
                                <component cmptype="Action" name="ActionFindLinkPayJournal">
                                    begin
                                        select t.ID
                                          into :ID
                                          from d_v_pj_con_payments t
                                         where t.PID=:PID
                                           and t.CONTRACT_PAYMENT=:CP;
                                exception when NO_DATA_FOUND then
                                            :ID := null;
                                    end;
                                    <component cmptype="ActionVar" name="ID"  src="PJ_CON_PAYMENT_ID"      srctype="var"  put="v3" len="20"/>
                                    <component cmptype="ActionVar" name="PID" src="GRID_PAYMENT_JOURNAL"   srctype="ctrl" get="v1"/>
                                    <component cmptype="ActionVar" name="CP"  src="GRID_CONTRACT_PAYMENTS" srctype="ctrl" get="v2"/>
                                </component>
                                <component cmptype="Action" name="ActionDelLinkPayJournal" unit="PJ_CON_PAYMENTS" action="DELETE">
                                    <component cmptype="ActionVar" name="pnLPU" src="LPU"               srctype="session"/>
                                    <component cmptype="ActionVar" name="pnID"  src="PJ_CON_PAYMENT_ID" srctype="var" get="v1"/>
                                </component>
                                <component cmptype="Action" name="ActionLinkPayJournal" unit="PJ_CON_PAYMENTS" action="INSERT">
                                    <component cmptype="ActionVar" name="pnLPU"              src="LPU"                    srctype="session"/>
                                    <component cmptype="ActionVar" name="pnPID"              src="GRID_PAYMENT_JOURNAL"   srctype="ctrl"  get="v1"/>
                                    <component cmptype="ActionVar" name="pnCONTRACT_PAYMENT" src="GRID_CONTRACT_PAYMENTS" srctype="ctrl"  get="v2"/>
                                    <component cmptype="ActionVar" name="pnPAYMENT_JOURNAL"  src="GRID_PAYMENT_JOURNAL"   srctype="ctrl"  get="v3"/>
                                    <component cmptype="ActionVar" name="pnPAY_SUMM"         src=""                       srctype="const" get="v4"/>
                                </component>
                                <component cmptype="Action" name="ActionSetPayidContract" unit="CONTRACTS" action="LINK_PAYMENT_JOURNAL">
                                    <component cmptype="ActionVar" name="pnLPU"             src="LPU"                  srctype="session"/>
                                    <component cmptype="ActionVar" name="pnID"              src="GRID_CONTRACTS"       srctype="ctrl" get="v0"/>
                                    <component cmptype="ActionVar" name="pnPAYMENT_JOURNAL" src="GRID_PAYMENT_JOURNAL" srctype="ctrl" get="v1"/>
                                </component>
                                <component cmptype="Action" name="DELETE_PJ" unit="PAYMENT_JOURNAL" action="DELETE">
                                    <component cmptype="ActionVar" name="pnLPU" src="LPU"                  srctype="session"/>
                                    <component cmptype="ActionVar" name="pnID"  src="GRID_PAYMENT_JOURNAL" srctype="ctrl" get="var0" len="17"/>
                                </component>
                            </component>
                        </component>
                    </td>
                </tr>
            </tbody>
        </table>
    </component>
</div>
