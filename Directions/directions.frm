<div cmptype="direction" version="2.5" oncreate="base().onCreate()" onshow="base().onShow();" window_size="100%x100%">

	<component cmptype="ProtectedBlock" alert="true" modcode="Doctor">
		<div cmptype="title">Дневник врача</div>
		<component cmptype="SubForm" path="Visit/PrintVisit"/>
		<component cmptype="SubForm" path="CostReferences/cost_references_actions"/>
		<component cmptype="SubForm" path="RegWrite/OpenRegWrite"/>
		<component cmptype="SubForm" path="Markers/subscripts/subscript_markers" name="MarkersScripts"/>
		<component cmptype="DataSet" activateoncreate="false" name="DS_USUAL" mode="Range" compile="true">
			<![CDATA[/**/
				select t.ID,
			           t.TIMER,
					 @if(:SHOW_COLOR) {
					   case when instr(';'||:SHOW_COLOR||';', ';'||t.PK_CODE||';') <> 0 then
						    1 else 0
					   end COLOR,
					 @}
			           t.PATIENT_FIO,
                       t.PATIENT_CARD_NUMB,
			           t.SE_CODE || ', ' || t.TOTAL || (SELECT case when e.fio is not null then ', оказал: '||e.fio end
                                                          FROM D_V_EMPLOYERS_FIO e
                                                         WHERE e.ID = t.VISIT_EMPLOYER) TOTAL,
			           t.TOTAL_HINT,
			           t.SERV_STATUS,
			           t.SE_TYPE,
			           t.SE_CODE,
			           t.SERVICE_ID,
                       t.S_COMMNET,
						@if((:SHOWHOSP==1)||(:SHOWHOSP==2)) {
						case when t.HH_LPU_FULLNAME is null then
									  case when t.HH_DEP  IS NOT NULL THEN 'С' else '' end
							 when t.HH_LPU_FULLNAME = 'текущем ЛПУ' then 'ИБ'
							 else 'ИБ*'
						end
						@}else{
						''
						@}
						IS_STAC,
						@if((:SHOWHOSP==1)||(:SHOWHOSP==2)) {
						case when t.HH_LPU_FULLNAME is null then
								case when t.hh_dep  IS NOT NULL THEN 'Стационар' else '' end
							 else 'Пациент находится на стационарном лечении в '||t.HH_LPU_FULLNAME
						end
						@}else{
						''
						@}
					   IS_STAC_HINT,
			           decode(t.HYPERLINK, 'Неявка', null, t.HYPERLINK) HYPERLINK,
			           decode (t.HYPERLINK, null, 'Отменена', 'Неявка', t.HYPERLINK, null) HYP_LABEL,
			           t.PATIENT_ID,
                       (D_PKG_CONTROL_CARD.HAS_DISP_REGISTRATION(:LPU,t.PATIENT_ID) *
                           (select case when count(1) > 0 then 1 else 0 end
                              from D_V_CONTROL_CARD c
                                   left join D_V_CONTROL_CARD_KIND_HELP kh on c.ID = kh.PID
                             where c.LPU = :LPU
                                   and c.PERSMEDCARD_ID = t.PATIENT_ID
                                   and (c.T_CODE != 9 or kh.CONTROL_TYPE_HELP_CODE != 'К'))
                       ) HAS_DISP,
                       t.PATIENT_AGENT,
                       t.PATIENT_NSEX,
			           t.REG_EMPLOYER,
			           t.VISIT_EMPLOYER,
			           t.DIRECTION DIRECTION_ID,
                       t.DIRECTION_KIND_NAME,
			           t.VISIT,
			           t.DISEASECASE,
		  	           t.CONTRACT_TYPE,
                       t.NURSE_USER_TEMPLATES,
                       t.OUTER_DIRECTION_ID,
                       t.REPRESENT_DIRECTION_ID,
                       t.REPRESENT_DIRECTION_LPU,
					   case when
						 exists(select null
								  from D_V_LABMED_RSRCH_JOURSP js
									   join D_V_LABMED_RSRCH_JOUR j on j.ID = js.PID
									   join D_V_DIRECTION_SERVICES_BASE ds on ds.ID = j.PATJOUR_DIRECTION_SERVICE
								 where js.VAL_RESULT = 1
								   and ds.DISEASECASE = t.DISEASECASE
								   and trunc(j.RESEARCH_DATE) = trunc(sysdate))
						 then 1 else 0
					   end IS_PATALOGY,
				       case when :SHOWLOSTRECORDS = 1
				             and d_pkg_clschs.get_info(:LPU,
				             						   case
														 when t.REC_TYPE in (0,2,4) then 0
														 when t.REC_TYPE in (1,3,5) then 1
													   end,
				             						   t.REC_DATE,
				             						   t.CABLAB_TO,
				             						   t.EMPLOYER_TO,
				             						   t.SERVICE_ID,
				             						   t.DIRECTION_REG_TYPE,
				             						   case t.REG_TYPE
                                                	     when 0 then 1 else 0 end) is null
				             then chr(13)||chr(10)||'Запись утеряна, выберите другое время приема.'
				             else '' end REC_LOST,
					   case when
						 exists(select null
								  from D_V_AGENT_COMP_DISEASES t
								 where t.PID = t.PATIENT_AGENT
								   and t.DATE_BEGIN <= sysdate
								   and (t.DATE_END >= sysdate
										or t.DATE_END is null))
						 then 1 else 0
					   end EXISTS_COMP_DIS,
					   case when
						 exists(select null
								  from D_V_AGENT_ALLERG_ANAMNESIS tr
								 where tr.PID = t.PATIENT_AGENT
								   and tr.BEGIN_DATE <= sysdate
								   and (tr.END_DATE >= sysdate
										or tr.END_DATE is null))

						 then 1 else 0
					   end EXIST_ALLERG,
					   case
						 when t.CONTRACT_TYPE = 1
						   then
							 case
							   when D_PKG_DIRECTION_SERVICES.GET_PAYMENT_STATUS(:LPU,t.ID) = 0
									or (exists(select null
												 from D_V_DIRECTION_SERVICES_BASE ds
												where ds.IRID = t.ID
												  and ds.PID = t.DIRECTION
												  and rownum = 1)
										and (select min(D_PKG_DIRECTION_SERVICES.GET_PAYMENT_STATUS(:LPU,ds.ID))
											   from D_V_DIRECTION_SERVICES_BASE ds
											  where ds.IRID = t.ID
												and ds.PID = t.DIRECTION) = 0)
								 then 'Не оплачено'
								   else ''
							 end
						   else ''
					   end PAID,
                       trim(case when t.PAYMENT_KIND = :PK_OMS then D_PKG_PERSMEDCARD.CHECK_FOR_OMS(t.PATIENT_ID) else null end) CHECK_OMS,
                       trim(case when t.FAC_ACCOUNT_DEBT > 0 then ' Долг пациента '||t.FAC_ACCOUNT_DEBT else null end) PAY_HAS,

					   case when
						 exists(select null
								  from D_V_HH_DIETARIES hhd
									   join D_V_HOSP_HISTORIES_BASE hh on hh.ID = hhd.PID
									   join D_V_HOSP_REGIMES hr on hr.ID = hhd.HOSP_REGIME_ID
								 where trunc(t.REC_DATE) between trunc(hhd.DATE_BEGIN) and coalesce(trunc(hhd.DATE_END), trunc(sysdate))
								   and hh.PATIENT = t.PATIENT_ID
								   and hr.HR_CODE in (select COLUMN_VALUE
														from table(D_PKG_TOOLS.STR_SEPARATE(D_PKG_OPTIONS.GET('HHRegimesBads', :LPU))))
								   and hh.DATE_OUT is null
								   and rownum = 1)
						 then 1 else 0
					   end PATIENT_IN_BED,
                       case when :SHOW_BUTTON = 0  OR t.SERV_STATUS <> 0
                                then 0
				            else (select 2 - count(1)
				                    from D_V_IB_INVITEES temp
				                   where temp.DIRECTION_SERVICE = t.ID)
				       end SHOW_BUTTON,
                       (select d_stragg(t1.ID)
                          from D_V_DIRECTIONS_BASE t1
                         where t1.REG_VISIT = t.VISIT and t1.DIR_TYPE = 1
                       )HOSP_DIR,
                       (select d_stragg(m.MARKER||'/'||m.GRAD_FROM||'/'||m.GRAD_TO)
                          from D_V_PMC_MARKERS m
                         where m.PID = t.PATIENT_ID
                           and m.BEGIN_DATE <= sysdate
                           and (m.END_DATE is null or m.END_DATE >= sysdate)
                           and d_pkg_cse_accesses.check_right(pnlpu => :LPU,
														psunitcode => 'MARKERS',
														pnunit_id => m.MARKER_ID,
														psright => 1,
														pncablab => :CABLAB) < 1
                       ) MARKER
					@if (:QUEUING == null || :QUEUING == 0 || :QUEUING == 1) {
					,
					case when exists(select null
									   from D_V_IB_INVITEES i
									  where i.DIRECTION_SERVICE = t.ID
									    and rownum = 1)
							  and trunc(t.REC_DATE) = trunc(sysdate)
							  and t.SERV_STATUS != 2
						 then 'Вызван'
						 when trunc(t.REC_DATE) = trunc(sysdate)
							  and t.SERV_STATUS = 0
						 then 'Ожидает'
					end INVITE_STATUS
					@}
					@if (:QUEUING == 1) {
			        ,
					case when exists(select null
									   from D_V_IB_INVITEES i
									  where i.DIRECTION_SERVICE = t.ID
									    and rownum = 1)
							  and trunc(t.REC_DATE) = trunc(sysdate)
							  and t.SERV_STATUS != 2
						 then 'Вызван'
			             when exists(select null
			                           from D_V_IB_QUEUE q
			                          where q.DIRECTION_SERVICE = t.ID
			                            and rownum = 1)
			                  and trunc(t.REC_DATE) = trunc(sysdate)
			                  and (t.SERV_STATUS = 0 or (t.SERV_STATUS = 1 and exists(select null
																					    from D_V_IB_QUEUE q
																					   where q.DIRECTION_SERVICE = t.ID
			                                                                             and q.IS_RETURNED = 2
																						 and rownum = 1)
			                                            )
								  )
			             then 'Ожидает'
			        end INVITE_STATUS
					@}
					@if (:QUEUING == 2) {
					,
					case when exists(select null
									   from D_V_IB_INVITEES i
									  where i.DIRECTION_SERVICE = t.ID
									    and rownum = 1)
							  and t.EMPLOYER_TO = :EMPLOYER
							  and t.CABLAB_TO = :CABLAB
							  and trunc(t.REC_DATE) = trunc(sysdate)
							  and t.SERV_STATUS != 2
						 then 'Вызван'
						 when trunc(t.REC_DATE) = trunc(sysdate) and t.SERV_STATUS = 0
						 then 'Ожидает'
					end INVITE_STATUS
					@}
                    @if (:SHOW_FLG == 1) {
					   ,
					   case when exists(select null
                                  from D_V_AGENT_FLU_BASE a
                                 where a.PID = t.PATIENT_AGENT) then 1 else 0 end  AGENT_FLU,
		       case when exists(select null
                                  from D_V_AGENT_FLU_PMC_LAST af
                                 where af.PID = t.PATIENT_AGENT
                                   and t.REC_DATE > af.NEXT_DATE
                                   and af.FLU_PURPOSE = 1) then 1 else 0 end  PMC_FLU,
		       case when exists(select null
                                  from D_V_AGENT_FLU_PMC_LAST af
                                 where af.PID = t.PATIENT_AGENT
                                   and af.FLU_PURPOSE in (1, 2)
                                   and af.FLU_CONCLUSION = 2) then 1 else 0 end  PMC_FLU_PATALOGY,
                       trunc(months_between(sysdate, t.BIRTHDATE)/12) AGN_YEARS
                    @}
                    @if(:CHECKPREGNANCY){
                       ,case when
                         exists(select null
                              from D_V_AGENT_PREGNANCY ap
                                 where ap.PID = t.PATIENT_AGENT
                               and ap.END_DATE is null
                                   and round((sysdate - ap.BEGIN_DATE)/7) > 42
                                   and rownum = 1
                               ) then 1 else 0
                       end
                    @}else{
                       ,0
                    @}
                    as IS_OL_PREG
					@if(:IS_RISAR) {
						, case when D_PKG_VISITS.RISAR_ERROR(t.VISIT,:LPU) is null
						    then
							   case when D_PKG_VISITS.RISAR_DATE(t.VISIT,:LPU) is null
							     then '-1'
							     else '1'
                               end
						    else D_PKG_VISITS.RISAR_ERROR(t.VISIT,:LPU)
						  end IS_RISAR
					@}
				     @if(:USE_QUEUE74 > 0) {
				       ,wlr.ID                  WLR_ID,
					   wlr.PREF                 WLR74_PREF,
					   wlr.NUMB                 WLR74_NUMB,
					   wlr.STATUS               WLR74_STATUS,
					   D_PKG_DAT_TOOLS.DATE_TO_CHAR(wlr.REG_DATE, 'dd.mm.yyyy hh24:mi:ss')
					                            WLR74_REG_DATE,
					   (case when sysdate > (wlr.REG_DATE + numToDSInterval(:MinCallPeriod74, 'second' ))
					         then 1
					         else 0
					         end)               WLR74_MINCALL
		             @}
		               ,D_PKG_SIGNAL_INFO_SETS.GET_FULL_SIGNAL_INFORMATION(fnLPU => :LPU, fnSI_PLACE => '3', fnPATIENT => t.PATIENT_ID)
		                                        SI_ICON
		          from D_V_DIR_SERV_FOR_DIARY t
		             @if(:USE_QUEUE74 > 0){
		               @if(:HPWT74 == 1){
					     join D_V_WL_RECORDS74 wlr on t.ID = wlr.DIR_SERV_ID
					   @}else{
					     left join D_V_WL_RECORDS74 wlr on t.ID = wlr.DIR_SERV_ID
					   @}
		             @}
		         where trunc(t.REC_DATE) = to_date(:SYS_DATE, 'dd.mm.yyyy')
		           and t.LPU = :LPU
		           and (D_PKG_OPTIONS.GET('ShowLostRecords',:LPU) in (0,1)
                       or D_PKG_OPTIONS.GET('ShowLostRecords',:LPU) = 2 and d_pkg_clschs.get_info(:LPU,
                       																		      case
																									when t.REC_TYPE in (0,2,4) then 0
																									when t.REC_TYPE in (1,3,5) then 1
																								  end,
                       																		      t.REC_DATE,
                       																		      t.CABLAB_TO,
                       																		      t.EMPLOYER_TO,
                       																		      t.SERVICE_ID,
                       																		      t.DIRECTION_REG_TYPE,
                       																		      case t.REG_TYPE
                                                													when 0 then 1 else 0 end) is not null)
                @if(:fPATIENT_ID){
                   and t.PATIENT_ID = :fPATIENT_ID
                @}
                @if(:fGENETIC_PEDIGREE_ID){
                   and t.PATIENT_ID in (
                                 select t.PERSMEDCARD
                                   from D_V_GENETIC_PEDIGREE_SP t
                                  where t.PID = :fGENETIC_PEDIGREE_ID
                                    and t.LPU = :LPU
                                    and t.PERSMEDCARD is not null)
                @}
                @if (:FI_FIO_PATIENT){
                    and (upper(t.PATIENT_FIO) like upper(:FI_FIO_PATIENT||'%'))
                @}
                @if(:FI_SE_CODE!=null){
                    and (';'||:FI_SE_CODE||';' like '%;'||t.SERVICE_ID||';%')
                @}
                @if(:FI_SERV_STATUS!=null){
                    and (t.SERV_STATUS=:FI_SERV_STATUS)
                @}
                @if(:PAYMENT_KIND!=null){
					and instr(';'||:PAYMENT_KIND||';', ';'||t.PAYMENT_KIND||';') > 0
                @}
                @if(:TEST_PAR == 1){
                    and t.EMPLOYER_TO=:EMPLOYER
                @}else if (:TEST_PAR == 2){
                    and t.CABLAB_TO=:CABLAB
                   @if(:EMPCAB){
                    and :EMPCAB = t.EMPLOYER_TO
                   @}
                @}else if (!:TEST_PAR){
                   @if(:EMPCAB){
                      @if(:CLCL){
                     and  t.CABLAB_TO = :CLCL and t.EMPLOYER_TO=:EMPLOYER
                      @}else{
                     and (
                            (t.EMPLOYER_TO = :EMPCAB and t.CABLAB_TO=:CABLAB )
                                  or((t.CABLAB_TO is null) and (t.EMPLOYER_TO=:EMPCAB))
                         )
                      @}
                    @}else{
                      @if(:CLCL){
                     and (t.CABLAB_TO = :CLCL and (t.EMPLOYER_TO = :EMPLOYER or t.EMPLOYER_TO is null))
                      @}else{
                     and ((t.CABLAB_TO = :CABLAB and (t.EMPLOYER_TO = :EMPLOYER or t.EMPLOYER_TO is null))
                            or ((t.CABLAB_TO is null) and (t.EMPLOYER_TO = :EMPLOYER))
                            or exists (select null
										 from D_V_CABLAB_BASE t1
										where t1.PID = :CABLAB
										  and t1.ID = t.CABLAB_TO))
                       @}
                    @}
                @}

			]]>
			<component cmptype="Variable" name="EMPCAB"               src="EMPL_CAB"             srctype="ctrl"    get="EMPCAB"/>
			<component cmptype="Variable" name="TEST_PAR"             src="VIEW_T"               srctype="ctrl"    get="TEST_PAR"/>
			<component cmptype="Variable" name="CLCL"                 src="CABLABS"              srctype="ctrl"    get="CLCL"/>
			<component cmptype="Variable" name="SYS_DATE"             src="SYS_DATE"             srctype="var"     get="SYS_DATE"/>
			<component cmptype="Variable" name="FI_FIO_PATIENT"       src="FI_FIO_PATIENT"       srctype="ctrl"    get="FI_FIO_PATIENT"/>
			<component cmptype="Variable" name="FI_SE_CODE"           src="FI_SE_CODE"           srctype="ctrl"    get="FI_SE_CODE"/>
			<component cmptype="Variable" name="FI_SERV_STATUS"       src="FI_SERV_STATUS"       srctype="ctrl"    get="FI_SERV_STATUS"/>
			<component cmptype="Variable" name="PAYMENT_KIND"         src="PAYMENT_KIND"         srctype="ctrl"    get="PAYMENT_KIND"/>
			<component cmptype="Variable" name="LPU"                  src="LPU"                  srctype="session" get="LPU"/>
			<component cmptype="Variable" name="EMPLOYER"             src="EMPLOYER"             srctype="session" get="EMPLOYER"/>
			<component cmptype="Variable" name="CABLAB"               src="CABLAB"               srctype="session" get="CABLAB"/>
			<component cmptype="Variable" type="count"                src="dscount"              srctype="var"     default="20"/>
			<component cmptype="Variable" type="start"                src="dsstart"              srctype="var"     default="1"/>
			<component cmptype="Variable" name="PK_OMS"               src="PAYM_KIND_OMS_OPT"    srctype="var"     get="PK_ID"/>
			<component cmptype="Variable" name="SHOW_BUTTON"          src="SHOW_BUTTON"          srctype="var"     get="SHOW_BUTTON"/>
			<component cmptype="Variable" name="fPATIENT_ID"          src="fPATIENT_ID"          srctype="ctrl"     get="fPATIENT_ID"/>

			<component cmptype="Variable" name="fGENETIC_PEDIGREE_ID" src="fGENETIC_PEDIGREE_ID" srctype="var"     get="fGENETIC_PEDIGREE_ID"/>
			<component cmptype="Variable" name="SHOW_FLG"             src="SHOW_FLG"             srctype="var"     get="gSHOW_FLG"/>
			<component cmptype="Variable" name="CHECKPREGNANCY"       src="CHECKPREGNANCY"       srctype="var"     get="pCH_P" />
			<component cmptype="Variable" name="IS_RISAR"             src="IS_RISAR"             srctype="var"     get="pIS_RISAR" />
			<component cmptype="Variable" name="SHOW_COLOR"           src="SHOW_COLOR"           srctype="var"     get="pSHOW_COLOR" />
			<component cmptype="Variable" name="SHOWLOSTRECORDS"      src="SHOWLOSTRECORDS"      srctype="var"     get="pSHOWLOSTRECORDS" />
			<component cmptype="Variable" name="REC_LOST"      		  src="REC_LOST"      		 srctype="var"     get="pREC_LOST" />
			<component cmptype="Variable" name="USE_QUEUE74"          src="0"                    srctype="const"   get="pUSE_QUEUE74" />
			<component cmptype="Variable" name="HPWT74"               src="0"                    srctype="const"   get="pHPWT74" />
			<component cmptype="Variable" name="MinCallPeriod74"      src="0"                    srctype="const"   get="pMinCallPeriod74" />
			<component cmptype="Variable" name="SHOWHOSP"             src="SHOWHOSP"             srctype="var"     get="SHOWHOSP"/>
			<component cmptype="Variable" name="QUEUING"              src="QUEUING"           	 srctype="var"     get="QUEUING"/>
		</component>
		<component cmptype="DataSet" name="DS_EMPL_CAB">
			select t.ID,
				   t.FIO FULLNAME
			  from d_v_employers t,
				   d_v_emp_cablabs t1
			 where t.ID = t1.PID
			   and t1.CABLAB_ID = :CABLAB
			<component cmptype="Variable" name="CABLAB" src="CABLAB" srctype="session"/>
		</component>
		<component cmptype="DataSet" name="DS_VIEW_T">
			(select 1 as PARAM,
					'По врачу' as CAPT
			  from dual)
		  union all
			(select 2 as PARAM,
					'По кабинету' as CAPT
			   from table(cast(D_PKG_CSE_ACCESSES.GET_ID_WITH_RIGHTS(:PNLPU,'CABLAB','3') AS d_c_id )) t1
			  where t1.COLUMN_VALUE = :CABLAB)
			<component cmptype="Variable" name="CABLAB" src="CABLAB" srctype="session"/>
			<component cmptype="Variable" name="PNLPU"  src="LPU"    srctype="session"/>
		</component>
		<component cmptype="DataSet" name="DS_CABLABS">
			<![CDATA[
				select c.ID as ID,
					   c.CL_NAME as CL_NAME
				  from D_V_CABLAB_BASE c
				 where c.PID = :CABLAB
				order by c.CL_NAME
			]]>
	  		<component cmptype="Variable" name="CABLAB" src="CABLAB" srctype="session"/>
		</component>

		<component cmptype="Action" name="getSYS_DATE">
			<![CDATA[
				declare nDaysToElapseCito number;
						bIbQueueModePrivs boolean;
						bIbCabsgroupCabsPrivs boolean;
				begin
					select to_char(sysdate,'dd.mm.yyyy'),
						   to_char(sysdate,'dd')||' '||
							D_PKG_STR_TOOLS.GET_ON_CASE(to_char(sysdate, 'Month', 'NLS_DATE_LANGUAGE=RUSSIAN'), 'р', 1)||' '||
							to_char(sysdate,'yyyy'),
							D_PKG_OPTIONS.GET('ShowHOSP', :LPU)
					  into :SYS_DATE,
						   :SYS_DATE_LABLE,
							:SHOWHOSP
					  from dual;
					begin
						select t.ID
						  into :PAYM_KIND_OMS_OPT
						  from d_v_payment_kind t
						 where t.VERSION = d_pkg_versions.get_version_by_lpu(1, :LPU, 'PAYMENT_KIND')
						   and t.PK_CODE = d_pkg_option_specs.get('PKOMS', :LPU);
				exception when no_data_found then :PAYM_KIND_OMS_OPT := null;
					end;
					:OPT_AVAIL_MAKE_VIS := d_pkg_option_specs.get('VisCheckOMS', :LPU);
					:CHECK_PAYMENTS := d_pkg_option_specs.get('DSCheckPayments', :LPU);
					:MassPost := d_pkg_option_specs.get('MassPost', :LPU);
					begin
						select count(1)
						  into :SHOW_EMERG_BUTTON
						  from d_v_emp_services t
						 where t.SERVICE_CODE = d_pkg_option_specs.get('EmergencyService', :LPU)
						   and t.PID = :EMPLOYER;
					end;
					begin
						select count(1)
						  into :SHOW_BUTTON
						  from D_V_IB_CABGROUP_CABS
						 where CABLAB_ID = :CABLAB;
						IF :SHOW_BUTTON > 1 THEN
							:SHOW_BUTTON := 1;
						END IF;
					end;
					begin
						:HELP_SERVICE_CODE := D_PKG_CONSTANTS.SEARCH_STR(psCONST_CODE => 'ServVipiska', pnLPU => :LPU);
					end;
					nDaysToElapseCito := d_pkg_option_specs.GET('DaysToElapseCito', :LPU);
					:CHECKPREGNANCY:=null;
					:CHECKPREGNANCY := d_pkg_option_specs.GET('CheсkPeriodPregnancy', :LPU);
					if nDaysToElapseCito > 0 then
					  :SYS_DATE_FIX := to_char(sysdate - nDaysToElapseCito, 'dd.mm.yyyy');
					else
					  :SYS_DATE_FIX := to_char(sysdate, 'dd.mm.yyyy');
					end if;
					:DSInputCancelReasons := D_PKG_OPTIONS.GET('DSInputCancelReasons', :LPU);
					:SHOW_FLG := d_pkg_option_specs.get('ActualFLG', :LPU);
					:IS_RISAR := d_pkg_option_specs.get('IncludeRisar', :LPU);
					:SHOW_COLOR := d_pkg_option_specs.get('ShowColor_PaymentKind', :LPU);
					:SHOWLOSTRECORDS := D_PKG_OPTIONS.GET('ShowLostRecords',:LPU);
					:CheckTAP := D_PKG_OPTIONS.GET('CheckTapWhenVisitSetClose',:LPU);

					begin
						select t.QUEUING,
							   t.INVITING
						  into :QUEUING,
							   :INVITING
						  from D_V_IB_QUEUE_MODE t
						 where t.LPU = :LPU;
					exception when NO_DATA_FOUND then null;
					end;

					begin
						bIbQueueModePrivs := d_pkg_urprivs.check_bppriv(pnlpu => :LPU,
																	pnversion => null,
																	psunitcode => 'IB_QUEUE_MODE',
																	pncatalog => null,
																	psunitbp => null,
																	pnraise => 0);
						bIbCabsgroupCabsPrivs := d_pkg_urprivs.check_bppriv(pnlpu => :LPU,
																	pnversion => null,
																	psunitcode => 'IB_CABGROUP_CABS',
																	pncatalog => null,
																	psunitbp => null,
																	pnraise => 0);

						if (bIbQueueModePrivs = false OR bIbCabsgroupCabsPrivs = false) then
							:SHOW_NEXT_BTN := 0;
						else
			            	select
								case when (select count(*) from D_V_IB_CABGROUP_CABS where CABLAB_ID = :CABLAB) > 0 then 1 else 0 end
							into :SHOW_NEXT_BTN
							from dual;
						end if;


					end;
				end;
			]]>
			<component cmptype="ActionVar" name="LPU"                  src="LPU"                     srctype="session"/>
			<component cmptype="ActionVar" name="EMPLOYER"             src="EMPLOYER"                srctype="session"/>
			<component cmptype="ActionVar" name="CABLAB"               src="CABLAB"                  srctype="session"/>
			<component cmptype="ActionVar" name="SYS_DATE"             src="GoDateEdit"              srctype="ctrl"        put="var1"           	len="50"/>
			<component cmptype="ActionVar" name="SYS_DATE"             src="SYS_DATE"                srctype="var"         put="var2"           	len="50"/>
			<component cmptype="ActionVar" name="SYS_DATE_FIX"         src="SYS_DATE_FIX"            srctype="var"         put="var4"           	len="50"/>
			<component cmptype="ActionVar" name="SYS_DATE_LABLE"       src="SYS_DATE_LABLE"          srctype="ctrlcaption" put="var3"           	len="50"/>
			<component cmptype="ActionVar" name="PAYM_KIND_OMS_OPT"    src="PAYM_KIND_OMS_OPT"       srctype="var"         put="PK_ID"          	len="17"/>
			<component cmptype="ActionVar" name="OPT_AVAIL_MAKE_VIS"   src="OPT_AVAIL_MAKE_VIS"      srctype="var"         put="OAMV"           	len="2"/>
			<component cmptype="ActionVar" name="CHECK_PAYMENTS"       src="CHECK_PAYMENTS"          srctype="var"         put="CHECK_PAYMENTS" 	len="2"/>
			<component cmptype="ActionVar" name="SHOW_EMERG_BUTTON"    src="SHOW_EMERG_BUTTON"       srctype="var"         put="SEB"            	len="5"/>
			<component cmptype="ActionVar" name="SHOW_BUTTON"          src="SHOW_BUTTON"             srctype="var"         put="S_B"            	len="2"/>
			<component cmptype="ActionVar" name="HELP_SERVICE_CODE"    src="HELP_SERVICE_CODE"       srctype="var"         put="help_serv_code" 	len="500"/>
			<component cmptype="ActionVar" name="DSInputCancelReasons" src="DSInputCancelReasons"    srctype="var"         put="var5"           	len="2"/>
			<component cmptype="ActionVar" name="SHOW_FLG"             src="SHOW_FLG"                srctype="var"         put="pSHOW_FLG"      	len="1"/>
			<component cmptype="ActionVar" name="CHECKPREGNANCY"       src="CHECKPREGNANCY"          srctype="var"         put="pCH_P"          	len="3"/>
			<component cmptype="ActionVar" name="MassPost"             src="MassPost"                srctype="var"         put="pMassPost"      	len="1"/>
			<component cmptype="ActionVar" name="IS_RISAR"             src="IS_RISAR"                srctype="var"         put="pIS_RISAR"      	len="1"/>
			<component cmptype="ActionVar" name="SHOW_COLOR"           src="SHOW_COLOR"              srctype="var"         put="pSHOW_COLOR"    	len="4000"/>
			<component cmptype="ActionVar" name="SHOWLOSTRECORDS"      src="SHOWLOSTRECORDS"         srctype="var"         put="pSHOWLOSTRECORDS"  	len="1"/>
			<component cmptype="ActionVar" name="SHOWHOSP"             src="SHOWHOSP"                srctype="var"         put="pSHOWHOSP"          len="1"/>
			<component cmptype="ActionVar" name="QUEUING"              src="QUEUING"           		 srctype="var"         put="pQUEUING"  			len="1"/>
			<component cmptype="ActionVar" name="INVITING"             src="INVITING"          		 srctype="var"         put="pINVITING" 			len="1"/>
			<component cmptype="ActionVar" name="SHOW_NEXT_BTN"        src="SHOW_NEXT_BTN"     		 srctype="var"         put="pSHOW_NEXT_BTN" 	len="1"/>
			<component cmptype="ActionVar" name="CheckTAP"             src="CheckTAP"     		     srctype="var"         put="pCheckTAP" 	        len="1"/>
		</component>
		<component cmptype="Action" name="getEmpServiceAvailability">
			<![CDATA[
			declare PK_ID NUMBER(17);
				    COUNT_DIR NUMBER(3);
				    COUNT_ALL NUMBER(3);
				    AVAIL_OPT NUMBER(3);
			begin
				select count(1)
				  into :IN_EMP_SERVS
				  from d_v_emp_services t
				 where t.SERVICE_ID = :SERVICE_ID
				   and t.PID =  d_pkg_employers.GET_ID(:LPU);
				begin
					:AVAIL_BY_FIN_SOURCE := 0;
					PK_ID := d_pkg_direction_services.get_payment_kind(:LPU, :DIRECTION_SERVICE_ID, 1, 0);
					AVAIL_OPT := d_pkg_option_specs.get('DSPCheckServPays', :LPU);

					IF PK_ID is not null AND AVAIL_OPT = 1 THEN
						select count(1)
						  into COUNT_DIR
						  from d_v_services_pays sp
						 where sp.PID = :SERVICE_ID
						   and sp.PAYMENT_KIND_ID = PK_ID
						   and sp.VERSION = d_pkg_versions.get_version_by_lpu(1,:LPU,'SERVICES_PAYS');
						select count(1)
						  into COUNT_ALL
						  from d_v_services_pays sp
						 where sp.PID = :SERVICE_ID
						   and sp.VERSION = d_pkg_versions.get_version_by_lpu(1,:LPU,'SERVICES_PAYS');
						IF COUNT_ALL = 0 OR COUNT_DIR > 0 THEN
							:AVAIL_BY_FIN_SOURCE := 1;
						ELSE
							:AVAIL_BY_FIN_SOURCE := 0;
						END IF;
					ELSE
						:AVAIL_BY_FIN_SOURCE := 1;
					END IF;
				end;
				begin
					select t.REG_TYPE
			          into :REG_TYPE_FOR_CHECK
					  from d_v_directions t,
						   d_v_direction_services t1
					 where t1.ID = :DIRECTION_SERVICE_ID
					   and t1.PID = t.ID;
			exception when no_data_found then
					:REG_TYPE_FOR_CHECK := 0;
				end;
				:TEMPLATE_ID := d_pkg_visits.get_template_info(fnLPU => :LPU,
							                                    fnID => :DIRECTION_SERVICE_ID,
							                              fsUNITCODE => 'DIRECTION_SERVICES',
							                                  fnWHAT => 0);
			end;
			]]>
			<component cmptype="ActionVar" name="SERVICE_ID"           src="SERVICE_ID"          srctype="var"  get="v1"/>
			<component cmptype="ActionVar" name="LPU"                  src="LPU"                 srctype="session"/>
			<component cmptype="ActionVar" name="IN_EMP_SERVS"         src="AVAIL_EMP_SERVICES"  srctype="var"  put="v2"   len="5"/>
			<component cmptype="ActionVar" name="DIRECTION_SERVICE_ID" src="Grid"                srctype="ctrl" get="DS_ID" />
			<component cmptype="ActionVar" name="AVAIL_BY_FIN_SOURCE"  src="AvailVisitByFS"      srctype="var"  put="AVF"  len="1"/>
			<component cmptype="ActionVar" name="REG_TYPE_FOR_CHECK"   src="REG_TYPE_FOR_CHECK"  srctype="var"  put="RTFC" len="2"/>
			<component cmptype="ActionVar" name="TEMPLATE_ID"          src="TEMPLATE_ID"         srctype="var"  put="v0"   len="17"/>
		</component>
		<component cmptype="Action" name="getSYS_DATE_LAST_NEXT">
			begin
				select to_char(to_date(:SYS_DATE)+:DATE_NUM,'dd')||' '||
						D_PKG_STR_TOOLS.GET_ON_CASE(to_char(to_date(:SYS_DATE)+:DATE_NUM, 'Month', 'NLS_DATE_LANGUAGE=RUSSIAN'), 'р', 1)||' '||
						to_char(to_date(:SYS_DATE)+:DATE_NUM,'yyyy'),
					   to_char(to_date(:SYS_DATE)+:DATE_NUM,'dd.mm.yyyy')
				  into :SYS_DATE_LABLE,
					   :SYS_DATE
				  from  dual;
			end;
			<component cmptype="ActionVar" name="SYS_DATE"       src="SYS_DATE"       srctype="var"         get="SYS_DATE1"/>
			<component cmptype="ActionVar" name="SYS_DATE"       src="SYS_DATE"       srctype="var"         put="SYS_DATE2"  len="50"/>
			<component cmptype="ActionVar" name="SYS_DATE"       src="GoDateEdit"     srctype="ctrl"        put="GoDateEdit" len="11"/>
			<component cmptype="ActionVar" name="DATE_NUM"       src="DATE_NUM"       srctype="var"         get="var2"/>
			<component cmptype="ActionVar" name="SYS_DATE_LABLE" src="SYS_DATE_LABLE" srctype="ctrlcaption" put="var3"       len="50"/>
		</component>
		<component cmptype="Action" name="cancelDirectionServices">
			<![CDATA[
			begin
				d_pkg_direction_services.set_status(pnID => :DIR_SERV,
								                   pnLPU => :LPU,
								           pnSERV_STATUS => 2);
			end;
			]]>
			<component cmptype="ActionVar" name="LPU"      src="LPU"  srctype="session"/>
			<component cmptype="ActionVar" name="DIR_SERV" src="Grid" srctype="ctrl"  get="v1"/>
		</component>

		<component cmptype="Action" name="getTO_DATE_LAST_NEXT">
			<![CDATA[
			begin
				:TO_DATE := d_pkg_direction_services.get_day_with_records(pnlpu => :LPU,
																       pncablab => :CABLAB,
																 pdcurrent_date => :SYS_DATE,
																    pndirection => :DATE_NUM);
				if 	:TO_DATE is null then
					:TO_DATE :=:SYS_DATE;
				end if;
				:TO_DATE_LABLE := to_char(to_date(:TO_DATE),'dd')||' '||
						D_PKG_STR_TOOLS.GET_ON_CASE(to_char(to_date(:TO_DATE), 'Month', 'NLS_DATE_LANGUAGE=RUSSIAN'), 'р', 1)||' '||
						to_char(to_date(:TO_DATE),'yyyy');
			end;
			]]>
			<component cmptype="ActionVar" name="LPU"           src="LPU"            srctype="session"/>
			<component cmptype="ActionVar" name="CABLAB"        src="CABLAB"         srctype="session"/>
			<component cmptype="ActionVar" name="DATE_NUM"      src="DATE_NUM"       srctype="var"         get="var2"/>
			<component cmptype="ActionVar" name="SYS_DATE"      src="SYS_DATE"       srctype="var"         get="SYS_DATE1"/>
			<component cmptype="ActionVar" name="TO_DATE"       src="SYS_DATE"       srctype="var"         put="SYS_DATE2"  len="50"/>
			<component cmptype="ActionVar" name="TO_DATE_LABLE" src="SYS_DATE_LABLE" srctype="ctrlcaption" put="var3"       len="50"/>
			<component cmptype="ActionVar" name="TO_DATE"       src="GoDateEdit"     srctype="ctrl"        put="GoDateEdit" len="11"/>
		</component>

		<component cmptype="Action" name="getEmpCab">
			<![CDATA[
				begin
					select D_PKG_EMPLOYERS.GET_ID(:LPU),
						   :CABLAB,
						   t.CL_NAME,
						   :LPU
					  into :EMP_ID,
						   :CAB_ID,
						   :CAB_NAME,
						   :LPU_ID
					  from d_v_cablab t where t.ID = :CABLAB;
			exception when no_data_found then
						  D_P_EXC('Не выбран кабинет.');
				end;
			]]>
			<component cmptype="ActionVar" name="EMP_ID"   src="EMP_ID"           srctype="var" put="EMP_ID"           len="17"/>
			<component cmptype="ActionVar" name="EMP_ID"   src="NEW_EMP_ID"       srctype="var" put="NEW_EMP_ID"       len="17"/>
			<component cmptype="ActionVar" name="CAB_ID"   src="CAB_ID"           srctype="var" put="CAB_ID"          len="17"/>
			<component cmptype="ActionVar" name="COUNT"    src="SYS_COUNT_ADMINS" srctype="var" put="SYS_COUNT_ADMINS" len="10"/>
			<component cmptype="ActionVar" name="LPU"      src="LPU"              srctype="session"/>
			<component cmptype="ActionVar" name="CABLAB"   src="CABLAB"           srctype="session"/>
			<component cmptype="ActionVar" name="CAB_NAME" src="CAB_NAME"         srctype="var" put="C_N"              len="160"/>
			<component cmptype="ActionVar" name="LPU_ID"   src="LPU_ID"           srctype="var" put="LPU_ID"           len="17"/>
			<component cmptype="ActionVar" name="EMPLOYER" src="EMPLOYER"         srctype="session"/>
		</component>

        <component cmptype="Action" name="GET_NURSE_DEFAULT">
            <![CDATA[
				begin
                    select
                          ec.ID,
                          ec.NURSE_DEFAULT_ID,
                          ec.NURSE_DEFAULT_FIO,
                          case when  ec.NURSE_DEFAULT_ID is not null
                              then '1'
                            else '0'
                          end NURSE_DEFAULT
                    into :EMP_CABLABS_ID,
                         :DEF_NURSE,
                         :DEF_NURSE_CAPTION,
                         :NURSE_DEFAULT
                    from D_V_EMP_CABLABS ec
                    where ec.CABLAB_ID = :CABLAB and ec.PID = D_PKG_EMPLOYERS.GET_ID(:LPU);
			        exception when no_data_found then
						  :DEF_NURSE := null;
						  :DEF_NURSE_CAPTION := null;
						  :NURSE_DEFAULT := '0';
				end;
			]]>
            <component cmptype="ActionVar" name="CABLAB"   src="CABLAB"           srctype="session"/>
            <component cmptype="ActionVar" name="LPU"      src="LPU"              srctype="session"/>

            <component cmptype="ActionVar" name="EMP_CABLABS_ID"        src="EMP_CABLABS_ID"     srctype="var"        put="EMP_CABLABS_ID"                     len="17"/>
            <component cmptype="ActionVar" name="DEF_NURSE"             src="DEF_NURSE"     srctype="ctrl"          put="DEF_NURSE"                     len="17"/>
            <component cmptype="ActionVar" name="DEF_NURSE"             src="DEF_NURSE_ID"     srctype="var"        put="DEF_NURSE_ID"                     len="17"/>
            <component cmptype="ActionVar" name="DEF_NURSE_CAPTION"     src="DEF_NURSE"     srctype="ctrlcaption"  put="DEF_NURSE_CAPTION"           len="200"/>

            <component cmptype="ActionVar" name="NURSE_DEFAULT"         src="NURSE_DEFAULT_CHECK"     srctype="ctrl"          put="NURSE_DEFAULT"     len="1"/>
        </component>

        <component cmptype="Action" name="ACT_CHECK_CLEMPS">
			<![CDATA[
				begin
					select case when exists (select null
											   from D_V_CLEMPS cl
											  where cl.PID = :CABLAB
												and cl.LPU = :LPU
												and cl.EMPLOYER_ID = :EMPLOYER
												and cl.WORK_FROM <= trunc(coalesce(to_date(:TO_DATE, D_PKG_STD.FRM_D), sysdate))
												and (cl.WORK_TO is null or cl.WORK_TO >= trunc(coalesce(to_date(:TO_DATE, D_PKG_STD.FRM_D), sysdate)))
											 )
										 or not exists (select null
														  from D_V_CLEMPS cl
														 where cl.PID = :CABLAB
														   and cl.LPU = :LPU
														   and cl.EMPLOYER_ID = :EMPLOYER)
											then 1
						   end
					  into :IS_WORKING_HERE
					  from dual;
			exception when OTHERS then
							:IS_WORKING_HERE := null;
				end;
            ]]>
            <component cmptype="ActionVar" name="LPU"             src="LPU"             srctype="session"/>
            <component cmptype="ActionVar" name="CABLAB"          src="CABLAB"          srctype="session"/>
            <component cmptype="ActionVar" name="EMPLOYER"        src="EMPLOYER"        srctype="session"/>
            <component cmptype="ActionVar" name="TO_DATE"         src="GoDateEdit"      srctype="ctrl" get="GoDateEdit"/>
            <component cmptype="ActionVar" name="IS_WORKING_HERE" src="IS_WORKING_HERE" srctype="ctrl" put="IS_WORKING_HERE" len="1"/>
		</component>

		<component cmptype="Action" name="getVisit">
			begin
				begin
					select t.MKB_ID,
						   t.MKB_CODE
					  into :MKB_ID,
			               :MKB_CODE
					  from d_v_vis_diagnosises_main t
					 where t.PID = :VISIT;
			exception when no_data_found then
						:MKB_ID := null;
						:MKB_CODE := null;
				end;
			end;
			<component cmptype="ActionVar" name="VISIT"     src="VISIT" 	srctype="var" get="v1"/>
			<component cmptype="ActionVar" name="MKB_ID" 	src="MKB_ID"  	srctype="var" put="v2" len="17"/>
			<component cmptype="ActionVar" name="MKB_CODE" 	src="MKB_CODE" 	srctype="var" put="v3" len="10"/>
		</component>
		<component cmptype="Action" name="getVisitForHosp">
			begin
				select t.ID,
					   vd.MKB_ID,
					   vd.INJURE_KIND_ID,
					   vd.EX_CAUSE_MKB_ID,
					   vd.INJURETIME,
					   vd.NOTE
				  into :VISIT,
					   :MKBS,
					   :INJURE_KIND,
					   :EX_CAUSE_MKB,
					   :INJURETIME,
					   :MKBS_NOTE
			  	  from d_v_visits t,
				       d_v_vis_diagnosises vd
				 where t.LPU = :pnlpu
				   and t.PID = :ID_DIR_SERV
				   and t.ID = vd.PID(+)
				   and vd.IS_MAIN(+) = 0;
			end;
			<component cmptype="ActionVar" name="PNLPU" 	   src="LPU"           srctype="session"/>
			<component cmptype="ActionVar" name="ID_DIR_SERV"  src="Grid"          srctype="ctrl" get="v1"/>
			<component cmptype="ActionVar" name="VISIT"        src="VISIT"         srctype="var"  put="v2" len="17"/>
			<component cmptype="ActionVar" name="MKBS"         src="MKBS"          srctype="var"  put="v3" len="17"/>
			<component cmptype="ActionVar" name="INJURE_KIND"  src="INJURE_KIND"   srctype="var"  put="v4" len="17"/>
			<component cmptype="ActionVar" name="EX_CAUSE_MKB" src="EX_CAUSE_MKB"  srctype="var"  put="v5" len="17"/>
			<component cmptype="ActionVar" name="INJURETIME"   src="INJURETIME"    srctype="var"  put="v6" len="3"/>
			<component cmptype="ActionVar" name="MKBS_NOTE"    src="MKBS_NOTE"     srctype="var"  put="v7" len="4000"/>
		</component>
		<component cmptype="Action" name="cancelVisit">
			<![CDATA[
			begin
				  d_pkg_visits.del(pnid => :pnid,
							      pnlpu => :pnLPU,
						   pnuse_checks => 1);
				  :CC_MESSAGE := d_pkg_visits.sgCC_MESSAGE;
			end;
			]]>
			<component cmptype="ActionVar" name="pnLPU"        src="LPU"          srctype="session"/>
			<component cmptype="ActionVar" name="pnid"         src="SYS_VISIT_ID" srctype="var" get="v1"/>
			<component cmptype="ActionVar" name="CC_MESSAGE"   src="CC_MESSAGE"   srctype="var" put="v2"  len="4000" />
		</component>

		<component cmptype="Action" name="SEL_DIR_SERV">
			<![CDATA[
				begin
					:IS_AUTO_TEMPL := d_pkg_visits.get_template_info(fnlpu => :pnLPU,
																	  fnID => :IDD,
																fsUNITCODE => 'DIRECTION_SERVICES',
																	fnWHAT => 3);
				end;
			]]>
			<component cmptype="ActionVar" name="pnLPU"         src="LPU"           srctype="session"/>
			<component cmptype="ActionVar" name="IDD"           src="Grid"          srctype="ctrl" get="var3"/>
			<component cmptype="ActionVar" name="IS_AUTO_TEMPL" src="IS_AUTO_TEMPL" srctype="var"  put="var4"/>
		</component>
		<component cmptype="Action" name="CheckRightsForServices" mode="post">
			<![CDATA[
				begin
				  :R_EDIT_OWN := D_PKG_CSE_ACCESSES.CHECK_RIGHT(:pnLPU,'SERVICES',:SERV_ID,'6',:pnCABLAB);
                  :R_EDIT_ANY := D_PKG_CSE_ACCESSES.CHECK_RIGHT(:pnLPU,'SERVICES',:SERV_ID,'7',:pnCABLAB);

				  :THIS_EMPLOYER_ID := d_pkg_employers.GET_ID(:pnLPU);

				  :RIGHT := 0;
				  if :THIS_EMPLOYER_ID = :REG_EMPLOYER_ID then
					if :R_EDIT_OWN > 0 then
					  :RIGHT := 1;
					else
					  D_P_EXC('Нет прав на редактирование результата для данной услуги!');
					end if;
				  else
					if  :R_EDIT_ANY > 0 then
					  :RIGHT := 1;
					else
					 D_P_EXC('Нет прав на редактирование результата для данной услуги!');
					end if;
				  end if;

				  if :RIGHT = 1 then
				  :IS_AUTO_TEMPL := d_pkg_visits.get_template_info(fnLPU => :pnLPU,
								fnID => :SYS_DIR_SERVICE,
								fsUNITCODE => 'DIRECTION_SERVICES',
								fnWHAT => 3);
				  end if;
				:TEMPLATE_ID := d_pkg_visits.get_template_info(fnLPU => :pnLPU,
								fnID => :SYS_DIR_SERVICE,
								fsUNITCODE => 'DIRECTION_SERVICES',
								fnWHAT => 0);
				begin
					select case
							 when d_pkg_options.GET('OpenClosedDiseasecase', :pnLPU) = 1 and
								  DC.IS_CLOSE = 1 then
							  1
							 else
							  0
						   end
					  into :IS_CLOSE
					  from D_V_DIRECTION_SERVICES_BASE DS
						   join D_V_DISEASECASES_BASE DC on DS.DISEASECASE = DC.ID
					 where DS.ID = :SYS_DIR_SERVICE;
				exception when no_data_found then
					:IS_CLOSE := 0;
				end;
				end;
			]]>
			<component cmptype="ActionVar" name="pnLPU"            src="LPU"               srctype="session"/>
			<component cmptype="ActionVar" name="pnCABLAB"         src="CABLAB"            srctype="session"/>
			<component cmptype="ActionVar" name="SERV_ID"          src="SERVICE_ID_FOR"    srctype="var"   get="g0"/>
			<component cmptype="ActionVar" name="REG_EMPLOYER_ID"  src="REG_EMPLOYER_ID"   srctype="var"   get="g1"/>
			<component cmptype="ActionVar" name="DIRDATE"          src="DIRDATE"           srctype="var"   get="g2"/>
			<component cmptype="ActionVar" name="R_EDIT_OWN"       src="R_EDIT_OWN"        srctype="var"   put="p2"       len="3"/>
			<component cmptype="ActionVar" name="R_EDIT_ANY"       src="R_EDIT_ANY"	       srctype="var"   put="p3"       len="3"/>
			<component cmptype="ActionVar" name="THIS_EMPLOYER_ID" src="THIS_EMPLOYER_ID"  srctype="var"   put="p4"       len="17"/>
			<component cmptype="ActionVar" name="RIGHT"            src="RIGHT"             srctype="var"   put="p5"       len="1"/>
			<component cmptype="ActionVar" name="SYS_DIR_SERVICE"  src="SYS_DIR_SERVICE"   srctype="var"   get="g3"/>
			<component cmptype="ActionVar" name="IS_AUTO_TEMPL"    src="IS_AUTO_TEMPL"     srctype="var"   put="p8"/>
			<component cmptype="ActionVar" name="TEMPLATE_ID"      src="TEMPLATE_ID"       srctype="var"   put="v0"       len="17"/>
			<component cmptype="ActionVar" name="IS_CLOSE"         src="IS_CLOSE_VAR"      srctype="var"   put="IS_CLOSE" len="1"/>
		</component>
        <component cmptype="Script" name="onCreate">
        	Form.onCreate=function(){
				executeAction('getEmpCab', function () {
                    executeAction('GET_NURSE_DEFAULT');
                });
			}
        </component>
		<component cmptype="Script">
		<![CDATA[
			Form.onShow = function () {
			_setFocus(getControlByName('fPATIENT_ID'));
				executeAction("getSYS_DATE", function () {

					setDomVisible(getControlByName('TR_NEXT_PATIENT'),  getVar('SHOW_NEXT_BTN') == 1 && getVar('INVITING') == 1);
					setDomVisible(getControlByName('INVITE_STATUS'), getVar('INVITING') == 1);
					setDomVisible(getControlByName('nButton'), getVar('INVITING') != 1);

					refreshDataSet('DS_USUAL');
					/*if(getVar('SHOW_EMERG_BUTTON') != 1)
					 getControlByName('EMERG_BUTTON').style.display = 'none';*/

					getControlByName('ButtonMassWrite').style.display = (getVar('MassPost') == 1) ? '' : 'none';
				}, null);
			}
			Form.SHOWHIST = function () {
				setVar('LOC', getValue('Grid'));
				setVar('SYS_DIR_SERVICE', getValue('Grid'));
				var pmc_array = getControlProperty('Grid', 'data');
				setVar('PatientID', pmc_array['PATIENT_ID']);
				setVar('PatientFIO', pmc_array['PATIENT_FIO']);
				openWindow({
					name: 'DiseaseCase/diseasecase',
					vars: {
						PatientID: getVar('PatientID'),
						PatientFIO: getVar('PatientFIO')
					}
				}, true, 1000, 700)
				.addListener('onclose',
						function () {
							setControlProperty('Grid', 'locate', getVar('LOC', 1), 1);
							refreshDataSet('DS_USUAL', true, 1);
						},
						null,
						false, 1);

			}
			Form.SHOWRESS = function () {
				var pmc_array = getControlProperty('Grid', 'data');
				setVar('PatientID', pmc_array['PATIENT_ID']);
				setVar('PatientFIO', pmc_array['PATIENT_FIO']);
				openWindow('DiseaseCase/resservice', true, 700, 450);

			}
			/*Form.HOSPITALIZATION=function()
			 {
			 var pmc_array = getControlProperty('Grid','data');
			 setVar('SFLAG',2);
			 setVar('PATIENT', pmc_array['PATIENT_ID']);
			 executeAction('getVisitForHosp', function() {
			 openWindow({name:'HospPlan/hp_add_direction', vars:{VIS_ID:pmc_array['VISIT']}}, true, 470,510); },null,null);
			 }*/
			Form.HOSPITALIZATION = function () {
				var pmc_array = getControlProperty('Grid', 'data');
				setVar('SFLAG', 2);
				executeAction('getVisitForHosp', function () {
					openWindow({
						name: 'HospPlan/hp_directions_edit', vars: {
							VISIT_ID: pmc_array['VISIT'],
							PATIENT_ID: pmc_array['PATIENT_ID'],
							PAT_CARD: pmc_array['PATIENT_CARD_NUMB'],
							MKB_ID: getVar('MKBS'),
							DIR_COMMENT: getVar('MKBS_NOTE'),
							DIR_ID: pmc_array['HOSP_DIR']
						}
					}, true, 470, 510)
							.addListener('onafterclose',
									function () {
										setControlProperty('Grid', 'locate', getVar('LOC', 1));
										refreshDataSet('DS_USUAL', true);
									});
				}, null, null)
																				<!--  тестовая форма--!>
					}
					Form.HOSPITALIZATION1 = function () {
				var pmc_array = getControlProperty('Grid', 'data');
				setVar('SFLAG', 2);
				executeAction('getVisitForHosp', function () {
					openWindow({
						name: 'HospPlan/hp_directions_edit1', vars: {
							VISIT_ID: pmc_array['VISIT'],
							PATIENT_ID: pmc_array['PATIENT_ID'],
							PAT_CARD: pmc_array['PATIENT_CARD_NUMB'],
							MKB_ID: getVar('MKBS'),
							DIR_COMMENT: getVar('MKBS_NOTE'),
							DIR_ID: pmc_array['HOSP_DIR']
						}
					}, true, 470, 510)
							.addListener('onafterclose',
									function () {
										setControlProperty('Grid', 'locate', getVar('LOC', 1));
										refreshDataSet('DS_USUAL', true);
									});
				}, null, null)
			}
			Form.TOHOSP = function () {
				var pmc_array = getControlProperty('Grid', 'data');
				setVar('SFLAG', 1);
				setVar('PATIENT', pmc_array['PATIENT_ID']);
				//executeAction('getVisit', function() {
				setVar('VISIT', pmc_array['VISIT']);
				setVar('DISEASECASES', pmc_array['DISEASECASE']);
				openWindow('HospPlan/hospplanperiod', true, 1000, 510);
				//},null,null);
			}
			Form.SHOWRECIPES = function () {
				setVar('PMC_ID', getControlProperty('Grid', 'data')['PATIENT_ID']);
				setVar('PMC_FIO', getControlProperty('Grid', 'data')['PATIENT_FIO']);
				setVar('REC_FROM_DIRECTIONS', 1);
				if (!empty(getVar('PMC_ID')))
					openWindow('Recipes/recipe_jour_by_pat', true);
			}
			Form.RECIPES = function () {
				setVar('PATIENT', getControlProperty('Grid', 'data')['PATIENT_ID']);
				setVar('DISCASE_CHECK', getControlProperty('Grid', 'data')['DISEASECASE']);
				executeAction('checkRegionAndOptionForRecipes', base().afterCheckRegionForRec)
			}

			Form.afterCheckRegionForRec = function () {
				//ALLOW_RECIPE_OPT  COUNT_HHS
				if (getVar('ALLOW_RECIPE_OPT') == 1 &amp;&amp; getVar('COUNT_HHS') > 0) {
					showAlert('У пациента есть открытая история болезни!', null, 500, 200, null);
				}
				else if (getVar('ALLOW_RECIPE_OPT') == 2 &amp;&amp; getVar('COUNT_HHS') > 0) {
					showConfirm('У пациента есть открытая история болезни. Продолжить выписку рецепта?', null, '500', '200',
							function () {
								base().priv();
							}, null, 'yesno');
				}
				else base().priv();
			}
			Form.priv = function () {
				var pmc_array = getControlProperty('Grid', 'data');
				setVar('PATIENT', pmc_array['PATIENT_ID']);
				setVar('VISIT', pmc_array['VISIT']);
				executeAction('getVisit', function () {
					setVar('DISEASECASES', pmc_array['DISEASECASE']);
					openWindow('Recipes/priv_select', true);
				}, null, null);
			}

			Form.SHOWCNTRL = function () {
				var pmc_array = getControlProperty('Grid', 'data');
				setVar('PERSMEDCARD', pmc_array['PATIENT_ID']);
				setVar('PERSMEDCARD_FIO', pmc_array['PATIENT_FIO']);
				setVar('VISIT', pmc_array['VISIT']);
				openWindow('ControlCard/pmc_control_card', true, 950, 550)
						.addListener(
								'onafterclose', function () {
									setControlProperty('Grid', 'locate', getValue('Grid'));
									refreshDataSet('DS_USUAL');
								}
						);
			}
			Form.ADD_VISITS = function (_dom) {
				setVar('SYS_DIR_SERVICE', getControlValue(_dom));
				setVar('SERVICE_CODE', getControlProperty('Grid', 'data')['SE_CODE']);
				setVar('SERVICE_ID', getControlProperty('Grid', 'data')['SERVICE_ID']);
				if (getControlProperty('Grid', 'data')['SERV_STATUS'] == 1) {
					setVar('SERVICE_ID_FOR', getControlProperty('Grid', 'data')['SERVICE_ID']);
					setVar('REG_EMPLOYER_ID', getControlProperty('Grid', 'data')['VISIT_EMPLOYER']);

					executeAction('CheckRightsForServices', function () {
						if (getVar('RIGHT') == '1') {
							if (getVar('IS_CLOSE_VAR') == 1) {
								showConfirm('Выбранный случай обращения закрыт, продолжить?', null, 300, 200, function () {
									executeAction("SEL_DIR_SERV", base().SuccsessVisit);
								});
							} else {
								executeAction("SEL_DIR_SERV", base().SuccsessVisit);
							}
						}
					});

				}
				else {
					if (!empty(getControlProperty('Grid', 'data')['PAID']) &amp;&amp; getVar('CHECK_PAYMENTS') == 1) {
						alert('Услуга не оплачена. Запрещено оказывать неоплаченные услуги.');
						return;
					}
					if (!empty(getControlProperty('Grid', 'data')['PAID']) &amp;&amp; getVar('CHECK_PAYMENTS') == 2 &amp;&amp; !confirm('Услуга не оплачена. Продолжить?'))
						return;
					executeAction('getEmpServiceAvailability', function () {
						if (getVar('OPT_AVAIL_MAKE_VIS') == 1 &amp;&amp; getControlProperty('Grid', 'data')['SERV_STATUS'] == 0 &amp;&amp; !empty(getControlProperty('Grid', 'data')['CHECK_OMS']) &amp;&amp; getVar('REG_TYPE_FOR_CHECK') != 2) {
							alert('Не заполнены персональные данные пациента');
							return;
						}
						else if (getVar('OPT_AVAIL_MAKE_VIS') == 2 &amp;&amp; getControlProperty('Grid', 'data')['SERV_STATUS'] == 0 &amp;&amp; !empty(getControlProperty('Grid', 'data')['CHECK_OMS']) &amp;&amp; getVar('REG_TYPE_FOR_CHECK') != 2) {
							if (confirm('Не заполнены персональные данные пациента. Оказать услугу?')) {
								if (getVar('AVAIL_EMP_SERVICES') &gt; 0) {
									if (getVar('AvailVisitByFS') > 0)
										executeAction("SEL_DIR_SERV", base().SuccsessVisit);
									else
										alert('Несоответствие оказываемой услуги и доступных источников финансирования!');
								}
								else
									alert('Данная услуга не оказывается данным врачом!');
							}
							else return;
						}
						else {
							if (getVar('AVAIL_EMP_SERVICES') &gt; 0) {
								if (getVar('AvailVisitByFS') > 0)
									executeAction("SEL_DIR_SERV", base().SuccsessVisit);
								else
									alert('Несоответствие оказываемой услуги и доступных источников финансирования!');
							}
							else
								alert('Данная услуга не оказывается данным врачом!');
						}
					});
				}
			}

			Form.refreshDataAfterVisit = function () {
				setControlProperty('Grid', 'locate', getVar('LOC', 1), 1);
				refreshDataSet('DS_USUAL', true, 1);
			}

			Form.ADD_PERSMEDCARD = function (_dom) {
				setVar('PERSMEDCARD', getControlValue(_dom));
				setVar('LOC', getValue('Grid'));
				openWindow('Persmedcard/persmedcard_edit', true, 800, 580)
						.addListener('onclose',
								function () {
									if (getVar('ModalResult', 1) == 1) {
										setControlProperty('Grid', 'locate', getVar('LOC', 1), 1);
										refreshDataSet('DS_USUAL', true, 1);
									}
								},
								null,
								false);
			}

			Form.SERV_CODE = function () {
				openWindow({
					name: 'Directions/lpu_service_multi_sel',
					vars: {'set_SERVICES_GRID': getValue('FI_SE_CODE'), 'multisel': 'true'}
				}, true, 580, 450)
						.addListener('onclose',
								function () {
									if (getVar('ModalResult', 1) == 1) {
										setValue('FI_SE_CODE', getVar('return_id'), 1);
										setCaption('FI_SE_CODE', getVar('return'), 1);
									}
								},
								null,
								false);
			}
			Form.ClearFilter = function () {
				clearControl('FI_FIO_PATIENT', 'FI_SE_CODE', 'FI_SERV_STATUS', 'PAYMENT_KIND', 'CABLABS', 'EMPL_CAB', 'VIEW_T');
				refreshDataSet('DS_USUAL');
			}
			Form.LastDate = function (event, _input) {
				event = event || window.event;
				if (event.ctrlKey) {
					setVar('DATE_NUM', 0);
					executeAction("getTO_DATE_LAST_NEXT", function () {
						base().HideREG_RECORD();
						refreshDataSet('DS_USUAL')
					}, null, null);
				}
				else {
					setVar('DATE_NUM', -1);
					executeAction("getSYS_DATE_LAST_NEXT", function () {
						base().HideREG_RECORD();
						refreshDataSet('DS_USUAL')
					}, null, null);
				}
			}
			Form.NextDate = function (event, _input) {
				event = event || window.event;
				if (event.ctrlKey) {
					setVar('DATE_NUM', 1);
					executeAction("getTO_DATE_LAST_NEXT", function () {
						base().HideREG_RECORD();
						refreshDataSet('DS_USUAL')
					}, null, null);
				}
				else {
					setVar('DATE_NUM', 1);
					executeAction("getSYS_DATE_LAST_NEXT", function () {
						base().HideREG_RECORD();
						refreshDataSet('DS_USUAL')
					}, null, null);
				}
			}
			Form.HideREG_RECORD = function () {
				var RegSYS_DATE_FIX = new RegExp("(\\d\\d)\\.(\\d\\d)\\.(\\d\\d\\d\\d)", "g");
				var tmp = RegSYS_DATE_FIX.exec(getVar('SYS_DATE_FIX'));
				var today_fix = RegExp.$3 + RegExp.$2 + RegExp.$1;
				var RegSYS_DATE = new RegExp("(\\d\\d)\\.(\\d\\d)\\.(\\d\\d\\d\\d)", "g");
				var tmp = RegSYS_DATE.exec(getVar('SYS_DATE'));
				var today_last = RegExp.$3 + RegExp.$2 + RegExp.$1;
				if (today_last &lt; today_fix) {
					setControlProperty('REG_RECORD', 'enabled', false);
				}
				else {
					setControlProperty('REG_RECORD', 'enabled', true);
				}
			}
			Form.goDate = function () {
				if (!empty(getValue('GoDateEdit'))) {
					setVar('SYS_DATE', getValue('GoDateEdit'));
					setVar('DATE_NUM', 0);
					base().HideREG_RECORD();
					executeAction("getSYS_DATE_LAST_NEXT", function () {
						refreshDataSet('DS_USUAL')
					}, null, null);
				}
				else {
					alert('Дата не выбрана');
				}
			}
			Form.PAT_TO_REG = function () {
				setVar('PERSMEDCARD_ID', getControlProperty('Grid', 'data')['PATIENT_ID']);
				//executeAction("getEmpCab",base().onSuccessGetEmpCab_new,null, null);
				executeAction("getEmpCab", base().onSuccessGetEmpCabStartReg, null, null);
			}

			Form.PAT_NEW_REG = function () {
				setVar('PERSMEDCARD_ID', getControlProperty('Grid', 'data')['PATIENT_ID']);
				setVar('PARAM_VISIT', getControlProperty('Grid', 'data')['VISIT']);
				setVar('PARAM_DISEASECASE', getControlProperty('Grid', 'data')['DISEASECASE']);
				//setVar('FLAG_FROM_DIRECTIONS', 1);
				//setVar('SERV_ID',null);
				setVar('PARAM_REG_TYPE', 2);
				setVar('NEED_TO_CLOSE', 1); //регистратура будет знать, что нужно закрыть окно после записи.
				setVar('ModalResult', 0);
				openWindow('Registry/reg_full', true)
						.addListener('onafterclose', function () {
							if (getVar('ModalResult') == 1)
								refreshDataSet('DS_USUAL');
						});

			}

			Form.RegRecord = function () {
				setVar('PERSMEDCARD_ID', null);
				executeAction("getEmpCab", base().onSuccessGetEmpCabStartReg, null, null);
			}
			Form.onSuccessGetEmpCabStartReg = function () {
				executeAction('checkAvailabilityCabEmpReg', function () {
					base().AfterCheckAvCER();
				});
			}
			Form.AfterCheckAvCER = function () {
				setVar('PARAM_VISIT_ID', null);
				setVar('PARAM_DISEASECASE_ID', null);
				if (getVar('FAIL') == 1) {
					alert('Невозможно записать в данный кабинет к данному врачу!');
					return;
				}
				else if (getVar('nREG_TYPE') === 0 || getVar('nREG_TYPE') === '0' || getVar('nREG_TYPE') == 2 || getVar('nREG_TYPE') == 4) {
					//есть врач. записываем к нему.
					setVar('IS_CITO', 0);
					setVar('SERV_ID', null);
					setVar('DATETIME', getValue('GoDateEdit') + ' 00:00');
					openWindow('Registry/reg_write', true, 1024, 550)
							.addListener('onafterclose', function () {
								if (getVar('ModalResult') == 1)
									refreshDataSet('DS_USUAL');
							});
				}
				else if (!empty(getVar('ONE_SERV_ID')) || getVar('nREG_TYPE') == 5) {
					//есть одна услуга записываем на нее (либо несколько услуг, но запись на кабинет - услуга выбирается постфактум)
					setVar('IS_CITO', 0);
					setVar('EMP_ID', null);
					setVar('SERV_ID', getVar('ONE_SERV_ID'));
					setVar('DATETIME', getValue('GoDateEdit') + ' 00:00');
					openWindow('Registry/reg_write', true, 1024, 550)
							.addListener('onafterclose', function () {
								if (getVar('ModalResult') == 1)
									refreshDataSet('DS_USUAL');
							});
				}
				else if (getVar('FAIL') == 2) {
					setVar('SERV_ID', null);
					setVar('PARAM_REG_TYPE', 2);
					executeAction('tryFindApps', function () {
						openWindow('Registry/reg_short', true, 1000, 800)
								.addListener('onafterclose', function () {
									if (getVar('ModalResult') == 1)
										refreshDataSet('DS_USUAL');
								});
					});
				}
				else {
					setVar('APP_NAMES', null);
					setVar('SERV_ID', null);
					setVar('PARAM_REG_TYPE', 2);
					openWindow('Registry/reg_short', true, 1000, 800)
							.addListener('onafterclose', function () {
								if (getVar('ModalResult') == 1)
									refreshDataSet('DS_USUAL');
							});
				}
			}
			Form.onSuccessGetEmpCab_new = function () {
				executeAction('CheckCountsEmpsCabs', null, null, null, 0, 0);
				if (getVar('COUNT_ALL') == 0) {
					alert('Нет действующих графиков для данного кабинета');
					return;
				}
				else if (getVar('COUNT_THIS_EMP') == 1) {
					//alert('Есть такой врач. запись к врачу.');
					setVar('nREG_TYPE', 0);
					setVar('IS_CITO', 0);
					//setVar('EMP_ID',null);
					setVar('SERV_ID', null);
					setVar('DATETIME', getValue('GoDateEdit') + ' 00:00');
					openWindow('Reg/reg_write', true, 1024, 550).addListener('onclose', function () {
						switch (getVar('ModalResult', 1)) {
							case 'close_clear_patient': {
								//1
								break;
							}
							case 'close_finish': {
								refreshDataSet('DS_USUAL', true, 2);
								break;
							}
							case 'close_clear_patient_finish': {
								refreshDataSet('DS_USUAL', true, 2);
								break;
							}
							case 'close_this_patient': {
								refreshDataSet('DS_USUAL', true, 2);
							}
						}
					});
				}
				else if (getVar('COUNT_SERVS') == 1) {
					//alert('Услуга одна. открываем финальное окно, запись на услугу.');
					executeAction('GetOneService', null, null, null, 0, 0);
					if (empty(getVar('ONE_SERV_ID')))
						setVar('nREG_TYPE', 5);
					else
						setVar('nREG_TYPE', 1);
					setVar('IS_CITO', 0);
					setVar('EMP_ID', null);
					setVar('SERV_ID', getVar('ONE_SERV_ID'));
					setVar('DATETIME', getValue('GoDateEdit') + ' 00:00');
					openWindow('Reg/reg_write', true, 1024, 550).addListener('onclose', function () {
						switch (getVar('ModalResult', 1)) {
							case 'close_clear_patient': {
								//1
								break;
							}
							case 'close_finish': {
								refreshDataSet('DS_USUAL', true, 2);
								break;
							}
							case 'close_clear_patient_finish': {
								refreshDataSet('DS_USUAL', true, 2);
								break;
							}
							case 'close_this_patient': {
								refreshDataSet('DS_USUAL', true, 2);
							}
						}
					});
				}
				else if (getVar('COUNT_SERVS') &gt; 1 &amp;&amp; getVar('COUNT_SERV_CAB') == 1) {
					//alert('Услуга не одна. имеется услуга по умолчанию, запись на услугу.');

					setVar('nREG_TYPE', 1);
					setVar('IS_CITO', 0);
					setVar('EMP_ID', null);
					setVar('SERV_ID', getVar('DEF_SERV_ID'));
					setVar('DATETIME', getValue('GoDateEdit') + ' 00:00');
					openWindow('Reg/reg_write', true, 1024, 550).addListener('onclose', function () {
						switch (getVar('ModalResult', 1)) {
							case 'close_clear_patient': {
								//1
								break;
							}
							case 'close_finish': {
								refreshDataSet('DS_USUAL', true, 2);
								break;
							}
							case 'close_clear_patient_finish': {
								refreshDataSet('DS_USUAL', true, 2);
								break;
							}
							case 'close_this_patient': {
								refreshDataSet('DS_USUAL', true, 2);
							}
						}
					});
				}
				else if (getVar('COUNT_SERVS') &gt; 1 &amp;&amp; getVar('COUNT_SERV_CAB') != 1) {
					setVar('SERV_ID', null);
					setVar('REG_TYPE', 2);
					setVar('FLAG_FROM_DIRECTIONS', 1);
					openWindow('Reg/reg_short', true, 1000, 800);
				}
				else {
					alert('Невозможно записать в данный кабинет к данному врачу!');
					return;
				}
			}
			Form.onSuccessGetEmpCab = function () {
				setVar('nREG_TYPE', 0);
				setVar('IS_CITO', 0);
				setVar('SERV_ID', null);
				setVar('DATETIME', getValue('GoDateEdit') + ' 00:00');
				openWindow('Reg/reg_write', true, 1024, 550).addListener('onclose', function () {
					switch (getVar('ModalResult', 1)) {
						case 'close_clear_patient': {
							//1
							break;
						}
						case 'close_finish': {
							refreshDataSet('DS_USUAL', true, 2);
							break;
						}
						case 'close_clear_patient_finish': {
							refreshDataSet('DS_USUAL', true, 2);
							break;
						}
						case 'close_this_patient': {
							refreshDataSet('DS_USUAL', true, 2);
						}
					}
				});
			}

			Form.ONPP = function () {
				if (empty(getValue('Grid'))) {
					PopUpItem_SetHide(getControlByName('pDiary'), 'pControlCard', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pPatToReg', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pPatNewReg', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pMultiDirect', false);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pReciept', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pHosp', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pBulletin', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pDdelDirectServ', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pDeditDirectServ', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pAddPregnantCard', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pDdelDirect', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pHospResult', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pViewRecipes', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pIzvOkaz', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pDirServ', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pCancelHosp', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pReverseCancelHosp', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pHospDel', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pDirByDS', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pCancelDS', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pJavka', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pNejavka', true);
                    PopUpItem_SetHide(getControlByName('pDiary'), 'pNewDraft', true);
                    PopUpItem_SetHide(getControlByName('pDiary'), 'pEditDraft', true);
                    PopUpItem_SetHide(getControlByName('pDiary'), 'pDelDraft', true);
                    PopUpItem_SetHide(getControlByName('pDiary'), 'pAddOuterDir', true);
                    PopUpItem_SetHide(getControlByName('pDiary'), 'pEditOuterDir', true);
                    PopUpItem_SetHide(getControlByName('pDiary'), 'pDelOuterDir', true);
				}
				else {
                    var data = getControlProperty('Grid', 'data');

					PopUpItem_SetHide(getControlByName('pDiary'), 'pDirByDS', false);
					if (getControlProperty('Grid', 'data')['SERV_STATUS'] == 0) {
						PopUpItem_SetHide(getControlByName('pDiary'), 'pReciept', true);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pHosp', true);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pBulletin', true);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pMedCard', true);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pDocResult', true);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pDdelDirectServ', false);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pDeditDirectServ', false);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pDdelDirect', true);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pHospResult', true);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pDirServ', false);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pJavka', true);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pNejavka', false);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pCancelDS', false);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pAddPregnantCard', true);
                        PopUpItem_SetHide(getControlByName('pDiary'), 'pNewDraft', !empty(data['NURSE_USER_TEMPLATES']));
					}
					else {
                        if(data['PATIENT_NSEX'] == 0 && data['SERV_STATUS'] == 1) {
						    PopUpItem_SetHide(getControlByName('pDiary'), 'pAddPregnantCard', false);
                        } else {
                            PopUpItem_SetHide(getControlByName('pDiary'), 'pAddPregnantCard', true);
                        }
						PopUpItem_SetHide(getControlByName('pDiary'), 'pReciept', false);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pBulletin', false);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pMedCard', false);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pDocResult', false);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pDeditDirectServ', true);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pDdelDirect', false);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pHospResult', false);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pDirServ', false);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pNejavka', true);
						PopUpItem_SetHide(getControlByName('pDiary'), 'pCancelDS', true);
                        PopUpItem_SetHide(getControlByName('pDiary'), 'pNewDraft', true);
						if (getControlProperty('Grid', 'data')['SERV_STATUS'] == 2) {
							PopUpItem_SetHide(getControlByName('pDiary'), 'pDdelDirect', true);
							PopUpItem_SetHide(getControlByName('pDiary'), 'pDdelDirectServ', false);
							PopUpItem_SetHide(getControlByName('pDiary'), 'pReciept', true);
							PopUpItem_SetHide(getControlByName('pDiary'), 'pHosp', true);
							PopUpItem_SetHide(getControlByName('pDiary'), 'pBulletin', true);
							PopUpItem_SetHide(getControlByName('pDiary'), 'pMultiDirect', true);
							PopUpItem_SetHide(getControlByName('pDiary'), 'pJavka', false);
						}
						else {
							PopUpItem_SetHide(getControlByName('pDiary'), 'pDdelDirect', false);
							PopUpItem_SetHide(getControlByName('pDiary'), 'pDdelDirectServ', true);
							PopUpItem_SetHide(getControlByName('pDiary'), 'pReciept', false);
							PopUpItem_SetHide(getControlByName('pDiary'), 'pBulletin', false);
							PopUpItem_SetHide(getControlByName('pDiary'), 'pMultiDirect', false);
							PopUpItem_SetHide(getControlByName('pDiary'), 'pJavka', true);
							if (getControlProperty('Grid', 'data')['SE_TYPE'] == 3) {
								PopUpItem_SetHide(getControlByName('pDiary'), 'pHosp', false);
							}
							else {
								PopUpItem_SetHide(getControlByName('pDiary'), 'pHosp', true);
							}
						}

					}
					if (!empty(getControlProperty('Grid', 'data')['HOSP_DIR']))
						PopUpItem_SetHide(getControlByName('pDiary'), 'pHospDel', false);
					else
						PopUpItem_SetHide(getControlByName('pDiary'), 'pHospDel', true);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pPatToReg', false);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pControlCard', false);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pPatNewReg', false);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pViewRecipes', false);
					PopUpItem_SetHide(getControlByName('pDiary'), 'pIzvOkaz', false);
					executeAction('isShowDirServReport', null, null, null, 0, 0);
					if (getVar('IS_SHOW') == 1)
						PopUpItem_SetHide(getControlByName('pDiary'), 'pDirServ', false);
					else
						PopUpItem_SetHide(getControlByName('pDiary'), 'pDirServ', true);

					// проверка на пункт меню 'Оформить отказ от госпитализации'
					setVar('VISIT_ID1', getControlProperty('Grid', 'data')['VISIT']);
					executeAction('getHospDirData', function () {
						if (!empty(getControlProperty('Grid', 'data')['HOSP_DIR']) && getVar('IS_CANCELED') == 0) {
							PopUpItem_SetHide(getControlByName('pDiary'), 'pCancelHosp', false);
						}
						else {
							PopUpItem_SetHide(getControlByName('pDiary'), 'pCancelHosp', true);
						}

						if (getVar('IS_CANCELED') == 1)
							PopUpItem_SetHide(getControlByName('pDiary'), 'pReverseCancelHosp', false);
						else
							PopUpItem_SetHide(getControlByName('pDiary'), 'pReverseCancelHosp', true);
					});
					setVar('AGENT_ID', getControlProperty('Grid', 'data')['PATIENT_AGENT']);
					setVar('REP_VISIT_ID', getControlProperty('Grid', 'data')['VISIT']);
					setVar('DIR_SERVICE', getValue('Grid'));

                    PopUpItem_SetHide(getControlByName('pDiary'), 'pEditDraft', empty(data['NURSE_USER_TEMPLATES']));
                    PopUpItem_SetHide(getControlByName('pDiary'), 'pDelDraft', empty(data['NURSE_USER_TEMPLATES']));

                    // внешние направления
                    if(data['SERV_STATUS'] == 1) {
                        if(
                            !empty(data['OUTER_DIRECTION_ID'])
                            && (data['REPRESENT_DIRECTION_LPU'] == data['LPU'] || empty(data['REPRESENT_DIRECTION_ID']))
                        ) {
                            PopUpItem_SetHide(getControlByName('pDiary'), 'pAddOuterDir', true);
                            PopUpItem_SetHide(getControlByName('pDiary'), 'pEditOuterDir', false);
                            PopUpItem_SetHide(getControlByName('pDiary'), 'pDelOuterDir', false);
                        } else {
                            PopUpItem_SetHide(getControlByName('pDiary'), 'pAddOuterDir', false);
                            PopUpItem_SetHide(getControlByName('pDiary'), 'pEditOuterDir', true);
                            PopUpItem_SetHide(getControlByName('pDiary'), 'pDelOuterDir', true);
                        }
                    } else {
                        PopUpItem_SetHide(getControlByName('pDiary'), 'pAddOuterDir', true);
                        PopUpItem_SetHide(getControlByName('pDiary'), 'pEditOuterDir', true);
                        PopUpItem_SetHide(getControlByName('pDiary'), 'pDelOuterDir', true);
                    }
				}
			}
			Form.DirByDS = function () {
				//Открытие окна направлений
				var data = getControlProperty('Grid', 'data');
				setVar('SYS_DIR_SERVICE', getValue('Grid'));
				setVar('SoloMode', 1);
				setVar('VISIT', data['VISIT']);
				setVar('DIR_ID', getValue('Grid'));
				setVar('SERVICE_CODE', data['SE_CODE']);
				setVar('SERVICE_ID', data['SERVICE_ID']);
				setVar('PERSMEDCARD_ID', data['PATIENT_ID']);
				openWindow({'name':'Directions/direction_lpuds_service_control',
					vars:{'VISIT':data['VISIT']}}, true, 850, 600)
						.addListener('onafterclose', function () {
							setVar('SoloMode', '')
						});
			}
			Form.imgErrorPath = new Array();
			Form.imgErrorPath[0] = 'Forms/Directions/img/empty';
			Form.imgErrorPath[1] = 'Forms/Directions/img/inform';
			Form.ImgOnClickError = function (domObject) {
				var _error = getProperty(domObject, 'ALOMS_PAY_HAS_ERROR', 0);
				if (!empty(_error)) {
					showAlert(_error, 'Ошибки в карте пациента, задолженности, запись утеряна', 400, 200)
				}
			}
			Form.VIEW_T_onChange = function () {
				if (getValue('VIEW_T') == 1) {
					setControlProperty('EMPL_CAB', 'enabled', false);
				}
				else {
					setControlProperty('EMPL_CAB', 'enabled', true);
				}
			}
			Form.CancelDS = function () {
				var data = getControlByName('Grid').data;
				setVar('DS_ID', getValue('Grid'));
				if (data['SERV_STATUS'] == 1) {
					alert('Услуга оказана. Отмена невозможна.');
				}
				else if (data['SERV_STATUS'] == 2) {
					alert('Услуга уже отменена.');
				}
				else {
					if (getVar('DSInputCancelReasons') == '1') {
						openWindow('Directions/direction_cancel', true)
								.addListener('onafterclose',
										function () {
											if (getVar('ModalResult')) {
												setVar('ModalResult', 1, 1);
												refreshDataSet('DS_USUAL');
											}
										});
					} else {
						executeAction('cancelDirectionServices', function () {
							setVar('ModalResult', 1, 1);
							refreshDataSet('DS_USUAL');
						});
					}
				}
			};

			Form.deleteDirServDir = function () {
				if (confirm('Вы действительно хотите удалить запись из регистратуры?')) {
					executeAction('DelDirDirServ', function () {
						refreshDataSet('DS_USUAL');
					});
				}
			}
			Form.updateDirServDir = function () {
				if (confirm('Вы действительно хотите редактировать запись в регистратуре?')) {
					setVar('DIR_SERV_UPD_ID', getValue('Grid'));
					setVar('flagDS_USUAL', 1);
					openWindow('Registry/reg_edit_write', true, 1024, 560)
							.addListener('onafterclose', function () {
								if (getVar('ModalResult') == 1)
									refreshDataSet('DS_USUAL');
							});
				}
			}
			Form.updateDirServGenReg = function () {
				if (empty(getValue('Grid')) || !confirm('Вы действительно хотите отредактировать запись в регистратуре?')) {
					return;
				}
				executeAction('getGenRegData', function () {
					if (empty(getVar('ACTION_DS_REC_TYPE'))) {
						alert('Не удалось подобрать параметры графика для данной записи. Возможно график был изменен.');
					} else {
						openWindow({
							name: 'GenRegistry/reg_write',
							vars: {
								DIR_REG_TYPE: getVar('ACTION_DIR_REG_TYPE'),
								TIME_TYPE: getVar('ACTION_TIME_TYPE'),
								EMP_ID: getVar('ACTION_EMP_ID'),
								SERV_ID: getVar('ACTION_SERV_ID'),
								HAS_OWN_SCHED: getVar('ACTION_HAS_OWN_SCH'),
								CAB_ID: getVar('ACTION_CAB_ID'),
								DS_REC_DATE: getVar('ACTION_DS_REC_DATE'),
								DS_REC_TYPE: getVar('ACTION_DS_REC_TYPE'),
								IS_CITO: getVar('ACTION_IS_CITO'),
								DIRECTION_SERVICE: getValue('Grid'),
								RESERVATION: null,
								LPU_DS: null,
								CLSCH_TYPE: getVar('ACTION_CLSCH_TYPE'),
								DURATION: getVar('ACTION_DURATION'),
								NORDER: getVar('ACTION_NORDER')
							}
						}, true)
								.addListener('onafterclose', function () {
									setVar('ACTION_DIR_REG_TYPE', null);
									setVar('ACTION_TIME_TYPE', null);
									setVar('ACTION_EMP_ID', null);
									setVar('ACTION_SERV_ID', null);
									setVar('ACTION_HAS_OWN_SCH', null);
									setVar('ACTION_CAB_ID', null);
									setVar('ACTION_DS_REC_DATE', null);
									setVar('ACTION_DS_REC_TYPE', null);
									setVar('ACTION_IS_CITO', null);
									setVar('ACTION_CLSCH_TYPE', null);
									setVar('ACTION_DURATION', null);
									setVar('ACTION_NORDER', null);
									if (getVar('ModalResult') == 1) {
										refreshDataSet('DS_USUAL')
									}
								});
					}
				});
			}


			Form.PrintAgreement = function (hyperlink) {
				setVar('REP_ID', getValue('Grid'));
				printReportByCode('reception_agreement');
			}
			Form.PrintAgreementPersInfo = function () {
				setVar('REP_ID', getValue('Grid'));
				if (!empty(getVar('REP_ID'))) {
					setVar('AGENT_ID', getControlProperty('Grid', 'data')['PATIENT_AGENT']);
					printReportByCode('reception_agreement_personal_info');
				}
			}
			Form.PrintExpertCard = function () {
				setVar('REP_ID', getValue('Grid'));
				printReportByCode('expert_card');
			}
			Form.PrintAgreementOper = function (hyperlink) {
				setVar('REP_ID', getValue('Grid'));
				printReportByCode('reception_agreement_oper');
			}
			Form.PrintDiagnozesRep = function (hyperlink) {
				setVar('REP_ID', getControlProperty('Grid', 'data')['PATIENT_ID']);
				printReportByCode('diagnozes');
			}
			Form.PrintMedCard = function () {
				Form.PrintVisit(getControlProperty('Grid', 'data')['VISIT']);
			}
			Form.PrintDocResult = function () {
				Form.PrintVisit(getControlProperty('Grid', 'data')['VISIT'], null, 2);
			}
			Form.MultiDirection = function () {
				setVar('PATIENT_FIO', getValue('FI_FIO_PATIENT'));
				setVar('CABLAB_TO_NAME', getValue('CABLABS'));
				openWindow('Directions/direction_multi', true, 999, 601);
			}
			Form.PrintAgreementNarkolog = function () {
				var pmc_array = getControlProperty('Grid', 'data');
				setVar('PATIENT_ID', pmc_array['PATIENT_ID']);
				printReportByCode('patient_agreement_narkolog');
			}
			Form.PrintAgreementUZI = function () {
				var pmc_array = getControlProperty('Grid', 'data');
				setVar('PATIENT_ID', pmc_array['PATIENT_ID']);
				setVar('DIRSERV_ID', pmc_array['ID']);
				printReportByCode('patient_agreement_uzi');
			}
			Form.PrintAgreementAbort = function () {
				setVar('REP_ID', getValue('Grid'));
				printReportByCode('agreement_abort');
			}
			Form.NewVisitOpen = function (_param, _param2) {
				_param2 = typeof _param2 !== 'undefined' ?  _param2 : null;
				setVar('NewIDD', null);
				setVar('NewVisIDD', null);
				setVar('DIRECT_ID', getControlProperty('Grid', 'data')['DIRECTION']);
				setVar('DISCAS_ID', getControlProperty('Grid', 'data')['DISEASECASE']);
				setVar('PERSMC_ID', getControlProperty('Grid', 'data')['PATIENT_ID']);
				//setVar('HELP_SERVICE_CODE', _param);
				_param ? setVar('PARAM_CODE', _param) : setVar('PARAM_CODE', getVar('HELP_SERVICE_CODE'));
				!empty(_param2) ? setVar('CHECK_SNILS_AND_LPU', _param2) : setVar('CHECK_SNILS_AND_LPU' , false);
				executeAction('TryFindIdDirServ', function () {
					base().afterTryFindDirServ();
				});
			}

			Form.afterTryFindDirServ = function () {
				if (!empty(getVar('NewVisIDD'))) {
					base().IsResultAfter();
				}
				else if (!empty(getVar('NewIDD'))) {
					if (getVar('HELP_SERVICE_CODE') == 'С 001') {
						base().IsResultAfterSpr();
					}
					else {
						base().IsResultAfter();
					}
				}
				else {
					executeAction('AddDirection', function () {
						if (getVar('HELP_SERVICE_CODE') == 'С 001') {
							base().IsResultAfterSpr();
						}
						else {
							base().IsResultAfter();
						}
					});
				}
			}
			Form.IsResultAfter = function () {
				setVar('SYS_DIR_SERVICE', getVar('NewIDD'));
				setVar('SER_CODE', getVar('PARAM_CODE')||getVar('HELP_SERVICE_CODE'));
				openWindow({
					name: 'UniversalTemplate/UniversalTemplate',
					service: getVar('SER_CODE'),
					template_id: getVar('TEMPLATE_ID')
				}, true, 890, 725);
			}
			Form.IsResultAfterSpr = function () {
				setVar('SYS_DIR_SERVICE', getVar('NewIDD'));
				setVar('SER_CODE', getVar('HELP_SERVICE_CODE'));
				setVar('TH_DISEASECASE', getControlProperty('Grid', 'data')['DISEASECASE']);
				openWindow('Directions/spr_visit_call', true);
			}
			Form.PrintReportHelpSrv = function () {
				if (getVar('HELP_SERVICE_CODE') == 'Извещение ЗНО') {
					setVar('VISIT', getVar('NewVisIDD'));
					printReportByCode('NOTIFICATION_FIRST_CANCER');
				}
				else if (getVar('HELP_SERVICE_CODE') == 'Протокол ЗНО') {
					setVar('VISIT', getVar('NewVisIDD'))
					printReportByCode('PROTOCOL_NEGLECT');
				}
			}
			Form.PrintHospResult = function () {
				setVar('VISIT_ID1', getControlProperty('Grid', 'data')['VISIT']);
				setVar('DIRECTION_ID', null);
				executeAction('getHospDirId', null, null, null, 0, 0);
				if (empty(getVar('DIRECTION_ID'))) return;
				if (getControlProperty('Grid', 'data')['SE_TYPE'] == 3) {
					printReportByCode('HOSPITALISATION_DIR');
				}
				else {
					return;
				}
			}
			Form.PrintAmbTalon = function () {
				setVar('REP_DS_ID', getValue('Grid'));
				setVar('REP_VISIT_ID', getControlProperty('Grid', 'data')['VISIT']);
				setVar('REP_PATIENT_ID', getControlProperty('Grid', 'data')['PATIENT_ID']);
				openWindow('Reports/AmbReps/amb_talon_choose', true);
				// printReportByCode(report_name);
			}
			Form.PrintRadDoseExposure = function () {
				setVar('PATIENT', getControlProperty('Grid', 'data')['PATIENT_ID']);
				printReportByCode('rad_dose_exposure_sheet');
			}
			Form.goExtr = function () {
				setVar('NEOTL_FROM_DIARY', 1);
				openWindow('Sys_Emergencyjournal/find_patient', true, 800, 800)
						.addListener(
								'onclose',
								function () {
									refreshDataSet('DS_USUAL', true, 1);
								},
								null,
								false
						);
			}
			Form.showPatientWarnings = function () {
				setVar('PERSMEDCARD', getControlProperty('Grid', 'data')['PATIENT_ID']);
				setVar('AGENT', getControlProperty('Grid', 'data')['PATIENT_AGENT']);
				openWindow('ArmPatientsInDep/patients_warnings', true);
			};
			Form.onCloneMainData = function (_dom, _dataArray) {
				var img = getControlByName('error_img');
				var butInv = getControlByName('INV_BUTTON');
				var butCanc = getControlByName('CANC_BUTTON');
				_dataArray['ALOMS_PAY_HAS_ERROR'] = _dataArray['CHECK_OMS'] + _dataArray['PAY_HAS'] + _dataArray['REC_LOST'];
				if (!empty(_dataArray['ALOMS_PAY_HAS_ERROR'])) {
					img.src = Form.imgErrorPath[1] + '.gif';
				}
				else {
					img.src = Form.imgErrorPath[0] + '.gif';
				}
				img.setAttribute('ALOMS_PAY_HAS_ERROR', _dataArray['ALOMS_PAY_HAS_ERROR'], true);
				var bed_img = getControlByName('bed_img'),
						pat_warn = getControlByName('pat_warn');
				if (_dataArray['PATIENT_IN_BED'] &amp;&amp; _dataArray['PATIENT_IN_BED'] != undefined &amp;&amp; _dataArray['PATIENT_IN_BED'] != '0') {
					bed_img.style.display = '';
					pat_warn.style.cssFloat = 'right';
					pat_warn.style.marginLeft = '5px';
				}
				else {
					bed_img.style.display = 'none';
				}
				if (_dataArray['EXISTS_COMP_DIS'] > 0 || _dataArray['EXIST_ALLERG'] > 0)
					getControlByName('pat_warn').style.display = '';
				else
					getControlByName('pat_warn').style.display = 'none';
				if (_dataArray['HAS_DISP'] == 1)
				    getControlByName('has_disp').style.display = '';
				else
					getControlByName('has_disp').style.display = 'none';
				if (_dataArray['IS_OL_PREG'] > 0)
					getControlByName('pregn_warn').style.display = '';
				else
					getControlByName('pregn_warn').style.display = 'none';
				if (_dataArray['IS_PATALOGY'] > 0)
					getControlByName('patalogy').style.display = '';
				else
					getControlByName('patalogy').style.display = 'none';

				if (_dataArray['SHOW_BUTTON'] == 2) {
					butInv.style.display = '';
					butCanc.style.display = 'none';
				}
				else if (_dataArray['SHOW_BUTTON'] == 1) {
					butInv.style.display = 'none';
					butCanc.style.display = '';
				}
				else {
					butInv.style.display = 'none';
					butCanc.style.display = 'none';
				}

				getControlByName('commentButton').style.display = (empty(_dataArray['S_COMMNET']) ? 'none' : '');

				if (getVar('SHOW_FLG') == 1) {
					if (parseInt(_dataArray['AGN_YEARS']) < 16) {
						getControlByName('pat_warn_FLG').style.display = 'none';
						getControlByName('patalogy_flg').style.display = 'none';
					} else {
						if (_dataArray['AGENT_FLU'] == 0) {
							getControlByName('pat_warn_FLG').style.display = 'inline-block';
						} else {
							if (_dataArray['PMC_FLU'] > 0) {
								getControlByName('pat_warn_FLG').style.display = 'inline-block';
							} else {
								getControlByName('pat_warn_FLG').style.display = 'none';
							}
						}

						if (_dataArray['PMC_FLU_PATALOGY'] > 0) {
							getControlByName('patalogy_flg').style.display = 'inline-block';
						} else {
							getControlByName('patalogy_flg').style.display = 'none';
						}
					}
				}
				if(getVar('IS_RISAR') == 1) {
					if(Number(_dataArray['IS_RISAR']) === -1 ) {
						getControlByName('risar_ok').style.display = 'none';
						getControlByName('risar_bad').style.display = 'none';
					} else if (Number(_dataArray['IS_RISAR']) === 1) {
					    getControlByName('risar_ok').style.display  = 'inline-block';
					    getControlByName('risar_bad').style.display = 'none';
					} else {
						var img = _dom.querySelector('[name="risar_bad"]');
						img.setAttribute('title', 'Осмотр не был передан в Барс.МР'+ '\n' + _dataArray['IS_RISAR']);
					    getControlByName('risar_bad').style.display = 'inline-block';
					    getControlByName('risar_ok').style.display  = 'none';
					}
				}
				if(Number(_dataArray['COLOR']) == 1) {
					_dom.style.color = 'red';
					try{
						_dom.querySelector('[name="nButton"]').style.color = 'initial';
					}catch (e){}
					try{
						_dom.querySelector('[name="PATIENT_FIO_COL"] a').style.color = 'red';
					}catch (e){}
					try{
						_dom.querySelector('[name="nHyperlink"] a').style.color = 'red';
					}catch (e){}
				} else {
					_dom.style.color = 'initial';
					try{
						_dom.querySelector('[name="PATIENT_FIO_COL"] a').style.color = 'initial';
					}catch (e){}
					try{
						_dom.querySelector('[name="nHyperlink"] a').style.color = 'initial';
					}catch (e){}
				}
			};

			Form.INVITE_PATIENT = function () {
				executeAction('invitePatientToCab', function () {
					setControlProperty('Grid', 'locate', getValue('Grid'));
					refreshDataSet('DS_USUAL');
				});
			}
			Form.CANCEL_INVITATION = function () {
				executeAction('cancelInvitationPatToCab', function () {
					setControlProperty('Grid', 'locate', getValue('Grid'));
					refreshDataSet('DS_USUAL');
				});
			}
			Form.SuccsessVisit = function () {
				if (getControlProperty('Grid', 'data')['SERV_STATUS'] == 1 &amp;&amp; getVar('IS_AUTO_TEMPL') == 1) {
					alert('Отметка о выполнении уже проставлена!');
					return;
				}
				setVar('LOC', getValue('Grid'));
				setVar('DEF_NURSE', getValue('DEF_NURSE'));
				setVar('DEF_NURSEcap', getCaption('DEF_NURSE'));
				if ((getVar('SHOW_BUTTON') == 1 || getVar('INVITING') == 0) &amp;&amp; getControlProperty('Grid', 'data')['SERV_STATUS'] == 0) {
					executeAction('cancelInvitationPatToCab', base().openTemplate);
				}
				else {
					Form.openTemplate();
				}
			}
			Form.openTemplate = function () {
				return openWindow({
					name: 'UniversalTemplate/UniversalTemplate',
					service: getVar('SERVICE_CODE'),
					template_id: getVar('TEMPLATE_ID'),
					service_ds: getVar('SYS_DIR_SERVICE'),
					vars: {REG_DIR_SERV: getValue('Grid'), PATIENT_ID: getControlProperty('Grid', 'data')['PATIENT_ID']}
				}, true, 890, 725);
			}
			Form.DelHosp = function () {
				var pmc_array = getControlProperty('Grid', 'data');

				setVar('VISIT_ID', pmc_array['VISIT']);
				executeAction('checkDirCancel', function () {
					if (getVar('IS_DIR_CANCELED') == 1) {
						alert('Невозможно удалить направление на госпитализацию, т.к. по данному направлению оформлен и подтвержден отказ от госпитализации');
						return;
					}
				});

				setVar('HospDir', pmc_array['HOSP_DIR'])
				if (!empty(getVar('HospDir')))
					if (confirm('Удалить направление на госпитализацию?'))
						executeAction('FullDelHospAction', function () {
							refreshDataSet('DS_USUAL')
						});
			}
			Form.cancelHosp = function () {
				if (!empty(getVar('OUTER_HOSP_HISTORY'))) {
					alert('Невозможно оформить отказ, т.к. по направлению ' + getVar('OUTER_DIR_NUMB') + ' создана История болезни');
					return;
				}

				setVar('LOC', getValue('Grid'));
				setVar('HOSP_DIR', getControlProperty('Grid', 'data')['HOSP_DIR']);
				setVar('HOSP_DIR_LPU', getVar('LPU_ID'));
				openWindow('Directions/direction_cancel_reason', true)
						.addListener('onclose', function () {
							if (getVar('ModalResult', 1) == 1) {
								setControlProperty('Grid', 'locate', getVar('LOC', 1), 1);
								refreshDataSet('DS_USUAL', true, 1);
							}
						}, null, false, 1);
			}
			Form.reverseCancelHosp = function () {
				setVar('LOC', getValue('Grid'));
				setVar('HOSP_DIR', getControlProperty('Grid', 'data')['HOSP_DIR']);
				setVar('HOSP_DIR_LPU', getVar('LPU_ID'));
				executeAction('reverseCancelHosp', function () {
					setControlProperty('Grid', 'locate', getVar('LOC'));
					refreshDataSet('DS_USUAL');
				});
			}
			//обратка кнопок нового расписания GenRegistry
			Form.genRegRecord = function (_set_current_patient) {
				if (empty(getValue('GoDateEdit'))) {
					alert('Для записи необходимо заполнить поле "Дата".');
				}
				if (!Number(getValue('IS_WORKING_HERE'))) {
					showAlert('Запись невозможна, так как врач больше не работает в этом кабинете.', 'Запись невозможна', 485, 115);
					return;
				}
				//очищаем ненужные переменные
				base().clearPatientVarsForSchedule();
				base().clearSystemVarsForSchedule();
				if (_set_current_patient == 1) {
					setVar('PERSMEDCARD_ID', getControlProperty('Grid', 'data')['PATIENT_ID']);
				}
				executeAction('getEmpCabGenReg', base().findSchedule);
			}
			Form.findSchedule = function () {
				executeAction('findSchedule', base().openSchedule);
			}
			Form.clearSystemVarsForSchedule = function () {
				setVar('CAB_LIST', null);
				setVar('SERV_ID', null);
				setVar('EMP_ID', null);
				setVar('CAB_ID', null);
				setVar('SCH_RES', 1);
				setVar('NORDER', null);
				setVar('DS_REC_TYPE', null);
				setVar('CLSCH_TYPE', null);
				setVar('HAS_OWN_SCHED', null);
			}
			Form.clearPatientVarsForSchedule = function () {

				setVar('REG_DIR_SERV', null);
				setVar('HH_DEP_ID', null);
				setVar('HPK_PLAN_JOURNAL', null);
				setVar('LPU_DS', null);
				setVar('PERSMEDCARD_ID', null);
				setVar('PARAM_VISIT', null);
				setVar('PARAM_DISEASECASE', null);

			}
			Form.openSchedule = function () {
				//начинаем запись
				if (getVar('SCH_RES') == '0') {
					//открываем последнее окно.
					setVar('DS_REC_DATE', getValue('GoDateEdit') + ' 00:00');
					_dsrt = getVar('DS_REC_TYPE');
					if (_dsrt == 0 || _dsrt == 2) {
						_resource = getVar('EMP_ID');
					} else if (_dsrt == 1 || _dsrt == 3) {
						_resource = getVar('SERV_ID');
					} else {
						_resource = null;
					}
					setVar('ParamAction',0);
					base().openRegWrite('GenRegistry/reg_write',{
							DIR_REG_TYPE: 0,
							TIME_TYPE: null,
							EMP_ID: getVar('EMP_ID'),
							SERV_ID: getVar('SERV_ID'),
							HAS_OWN_SCHED: getVar('HAS_OWN_SCHED'),
							CAB_ID: getVar('CAB_ID'),
							DS_REC_DATE: getVar('DS_REC_DATE'),
							DS_REC_TYPE: getVar('DS_REC_TYPE'),
							IS_CITO: 1,
							DIRECTION_SERVICE: null,
							RESERVATION: null,
							LPU_DS: null,
							CLSCH_TYPE: getVar('CLSCH_TYPE'),
							DURATION: null,
							NORDER: getVar('NORDER')
						},function(_mod){
						refreshDataSet('DS_USUAL');
					})
				} else if (getVar('SCH_RES') == '2' && !empty(getVar('CAB_LIST'))) {
					//открывает расписание на кабинет
					openWindow({
						name: 'GenRegistry/reg_full',
						vars: {
							CAB_LIST: getVar('CAB_LIST'),
							MODE: 'close',
							DIR_REG_TYPE: 0
						}
					}, true)
							.addListener('onafterclose', function () {
								refreshDataSet('DS_USUAL');
							});
				} else if (getVar('SCH_RES') == '3') {
					if (!confirm('Не удается создать срочную запись пациента в данный кабинет на выбранную дату. Открыть окно выбора времени?')) {
						return;
					}
					//открываем расписание на текущую сущность (т.к. срочников нет или забито все)
					_dsrt = getVar('DS_REC_TYPE');
					if (_dsrt == 0 || _dsrt == 2) {
						_resource = getVar('EMP_ID');
					} else if (_dsrt == 1 || _dsrt == 3) {
						_resource = getVar('SERV_ID');
					} else {
						_resource = null;
					}
					openWindow({
						name: 'GenRegistry/reg_select_time_full',
						vars: {
							DIR_REG_TYPE: 0,
							TIME_TYPE: '',
							SOURCE_ID: _resource,
							SOURCE_TYPE: getVar('DS_REC_TYPE'),
							HAS_OWN_SCHED: getVar('HAS_OWN_SCHED'),
							CAB_ID: getVar('CAB_ID'),
							DS_DATE: getValue('GoDateEdit')
						}
					}, true)
							.addListener('onafterclose', function () {
								refreshDataSet('DS_USUAL');
							});
				} else if (getVar('SCH_RES') == '4') {
					//открывает расписание на кабинет
					openWindow({
						name: 'GenRegistry/reg_full',
						vars: {
							CAB_ID: getVar('CAB_ID'),
							MODE: 'close',
							DIR_REG_TYPE: 0
						}
					}, true)
							.addListener('onafterclose', function () {
								refreshDataSet('DS_USUAL');
							});
				} else {
					alert('Невозможно записать в данный кабинет к данному врачу.');
				}
			}
			Form.patientNewGenReg = function () {
				//очищаем ненужные переменные
				base().clearPatientVarsForSchedule();
				base().clearSystemVarsForSchedule();
				//переменные
				setVar('PERSMEDCARD_ID', getControlProperty('Grid', 'data')['PATIENT_ID']);
				setVar('PARAM_VISIT', getControlProperty('Grid', 'data')['VISIT']);
				setVar('PARAM_DISEASECASE', getControlProperty('Grid', 'data')['DISEASECASE']);
				//новое расписание
				openWindow({
					name: 'GenRegistry/reg_full',
					vars: {
						MODE: 'close'
					}
				}, true)
						.addListener('onafterclose', function () {
							refreshDataSet('DS_USUAL');
						});
			}
			Form.PrintCostReference = function () {
				var visit = getControlProperty('Grid', 'data')['VISIT'];
				Form.CostReferences_PrintReport('VISITS', visit); // из CostReferences/cost_references_actions
			};
			//обработка кнопок нового расписания GenRegistry конец
			Form.checkCLEmps = function () {
				executeAction('ACT_CHECK_CLEMPS');
			};
			Form.addPregnantCard = function () {
				openD3Form('Pregnancy/pregnant_card_add', true, {
					vars: {
						PATIENT: getControlProperty('Grid', 'data')['PATIENT_ID'],
						VISIT: getControlProperty('Grid', 'data')['VISIT'],
						FROM_VISIT: 1
					},
					onclose: function (mod) {
						if (mod) {
							refreshDataSet('DS_USUAL');
						}
					}
				});
			}
			Form.openMassWrite = function () {
				openD3Form('Registry/reg_mass_write');
			}
			Form.updDirComment = function () {
				var data = getControlProperty('Grid', 'data');

				setVar('window_caption', 'Комментарий');
				setVar('in_value', data['S_COMMNET']);

				openWindow('UniversalForms/text_area', true)
						.addListener('onafterclose', function () {
							setVar('in_value', null);

							if (getVar('ModalResult') == 1) {
								setVar('S_COMMNET', getVar('return_value'));
								setVar('DS_ID', data['ID']);

								executeAction('updDirComment', function () {
									data['S_COMMNET'] = getVar('S_COMMNET');
								});
							}
						}, null, false);
			}
            Form.editDraft = function() {
                var data = getControlProperty('Grid', 'data');

                setVar('VUT_ID', data['NURSE_USER_TEMPLATES']);

                executeAction('getVUTData', function() {
                    setVar('SYS_DIR_SERVICE', data['ID']);
                    setVar('PREV_VISIT', null);

                    openWindow({
                        name: 'UniversalTemplate/UniversalTemplate',
                        template_id: getVar('VUT_TEMPLATE_ID'),
                        service: data['SE_CODE'],
                        templateprev: 'true',
                        fill_nurse_vut: 'true',
                        vars:{
                            REG_DIR_SERV: data['ID'],
                            templateprev: true,
                            fill_nurse_vut: true,
                            templateprev_data: {
                                TEMPL_NAME: getVar('VUT_TEMPLATE_NAME'),
                                TEMPL_ID: getVar('VUT_ID')
                            }
                        }
                    }, true, 890,725);
                });
            };
            Form.newDraft = function() {
                var data = getControlProperty('Grid', 'data');

                setVar('SYS_DIR_SERVICE', data['ID']);

                executeAction('getDataBeforeFillVUT', function() {
                    openWindow({
                        name: 'UniversalTemplate/UniversalTemplate',
                        template_id: getVar('VUT_TEMPLATE_ID'),
                        service: data['SE_CODE'],
                        templateprev: 'true',
                        fill_nurse_vut: 'true',
                        vars:{
                            REG_DIR_SERV: data['ID'],
                            templateprev: true,
                            fill_nurse_vut: true,
                            templateprev_data: {
                                TEMPL_NAME: getVar('VUT_TEMPLATE_NAME')
                            }
                        }
                    }, true, 890,725);
                });
            };
            Form.delDraft = function() {
                var data = getControlProperty('Grid', 'data');
                setVar('SYS_DIR_SERVICE', data['ID']);
                setVar('VUT_ID', data['NURSE_USER_TEMPLATES']);

                if(confirm('Вы действительно хотите удалить запись?')) {
                    executeAction('delDraft', function() {
                        setControlProperty('Grid', 'locate', getVar('LOC'));
                        refreshDataSet('DS_USUAL');
                    });
                }
            };
            Form.changeDefNurse = function () {
                if(getValue('DEF_NURSE') != getVar('DEF_NURSE_ID')){
                    setValue('NURSE_DEFAULT_CHECK', 0);
                }
            }

            Form.setDefaultNurse = function () {
                if(getValue('DEF_NURSE') != getVar('DEF_NURSE_ID')){
                    if(getValue('NURSE_DEFAULT_CHECK') == 1 && getValue('DEF_NURSE')){
                        executeAction('SET_NURSE_DEFAULT', function () {
                            setVar('DEF_NURSE_ID', getValue('DEF_NURSE'));
                        });
                    }
                }
            }
            Form.addEditOuterDir = function(mode) {
                var data = getControlProperty('Grid', 'data');

                executeAction('checkIsAmbTalonInReestr', function() {
                    if(+getVar('REESTRSP_CHECK') == 0) {
                        showAlert('ТАП уже включен в счет-реестр, изменение данных внешнего направления невозможно.');
                        return;
                    } else {
                        openD3Form('Directions/outer_dir_edit', true, {
                            width: 1000,
                            height: 240,
                            vars: {
                                ID: (mode == 'edit') ? data['OUTER_DIRECTION_ID'] : null,
                                DS_ID: data['ID']
                            }, onclose: function(mod) {
                                console.log(mod);
                                if(mod) {
                                    setControlProperty('Grid', 'locate', getValue('Grid'));
                                    refreshDataSet('DS_USUAL');
                                }
                            }
                        });
                    }
                });
            };
            Form.delOuterDir = function() {
                if (confirm('Вы действительно хотите удалить внешнее направление?')) {
                    executeAction('checkIsAmbTalonInReestr', function() {
                        if(+getVar('REESTRSP_CHECK') == 0) {
                            showAlert('ТАП уже включен в счет-реестр, изменение данных внешнего направления невозможно.');
                            return;
                        } else {
                            executeAction('delOuterDir', function() {
                                setControlProperty('Grid', 'locate', getValue('Grid'));
                                refreshDataSet('DS_USUAL');
                            });
                        }
                    });
                }
            };
            Form.findNext = function() {
                executeAction('findRecord', function(){
                    if (empty(getVar('DIRECTION_SERVICE'))) {
                        showAlert('В данный момент пациентов в очереди нет');
                        return;
					}
					executeAction('invitePatientToCab', function(){
                        setControlProperty('Grid', 'locate', getVar('DIRECTION_SERVICE'));
					    refreshDataSet('DS_USUAL');
						setVar('DIRECTION_SERVICE', null);
					});
				});
			};
			Form.setNejavka = function() {
				if(+getVar('CheckTAP') === 1) {
					setVar('PMC_ID', getControlProperty('Grid', 'data')['PATIENT_ID']);
					executeAction('checkTAP', function() {
						if(+getVar('AMP_TALON') > 0) {
							if(confirm('Вы хотите закрыть амбулаторный талон?')) {
								openD3Form('Directions/close_tap', true, {
									height: 250,
									width: 350,
									vars: {
										PMC_ID: getVar('PMC_ID')
									},
									onclose: function (mod) {
										if (mod) {
											setNejavka();
										}
									}
								});
							} else {
								setNejavka();
							}
						} else {
							setNejavka();
						}
					});
				} else {
					setNejavka();
				}
				function setNejavka() {
					executeAction('setNejavka', null,null,null,0,0);
					refreshDataSet('DS_USUAL');
				};
			};
			Form.setJavka = function() {
				alert('Внимание! Если при проставлении неявки был закрыт ТАП, то данный ТАП открыт не будет, необходимо вносить данные в ТАП вручную.');
				executeAction('setJavka',null,null,null,0,0);
				refreshDataSet('DS_USUAL');
			};
			
			
			Form.enterBarcode = function() {
			base().ClearFilter();
			clearControl('fPATIENT_ID');
			_setFocus(getControlByName('fPATIENT_ID'));
		};
			]]>
			
			
			
			
		</component>
        <component cmptype="Action" name="delOuterDir">
            <![CDATA[
            declare
                nDIR_ID             NUMBER;
                nAMB_TALON_ID       NUMBER;
            begin
                begin
                    select ds.PID  as DIR_ID,
                           atv.PID as AMB_TALON_ID
                      into nDIR_ID,
                           nAMB_TALON_ID
                      from D_V_DIRECTION_SERVICES ds
                           left join D_V_VISITS v on v.PID = ds.ID
                                left join D_V_AMB_TALON_VISITS atv on atv.VISIT = v.ID
                     where ds.ID = :DS_ID;
                end;

                D_PKG_DIRECTIONS.SET_OUTER_DIRECTION(pnID              => nDIR_ID,
                                                     pnLPU             => :LPU,
                                                     pnOUTER_DIRECTION => null);

                if nAMB_TALON_ID is not null then
                    D_PKG_AMB_TALONS.SET_DIRECT_DATA(pnID                => nAMB_TALON_ID,
                                                     pnLPU               => :LPU,
                                                     psDIRECT_NUMB       => null,
                                                     pdDIRECT_DATE       => null,
                                                     pnDIRECT_LPU        => null,
                                                     pnDIRECT_SPECIALITY => null);
                end if;
            end;
            ]]>
            <component cmptype="ActionVar" name="LPU"       src="LPU"       srctype="session"/>
            <component cmptype="ActionVar" name="DS_ID"     src="Grid"      srctype="ctrl"  get="gDS_ID"/>
        </component>
        <component cmptype="Action" name="checkIsAmbTalonInReestr">
            <![CDATA[
            begin
                select D_PKG_REESTRSP.CHECK_FOR_ACT(t2.REESTRSP, t2.LPU)
                  into :REESTRSP_CHECK
                  from D_V_VISITS t
                       join D_V_AMB_TALON_VISITS t2 on t2.VISIT = t.ID
                            join D_V_AMB_TALONS t3 on t3.ID = t2.PID
                 where t.PID = :DS_ID;
            exception when OTHERS then
                :REESTRSP_CHECK := 1;
            end;
            ]]>
            <component cmptype="ActionVar" name="DS_ID"             src="Grid"              srctype="ctrl"  get="gDS_ID"/>
            <component cmptype="ActionVar" name="REESTRSP_CHECK"    src="REESTRSP_CHECK"    srctype="var"   put="pREESTRSP_CHECK" len="17"/>
        </component>
        <component cmptype="Action" name="SET_NURSE_DEFAULT">
            <![CDATA[
                begin
                    d_pkg_emp_cablabs.set_nurse_default(pnid => :pnid,
                                                        pnlpu => :pnlpu,
                                                        pnnurse_default => :pnnurse_default);
                end;
            ]]>
            <component cmptype="ActionVar" name="pnid"   src="EMP_CABLABS_ID"           srctype="var" get="pnid"/>
            <component cmptype="ActionVar" name="pnlpu" src="LPU" srctype="session"/>
            <component cmptype="ActionVar" name="pnnurse_default" src="DEF_NURSE" srctype="ctrl" get="pnnurse_default"/>
        </component>
		<component cmptype="Script" name="SCRIPT_CANCEL_VISIT">
			<![CDATA[
				Form.cancelVisit = function () {
					setVar('SYS_VISIT_ID', getControlProperty('Grid', 'data')['VISIT']);
					executeAction('cancelVisit', function () {
						if (!empty(getVar("CC_MESSAGE"))){
							alert(getVar("CC_MESSAGE"));
						};
						refreshDataSet('DS_USUAL');
					});
				}
			]]>
		</component>
		<component cmptype="Script" name="PrintContract">
			<![CDATA[
				Form.PrintContract=function(){
					setVar('REP_ID', getValue('Grid'));
					executeAction('GetTrueDSID', null, null, null, 0, 0);
					if(!empty(getVar('REPP_ID'))){
						setVar('REP_ID', getVar('REPP_ID'));
					}
					printReportByCode('reception_contract');
				}
			]]>
		</component>
		<component cmptype="Action" name="updDirComment">
			<![CDATA[
				begin
					D_PKG_DIRECTION_SERVICES.SET_COMMENT(pnID => :DS_ID,
														pnLPU => :LPU,
												  psS_COMMNET => :S_COMMNET);
				end;
			]]>
			<component cmptype="ActionVar" name="LPU"       src="LPU"       srctype="session"/>
			<component cmptype="ActionVar" name="DS_ID"     src="DS_ID"     srctype="var" get="gDS_ID"/>
			<component cmptype="ActionVar" name="S_COMMNET" src="S_COMMNET" srctype="var" get="gS_COMMNET"/>
		</component>

        <component cmptype="Action" name="delDraft">
            <![CDATA[
            begin
                D_PKG_DIRECTION_SERVICES.SET_NURSE_USER_TEMPLATES(pnID => :SYS_DIR_SERVICE,
                                                                  pnLPU => :LPU,
                                                                  pnNURSE_USER_TEMPLATES => null);
            end;
            ]]>
            <component cmptype="ActionVar" name="LPU"               src="LPU"               srctype="session"/>
            <component cmptype="ActionVar" name="SYS_DIR_SERVICE"   src="SYS_DIR_SERVICE"   srctype="var" get="gSYS_DIR_SERVICE"/>
            <component cmptype="ActionVar" name="VUT_ID"            src="VUT_ID"            srctype="var" get="gVUT_ID"/>
        </component>

        <component cmptype="Action" name="getDataBeforeFillVUT">
            <![CDATA[
            begin
                :VUT_TEMPLATE_ID := D_PKG_VISITS.GET_TEMPLATE_INFO(fnLPU => :LPU,
                                                                   fnID => :SYS_DIR_SERVICE,
                                                                   fsUNITCODE => 'DIRECTION_SERVICES',
                                                                   fnWHAT => 0);
                :VUT_TEMPLATE_NAME := D_PKG_VIS_USER_TEMPLATES.GET_DRAFT_NAME(:LPU);
            end;
            ]]>
            <component cmptype="ActionVar" name="LPU"               src="LPU"               srctype="session"/>
            <component cmptype="ActionVar" name="SYS_DIR_SERVICE"   src="SYS_DIR_SERVICE"   srctype="var" get="gSYS_DIR_SERVICE"/>
            <component cmptype="ActionVar" name="VUT_TEMPLATE_ID"   src="VUT_TEMPLATE_ID"   srctype="var" put="pVUT_TEMPLATE_ID" len="17"/>
            <component cmptype="ActionVar" name="VUT_TEMPLATE_NAME" src="VUT_TEMPLATE_NAME" srctype="var" put="pVUT_TEMPLATE_NAME" len="100"/>
        </component>

        <component cmptype="Action" name="getVUTData">
            <![CDATA[
            begin
                select t.VISIT_TEMP,
                       t.TEMPL_NAME
                  into :VUT_TEMPLATE_ID,
                       :VUT_TEMPLATE_NAME
                  from D_V_VIS_USER_TEMPLATES t
                 where t.ID = :VUT_ID;
            exception when NO_DATA_FOUND then
                null;
            end;
            ]]>
            <component cmptype="ActionVar" name="VUT_ID"            src="VUT_ID"            srctype="var" get="gVUT_ID"/>
            <component cmptype="ActionVar" name="VUT_TEMPLATE_ID"   src="VUT_TEMPLATE_ID"   srctype="var" put="pVUT_TEMPLATE_ID" len="17"/>
            <component cmptype="ActionVar" name="VUT_TEMPLATE_NAME" src="VUT_TEMPLATE_NAME" srctype="var" put="pVUT_TEMPLATE_NAME" len="100"/>
        </component>

		<component cmptype="Action" name="getGenRegData">
			declare
				nREC_TYPE   NUMBER(1);
			begin
				:DS_REC_TYPE := null;
				:HAS_OWN_SCH := null;
				:CLSCH_TYPE := null;
				:TIME_TYPE := null;
				select t.CABLAB_TO_ID,
					   1 - t.REG_TYPE,
					   t.EMPLOYER_TO,
					   t.SERVICE_ID,
					   to_char(t.REC_DATE,'dd.mm.yyyy hh24:mi'),
					   t.REC_TYPE,
					   t.REC_DURATION,
					   t.TICKET_N,
					   t2.REG_TYPE
				  into :CAB_ID,
					   :IS_CITO,
					   :EMP_ID,
					   :SERV_ID,
					   :REC_DATE,
					   nREC_TYPE,
					   :REC_DURATION,
					   :NORDER,
					   :DIR_REG_TYPE
				  from D_V_DIRECTION_SERVICES t,
					   D_V_DIRECTIONS t2
				 where t.ID  = :RES_ID
				   and t.LPU = :LPU
				   and t.PID = t2.ID;
				d_pkg_clschs_tools.get_info(pnlpu => :LPU,
								         pncablab => :CAB_ID,
								        pnservice => :SERV_ID,
								       pnemployer => :EMP_ID,
								       pnrec_type => nREC_TYPE,
								        pnis_cito => :IS_CITO,
								       pdrec_date => to_date(:REC_DATE, 'dd.mm.yyyy hh24:mi'),
								    pnds_rec_type => :DS_REC_TYPE,
								  pnhas_own_sched => :HAS_OWN_SCH,
								     pnclsch_type => :CLSCH_TYPE,
								      pntime_type => :TIME_TYPE);
			end;
			<component cmptype="ActionVar" name="LPU"            src="LPU"                 srctype="session"/>
			<component cmptype="ActionVar" name="RES_ID"         src="Grid"                srctype="ctrl" get="v1"/>
			<component cmptype="ActionVar" name="CAB_ID"         src="ACTION_CAB_ID"       srctype="var"  put="v2" len="17"/>
			<component cmptype="ActionVar" name="SERV_ID"        src="ACTION_SERV_ID"      srctype="var"  put="v3" len="17"/>
			<component cmptype="ActionVar" name="EMP_ID"         src="ACTION_EMP_ID"       srctype="var"  put="v4" len="17"/>
			<component cmptype="ActionVar" name="DS_REC_TYPE"    src="ACTION_DS_REC_TYPE"  srctype="var"  put="v5" len="2"/>
			<component cmptype="ActionVar" name="REC_DATE"       src="ACTION_DS_REC_DATE"  srctype="var"  put="v6" len="25"/>
			<component cmptype="ActionVar" name="HAS_OWN_SCH"    src="ACTION_HAS_OWN_SCH"  srctype="var"  put="v7" len="2"/>
			<component cmptype="ActionVar" name="CLSCH_TYPE"     src="ACTION_CLSCH_TYPE"   srctype="var"  put="v8" len="5"/>
			<component cmptype="ActionVar" name="TIME_TYPE"      src="ACTION_TIME_TYPE"    srctype="var"  put="v9" len="17"/>
			<component cmptype="ActionVar" name="REC_DURATION"   src="ACTION_DURATION"     srctype="var"  put="v10" len="17"/>
			<component cmptype="ActionVar" name="IS_CITO"        src="ACTION_IS_CITO"      srctype="var"  put="v11" len="2"/>
			<component cmptype="ActionVar" name="NORDER"         src="ACTION_NORDER"       srctype="var"  put="v12" len="15"/>
			<component cmptype="ActionVar" name="DIR_REG_TYPE"   src="ACTION_DIR_REG_TYPE" srctype="var"  put="v13" len="5"/>
		</component>
		<component cmptype="Action" name="findSchedule">
			begin
				D_PKG_CLSCHS_TOOLS.FIND_CLSCHS_INFO (pnLPU => :LPU,
						                          pnCABLAB => :CAB_ID,
						                        pnEMPLOYER => :EMP_ID,
						                        pdREC_DATE => :REC_DATE,
						                         pnSCH_RES => :SCH_RES,
						                        pnREC_TYPE => :DS_REC_TYPE,
						                         pnIS_CITO => :IS_CITO,
						                   pnHAS_OWN_SCHED => :HAS_OWN_SCHED,
						                         pnSERVICE => :SERV_ID,
						                           pnORDER => :NORDER,
			                                  pnCLSCH_TYPE => :CLSCH_TYPE);
				if :SCH_RES = 2 then
					select d_stragg(c.CL_NAME)
					  into :CAB_LIST
					  from D_V_CABLAB c
					 where (c.ID = :CAB_ID or c.PID = :CAB_ID)
					   and c.LPU = :LPU;
				end if;
			end;
			<component cmptype="ActionVar" name="LPU"            src="LPU"             srctype="session"/>
			<component cmptype="ActionVar" name="CAB_ID"         src="CAB_ID"          srctype="var"  get="v1"/>
			<component cmptype="ActionVar" name="EMP_ID"         src="EMP_ID"          srctype="var"  get="v2"/>
			<component cmptype="ActionVar" name="REC_DATE"       src="GoDateEdit"      srctype="ctrl" get="v3"/>
			<!-- out -->
			<component cmptype="ActionVar" name="SCH_RES"        src="SCH_RES"         srctype="var"  put="v4"  len="1"/>
			<component cmptype="ActionVar" name="DS_REC_TYPE"    src="DS_REC_TYPE"     srctype="var"  put="v5"  len="1"/>
			<component cmptype="ActionVar" name="IS_CITO"        src="IS_CITO"         srctype="var"  put="v6"  len="1"/>
			<component cmptype="ActionVar" name="HAS_OWN_SCHED"  src="HAS_OWN_SCHED"   srctype="var"  put="v7"  len="1"/>
			<component cmptype="ActionVar" name="SERV_ID"        src="SERV_ID"         srctype="var"  put="v8"  len="17"/>
			<component cmptype="ActionVar" name="NORDER"         src="NORDER"          srctype="var"  put="v9"  len="5"/>
			<component cmptype="ActionVar" name="CLSCH_TYPE"     src="CLSCH_TYPE"      srctype="var"  put="v10" len="5"/>
			<component cmptype="ActionVar" name="CAB_LIST"       src="CAB_LIST"        srctype="var"  put="v11" len="4000"/>
		</component>
		<component cmptype="Action" name="getEmpCabGenReg">
			<![CDATA[
			begin
				:EMP_ID := D_PKG_EMPLOYERS.GET_ID(:LPU);
				:LPU_ID := :LPU;
				select t.ID,
					   t.CL_NAME
				  into :CAB_ID,
					   :CAB_NAME
				  from D_V_CABLAB t
				 where t.ID = :CABLAB;
			exception when NO_DATA_FOUND then
				D_P_EXC('Для записи в регистратуру необходимо зайти в рабочий кабинет.');
			end;
			]]>
			<component cmptype="ActionVar" name="LPU"       src="LPU"      srctype="session"/>
			<component cmptype="ActionVar" name="CABLAB"    src="CABLAB"   srctype="session"/>
			<!-- out -->
			<component cmptype="ActionVar" name="LPU_ID"    src="LPU_ID"   srctype="var"  put="v1" len="17"/>
			<component cmptype="ActionVar" name="EMP_ID"    src="EMP_ID"   srctype="var"  put="v2" len="17"/>
			<component cmptype="ActionVar" name="CAB_ID"    src="CAB_ID"   srctype="var"  put="v3" len="17"/>
			<component cmptype="ActionVar" name="CAB_NAME"  src="CAB_NAME" srctype="var"  put="v4" len="160"/>
		</component>
		<component cmptype="Action" name="checkDirCancel">
			begin
				SELECT case when t4.id is null and t3.is_canceled = 1 and t.is_canceled = 1
								 and t.canc_reason_id is not null and t3.canc_reason_id is not null then 1 else 0
			           end
				  INTO :IS_DIR_CANCELED
				  FROM d_v_directions t,
					   d_v_outer_directions t2,
					   d_v_directions t3,
					   d_v_hpk_plan_journals t4
				 WHERE t.ID = (SELECT s.ID
							    FROM (SELECT t.ID
									    FROM d_v_directions t
									   WHERE t.REG_VISIT_ID = :VISIT_ID
									     AND t.DIR_TYPE = 1
								    ORDER BY t.REG_DATE DESC) s
							  WHERE ROWNUM = 1)
				   AND t2.represent_direction = t.ID
				   AND t3.outer_direction_id = t2.ID
				   AND t4.direction(+) = t3.ID;
		exception when others then
					:IS_DIR_CANCELED := null;
			end;
			<component cmptype="ActionVar" name="VISIT_ID"        src="VISIT_ID"        srctype="var" get="g0"/>
			<component cmptype="ActionVar" name="IS_DIR_CANCELED" src="IS_DIR_CANCELED" srctype="var" put="p0" len="1"/>
		</component>
		<component cmptype="Action" name="reverseCancelHosp">
			begin
				d_pkg_directions.set_canceled(pnID => :HOSP_DIR,
											 pnLPU => :LPU,
									 pnIS_CANCELED => 0,
									 pnCANC_REASON => null,
								   pnCANC_EMPLOYER => null,
									   pdCANC_DATE => null);
			end;
			<component cmptype="ActionVar" name="HOSP_DIR" src="HOSP_DIR"     srctype="var" get="g0"/>
			<component cmptype="ActionVar" name="LPU"      src="HOSP_DIR_LPU" srctype="var" get="g1"/>
		</component>
		<component cmptype="Action" name="getHospDirData">
			begin
				SELECT t4.id,
					   t.IS_CANCELED,
					   t4.hosp_history,
					   t3.dir_pref || ' - ' || t3.dir_numb
			 	  INTO :OUTER_HPK_ID,
					   :IS_CANCELED,
					   :OUTER_HOSP_HISTORY,
					   :OUTER_DIR_NUMB
				  FROM d_v_directions t,
					   d_v_outer_directions t2,
					   d_v_directions t3,
					   d_v_hpk_plan_journals t4
				 WHERE t.ID = (SELECT s.ID
							    FROM (SELECT t.ID
									    FROM d_v_directions t
									   WHERE t.REG_VISIT_ID = :VISIT_ID
									     AND t.DIR_TYPE = 1
									ORDER BY t.REG_DATE DESC) s
							   WHERE ROWNUM = 1)
				   AND t2.represent_direction = t.ID
				   AND t3.outer_direction_id = t2.ID
				   AND t4.direction(+) = t3.ID
				   AND ROWNUM = 1;
	    exception when no_data_found then
					:OUTER_HPK_ID := null;
					:IS_CANCELED := null;
					:OUTER_HOSP_HISTORY := null;
					:OUTER_DIR_NUMB := null;
			end;
			<component cmptype="ActionVar" name="VISIT_ID"           src="VISIT_ID1"          srctype="var" get="g0"/>
			<component cmptype="ActionVar" name="OUTER_HPK_ID"       src="OUTER_HPK_ID"       srctype="var" put="p0" len="17"/>
			<component cmptype="ActionVar" name="IS_CANCELED"        src="IS_CANCELED"        srctype="var" put="p1" len="1"/>
			<component cmptype="ActionVar" name="OUTER_HOSP_HISTORY" src="OUTER_HOSP_HISTORY" srctype="var" put="p2" len="17"/>
			<component cmptype="ActionVar" name="OUTER_DIR_NUMB"     src="OUTER_DIR_NUMB"     srctype="var" put="p3" len="100"/>
		</component>
		<component cmptype="Action" name="DelHospAction" unit="DIRECTIONS" action="DELETE">
			<component cmptype="ActionVar" name="pnLPU" src="LPU" srctype="session"/>
			<component cmptype="ActionVar" name="~pnID" src="HospDir" srctype="var" get="v1"/>
		</component>
		<component cmptype="Action" name="FullDelHospAction">
			declare TYPE sARR   is table of varchar2(100) index by binary_integer;
				nLPU_DS 		NUMBER(17);
				nOUTER_DIR 		NUMBER(17);
				nTHEIR_DIR 		NUMBER(17);
				cDIR_ARRAY      sARR;
				sDIR_LIST       VARCHAR2(4000);
				sVALUE        	D_PKG_STD.tSTR;
				nI              NUMBER(3) := 1;
			begin
				if :pnID_LIST is not null then
					sDIR_LIST := :pnID_LIST;
					loop
						if sDIR_LIST is null then
							exit;
			            end if;
						D_PKG_STR_TOOLS.ARRSTR_GET(sDIR_LIST,';',sVALUE);
						cDIR_ARRAY(nI) := sVALUE;
						nI := nI + 1;
					end loop;
					for i in cDIR_ARRAY.First..cDIR_ARRAY.Last
					loop
						begin
							select t.ID,
								   t1.ID,
								   t1.LPU
							  into nOUTER_DIR,
								   nTHEIR_DIR,
								   nLPU_DS
							  from D_V_OUTER_DIRECTIONS t,
								   D_V_DIRECTIONS t1
							 where t.REPRESENT_DIRECTION = cDIR_ARRAY(i)
							   and t1.OUTER_DIRECTION_ID = t.ID;
					exception when NO_DATA_FOUND then
							nTHEIR_DIR := null;
						end;
						-- наше ЛПУ
						D_PKG_DIRECTIONS.DEL(cDIR_ARRAY(i),:pnLPU);
						-- не наше ЛПУ
						if nTHEIR_DIR is not null then
							d_pkg_directions.del(nTHEIR_DIR,nLPU_DS);
							d_pkg_outer_directions.del(nOUTER_DIR,nLPU_DS);
						end if;
					end loop;
				end if;
			end;
			<component cmptype="ActionVar" name="pnLPU"	    src="LPU"      srctype="session"/>
			<component cmptype="ActionVar" name="pnID_LIST" src="HospDir"  srctype="var" get="v1"/>
		</component>
        <component cmptype="Action" name="invitePatientToCab">
			begin
				D_PKG_IB_CABGROUP_CABS.ADD_IB_INVITEES(coalesce(:DIRECTION_SERVICE, :DS));
				exception when others then
					null;
			end;
			<component cmptype="ActionVar" name="LPU" src="LPU"  srctype="session"/>
			<component cmptype="ActionVar" name="DS"  src="Grid" srctype="ctrl" get="v1"/>
			<component cmptype="ActionVar" name="DIRECTION_SERVICE" src="DIRECTION_SERVICE" srctype="var" get="gDIRECTION_SERVICE"/>
		</component>
		<component cmptype="Action" name="cancelInvitationPatToCab">
			begin
				 D_PKG_IB_CABGROUP_CABS.DEL_IB_INVITEES(:DS);
				exception when others then
					null;
			end;
			<component cmptype="ActionVar" name="LPU" src="LPU"  srctype="session"/>
			<component cmptype="ActionVar" name="DS"  src="Grid" srctype="ctrl" get="v1"/>
		</component>
		<component cmptype="Action" name="tryFindApps" mode="Post">
			begin
				select d_stragg(c.CL_NAME)
				  into :APP_NAMES
				  from d_v_schedule_tree t,
					   d_v_cablab c
				 where t.PID = :CAB_ID and t.R_TYPE = 2
			       and c.ID = t.ID;
				IF :APP_NAMES is not null AND :CAB_NAME is not null THEN
					:APP_NAMES := :APP_NAMES||';'||:CAB_NAME;
				END IF;
				exception when no_data_found then
					:APP_NAMES := null;
			end;
			<component cmptype="ActionVar" name="CAB_ID"    src="CABLAB"    srctype="session"/>
			<component cmptype="ActionVar" name="CAB_NAME"  src="CAB_NAME"  srctype="var" get="C_N" />
			<component cmptype="ActionVar" name="APP_NAMES" src="APP_NAMES" srctype="var" put="var" len="1000"/>
		</component>
		<component cmptype="Action" name="checkRegionAndOptionForRecipes">
			begin
				:ALLOW_RECIPE_OPT := d_pkg_option_specs.get('CheckOpenHH', :LPU);
				select count(1)
				  into :COUNT_HHS
				  from D_V_HOSP_HISTORIES t
				 where t.DISEASECASE = :DISCASE_CHECK
				   and t.LPU         = :LPU
				   and t.DATE_OUT is null
				   and rownum        = 1;
			end;
			<component cmptype="ActionVar" name="LPU"              src="LPU"              srctype="session"/>
			<component cmptype="ActionVar" name="DISCASE_CHECK"    src="DISCASE_CHECK"    srctype="var" get="v2"/>
			<component cmptype="ActionVar" name="ALLOW_RECIPE_OPT" src="ALLOW_RECIPE_OPT" srctype="var" put="ARO" len="2"/>
			<component cmptype="ActionVar" name="COUNT_HHS"        src="COUNT_HHS"        srctype="var" put="CHHS" len="2"/>
		</component>
		<component cmptype="Action" name="getHospDirId">
			begin
				select s.ID
			      into :ID
			      from (select t.ID
				          from d_v_directions t
				         where t.REG_VISIT_ID = :VISIT_ID
			               and t.DIR_TYPE = 1
					  order by t.REG_DATE desc) s
		         where rownum = 1;
		exception when no_data_found then
					:ID := null;
			end;
			<component cmptype="ActionVar" name="VISIT_ID" src="VISIT_ID1"    get="v1"          srctype="var"/>
			<component cmptype="ActionVar" name="ID"       src="DIRECTION_ID" put="v2" len="17" srctype="var"/>
		</component>
		<component cmptype="Action" name="AddDirection">
			begin
				begin
					select t2.ID
					  into :SERVICES_ID
					  from d_v_services t2
					 where t2.SE_CODE = :HELP_SERVICE_CODE
					   and t2.VERSION = d_pkg_versions.get_version_by_lpu(1,:LPU,'SERVICES');
			exception when no_data_found then D_P_EXC('Не найдена услуга с кодом "'||:HELP_SERVICE_CODE||'". Проверьте значение константы "ServVipiska".');
				end;
				begin
					d_pkg_direction_services.create_fast_direction(pnlpu => :LPU,
													           pnpatient => :P_ID,
													       pndiseasecase => :DC_ID,
													           pnservice => :SERVICES_ID,
													          pndir_serv => :OUT_DIR_SERV);
				end;
				end;
			<component cmptype="ActionVar" name="OUT_DIR_SERV"      src="NewIDD"      srctype="var" put="v0v" len="17"/>
			<component cmptype="ActionVar" name="LPU"               src="LPU"         srctype="session"/>
			<component cmptype="ActionVar" name="SERVICES_ID"       src="SERVICES_ID" srctype="var" put="v2"  len="17"/>
			<component cmptype="ActionVar" name="HELP_SERVICE_CODE" src="PARAM_CODE"  srctype="var" get="vr4"/>
			<component cmptype="ActionVar" name="DC_ID"             src="DISCAS_ID"   srctype="var" get="DC_ID"/>
			<component cmptype="ActionVar" name="P_ID"              src="PERSMC_ID"   srctype="var" get="P_ID"/>
		</component>
		<component cmptype="Action" name="TryFindIdDirServ">
			declare
				nSERV NUMBER(17);
				rDATE date;
			begin
				if :HELP_SERVICE_CODE is null then
					D_P_EXC('Проверьте настройку константы с кодом "ServVipiska"');
				end if;
				begin
					select t.ID
					  into nSERV
					  from D_V_SERVICES t
					 where t.SE_CODE = :HELP_SERVICE_CODE
					   and t.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(1,:LPU,'SERVICES');
			exception when no_data_found then
					D_P_EXC('Не найдена услуга с кодом "'||:HELP_SERVICE_CODE||'". Проверьте значение константы "ServVipiska".');
				end;
				begin
					 select f.DS_ID,
			                v.ID,
			                f.REC_DATE,
			                v.VISIT_TEMPLATE
					   into :NEW_DS,
			                :NEW_VIS,
			                rDATE,
			                :TEMPLATE_ID
					   from (select ds.ID DS_ID,
									ds.REC_DATE
							   from D_V_DIRECTION_SERVICES_BASE ds
							  where ds.ID != :DIR_SERVICE
								and ds.DISEASECASE = :DISEASECASE_ID
								and ds.HID is null
								and ds.SERVICE = nSERV
								and ds.REG_TYPE != 3
								and ds.SERV_STATUS != 3
						  union
							 select ds.ID DS_ID,
									ds.REC_DATE
							   from D_V_DIRECTION_SERVICES_BASE ds
							  where ds.ID != :DIR_SERVICE
								and ds.PID = :DIRECTION_ID
								and ds.HID is null
								and ds.SERVICE = nSERV
								and ds.REG_TYPE != 3
								and ds.SERV_STATUS != 3
						  union
							 select ds.ID DS_ID,
									ds.REC_DATE
							   from D_V_DIRECTION_SERVICES_BASE ds
							  where ds.HID = :DIR_SERVICE
								and ds.SERVICE = nSERV
								and ds.REG_TYPE != 3
								and ds.SERV_STATUS != 3
							) f
							left join D_V_VISITS_BASE v on v.PID = f.DS_ID
					  where rownum = 1;
					if :TEMPLATE_ID is null then
						:TEMPLATE_ID := d_pkg_visits.get_template_info(fnLPU => :LPU,
														                fnID => :NEW_DS,
														          fsUNITCODE => 'DIRECTION_SERVICES',
														              fnWHAT => 0,
														              fdDATE => rDATE);
					end if;
		 exception when no_data_found then
					:NEW_DS := null;
					:NEW_VIS:= null;
					:TEMPLATE_ID := d_pkg_visits.get_template_info(fnLPU => :LPU,
																	fnID => nSERV,
															  fsUNITCODE => 'SERVICES',
																  fnWHAT => 0);
				end;
			end;
			<component cmptype="ActionVar" name="LPU"               src="LPU"         srctype="session"/>
			<component cmptype="ActionVar" name="DIR_SERVICE"       src="Grid"        srctype="ctrl" get="v1"/>
			<component cmptype="ActionVar" name="DIRECTION_ID"      src="DIRECT_ID"   srctype="var"  get="v2"/>
			<component cmptype="ActionVar" name="DISEASECASE_ID"    src="DISCAS_ID"   srctype="var"  get="v3"/>
			<component cmptype="ActionVar" name="HELP_SERVICE_CODE" src="PARAM_CODE"  srctype="var"  get="v4"/>
			<component cmptype="ActionVar" name="NEW_DS"            src="NewIDD"      srctype="var"  put="v5" len="17"/>
			<component cmptype="ActionVar" name="NEW_VIS"           src="NewVisIDD"   srctype="var"  put="v6" len="17"/>
			<component cmptype="ActionVar" name="TEMPLATE_ID"       src="TEMPLATE_ID" srctype="var"  put="v7" len="17"/>
		</component>
		<component cmptype="Action" name="DelDirDirServ">
			begin
				d_pkg_direction_services.del(pnid => :ID,
								            pnlpu => :LPU,
								        pndel_dir => 1);
			end;
			<component cmptype="ActionVar" name="ID"  src="Grid" srctype="ctrl" get="v1"/>
			<component cmptype="ActionVar" name="LPU" src="LPU"  srctype="session"/>
		</component>
		<component cmptype="Action" name="GetOneService">
			begin
				select t2.ALL_ID
				  into :ONE_SERV_ID
				  from table(cast(D_PKG_CLSCHS.get_week_es(:LPU, 1, to_date(:ddate,'dd.mm.YYYY'),null, null, :CAB_ID, null/*:EMP_ID*/, null, 2, null, null, null, null, null, null) as D_CL_WEEK_ES)) t2;
			end;
			<component cmptype="ActionVar" name="LPU"        	  src="LPU"        	  	srctype="session"/>
			<component cmptype="ActionVar" name="CAB_ID"     	  src="CAB_ID"   	  	srctype="var"   get="v0"/>
			<component cmptype="ActionVar" name="EMP_ID"     	  src="EMP_ID"    	  	srctype="var"   get="v1"/>
			<component cmptype="ActionVar" name="ddate"      	  src="GoDateEdit"    	srctype="ctrl"   get="v2"/>
			<component cmptype="ActionVar" name="ONE_SERV_ID"     src="ONE_SERV_ID"     srctype="var"   put="v3" len="17"/>
		</component>
		<component cmptype="Action" name="checkAvailabilityCabEmpReg">
			<![CDATA[
				declare
				  nDEF_SERVICE          D_PKG_STD.tREF;
				  nCNT                  INTEGER;
				  nREC_TYPE             INTEGER;
				  dDATE                 DATE;
				begin
				  dDATE := to_date(:DDATE,'dd.mm.yyyy');
				  :FAIL := 0;
				  select count(1)
					into nCNT
					from D_V_CLSCHS v
				   where v.LPU         = :LPU
					 and v.CABLAB_ID   = :CAB_ID
					 and v.DBEGIN      <= dDATE
					 and (v.DEND       >= trunc(dDATE) or v.DEND is null);
				  if nCNT > 0 then -- есть хотя бы один график
					:REC_TYPE := D_PKG_CLSCHS.GET_REC_TYPE(:LPU, :CAB_ID, null, :EMP_ID, dDATE, 0);
					if :REC_TYPE is null then -- нет графика врача
					  nDEF_SERVICE := D_PKG_CSE_ACCESSES.GET_ID_WITH_DEFAULT_RIGHTS(:LPU,'SERVICES',2,:CAB_ID);
					  nCNT         := 0;
					  for x in (select cl.SERVICE_ID,
									   D_PKG_CLSCHS.GET_REC_TYPE(:LPU, :CAB_ID, cl.SERVICE_ID, null, dDATE, 0) REC_TYPE
								  from D_V_CLSERVS cl
								 where cl.PID      = :CAB_ID
								   and cl.LPU      = :LPU
								order by case when cl.SERVICE_ID = nDEF_SERVICE then 1 else 0 end desc) loop -- x
						if x.REC_TYPE is not null then
						  nCNT := nCNT + 1;
						  :ONE_SERV_ID := x.SERVICE_ID;
						  :REC_TYPE    := x.REC_TYPE;
						  if nREC_TYPE is null then
							nREC_TYPE := x.REC_TYPE;
						  else
							if nREC_TYPE != x.REC_TYPE then
							  :REC_TYPE := null;
							end if;
						  end if;
						  if nDEF_SERVICE = x.SERVICE_ID then
							exit;
						  end if;
						end if;
					  end loop; -- x
					  if nCNT > 1 then
						:ONE_SERV_ID := null;
					  elsif nCNT = 0 then
						:FAIL := 1;
					  end if;
					end if;
				  else
					:FAIL := 1;
				  end if;
				  if :FAIL = 1 then
					begin
					  select 2
						into :FAIL
						from D_V_CABLAB g
					   where g.LPU   = :LPU
						 and g.PID   = :CAB_ID
						 and rownum  = 1;
					exception when NO_DATA_FOUND then :FAIL := 1;
					end;
				  end if;
				end;
			]]>
			<component cmptype="ActionVar" name="LPU"         src="LPU"         srctype="session"/>
			<component cmptype="ActionVar" name="DDATE"       src="GoDateEdit"  srctype="ctrl" get="v0"/>
			<component cmptype="ActionVar" name="CAB_ID"      src="CAB_ID"      srctype="var" get="v1"/>
			<component cmptype="ActionVar" name="EMP_ID"      src="EMP_ID"      srctype="var" get="v2"/>

			<component cmptype="ActionVar" name="REC_TYPE"    src="nREG_TYPE"   srctype="var" put="REG_TYPE"    len="2"/>
			<component cmptype="ActionVar" name="FAIL"        src="FAIL"        srctype="var" put="FAIL"        len="17"/>
			<component cmptype="ActionVar" name="ONE_SERV_ID" src="ONE_SERV_ID" srctype="var" put="ONE_SERV_ID" len="17"/>
		</component>
		<component cmptype="Action" name="CheckCountsEmpsCabs">
			<![CDATA[
			begin
				select count(1)
				  into :COUNT_ALL
				  from table(cast(D_PKG_CLSCHS.get_week_es(:LPU, 2, to_date(:ddate,'dd.mm.YYYY'), null, null, :CAB_ID, null, null, 2, null, null, null, null, null, null) as D_CL_WEEK_ES)) t;

				IF (:COUNT_ALL <> 0) THEN
					select count(1)
					  into :COUNT_THIS_EMP
					  from table(cast(D_PKG_CLSCHS.get_week_es(:LPU, 0, to_date(:ddate,'dd.mm.YYYY'), null, null, :CAB_ID, :EMP_ID, null, 2, null, null, null, null, null, null) as D_CL_WEEK_ES)) t3;

					IF (:COUNT_THIS_EMP <> 1) THEN
						select count(1)
						  into :COUNT_SERVS
						  from table(cast(D_PKG_CLSCHS.get_week_es(:LPU, 1, to_date(:ddate,'dd.mm.YYYY'),null, null, :CAB_ID, null/*:EMP_ID*/, null, 2, null, null, null, null, null, null) as D_CL_WEEK_ES)) t2;

						IF (:COUNT_SERVS <> 1) THEN
							:DEF_SERV_ID := d_pkg_cse_accesses.get_id_with_default_rights(:LPU,'SERVICES',2,:CAB_ID);
							select count(1)
							  into :COUNT_SERV_CAB
							  from table(cast(D_PKG_CLSCHS.get_week_es(:LPU, 1, to_date(:ddate,'dd.mm.YYYY'),null, null, :CAB_ID, null, null, 2, null, null, null, null, null, null) as D_CL_WEEK_ES)) t2
							 where t2.ALL_ID = :DEF_SERV_ID;
						END IF;
					END IF;
				END IF;
			end;
			]]>
			<component cmptype="ActionVar" name="LPU"        	  src="LPU"             srctype="session"/>
			<component cmptype="ActionVar" name="CAB_ID"     	  src="CAB_ID"          srctype="var"   get="v0"/>
			<component cmptype="ActionVar" name="EMP_ID"     	  src="EMP_ID"          srctype="var"   get="v1"/>
			<component cmptype="ActionVar" name="ddate"      	  src="GoDateEdit"      srctype="ctrl"  get="v2"/>
			<component cmptype="ActionVar" name="COUNT_ALL"  	  src="COUNT_ALL"       srctype="var"   put="v3" len="17"/>
			<component cmptype="ActionVar" name="COUNT_SERV_CAB"  src="COUNT_SERV_CAB"  srctype="var"   put="v4" len="17"/>
			<component cmptype="ActionVar" name="COUNT_SERVS" 	  src="COUNT_SERVS"     srctype="var"   put="v5" len="17"/>
			<component cmptype="ActionVar" name="COUNT_THIS_EMP"  src="COUNT_THIS_EMP"  srctype="var"   put="v6" len="17"/>
			<component cmptype="ActionVar" name="DEF_SERV_ID"     src="DEF_SERV_ID"     srctype="var"   put="v7" len="17"/>
		</component>
		<component cmptype="Action" name="isShowDirServReport">
			<![CDATA[
			 begin
				-- проверка - показывать отчет с типом "Направление" или нет
				select 1
				  into :IS_SHOW
				  from d_v_vis_template_reports t
				 where t.PID = D_PKG_VISITS.GET_TEMPLATE_INFO(:LPU, :DIR_SERVICE, 'DIRECTION_SERVICES', 0, 1)
				   and t.REP_TYPE = 3
				   and rownum = 1;
				 exception when others then
					:IS_SHOW := 0;
			 end;
			]]>
			<component cmptype="ActionVar" name="LPU"         src="LPU"     srctype="session"/>
			<component cmptype="ActionVar" name="DIR_SERVICE" src="Grid"    srctype="ctrl" get="ds"/>
			<component cmptype="ActionVar" name="IS_SHOW"     src="IS_SHOW" srctype="var"  put="is_show" len="1"/>
		</component>
		<component cmptype="Action" name="GetTrueDSID" mode="post">
				BEGIN
				  select t.SERVICE_TYPE
				    into :SE_TYPE
				    from D_V_DIRECTION_SERVICES t
				   where t.ID = :DIR_SER;
				  IF :SE_TYPE = 1 THEN
					:HELP := D_PKG_DIRECTION_SERVICES.GET_LAST_PROC_DS(:DIR_SER, :PNLPU);
				  END IF;
				END;
			<component cmptype="ActionVar" name="PNLPU"   src="LPU"             srctype="session"/>
			<component cmptype="ActionVar" name="DIR_SER" src="REP_ID"          srctype="var" get="SERV_ID"/>
			<component cmptype="ActionVar" name="HELP"    src="REPP_ID"         srctype="var" put="v1"              len="17"/>
			<component cmptype="ActionVar" name="SE_TYPE" src="SE_TYPE_ID_TEST" srctype="var" put="SE_TYPE_ID_TEST" len="10"/>
		</component>

		<component cmptype="Action" name="checkTAP">
			<![CDATA[
				begin
					select count(*)
			          into :AMP_TALON
			          from D_V_AMB_TALONS
			         where PERSMEDCARD = :PMC_ID
			           and IS_CLOSE = 0;
				end;
			]]>
			<component cmptype="ActionVar" name="LPU" 		src="LPU" 		srctype="session"/>
			<component cmptype="ActionVar" name="PMC_ID" 	src="PMC_ID"  	srctype="var" get="g0"/>
			<component cmptype="ActionVar" name="AMP_TALON" src="AMP_TALON" srctype="var" put="p0" len="2"/>
		</component>
        <component cmptype="Action" name="setNejavka">
                    begin
                        d_pkg_direction_services.SET_STATUS(pnLPU => :LPU,
                                                             pnID => :DS,
                                                    pnSERV_STATUS => 2,
                                             psSERV_STATUS_REASON => 'Неявка');
                    end;
			<component cmptype="ActionVar" name="LPU" src="LPU"  srctype="session"/>
			<component cmptype="ActionVar" name="DS"  src="Grid" srctype="ctrl" get="v1"/>
		</component>

        <component cmptype="Action" name="setJavka">
            declare nisn number(1);
            begin

                select count(1)
                  into nisn
                  from d_v_direction_services ds
                 where ds.id=:DS
                   and ds.SERV_STATUS_REASON='Неявка';

                if nisn=1 then
					d_pkg_direction_services.SET_STATUS(pnLPU => :LPU,
                                                         pnID => :DS,
                                                pnSERV_STATUS => 0,
                                         psSERV_STATUS_REASON => null);
                else
					d_p_exc('Этот пациент отменен не из-за неявки!');
                end if;
            end;
            <component cmptype="ActionVar" name="LPU" src="LPU"  srctype="session"/>
            <component cmptype="ActionVar" name="DS"  src="Grid" srctype="ctrl" get="v1"/>
		</component>

		<component cmptype="Action" name="findRecord" compile="true">
			<![CDATA[
            begin
				select id
			      into :DIRECTION_SERVICE
				  from (select t.id
						  from D_V_DIRECTION_SERVICES t
							   join D_V_DIRECTIONS_BASE d on d.ID = t.PID
				@if(:QUEUING == 1) {
							   join D_V_IB_QUEUE q on q.DIRECTION_SERVICE = t.ID
				@}
						 where t.LPU = :LPU
						   and trunc(t.REC_DATE) = trunc(sysdate)
				@if(:QUEUING == 1) {
						   and t.ID = (select v.ID from(select t1.id
			                             from D_V_DIRECTION_SERVICES t1
                                              join D_V_IB_LIST il on il.DIR_SERV_ID = t1.ID
									          join D_V_IB_QUEUE q on q.DIRECTION_SERVICE =t1.ID
                                        where ((t1.CABLAB_TO_ID = :CABLAB and (t1.EMPLOYER_TO = :EMP_ID or t1.EMPLOYER_TO is null))
                                                or (t1.CABLAB_TO_ID is null and t1.EMPLOYER_TO = :EMP_ID)
                                                or exists (select null
													         from D_V_CABLAB_BASE cb
													        where cb.PID = :CABLAB
													          and cb.ID = t1.CABLAB_TO_ID))
                                          and t1.LPU = :LPU
                                          and trunc(t1.REC_DATE) = trunc(sysdate)
                                        order by t1.REC_DATE,
										 case when to_char(t1.REC_DATE, D_PKG_STD.FRM_T) = '00:00'
			                             then (select q.CREATE_DATE
                                                 from D_V_IB_QUEUE q1
                                                where q1.DIRECTION_SERVICE = il.DIR_SERV_ID
                                                  and q1.IS_RETURNED = 2
			                                    /*order by case when q1.IS_RETURNED = 2 then 0 else 1 end*/)
                                          end,
                                         case when to_char(t1.REC_DATE, D_PKG_STD.FRM_T) = '00:00'
			                             then (select q.CREATE_DATE
                                                 from D_V_IB_QUEUE q
                                                where q.DIRECTION_SERVICE = il.DIR_SERV_ID)
                                          end) v where rownum =1)
				@}
						   order by case when t.REG_TYPE = 0 then 0 else 1 end, t.REC_DATE, d.REG_DATE, t.ID)
				   where rownum = 1;
			exception when NO_DATA_FOUND then :DIRECTION_SERVICE := null;
            end;
			]]>
            <component cmptype="ActionVar" name="DIRECTION_SERVICE"  src="DIRECTION_SERVICE"    srctype="var"      put="DIRECTION_SERVICE" len="17"/>
            <component cmptype="ActionVar" name="LPU"                src="LPU"                  srctype="session"  get="LPU"/>
			<component cmptype="ActionVar" name="EMP_ID"             src="EMPLOYER"             srctype="session"  get="EMPLOYER"/>
			<component cmptype="ActionVar" name="CABLAB"             src="CABLAB"               srctype="session"  get="CABLAB"/>
			<component cmptype="ActionVar" name="QUEUING"            src="QUEUING"              srctype="var"      get="pQUEUING"/>
		</component>

        <table style="width:100%;height:100%;" class="box-sizing">
			<tr>
				<td>
        			<div class="blockBackground" style="width:100%;height:100%">
        				<div style="padding:5px;width:100%;" class="box-sizing-force">
							<table style="width:100%;">
								<tr>
									<td align="left">
										<component cmptype="Label" style="margin-right: 5px; text-align: right;color:#29518a; font-weight:bold; font-size: 16pt; display: block; float: left; white-space: nowrap;" caption="" name="SYS_DATE_LABLE" />
                                		<component cmptype="Button" type="small" icon="Icons/control_l" title="Назад" onclick="base().LastDate(event,this)"/>
                                		<component cmptype="Button" type="small" icon="Icons/control_r" title="Вперёд" onclick="base().NextDate(event,this)"/>
										<component cmptype="Label" caption="Мед. сестра"/>
										<component cmptype="UnitEdit" name="DEF_NURSE" unit="EMPLOYERS" composition="EMP_NURSES" width="120" addListener="base().changeDefNurse"/>
                                        <component cmptype="CheckBox" caption="Мед. сестра по умолчанию" name="NURSE_DEFAULT_CHECK" valuechecked="1" valueunchecked="0" onchange="base().setDefaultNurse();"/>
										</td>
							<td style="text-align:left">		
	<component cmptype="Label" caption="        Поиск по браслету"/>						
                        <component cmptype="Edit" name="fPATIENT_ID" onkeypress="onEnter(function(){base().enterBarcode()});"/>
                      	<!--<component cmptype="Button"  onclick="refreshDataSet('DS_USUAL');" caption="Искать баркод " style="width:86px"/> -->
							
                                    </td>
									<td style="text-align:right">
										<component cmptype="DateEdit" name="GoDateEdit" typeMask="date" emptyMask="true"/>
										<component cmptype="Button" name="ButtonGoDate" caption="Перейти к дате" onclick="base().goDate()"/>
        								<component cmptype="Button" name="ButtonMassWrite" caption="Массовая запись" onclick="base().openMassWrite()" style="display:none"/>
                                		<component cmptype="Edit" name="IS_WORKING_HERE" emptyMask="true" style="display: none;"/>
										<!--component cmptype="Button" name="EMERG_BUTTON" caption="Неотложка" onclick="base().goExtr();"/-->
										<!-- старое расписание возвращается обратной заменой закоментированного кода. пометка на всей форме @gen_reg -->
										<!-- @gen_reg from -->
										<!-- component cmptype="Button" name="REG_RECORD" caption="Записать" onclick="base().RegRecord()"/-->
										<component cmptype="Button" name="REG_RECORD" caption="Записать" onclick="base().genRegRecord(0);"/>

                						<component cmptype="MaskInspector" controls="GoDateEdit" effectControls="ButtonGoDate"/>
                                		<component cmptype="MaskInspector" controls="IS_WORKING_HERE;GoDateEdit" effectControls="REG_RECORD"/>
										<!-- @gen_reg to -->
									</td>
								</tr>
								<tr cmptype="bogus" name="TR_NEXT_PATIENT">
									<td colspan="2" style="text-align:right">
										<component cmptype="Button" name="NEXT_PATIENT" caption="Следующий" onclick="base().findNext();"/>
									</td>
								</tr>
        					</table>
        				</div>
       	 				<div cmptype="bogus" name="FILTR_ALL" style="display:none;padding:5px;" class="box-sizing">
                			<table class="form-table" style="width:100%">
                				<tbody>
                        			<tr>
                                		<td>
                                        	<component cmptype="Label" caption="Фамилия:"/>
                                		</td>
                                		<td style="padding-left:5pt">
                                        	<component cmptype="Label" caption="Услуга:"/>
                                		</td>
                                		<td style="padding-left:5pt">
                                        	<component cmptype="Label" caption="Статус услуги:"/>
                                		</td>
                                		<td style="padding-left:5pt">
                                        	<component cmptype="Label" caption="Вид оплаты:"/>
                                		</td>
                                		<td>
                                		</td>
                        			</tr>
                        			<tr>
                                		<td>
                                         	<component cmptype="Edit" name="FI_FIO_PATIENT" width="100%"/>
                                		</td>
                                		<td style="padding-left:5pt">
                                        	<component cmptype="ButtonEdit" width="100%" unit="tmp" name="FI_SE_CODE" buttononclick="base().SERV_CODE();" readonly ="true">
												<td style="width:20px;">
													<component cmptype="Button" type="micro" background="Icons/btn_erase" onclick="setValue('FI_SE_CODE',null);setCaption('FI_SE_CODE',null);" />
												</td>
                                        	</component>
                                		</td>
                                		<td style="padding-left:5pt">
                                        	<component cmptype="ComboBox" name="FI_SERV_STATUS" width="100%">
												 <component cmptype="ComboItem" value="" caption="Все"/>
												 <component cmptype="ComboItem" value="1" caption="Выполнена"/>
												 <component cmptype="ComboItem" value="0" caption="Не выполнена"/>
                                        	</component>
                                		</td>
                                		<td colspan="1" style="padding-left:5pt">
                                        	<component cmptype="UnitEdit" name="PAYMENT_KIND" unit="PAYMENT_KIND" composition="LIST" multisel="true" width="100%"/>
                                		</td>
                        			</tr>
                        			<tr>
                                		<td colspan="1">
                                        	<component cmptype="Label" caption="Оборудование:"/>
											<br/>
                                        	<component cmptype="ComboBox" name="CABLABS" width="100%">
                                                <component cmptype="ComboItem" value="" caption="Все"/>
                                                <component cmptype="ComboItem" datafield="ID" captionfield="CL_NAME" DataSet="DS_CABLABS" repeate="0"/>
                                        	</component>
                                		</td>
										<td colspan="1" style="padding-left:5pt">
											<component cmptype="Label" caption="Вид просмотра:"/>
											<br/>
											<component cmptype="ComboBox" name="VIEW_T" width="100%" onchange="base().VIEW_T_onChange();">
												<component cmptype="ComboItem" value="" caption="Стандартно"/>
												<component cmptype="ComboItem" datafield="PARAM" captionfield="CAPT" DataSet="DS_VIEW_T" repeate="0"/>
											</component>
										</td>
										<td colspan="1" style="padding-left:5pt">
											<component cmptype="Label" caption="Врач:"/><br/>
											<component cmptype="ComboBox" name="EMPL_CAB" width="100%">
												<component cmptype="ComboItem" value="" caption="Все"/>
												<component cmptype="ComboItem" datafield="ID" captionfield="FULLNAME" DataSet="DS_EMPL_CAB" repeate="0"/>
											</component>
										</td>
										<td align="left" valign="bottom" style="padding-left:5pt">
											<component cmptype="Button" name="ButtonOk" onclick="refreshDataSet('DS_USUAL');" caption="OK" style="width:86px"/>
											<component cmptype="Button" name="ButtonClear" onclick="base().ClearFilter();" caption="Очистить" style="width:86px"/>
										</td>
                        			</tr>
                				</tbody>
                			</table>
        				</div>

        				<component cmptype="Expander" control="FILTR_ALL" caption="Поиск"/>

        			</div>
        		</td>
        	</tr>
       		<tr>
        		<td style="width:100%;height:100%;padding-top:5px;">
        			<div class="blockBackground box-sizing" style="padding:5px;height:100%;">
        				<table style="width:100%;height:100%;">
							<tr>
								<td colspan="2" style="height:100%">
									<component cmptype="Grid"
											   onclone="base().onCloneMainData(this,_dataArray); /*base().direct_onCLone(this,_dataArray);*/"
											   style= "width:100%"
											   name="Grid"
											   dataset="DS_USUAL"
											   field="ID"
											   onchange=""
											   calc_height="parent"
											   afterrefresh="base().checkCLEmps();"
											   onpostclone="base().onPostCloneMarker(_clone,_dataArray);">
										<component cmptype="Column" caption = "Время" field="TIMER" sort="TIMER" sortorder="1" upper="true" width="50px" name="nTimer"/>
										<component cmptype="Column" caption = "Пациент" width="220px" upper="true" sort="PATIENT_FIO" sortorder="2" name="PATIENT_FIO_COL">
											<div class="column_btn">
												<img name="pat_img" cmptype="img" src="Icons/result" title="История заболеваний и результаты исследований" onclick="base().SHOWHIST();"/>
											</div>
											<component cmptype="HyperLink" name="PAT_LINK" captionfield="PATIENT_FIO" width="100px" datafield="PATIENT_ID" onclick="base().ADD_PERSMEDCARD(this);"/>
											<img name="pat_warn" cmptype="img" src="Images/img2/warning.png" style="display:none;vertical-align:middle;cursor:pointer;" onclick="base().showPatientWarnings();" title="Обратите внимание на аллергологический анамнез и сопутствующие заболевания!"/>
											<img name="has_disp" cmptype="img" src="Images/img2/warning2.png" style="display:none;vertical-align:middle;" title="Пациент стоит на диспансерном учете"/>
											<img name="pregn_warn" cmptype="img" src="Images/img2/warning3.png" style="vertical-align:middle;" title="Срок беременности пациентки больше допустимого периода"/>
											<img name="patalogy" cmptype="img" src="Images/warning/exclamation.png" style="display:none;vertical-align:middle;" title="Наличие патологии при обследовании"/>
											<img name="bed_img" cmptype="img" src="Icons/bed" title="Лежачий пациент" style="display:none;margin-bottomm:-5px;float:right;"/>
											<component cmptype="Image" name="pat_warn_FLG" src="Images/warning/warning_flg.png" style="display:none;vertical-align:middle;" title="Обратите внимание на просроченную ФЛГ!"/>
											<component cmptype="Image" name="patalogy_flg" src="Images/warning/exclamation.png" style="display:none;vertical-align:middle;" title="Наличие патологии при флюорографии"/>
											<component cmptype="Image" name="risar_ok"     src="Images/img2/ok-confirm.png"      style="display:none;vertical-align:middle;" title="Осмотр успешно передан в Барс.МР"/>
											<component cmptype="Image" name="risar_bad"    src="Images/warning/warning3.png"    style="display:none;vertical-align:middle;" />
										</component>
										<component cmptype="Column" caption="" name="colSignalInfo" style="width: 0px; white-space: nowrap;">
											<component cmptype="Label" captionfield="SI_ICON"/>
										</component>
										<component cmptype="Column" field='MARKER' caption="Маркер" width="30px" style="padding:0;vertical-align:top;" profile_hidden="true" name="nMarcer">
											<component cmptype="SubForm" path="Markers/subforms/subforms_markers"/>
										</component>
										<component cmptype="Column" width="110px" sort="HYPERLINK" name="nHyperlink">
											<component cmptype="HyperLink" captionfield="HYPERLINK" datafield="ID" onclick="base().ADD_VISITS(this);"/>
											<component cmptype="Label" captionfield="HYP_LABEL"/>
										</component>
										<component cmptype="Column" caption="" field="TOTAL" sort="TOTAL" hint="TOTAL_HINT" name="nTotal"/>
                                        <component cmptype="Column" caption="C" field="IS_STAC" sort="IS_STAC" hint="IS_STAC_HINT" name="nC"/>
          								<component cmptype="Column" name="iconsColumn">
              								<img cmptype="HyperLink" name="commentButton" src="Images/Icons/PopUpMenu/blue-document.png" title="Комментарий" style="cursor:pointer;" onclick="base().updDirComment(this);"/>
          								</component>
										<component cmptype="Column" style="padding-left:5px;padding-right:5px;" name="nPaid">
											<component cmptype="Label" captionfield="PAID" style="color:red;" name="L_PAID"/>
										</component>
										<component cmptype="Column" width="20px" field="ALOMS_PAY_HAS_ERROR" name="ALOMS_PAY_ERR_COL">
											<img name="error_img" cmptype="HyperLink" src="" title="Ошибки в карте пациента, задолженности, запись утеряна" style="cursor:pointer;" onclick="base().ImgOnClickError(this);"/>
										</component>
										<component cmptype="Column" field="INVITE_STATUS" name="INVITE_STATUS">
											<component cmptype="Label" captionfield="INVITE_STATUS"/>
										</component>
                                        <component cmptype="Column" field="SHOW_BUTTON" width="1" name="nButton">
                                            <component cmptype="Button" caption="Пригласить" name="INV_BUTTON" onclick="base().INVITE_PATIENT();"/>
                                            <component cmptype="Button" caption="Отменить" name="CANC_BUTTON" onclick="base().CANCEL_INVITATION();"/>
                                        </component>
										<component cmptype="GridFooter" separate="false">
											<component insteadrefresh="InsteadRefresh(this);" count="10" cmptype="Range" varstart="dsstart" varcount="dscount" name="dirRange" valuecount="30" valuestart="1"/>
										</component>
									</component>
								</td>
							</tr>
						</table>
					</div>
        		</td>
       		</tr>
        </table>
		<component cmptype="Hint" name="MarkersHint"/>

        <component cmptype="Popup" name="pDiary" popupobject="Grid" onpopup="base().ONPP();">
        	<component cmptype="PopupItem" name="pRefreshDirect"   caption="Обновить"       onclick="refreshDataSet('DS_USUAL');" cssimg="refresh"/>
        	<component cmptype="PopupItem" caption="-"/>
			<!-- @gen_reg from -->
			<!--component cmptype="PopupItem" name="pPatNewReg"   caption="Новая запись" onclick="base().PAT_NEW_REG()" cssimg="insert"/-->
			<component cmptype="PopupItem" name="pPatNewReg"   caption="Новая запись" onclick="base().patientNewGenReg()" cssimg="insert"/>
			<!--component cmptype="PopupItem" name="pPatToReg"    caption="Записать пациента" onclick="base().PAT_TO_REG()" cssimg="edit"/-->
			<component cmptype="PopupItem" name="pPatToReg" caption="Записать пациента" onclick="base().genRegRecord(1)" cssimg="edit"/>
			<!-- @gen_reg to -->
			<component cmptype="PopupItem" name="pMultiDirect" caption="Массовое оказание услуг" onclick="base().MultiDirection()" cssimg="insert"/>
			<component cmptype="PopupItem" name="pDdelDirect"      caption="Отменить оказание"    unitbp="VISITS_CANCEL"   onclick="base().cancelVisit();" cssimg="delete"/>
			<component cmptype="PopupItem" name="pCancelDS"      caption="Отменить направление"    unitbp="DIRECTION_SERVICES_CANCEL"   onclick="base().CancelDS();" cssimg="delete"/>
			<component cmptype="PopupItem" name="pDirByDS"  caption="Направления"     onclick="base().DirByDS()" unitbp="DIRECTIONS_ADD_BY_DS" cssimg="insert"/>
			<component cmptype="PopupItem" caption="-"/>
			<component cmptype="PopupItem" name="pControlCard" caption="Контрольные карты диспансерного учета" onclick="base().SHOWCNTRL()" cssimg="edit"/>
			<component cmptype="PopupItem" name="pRecipesGroup" caption="Рецепты">
				<component cmptype="PopupItem" name="pViewRecipes" caption="Просмотр рецептов" onclick="base().SHOWRECIPES();" cssimg="list"/>
				<component cmptype="PopupItem" name="pReciept"     caption="Выписать рецепт"  onclick="base().RECIPES()" cssimg="list"/>
			</component>
			<component cmptype="PopupItem" caption="-"/>
			<component cmptype="PopupItem" name="pOBSL"        caption="Обследование"    onclick="base().HOSPITALIZATION1()"/>
			<component cmptype="PopupItem" name="pIzvOkaz"     caption="Выписка" onclick="base().NewVisitOpen();"/>
        	<component cmptype="PopupItem" caption="-"/>
        	<component cmptype="PopupItem" name="pHospGroup" caption="Госпитализация">
        		<component cmptype="PopupItem" name="pHosp"        caption="Госпитализировать"     onclick="base().HOSPITALIZATION()"/>
				<component cmptype="PopupItem" name="pCancelHosp"  caption="Оформить отказ от госпитализации"     onclick="base().cancelHosp()" cssimg="ok"/>
        		<component cmptype="PopupItem" name="pReverseCancelHosp"  caption="Отменить отказ от госпитализации"     onclick="base().reverseCancelHosp()" cssimg="delete"/>
        		<component cmptype="PopupItem" name="pHospDel"     caption="Удалить направление на госпитализацию"  onclick="base().DelHosp()"/>
        	</component>
        	<component cmptype="PopupItem" name="pJavka"        caption="Явка" onclick="base().setJavka();"/>
        	<component cmptype="PopupItem" name="pNejavka"      caption="Неявка" onclick="base().setNejavka();"/>
			<component cmptype="PopupItem" name="pDdelDirectServ"  caption="Удалить направление"  unitbp="DIRECTION_SERVICES_DELETE" onclick="base().deleteDirServDir();" cssimg="delete"/>

            <component cmptype="PopupItem" caption="-"/>
            <component cmptype="PopupItem" name="pNewDraft"    caption="Заполнить черновик" onclick="base().newDraft();" cssimg="insert"/>
            <component cmptype="PopupItem" name="pEditDraft"    caption="Открыть черновик"   onclick="base().editDraft();" cssimg="edit"/>
            <component cmptype="PopupItem" name="pDelDraft"     caption="Удалить черновик"   onclick="base().delDraft();"  cssimg="delete"/>
            <component cmptype="PopupItem" caption="-"/>
            <component cmptype="PopupItem" name="pAddOuterDir"  caption="Добавить внешнее направление" onclick="base().addEditOuterDir();" cssimg="insert"/>
            <component cmptype="PopupItem" name="pEditOuterDir"  caption="Редактировать внешнее направление" onclick="base().addEditOuterDir('edit');" cssimg="edit"/>
            <component cmptype="PopupItem" name="pDelOuterDir"  caption="Удалить внешнее направление" onclick="base().delOuterDir();" cssimg="delete"/>
            <component cmptype="PopupItem" caption="-"/>

			<!-- @gen_reg начало -->
			<!--component cmptype="PopupItem" name="pDeditDirectServ" caption="Редактировать запись" unitbp="DIRECTION_SERVICES_UPDATE" onclick="base().updateDirServDir();" cssimg="edit"/-->
			<component cmptype="PopupItem" name="pDeditDirectServ" caption="Редактировать запись" unitbp="DIRECTION_SERVICES_UPDATE" onclick="base().updateDirServGenReg();" cssimg="edit"/>
    		<component cmptype="PopupItem" name="pAddPregnantCard" caption="Поставить на учет по беременности" unitbp="PREGNANT_CARDS_INSERT" onclick="base().addPregnantCard();" cssimg="insert"/>
			<!-- @gen_reg конец -->
  		</component>
	 	<component cmptype="AutoPopupMenu" name="pREPS"  unit="DIRECTION_SERVICES" join_menu="pDiary" popupobject="Grid" all="true">
			<component cmptype="PopupItem" name="pContr" caption="Контракт" onclick="base().PrintContract()" cssimg="print"/>
			<component cmptype="PopupItem" name="pInf"   caption="Информированное согласие" onclick="base().PrintAgreement();" cssimg="print"/>
			<component cmptype="PopupItem" name="pInfPers" caption="Инф. согл. на обработку ПД" onclick="base().PrintAgreementPersInfo();" cssimg="print"/>
			<component cmptype="PopupItem" name="pInfReps" caption="Информированные согласия (спец.)" cssimg="report">
				<component cmptype="PopupItem" name="pInfOper"  caption="На операцию" onclick="base().PrintAgreementOper();" cssimg="print"/>
				<component cmptype="PopupItem" name="pInfNark"  caption="Наркологическое" onclick="base().PrintAgreementNarkolog();" cssimg="print"/>
				<component cmptype="PopupItem" name="pInfUZI"   caption="УЗИ" onclick="base().PrintAgreementUZI();" cssimg="print"/>
				<component cmptype="PopupItem" name="pInfAbort" caption="Аборт" onclick="base().PrintAgreementAbort();" cssimg="print"/>
			</component>
			<component cmptype="PopupItem" name="pS" caption="-"/>
			<component cmptype="PopupItem" name="pDirServ" caption="Направление" onclick="base().PrintVisit(null, getValue('Grid'), 3);" cssimg="print"/>
			<component cmptype="PopupItem" name="pExperCard" caption="Лист экспертной оценки" onclick="base().PrintExpertCard();" cssimg="print"/>
			<component cmptype="PopupItem" name="pMedCard"   caption="Медицинская карта" onclick="base().PrintMedCard();" cssimg="print"/>
			<component cmptype="PopupItem" name="pDocResult" caption="Заключение врача" onclick="base().PrintDocResult();" cssimg="print"/>
			<component cmptype="PopupItem" name="pDocDiag" caption="Диагнозы пациента" onclick="base().PrintDiagnozesRep();" cssimg="print"/>
			<component cmptype="PopupItem" name="pHospResult" caption="Направление на госпитализацию" onclick="base().PrintHospResult();" cssimg="print"/>
			<component cmptype="PopupItem" name="pAmbTalon" caption="Амбулаторный талон" onclick="base().PrintAmbTalon();" cssimg="print"/>
			<component cmptype="PopupItem" name="pCostReference" caption="Справка о стоимости лечения" cssimg="print" onclick="base().PrintCostReference();"/>
			<component cmptype="PopupItem" name="pRadDoseExposure" caption="Лист учета доз облучения при рентгенологических исследованиях" onclick="base().PrintRadDoseExposure();" cssimg="print"/>
        </component>

	</component>
</div>
