<div cmptype="bogus" name="mainForm" oncreate="base().onCreate();" class="report_main_div" style="margin:1cm 1cm 1cm;">
    <component cmptype="Script">
        <![CDATA[
        Form.onCreate = function()
        {
            var id = getVar('DIR_NUMB') || getVar('DIR_ID');

            setValue('BARCODE', id);
        };
        ]]>
    </component>

    <component cmptype="DataSet" name="DS_INFO" compile="true">
        <![CDATA[
        select
	@if (:DIR_ID){
               decode (t2.id,null,to_char(t.ID),t2.REQUEST_PREF || ' - ' || t2.REQUEST_NUMB) REQ_FULL_NUMB,
	@}else{
	       case when min(t.ID) over() = max(t.ID) over()
		 then
		    case when t2.ID is null
			then to_char(t.ID)
			else to_char(t2.REQUEST_PREF) || ' - ' || to_char(t2.REQUEST_NUMB)
		    end
		 else
		   ''
	       end REQ_FULL_NUMB,
	@}
               t.REG_DATE,
               t4.LPU_FULLNAME,
               initcap(t.PAT_SURNAME||' '||t.PAT_FIRSTNAME||' '||t.PAT_LASTNAME) FIO,
               t.PAT_BIRTHDATE,
               d_pkg_dat_tools.FULL_YEARS(nvl(t.REG_DATE,sysdate),t.PAT_BIRTHDATE) AGE,
               decode(t.PAT_SEX,1,'Мужской','Женский') SEX,
               d_pkg_agent_addrs.GET_ACTUAL_ON_DATE(t.PAT_AGENT_ID,nvl(t.REG_DATE,sysdate),1,'SHORT') ADDR,
               D_PKG_AGENT_CONTACTS.GET_ACTUAL_PHONE(t.PAT_AGENT_ID, 'PHONE', 2) PHONE,
               (select nvl(t.STR_VALUE, t.NUM_VALUE)
                  from D_V_DIR_SERV_LM_PAR_VALUES t
                  join D_V_LABMED_PARAMS t2
                       on t2.ID = t.LBMD_PARAM
                 where t2.PAR_CODE = '00019'
                   and t.PID = dss.ID
                   and rownum = 1) CONTINGENT_CODE,

               (case when dss.IS_COMBINED_PAYMENT = 0 and dss.PAYMENT_KIND_NAME = 'ОМС' then
                           'полис ОМС '||D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(t.PAT_AGENT_ID,nvl(dss.REC_DATE,sysdate),0,'P_SER P_NUM от P_BEGIN P_WHO_NAME')
                      when dss.IS_COMBINED_PAYMENT = 0 and dss.PAYMENT_KIND_NAME = 'ДМС' then
                           'полис ДМС '||D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(t.PAT_AGENT_ID,nvl(dss.REC_DATE,sysdate),1,'P_SER P_NUM от P_BEGIN P_WHO_NAME')
                      when dss.IS_COMBINED_PAYMENT = 0 and dss.PAYMENT_KIND_NAME = 'Договор с организацией' then (select nvl2(c.ID,'Договор с '||c.AGENT_NAME||' №'||c.DOC_NUMB||' от '||c.DATE_BEGIN,null)
                                                                                                                    from D_V_RENDERING_JOURNAL j,
                                                                                                                         D_V_RJ_FACC_PAYMENTS  jp,
                                                                                                                         D_V_CONTRACT_PAYMENTS cp,
                                                                                                                         D_V_CONTRACTS         c
                                                                                                                   where j.DIRECTION_SERVICE = dss.ID
                                                                                                                     and j.PATIENT_ID        = t.PATIENT_ID
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
                                                                                                               and j.PATIENT_ID        = t.PATIENT_ID
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
                                                                                                     and j.PATIENT_ID        = t.PATIENT_ID
                                                                                                     and jp.PID              = j.ID
                                                                                                     and cp.ID               = jp.CONTRACT_PAYMENT
                                                                                                     and c.ID                = cp.PID
                                                                                                     and rownum              = 1)
                      when dss.IS_COMBINED_PAYMENT = 0 and dss.PAYMENT_KIND_NAME not in ('ОМС','ДМС','Договор с организацией','Средства граждан','Бюджет')
                            and pk.IS_COMMERC = 0 then 'Полим ОМС '||D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(t.PAT_AGENT_ID,nvl(dss.REC_DATE,sysdate),0,'P_SER P_NUM от P_BEGIN P_WHO_NAME')
                      when dss.IS_COMBINED_PAYMENT = 0 and dss.PAYMENT_KIND_NAME not in ('ОМС','ДМС','Договор с организацией','Средства граждан','Бюджет')
                            and pk.IS_COMMERC = 1 then (select nvl2(c.ID,'Договор с '||c.AGENT_NAME||' №'||c.DOC_NUMB||' от '||c.DATE_BEGIN,null)
                                                          from D_V_RENDERING_JOURNAL j,
                                                               D_V_RJ_FACC_PAYMENTS  jp,
                                                               D_V_CONTRACT_PAYMENTS cp,
                                                               D_V_CONTRACTS         c
                                                         where j.DIRECTION_SERVICE = dss.ID
                                                           and j.PATIENT_ID        = t.PATIENT_ID
                                                           and jp.PID              = j.ID
                                                           and cp.ID               = jp.CONTRACT_PAYMENT
                                                           and c.ID                = cp.PID
                                                           and rownum              = 1)
                      when dss.IS_COMBINED_PAYMENT = 1 then (select d_stragg(case when dssp.PAYMENT_KIND = 'ОМС' then
                                                                                       'полис ОМС '||D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(t.PAT_AGENT_ID,nvl(dss.REC_DATE,sysdate),0,'P_SER P_NUM от P_BEGIN P_WHO_NAME')
                                                                                  when dssp.PAYMENT_KIND = 'ДМС' then
                                                                                       'полис ДМС '||D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(t.PAT_AGENT_ID,nvl(dss.REC_DATE,sysdate),1,'P_SER P_NUM от P_BEGIN P_WHO_NAME')
                                                                                  when dssp.PAYMENT_KIND = 'Договор с организацией' then (select nvl2(c.ID,'Договор с '||c.AGENT_NAME||' №'||c.DOC_NUMB||' от '||c.DATE_BEGIN,null)
                                                                                                                                            from D_V_RENDERING_JOURNAL j,
                                                                                                                                                 D_V_RJ_FACC_PAYMENTS  jp,
                                                                                                                                                 D_V_CONTRACT_PAYMENTS cp,
                                                                                                                                                 D_V_CONTRACTS         c
                                                                                                                                           where j.DIRECTION_SERVICE = dss.ID
                                                                                                                                             and j.PAYMENT_KIND_ID   = dssp.PAYMENT_KIND_ID
                                                                                                                                             and j.PATIENT_ID        = t.PATIENT_ID
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
                                                                                                                                       and j.PATIENT_ID        = t.PATIENT_ID
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
                                                                                                                             and j.PATIENT_ID        = t.PATIENT_ID
                                                                                                                             and jp.PID              = j.ID
                                                                                                                             and cp.ID               = jp.CONTRACT_PAYMENT
                                                                                                                             and c.ID                = cp.PID
                                                                                                                             and rownum              = 1)
                                                                                  when dssp.PAYMENT_KIND not in ('ОМС','ДМС','Договор с организацией','Средства граждан','Бюджет')
                                                                                        and dssp.IS_COMMERC = 0 then 'Полим ОМС '||D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(t.PAT_AGENT_ID,nvl(dss.REC_DATE,sysdate),0,'P_SER P_NUM от P_BEGIN P_WHO_NAME')
                                                                                  when dssp.PAYMENT_KIND not in ('ОМС','ДМС','Договор с организацией','Средства граждан','Бюджет')
                                                                                        and dssp.IS_COMMERC = 1 then (select nvl2(c.ID,'Договор с '||c.AGENT_NAME||' №'||c.DOC_NUMB||' от '||c.DATE_BEGIN,null)
                                                                                                                        from D_V_RENDERING_JOURNAL j,
                                                                                                                             D_V_RJ_FACC_PAYMENTS  jp,
                                                                                                                             D_V_CONTRACT_PAYMENTS cp,
                                                                                                                             D_V_CONTRACTS         c
                                                                                                                       where j.DIRECTION_SERVICE = dss.ID
                                                                                                                         and j.PAYMENT_KIND_ID   = dssp.PAYMENT_KIND_ID
                                                                                                                         and j.PATIENT_ID        = t.PATIENT_ID
                                                                                                                         and jp.PID              = j.ID
                                                                                                                         and cp.ID               = jp.CONTRACT_PAYMENT
                                                                                                                         and c.ID                = cp.PID
                                                                                                                         and rownum              = 1)
                                                                             end)
                                                               from D_V_DIR_SERV_PAYMENTS dssp
                                                              where dssp.PID = dss.ID)
                 end) PAYMENT_KIND_NAME,
                nvl2(dss.HH_DEP, hhd.DEP_NAME, nvl(ds2.DP_NAME, (select e.DEPARTMENT from d_v_employers e where e.ID = v.EMPLOYER_ID and e.LPU = v.LPU))) DEPARTMENT,
                t4.LPU_NAME,
                t.REG_EMPLOYER_FIO,
                dss.SERVICE_NAME,
                nvl2(dss.HH_DEP,
                    nvl2(hh.MKB_FINAL_ID,hh.MKB_FINAL||' '||hh.MKB_FINAL_NAME,
                        nvl2(hh.MKB_CLINIC_ID,hh.MKB_CLINIC||' '||hh.MKB_CLINIC_NAME,
                            nvl2(hh.MKB_RECEIVE_ID,hh.MKB_RECEIVE||' '||hh.MKB_RECEIVE_NAME,hh.MKB_SEND||' '||hh.MKB_SEND_NAME))),
                                 nvl((select vd.MKB_CODE||' '||vd.MKB_NAME from D_V_VIS_DIAGNOSISES_MAIN vd where vd.PID = v.ID), t.EX_CAUSE_MKB)) DIAGNOSIS
        from d_v_directions t
             left join d_v_direction_additives t2
		    on t2.PID = t.ID
	     join d_v_lpu t3
	       on t3.ID = t.LPU
		  join d_v_lpudict t4
		    on t4.ID = t3.LPUDICT_ID
	     join d_v_direction_services dss
	       on dss.PID = t.ID
		  and dss.LPU = t3.ID
		  left join d_v_direction_services ds2
			 on ds2.ID = dss.HID
		  left join d_v_hosp_history_deps hhd
			 on hhd.ID = dss.HH_DEP
			    left join d_v_hosp_histories hh
				   on hh.ID = hhd.PID
		  left join d_v_payment_kind pk
			 on pk.ID = dss.PAYMENT_KIND_ID
	     left join d_v_visits v
		    on v.ID = t.REG_VISIT_ID

        where
	@if (:DIR_ID){
	    t.ID = :DIR_ID
	@}else if (:VISIT_ID){
	    t.REG_VISIT_ID = :VISIT_ID
	and t.LPU = :LPU
	@}else{
	    trunc(t.REG_DATE) = to_date(:REP_DATE, D_PKG_STD.FRM_D)
	and t.REG_EMPLOYER_ID = :EMP_ID
	and t.PATIENT_ID = :PAT_ID
	@}
        ]]>
        <component cmptype="Variable" name="LPU"	src="LPU"	srctype="session"/>
        <component cmptype="Variable" name="DIR_ID"     src="DIR_ID"    srctype="var" get="g1"/>
        <component cmptype="Variable" name="PAT_ID"     src="PAT_ID"    srctype="var" get="g2"/>
        <component cmptype="Variable" name="REP_DATE"   src="REP_DATE"  srctype="var" get="g3"/>
        <component cmptype="Variable" name="EMP_ID"     src="EMP_ID"    srctype="var" get="g4"/>
        <component cmptype="Variable" name="VISIT_ID"   src="VISIT_ID"  srctype="var" get="g5"/>
    </component>

    <component cmptype="DataSet" name="DS_SERVICES" compile="true">
        <![CDATA[
            select lp.PICK_CABLAB_NAME CABLAB_TO_NAME,
                    case when t.REG_TYPE = 0 then to_char(lp.REC_TIME,'dd.mm.yyyy')
                         else replace(to_char(lp.REC_TIME,'dd.mm.yyyy hh24:mi'),'00:00','')
                    end REC_DATE,
                    la.LA_NAME S_NAME,
                    la.LA_CODE S_CODE
               from d_v_directions t3
                    join d_v_direction_services t
                      on t3.ID = t.PID
                    join d_v_lpu_services t4
                      on t4.SERVICE_ID = t.SERVICE_ID
                         and t4.LPU = t.LPU

                    join d_v_labmed_analyze la on la.LPU_SERVICE_ID = t4.ID
                    /*дложны попавдать только анализы, без исследований*/
                    join D_V_LABMED_PATJOUR lp
                      on lp.DIRECTION_SERVICE = t.ID
              where 1 = 1
            @if (:DIR_ID){
                and t3.ID = :DIR_ID
            @}else if (:VISIT_ID){
                and t3.REG_VISIT_ID = :VISIT_ID
                and t3.LPU = :LPU
           order by t.REC_DATE
            @}else{
                and trunc(t3.REG_DATE) = to_date(:REP_DATE, D_PKG_STD.FRM_D)
                and t3.REG_EMPLOYER_ID = :EMP_ID
                and t3.PATIENT_ID = :PAT_ID
           order by t.REC_DATE
            @}
        ]]>
        <component cmptype="Variable" name="LPU"	    src="LPU"       srctype="session"/>
        <component cmptype="Variable" name="DIR_ID"	    src="DIR_ID"    srctype="var" get="g1"/>
        <component cmptype="Variable" name="PAT_ID"     src="PAT_ID"    srctype="var" get="g2"/>
        <component cmptype="Variable" name="REP_DATE"   src="REP_DATE"  srctype="var" get="g3"/>
        <component cmptype="Variable" name="EMP_ID"     src="EMP_ID"    srctype="var" get="g4"/>
        <component cmptype="Variable" name="VISIT_ID"   src="VISIT_ID"  srctype="var" get="g5"/>
    </component>

    <table border="0px" width="100%">
        <tr>
            <td style="text-align:center;vertical-align:middle;width:50%">
                <u><component cmptype="Label" captionfield="LPU_FULLNAME" dataset="DS_INFO" /></u><br/>
                <component cmptype="Label" caption="(наименование учреждения направления)" />
            </td>
            <td style="text-align:right;width:50%">
                <component cmptype="ModuleImage" name="BARCODE" module="Barcode/code128"/>
            </td>
        </tr>
    </table>

    <div cmptype="tmp" dataset="DS_INFO" name="info">
        <br /><br />
        <div style="text-align:left;">
            <b>
                <component cmptype="Label" caption="НАПРАВЛЕНИЕ "/>
                <component cmptype="Label" before_caption="№ " captionfield="REQ_FULL_NUMB"/>
            </b>
            <br/>
            <component cmptype="Label" caption="от "/>
            <component cmptype="Label" captionfield="REG_DATE"/>
            <br/>
            <br/>
            <component cmptype="Label" caption="Пациент:  "/>
            <u>
                <b>
                    <component cmptype="Label" captionfield="FIO"/>
                </b>
            </u>
            <component cmptype="Label" caption="Дата рождения:  "/>
            <u>
                <component cmptype="Label" captionfield="PAT_BIRTHDATE"/>
            </u>
            <component cmptype="Label" caption="Возраст: "/>
            <u>
                <component cmptype="Label" captionfield="AGE"/>
            </u>
            <component cmptype="Label" caption="Пол: "/>
            <u>
                <component cmptype="Label" captionfield="SEX"/>
            </u>
            <br />
            <component cmptype="Label" caption="Адрес: "/>
            <u>
                <component cmptype="Label" captionfield="ADDR"/>
            </u>
            <component cmptype="Label" caption=" , телефон: "/>
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
            <component cmptype="Label" caption="Отделение"/>
            <u>
                <component cmptype="Label" captionfield="DEPARTMENT"/>
            </u>
            <br />
            <component cmptype="Label" caption="Врач направивший: "/>
            <u>
                <component cmptype="Label" captionfield="REG_EMPLOYER_FIO"/>
            </u>
            <component cmptype="Label" caption="от"/>
            <u>
                <component cmptype="Label" captionfield="REG_DATE"/>
            </u>
            <br/>
            <component cmptype="Label" caption="Диагноз: "/>
            <u>
                <component cmptype="Label" captionfield="DIAGNOSIS"/>
            </u>
            <br/>
            <component cmptype="Label" caption="Код контингента для обследования: "/>
            <u>
                <component cmptype="Label" captionfield="CONTINGENT_CODE"/>
            </u>
            <br />
            <br />

            <table class="rep-main-table">
                <tr style="text-align:center;">
                    <td>
                        <component cmptype="Label" caption="Наименование анализа"/>
                    </td>
                    <td>
                        <component cmptype="Label" caption="Кабинет забора"/>
                    </td>
                    <td>
                        <component cmptype="Label" caption="Дата"/>
                    </td>
                </tr>
                <tr dataset="DS_SERVICES" repeate="0">
                    <td>
                        <component cmptype="Label" captionfield="S_NAME"/>
                    </td>
                    <td>
                        <component cmptype="Label" captionfield="CABLAB_TO_NAME"/>
                    </td>
                    <td>
                        <component cmptype="Label" captionfield="REC_DATE"/>
                    </td>
                </tr>
            </table>
        </div>
    </div>

    <style>
        body {
            font-family: Tahoma;
            font-size: 12px;
        }
        .rep-main-table {
            width:100%;
            table-layout: fixed;
            word-wrap:break-word;
        }
        .rep-main-table thead td {
            vertical-align: middle;
        }
        .rep-main-table td {
            text-align: center;
            padding: 1px;
            border: 1px solid #000;
            border-collapse: collapse;
        }
    </style>

</div>