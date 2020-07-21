<div cmptype="TMP" oncreate="base().onCreateUpper()" style="width:100% ">
<component cmptype="Script">
  Form.onCreateUpper = function()
  {
  	setVar('VISIT', $_GET['REP_VISIT_ID']);

	setVar('VISIT_DIAGN', $_GET['VISIT_DIAGN']);
	if(empty(getVar('VISIT')) &amp;&amp; !empty(getVar('VISIT_DIAGN')))
		setVar('VISIT', getVar('VISIT_DIAGN'));

  	executeAction('getVisitData', null, null, null, false);
        if(isExistsControlByName('LABEL_EMPLOYER_FIO'))
        {
            setCaption('LABEL_EMPLOYER_FIO',getVar('LABEL_EMPLOYER_FIO'));
        }
  	setWindowCaption('Отчет: Медицинская карта');
  }
</component>
    <component cmptype="Action" name="getVisitData">
	begin
            begin
                select ds.ID, ds.SERVICE_ID, ds.SERVICE, ds.SERVICE_NAME, v.EMPLOYER_ID, em.SURNAME||' '||em.FIRSTNAME||' '||em.LASTNAME EMPLOYER_FIO_FULL, v.EMPLOYER_FIO,
               d.PATIENT, d.PATIENT_ID, d.PATIENT_CARD, ds.DISEASECASE, ds.REC_DATE, trunc(v.VISIT_DATE) REC_DATE_TRUNC, em.SPECIALITY||':'
            into :DIRECTION_SERVISES, :SERVICE_ID, :SERVICE_CODE, :SERVICE_NAME, :EMPLOYER_ID, :EMPLOYER_FIO_FULL, :EMPLOYER_FIO,
                :PATIENT, :PATIENT_ID, :PATIENT_CARD, :DISEASECASE, :REC_DATE, :REC_DATE_TRUNC, :SPEC_DOC
                from d_v_direction_services ds, d_v_employers em, d_v_directions d, d_v_visits v
                where ds.EMPLOYER_TO = em.ID(+)
                  and d.ID = ds.PID
                  and v.PID(+) = ds.ID
                  and v.ID = :VISIT;
                  exception when no_data_found then
                   D_PKG_MSG.RECORD_NOT_FOUND(:VISIT,'VISITS');
             end;

             begin
                    select a.BIRTHDATE,
                            d_pkg_agent_addrs.GET_ACTUAL_ON_DATE(a.ID,sysdate,1, 'FULL'),
                            D_PKG_DAT_TOOLS.FULL_YEARS(sysdate,a.BIRTHDATE)
                                            AGE
                    into :BIRTHDATE,
                            :ADR_FULL,
                            :AGE
                    from d_v_persmedcard t, d_v_agents a
                    where t.AGENT = a.ID
                      and t.ID = :PATIENT_ID;
             end;
	 end;
	    <component cmptype="ActionVar" name="LPU" src="LPU" srctype="session"/>
            <component cmptype="ActionVar" name="VISIT" src="VISIT" srctype="var" get="v9"/>
            <component cmptype="ActionVar" name="DIRECTION_SERVISES" src="DIRECTION_SERVISES" srctype="var" put="v11" len="17"/>
            <component cmptype="ActionVar" name="SERVICE_ID" src="SERVICE_ID" srctype="var" put="v0" len="17"/>
            <component cmptype="ActionVar" name="SERVICE_CODE" src="SERVICE_CODE" srctype="var" put="v1" len="20"/>
            <component cmptype="ActionVar" name="SERVICE_NAME" src="LABEL_SERVICE_NAME" srctype="ctrlcaption" put="v2" len="250"/>
            <component cmptype="ActionVar" name="EMPLOYER_ID" src="EMPLOYER_ID" srctype="var" put="v3" len="17"/>
            <component cmptype="ActionVar" name="EMPLOYER_FIO_FULL" src="EMPLOYER_FIO_FULL" srctype="var" put="v4" len="360"/>
            <component cmptype="ActionVar" name="EMPLOYER_FIO" src="LABEL_EMPLOYER_FIO" srctype="var" put="v5" len="360"/>
            <component cmptype="ActionVar" name="PATIENT" src="PATIENT" srctype="ctrlcaption" put="v6" len="160"/>
            <component cmptype="ActionVar" name="PATIENT_ID" src="PATIENT_ID" srctype="var" put="v7" len="17"/>
            <component cmptype="ActionVar" name="DISEASECASE" src="DISEASECASE" srctype="var" put="v8" len="17"/>
            <component cmptype="ActionVar" name="REC_DATE" src="REC_DATE" srctype="var" put="v9" len="20"/>
            <component cmptype="ActionVar" name="REC_DATE_TRUNC" src="REC_DATE_TRUNC" srctype="ctrlcaption" put="v10" len="20"/>
            <component cmptype="ActionVar" name="BIRTHDATE" src="BIRTHDATE_LABEL" srctype="ctrlcaption" put="vv1" len="25"/>
            <component cmptype="ActionVar" name="AGE" src="AGE_LABEL" srctype="ctrlcaption" put="vv3" len="25"/>
            <component cmptype="ActionVar" name="ADR_FULL" src="ADR_FULL_LABEL" srctype="ctrlcaption" put="v2v" len="500"/>
            <component cmptype="ActionVar" name="SPEC_DOC" src="SPEC_DOCT" srctype="var" put="v2vc2" len="500"/>
            <component cmptype="ActionVar" name="PATIENT_CARD" src="CARD_NUMBER" srctype="var" put="PATIENT_CARD" len="20"/>
    </component>
<table style="margin-left:80px;width:625px; border: 0px double black;">
<tbody>
	<tr>
            <td style="text-align:center">
                <b><component cmptype="Label" caption="Обследование"/></b>
            </td>
	</tr>
	<tr>
            <td style="text-align: right;">
                    <b>
                            <component cmptype="Label" name="REC_DATE_TRUNC"/>
                    </b>
            </td>
	</tr>
	<tr>
          <td style="text-align: left;">
                    <component cmptype="Label" caption="Пациент:"/>&amp;nbsp;<b><component cmptype="Label" name="PATIENT"/></b>
          </td>
        </tr>
	<tr>
          <td style="text-align: left;">
                    <component cmptype="Label" caption="Дата рождения"/>&amp;nbsp;<b><component cmptype="Label" name="BIRTHDATE_LABEL"/></b> Возраст: <b><component cmptype="Label" name="AGE_LABEL"/></b>
          </td>
        </tr>
	<tr>
          <td style="text-align: left;">
                    <component cmptype="Label" caption="Адрес:"/>&amp;nbsp;<b><component cmptype="Label" name="ADR_FULL_LABEL"/></b>
          </td>
        </tr>
	<tr>
            <td style="text-align: center;">
                    <b><component cmptype="Label" name="LABEL_SERVICE_NAME" before_caption="&lt;br/&gt;"/><br/><br/></b>
            </td>
	</tr>
</tbody>
</table>
</div>