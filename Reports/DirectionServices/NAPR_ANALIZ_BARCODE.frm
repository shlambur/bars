<div cmptype="bogus" oncreate="base().onCreate()" class="report_main_div" style="margin:1cm 1cm 1cm;">
    <component cmptype="Script">
        <![CDATA[
            Form.onCreate=function(){
                setValue('Module1', getVar('DIRSERV_ID'));
                executeAction('GetLabmedPatjour', function(){refreshDataSet('DS_SERVICES')})
            }
            Form.onLoadBarcode = function(_dom) {
                var canvas = document.createElement("canvas");
                var img = _dom;
                var new_img = new Image();

                try {
                    canvas.width = img.width;
                    canvas.height = img.height;
                    var ctx = canvas.getContext("2d");
                    ctx.clearRect(0, 0, canvas.width, canvas.height);
                    ctx.drawImage(img, 0, 0, img.width, img.height);
                    var dataURL = canvas.toDataURL("image/png");
                    new_img.src = dataURL;

                    var parent = _dom.parentNode;
                    parent.replaceChild(new_img, _dom);
                } catch(e) {
                    console.log(e.name, e.message);
                }

                delete canvas;
            }
        ]]>
    </component>
    
    <component cmptype="DataSet" name="DS_DATA" compile="true">
        <![CDATA[
             select dss.ID DIRSERV_ID,
                    dss.SERVICE_NAME,
                    trim(d.DIR_PREF||' '||d.DIR_NUMB) DIR_NUMB,
                    (case when dss.REG_TYPE = 0 then to_char(dss.REC_DATE,'DD.MM.YYYY')
                          when dss.REG_TYPE != 0 then decode(to_char(dss.REC_DATE,'HH24:MI'),'',to_char(dss.REC_DATE, 'dd.mm.yyyy'),to_char(dss.REC_DATE,'DD.MM.YYYY HH24:MI'))
                     end) REC_DATE,
                    initcap(d.PAT_SURNAME||' '||d.PAT_FIRSTNAME||' '||d.PAT_LASTNAME) FIO,
                    d_pkg_dat_tools.FULL_YEARS(nvl(dss.REC_DATE,sysdate),d.PAT_BIRTHDATE) AGE,
                    decode(d.PAT_SEX,1,'Мужской','Женский') POL,
                    d_pkg_agent_addrs.GET_ACTUAL_ON_DATE(d.PAT_AGENT_ID,nvl(dss.REC_DATE,sysdate),1,'SHORT') ADDR,
                    D_PKG_AGENT_CONTACTS.GET_ACTUAL_PHONE(d.PAT_AGENT_ID, 'PHONE', 2) PHONE,
                    (case when dss.IS_COMBINED_PAYMENT = 0 and dss.PAYMENT_KIND_NAME = 'ОМС' then
                               'полис ОМС '||D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(d.PAT_AGENT_ID,nvl(dss.REC_DATE,sysdate),0,'P_SER P_NUM от P_BEGIN P_WHO_NAME')
                          when dss.IS_COMBINED_PAYMENT = 0 and dss.PAYMENT_KIND_NAME = 'ДМС' then
                               'полис ДМС '||D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(d.PAT_AGENT_ID,nvl(dss.REC_DATE,sysdate),1,'P_SER P_NUM от P_BEGIN P_WHO_NAME')
                          when dss.IS_COMBINED_PAYMENT = 0 and dss.PAYMENT_KIND_NAME = 'Договор с организацией' then (select nvl2(c.ID,'Договор с '||c.AGENT_NAME||' №'||c.DOC_NUMB||' от '||c.DATE_BEGIN,null)
                                                                                                                        from D_V_RENDERING_JOURNAL j,
                                                                                                                             D_V_RJ_FACC_PAYMENTS  jp,
                                                                                                                             D_V_CONTRACT_PAYMENTS cp,
                                                                                                                             D_V_CONTRACTS         c
                                                                                                                       where j.DIRECTION_SERVICE = dss.ID
                                                                                                                         and j.PATIENT_ID        = d.PATIENT_ID
                                                                                                                         and jp.PID              = j.ID
                                                                                                                         and cp.ID               = jp.CONTRACT_PAYMENT
                                                                                                                         and c.ID                = cp.PID
                                                                                                                         and rownum              = 1)
                          when dss.IS_COMBINED_PAYMENT = 0 and dss.PAYMENT_KIND_NAME = 'Средства граждан' then (select nvl2(c.ID,'Договор с физ.лицами №'||c.DOC_NUMB||' от '||c.DATE_BEGIN,null)
                                                                                                                  from D_V_RENDERING_JOURNAL j,
                                                                                                                       D_V_RJ_FACC_PAYMENTS  jp,
                                                                                                                       D_V_CONTRACT_PAYMENTS cp,
                                                                                                                       D_V_CONTRACTS         c
                                                                                                                 where j.DIRECTION_SERVICE = dss.ID
                                                                                                                   and j.PATIENT_ID        = d.PATIENT_ID
                                                                                                                   and jp.PID              = j.ID
                                                                                                                   and cp.ID               = jp.CONTRACT_PAYMENT
                                                                                                                   and c.ID                = cp.PID
                                                                                                                   and rownum              = 1)
                          when dss.IS_COMBINED_PAYMENT = 0 and dss.PAYMENT_KIND_NAME = 'Бюджет' then (select nvl2(c.ID,'Договор с '||c.AGENT_NAME||' №'||c.DOC_NUMB||' от '||c.DATE_BEGIN,null)
                                                                                                        from D_V_RENDERING_JOURNAL j,
                                                                                                             D_V_RJ_FACC_PAYMENTS  jp,
                                                                                                             D_V_CONTRACT_PAYMENTS cp,
                                                                                                             D_V_CONTRACTS         c
                                                                                                       where j.DIRECTION_SERVICE = dss.ID
                                                                                                         and j.PATIENT_ID        = d.PATIENT_ID
                                                                                                         and jp.PID              = j.ID
                                                                                                         and cp.ID               = jp.CONTRACT_PAYMENT
                                                                                                         and c.ID                = cp.PID
                                                                                                         and rownum              = 1)
                          when dss.IS_COMBINED_PAYMENT = 0 and dss.PAYMENT_KIND_NAME not in ('ОМС','ДМС','Договор с организацией','Средства граждан','Бюджет')
                                and pk.IS_COMMERC = 0 then 'Полис ОМС '||D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(d.PAT_AGENT_ID,nvl(dss.REC_DATE,sysdate),0,'P_SER P_NUM от P_BEGIN P_WHO_NAME')
                          when dss.IS_COMBINED_PAYMENT = 0 and dss.PAYMENT_KIND_NAME not in ('ОМС','ДМС','Договор с организацией','Средства граждан','Бюджет')
                                and pk.IS_COMMERC = 1 then (select nvl2(c.ID,'Договор с '||c.AGENT_NAME||' №'||c.DOC_NUMB||' от '||c.DATE_BEGIN,null)
                                                              from D_V_RENDERING_JOURNAL j,
                                                                   D_V_RJ_FACC_PAYMENTS  jp,
                                                                   D_V_CONTRACT_PAYMENTS cp,
                                                                   D_V_CONTRACTS         c
                                                             where j.DIRECTION_SERVICE = dss.ID
                                                               and j.PATIENT_ID        = d.PATIENT_ID
                                                               and jp.PID              = j.ID
                                                               and cp.ID               = jp.CONTRACT_PAYMENT
                                                               and c.ID                = cp.PID
                                                               and rownum              = 1)
                          when dss.IS_COMBINED_PAYMENT = 1 then (select d_stragg(case when dssp.PAYMENT_KIND = 'ОМС' then
                                                                                           'полис ОМС '||D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(d.PAT_AGENT_ID,nvl(dss.REC_DATE,sysdate),0,'P_SER P_NUM от P_BEGIN P_WHO_NAME')
                                                                                      when dssp.PAYMENT_KIND = 'ДМС' then
                                                                                           'полис ДМС '||D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(d.PAT_AGENT_ID,nvl(dss.REC_DATE,sysdate),1,'P_SER P_NUM от P_BEGIN P_WHO_NAME')
                                                                                      when dssp.PAYMENT_KIND = 'Договор с организацией' then (select nvl2(c.ID,'Договор с '||c.AGENT_NAME||' №'||c.DOC_NUMB||' от '||c.DATE_BEGIN,null)
                                                                                                                                                from D_V_RENDERING_JOURNAL j,
                                                                                                                                                     D_V_RJ_FACC_PAYMENTS  jp,
                                                                                                                                                     D_V_CONTRACT_PAYMENTS cp,
                                                                                                                                                     D_V_CONTRACTS         c
                                                                                                                                               where j.DIRECTION_SERVICE = dss.ID
                                                                                                                                                 and j.PAYMENT_KIND_ID   = dssp.PAYMENT_KIND_ID
                                                                                                                                                 and j.PATIENT_ID        = d.PATIENT_ID
                                                                                                                                                 and jp.PID              = j.ID
                                                                                                                                                 and cp.ID               = jp.CONTRACT_PAYMENT
                                                                                                                                                 and c.ID                = cp.PID
                                                                                                                                                 and rownum              = 1)
                                                                                      when dssp.PAYMENT_KIND = 'Средства граждан' then (select nvl2(c.ID,'Договор с физ.лицами №'||c.DOC_NUMB||' от '||c.DATE_BEGIN,null)
                                                                                                                                          from D_V_RENDERING_JOURNAL j,
                                                                                                                                               D_V_RJ_FACC_PAYMENTS  jp,
                                                                                                                                               D_V_CONTRACT_PAYMENTS cp,
                                                                                                                                               D_V_CONTRACTS         c
                                                                                                                                         where j.DIRECTION_SERVICE = dss.ID
                                                                                                                                           and j.PAYMENT_KIND_ID   = dssp.PAYMENT_KIND_ID
                                                                                                                                           and j.PATIENT_ID        = d.PATIENT_ID
                                                                                                                                           and jp.PID              = j.ID
                                                                                                                                           and cp.ID               = jp.CONTRACT_PAYMENT
                                                                                                                                           and c.ID                = cp.PID
                                                                                                                                           and rownum              = 1)
                                                                                      when dssp.PAYMENT_KIND = 'Бюджет' then (select nvl2(c.ID,'Договор с '||c.AGENT_NAME||' №'||c.DOC_NUMB||' от '||c.DATE_BEGIN,null)
                                                                                                                                from D_V_RENDERING_JOURNAL j,
                                                                                                                                     D_V_RJ_FACC_PAYMENTS  jp,
                                                                                                                                     D_V_CONTRACT_PAYMENTS cp,
                                                                                                                                     D_V_CONTRACTS         c
                                                                                                                               where j.DIRECTION_SERVICE = dss.ID
                                                                                                                                 and j.PAYMENT_KIND_ID   = dssp.PAYMENT_KIND_ID
                                                                                                                                 and j.PATIENT_ID        = d.PATIENT_ID
                                                                                                                                 and jp.PID              = j.ID
                                                                                                                                 and cp.ID               = jp.CONTRACT_PAYMENT
                                                                                                                                 and c.ID                = cp.PID
                                                                                                                                 and rownum              = 1)
                                                                                      when dssp.PAYMENT_KIND not in ('ОМС','ДМС','Договор с организацией','Средства граждан','Бюджет')
                                                                                            and dssp.IS_COMMERC = 0 then 'Полис ОМС '||D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(d.PAT_AGENT_ID,nvl(dss.REC_DATE,sysdate),0,'P_SER P_NUM от P_BEGIN P_WHO_NAME')
                                                                                      when dssp.PAYMENT_KIND not in ('ОМС','ДМС','Договор с организацией','Средства граждан','Бюджет')
                                                                                            and dssp.IS_COMMERC = 1 then (select nvl2(c.ID,'Договор с '||c.AGENT_NAME||' №'||c.DOC_NUMB||' от '||c.DATE_BEGIN,null)
                                                                                                                            from D_V_RENDERING_JOURNAL j,
                                                                                                                                 D_V_RJ_FACC_PAYMENTS  jp,
                                                                                                                                 D_V_CONTRACT_PAYMENTS cp,
                                                                                                                                 D_V_CONTRACTS         c
                                                                                                                           where j.DIRECTION_SERVICE = dss.ID
                                                                                                                             and j.PAYMENT_KIND_ID   = dssp.PAYMENT_KIND_ID
                                                                                                                             and j.PATIENT_ID        = d.PATIENT_ID
                                                                                                                             and jp.PID              = j.ID
                                                                                                                             and cp.ID               = jp.CONTRACT_PAYMENT
                                                                                                                             and c.ID                = cp.PID
                                                                                                                             and rownum              = 1)
                                                                                 end)
                                                                   from D_V_DIR_SERV_PAYMENTS dssp
                                                                  where dssp.PID = dss.ID)
                     end) PAYMENT_KIND_NAME,
                    nvl2(dss.HH_DEP, hhd.DEP_NAME, nvl(ds2.DP_NAME, (select e.DEPARTMENT from d_v_employers e where e.ID = v.EMPLOYER_ID and e.LPU = v.LPU))) DEPARTMENT,
                    nvl2(dss.HH_DEP,
                                'палата № '||(select db.BED_CODE from d_v_hh_dep_beds db
                                where nvl(dss.REC_DATE,sysdate)>=db.DATE_IN
                                      and (nvl(dss.REC_DATE,sysdate)<=db.DATE_out or db.DATE_OUT is null)
                                      and hhd.PATIENT=d.PATIENT_ID
                                      and db.PID=hhd.id),
                                 nvl2(d_pkg_pmc_registration.GET_ACTUAL_ON_DATE(d.PATIENT_ID,nvl(dss.REC_DATE,sysdate),null,'LPU_SITE_ID'),
                                 'Участок № '||d_pkg_pmc_registration.GET_ACTUAL_ON_DATE(d.PATIENT_ID,nvl(dss.REC_DATE,sysdate),null,'LPU_SITE_CODE'),null)) PALATA,
                    nvl2(dss.HH_DEP,'История болезни № '||hh.HH_PREF||'-'||hh.HH_NUMB_ALTERN||'\'||hh.HH_NUMB,'Амб. карта № '||d.PATIENT_CARD) AMB_CARD,
                    d.REG_EMPLOYER_FIO,
                    d.REG_DATE,
                    nvl2(dss.HH_DEP,
                        nvl2(hh.MKB_FINAL_ID,hh.MKB_FINAL||' '||hh.MKB_FINAL_NAME,
                            nvl2(hh.MKB_CLINIC_ID,hh.MKB_CLINIC||' '||hh.MKB_CLINIC_NAME,
                                nvl2(hh.MKB_RECEIVE_ID,hh.MKB_RECEIVE||' '||hh.MKB_RECEIVE_NAME,hh.MKB_SEND||' '||hh.MKB_SEND_NAME))),
                                     nvl((select vd.MKB_CODE||' '||vd.MKB_NAME from D_V_VIS_DIAGNOSISES_MAIN vd where vd.PID = v.ID), d.EX_CAUSE_MKB)) DIAGNOSIS,
                    l.FULLNAME,
                    lv.LPU_NAME
               from d_v_direction_services dss
                    join d_v_directions d on d.ID = dss.PID
                    left join d_v_direction_services ds2 on ds2.ID = dss.HID
                    left join d_v_hosp_history_deps hhd on hhd.ID = dss.HH_DEP
                    left join d_v_hosp_histories hh on hh.ID  = hhd.PID
                    left join d_v_visits v on v.ID = d.REG_VISIT_ID
                    left join d_v_payment_kind pk on pk.ID  = dss.PAYMENT_KIND_ID
                    join d_v_lpu l on l.ID = dss.LPU
                    join d_v_lpudict lv on lv.ID = l.LPUDICT_ID
              where dss.ID  = :DIRSERV_ID
        ]]>
        <component cmptype="Variable" name="DIRSERV_ID"   get="v1" src="DIRSERV_ID"   srctype="var"/>
    </component>
    <component cmptype="Action" name="GetLabmedPatjour">
        <![CDATA[
            begin
                select 1
                  into :IS_LP
                  FROM D_V_LABMED_PATJOUR lp
	             WHERE lp.DIRECTION_SERVICE = :DIRSERV_ID and rownum=1;
             exception when NO_DATA_FOUND then :IS_LP:=null;
            end;
            ]]>
        <component cmptype="ActionVar" name="DIRSERV_ID"    get="v1" src="DIRSERV_ID"   srctype="var"/>
        <component cmptype="ActionVar" name="IS_LP"         put="v2" src="IS_LP"        srctype="var" len="1"/>
    </component>
    <component cmptype="DataSet" name="DS_SERVICES" activateoncreate="false" compile="true">
        <![CDATA[
            @if (:IS_LP){
                SELECT lrj.RESEARCH_NAME SERVICE_NAME
                  FROM D_V_LABMED_PATJOUR lp
                       join D_V_LABMED_RSRCH_JOUR lrj on lrj.PATJOUR = lp.ID
                 WHERE lp.DIRECTION_SERVICE = :DIRSERV_ID
              ORDER BY lrj.RESEARCH_NAME
             @}else{
                 select s.SERVICE_NAME
                  from d_v_direction_services ds
                       join d_v_direction_services s on s.HID = ds.ID
                 where ds.ID = :DIRSERV_ID
             @}
        ]]>
        <component cmptype="Variable" name="DIRSERV_ID"    get="v1" src="DIRSERV_ID"   srctype="var"/>
        <component cmptype="Variable" name="IS_LP"         get="v2" src="IS_LP"        srctype="var"/>
    </component>

    <table border="0px" width="100%" cmptype="tmp" name="ReportHeader">
        <tr>
            <td style="text-align:center;vertical-align:middle;">
                <u>
                    <component cmptype="Label" captionfield="FULLNAME" dataset="DS_DATA" />
                </u>
                <br/>
                <component cmptype="Label" caption="(наименование учреждения направления)" />
            </td>
            <td style="text-align:right">
                <component cmptype="ModuleImage" name="Module1" module="Recips/barcode_sf" flag_check="0" onload="base().onLoadBarcode(this);"/> 
            </td>
        </tr>
    </table>

    <div cmptype="tmp" dataset="DS_DATA" name="DivMainData">
        <br /><br />
        <div style="text-align:left;">
            <b>
                <component cmptype="Label" caption="НАПРАВЛЕНИЕ на "/>
                <component cmptype="Label" captionfield="SERVICE_NAME"/>
                <br />
                <b>
                    <component cmptype="Label" caption=" № "/>
                </b>
                <component cmptype="Label" name="DIRSERV_ID" captionfield="DIRSERV_ID"/>
                <component cmptype="Label" caption=" на "/>
                <component cmptype="Label" captionfield="REC_DATE"/>
            </b>
            <br />
            <br />
            <component cmptype="Label" caption="Пациент: "/>
            <u>
                <b>
                    <component cmptype="Label" captionfield="FIO"/>
                </b>
            </u>
            <component cmptype="Label" caption="Возраст "/>
            <u>
                <component cmptype="Label" captionfield="AGE"/>
            </u>
            <component cmptype="Label" caption="Пол "/>
            <u>
                <component cmptype="Label" captionfield="POL"/>
            </u>
            <br />
            <component cmptype="Label" caption="Адрес: "/>
            <u>
                <component cmptype="Label" captionfield="ADDR"/>
            </u>
            <component cmptype="Label" caption=",телефон "/>
            <u>
                <component cmptype="Label" captionfield="PHONE"/>
            </u>
            <br />
            <!--{ОМС полис / ДМС полис /Договор}-->
            <component cmptype="Label" caption="Вид оплаты: "/>
            <u>
                <component cmptype="Label" captionfield="PAYMENT_KIND_NAME"/>
            </u>
            <br />
            <component cmptype="Label" caption="Учреждение: "/>
            <u>
                <component cmptype="Label" captionfield="LPU_NAME"/>
            </u>
            <br/>
            <component cmptype="Label" caption="Отделение "/>
            <u>
                <component cmptype="Label" captionfield="DEPARTMENT"/>
            </u>
            <br />
            <!--{Палата/Участок}-->
            <u>
                <component cmptype="Label" captionfield="PALATA"/>
            </u>
            <!--{Амб. карта № / История болезни №} -->
            <u>
                <component cmptype="Label" captionfield="AMB_CARD"/>
            </u>
            <br />
            <component cmptype="Label" caption="Врач направивший: "/>
            <u>
                <component cmptype="Label" captionfield="REG_EMPLOYER_FIO"/>
            </u>
            <component cmptype="Label" caption=" от "/>
            <u>
                <component cmptype="Label" captionfield="REG_DATE"/>
            </u>
            <br/>
            <component cmptype="Label" caption="Диагноз: "/>
            <u>
                <component cmptype="Label" captionfield="DIAGNOSIS"/>
            </u>
            <br />
            <b>
                <component cmptype="Label" caption="Наименование анализа: "/>
            </b>
            <component cmptype="Label" captionfield="SERVICE_NAME" dataset="DS_DATA" />
            <br />
            <div cmptype="tmp" dataset="DS_SERVICES" repeate="0">
                <component cmptype="Label" captionfield="SERVICE_NAME"/>
            </div>
        </div>
    </div>
</div>