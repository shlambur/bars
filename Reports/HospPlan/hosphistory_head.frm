<div cmptype="Form" class="report-form" dataset="DS_HOSPHISTORY_HEAD" repeate="0" oncreate="base().onCreate();"
     onclone="base().onClone(_dataArray);" afterrefresh="base().afterRefresh();">
    <span style="display: none;" cmptype="tmp" name="PRINT_SETUP" id="PrintSetup" ps_paperData="9" ps_marginTop="0" ps_marginBottom="0" ps_marginRight="0"
          ps_marginLeft="0"></span>
    <component cmptype="Subform" path="UniversalForms/multilined_control"/>

    <component cmptype="Script">
        <![CDATA[
            Form.onCreate = function() {
                startMultiDataSetsGroup();
                    refreshDataSet('DS_LPU_SHORT_NAME');
                    refreshDataSet('DS_HOSPHISTORY_HEAD');
                endMultiDataSetsGroup();
            };
            Form.onClone = function(data, clone) {
                var type = data['HT'];
                if(isExistsControlByName('IS_SITIZEN_' + data['IS_SITIZEN'])){
                    getControlByName('IS_SITIZEN_' + data['IS_SITIZEN']).className += ' underlined';
                }
                switch(type) {
                    case '1':
                        getControlByName('HOSPITAL_TYPE_2').className += ' underlined';
                        getControlByName('HOSPITAL_TYPE_6').className += ' underlined';
                    break;
                    case '2':
                        getControlByName('HOSPITAL_TYPE_2').className += ' underlined';
                        getControlByName('HOSPITAL_TYPE_5').className += ' underlined';
                    break;
                    case '3':
                        getControlByName('HOSPITAL_TYPE_3').className += ' underlined';
                        getControlByName('HOSPITAL_TYPE_7').className += ' underlined';
                    break;
                }

                if (type == 2 || type == 3) {
                    if (data['HOSP_HOUR']) {
                        setCaption('INJURE_TIME', data['HOSP_HOUR']);
                    }
                } else if (type == 1) {
                    if (data['INJURE_TIME']) {
                        setCaption('INJURE_TIME', data['INJURE_TIME']);
                    }
                }
            };
            Form.afterRefresh = function() {
                if (getCaption('HOSPITAL_TYPE_CODE') != '1') {
                    executeAction('getLpuCH');
                }

                var data = getDataSet('DS_HOSPHISTORY_HEAD').data;

                if(data.length > 0) {
                    data = data[0];
                    setCaption('DEP', data['DEP']);
                    setCaption('BED_CODE', data['BED_CODE']);
                }

                Form.addMultilinedControl('BED_CODE', 25, 90, null, 'font-weight:bold;', 1, null, 2, 140);

                if (typeof(base().UF_onAfterRefresh) == 'function') {
                    base().UF_onAfterRefresh();
                }
            }
        ]]>
    </component>

    <component cmptype="DataSet" name="DS_LPU_SHORT_NAME" activateoncreate="false">
        select d_pkg_constants.search_str('LpuShortName', :LPU, sysdate) LPU_SHORT_NAME
          from dual
        <component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
    </component>

    <component cmptype="DataSet" name="DS_HOSPHISTORY_HEAD" activateoncreate="false">
        <![CDATA[
            select coalesce(
                   (select ld.LPU_FULLNAME
                      from D_V_HOSP_HISTORIES hh
                           join D_V_LPUDICT ld on ld.ID = hh.LPU_FROM_ID
                     where hh.ID = t.HH_ID),
                   (case when t.OUTER_DIRECTION_ID is not null then
                         (select decode(nvl(trim(odir_ag.AGN_NAME),odir.REPRESENT_HANDLE), null, null,
                                 nvl(trim(odir_ag.AGN_NAME), odir.REPRESENT_HANDLE)||', №'||odir.D_NUMB||' от '||odir.D_DATE)
                            from D_V_OUTER_DIRECTIONS      odir,
                                 D_V_AGENTS                odir_ag
                           where odir.ID(+)             = t.OUTER_DIRECTION_ID
                             and odir_ag.ID(+)          = odir.REPRESENT_ID)
                             else t.LPU||', №'||t.DIR_NUMB
                   end))                                                                    DIRECTED_LPU_CH,
                   trim(t.MKB_CODE_OUTER||' '||t.MKB_NAME_OUTER||' '||t.MKB_EXACT_OUTER)    OUTER_DIAGNOSIS,
                   trim(t.MKB_CODE_HOSP||' '||t.MKB_NAME_HOSP||' '||t.MKB_EXACT_HOSP)       HOSP_DIAGNOSIS,
                   trim(t.MKB_CODE_CLINIC||' '||t.MKB_NAME_CLINIC||' '||t.MKB_EXACT_CLINIC) DIAG_CLINIC,
                   trim(t.MKB_CODE_FINAL||' '||t.MKB_EXACT_FINAL)                           DIAG_FINAL,
                   trim(t.MKB_CODE_FIN_COMP||' '||t.MKB_EXACT_FIN_COMP)                     DIAG_FIN_COMP,
                   trim(t.MKB_CODE_FIN_ADD||' '||t.MKB_EXACT_FIN_ADD)                       DIAG_FIN_ADD,
                   t.DIAG_CLINIC_DATE,
                   case when t.DIRECTION is not null then (select D_PKG_VISIT_FIELDS.GET_VALUE(e.visit, e.LPU, 'NUM_NAP')
                                                             from D_V_DIRECTIONS d,
                                                                  D_V_EMERGENCYJOURNAL e
                                                            where d.ID = t.DIRECTION
                                                              and e.VISIT = d.REG_VISIT_ID
                                                              and rownum = 1) end NUM_NAP,
                   t.DATE_IN,
                   to_char(t.DATE_IN, 'HH24:MI') TIME_IN,
                   t.DEP,
                   t.BED_CODE,
                   t.WORK_PLACE,
                   t.JOBTITLE_TITLE,
                   decode(t.SIS_SITIZEN, 'село', 0, 1) IS_SITIZEN,
                   t.SIS_SITIZEN,
                   t.DATE_OUT,
                   to_char(t.DATE_OUT, 'HH24:MI') TIME_OUT,
                   case when t.SEX = 'Женский' then 'Жен' else 'Муж' end SEX,
                   case when t.SEX = 'Женский' then 0 else 1 end NSEX,
                   t.POLIS_SER,
                   t.POLIS_NUM,
                   t.POLIS_WHO,
                   t.BIRTHDATE,
                   t.SOCIAL_STATE ||
                   (select case when t1.INABILITY_GROUP_NAME is not null
                                then ', Инвалидность: ' || t1.INABILITY_GROUP_NAME || ' группа'
                                else null
                           end
                      from D_V_AGENT_INABILITIES t1
                     where t1.PID = t.AGENT
                       and t1.BEGIN_DATE <= sysdate
                       and (t1.END_DATE >= trunc(sysdate) or t1.END_DATE is null)) SOCIAL_STATE,
                   t.CATEGORY_NAME,
                   t.IS_DAY_HOSPITAL,
                   t.HH_NUMB_FULL HH_NUMB,
                   t.PERS_ID,
                   t.PMC_CARD_NUMB,
                   t.AGE,
                   t.PATIENT,
                   t.PAYMENT_KIND,
                   t.FACT_DAYS,
                   t.FACT_DAYS FACT_DAYS_ALL,
                   t.HH_PREF,
                   t.HH_NUMB_ALTERN,
                   D_PKG_AGENT_ADDRS.GET_ACTUAL_ON_DATE(t.AGENT,sysdate,0, 'SHORT') ADDRESS,
                   case when c.phone1 is not null and c.phone2 is not null
                        then ' тел. '||c.phone1||','||c.phone2
                        when c.phone1 is not null
                        then ' тел. '||c.phone1
                        when c.phone2 is not null
                        then ' тел. '||c.phone2
                   end PHONES_AGENT,
                   case when t.PATIENT_LASTNAME is null then t.PATIENT_SURNAME else t.PATIENT_SURNAME||'  '||t.PATIENT_LASTNAME end FIO,
                   t.HOSP_TIMES,
                   case when t.HOSPITAL_TYPE_CODE in (2,3,4)
                        then 'по экстренным показаниям, через '||decode(t.INJURE_TIME,null,'__',t.INJURE_TIME)||' часа(ов) после начала заболевания, получения травмы' else 'госпитализирован в плановом порядке' end HOSPITAL_TYPE,
                   hr.HOUR_NAME HOSP_HOUR,
                   t.INJURE_TIME,
                   case when t.HOSPITAL_TYPE_CODE in (0,2,3,4) and (t.INJURE_TIME is not null) then 1
                        when t.HOSPITAL_TYPE_CODE in (0,2,3,4) and (t.INJURE_TIME is null) then 2
                        when t.HOSPITAL_TYPE_CODE='1' then 3
                   end HT,
                   t.HOSP_INFO,
                   t.HOSPITAL_TYPE_CODE,
                   t.TRANSPORTATION_KIND,
                   t.DISEASECASE,
                   t.BLOODGROUPE,
                   t.RHESUS,
                   d_pkg_agent_allerg_anamnesis.get_by_string(t.AGENT,sysdate) AGENT_ALLERG,
                   t.PD_SER,
                   t.PD_NUMB,
                   t.PD_TYPE,
                   t.PD_WHO,
                   t.PD_WHEN,
                   D_PKG_AGENT_ADDRS.GET_REG_RAION(t.AGENT,sysdate,2) RAION_REG,
                   D_PKG_AGENT_ADDRS.GET_ACTUAL_ON_DATE(fnAGENT => PATIENT_ID,
                                                        fdDATE  => sysdate,
                                                        fnTYPE  => 1,
                                                        fnFIELD => 'RAION_NAME') RAION_LIVE,
                   D_PKG_AGENT_ADDRS.GET_ACTUAL_ON_DATE(t.AGENT,sysdate,1, 'SHORT') ADDRESS_LIVE,
                   hh1.HOSPITALIZATION_TYPE_NAME,
                   case hh1.HOSP_IS_FIRST
                        when 0 then 'впервые в жизни'
                        when 1 then 'повторно'
                        when 2 then 'повторно в данном году'
                         end HOSP_TIMES_STR,
                   t.SNILS,
                   hh1.NOTE,
                   case d_Pkg_Agent_Addrs.GET_ACTUAL_ON_DATE(fnAGENT => hh1.PATIENT_ID,
                                                        fdDATE  => sysdate,
                                                        fnTYPE  => 0,
                                                        fnFIELD => 'IS_CITIZEN') when '0' then 'село' else 'город'
                                                        end REG_SIS_SITIZEN,
                   t.DIR_COMMENT,
                   (select LISTAGG(awp.WORK_PLACE_HAND, ', ') WITHIN GROUP (ORDER BY awp.WORK_PLACE_HAND)
                      from D_V_AGENT_WORK_PLACES awp
                     where awp.PID = t.AGENT
                       and (awp.END_DATE is null or awp.END_DATE>sysdate)) WORK_PLACE_HAND,
                   trim(t.MKB_CODE_OUTER||' '||t.MKB_EXACT_OUTER)  SEND_DIAGNOSIS,
                   case when t.PMC_TYPE = '1' then ''
                        when t.PMC_TYPE = '2' then 'новорожденный'
                        WHEN t.PMC_TYPE = '3' then 'неизвестный'
                        when t.PMC_TYPE is null then 'пациент'
                   end PMC_TYPE
              from D_V_REP_HOSPHISTORY_HEAD t
                   join D_V_HOSP_HISTORIES hh1 on t.HH_ID = hh1.ID
                   left join (select c.PID,
                                     c.PHONE1,
                                     c.PHONE2
                                from D_V_AGENT_CONTACTS c
                               where c.BEGIN_DATE <= sysdate
                                 and (c.END_DATE >= sysdate or c.END_DATE is null)
                                 and c.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'AGENT_CONTACTS')) c
                          on t.AGENT = c.PID
                   left join D_V_HOSP_HOURS hr on hr.HOUR_CODE = hh1.HOSP_HOUR_ID
             where t.HH_ID = :HH_ID
        ]]>
        <component cmptype="Variable" name="HH_ID" src="HH_ID" srctype="var" get="v1"/>
        <component cmptype="Variable" name="LPU" get="LPU" srctype="session" src="LPU"/>
    </component>

    <component cmptype="Action" name="getLpuCH">
        <![CDATA[
            declare sLPU_CODE VARCHAR2(40);
            begin
              begin
                select D_PKG_VISIT_FIELDS.GET_VALUE(s.VISIT_ID, s.LPU, 'LPU_FROM')
                  into sLPU_CODE
                  from (select ROW_NUMBER() over (order by v.VISIT_DATE desc) RN,
                               v.ID   VISIT_ID,
                               v.LPU  LPU
                          from D_V_DIRECTIONS         d,
                               D_V_DIRECTION_SERVICES ds,
                               D_V_VISITS             v
                         where d.ID          = ds.PID
                          and d.PATIENT_ID     = :PATIENT
                          and ds.SERVICE    = D_PKG_OPTIONS.GET('EmergencyService', ds.LPU)
                          and ds.ID         = v.PID
                          and trunc(v.VISIT_DATE)  > to_date(:DATE_IN, 'dd.mm.yyyy') - 1
                          and trunc(v.VISIT_DATE) <= to_date(:DATE_IN, 'dd.mm.yyyy')
                          and not exists(select null
                                           from D_V_DIRECTION_SERVICES ds1,
                                                D_V_VISITS             v1
                                          where ds1.HID     = ds.ID
                                            and ds1.SERVICE = D_PKG_OPTIONS.GET('HospRefuseService', ds1.LPU)
                                            and ds1.ID      = v1.PID )) s

                  where s.RN = 1;
                  exception when no_data_found then
                      sLPU_CODE := '';
                end;
                  begin
                    select l.LPU_NAME
                      into :DIRECTED_LPU_CH
                      from D_V_LPUDICT l
                     where l.LPU_CODE = sLPU_CODE;
                     exception when no_data_found then
                     :DIRECTED_LPU_CH := :DIRECTED_LPU_CH_GET;
                  end;
            end;
        ]]>
        <component cmptype="ActionVar" name="DATE_IN"             src="DATE_IN"         srctype="ctrlcaption" get="v1"/>
        <component cmptype="ActionVar" name="PATIENT"             src="PATIENT"         srctype="ctrlcaption" get="v2"/>
        <component cmptype="ActionVar" name="DIRECTED_LPU_CH"     src="DIRECTED_LPU_CH" srctype="ctrlcaption" put="p1" len="500"/>
        <component cmptype="ActionVar" name="DIRECTED_LPU_CH_GET" src="DIRECTED_LPU_CH" srctype="ctrlcaption" get="g1"/>
    </component>

    <component cmptype="Label" captionfield="NSEX" name="NSEX" style="display: none;"/>
    <component cmptype="Label" captionfield="PERS_ID" name="PERS_ID" style="display: none;"/>
    <component cmptype="Label" captionfield="DISEASECASE" name="DISEASECASE" style="display: none;"/>
    <component cmptype="Label" captionfield="PATIENT" name="PATIENT" style="display: none;"/>
    <component cmptype="Label" captionfield="DATE_IN" name="DATE_IN" style="display: none;"/>
    <component cmptype="Label" captionfield="HOSPITAL_TYPE_CODE" name="HOSPITAL_TYPE_CODE" style="display: none;"/>
    <div class="main-div">
        <div name="this_page">
            <table class="header-table">
                <tr>
                   <td cmptype="tmp" name="LPU_NAME_TD">
                       <span class="field-sh">
                           <component cmptype="Label" dataset="DS_LPU_SHORT_NAME" captionfield="LPU_SHORT_NAME"/>
                       </span>
                       <div class="sign">наименование учреждения</div>
                   </td>
                   <td></td>
                   <td>
                        <div>Код формы по ОКУД <span class="field"></span></div>
                        <div>Код учреждения по ОКПО <span class="field"></span></div>
                        <div>Медицинская документация форма № 003/у</div>
                        <div>Утверждена Минздравом СССР</div>
                        <div>04.10.80 г. № 1030</div>
                   </td>
                </tr>
            </table>
            <div class="title">
                <div>
                    МЕДИЦИНСКАЯ КАРТА №
                    <span class="field" style="min-width: 70pt; width: auto;">
                        <component cmptype="Label" captionfield="HH_NUMB"/>
                    </span>
                </div>
                <div>стационарного больного</div>
            </div>
            <div>
                Дата и время поступления
                <span class="field">
                    <component cmptype="Label" captionfield="DATE_IN"/>
                    <component cmptype="Label" captionfield="TIME_IN" style="padding-left: 10pt;"/>
                </span>
            </div>
            <div>
                Дата и время выписки
                <span class="field">
                    <component cmptype="Label" captionfield="DATE_OUT"/>
                    <component cmptype="Label" captionfield="TIME_OUT" style="padding-left: 10pt;"/>
                </span>
            </div>
            <!--
            <table>
                <tr>
                    <td style="width: 55%;">
                        Отделение <span class="field"><component cmptype="Label" captionfield="DEP"/></span>
                    </td>
                    <td>
                        <span class="caption">палата №</span>
                        <span class="field"><component cmptype="Label" captionfield="BED_CODE"/></span>
                    </td>
                </tr>
            </table>
            -->
            <div>
                Отделение <span class="field" style="width:100mm;"><component cmptype="Label" name="DEP" captionfield="DEP"/></span>
                палата № <component cmptype="Label" name="BED_CODE" captionfield="BED_CODE"/>
            </div>

            <div>Переведен в отделение <span class="field"></span></div>
            <div>Проведено койко-дней <span class="field"><!--<component cmptype="Label" captionfield="FACT_DAYS"/> SD#465--></span></div>
            <div cmptype="tmp" name="TRANSPORTATION_KIND_BLOCK">Виды транспортировки <span class="field"><component cmptype="Label" captionfield="TRANSPORTATION_KIND"/></span></div>
            <table>
                <tr>
                    <td style="width: 45% !important;">
                        Группа крови <span class="field"><component cmptype="Label" captionfield="BLOODGROUPE"/></span>
                    </td>
                    <td>
                        <span class="caption">Резус-принадлежность</span>
                        <span class="field"><component cmptype="Label" captionfield="RHESUS"/></span>
                    </td>
                </tr>
            </table>
            <div name="block_1">
                <div>
                    Побочное действие лекарств (непереносимость) <span class="field"></span>
                    <span class="text" style="text-indent: 226pt;">
                        <component cmptype="Label" captionfield="AGENT_ALLERG"/>
                    </span>
                </div>
                <div><span class="field"></span></div>
                <div class="sign">название препарата, характер побочного действия</div>
                <div><span class="field"></span></div>
            </div>
            <div>
                1. Фамилия, имя, отчество
                <span class="field">
                    <component cmptype="Label" name="FIO" captionfield="FIO"/>
                </span>
            </div>
            <div>2. Пол <span class="field"><component cmptype="Label" captionfield="SEX"/></span></div>
            <div>
                3. Возраст
                <span class="field" style="min-width: 50pt; width: auto;">
                    <component cmptype="Label" captionfield="AGE"/>
                </span>
                лет.
                Дата рождения
                <span class="field" style="min-width: 50pt; width: auto;">
                    <component cmptype="Label" captionfield="BIRTHDATE"/>
                </span>
                г.
            </div>
            <div>
                <component cmptype="Label" name="PERS_DOC" style="display: none;"/>
            </div>
            <div cmptype="tmp" name="POLIS_BLOCK">
                &amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;Страховой полис: серия
                <span class="field" style="min-width: 50pt; width: auto;">
                    <component cmptype="Label" captionfield="POLIS_SER"/>
                </span>
                номер
                <span class="field" style="min-width: 70pt; width: auto;">
                    <component cmptype="Label" name="POLIS_NUM" class="" captionfield="POLIS_NUM"/>
                </span>
                <br/>
                &amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;Кем выдан:
                <span class="field"><component cmptype="Label" captionfield="POLIS_WHO"/></span>
            </div>
            <div cmptype="tmp" name="ADDRESS_BLOCK">
                <div>
                    4. Постоянное место жительства:
                    <span cmptype="Base" name="IS_SITIZEN_1">город</span>,
                    <span cmptype="Base" name="IS_SITIZEN_0">село</span> (подчеркнуть)
                    <span class="field"></span>
                    <span class="text" style="text-indent: 285pt;">
                        <component cmptype="Label" captionfield="ADDRESS"/>
                        <component cmptype="Label" captionfield="PHONES_AGENT"/>
                    </span>
                </div>
                <div cmptype="tmp" name="ADDRESS_SPAN"><span class="field"></span></div>
                <div class="sign">вписать адрес, указав для приезжих город, район, населенный пункт</div>
                <div><span class="field"></span></div>
                <div class="sign">адрес родственников и № телефона</div>
                </div>
            <div cmptype="Base" name="WORK_PLACE_BLOCK">
                5. Место работы, профессия или должность <span class="field"></span>
                <span cmptype="tmp" name="WORK_PLACE_SPAN" class="text" style="text-indent: 205pt;" >
                    <component cmptype="Label" captionfield="WORK_PLACE"/>
                    <component cmptype="Label" captionfield="JOBTITLE_TITLE"/>
                </span>
            </div>
            <div name="AGN_CAT"><span class="field"></span></div>
            <div class="sign">для учащихся - место учебы; для детей - название детского учреждения, школы;</div>
            <div>
                Социальный статус: <span class="field"><component cmptype="Label" captionfield="SOCIAL_STATE"/></span>
            </div>
            <div class="sign">для инвалидов - род и группа инвалидности, ИОВ – да, нет подчеркнуть</div>
            <div cmptype="tmp" name="DIRECTED_LPU_BLOCK">
                6. Кем направлен больной <span class="field" style="margin-left: 2mm;"></span>
                <span class="text" style="text-indent: 130pt;">
                    <component cmptype="Label" captionfield="DIRECTED_LPU_CH" name="DIRECTED_LPU_CH"/>
                    <component name="NUM_NAP_LABEL" cmptype="Label" captionfield="NUM_NAP"/>
                </span>
                <div><span class="field"></span></div>
                <!-- <div><span class="field"></span></div> -->
            </div>
            <div class="sign">название лечебного учреждения</div>
            <div class="notnowrap" name="7_point">
                7. Доставлен в стационар
                <span cmptype="Base" name="HOSPITAL_TYPE_1">по экстренным показаниям:</span>
                <span cmptype="Base" name="HOSPITAL_TYPE_2">да</span>,
                <span cmptype="Base" name="HOSPITAL_TYPE_3">нет</span>
                <span cmptype="Base" name="HOSPITAL_TYPE_4">
                    через
                    <span class="field" style="min-width: 50pt; width: auto;">
                        <component cmptype="Label" captionfield="INJURE_TIME" name="INJURE_TIME"/>
                    </span>
                    часов
                </span>
                <span cmptype="Base" name="HOSPITAL_TYPE_5">после начала заболевания</span>,
                <span cmptype="Base" name="HOSPITAL_TYPE_6">получения травмы</span>;
                <span cmptype="Base" name="HOSPITAL_TYPE_7">госпитализирован в плановом порядке</span>
                (подчеркнуть).
            </div>
			<!--
            <div cmptype="Base" name="OUTER_DIAGNOSIS_BLOCK">
                8. Диагноз направившего учреждения
                <span class="text1">
                    <component cmptype="Label" captionfield="OUTER_DIAGNOSIS"/>
                </span>
            </div>
            <div cmptype="tmp" name="HOSP_DIAGNOSIS_BLOCK">
                9. Диагноз при поступлении
                <span class="text1">
                    <component cmptype="Label" captionfield="HOSP_DIAGNOSIS"/>
                </span>
            </div>
            <div cmptype="tmp" name="DIAG_CLINIC_BLOCK">
                10. Диагноз клинический
                <span class="text1">
                    <component cmptype="Label" captionfield="DIAG_CLINIC"/>
                </span>
            </div>
            <div cmptype="tmp" name="DIAG_FINAL_BLOCK">
                <div>11. Диагноз заключительный:</div>
                <div>а) основной: <span class="text1"><component cmptype="Label" captionfield="DIAG_FINAL"/></span></div>
                <div>б) осложнение основного: <span class="text1"><component cmptype="Label" captionfield="DIAG_FIN_COMP"/></span></div>
                <div>в) сопутствующий: <span class="text1"><component cmptype="Label" captionfield="DIAG_FIN_ADD"/></span></div>
            </div>  SD471-->
			
			<div cmptype="Base" name="OUTER_DIAGNOSIS_BLOCK">
                8. Диагноз направившего учреждения
                <span class="field">
                    <component cmptype="Label" captionfield="OUTER_DIAGNOSIS"/>
					
                </span>
				
            </div>
            <div cmptype="tmp" name="HOSP_DIAGNOSIS_BLOCK">
                9. Диагноз при поступлении
                <span class="field">
                    <component cmptype="Label" captionfield="HOSP_DIAGNOSIS"/>
                </span>
				 <div><span class="field"></span></div>
                
				

            </div>
            <div cmptype="tmp" name="DIAG_CLINIC_BLOCK">
                10. Диагноз клинический
                <span class="field">
                    <component cmptype="Label" captionfield="DIAG_CLINIC"/>
                </span>
				  <div><span class="field"></span></div>
                <div><span class="field"></span></div>
				<div><span class="field"></span></div>
				
	
            </div>
            <div cmptype="tmp" name="DIAG_FINAL_BLOCK">
                <div>11. Диагноз заключительный:</div>
                <div>а) основной: <span class="field"><component cmptype="Label" captionfield="DIAG_FINAL"/></span></div>
				  <div><span class="field"></span></div>
                <div><span class="field"></span></div>
				<div><span class="field"></span></div>

                <div>б) осложнение основного: <span class="field"><component cmptype="Label" captionfield="DIAG_FIN_COMP"/></span></div>
				<div><span class="field"></span></div>
                <div>в) сопутствующий: <span class="field"><component cmptype="Label" captionfield="DIAG_FIN_ADD"/></span></div>
				  <div><span class="field"></span></div>
               
			
			</div>
			
			
			
			
			
			
			
			
			
        </div>
    </div>

    <style>
        .report-form {
            padding: 5pt 10pt;
        }
        .main-div {
            width: 100%;
            height: 100%;
            white-space: nowrap;
            font-size: 10pt;
            padding-left:0.5em;
        }
        .main-div > div { /* PDF fix */
            overflow: hidden;
        }
        .main-div table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
            font-size: 10pt;
        }
        .main-div table td {
            overflow: hidden;
            white-space: nowrap;
        }
        .main-div table td span.caption {
            padding-left: 2px;
        }
        .header-table {
            padding-top: 30pt;
        }
        .header-table > tbody > tr > td:first-child {
            padding-right: 10pt;
            width: 35%;
            white-space: normal;
            height: 100%;
            overflow: visible;
        }
        .header-table > tbody > tr > td:first-child .field {
            height: 100%;
            line-height: normal;
        }
        .header-table > tbody > tr > td:last-child {
            width: 50%;
        }
        .title {
            text-align: center;
            padding-top: 15pt;
            padding-bottom: 5pt;
            font-weight: bold;
            position: relative;
            width: 100%;
        }
        .main-div div {
            margin: 0;
            position: relative;
        }
        .main-div div.sign {
            text-align: center;
            font-size: 8pt;
            line-height: 8pt;
        }
        .main-div span.text {
            position: absolute;
            white-space: normal;
            width: 100%;
            top: 1.5pt;
            left: 0;
            font-weight: bold;
            line-height: 15pt;
        }
        .diag-table {
            border-bottom: 1px solid #000;
        }
        .diag-table > tbody > tr > td:first-child {
            border-right: 1px solid #000;
        }
        .diag-table > tbody > tr > td:last-child > p:first-child {
            text-align: center;
        }
        .diag-table table > tbody > tr > td:first-child {
            width: 65%;
        }
        .field {
            border-bottom: 1px solid #000;
            
            padding: 0 2px;
            display: inline-block;
            vertical-align: text-bottom;
            height: 14pt;
            line-height: 18pt;
            width: 100%;
            font-weight: bold;
        }
        .notnowrap {
            white-space: normal;
        }
        .underlined {
            border-bottom: 1px solid #000;
            padding: 0 2px;
        }
        .text1 {
            white-space: normal;
            font-weight: bold;
            border-bottom: 1px solid #000;
            line-height: 15pt;
        }
        .field-sh {
            border-bottom: 1px solid #000;
            text-align:center;
            padding: 0 2px;
            display: inline-block;
            vertical-align: text-bottom;
            height: 14pt;
            line-height: 18pt;
            width: 100%;
            font-weight: bold;
        }
    </style>
</div>