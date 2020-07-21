<table cmptype="TMP" dataset="ds1" oncreate="base().onCreateUpper()" style="width:100%;font-size:10pt;">
<component cmptype="Script">
  Form.onCreateUpper = function()
  {
  	setVar('VISIT', $_GET['REP_VISIT_ID']);
	setVar('VISIT_DIAGN', $_GET['VISIT_DIAGN']);
	if(empty(getVar('VISIT')) &amp;&amp; !empty(getVar('VISIT_DIAGN')))
		setVar('VISIT', getVar('VISIT_DIAGN'));
  	executeAction('getVisitData', null, null, null, false);
  	setWindowCaption('Отчет: Заключение');
  }
</component>
    <component cmptype="Action" name="getVisitData">
    <![CDATA[
        declare nLPU NUMBER(17);
                nAGENT NUMBER(17);
    begin
     begin
     select d.PATIENT_ID, d.HOSP_MKB, d.PATIENT, d.REG_EMPLOYER_FIO, d.REG_EMPLOYER_FIO, d.REG_EMPLOYER_ID, trunc(d.REG_DATE), trunc(d.REG_DATE), d.DIR_COMMENT,
            d.LPU, nvl(d.LPU_TO_HANDLE, d.LPU_TO_NAME), CASE WHEN d.dir_numb IS NOT NULL THEN '№ ' || d.dir_numb END
     
     into :PATIENT_ID, :MKB_FULL_NAME, :PATIENT,  :EMPLOYER_FIO_FULL, :EMPLOYER_FIO, :EMPLOYER_ID, :REC_DATE, :REC_DATE_TRUNC, :DIR_COMMENT, nLPU,:LPU_TO_NAME, :DIR_NUMB
     from d_v_directions d
     where d.ID = :DIR_ID;
     exception when no_data_found
            then D_P_EXC('Направление на госпитализацию не найдено ('||:DIR_ID||')');
     end;
     begin
             select t.fullname,
        	    t.code_ogrn
               into :fullname,:code_ogrn
               from d_v_lpu t 
              where t.id = nLPU;
     end;

     begin
           select t.BIRTHDATE,
                  d_pkg_agent_addrs.GET_ACTUAL_ON_DATE(t.AGENT,sysdate,1, 'FULL'),
                  d_pkg_agent_polis.GET_ACTUAL_ON_DATE(t.AGENT,sysdate,0, 'P_SER P_NUM'),
                  d_pkg_agent_work_places.GET_ACTUAL_ON_DATE(t.AGENT,sysdate,'WORK_PLACE_NAME WORK_PLACE_HAND, JOBTITLE_TITLE'),
		  t.AGENT
                    
            into :BIRTHDATE,
                    :ADR_FULL,
                    :PLOIS,
                    :WORK_PLACE,
                    nAGENT
            from d_v_persmedcard t
            where t.ID = :PATIENT_ID;
            
            begin
                SELECT d_stragg(ac.CATEGORY_CODE)
                 into :LG_CODE
                 FROM  d_v_agent_categories ac
                WHERE ac.pid = nAGENT
                  AND ac.DATE_B  <= trunc(SYSDATE)
                  AND (ac.DATE_E >= trunc(SYSDATE) OR ac.DATE_E IS NULL) ; 
                exception when NO_DATA_FOUND then :LG_CODE:=null;
              end;
     end;
	 
	 begin
                select d.DP_MGR_NAME, d.DP_MGR_ID
                  into :ZAV_OTD, :ZAV_OTD_ID
                  from D_V_EMPLOYERS e,
                       D_V_DEPS d
                 where e.DEPARTMENT_id= d.id
                   and e.id=:EMPLOYER_ID;
               exception when NO_DATA_FOUND then :ZAV_OTD:= null;
         end;
	 
     end;]]>
        <component cmptype="ActionVar" name="CABLAB" 		src="CABLAB"             srctype="session"/>
	<component cmptype="ActionVar" name="LPU" 		src="LPU"                srctype="session"/>
        <component cmptype="ActionVar" name="DIR_ID" 	        src="DIRECTION_ID"       srctype="var" 	       get="v1"/>
        <component cmptype="ActionVar" name="BIRTHDATE"         src="BIRTHDATE_LABEL" 	 srctype="ctrlcaption" put="v2"  len="25"/>
        <component cmptype="ActionVar" name="ADR_FULL" 	        src="ADR_FULL_LABEL"     srctype="ctrlcaption" put="v3"  len="500"/>
        <component cmptype="ActionVar" name="PATIENT_ID"        src="PATIENT_ID" 	 srctype="var" 	       put="v4"  len="17"/>
        <component cmptype="ActionVar" name="MKB_FULL_NAME" 	src="MKB"	         srctype="ctrlcaption" put="v5"  len="550"/>
        <component cmptype="ActionVar" name="PATIENT" 	        src="PATIENT" 	         srctype="ctrlcaption" put="v6"  len="160"/>
        <component cmptype="ActionVar" name="PLOIS"             src="PATIENT_OMS"        srctype="ctrlcaption" put="v8"  len="160"/>
        <component cmptype="ActionVar" name="EMPLOYER_ID"       src="EMPLOYER_ID"        srctype="var"         put="v9"  len="17"/>
        <component cmptype="ActionVar" name="EMPLOYER_FIO_FULL" src="EMPLOYER_FIO_FULL"  srctype="var"         put="v10" len="360"/>
        <component cmptype="ActionVar" name="EMPLOYER_FIO"      src="LABEL_EMPLOYER_FIO" srctype="ctrlcaption" put="v11" len="360"/>
        <component cmptype="ActionVar" name="REC_DATE"          src="REC_DATE"           srctype="var"         put="v12" len="20"/>
        <component cmptype="ActionVar" name="REC_DATE_TRUNC"    src="REC_DATE_TRUNC"     srctype="ctrlcaption" put="v13" len="20"/>
        <component cmptype="ActionVar" name="WORK_PLACE"        src="WORK_PLACE"         srctype="ctrlcaption" put="v15" len="300"/>
        <component cmptype="ActionVar" name="DIR_COMMENT"       src="DIR_COMMENT"        srctype="ctrlcaption" put="v16" len="500"/>
        <component cmptype="ActionVar" name="LG_CODE"           src="LG_CODE"            srctype="ctrlcaption" put="v17" len="10"/>
	<component cmptype="ActionVar" name="ZAV_OTD"           src="ZAV_OTD"            srctype="ctrlcaption" put="v18" len="360"/>
	<component cmptype="ActionVar" name="ZAV_OTD_ID"           src="ZAV_OTD"            srctype="ctrl" put="ZAV_OTD_ID" len="360"/>
	<component cmptype="ActionVar" name="fullname"          src="fullname"           srctype="ctrlcaption" put="v19" len="400"/>
	<component cmptype="ActionVar" name="code_ogrn"         src="code_ogrn"          srctype="ctrlcaption" put="v20" len="40"/>
	<component cmptype="ActionVar" name="LPU_TO_NAME"       src="LPU_TO_NAME"        srctype="ctrlcaption" put="v21" len="400"/>
        <component cmptype="ActionVar" name="DIR_NUMB"          src="DIR_NUMB"           srctype="ctrlcaption" put="v22" len="500"/>
   </component>
<tbody>

	<tr>
		<td style="vertical-align:top;text-align:center; width:150px">
			<component style="font-size:8pt;" cmptype="Label" caption="Министерство здравоохранения Российской Федерации"/><br/><br/>

			<component  cmptype="Label" name="fullname"/><br/><br/>

			<div  style="margin-left 30px;"><component cmptype="Label" caption="Код ОГРН:"/>
			<b><component  cmptype="Label" name="code_ogrn"/></b>
			</div>
		</td>

		<td style="vertical-align:top;text-align:left; width:50%">
			<component style="font-size:8pt;" cmptype="Label" caption="Медицинская документация"/><br/>
			<component style="font-size:8pt;" cmptype="Label" caption="Форма № 057/у-04"/><br/><br/>
			<component style="font-size:8pt;" cmptype="Label" caption="утверждена приказом Минздравсоцразвития России"/><br/>
			<component style="font-size:8pt;" cmptype="Label" caption="от 22 ноября 2004 года № 255"/><br/>
<br/><br/>
		</td>
	</tr>
	</tbody>
	<tbody>
	<tr>
		<td colspan="3" style="text-align: center; width:400px">
			<b>
        <component style="font-size:12pt;" cmptype="Label"/>НАПРАВЛЕНИЕ<br/> на  <u>обследование</u>, консультацию"
        <component style="font-size:12pt;" cmptype="Label" name="DIR_NUMB"/>
      </b><br/>
			<component style="font-size:8pt;" cmptype="Label" caption="(нужное подчеркнуть)"/><br/><br/>

			<u><b><component  cmptype="Label" name="LPU_TO_NAME"/></b></u><br/>
			<component style="font-size:8pt;" cmptype="Label" caption="наименование медицинского учреждения"/>
			<br/>
		</td>
	</tr>
	</tbody>
	<tbody>
	<tr>
      <td style="text-align: left;" colspan="3">
	  <table style="width:100%">
	  <tr>
		<td style="width:35%;padding:2pt;">
		<component cmptype="Label" caption="1. Номер страхового полиса ОМС"/>
      </td>
	  <td style="width:65%;padding:2pt;">
		<b><component cmptype="Label" name="PATIENT_OMS"/></b>
	  </td>
    </tr>
    <tr>
	  <td style="text-align: left;padding:2pt;">
		<component cmptype="Label" caption="2. Код льготы: "/>
          </td>
	  <td style="padding:2pt;">
		<b><component cmptype="Label" name="LG_CODE"/></b>
	  </td>
    </tr>
	<tr>
      <td style="text-align: left;padding:2pt;">
		<component cmptype="Label" caption="3. Фамилия, Имя, Отчество"/>
      </td>
	  <td style="padding:2pt;">
		<b><component cmptype="Label" name="PATIENT"/></b>
	  </td>
    </tr>
	<tr>
      <td style="text-align: left;padding:2pt;">
		<component cmptype="Label" caption="4. Дата рождения"/>
      </td>
	  <td style="padding:2pt;">
		<b><component cmptype="Label" name="BIRTHDATE_LABEL"/></b>
	  </td>
    </tr>	
    <tr>
      <td style="text-align: left;padding:2pt;">
<component cmptype="Label" caption="5. Адрес постоянного места жительства"/>
</td>
<td style="padding:2pt;">
<b><component cmptype="Label" name="ADR_FULL_LABEL"/></b>
</td>
</tr>
    <tr>
      <td style="text-align: left;padding:2pt;">
<component cmptype="Label" caption="6. Место работы, должность"/>
</td>
<td style="padding:2pt;">
<b><component cmptype="Label" name="WORK_PLACE"/></b>
</td>
</tr>
	<tr>
      <td style="text-align: left;padding:2pt;">
		<component cmptype="Label" caption="7. Код диагноза по МКБ"/>
      </td>
	  <td style="padding:2pt;">
		<b><component cmptype="Label" name="MKB"/></b>
	  </td>
    </tr>	
	<tr>
      <td style="text-align: left;padding:2pt;">
		<component cmptype="Label" caption="8. Обоснование направления"/>
      </td>
	  <td style="padding:2pt;">
		<b><component cmptype="Label" name="DIR_COMMENT"/></b>
	  </td>
    </tr>	
	</table>
	</td>
	</tr>
	</tbody>
	</table>