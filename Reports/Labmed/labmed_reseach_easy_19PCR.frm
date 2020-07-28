<div cmptype="TMP" oncreate="base().onCreateRes()" onshow="base().OnShow();" style="width:95%; padding-left:10pt" class="print-page">
	<style type="text/css" >
		@page {size: landscape;}
		@page rotated { size: landscape; writing-mode: tb-rl;}
		div.print-page{
/*			print:rotated;*/
			font-family:Tahoma;
			font-size: 8pt;
			background-Color:#FFFFFF;
			/*writing-mode: tb-rl;*/
			height: 95%;
                        margin-bottom: 15pt;
		}
		div.print-header{
			font-size: 10pt;
			text-align:center;
			text-valign:middle;
			font-weight:bold;
		}
		div.print-text{
			font-size: 8pt;
			text-align:center;
			text-valign:middle;
			font-weight:normal;
		}
		td.print
		{
			border-collapse:collapse;
			font-size: 8pt;
			padding:2px;
			font-family:Tahoma;
			padding-top:0px;
			margin:0px;
			padding-bottom:0px;
			spasing:10px;
			border:1px solid #000000;
		}
		td.header
		{
			border-collapse:collapse;
			font-size: 8pt;
			padding:2px;
			font-family:Tahoma;
			border:1px solid #000000;
			padding-top:0px;
			margin:0px;
			padding-bottom:0px;
			spasing:10px;
			font-weight:bold;
			text-align:center;
		}
            @media print{
                div.print-page{
                    page-break-inside: avoid;
                }
            }
	</style>
    <component cmptype="Script">
 		<![CDATA[
			Form.onCreateRes = function () {
				setVar('PAT_PROB', $_GET['PAT_PROB']);
				if (empty($_GET['DIRSERV_ID']) == false) setVar('DIRSERV_ID', $_GET['DIRSERV_ID']);
				if (empty($_GET['PAT_PROB']) || empty($_GET['DIRSERV_ID']) == false) {
					setVar('DIRSERV_ID', $_GET['DIRSERV_ID']);
					executeAction('GET_PAT_ID', function () {
						setVar('PAT_PROB', getVar('PAT_PROB2'));
						refreshDataSet('DS_RESULTS');
						refreshDataSet('DS_RESULT_REF');
					});
				}else{
					refreshDataSet('DS_RESULTS');
					refreshDataSet('DS_RESULT_REF');
				}
				executeAction('GetTypeAnalyse', null, null, null, false, 0);
				executeAction('getSysdate', function () {
					setCaption('DATE_NOW', getVar('DATE_NOW'));
				});
				executeAction('SelectUser', function () {
					setCaption('EMPLOYER_FIO_SES', getVar('FIO_SES'));
				});
				executeAction('GetEmployerID', function () {
					getControlByName('SIGN_NAME').src='./UserFormsFNKC/Reports/Labmed/Signatures/' + getVar('EMP_ID') + '.png';
				});
				
			}
			Form.OnShow = function () {
				if (getDataSet('GET_DOP_PARAM').data.info.rowcount == 0) base().HideDopPar();
			}
			Form.Fn = function () {
				if (getVar('SPEC_ANALYSE_CNT') > 0) {
					getControlByName('ResearchBlock1').style.display = '';
					getControlByName('ResearchBlock2').style.display = 'none';
				} else {
					getControlByName('ResearchBlock1').style.display = 'none';
					getControlByName('ResearchBlock2').style.display = '';
				}
			}
			Form.setNormPatalogy = function (_dataArray, dom) {
				if (_dataArray['RAZNICA'] == '1') {
					setCaption('RAZNICA', '&nbsp;&nbsp;↑');
					dom.style.color = '#f00';
					dom.style.fontWeight = 'bold';
					//setDomVisible(getControlByName('Lab_up'), true);
					//setDomVisible(getControlByName('Lab_down'), false);
				}
				else if (_dataArray['RAZNICA'] == '0') {
					setCaption('RAZNICA', '&nbsp;&nbsp;↓');
					dom.style.color = '#f00';
					dom.style.fontWeight = 'bold';
					//setDomVisible(getControlByName('Lab_down'), true);
					//setDomVisible(getControlByName('Lab_up'), false);
				}
				else {
					setCaption('RAZNICA', '');
					dom.style.color = '#000';
					dom.style.fontWeight = 'normal';
				}
			}
		       Form.HideDopPar = function () {
				var el = document.getElementsByClassName('dop_par');
				for(var u=0;u<el.length;u++){
					el[u].style.display = 'none';
				}
			}
		]]>
    </component>

    <component cmptype="Action" name="GET_PAT_ID">
		begin
			select t.PATIENT_ID || '' || t.CROCKERY_PREF || '' || t.CROCKERY_NUMB
			  into :PAT_PROB2
			  from D_V_LABMED_PATJOUR t
			 where t.DIRECTION_SERVICE = :DIRSERV_ID;
			exception when OTHERS then null;
		end;
		<component cmptype="ActionVar" name="DIRSERV_ID"  srctype="var" src="DIRSERV_ID"  get="v1"/>
		<component cmptype="ActionVar" name="PAT_PROB2"   srctype="var" src="PAT_PROB2"   put="v1d" len="400"/>
    </component>

    <component cmptype="Action" name="GetTypeAnalyse">
		begin
				:ANALYSE_CODE := d_pkg_constants.search_str(psconst_code => :psconst_code,
																   pnlpu => :pnlpu,
																  pddate => sysdate,
																 pnraise => 0);
				select count(1)
				  into :SPEC_ANALYSE_CNT
				  from d_v_labmed_analyze t
					   join d_v_labmed_patjour t2 on t2.ANALYSE_ID = t.ID
				 where ';' || :ANALYSE_CODE || ';' like '%;' || t.LA_CODE || ';%'
				   and t2.DIRECTION_SERVICE = :DIRSERV_ID;
		end;
		<component cmptype="ActionVar" name="PNLPU"            srctype="session" src="LPU"/>
		<component cmptype="ActionVar" name="DIRSERV_ID"       srctype="var"     src="DIRSERV_ID"            get="v1"/>
		<component cmptype="ActionVar" name="psconst_code"     srctype="const"   src="LabmedResearchCompact" get="v2"/>
		<component cmptype="ActionVar" name="CNT_ANALYSE"      srctype="var"     src="CNT_ANALYSE"           put="v3"/>
		<component cmptype="ActionVar" name="ANALYSE_CODE"     srctype="var"     src="ANALYSE_CODE"          put="v4" len="250"/>
		<component cmptype="ActionVar" name="SPEC_ANALYSE_CNT" srctype="var"     src="SPEC_ANALYSE_CNT"      put="v5" len="10"/>
    </component>
	
	<component cmptype="Action" name="getSysdate"> 
        <![CDATA[ 
        begin 
            select to_char(sysdate, 'dd.mm.yyyy hh24:mi')
              into :DATE_NOW 
              from dual; 
        end; 
        ]]> 
        <component cmptype="ActionVar" name="DATE_NOW" src="DATE_NOW" srctype="var" put="DATE_NOW" len="30"/> 
    </component> 
    
    <component cmptype="Action" name="SelectUser">
			begin
				select D_PKG_STR_TOOLS.FIO(t.SURNAME,t.FIRSTNAME,t.LASTNAME)
				  into :FIO_SES
				  from d_v_employers t
				 where t.ID = :EMPLOYER;
			end;
		<component cmptype="ActionVar" name="PNLPU"     src="LPU"           srctype="session"/>
		<component cmptype="ActionVar" name="EMPLOYER"  src="EMPLOYER"      srctype="session"/>
		<component cmptype="ActionVar" name="FIO_SES"   src="FIO_SES"       srctype="var"     put="var1" len="100"/>
    </component>

    <component cmptype="Action" name="GetEmployerID">
			DECLARE
				TYPE emp_id_typ IS TABLE OF D_V_LABMED_RSRCH_JOUR.RESEARCH_EMP_ID%TYPE INDEX BY PLS_INTEGER;
				emp_ids emp_id_typ;
				
			begin
				select DISTINCT t.RESEARCH_EMP_ID
--				BULK COLLECT INTO emp_ids
				INTO :emp_id
				from D_V_LABMED_RSRCH_JOUR t 
				where t.PATJOUR_DIRECTION_SERVICE = :DIRSERV_ID;
				exception
					when too_many_rows THEN 
--						select
						Null;
--				select RESEARCH_EMP_ID INTO :EMP_ID FROM emp_ids WHERE 
			end;
		<component cmptype="ActionVar" name="DIRSERV_ID"       srctype="var"     src="DIRSERV_ID"            get="v1"/>
		<component cmptype="ActionVar" name="EMP_ID"   src="EMP_ID"       srctype="var"     put="var1" len="100"/>
    </component>	
	
    <component cmptype="DataSet" name="GET_DOP_PARAM">
			select lp.PAR_NAME,
				   coalesce(t.str_value, to_char(t.num_value), to_char(t.dat_value)) VALUE
			  from D_V_DIR_SERV_LM_PAR_VALUES t
				   join d_v_Labmed_Params lp on lp.ID = t.LBMD_PARAM
			 where t.pid = :DIRSERV_ID
		<component cmptype="Variable" name="DIRSERV_ID" src="DIRSERV_ID" srctype="var" get="v11" len="17"/>
    </component>
	
    <component cmptype="DataSet" name="ds1">
		select l.fullname,
			   l.fulladdress,
			   a.AGN_INN,
			   a.AGN_KPP,
			   l.CODE_OKPO,
			   l.PHONES,
			   d_pkg_option_specs.get('ContactsFax', :LPU) CONTACTSFAX,
			   d_pkg_option_specs.get('ContactsSite', :LPU) CONTACTSSITE,
			   d_pkg_option_specs.get('ContactsMail', :LPU) CONTACTSMAIL,
			   d_pkg_option_specs.get('ContactsTelReg', :LPU) CONTACTSTELREG
		  from d_v_lpu l
			   join d_v_lpudict ld on ld.ID = l.LPUDICT_ID
			   join d_v_agents a on a.ID = ld.AGENT
		 where l.id = :LPU
		<component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
    </component>

    <component cmptype="Action" name="getVisitData">
		begin
			begin
				 select ds.ID,
						ds.SERVICE_ID,
						ds.SERVICE,
						ds.SERVICE_NAME,
						d.PATIENT,
						d.PATIENT_ID,
						ds.DISEASECASE,
						ds.REC_DATE,
						trunc(ds.REC_DATE) REC_DATE_TRUNC
				   into :DIRSERV_ID,
						:SERVICE_ID,
						:SERVICE_CODE,
						:SERVICE_NAME,
						:PATIENT,
						:PATIENT_ID,
						:DISEASECASE,
						:REC_DATE,
						:REC_DATE_TRUNC
				  from d_v_direction_services ds
					   join d_v_directions d on d.ID = ds.PID
				 where ds.LPU = :LPU
				   and ds.ID = :DIRSERV_ID;
		   end;
	   end;
	    <component cmptype="ActionVar" name="LPU"                   src="LPU"                srctype="session"/>
            <component cmptype="ActionVar" name="DIRSERV_ID"        src="DIRSERV_ID"         srctype="var"         get="v11" len="17"/>
            <component cmptype="ActionVar" name="SERVICE_ID"        src="SERVICE_ID"         srctype="var"         put="v0"  len="17"/>
            <component cmptype="ActionVar" name="SERVICE_CODE"      src="SERVICE_CODE"       srctype="var"         put="v1"  len="20"/>
            <component cmptype="ActionVar" name="SERVICE_NAME"      src="LABEL_SERVICE_NAME" srctype="ctrlcaption" put="v2"  len="500"/>
            <component cmptype="ActionVar" name="EMPLOYER_ID"       src="EMPLOYER_ID"        srctype="var"         put="v3"  len="17"/>
            <component cmptype="ActionVar" name="EMPLOYER_FIO_FULL" src="EMPLOYER_FIO_FULL"  srctype="var"         put="v4"  len="360"/>
            <component cmptype="ActionVar" name="PATIENT"           src="PATIENT"            srctype="ctrlcaption" put="v6"  len="160"/>
            <component cmptype="ActionVar" name="PATIENT_ID"        src="PATIENT_ID"         srctype="var"         put="v7"  len="17"/>
            <component cmptype="ActionVar" name="DISEASECASE"       src="DISEASECASE"        srctype="var"         put="v8"  len="17"/>
            <component cmptype="ActionVar" name="REC_DATE"          src="REC_DATE"           srctype="var"         put="v9"  len="20"/>
            <component cmptype="ActionVar" name="REC_DATE_TRUNC"    src="REC_DATE_TRUNC"     srctype="ctrlcaption" put="v10" len="20"/>
    </component>
	
    <component cmptype="DataSet" name="DS_RESULTS" activateoncreate="false" compile="true">
		<![CDATA[ 
			select ds.ID,
				   pmc.BIRTHDATE BIRTHDATE_LABEL,
				   case when D_PKG_DAT_TOOLS.FULL_YEARS(sysdate,pmc.BIRTHDATE) = 0 then
						  case when D_PKG_DAT_TOOLS.FULL_UNITS(sysdate, pmc.BIRTHDATE,'MM') = 0
						  			then D_PKG_DAT_TOOLS.FULL_UNITS(sysdate, pmc.BIRTHDATE,'DD')||' дн.'
						       else D_PKG_DAT_TOOLS.FULL_UNITS(sysdate, pmc.BIRTHDATE,'MM')||' мес.'
						  end
					 	else D_PKG_DAT_TOOLS.FULL_YEARS(sysdate,pmc.BIRTHDATE)||''
				   end AGE,
				   coalesce(dir.REG_EMPLOYER_FIO, (select a.AGN_NAME from D_V_AGENTS_BASE a where a.ID = dir.REG_EMPLOYER_AGENT)) REG_EMPLOYER,
				   lp.LOCUS,
				   pmc.CARD_NUMB,
				   (select hh.HH_PREF||'-'||hh.HH_NUMB
				      from D_V_HOSP_HISTORIES hh 
					 where hh.PATIENT_ID = pmc.ID
					   and trunc(lp.PICK_DATE) between hh.DATE_IN and coalesce(hh.DATE_OUT,lp.PICK_DATE)
					   and hh.DATE_IN = (
							select max(hh1.DATE_IN)
				              from D_V_HOSP_HISTORIES hh1
					         where hh1.PATIENT_ID = pmc.ID
					           and trunc(lp.PICK_DATE) between hh1.DATE_IN and coalesce(hh1.DATE_OUT,lp.PICK_DATE)
					   )
				   ) HH_NUMB,
				   lp.SURNAME || ' ' || lp.FIRSTNAME || ' ' || lp.LASTNAME PATIENT2,
				   lr_j.RESEARCH_EMP_FIO,
				   lr_j.CONFIRM_EMP_FIO,
				   lr_j.RESEARCH_EMP_ID LABEL_EMPLOYER_ID,
				   lr_j.RESEARCH_DATE,
				   to_char(lr_j.RESEARCH_DATE,'hh24:mi') RESEARCH_TIME,
				   to_char(lp.PICK_DATE, 'dd.mm.yyyy') DATA2,
				   lr_sp.RESULT_TYPE,
				   lr_j.RESEARCH_EMP_FIO LABEL_EMPLOYER_FIO,
				   lr_sp.ID,
				   lr_sp.RES_VALUE,
				   lr_r.NAME,
				   lp.PATIENT_ID,
				   lr_j.RESEARCH_STATUS,
				   lr_j.IS_OPEN,
				   lr_r.ID RESULT_ID,
				   lr_r.CODE,
				   lr_r.ORDER_NUMB,
				   lr_r.NECESSARILY,
				   lp.ANALYSE,
				   ds.SERVICE,
				   a.ANALYZ_TYPE_ID AT_ID,
				   ds.ID ID_NAPR,
				   ds.SERVICE_NAME,
				   lp.ANALYSE_ID,
				   ds.SERVICE_ID,
				   ds.DP_NAME DEPARTMENT,
				   lp.ID ID_PATJOUR,
				   lp.CROCKERY_PREF,
				   lp.CROCKERY_NUMB,
				   lp.COMMENTS,
				   lr_j.RESEARCH_ID,
				   lr_sp.MEASURE,
				   lr_sp.RESULT,
				   lr_j.RESEARCH_NAME,
				   lp.PATIENT_ID || '' || lp.CROCKERY_PREF || '' || lp.CROCKERY_NUMB PAT_PROB,
				   lp.BIOMATERIAL_NAME,
				   D_PKG_LABMED_RSRCH_JOURSP.GET_REF_VALUE(lr_sp.ID, lr_sp.LPU, 4) RAZNICA
				   @if(:ADDRES){
				   		,D_PKG_AGENT_ADDRS.GET_ACTUAL_ON_DATE(pmc.AGENT, sysdate, 0, 'FULL') PATIENT_ADDRESS
				   @}
			  from D_V_LABMED_RSRCH_JOURSP lr_sp
				   join D_V_LABMED_RESEARCH_RES lr_r on lr_r.ID = lr_sp.RESULT_ID
				   join D_V_LABMED_RSRCH_JOUR lr_j on lr_j.ID = lr_sp.PID
				   join D_V_LABMED_PATJOUR lp on lp.ID = lr_j.PATJOUR
				   join D_V_DIRECTION_SERVICES ds on ds.ID = lp.DIRECTION_SERVICE
				   join D_V_DIRECTIONS dir on dir.ID = ds.PID
				   join D_V_LABMED_ANALYZE a on a.ID = lp.ANALYSE_ID
				   join D_V_PERSMEDCARD pmc on pmc.ID = lp.PATIENT_ID
			 where lr_sp.RES_VALUE is not null
			   and lr_j.IS_OPEN = 0
			   @if(:PICK_DATE || :PAT_PROB || :DIRSERV_ID){
			   @if(:PICK_DATE){
				and (trunc(lp.PICK_DATE) = to_date(:PICK_DATE, 'dd.mm.yyyy'))
			   @}
			   @if(:PAT_PROB){
				and lp.PATIENT_ID || lp.CROCKERY_PREF || lp.CROCKERY_NUMB = :PAT_PROB
			   @}
			   @if(:DIRSERV_ID){
			    and ds.ID = :DIRSERV_ID
			   @}
			   @}else{
                                and 1 = 0
			   @}
			 order by lp.ANALYSE_ID, lr_r.ORDER_NUMB
		]]>
		<component cmptype="Variable" name="PAT_PROB"   src="PAT_PROB"   srctype="var" get="v11"/>
		<component cmptype="Variable" name="PICK_DATE"  src="PICK_DATE"  srctype="var" get="v12"/>
        <component cmptype="Variable" name="DIRSERV_ID" src="DIRSERV_ID" srctype="var" get="v0"/>
        <component cmptype="Variable" name="ADDRES"     src="ADDRES"     srctype="var" get="v3"/>
    </component>
	
	<component cmptype="DataSet" name="DS_RESULT_REF" activateoncreate="false">
        <![CDATA[
            with j1 as
             (select j1.*
                  from d_v_labmed_rsrch_jour_web j1
                 where j1.LPU = :LPU
                   and j1.PATJOUR_DIRECTION_SERVICE = :DIRSERV_ID
                   and j1.RESEARCH_STATUS = 1)
            select j3.RESULT_ID,
                               j3.RESULT,
                               j1.RESEARCH_ID,
                               j1.RESEARCH,
                               coalesce(j4.REF_VALUE,
                                        case when j4.ID is not null
                                             then case when (D_PKG_DAT_TOOLS.FULL_YEARS(sysdate, j1.BIRTHDATE) between j4.F_FROM and j4.F_TO
                                                             or j4.F_FROM is null and j4.F_TO is null) and (j4.F_SEX = j1.SEX or j4.F_SEX is null)
                                                       then decode(j4.F_FROM || j4.F_TO,
                                                                    null,
                                                                    '',
                                                                    j4.F_FROM || ' - ' || j4.F_TO || ' ' || j4.F_MEASURE ||
                                                                    ' / ') || D_PKG_NUM_TOOLS.TO_STR(j4.REF_VALUE_FROM, 1) ||
                                                                    ' - ' || D_PKG_NUM_TOOLS.TO_STR(j4.REF_VALUE_TO, 1) || ' ' ||
                                                                    j3.MEASURE
                                                  end
                                        end) REF_VALUE
                            from j1
                                 join d_v_labmed_rsrch_joursp j3 on j3.PID = j1.ID and j3.LPU = j1.LPU
                                 left join D_V_LABMED_RSRCH_RES_REFS_ALL j4
                                        on (j3.RSRCH_RES_REF is not null and j3.RSRCH_RES_REF = j4.ID
                                            or j3.RSRCH_RES_REF is null and j3.RESULT_ID = j4.PID and j4.IS_MAIN = 1)
                                           and j4.DATE_BEGIN <= j1.PICK_DATE
                                           and (j4.DATE_END >= j1.PICK_DATE or j4.DATE_END is null)

                         order by j4.REF_TYPE_MNEMO
		]]>
        <component cmptype="Variable" name="DIRSERV_ID" src="DIRSERV_ID" srctype="var" get="v0"/>
        <component cmptype="Variable" name="LPU"        src="LPU"        srctype="session"/>
    </component>
	<table cmptype="TMP" dataset="ds1" style="width:100%">
		<thead dataset="ds1" repeate="1">
			<tr>
				<td>
					
					<component cmptype="Image" src="LpuLogo/$lpu$/logo.png" width="60px"/> 
				</td>
				<td style="text-align: right;" colspan="4">
					<component cmptype="Label" captionfield="FULLADDRESS"/>
					<br/>
					<component cmptype="Label" captionfield="FULLNAME"/>
					<br/>
					<component cmptype="Label" caption=" тел. "/>
					<component cmptype="Label" captionfield="PHONES"/>
					<component cmptype="Label" caption=" ИНН "/>
					<component cmptype="Label" captionfield="AGN_INN"/>
					<component cmptype="Label" caption=" КПП "/>
					<component cmptype="Label" captionfield="AGN_KPP"/>
					<component cmptype="Label" caption=" Код по ОКПО "/>
					<component cmptype="Label" captionfield="CODE_OKPO"/>
					<component cmptype="Label" captionfield="CONTACTSFAX"/>
					<component cmptype="Label" captionfield="CONTACTSTELREG"/>
					
				</td>
			</tr>
						<tr>
						<td colspan="5"><component cmptype="Label" caption="Лицензия № ФС-99-01-009750 от 14 мая 2020 на осуществление медицинской деятельности. " /> </td>
						</tr>
						<tr>
						<td colspan="5"><component cmptype="Label" caption="Санитарно-эпидимиологическое заключение № 77.МУ.02.000.М.000092.07.02 от 27 июля 2020  о соответсвии государственным санитарно-эпидимиологическим правилам " /></td>
						</tr>
						<tr>
						<td colspan="5"> <component cmptype="Label" caption="  и нормативам (Безопасность работ с микроорганизмами III IV групп патогенности (опастности) и возбудителями паразитарных болезней)" /> </td>
						</tr>
			<tr>
				<td colspan="5">
					<hr/>
					<br/>
				</td>
			</tr>
		</thead>
		<tbody dataset="DS_RESULTS" repeate="1">
			<tr>
				<td style="text-align: center;" colspan="4">
				   <b>
					   <font size="4px">
						   <component cmptype="Label" name="ANALYSE" captionfield="ANALYSE"/>
					   </font>
				   </b>
				   <br/>
					<br/>
				</td>
			</tr>
			<tr>
				<td style="text-align: left;" valign="top">
				   	<b>
						<component cmptype="Label" caption="Данные о пациенте"/>
				   	</b>
				   	<br/>
				</td>
				<td style="text-align: left;" valign="top">
				   	<b>
						<component cmptype="Label" caption="Данные о заборе биоматериала"/>
				   	</b>
				   	<br/>
				</td>
				<td style="text-align: left;" valign="top">
				   	<b>
					   <component cmptype="Label" caption="Данные анализа"/>
				   	</b>
				   	<br/>
				</td>
				<td style="text-align: left;" valign="top" class="dop_par">
					<b>
						<component cmptype="Label" caption="Дополнительные параметры"/>
					</b>
				</td>
			</tr>
			<tr>
				<td style="text-align: left;padding:3px;" valign="top">
					<component cmptype="Label" caption="ФИО пациента:"/>
					&amp;nbsp;
					<b>
						<component cmptype="Label" name="PATIENT2" captionfield="PATIENT2"/>
					</b>
					<br/>
					<component cmptype="Label" caption="Возраст:"/>
					&amp;nbsp;
					<b>
						<component cmptype="Label" name="AGE" captionfield="AGE"/>
					</b>
					<br/>
					<component cmptype="Label" caption="Дата рождения:"/>
					&amp;nbsp;
					<b>
						<component cmptype="Label" name="BIRTHDATE_LABEL" captionfield="BIRTHDATE_LABEL"/>
					</b>
					<br/>
					<component cmptype="Label" caption="№ амбулаторной карты:"/>
					&amp;nbsp;
					<b>
						<component cmptype="Label" name="CARD_NUMB" captionfield="CARD_NUMB"/>
					</b>
					<br/>
					<component cmptype="Label" caption="№ ИБ:"/>
					&amp;nbsp;
					<b>
						<component cmptype="Label" name="HH_NUMB" captionfield="HH_NUMB"/>
					</b>
				</td>
				<td style="text-align: left;padding:3px;" valign="top">
					<component cmptype="Label" caption="Дата забора: "/>
					<b>
						<component cmptype="Label" name="RESEARCH_DATE" captionfield="RESEARCH_DATE"/>    <!--Изменена лата забора  старое значение DATA2-->
					</b>
					<br/>
					<component cmptype="Label" caption="№ забора "/>
					<b>
						<component cmptype="Label" name="CROCKERY_NUMB" captionfield="CROCKERY_NUMB"/>
						<component cmptype="Label" caption=" - "/>
						<component cmptype="Label" name="CROCKERY_PREF" captionfield="CROCKERY_PREF"/>
					</b>
					<br/>
					<component cmptype="Label" caption="Локус "/>
					<b>
						<component cmptype="Label" name="LOCUS" captionfield="LOCUS"/>
					</b>
					<br/>
					<component cmptype="Label" caption="Биоматериал "/>
					<b>
						<component cmptype="Label" name="BIOMATERIAL_NAME" captionfield="BIOMATERIAL_NAME"/>
					</b>
				</td>
				<td style="text-align: left;padding:3px;" valign="top">
					<component cmptype="Label" caption="№ Направления - "/>
					<b>
						<component cmptype="Label" name="ID_NAPR" captionfield="ID_NAPR"/>
					</b>
					<br/>
					<component cmptype="Label" caption="Кто направил:"/>
					&amp;nbsp;
					<b>
						<component cmptype="Label" name="REG_EMPLOYER" captionfield="REG_EMPLOYER"/>
					</b>
					<br/>
					<component cmptype="Label" caption="Отделение:"/>
					&amp;nbsp;
					<b>
						<component cmptype="Label" name="DEPARTMENT" captionfield="DEPARTMENT"/>
					</b>
				</td>
				<td valign="top" class="dop_par">
					<br/>
					<table>
						<tr cmptype="tmp" dataset="GET_DOP_PARAM" repeate="0">
							<td>
								<component cmptype="Label" name="NAZV_DOP_PARAM" captionfield="PAR_NAME"/>
							</td>
							<td style="padding-left:5px;">
								<b>
									<component cmptype="Label" name="VALUE_DOP_PARAM" captionfield="VALUE"/>
								</b>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</tbody>
	</table>
	<br/>
	<table style="margin-top:5px;" cmptype="tmp" name="ResearchBlock1">
		<tr>
			<td style="vertical-align: bottom;">
				<table class="form-table" border="1">
					<colgroup>
						<col width="250"/>
					</colgroup>
					<tbody>
						<tr>
							<td>
								<div style="min-height:45px;min-width:170px;">
									<component cmptype="Label" caption="Исследования"/>
								</div>
							</td>
						</tr>
						<tr>
							<td>
								<component cmptype="Label" caption="Дата забора"/>
							</td>
						</tr>
						<tr>
							<td>
								<component cmptype="Label" caption="Дата исследования"/>
							</td>
						</tr>
						<tr>
							<td>
								<component cmptype="Label" caption="Результаты"/>
							</td>
						</tr>
						<tr dataset="DS_RESULTS" repeate="0" distinct="RESULT">
							<td>
								 <div style="min-height:30px;">
									 <component cmptype="Label" captionfield="RESULT"/>
									 <component cmptype="Label" caption=":"/>
								 </div>
							</td>
						</tr>
					</tbody>
				</table>
			</td>
			<td dataset="DS_RESULTS" repeate="0" distinct="RESEARCH_ID" keyfield="RESEARCH_ID" style="vertical-align:bottom;" afterrefresh="base().Fn();">
				<table class="form-table" border="1">
					 <colgroup>
						<col/>
						<col width="37"/>
					</colgroup>
					<tbody>
						<tr>
							<td colspan="3">
								<div style="min-height:45px;min-width:170px;font-weight:bold;">
									<component cmptype="Label" captionfield="RESEARCH_NAME" hintfield="RESEARCH_NAME"/>
								</div>
							</td>
						</tr>
						<tr>
							<td colspan="3">
								<div style="min-height:15px;">
									<component cmptype="Label" captionfield="PICK_DATE" hintfield="PICK_DATE"/>
									<component cmptype="Label" captionfield="PICK_TIME" hintfield="PICK_TIME"/>
								</div>
							</td>
						</tr>
						<tr>
							<td colspan="3">
								<div style="min-height:15px;">
									<component cmptype="Label" captionfield="RESEARCH_DATE" hintfield="RESEARCH_DATE"/>
									<component cmptype="Label" captionfield="RESEARCH_TIME" hintfield="RESEARCH_TIME"/>
								</div>
							</td>
						</tr>
						<tr>
							<td>
								<component cmptype="Label" caption="Значение"/>
							</td>
							<td>
								<component cmptype="Label" caption="Норма"/>
							</td>
							<td>
								<component cmptype="Label" caption="Норма"/>
							</td>
						</tr>
						<tr dataset="DS_RESULTS" repeate="0" keyfield="RESULT" distinct="RESULT" detail="true" parentfield="RESEARCH_ID">
							<td style="text-align:right;">
								<div style="min-height:30px;" dataset="DS_RESULTS" repeate="0" detail="true" keyfield="RESULT_ID" parentfieldsdata="{0:'RESULT',1:'RESEARCH_ID'}" onclone="base().setNormPatalogy(_dataArray,this)">
									<component cmptype="Label" captionfield="RES_VALUE"/>
									<component cmptype="Label" captionfield="MEASURE"/>
								</div>
							</td>
							<td>
								<div style="min-height:30px;" dataset="DS_RESULTS" repeate="0" detail="true" keyfield="RESULT_ID" parentfieldsdata="{0:'RESULT',1:'RESEARCH_ID'}" onclone="base().setNormPatalogy(_dataArray,this)">
									  <component cmptype="Label" captionfield="VAL_RESULT_MNEMO"/>
								</div>
							</td>
							<td>
								<div style="min-height:30px;" dataset="DS_RESULT_REF" repeate="0" detail="true" distinct="REF_VALUE" parentfieldsdata="{0:'RESULT',1:'RESEARCH_ID'}" onclone="base().setNormPatalogy(_dataArray,this)">
									  <component cmptype="Label" captionfield="REF_VALUE"/>;
								</div>
							</td>
							
						</tr>
					</tbody>
				</table>
			</td>
		</tr>
	</table>
  	<div cmptype="tmp" name="ResearchBlock2">
	
		<table border="1" dataset="DS_RESULTS" repeate="0" distinct="AT_ID" keyfield="AT_ID" width="100%" >
			<colgroup>
					<col width="40%"/>
					<col width="15%"/>
					<col width="15%"/>
					<col width="15%"/>
					<col width="15%"/>
			</colgroup>
		<thead>

			<tr>
				<td style="font-size:9pt;font-weight: bold;padding-left:5px;" width="40%">
					<component cmptype="Label" caption="Наименование"/>
				</td>
				<td style="font-size:9pt;text-align:center;font-weight: bold;" width="15%">
					<component cmptype="Label" caption="Результат"/>
				</td>
				
				<td style="font-size:9pt;text-align:center;font-weight: bold;" width="30%">
					<component cmptype="Label" caption="Реф.значение"/>
				</td>
				<td style="font-size:9pt;text-align:center;font-weight: bold;" width="30%">
					<component cmptype="Label" caption="Дата проведения"/>
				</td>			
			</tr>
		</thead>

			<tbody dataset="DS_RESULTS" repeate="0" keyfield="RESEARCH_ID" distinct="RESEARCH_ID" parentfield="AT_ID" detail="true" >
				<tr cmptype="tmp" dataset="DS_RESULTS" repeate="0" keyfield="RESULT_ID" detail="true" name="RESULT_TR" parentfield="RESEARCH_ID" onclone="base().setNormPatalogy(_dataArray,this)">
					<td style="font-size:9pt;text-align:left;padding-left:5px;">
						<component cmptype="Label" captionfield="RESULT"/>
					</td>
					<td style="font-size:9pt;text-align:center;">
						<component cmptype="Label" captionfield="RES_VALUE" name="RES_VALUE"/>
						<component cmptype="Label" captionfield="RAZNICA" name="RAZNICA"/>
					</td>
					
					<td style="font-size:9pt;text-align:center;">
						<div style="display:inline-block;" dataset="DS_RESULT_REF"  distinct="REF_VALUE" repeate="0" detail="true" keyfield="RESULT_ID" parentfieldsdata="{0:'RESULT_ID'}">
							  <component cmptype="Label" captionfield="REF_VALUE"/>
						</div>
					</td>
					<td>
						<div style="font-size:9pt;text-align:center;padding-left:5px;">
							<component cmptype="Label" captionfield="DATA2" hintfield="DATA2"/>  <!--Изменена лата забора  старое значение RESEARCH_DATE-->
							<component cmptype="Label" captionfield="RESEARCH_TIME" hintfield="RESEARCH_TIME"/>
						</div>
					</td>					
				</tr>
			</tbody>
		</table>
	</div>
	<br/>
	<div>  <b>  При получении положительного результата  рекомендована консультация  врача </b></div>
	<div>  <b>Комментарии:</b></div>
<div>  
<I>
"РНК не обнаружена": в анализируемом образце РНК коронавируса СО\/Ю-19 отсутствует или его концентрация ниже чувствительности тест-системы. Результат "РНК не обнаружена" является показателем отсутствия возбудителя на момент взятия мазка из носоглотки/ротоглотки. Повторное исследование проводить согласно рекомендациям Роспотребнадзора.
Внимание! Отрицательный результат лабораторного исследования на коронавирус СО\/Ю-19 не отменяет карантинных мер, если они были рекомендованы Роспотребнадзором. Для получения консультации по карантинным мерам обратитесь, пожалуйста, в Единый консультационный центр Роспотребнадзора по тел. 8-800-555-49-43.
Результаты исследований на коронавирус СОМ О-19 в обязательном порядке передаются в территориальный орган Роспотребнадзора.
</I>
</div>

	<table style="width:100%">
		<tr>
			<td>
				<component cmptype="Label" name="COMMENTS" captionfield="COMMENTS" dataset="DS_RESULTS" repeate="1" before_caption="&lt;b&gt;Комментарии - &lt;/b&gt;" after_caption="&lt;br/&gt;&lt;br/&gt;"/>
				<b>
					<component cmptype="Label" caption="Подпись"/>
				</b>
				<br/>
				<component cmptype="Label" caption="ФИО сотрудника лаборатории: "/>
				<component cmptype="Label" name="LABEL_EMPLOYER_FIO" captionfield="LABEL_EMPLOYER_FIO" dataset="DS_RESULTS" repeate="1"/>
				<component cmptype="Label" caption=" _______________"/>
			</td>
			<td><img cmptype="tmp" style="width:150px;" name="SIGN_NAME" src="" /> 
			</td>
<!--			<td><component style="margin: 6px 0; width:48px; height:48px;" cmptype="Image" src="Logo/frccpcm_logo144.gif"/></td>-->
			<td align="right" cmptype="Base" name="footerRightCol">
				<component cmptype="Label" caption="Дата и время печати: "/>
				<component cmptype="Label" name="DATE_NOW"/>
				<br/>
				<component cmptype="Label" caption="Распечатал: "/>
				<u><component cmptype="Label" name="EMPLOYER_FIO_SES"/></u>
			</td>
		</tr>
	</table>
</div>