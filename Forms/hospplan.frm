<div cmptype="bogus" oncreate="base().OnCreate();" onshow="base().OnShow();" name="BASE_FORM">
	<component cmptype="ProtectedBlock" alert="true" modcode="HospitalIncome">
		<!--
		Форма планы госпитализации по конкретной дате
			!-ComboBox "Журнал:" содержит только те записи, на которые у пользователя имеются права-!
		-->
  		<div cmptype="title">Планы госпитализации (по конкретной дате)</div>
    	<component cmptype="Action" name="CreateNewPlan">
			<![CDATA[
		 		begin
			  		d_pkg_hpk_plans.add(pnd_insert_id => :pnd_insert_id,
								                pnlpu => :pnlpu,
								                pnpid => :pnpid,
								          pdplan_date => :pdplan_date,
								         pnmale_count => null,
								         pnoper_count => null,
								          pngen_count => null);
			 end;
		 	]]>
		 	<component cmptype="ActionVar" name="pnd_insert_id"       put="var0"      src="NewID"                srctype="var" len="17"/>
		 	<component cmptype="ActionVar" name="pnlpu"               get="var2"      src="LPU"                  srctype="var"/>
		 	<component cmptype="ActionVar" name="pdplan_date"         get="var1"      src="DDATE"                srctype="ctrl"/>
			<component cmptype="ActionVar" name="pnpid"               get="var5"      src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl"/>
  		</component>
  		<!--Action для получения начала и конца текущего месяца при открытии формы-->
  		<component cmptype="Action" name="getSYS_DATE">
			<![CDATA[
			begin
				select  to_char(sysdate,'dd.mm.yyyy')
				  into :CUR_START_DATE
				  from  dual;
			end;
			]]>
			<component cmptype="ActionVar" name="CUR_START_DATE" src="DDATE" srctype="ctrl" put="var1" len="11"/>
  		</component>

		<component cmptype="Action" name="SetPKConstr">
	  		<![CDATA[
				begin
					select hpk.HAS_PAYMENT_CONSTRAINTS
					  into :HAS_PAYMENT_CONSTRAINTS
					  from d_v_hosp_plan_kinds hpk
					 where hpk.ID = :HPK_ID;
				 exception when no_data_found then
						:HAS_PAYMENT_CONSTRAINTS := 0;
				end;
			]]>
			<component cmptype="ActionVar" name="HAS_PAYMENT_CONSTRAINTS" src="HAS_PK_CONSTR"        srctype="var"  put="var1" len="2"/>
			<component cmptype="ActionVar" name="HPK_ID"                  src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl" get="var2"/>
	  	</component>

  		<!--Action для проверки прав на отправку на ИБ-->
	  	<component cmptype="Action" name="CheckRightsIB">
			<![CDATA[
			begin
			  :checkIB := D_PKG_CSE_ACCESSES.CHECK_RIGHT( pnLPU => :PNLPU,
					                                 psUNITCODE => 'HOSP_PLAN_KINDS',
					                                  pnUNIT_ID => :PLANID,
					                                    psRIGHT => '8',
					                                   pnCABLAB => :CABLAB,
					                                  pnSERVICE => null);
			end;
			]]>
			<component cmptype="ActionVar" name="PNLPU"   src="LPU"                  srctype="var"  get="var3"/>
			<component cmptype="ActionVar" name="CABLAB"  src="CABLAB"               srctype="var"  get="var0"/>
			<component cmptype="ActionVar" name="PLANID"  src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl" get="var1"/>
			<component cmptype="ActionVar" name="checkIB" src="CHIB"                 srctype="var"  put="var2" len="2"/>
	  	</component>

  		<!--Action для проверки прав на запись, редакт., удаление-->
  		<component cmptype="Action" name="CheckRightsREC">
			<![CDATA[
			begin
			  :checkREC := D_PKG_CSE_ACCESSES.CHECK_RIGHT(pnLPU => :PNLPU,
					                                 psUNITCODE => 'HOSP_PLAN_KINDS',
					                                  pnUNIT_ID => :PLANID,
					                                    psRIGHT => '7',
					                                   pnCABLAB => :CABLAB,
					                                  pnSERVICE => null);
			end;
			]]>
			<component cmptype="ActionVar" name="PNLPU"    src="LPU"               srctype="var" get="var3"/>
			<component cmptype="ActionVar" name="CABLAB"   src="CABLAB"            srctype="var" get="var0"/>
			<component cmptype="ActionVar" name="PLANID"   src="C_HOSP_PLAN_KINDS" srctype="var" get="var1"/>
			<component cmptype="ActionVar" name="checkREC" src="CHREC"             srctype="var" put="var2" len="2"/>
  		</component>

	  	<component cmptype="Action" name="ActionDelPlanDay">
			<![CDATA[
			begin
				d_pkg_hpk_plan_journals.del(pnid => :pnid,
									       pnlpu => :pnlpu);
			end;
			]]>
			<component cmptype="ActionVar" name="pnlpu" src="LPU"            srctype="var" get="v0"/>
			<component cmptype="ActionVar" name="pnid"  src="HPK_PL_DAY_VAR" srctype="var" get="v1"/>
			<!--component cmptype="ActionVar" name="pnid"  src="GR_HPK_PLAN_DAY" srctype="ctrl" get="var1"/-->
	  	</component>

  		<!--Action: минус день-->
	  	<component cmptype="Action" name="prevDay">
			<![CDATA[
			begin
				:START_DATE := to_char(to_date(:CURR_DATE)-1,'dd.mm.yyyy');
			end;
			]]>
			<component cmptype="ActionVar" name="START_DATE" src="DDATE" srctype="ctrl" put="var1" len="11"/>
			<component cmptype="ActionVar" name="CURR_DATE"  src="DDATE" srctype="ctrl" get="var3"         />
	  	</component>

  		<!--Action: плюс день-->
	  	<component cmptype="Action" name="nextDay">
			<![CDATA[
			begin
				:START_DATE := to_char(to_date(:CURR_DATE)+1,'dd.mm.yyyy');
			end;
			]]>
			<component cmptype="ActionVar" name="START_DATE" src="DDATE" srctype="ctrl" put="var1" len="11"/>
			<component cmptype="ActionVar" name="CURR_DATE"  src="DDATE" srctype="ctrl" get="var3"         />
	  	</component>

	  	<component cmptype="Action" name="SearchPatient">
			<![CDATA[
			begin
				d_pkg_hpk_plan_journals.set_record(pnlpu => :pnlpu,
										       pnpatient => :pnpatient,
											     pnexist => :pnexist,
											      pddate => :pddate,
										     pnplan_kind => :pnplan_kind,
										     pnhave_next => :pnhave_next,
							                 pnhave_prev => :pnhave_prev);
			   	if :pnexist = 0 then
			   		:pnhave_next := 0;
			   		:pnhave_prev := 0;
			   		:pnplan_kind:=:plan_kind;
				end if;
			end;
			]]>
			<component cmptype="ActionVar" name="pnlpu"        src="LPU"                  srctype="var"  get="v0"/>
			<component cmptype="ActionVar" name="pnpatient"    src="PERSMEDCARD"          srctype="ctrl" get="var1"/>
			<component cmptype="ActionVar" name="pnexist"      src="EXIST"                srctype="var"  put="var2" len="2"/>
			<component cmptype="ActionVar" name="pddate"       src="DDATE"                srctype="ctrl" put="var3" len="11"/>
			<component cmptype="ActionVar" name="pnplan_kind"  src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl" put="var4" len="17"/>
			<component cmptype="ActionVar" name="pnhave_next"  src="HAVE_NEXT"            srctype="var"  put="var5" len="2"/>
			<component cmptype="ActionVar" name="pnhave_prev"  src="HAVE_PREV"            srctype="var"  put="var6" len="2"/>
			<component cmptype="ActionVar" name="plan_kind"    src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl" get="var7"/>
	  	</component>
	  	<component cmptype="Action" name="startSearchDirection">
			<![CDATA[
			begin
				begin
					select t.PATIENT,
						   t.ID
					  into :PMC,
						   :DIR
					  from D_V_DIRECTIONS_BASE t
					 where (t.DIR_PREF = :DIR_PREF or (:DIR_PREF is null and t.DIR_PREF is null))
					   and (t.DIR_NUMB = :DIR_NUMB or (:DIR_NUMB is null and t.DIR_NUMB is null))
					   and t.DIR_TYPE  = 1
					   and t.LPU       = :LPU;
				exception
					when NO_DATA_FOUND then
						:PMC := null;
						:DIR := null;
						:DIR_RESULT := -1;
					when TOO_MANY_ROWS then
						:PMC := null;
						:DIR := null;
						:DIR_RESULT := -2;
				end;
				if :DIR is not null and :PMC is not null then
					d_pkg_hpk_plan_journals.set_record(:LPU,:PMC,:DIR_RESULT,:DDATE,:HPK,:HAVE_NEXT,:HAVE_PREV,:DIR);
				end if;
			end;
			]]>
			<component cmptype="ActionVar" name="LPU"        src="LPU"                  srctype="var"  get="v0"/>
			<component cmptype="ActionVar" name="DIR_PREF"   src="DIR_PREF"             srctype="ctrl" get="v1"/>
			<component cmptype="ActionVar" name="DIR_NUMB"   src="DIR_NUMB"             srctype="ctrl" get="v2"/>
			<component cmptype="ActionVar" name="DIR_RESULT" src="DIR_RESULT"           srctype="var"  put="v3" len="2"/>
			<component cmptype="ActionVar" name="PMC"        src="PMC_DIR"              srctype="var"  put="v4" len="17"/>
			<component cmptype="ActionVar" name="DIR"        src="DIR_DIR"              srctype="var"  put="v5" len="17"/>
			<component cmptype="ActionVar" name="DDATE"      src="DDATE"                srctype="ctrl" put="v6" len="25"/>
			<component cmptype="ActionVar" name="HPK"        src="C_DS_HOSP_PLAN_KINDS" srctype="ctrt" put="v7" len="17"/>
			<component cmptype="ActionVar" name="HAVE_NEXT"  src="DIR_HAVE_NEXT"        srctype="var"  put="v8" len="3"/>
			<component cmptype="ActionVar" name="HAVE_PREV"  src="DIR_HAVE_PREV"        srctype="var"  put="v9" len="3"/>
	  	</component>
	  	<component cmptype="Action" name="SearchPatientNext">
			<![CDATA[
			begin
				d_pkg_hpk_plan_journals.set_next_record(pnlpu => :pnlpu,
												    pnpatient => :pnpatient,
												       pddate => :pddate,
												  pnplan_kind => :pnplan_kind,
												  pdnext_date => :pdnext_date,
											 pnnext_plan_kind => :pnnext_plan_kind,
												  pnhave_next => :pnhave_next);
			end;
			]]>
			<component cmptype="ActionVar" name="pnlpu"            src="LPU"                  srctype="var"  get="var0"/>
			<component cmptype="ActionVar" name="pnpatient"        src="PERSMEDCARD"          srctype="ctrl" get="var1"/>
			<component cmptype="ActionVar" name="pddate"           src="DDATE"                srctype="ctrl" get="var2"/>
			<component cmptype="ActionVar" name="pnplan_kind"      src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl" get="var3"/>
			<component cmptype="ActionVar" name="pdnext_date"      src="DDATE"                srctype="ctrl" put="var4" len="11"/>
			<component cmptype="ActionVar" name="pnnext_plan_kind" src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl" put="var5" len="17"/>
			<component cmptype="ActionVar" name="pnhave_next"      src="HAVE_NEXTT"           srctype="var"  put="var6" len="2"/>
	  	</component>
	  	<component cmptype="Action" name="searchDirNext">
			<![CDATA[
			begin
				d_pkg_hpk_plan_journals.set_next_record(:LPU,:PMC,:DDATE_IN,:HPK_IN,:DDATE_OUT,:HPK_OUT,:HAVE_NEXT,:DIR);
			end;
			]]> 
			<component cmptype="ActionVar" name="LPU"       src="LPU"                  srctype="var"  get="v0"/>
			<component cmptype="ActionVar" name="PMC"       src="PMC_DIR"              srctype="var"  get="v1"/>
			<component cmptype="ActionVar" name="DIR"       src="DIR_DIR"              srctype="var"  get="v2"/>
			<component cmptype="ActionVar" name="DDATE_IN"  src="DDATE"                srctype="ctrl" get="v3"/>
			<component cmptype="ActionVar" name="HPK_IN"    src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl" get="v4"/>
			<component cmptype="ActionVar" name="DDATE_OUT" src="DDATE"                srctype="ctrl" put="v5" len="25"/>
			<component cmptype="ActionVar" name="HPK_OUT"	src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl" put="v6" len="17"/>
			<component cmptype="ActionVar" name="HAVE_NEXT" src="DIR_HAVE_NEXTT"       srctype="var"  put="v7" len="3"/>
	  	</component>
  		<component cmptype="Action" name="searchDirPrev">
			<![CDATA[
			begin
				d_pkg_hpk_plan_journals.set_prev_record(:LPU,:PMC,:DDATE_IN,:HPK_IN,:DDATE_OUT,:HPK_OUT,:HAVE_PREV,:DIR);
			end;
			]]>
			<component cmptype="ActionVar" name="LPU"       src="LPU"                  srctype="var"  get="v0"/>
			<component cmptype="ActionVar" name="PMC"       src="PMC_DIR"              srctype="var"  get="v1"/>
			<component cmptype="ActionVar" name="DIR"       src="DIR_DIR"              srctype="var"  get="v2"/>
			<component cmptype="ActionVar" name="DDATE_IN"  src="DDATE"                srctype="ctrl" get="v3"/>
			<component cmptype="ActionVar" name="HPK_IN"    src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl" get="v4"/>
			<component cmptype="ActionVar" name="DDATE_OUT" src="DDATE"                srctype="ctrl" put="v5" len="25"/>
			<component cmptype="ActionVar" name="HPK_OUT"	src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl" put="v6" len="17"/>
			<component cmptype="ActionVar" name="HAVE_NEXT" src="DIR_HAVE_PREVV"       srctype="var"  put="v7" len="3"/>
  		</component>
		<component cmptype="Action" name="SearchPatientPrev">
	  		<![CDATA[
				begin
  					d_pkg_hpk_plan_journals.set_prev_record(pnlpu => :pnlpu,
                                                        pnpatient => :pnpatient,
                                                           pddate => :pddate,
                                                      pnplan_kind => :pnplan_kind,
                                                      pdprev_date => :pdprev_date,
                                                 pnprev_plan_kind => :pnprev_plan_kind,
                                                      pnhave_prev => :pnhave_prev);
				end;
			]]>
			<component cmptype="ActionVar" name="pnlpu"            src="LPU"                  srctype="var"  get="v0"/>
			<component cmptype="ActionVar" name="pnpatient"        src="PERSMEDCARD"          srctype="ctrl" get="var1"/>
			<component cmptype="ActionVar" name="pddate"           src="DDATE"                srctype="ctrl" get="var2"/>
			<component cmptype="ActionVar" name="pnplan_kind"      src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl" get="var3"/>
			<component cmptype="ActionVar" name="pdprev_date"      src="DDATE"                srctype="ctrl" put="var4" len="11"/>
			<component cmptype="ActionVar" name="pnprev_plan_kind" src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl" put="var5" len="17"/>
			<component cmptype="ActionVar" name="pnhave_prev"      src="HAVE_PREVV"           srctype="var"  put="var6" len="2"/>
  		</component>

	  	<component cmptype="Action" name="ActionIB">
			<![CDATA[
				begin
					d_pkg_hpk_plan_journals.set_hh_direction_date(pnid => :pnid);
				end;
			]]>
			<component cmptype="ActionVar" name="pnid" src="HPK_PL_DAY_VAR" srctype="var" get="v1"/>
			<!-- component cmptype="ActionVar" name="pnid" src="GR_HPK_PLAN_DAY" srctype="ctrl" get="var1"/ -->
	  	</component>

  		<component cmptype="Action" name="ActionMax_Prior">
			<![CDATA[
			begin
				begin
					select case when t.MAX_PRIOR is null then ''
                                else ' Предварительная запись: '||t.MAX_PRIOR||' дней.'
                           end,
						   case when t.MIN_AGE is null then''
							    else ' Минимальный возраст: '||t.MIN_AGE||'.'
						   end,
						   case when t.MAX_AGE is null then ''
							    else ' Максимальный возраст: '||t.MAX_AGE||'.'
						   end,
						   case when t.HAS_MKB_CONSTRAINTS = 1 then ' Имеются ограничения по диагнозам.'
							    else ''
						   end,
						   case when t.HAS_MKB_CONSTRAINTS = 1 then ''
							    else ' Имеются ограничения по видам оплаты.'
						   end,
						   case when t.HAS_LIMITS = 1 then ''
							    else ' Неограниченная запись.'
						   end
		             into :MAX_PRIOR,
		                  :MIN_AGE,
		                  :MAX_AGE,
		                  :HAS_MKB_CONSTRAINTS,
		                  :PAYMENT_KIND,
		                  :HAS_LIMITS
		             from d_v_hosp_plan_kinds t
		            where t.ID = :HPKID;
		        exception when no_data_found then
		            :MAX_PRIOR := null;
		            :MIN_AGE := null;
		            :MAX_AGE := null;
		            :HAS_MKB_CONSTRAINTS := null;
		            :PAYMENT_KIND := null;
		            :HAS_LIMITS := null;
				end;
				begin
					select ' Мест занято(всего): '||h.GEN_COUNT_S||',',
		                   ' мужских: '||h.MALE_COUNT_S||',',
		                   ' женских: '||h.FEMALE_COUNT_S,
		                   ' из них оперативных: '||h.OPER_COUNT_S||',',
		                   ' консервативных: '||h.CON_COUNT_S||','
		              into :GEN_COUNT_S,
		                   :MALE_COUNT_S,
		                   :FEMALE_COUNT_S,
		                   :OPER_COUNT_S,
		                   :CON_COUNT_S
		              from d_v_hpk_plans h
	                 where h.PID = :HPKID
		               and h.PLAN_DATE = :START_DATE;
		         exception when no_data_found then
		 			:GEN_COUNT_S := null;
		 			:MALE_COUNT_S := null;
		 			:FEMALE_COUNT_S := null;
		 			:OPER_COUNT_S := null;
		 			:CON_COUNT_S := null;
				end;

				begin
					select hpk.HAS_PAYMENT_CONSTRAINTS
				  	  into :HAS_PAYMENT_CONSTRAINTS
					  from d_v_hosp_plan_kinds hpk
				  	 where hpk.ID = :HPKID;
			     exception when no_data_found then
						:HAS_PAYMENT_CONSTRAINTS := 0;
				end;
				begin
					if to_date(:START_DATE, 'dd.mm.yyyy') < trunc(sysdate) then
						:AVAIL_ADD := 0;
					else
						:AVAIL_ADD := 1;
					end if;
				end;
			end;
			]]>
			<component cmptype="ActionVar" name="HPKID"               src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl"        get="var1"/>
			<component cmptype="ActionVar" name="MAX_PRIOR"           src="max_reg_date"         srctype="ctrlcaption" put="var2" len="60"/>
			<component cmptype="ActionVar" name="MIN_AGE"             src="min_reg_age"          srctype="ctrlcaption" put="var3" len="60"/>
			<component cmptype="ActionVar" name="MAX_AGE"             src="max_reg_age"          srctype="ctrlcaption" put="var4" len="60"/>
			<component cmptype="ActionVar" name="HAS_MKB_CONSTRAINTS" src="has_mkb_ogr"          srctype="ctrlcaption" put="var5" len="60"/>
			<component cmptype="ActionVar" name="PAYMENT_KIND"        src="pay_reg_kind"         srctype="ctrlcaption" put="var6" len="60"/>
			<component cmptype="ActionVar" name="HAS_LIMITS"          src="has_reg_lim"          srctype="ctrlcaption" put="var7" len="60"/>

			<!-- 	<component cmptype="ActionVar" name="HPKID"         src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl" get="var1"/> -->
			<component cmptype="ActionVar" name="GEN_COUNT_S"             src="Place_all"     srctype="ctrlcaption" put="va2"    len="82"/>
			<component cmptype="ActionVar" name="MALE_COUNT_S"            src="Place_male"    srctype="ctrlcaption" put="va3"    len="82"/>
			<component cmptype="ActionVar" name="FEMALE_COUNT_S"          src="Place_female"  srctype="ctrlcaption" put="va4"    len="82"/>
			<component cmptype="ActionVar" name="OPER_COUNT_S"            src="Place_oper"    srctype="ctrlcaption" put="va5"    len="82"/>
			<component cmptype="ActionVar" name="CON_COUNT_S"             src="Place_cons"    srctype="ctrlcaption" put="va6"    len="82"/>
			<component cmptype="ActionVar" name="START_DATE"	          src="DDATE"         srctype="ctrl"        get="va9"/>
			<component cmptype="ActionVar" name="AVAIL_ADD"               src="AVAIL_ADD"     srctype="var"         put="AV_ADD" len="1"/>
			<component cmptype="ActionVar" name="HAS_PAYMENT_CONSTRAINTS" src="HAS_PK_CONSTR" srctype="var"         put="vv1"    len="2"/>
			<!-- <component cmptype="ActionVar" name="HPK_ID"   src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl" get="var2"/> -->
			<component cmptype="ActionVar" name="PNLPU"                   src="LPU"           srctype="var"         get="v0"/>
  		</component>

   		<component cmptype="Action" name="NearestDaySearch">
			<![CDATA[
			begin
    		:result := d_pkg_hpk_plan_journals.nearest_date_search(pnlpu => :pnlpu,
    		                                                       pnhpk => :pnhpk,
    		                                                pdstart_date => :pdstart_date,
    		                                                       pnsex => :pnsex,
    		                                                 pnoper_type => :pnoper_type);
			end;
			]]>
			<component cmptype="ActionVar" name="pnhpk"        src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl"  get="var1"/>
			<component cmptype="ActionVar" name="PNLPU"        src="LPU"                  srctype="var"   get="v0"/>
			<component cmptype="ActionVar" name="pdstart_date" src="DDATE"                srctype="ctrl"  get="var2"/>
			<component cmptype="ActionVar" name="pnsex"        src="C_HOSP_READY"         srctype="ctrl"  get="var3"/>
			<component cmptype="ActionVar" name="pnoper_type"  src="C_HOSP_KIND"          srctype="ctrl"  get="var4"/>
			<component cmptype="ActionVar" name="result"       src="DDATE"                srctype="ctrl"  put="var6" len="11"/>
  		</component>

	  	<component cmptype="Action" name="ActionPlanForDate">
			<![CDATA[
			begin
				select t.ID
			  	  into :IDD
			  	  from d_v_hpk_plans t
				 where t.PID = :PLANID
				   and t.PLAN_DATE = :START_DATE;
			 exception when no_data_found then
				:IDD := null;
			end;
			]]>   
			<component cmptype="ActionVar" name="PLANID"     src="C_DS_HOSP_PLAN_KINDS"    srctype="ctrl"  get="var1"/>
			<component cmptype="ActionVar" name="START_DATE" src="DDATE"                   srctype="ctrl"  get="var2"/>
			<component cmptype="ActionVar" name="IDD"        src="THISPLANID"              srctype="var"   put="var3" len="17"/>
	  	</component>

	  	<component cmptype="Action" name="getQuantBeds">
			<![CDATA[
			begin
			  :quant_beds := d_pkg_hpk_plan_journals.get_quant_beds_profiles_new(pnhpk_plan => :pnhpk_plan,
			                                                                          pnlpu => :pnlpu);
			end;
			]]>
			<!--<component cmptype="ActionVar" name="pnhpk_plan"   src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl"  get="var1"/>-->
			<component cmptype="ActionVar" name="pnhpk_plan"   src="THISPLANID" srctype="var" get="v1"/>
			<component cmptype="ActionVar" name="pnlpu"        src="LPU"        srctype="var" get="v0"/>
			<component cmptype="ActionVar" name="quant_beds"   src="quant_beds" srctype="var" put="var2" len="700"/>
	  	</component>

    	<component cmptype="Action" name="ActionPlaces">
			<![CDATA[
				begin
					select ' Мест занято(всего): '||h.GEN_COUNT_S||',',
					       ' мужских: '||h.MALE_COUNT_S||',',
					       ' женских: '||h.FEMALE_COUNT_S,
					       ' из них оперативных: '||h.OPER_COUNT_S||',',
					       ' консервативных: '||h.CON_COUNT_S||','
					  into :GEN_COUNT_S,
					       :MALE_COUNT_S,
					       :FEMALE_COUNT_S,
					       :OPER_COUNT_S,
					       :CON_COUNT_S
				  	  from d_v_hpk_plans h
					 where h.PID = :HPKID
					   and h.PLAN_DATE = :START_DATE;
				 exception when no_data_found then
					 :GEN_COUNT_S := null;
					 :MALE_COUNT_S := null;
					 :FEMALE_COUNT_S := null;
					 :OPER_COUNT_S := null;
					 :CON_COUNT_S := null;
				end;
			]]>
			<component cmptype="ActionVar" name="HPKID"          src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl"        get="var1"/>
			<component cmptype="ActionVar" name="GEN_COUNT_S"    src="Place_all"            srctype="ctrlcaption" put="var2" len="82"/>
			<component cmptype="ActionVar" name="MALE_COUNT_S"   src="Place_male"           srctype="ctrlcaption" put="var3" len="82"/>
			<component cmptype="ActionVar" name="FEMALE_COUNT_S" src="Place_female"         srctype="ctrlcaption" put="var4" len="82"/>
			<component cmptype="ActionVar" name="OPER_COUNT_S"   src="Place_oper"           srctype="ctrlcaption" put="var5" len="82"/>
			<component cmptype="ActionVar" name="CON_COUNT_S"    src="Place_cons"           srctype="ctrlcaption" put="var6" len="82"/>
			<component cmptype="ActionVar" name="START_DATE"     src="DDATE"                srctype="ctrl"        get="var9"/>
  		</component>
  		<component cmptype="Action" name="GetRight">
			<![CDATA[
				begin
					:CHECK_HPK:=D_PKG_CSE_ACCESSES.CHECK_RIGHT(pnLPU => :PNLPU,
					                                      psUNITCODE => 'HOSP_PLAN_KINDS',
					                                       pnUNIT_ID => :PLANIDD,
					                                         psRIGHT => 3,
					                                        pnCABLAB => :CABLAB,
					                                       pnSERVICE => null);
				end;
  		    ]]>
  		    <component cmptype="ActionVar" name="PNLPU"     src="LPU"                  srctype="var"  get="v0"/>
  		    <component cmptype="ActionVar" name="PLANIDD"   src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl" get="v1"/>
  		    <component cmptype="ActionVar" name="CABLAB"    src="CABLAB"               srctype="var"  get="v2"/>
  		    <component cmptype="ActionVar" name="CHECK_HPK" src="CHECK_HPK"            srctype="var"  put="v3" len="1"/>
  		</component>

  		<!--DataSet: Для элемента ComboBox (виды госпитализации, доступные пользователю)-->
  		<component cmptype="DataSet" name="DS_HOSP_PLAN_KINDS">
  		    <![CDATA[
				select hpk.ID,
				       hpk.HP_NAME,
  		               hpk.JOURNAL_TYPE
				  from d_v_hosp_plan_kinds hpk
				       join table(cast(D_PKG_CSE_ACCESSES.GET_ID_WITH_RIGHTS(:PNLPU,'HOSP_PLAN_KINDS','3', :CABLAB) AS d_c_id )) t1 on t1.COLUMN_VALUE = hpk.id
  		      order by hpk.HP_NAME
		 	]]>
  		  	<component cmptype="Variable" name="PNLPU"       src="LPU"    srctype="var" get="var1"/>
  		  	<component cmptype="Variable" name="CABLAB"      src="CABLAB" srctype="var" get="var0"/>
  		</component>

  		<!--DataSet: Содержимое таблицы-->
  		<component cmptype="DataSet" name="DS_HPK_PLAN_DAY" activateoncreate="false" mode="Range" compile="true">
			<![CDATA[
				select row_number() over (
                          @if (:JOURNAL_TYPE == 2 && :GenDirNumbToDirKinds == 1){
                              @if (:fltr_DIRECTION_KIND_ID){
                                  partition by t.DIRECTION_KIND_ID
                              @}
                                  order by t.REGISTER_DATE
                          @}else{
                                  order by t.ID
                          @}
                       ) ROW_NUM,
                       t.ID,
		               t.ID||t.HOSP_HISTORY UNIQ_N,
		               t.LPU,
		               t.HPK_PLAN THISPLANID,
                       t.PATIENT_ADDRESS,
                       t.PATIENT_SNILS,
                       t.RECORD_STATUS,
                       case when t.RECORD_STATUS = 0 then 'Не отработана' else 'Отработана' end RECORD_STATUS_MNEMO,
		               t.HOSP_PLAN_KIND,
		               t.HOSP_PLAN_KIND_NAME,
		               t.PATIENT_ID,
		               t.PATIENT_AGENT,
		               t.PATIENT_CARD_NUMB CARD_NUMB,
		               t.COMMENTS PATIENT_PHONE,
		               (select mkb.MKB_CODE || ' ' || mkb.MKB_NAME
		                  from D_V_MKB10 mkb
		                 where mkb.ID = t.HOSP_MKB) HOSP_MKB,
		               t.IS_CANCELED,
		               t.PATIENT,
		               nvl(trim(D_PKG_AGENT_NAMES.GET_ACTUAL_ON_DATE(t.PATIENT_AGENT, CASE WHEN t.DATE_IN IS Null THEN t.REGISTER_DATE ELSE t.DATE_IN END, 'SURNAME FIRSTNAME LASTNAME')),t.PATIENT) PATIENT_ACTUAL,
		               trunc(t.PATIENT_BIRTHDATE) PATIENT_BIRTHDATE,
		               t.DIRECTED_BY_ID,
		               t.DIRECTED_BY,
		               t.DIRECTED_TO_ID,
		               t.DIRECTED_TO,
		               t.REGISTERED_BY_ID,
		               trim(t.REGISTERED_BY) REGISTERED_BY,
	  	               to_char(t.REGISTER_DATE, D_PKG_STD.FRM_DT) REGISTER_DATE,
		               to_char(t.DATE_IN, D_PKG_STD.FRM_DT) DATE_IN,
		               trunc(t.DATE_IN) DATE_IN_TRUNC,
		               (select hhd.DEP_NAME
		                  from D_V_HOSP_HISTORIES_BASE hh_b
		                       left join D_V_HOSP_RESULTS hr on hh_b.HOSP_RESULT = hr.ID
		                       join D_V_HOSP_HISTORY_DEPS hhd on hh_b.ID = hhd.PID
		                 where hh_b.ID = t.HOSP_HISTORY
		                   and hhd.PRVSID is null
		                   and (hh_b.HOSP_RESULT is null or hr.R_CODE != '6')
		               ) HOSP_IN_DEP,
		               to_char(t.DATE_OUT, D_PKG_STD.FRM_DT) DATE_OUT,
		               t.HAS_PRIVILEGES,
		               t.SHAS_PRIVILEGES,
		               t.OPERATION_ID,
		               t.OPERATION_NAME OPERATION,
		               t.DIRECTION,
		               t.PAYMENT_KIND_ID,
		               t.PAYMENT_KIND,
		               nvl(t.HOSP_PAYMENT_KIND, t.PAYMENT_KIND) PAYMENT_KIND_NAME,
		               t.IS_READY,
		               t.HH_DIRECTION_DATE,
		               t.IS_OPER,
		               t.IS_OPER_MNEMO,
		               t.IS_READY_MNEMO,
		               t.HP_NAME,
		               D_PKG_HPK_PLAN_JOURNALS.GET_HOSP_HISTORY_STATUS(t.LPU, t.ID) BEDS,
		               t.HOSP_HISTORY,
		               t.HOSP_HISTORY_DS,
		               to_char(t.PLAN_DATE,D_PKG_STD.FRM_D) PLAN_DATE,
		               t.COMMS COMMENTS,
		               t.DEPBED,
		               /*nvl(t.DEP,'---')||'/'||*/t.HOSP_PLAN_KIND_NAME DEP,
		               t.DEP_ID,
		               t.DIAGNOSIS_FROM,
                       t.HPK_JOURNAL_TYPE JT,
                       t.DIR_COMMENT DIR_COMMENTS,
		               t.PATIENT_POLIS,
		               t.COMMENTS PATIENT_CONTACTS,
		               t.DISEASECASE,
                       t.HPK_JOURNAL_TYPE,
                       t.record_numb||'-'||t.record_pref RECORD_PREF_NUMB,
                       t.DIR_PREF || '/' || t.DIRECTION_KIND_SHORT_NAME || '/' || t.DIR_NUMB DIR_PREF_NUMB,
                       t.HH_TYPE,
                       t.DIRECTION_KIND_ID,
                       t.DIRECTION_KIND_NAME,
                       (select t2.D_NUMB
                          from D_V_OUTER_DIRECTIONS t2
                         where t2.ID = t.OUTER_DIRECTION_ID
                       ) OD_NUMB,
                       t.CANC_REASON_NAME,
                       t.HOSP_TYPE HOSPITALIZATION_TYPE_NAME,
                       tr.PATIENT_ID RELATIVE_PATIENT_ID,
                       tr.PATIENT_FIO RELATIVE_PATIENT,
                       tr.ID RELATIVE_HOSP_HISTORY,
                       tr.DISEASECASE RELATIVE_DISEASECASE,
			           (select sr.CABLAB_NAME from D_V_SCH_RESOURCES sr where sr.ID = t.SCH_RESOURCE) CABLAB_NAME,
                       tr.PAYMENT_KIND RELATIVE_PAYMENT_KIND_ID,
                       trunc(t.REGISTER_DATE) REGISTER_DATE_TRUNC
                    @if (:SHOW_FLG == 1){
                       ,case when exists(select null
                                  from D_V_AGENT_FLU_BASE a
                                 where a.PID = t.PATIENT_AGENT) then 1 else 0 end  AGENT_FLU,
		       case when exists(select null
                                  from D_V_AGENT_FLU_PMC_LAST af
                                 where af.PID = t.PATIENT_AGENT
                                   and t.REGISTER_DATE > af.NEXT_DATE
                                   and af.FLU_PURPOSE = 1) then 1 else 0 end  PMC_FLU,
		       case when exists(select null
                                  from D_V_AGENT_FLU_PMC_LAST af
                                 where af.PID = t.PATIENT_AGENT
                                   and af.FLU_PURPOSE in (1, 2)
                                   and af.FLU_CONCLUSION = 2) then 1 else 0 end  PMC_FLU_PATALOGY,
                       D_PKG_DAT_TOOLS.FULL_YEARS(sysdate, t.PATIENT_BIRTHDATE) AGN_YEARS
                    @}
                  from D_V_HPK_PLAN_JOURNALS_ADD t
                       left join D_V_HOSP_HISTORIES_RELATIVE tr
                              on tr.RELATIVE_HH = t.HOSP_HISTORY
                                 and (tr.DATE_OUT is null or tr.DATE_OUT = t.DATE_OUT)
                 where t.LPU     = :PNLPU
               @if(:PERSMEDCARD){
                   and t.PATIENT_ID = :PERSMEDCARD
               @}
               @if (:JOURNAL_TYPE==0 &&:PLANIDD<>-1){
                   and t.HOSP_PLAN_KIND = :PLANIDD
                   and :CHECK_HPK = 1
               @} else if (:JOURNAL_TYPE){
                   and t.HOSP_PLAN_KIND = :PLANIDD
                   and :CHECK_HPK = 1
               @}else if (:PLANIDD==-1){
                   and (select D_PKG_CSE_ACCESSES.CHECK_RIGHT(pnLPU      => :PNLPU,
                                                              psUNITCODE => 'HOSP_PLAN_KINDS',
                                                              pnUNIT_ID  => t.HOSP_PLAN_KIND,
                                                              psRIGHT    => 3,
                                                              pnCABLAB   => :CABLAB,
                                                              pnSERVICE  => null)
                          from dual) = 1
               @}else {
                   and t.HPK_PLAN_KIND is null
               @}
               @if(:CH_HH_ANNUL==1){
                   and (t.HOSP_HISTORY_DS is null or t.HOSP_HISTORY_DS != 1)
               @}
               @if (:JOURNAL_TYPE==0){
                   and t.PLAN_DATE = to_date(:START_DATE, D_PKG_STD.FRM_D)
               @}
			]]>
			<component cmptype="Variable" name="PNLPU"                src="LPU"                   srctype="var"   get="var0"/>
			<component cmptype="Variable" name="PLANIDD"              src="C_DS_HOSP_PLAN_KINDS"  srctype="ctrl"  get="var3"/>
			<component cmptype="Variable" name="START_DATE"           src="DDATE"                 srctype="ctrl"  get="var2"/>
        	<component cmptype="Variable" name="JOURNAL_TYPE"         src="JOURNAL_TYPE"          srctype="var"   get="var4"/>
			<component cmptype="Variable" name="CABLAB"	              src="CABLAB"                srctype="var"   get="var5"/>
			<component cmptype="Variable" name="CHECK_HPK"	          src="CHECK_HPK"             srctype="var"   get="var6"/>
			<component cmptype="Variable" name="GenDirNumbToDirKinds" src="GenDirNumbToDirKinds"  srctype="var"   get="var7"/>
			<component cmptype="Variable" name="CH_HH_ANNUL"          src="CH_HH_ANNUL"           srctype="ctrl"  get="var8"/>
			<component cmptype="Variable" name="PERSMEDCARD"          src="PERSMEDCARD"           srctype="ctrl"  get="var9"/>
			<component cmptype="Variable" name="SHOW_FLG"             src="SHOW_FLG"              srctype="var"   get="gSHOW_FLG"/>
			<component cmptype="Variable" type="count"                src="ds1count"              srctype="var"   default="5"/>
			<component cmptype="Variable" type="start"                src="ds1start"              srctype="var"   default="1"/>
  		</component>
  		<component cmptype="Action" name="GetCardNumbAndStandartRights">
    		<![CDATA[
				declare nCID NUMBER(17);
				begin
                    begin
                        select p2.ID,
                               p2.CARD_NUMB
                          into :PMC_ID,
                               :CARDN
                          from D_V_PERSMEDCARD p1
                               join D_V_PERSMEDCARD p2 on p1.AGENT = p2.AGENT and p2.LPU = :pnlpu
                         where p1.ID = :PMC;
                    exception when no_data_found then
                        :PMC_ID := null;
                        :CARDN := null;
                    end;
  	 				D_PKG_CATALOGS.FIND_ROOT_CATALOG(1,:pnlpu,'HPK_PLAN_JOURNALS',nCID);
					D_PKG_URPRIVS.GET_STANDART_PRIVS(pnlpu => :pnlpu,
                                                psunitcode => 'HPK_PLAN_JOURNALS',
                                                     pncid => nCID,
                                                  pninsert => :pninsert,
                                                  pnupdate => :pnupdate,
                                                  pndelete => :pndelete,
                                                pnmove_out => :pnmove_out);
                	:SHOW_FLG := D_PKG_OPTION_SPECS.GET('ActualFLG', :pnlpu);
				end;
			]]>
			<component cmptype="ActionVar" name="PMC"          src="PMC_ID"      srctype="var"         get="v0"       />
			<component cmptype="ActionVar" name="CARDN"        src="PERSMEDCARD" srctype="ctrlcaption" put="v1"        len="26"/>
			<component cmptype="ActionVar" name="PMC_ID"       src="PERSMEDCARD" srctype="ctrl"        put="v2"        len="17"/>
			<component cmptype="ActionVar" name="pnlpu"        src="LPU"         srctype="var"         get="v3"       />
			<component cmptype="ActionVar" name="LPU_SESSION"  src="LPU"         srctype="session"/>
        	<component cmptype="ActionVar" name="SHOW_FLG"     src="SHOW_FLG"    srctype="var"         put="pSHOW_FLG" len="1"/>
			<!-- права -->
			<component cmptype="ActionVar" name="pninsert"     src="PINSS"       srctype="var"         put="var1"      len="2"/>
			<component cmptype="ActionVar" name="pnupdate"     src="PUPDD"       srctype="var"         put="var2"      len="2"/>
			<component cmptype="ActionVar" name="pndelete"     src="PDELL"       srctype="var"         put="var3"      len="2"/>
			<component cmptype="ActionVar" name="pnmove_out"   src="PMOVV"       srctype="var"         put="var4"      len="2"/>
		</component>
		<component cmptype="Action" name="changeAnnStatus">
			<![CDATA[
				begin
				 	if :HOSP_HISTORY_DS = 0 then
				  		d_pkg_hosp_histories.set_discard_status(:HOSP_HISTORY,:LPU,2);
				 	else
				  		d_pkg_hosp_histories.set_discard_status(:HOSP_HISTORY,:LPU,1);
				 	end if;
				end;
			]]>
			<component cmptype="ActionVar" name="LPU"             get="LPU"             src="LPU"             srctype="var"/>
			<component cmptype="ActionVar" name="HOSP_HISTORY"    get="HOSP_HISTORY"    src="HOSP_HISTORY"    srctype="var"/>
			<component cmptype="ActionVar" name="HOSP_HISTORY_DS" get="HOSP_HISTORY_DS" src="HOSP_HISTORY_DS" srctype="var"/>
		</component>
		<component cmptype="Action" name="rollbackAnnIB">
			<![CDATA[
			begin
				d_pkg_hosp_histories.set_discard_status(:HOSP_HISTORY,:LPU,0);
			end;
			]]>
			<component cmptype="ActionVar" name="LPU"          get="LPU"          src="LPU"          srctype="var"/>
			<component cmptype="ActionVar" name="HOSP_HISTORY" get="HOSP_HISTORY" src="HOSP_HISTORY" srctype="var"/>
		</component>
		<component cmptype="Action" name="getJournalType">
			<![CDATA[
			begin
				begin
					SELECT t.journal_type
					  INTO :JOURNAL_TYPE
					  FROM d_v_hosp_plan_kinds t
					 WHERE t.ID = :HPK_ID;
				 exception when no_data_found then
						:JOURNAL_TYPE := null;
					end;

				:GenDirNumbToDirKinds := D_PKG_OPTIONS.GET('GenDirNumbToDirKinds', :LPU);
			end;
			]]>
			<component cmptype="ActionVar" name="HPK_ID"               src="C_DS_HOSP_PLAN_KINDS" srctype="ctrl"    get="g0"/>
			<component cmptype="ActionVar" name="LPU"                  src="LPU"                  srctype="session" get="g1"/>
			<component cmptype="ActionVar" name="JOURNAL_TYPE"         src="JOURNAL_TYPE"         srctype="var"     put="p0" len="1"/>
			<component cmptype="ActionVar" name="GenDirNumbToDirKinds" src="GenDirNumbToDirKinds" srctype="var"     put="p1" len="1"/>
		</component>
		<component cmptype="Action" name="getOuterLPUCablab">
			begin
				SELECT t.ID
				  INTO :LPU
				  FROM d_v_lpu t
				 WHERE t.lpudict_id = :OUTER_LPUDICT;

				:ERR:=null;
				begin
					SELECT t.id
				      INTO :CABLAB
				      FROM d_v_cablab t,
					       d_v_lpu t2
				     WHERE t.cl_code = d_pkg_option_specs.get('CABLAB_OUTER_DIRECTIONS', t2.id)
				       AND t.LPU = t2.id
				       AND t2.lpudict_id = :OUTER_LPUDICT;
				 exception when NO_DATA_FOUND then
						:ERR:='Не найден кабинет для внешних направлений. Обратитесь к администратору';
				end;
				if :DDIR_ID is not null then
					begin
						select id
			              into :DDIR_IDN
			              from D_V_DIRECTIONS d2
			             where d2.id=:DDIR_ID
			               and d2.LPU = :LPU;
				     exception when NO_DATA_FOUND then
							select d2.id
			                  into :DDIR_IDN
			                  from D_V_OUTER_DIRECTIONS od
			                       join D_V_DIRECTIONS d2 on d2.OUTER_DIRECTION_ID = od.id
					         where od.REPRESENT_DIRECTION = :DDIR_ID;
					end;
				end if;
			end;
			<component cmptype="ActionVar" name="OUTER_LPUDICT" src="OUTER_LPUDICT" srctype="var" get="g0"/>
			<component cmptype="ActionVar" name="DDIR_ID"       src="DDIR_ID"       srctype="var" get="g1"/>
			<component cmptype="ActionVar" name="CABLAB"        src="CABLAB"        srctype="var" put="p0" len="17"/>
			<component cmptype="ActionVar" name="ERR"           src="ERR"           srctype="var" put="p1" len="100"/>
			<component cmptype="ActionVar" name="LPU"           src="LPU"           srctype="var" put="p2" len="17"/>
			<component cmptype="ActionVar" name="DDIR_IDN"      src="DDIR_ID"       srctype="var" put="p3" len="17"/>
		</component>
		<component cmptype="Action" name="getCurrentCablab">
			<component cmptype="ActionVar" name="CABLAB" src="CABLAB" srctype="session"/>
			<component cmptype="ActionVar" name="CABLAB" src="CABLAB" srctype="var" put="p0" len="17"/>
		</component>

		<component cmptype="Action" name="getCurrentLPU">
			<component cmptype="ActionVar" name="LPU" src="LPU" srctype="session"/>
			<component cmptype="ActionVar" name="LPU" src="LPU" srctype="var" put="p0" len="17"/>
		</component>

		<component cmptype="Action" name="getCurrentHHDep">
			begin
				select hhd.id
				  into :HH_DEP_ID
				  from d_v_hosp_history_deps hhd
					   join d_v_hosp_histories hh on hh.id = hhd.pid
				 where hh.id = :HH_ID
				   and (hhd.date_in in (select max(date_in)
			                              from d_v_hosp_history_deps
			                             where pid = :HH_ID)
		               );
			 exception when no_data_found then
					:HH_DEP_ID := null;
			end;
			<component cmptype="ActionVar" name="HH_ID"     src="HH_ID"     srctype="var" get="g0"/>
			<component cmptype="ActionVar" name="HH_DEP_ID" src="HH_DEP_ID" srctype="var" put="p0" len="17"/>
		</component>
		<component cmptype="Action" name="ACT_CHECK_IF_HH_IS_SINGLE">
			begin
				D_PKG_HOSP_HISTORIES.CHECK_HOSP_ONE_TIME(pnLPU => :LPU,
												     pnPATIENT => :PATIENT,
												     pdDATE_IN => to_date(:DATE_IN, 'dd.mm.yyyy hh24:mi'),
												    pdDATE_OUT => to_date(:DATE_OUT, 'dd.mm.yyyy hh24:mi'),
												         psERR => :ERR,
												        psWARN => :WARN);
			end;
			<component cmptype="ActionVar" name="LPU"      src="LPU"        srctype="session"/>
			<component cmptype="ActionVar" name="PATIENT"  src="PATIENT_ID" srctype="var" get="v0"/>
			<component cmptype="ActionVar" name="DATE_IN"  src="DATE_IN"    srctype="var" get="v1"/>
			<component cmptype="ActionVar" name="DATE_OUT" src="DATE_OUT"   srctype="var" get="v2"/>
			<component cmptype="ActionVar" name="ERR"      src="ERR"        srctype="var" put="v3" len="4000"/>
			<component cmptype="ActionVar" name="WARN"     src="WARN"       srctype="var" put="v4" len="4000"/>
		</component>
  		<component cmptype="Script" name="Script">
	  		<![CDATA[
			Form.OnCreate = function () {
				setVar('HELPDATE', getVar('DDATE', 1));
				setVar('HELPID', getVar('IDD', 1));
				setVar('ID_FOR_LOCATE', getVar('ID_FOR_LOCATE', 1));
				setVar('HELPPLAN', getVar('C_HOSP_PLAN_KINDS', 1));
				setVar('SFLAG', getVar('SFLAG', 1));
				if (empty(getVar('DDIR_ID'))) setVar('DDIR_ID', getVar('DDIR', 1));
				//PMC_ID может передаваться при открытии окна
				if (empty(getVar('PMC_ID')))
					setVar('PMC_ID', getVar('PERSMEDCARD_ID', 1));
				if (getVar('SFLAG') == 1) {
					setVar('VISIT_ID', getVar('VISIT', 1));
					setVar('PMC_ID', getVar('PATIENT', 1));
				}
				if (getVar('SFLAG') == 2) {
					setVar('PMC_ID', getVar('PMC_ID', 1));
					setVar('DDIR_ID', getVar('DIRECTION', 1));
				}

				if (window.sessionStorage) {
					// PERSMEDCARD_ID сохраняется в sessionStorage при выборе пациента в расписании
					if (empty(getVar('PMC_ID')) && sessionStorage.getItem('PERSMEDCARD_ID') !== null) {
						setVar('PMC_ID', sessionStorage.getItem('PERSMEDCARD_ID'));
						sessionStorage.removeItem('PERSMEDCARD_ID');
					}
				}

				// OUTER_LPUDICT передается с формы hp_directions_edit
				setVar('OUTER_LPUDICT', getVar('OUTER_LPUDICT', 1));
				if (!empty(getVar('OUTER_LPUDICT'))) {
					executeAction('getOuterLPUCablab', function () {
						if (!empty(getVar('ERR'))) {
							alert(getVar('ERR'));
							closeWindow();
						}
						setControlProperty('PERSMEDCARD', 'enabled', false);
					}, null, 0, 0);
				}
				else {
					executeAction('getCurrentLPU', null, null, 0, 0);
					executeAction('getCurrentCablab', null, null, 0, 0);
				}

				executeAction('GetCardNumbAndStandartRights');
				if ((!empty(getVar('HELPID'))) || ((!empty(getVar('HELPDATE'))) &amp;&amp; (!empty(getVar('HELPPLAN'))))) {
					setVar('FROM_PREV_PAGE', 1);
				}
				else {
					setVar('FROM_PREV_PAGE', 0);
				}
			};
			Form.OnShow = function () {
				if (getVar('FROM_PREV_PAGE') == 1) {
					setValue('DDATE', getVar('HELPDATE'));
					setValue('C_DS_HOSP_PLAN_KINDS', getVar('HELPPLAN'));
					if (!empty(getVar('ID_FOR_LOCATE')))
						setControlProperty('GR_HPK_PLAN_DAY', 'locate', getVar('ID_FOR_LOCATE'));
					base().onJournalChange(getVar('noActive'));
				}
				else {
					executeAction('getSYS_DATE', null, null, null, 0, 0);
					base().onJournalChange(getVar('noActive'));
				}

				base().focusOnFilterField('GR_HPK_PLAN_DAY', 'DS_HPK_PLAN_DAY_PATIENT_ACTUAL_FilterItem');
			};
			Form.focusOnFilterField = function (grid, field) {
				// раскрыть фильтр по-умолчанию и установить фокус
				ToogleDisplayFilter(grid);
				var filter = field;
				if (filter && isExistsControlByName(filter)) {
					filter = getControlByName(filter).querySelector('.input-ctrl');
					if (filter) filter.focus();
				}
			}
			Form.AddPat = function () {
				setVar('C_HOSP_PLAN_KINDS', getControlProperty('GR_HPK_PLAN_DAY', 'data')['HOSP_PLAN_KIND']);
				if (getVar('PINSS') != 1) {
					alert('Недостаточно прав!');
					return;
				}
				setVar('PMC_ID', getValue('PERSMEDCARD'));
				setVar('PLANDAY_ID', null);
				if (getValue('C_DS_HOSP_PLAN_KINDS') != -1)
					setVar('PLAN_JOURNAL', getValue('C_DS_HOSP_PLAN_KINDS'));
				else setVar('PLAN_JOURNAL', null);
				setVar('DDATE', getValue('DDATE'));
				openWindow({
					name: 'HospPlanJournal/hp_add_direction',
					vars: {VIS_ID: getVar('VIS_ID'), LPU: getVar('LPU')}
				}, true, 520, 650)
						.addListener('onafterclose',
								function () {
									if (getVar('ModalResult') == 1) {
										setControlProperty('GR_HPK_PLAN_DAY', 'locate', getVar('newid'));
										base().refreshHPK_PLAN_DAY();
									}
									executeAction('ActionPlaces');
								});
			};
			Form.NearestDayFind = function () {
				if (!empty(getValue('C_DS_HOSP_PLAN_KINDS')) &amp;&amp; getValue('C_DS_HOSP_PLAN_KINDS') != '-1')
					executeAction('NearestDaySearch', base().onJournalChange);
				else alert('Не выбран журнал.');
			};
			Form.EditPat = function () {
				if (getVar('PUPDD') != 1) {
					alert('Недостаточно прав!');
					return;
				}
				if (empty(getValue('GR_HPK_PLAN_DAY'))) {
					alert('Не выбрана запись.');
					return;
				}
				setVar('PLANDAY_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID']);
				setVar('PLAN_JOURNAL', getControlProperty('GR_HPK_PLAN_DAY', 'data')['HOSP_PLAN_KIND']);
				setVar('IDD', getControlProperty('GR_HPK_PLAN_DAY', 'data')['THISPLANID']);
				setVar('DDATE', getValue('DDATE'));
				setControlProperty('GR_HPK_PLAN_DAY', 'locate', getValue('GR_HPK_PLAN_DAY'));
				openWindow({name: 'HospPlanJournal/hp_add_direction', vars: {LPU: getVar('LPU')}}, true, 520, 650)
						.addListener('onafterclose',
								function () {
									if (getVar('ModalResult') == 1)
										base().refreshHPK_PLAN_DAY();
								});
			};
			Form.BackDay = function () {
				executeAction('prevDay', base().onJournalChange, null, null);
			};
			Form.HistHosp = function () {
				if (empty(getValue('GR_HPK_PLAN_DAY'))) {
					alert('Не выбрана запись, либо остутствует план госпитализации!');
					return;
				}
				setVar('PMC_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['PATIENT_ID']);
				setVar('PMC_FIO', getControlProperty('GR_HPK_PLAN_DAY', 'data')['PATIENT']);
				openWindow('HospPlan/hosp_hist', true, 1000, 510);
			};
			Form.DirSearch = function () {
				if (empty(getValue('DIR_PREF')) && empty(getValue('DIR_NUMB'))) {
					alert('Для поиска необходимо выбрать номер и префикс направления!');
					return;
				}
				executeAction('startSearchDirection', base().AfterSearchDirection);
			};
			Form.AfterSearchDirection = function () {
				if (getVar('DIR_RESULT') == 0 || getVar('DIR_RESULT') == -1) {
					alert('Не найдено направление по данному префиксу и номеру!');
					return;
				}
				if (getVar('DIR_RESULT') == -2) {
					alert('Найдено более одного направления по данному префиксу и номеру!');
					return;
				}
				if (getVar('DIR_HAVE_NEXT') == 1)
					setControlProperty('dirnex', 'enabled', true);
				else
					setControlProperty('dirnex', 'enabled', false);
				if (getVar('DIR_HAVE_PREV') == 1)
					setControlProperty('dirpre', 'enabled', true);
				else
					setControlProperty('dirpre', 'enabled', false);
				base().onJournalChange();
			};
			Form.DirNext = function () {
				executeAction('searchDirNext', base().afterSearchDirNext, null, null);
			};
			Form.afterSearchDirNext = function () {
				setControlProperty('dirpre', 'enabled', true);
				if (getVar('DIR_HAVE_NEXTT') != 1)
					setControlProperty('dirnex', 'enabled', false);
				base().onJournalChange();
			};
			Form.DirPrev = function () {
				executeAction('searchDirPrev', base().afterSearchDirPrev, null, null);
			};
			Form.afterSearchDirPrev = function () {
				setControlProperty('dirnex', 'enabled', true);
				if (getVar('DIR_HAVE_PREVV') != 1)
					setControlProperty('dirpre', 'enabled', false);
				base().onJournalChange();
			};

			Form.PatSearch = function () {
				if (!empty(getValue('PERSMEDCARD'))) {
					executeAction('SearchPatient', base().AfterSearchPatient, null, null);
				}
				else {
					alert('Для поиска необходимо выбрать пациента.');
				}
			};
			Form.AfterSearchPatient = function () {
				if (getVar('HAVE_NEXT') == 1)
					setControlProperty('patnex', 'enabled', true);
				else
					setControlProperty('patnex', 'enabled', false);
				if (getVar('HAVE_PREV') == 1)
					setControlProperty('patpre', 'enabled', true);
				else
					setControlProperty('patpre', 'enabled', false);
				base().onJournalChange();
			};
			Form.PatNext = function () {
				executeAction('SearchPatientNext', base().AfterSearchPatientNext, null, null);
			};
			Form.AfterSearchPatientNext = function () {
				setControlProperty('patpre', 'enabled', true);
				if (getVar('HAVE_NEXTT') != 1) {
					setControlProperty('patnex', 'enabled', false);
				}
				base().onJournalChange();
			};
			Form.PatPrev = function () {
				executeAction('SearchPatientPrev', base().AfterSearchPatientPrev, null, null);
			};
			Form.AfterSearchPatientPrev = function () {
				setControlProperty('patnex', 'enabled', true);
				if (getVar('HAVE_PREVV') != 1) {
					setControlProperty('patpre', 'enabled', false);
				}
				base().onJournalChange();
			};
			Form.ForwDay = function () {
				executeAction('nextDay', base().onJournalChange, null, null);
			};
			Form.OtobrDay = function () {
				base().onJournalChange();
			};
			Form.ChangeDate = function () {
				if (empty(getValue('GR_HPK_PLAN_DAY'))) {
					alert('Не выбрана запись.');
					return;
				}
				setVar('ModalResult', 0);
				setVar('C_HOSP_PLAN_KINDS', getControlProperty('GR_HPK_PLAN_DAY', 'data')['HOSP_PLAN_KIND']);
				executeAction('CheckRightsREC', base().ChangeDateAfter, null, null);
			};
			Form.ChangeDateAfter = function () {
				if (!empty(getValue('C_DS_HOSP_PLAN_KINDS'))) {
					if (getVar('CHREC') &lt; 1) {
						alert('Недостаточно прав!');
						return;
					}
					setVar('GR_HPK_PLAN_DAY', getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID']);
					setVar('FLAG_MOVE', 1);
					openWindow('HospPlan/hospplanperiod', true, 1000, 540)
							.addListener('onafterclose', function () {
										setValue('DDATE', getVar('NEW_PLAN_DDATE'));
										setControlProperty('GR_HPK_PLAN_DAY', 'locate', getValue('GR_HPK_PLAN_DAY'));
										base().refreshHPK_PLAN_DAY();
									}
									, null, false);
				}
				else {
					setVar('GR_HPK_PLAN_DAY', getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID']);
					setVar('FLAG_MOVE', 1);
					openWindow('HospPlan/hospplanperiod', true, 1000, 540)
							.addListener('onafterclose', function () {
										setValue('DDATE', getVar('NEW_PLAN_DDATE'));
										setControlProperty('GR_HPK_PLAN_DAY', 'locate', getValue('GR_HPK_PLAN_DAY'));
										base().refreshHPK_PLAN_DAY();
									}
									, null, false);
				}
			};
			Form.GoIBAfterCheckRights = function () {
				if (getVar('CHIB') &lt;= 1) {
					alert('Недостаточно прав!');
					return;
				}
				if (confirm('Отправить на создание ИБ?')) {
					setVar('HPK_PL_DAY_VAR', getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID']);
					executeAction('ActionIB', function () {
						base().refreshHPK_PLAN_DAY();
						setControlProperty('GR_HPK_PLAN_DAY', 'locate', getValue('GR_HPK_PLAN_DAY'));
					}, null, null);
				}
			};
			Form.GoIB = function () {
				if (empty(getValue('GR_HPK_PLAN_DAY'))) {
					alert('Не выбрана запись, либо остутствует план госпитализации!');
					return;
				}
				executeAction('CheckRightsIB', function () {
					base().GoIBAfterCheckRights();
				}, null, null);
			};
			Form.GoDelPatAfterCheckRights = function () {
				setVar('HPK_PL_DAY_VAR', getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID']);
				if (!empty(getValue('C_DS_HOSP_PLAN_KINDS')) && getValue('C_DS_HOSP_PLAN_KINDS') != -1) {
					if (getVar('CHREC') &lt; 1) {
						alert('Недостаточно прав!');
						return;
					}
					executeAction('ActionDelPlanDay', base().refreshWithCurrentLocate, null, null);//function(){base().refreshHPK_PLAN_DAY();}, null, null);
				}
				else {
					executeAction('ActionDelPlanDay', base().refreshWithCurrentLocate, null, null);//function(){base().refreshHPK_PLAN_DAY();}, null, null);
				}
			};
			Form.DelPat = function () {
				if (!empty(getValue('GR_HPK_PLAN_DAY'))) {
					if (confirm('Вы действительно хотите удалить запись?')) {
						setVar('C_HOSP_PLAN_KINDS', getControlProperty('GR_HPK_PLAN_DAY', 'data')['HOSP_PLAN_KIND']);
						executeAction('CheckRightsREC', base().GoDelPatAfterCheckRights);
					}
				}
				else {
					alert('Не выбрана запись.');
				}
			};
			Form.onJournalChange = function (_param) {
				executeAction('ActionMax_Prior');

				executeAction('ActionPlanForDate', function () {
//        executeAction('getQuantBeds', function() {
//          setCaption('quant_beds', getVar('quant_beds').replace(/(\d) (\[)/g, '$1 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; $2'));
//        });
					if (getValue('C_DS_HOSP_PLAN_KINDS') == '-1')
						setControlProperty('BedFondPlan', 'enabled', false)
					else  setControlProperty('BedFondPlan', 'enabled', true);
				});

				executeAction('getJournalType', function () {
					base().refreshHPK_PLAN_DAY(_param);
					if (getVar('JOURNAL_TYPE') === '1') {
						setValue('DS_HPK_PLAN_DAY_RECORD_STATUS_FilterItem', '0');
					} else {
						setValue('DS_HPK_PLAN_DAY_RECORD_STATUS_FilterItem', 0);
					}
				});
			};
			Form.genRegPat = function () {
				setVar('PERSMEDCARD_ID', getVar('PATIENT_ID'));
				setVar('HPK_PLAN_JOURNAL', getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID']);
				setVar('PARAM_VISIT_ID', null);
				openWindow({
					name: 'GenRegistry/reg_full',
					vars: {
						MODE: 'close'
					}
				}, true)
						.addListener('onafterclose', function () {
							//if (getVar('ModalResult') == 1) {
							base().refreshHPK_PLAN_DAY();
							//}
						});
			}
			Form.RecordPat = function () {
				setVar('Modalresult', 0);
				setVar('SERV_ID', null);
				setVar('PARAM_VISIT_ID', null);
				// setVar('PARAM_DISEASECASE_ID', getVar('DISEASECASE'));
				// setVar('PARAM_HH_DEP', getVar('HH_DEP'));
				setVar('PARAM_REG_TYPE', 1);
				setVar('PERSMEDCARD_ID', getVar('PATIENT_ID'));
				setVar('CONTRACT_CODE', null);
				setVar('CONTRACT_ID', null);
				setVar('CONTR_AMI_DIR_CODE', null);
				setVar('CONTR_AMI_DIR_ID', null);
				setVar('HPK_PLAN_JOURNAL', getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID']);

				executeAction('getDefDepFromOption', function () {
					openWindow('Registry/reg_short', true, 1000, 800)
							.addListener('onafterclose', function () {
								if (getVar('ModalResult') == 1)
									base().refreshHPK_PLAN_DAY();
							});
				});
			}
			Form.MoveHistory = function () {
				setVar('PRIMARY', getValue('GR_HPK_PLAN_DAY'));
				openWindow('HospPlan/move_history', true, 400, 250);
			}
			Form.showPopUpjt = function (pItemName) {
				if (Form.jt == 1) {
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), pItemName, true);
				} else {
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), pItemName, false);
				}
			}
			Form.onPopupFunc = function () {
				_grd = getControlProperty('GR_HPK_PLAN_DAY', 'data');
				if (!empty(getValue('C_DS_HOSP_PLAN_KINDS')) && empty(getValue('DDATE'))) {
					setVar('UNFILLED_DATE', 1);
				} else {
					setVar('UNFILLED_DATE', 0);
				}

				if (_grd['JT'] == '0')/*не очередь*/
				{
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pSHOW_OPERS', false);
				}
				else {
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pSHOW_OPERS', true);
				}

				if (getVar('UNFILLED_DATE') == 1 || getVar('AVAIL_ADD') == 0) {
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pADD', true);
				} else {
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pADD', false);
				}

				if (empty(getVar('OUTER_LPUDICT'))) {
					Form.jt = (_grd['JT']) ? _grd['JT'] : 0;
					if ((getVar('JOURNAL_TYPE') == '1' || Form.jt == 1) && _grd['RECORD_STATUS'] == 0) {
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pRECORD', false);
					} else {
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pRECORD', true);
					}


					if (empty(getValue('GR_HPK_PLAN_DAY'))) //pCANC_ANN pANN pANN_DO
					{
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pEDIT', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pMOVE_HISTORY', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDEL', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCANC_ANN', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANN', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANN_DO', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT_S', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT_CANC', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pOPENIB', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDIR_S', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANALYZE', true);
						//переместить на другую дату
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCH_PLAN', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCH_PLAN_RAZD', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pREPS', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pSHOW_VMP', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHIST_HOSP', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pFAC_ACC', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pRAZDELITEL', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'RAZD2', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'RAZD3', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'RAZD4', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCancelHosp', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pReverseCancelHosp', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCREATEIB_true', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCREATEIB_false', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDIR_SERVICES', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDIR_SERVICES2', true);

					}
					else {
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pMOVE_HISTORY', false);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'RAZD2', false);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'RAZD3', false);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'RAZD4', false);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pRAZDELITEL', false);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pREPS', false);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pFAC_ACC', false);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANALYZE', false);
                        PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCREATEIB_true', true);
                        PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCREATEIB_false', true);

						setVar('PATIENT_ID', _grd['PATIENT_ID']);
						setVar('AGENT_ID', _grd['PATIENT_AGENT']);
						setVar('HH_ID', _grd['HOSP_HISTORY']);
						setVar('HP_ID', _grd['ID']);

						if (_grd['BEDS'] != 0)
						/*если есть ИБ,то не доступны Редактировать, Удалить*/
						{
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pEDIT', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDEL', true);
						} else {
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pEDIT', false);
							/*если нет ИБ, и оформлен отказ,то не доступно Удалить*/
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDEL', (_grd['IS_CANCELED'] == 1));
						}

						/*Если статус записи Отработана или есть отказ от госпитализации,
						 не доступен пункт Перенести на другую дату*/
						if ((_grd['RECORD_STATUS'] == 1) || (_grd['IS_CANCELED'] == 1)) {
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCH_PLAN', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCH_PLAN_RAZD', true);
						}
						else {
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCH_PLAN', false);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCH_PLAN_RAZD', false);
						}

						/*Направления на услуги показываем всегда, кроме случая, когда ИБ списана*/
						if (_grd['HOSP_HISTORY_DS'] == 1) {
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDIR_SERVICES', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDIR_SERVICES2', true);
						}
						else {
							/*если есть ИБ и есть ИБ сопровождающего то показываем направления пациента и сопровождающего, иначе - только пациента*/
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDIR_SERVICES', !empty(_grd['RELATIVE_HOSP_HISTORY']));
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDIR_SERVICES2', empty(_grd['RELATIVE_HOSP_HISTORY']));
						}

						/*Иб действует и пациент не выписан*/
						if (!empty(_grd['HOSP_HISTORY']) && _grd['HOSP_HISTORY_DS'] == 0 && _grd['BEDS'] != 3) {
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCANC_ANN', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANN_DO', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT_S', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT_CANC', false);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANN', false);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pOPENIB', false);
						}
						/*ИБ списана*/
						else if (_grd['HOSP_HISTORY_DS'] == 1) {
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANN', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCANC_ANN', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANN_DO', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT_S', false);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT_CANC', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pOPENIB', true);
						}
						/*ИБ направлена на списание*/
						else if (_grd['HOSP_HISTORY_DS'] == 2) {
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCANC_ANN', false);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANN_DO', false);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT_S', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT_CANC', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANN', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pOPENIB', true);
						}
						else {/*нет ИБ или выписан*/
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCANC_ANN', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANN_DO', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT_CANC', true);
							if (empty(_grd['HOSP_HISTORY'])) {
								Form.showPopUpjt('pHOSPIT');
								PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT_S', true);
								PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANN', true);
								PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pOPENIB', true);
							}
							else {
								PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT', true);
								PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANN', false);
								PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pOPENIB', false);
							}
						}

						if ((_grd['HPK_JOURNAL_TYPE']) != 0 || _grd['IS_CANCELED'] == 1)/*0- обычный, то есть ниже только для очередей
						 или если есть отказ от госпитализации*/
						{
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT_S', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT_CANC', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANN', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pOPENIB', true);
						}

						/*Отказ от госпитализации, отправлен на создание ИБ*/
						if (!empty(_grd['HOSP_HISTORY'])) {
							/*18.12.2013 #66488 Доработка "Истории заболеваний и результаты исследований"отображать Причину отказа от госпитализации другого ГУЗ НСО.*/
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCancelHosp', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pReverseCancelHosp', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCREATEIB_true', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCREATEIB_false', true);
						} else {
							if (_grd['IS_CANCELED'] == 1) {
								PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCancelHosp', true);
								PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pReverseCancelHosp', false);
								PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCREATEIB_true', true);
								PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCREATEIB_false', true);
							} else {
								Form.showPopUpjt('pCancelHosp');
								PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pReverseCancelHosp', true);
								/*  7078:5a20587ad107 - Бурнаев 12.12.2012
								 #87153: Перенести на WEB-интерфейс возможность подтверждать направление в Журнал госитализации
								 #81221: Настройка прав на мед. словарь "видимость мед. словаря по услуге"
								 */
								if ((_grd['hosp_ready_rights'] === undefined) && (_grd['IS_CANCELED'] == 0)) {
									setVar('HOSP_PLAN_KIND', _grd['HOSP_PLAN_KIND']);
									executeAction('A_hosp_ready_rights', function () {
										if (getVar('hosp_ready_rights') == 1) {

											if (_grd['IS_READY'] == 1) {
												Form.showPopUpjt('pCREATEIB_true');
												PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCREATEIB_false', true);
											} else {
												PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCREATEIB_true', true);
												Form.showPopUpjt('pCREATEIB_false');
											}
										}
									});
								}
							}

						}
						/*ВМП,Хронология*/
						if (_grd['IS_CANCELED'] == 1) {
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pSHOW_VMP', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHIST_HOSP', true);
						} else {
							Form.showPopUpjt('pSHOW_VMP');
							Form.showPopUpjt('pHIST_HOSP');
						}

					}

				} else {// если записть в журнал чужого ЛПУ

					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pRECORD', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pEDIT', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pMOVE_HISTORY', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDEL', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCANC_ANN', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANN', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANN_DO', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT_S', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHOSPIT_CANC', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pOPENIB', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDIR_S', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pANALYZE', true);
					//переместить на другую дату
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCH_PLAN', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCH_PLAN_RAZD', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pREPS', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pSHOW_VMP', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pHIST_HOSP', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pFAC_ACC', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pRAZDELITEL', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'RAZD2', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'RAZD3', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'RAZD4', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDIR_SERVICES', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDIR_SERVICES2', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pCancelHosp', true);
					PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pReverseCancelHosp', true);
					if (empty(getValue('GR_HPK_PLAN_DAY'))) {
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pEDIT', true);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDEL', true);
					}
					else {
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pEDIT', false);
						PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDEL', false);
						if (_grd['BEDS'] != 0) {
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pEDIT', true);
							PopUpItem_SetHide(getControlByName('P_HPK_PLAN'), 'pDEL', true);
						}
					}
				}
				if (typeof base().SHOW_POPUP_EDIT == 'function') {
					base().SHOW_POPUP_EDIT();//для РКОД
				}
			};
			Form.onPaint = function (_dataArray) {
				var _domObject = getControlByName('PAT_STATUS');
				switch (parseInt(_dataArray['BEDS'])) {
					case 0: {
						_domObject.style.backgroundColor = '';
						break;
					}
					case 4: {
						_domObject.style.backgroundColor = '#FF0000';
						break;
					}
					case 1: {
						_domObject.style.backgroundColor = '#669999';
						break;
					}
					case 2: {
						_domObject.style.backgroundColor = '#66CC66';
						break;
					}
					case 3: {
						_domObject.style.backgroundColor = '#6699FF';
						break;
					}
					default : {
						_domObject.style.backgroundColor = '';
					}
				}
				switch (parseInt(_dataArray['HOSP_HISTORY_DS'])) {
					case 1: {
						_domObject.style.backgroundColor = '#996600';
						break;
					}
					case 2: {
						_domObject.style.backgroundColor = '#A7A7A7';
						break;
					}
				}
				if (_dataArray['IS_CANCELED'] == 1) _domObject.style.backgroundColor = '#db9d00';
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
			};
			Form.ShowHideLegend = function () {
				var _dom = getControlByName('legenddiv');
				if (_dom.style.display == 'none') {
					setCaption('link1', 'Скрыть легенду');
					_dom.style.display = '';
				}
				else {
					setCaption('link1', 'Показать легенду');
					_dom.style.display = 'none';
				}
			};
			Form.toHosp = function () {
				if (!empty(getValue('GR_HPK_PLAN_DAY'))) {
					setVar('ModalResult', 0);
					setVar('HPK_PLAN_JOURNAL_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID']);
					setVar('PMC_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['PATIENT_ID']);
					setVar('PMC_FIO', getControlProperty('GR_HPK_PLAN_DAY', 'data')['PATIENT']);
					setVar('DIRECTION_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['DIRECTION']);
					setVar('HOSP_PLAN_KIND', getControlProperty('GR_HPK_PLAN_DAY', 'data')['HOSP_PLAN_KIND']);
					openWindow('HospPlan/hospitalisation', true)
							.addListener('onafterclose',
									function () {
										if (getVar('ModalResult') == 1) {
											setControlProperty('GR_HPK_PLAN_DAY', 'locate', getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID'] + getVar('HH_ID'));
											base().refreshHPK_PLAN_DAY();
										}
									});
				}
				else {
					alert('Не выбрана запись, либо отсутствует план госпитализации!');
				}
			};
			Form.checkIfHHIsSingle = function () {
				var data = getControlProperty('GR_HPK_PLAN_DAY', 'data');
				['PATIENT_ID', 'DATE_IN', 'DATE_OUT'].forEach(function (e) {
					setVar(e, data[e]);
				});
				executeAction('ACT_CHECK_IF_HH_IS_SINGLE', function () {
					if (!empty(getVar('ERR'))) {
						showAlert(getVar('ERR'));
					} else if (!empty(getVar('WARN'))) {
						showConfirm(getVar('WARN') + ' Вы действительно хотите госпитализировать?', null, 100, 100, base().toHosp, null, 'yesno');
					} else {
						base().toHosp();
					}
				});
			};
			Form.CancelHosp = function () {
				if (confirm('Вы действительно хотите отменить госпитализацию?')) {
					setVar('HH_ID_DEL', getControlProperty('GR_HPK_PLAN_DAY', 'data')['HOSP_HISTORY']);
					executeAction('ACancelHosp', function () {
						setControlProperty('GR_HPK_PLAN_DAY', 'locate', getVar('LOC'));
						base().refreshHPK_PLAN_DAY();
					});
				}
			}
			Form.ViewQuotes = function () {
				if (empty(getValue('C_DS_HOSP_PLAN_KINDS')) || getValue('C_DS_HOSP_PLAN_KINDS') == -1) {
					alert('Не выбран журнал!');
					return;
				}
				setVar('JOURNAL_ID', getValue('C_DS_HOSP_PLAN_KINDS'));
				openWindow('HospPlan/showQuotes', true);
			};
			Form.showLoadKF = function () {
				setVar('JOURNAL_ID', getValue('C_DS_HOSP_PLAN_KINDS'));
				setVar('JOURNAL_DATE', getValue('DDATE'));
				openWindow('HospPlan/showLoadKF', true);
			};
			Form.showPlaning = function () {
				setVar('JOURNAL_ID', getValue('C_DS_HOSP_PLAN_KINDS'));
				setVar('JOURNAL_DATE', getValue('DDATE'));
				openWindow('HospPlan/showPlaning', true);
			};
			Form.ADD_PERSMEDCARD = function (_dom) {
				setVar('PERSMEDCARD', getControlValue(_dom));
				openWindow('Persmedcard/persmedcard_edit', true, 800, 580)
						.addListener('onafterclose', function () {
							if (getVar('ModalResult') == 1) {
								setControlProperty('GR_HPK_PLAN_DAY', 'locate', getValue('GR_HPK_PLAN_DAY'));
								refreshDataSet('DS_HPK_PLAN_DAY');
							}
						});
			};
			Form.SHOWHIST = function () {
				var pmc_array = getControlProperty('GR_HPK_PLAN_DAY', 'data');
				setVar('PatientID', pmc_array['PATIENT_ID']);
				setVar('PatientFIO', pmc_array['PATIENT']);
				openWindow('DiseaseCase/diseasecase', true, 1000, 700);

			};
			Form.annulmentHH = function () {
				if (confirm('Аннулированная ИБ будет недоступна для работы. Для высвобождения номера требудется подтверждение в регистратуре. Продолжить?')) {
					_grd = getControlProperty('GR_HPK_PLAN_DAY', 'data');
					setVar('HOSP_HISTORY', _grd['HOSP_HISTORY']);
					setVar('HOSP_HISTORY_DS', _grd['HOSP_HISTORY_DS']);
					executeAction('changeAnnStatus', function () {
						setControlProperty('GR_HPK_PLAN_DAY', 'locate', getValue('GR_HPK_PLAN_DAY'));
						refreshDataSet('DS_HPK_PLAN_DAY');
					});
				}
			}

			Form.rollbackIB = function () {
				if (confirm('Отменить аннулирование ИБ? Часть информации по госпитализации восстановлена не будет')) {
					setVar('HOSP_HISTORY', _grd['HOSP_HISTORY']);
					executeAction('rollbackAnnIB', function () {
						setControlProperty('GR_HPK_PLAN_DAY', 'locate', getValue('GR_HPK_PLAN_DAY'));
						base().refreshHPK_PLAN_DAY();
					});
				}
			};
			Form.setVMP = function () {
				setVar('HPK_PLAN_JOURNAL', getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID']);
				setVar('ModalResult', 0);
				openWindow('HospPlan/setPrivilege', true)
						.addListener('onafterclose',
								function () {
									if (getVar('ModalResult') == 1) {
										setControlProperty('GR_HPK_PLAN_DAY', 'locate', getValue('GR_HPK_PLAN_DAY'));
										base().refreshHPK_PLAN_DAY();
									}
								});
			};
			Form.showPayAcc = function () {
				setVar('PERSMEDCARD', getControlProperty('GR_HPK_PLAN_DAY', 'data')['PATIENT_ID']);
				setVar('AGENT', getControlProperty('GR_HPK_PLAN_DAY', 'data')['PATIENT_AGENT']);
				openWindow('PersonalAccount/patient_contracts', true, 1222, 684);
			};
			Form.showAnalyze = function () {
				setVar('PERSMEDCARD', getControlProperty('GR_HPK_PLAN_DAY', 'data')['PATIENT_ID']);
				setVar('DISEASECASE_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['DISEASECASE']);
				openWindow('HospPlan/patient_analyze', true);
			};
			Form.showHHOperations = function () {
				setVar('FROM_HOSP_PLAN', 1);
				setVar('HOSP_HISTORY_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['HOSP_HISTORY']);
				setVar('HPK_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID']);
				setVar('PERSMEDCARD', getControlProperty('GR_HPK_PLAN_DAY', 'data')['PATIENT_ID']);
				setVar('DISEASECASE', getControlProperty('GR_HPK_PLAN_DAY', 'data')['DISEASECASE']);
				executeAction('getCurrentHHDep', null, null, 0, 0);
				openWindow('ArmPatientsInDep/Wrappers/direction_operations', true);
			};
			Form.showDirectionServiceControl = function (type) {
				setVar('TYPE', type);
				if (!empty(type)) type = type + '_'; else type = '';

				var _grd = getControlProperty('GR_HPK_PLAN_DAY', 'data');
				setVar('HH_ID', _grd[type + 'HOSP_HISTORY']);
				setVar('PMC_ID', _grd[type + 'PATIENT_ID']);
				setVar('PMC_FIO', _grd[type + 'PATIENT']);
				setVar('DISEASECASE', _grd[type + 'DISEASECASE']);
				setVar('PAYMENT_KIND_ID', _grd['PAYMENT_KIND_ID']);
				openWindow({name: 'HospPlan/Dirs/hh_direction_service_control', vars: {TYPE: getVar('TYPE')}}, true);
			};

			Form.PrintPatientAgreement = function () {
				setVar('ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID']);
				setVar('AGENT_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['PATIENT_AGENT']);
				printReportByCode('patient_agreement');
			};
			Form.PrintStacionaryAct = function () {
				setVar('ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID']);
				openWindow('Reports/HospPlan/stationary_act', true);
			};
			Form.PrintComissionVMP = function () {
				setVar('ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID']);
				openWindow('Reports/HospPlan/comission_vmp_protocol_call', true, 350, 375);
			}
			Form.PrintPlanOnDate = function () {
				setVar('JOURNAL_ID', getValue('C_DS_HOSP_PLAN_KINDS'));
				if (!empty(getVar('JOURNAL_ID')) && (getVar('JOURNAL_ID') > 0)) {
					setVar('DATE_PLAN', getValue('DDATE'));
					printReportByCode('hosp_plan_on_date');
				} else {
					alert('Не выбран журнал для отчета')
				}
			}
			Form.PrintReportJournalPatient = function () {
				openWindow('Reports/HospPlan/journal_hpk_patient_call', true);
			};
			Form.PrintReportPlanDir = function () {
				setVar('DATE', getControlProperty('GR_HPK_PLAN_DAY', 'data')['PLAN_DATE']);
				printReportByCode('hpk_plan_directions', 830, 768);
			};
			Form.PrintReportPlanAnDir = function () {
				setVar('DATE', getControlProperty('GR_HPK_PLAN_DAY', 'data')['PLAN_DATE']);
				printReportByCode('Analiz_otvet', 830, 768);
			};
			Form.PrintFirstList = function () {

				var HOSP_HISTORY_DS = getControlProperty('GR_HPK_PLAN_DAY', 'data')['HOSP_HISTORY_DS'];
				if (HOSP_HISTORY_DS == 2) {
					alert('ИБ направлена на удаление');
					return;
				}
				if (HOSP_HISTORY_DS == 1) {
					alert('ИБ аннулирована');
					return;
				}
				if (getControlProperty('GR_HPK_PLAN_DAY', 'data')['BEDS'] == 0) {
					alert('История болезни не создана');
					return;
				}
				setVar('HH_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['HOSP_HISTORY']);
				if (getControlProperty('GR_HPK_PLAN_DAY', 'data')['HH_TYPE'] == 1)
					printReportByCode('birth_history', 830, 768);
				else
					printReportByCode('hosphistory_head', 830, 768);

			};
			Form.PrintStopCard = function () {
				setVar('REP_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['HOSP_HISTORY']);
				printReportByCode('stop_pregnancy_card', 830, 768);
			};
			Form.PrintPatientsIndept = function () {
				openWindow('Reports/HospPlan/patient_indept_sys_hpk_call', true);
			};
			Form.PrintReportListPat = function () {
				openWindow('Reports/HospPlan/patient_incom_date_call', true);
			};
			
			Form.reHideInfo = function () {
				if (getControlByName('HINT1').style.display == 'none') {
					getControlByName('HINT1').style.display = '';
				}
				else {
					getControlByName('HINT1').style.display = 'none';
				}
			};
			Form.openWindowHint = function () {
				showLegend("Журнал госпитализации",
						[{
							backgroundColor: "#FFF",
							caption: 'История болезни не создана'
						}, {
							backgroundColor: "#F00",
							caption: 'Не направлен в отделение'
						}, {
							backgroundColor: "#699",
							caption: 'Направлен в отделение'
						}, {
							backgroundColor: "#6C6",
							caption: 'Госпитализирован'
						}, {
							backgroundColor: "#69F",
							caption: 'Выписан'
						}, {
							backgroundColor: "#A7A7A7",
							caption: 'ИБ направлена на удаление'
						}, {
							backgroundColor: "#960",
							caption: 'ИБ аннулирована'
						}, {
							backgroundColor: "#db9d00",
							caption: 'Отказ от госпитализации'
						}], 425, 260
				);
			};
			Form.createIb = function (is_ready) {
				setVar('HPK_PLAN_DAY_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID']);
				setVar('IS_READY', is_ready);
				executeAction('setIsReady', function () {
					setControlProperty('GR_HPK_PLAN_DAY', 'locate', getValue('GR_HPK_PLAN_DAY'));
					base().refreshHPK_PLAN_DAY();
				});
			};
			Form.PrintPatientAgreePers = function () {
				setVar('AGENT_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['PATIENT_AGENT']);
				printReportByCode('reception_agreement_personal_info');
			}
			Form.PrintPatientAgreeSif = function () {
				setVar('HH_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['HOSP_HISTORY']);
				setVar('PATIENT_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['PATIENT_ID']);
				printReportByCode('reception_agreement_sifilis');
			}
			Form.PrintPatientAgreeSifDop = function () {
				printReportByCode('reception_agreement_sifilis_dop');
			}
			Form.refreshHPK_PLAN_DAY = function (_param) {
				if (!empty(getVar('JOURNAL_TYPE')) || (getVar('JOURNAL_TYPE') == 0 && getValue('C_DS_HOSP_PLAN_KINDS') != -1))
					executeAction('GetRight', null, null, 0, 0);
				if (empty(_param)) {
					refreshDataSet('DS_HPK_PLAN_DAY');
				}
			}
			Form.refreshWithCurrentLocate = function () {
				var rows = getCloneObjectsByRepeaterName('GR_HPK_PLAN_DAY_Row', 'GR_HPK_PLAN_DAY_Row');
				for (var i = 0; i < rows.length; i++) {
					if (rows[i].className == 'activdata') {
						if (rows[i + 1] != undefined) {
							setControlProperty('GR_HPK_PLAN_DAY', 'locate', rows[i + 1].clone.data['ID']);
							//refreshDataSet('DS_HPK_PLAN_DAY');
							break;
						} else if (rows[i - 1] != undefined) {
							setControlProperty('GR_HPK_PLAN_DAY', 'locate', rows[i - 1].clone.data['ID']);
							//refreshDataSet('DS_HPK_PLAN_DAY');
							break;
						}
						//var prior = getControlByName('GR_HPK_PLAN_DAY').querySelectorAll('[cmptype][class*="prior_page"]')[0];
						//RangeGotoPriorPage(prior);
						break;
					}
				}
				base().refreshHPK_PLAN_DAY();
			}
			Form.cancelHosp = function () {
				setVar('LOC', getValue('GR_HPK_PLAN_DAY'));
				setVar('HOSP_DIR', getControlProperty('GR_HPK_PLAN_DAY', 'data')['DIRECTION']);
				setVar('HPK_ID', getValue('GR_HPK_PLAN_DAY'));
				// setVar('HOSP_DIR_LPU', getVar('LPU_ID'));
				openWindow('Directions/direction_cancel_reason', true)
						.addListener('onafterclose', function () {
							if (getVar('ModalResult') == 1) {
								setControlProperty('GR_HPK_PLAN_DAY', 'locate', getVar('LOC'));
								base().refreshHPK_PLAN_DAY();
							}
						});
			}
			Form.reverseCancelHosp = function () {
				setVar('LOC', getValue('GR_HPK_PLAN_DAY'));
				setVar('HOSP_DIR', getControlProperty('GR_HPK_PLAN_DAY', 'data')['DIRECTION']);
				setVar('HPK_ID', getValue('GR_HPK_PLAN_DAY'));
				// setVar('HOSP_DIR_LPU', getVar('LPU_ID'));
				executeAction('reverseCancelHosp', function () {
					setControlProperty('GR_HPK_PLAN_DAY', 'locate', getVar('LOC'));
					base().refreshHPK_PLAN_DAY();
				});
			}
			Form.massPrintAdrList = function (type) {
				setVar('REP_DATE', getValue('DDATE'));
				setVar('REP_TYPE', type);

				if (!empty(getValue('GR_HPK_PLAN_DAY_SelectList')))
					setVar('IDS', getValue('GR_HPK_PLAN_DAY_SelectList'));

				openWindow('Reports/HospPlan/adr_list_mass_call', true);
			}
			Form.getRealPRIMARY = function () {
				/*костыль для присоединенных документов, поскольку им нужна ID. Эту функция вызывается в компоненте AutoPopupMenu.
				 Сам  костыль сделан в  Jun 07 2013 #110975 Ошибка при выборе в контекстном меню пункта "Присоединенные документы"	*/
				return getControlProperty('GR_HPK_PLAN_DAY', 'data')['ID'];
			}
			Form.afterSelPMC = function () {
				if (getVar('newid')) {
					setControlProperty('GR_HPK_PLAN_DAY', 'locate', getVar('newid'));
					refreshDataSet('DS_HPK_PLAN_DAY');
					setVar('newid', '');
					executeAction('ActionPlaces');
				}
			}
			Form.prepareVariables = function() {
			    if (!empty(getValue('GR_HPK_PLAN_DAY'))) {
			        var data = getControlProperty('GR_HPK_PLAN_DAY', 'data');
					setVar('HPK_PLAN_JOURNAL_ID', data['ID']);
					setVar('PMC_ID', data['PATIENT_ID']);
					setVar('PMC_FIO', data['PATIENT']);
					setVar('DIRECTION_ID', data['DIRECTION']);
					setVar('HOSP_PLAN_KIND', data['HOSP_PLAN_KIND']);
			    }
			};
			Form.setBedLoadKF = function(){
				setControlProperty('BedLoadKF','enabled',!empty(getValue('DDATE')));
				if(!empty(getValue('DDATE'))){
					getControlByName('BedLoadKF').removeAttribute('title')
				}else{
					getControlByName('BedLoadKF').setAttribute('title','Необходимо заполнить дату')
				}
			}
			]]>
		</component>
	  	<component cmptype="Script" name="script_tat">
			<![CDATA[
			Form.PrintStatCard = function () {
				setVar('REP_ID', getControlProperty('GR_HPK_PLAN_DAY', 'data')['HOSP_HISTORY']);
				if (getControlProperty('GR_HPK_PLAN_DAY', 'data')['BEDS'] == 3) {
					printReportByCode('outhost_stat_card', 830, 768);
				} else {
					printReportByCode('out_history_card', 830, 768);
				}
			};
			]]>
	  	</component>
		<component cmptype="Action" name="ACancelHosp">
			<![CDATA[
			begin
				d_pkg_hosp_histories.del(pnID => :HH_ID,
											pnLPU => :LPU);
			end;
			]]>
			<component cmptype="ActionVar" name="HH_ID" src="HH_ID_DEL" srctype="var" get="g0"/>
			<component cmptype="ActionVar" name="LPU" src="LPU" srctype="session" get="g1"/>
		</component>
		<component cmptype="Action" name="reverseCancelHosp">
			<![CDATA[
			begin
				d_pkg_directions.set_canceled(pnID => :HOSP_DIR,
											 pnLPU => :LPU,
									 pnIS_CANCELED => 0,
									 pnCANC_REASON => null,
								   pnCANC_EMPLOYER => null,
								   	   pdCANC_DATE => null);
			end;
			]]>
			<component cmptype="ActionVar" name="HOSP_DIR" src="HOSP_DIR" srctype="var"     get="g0"/>
			<component cmptype="ActionVar" name="HPK_ID"   src="HPK_ID"   srctype="var"     get="g1"/>
			<component cmptype="ActionVar" name="LPU"      src="LPU"      srctype="session" get="g2"/>
			<component cmptype="SubAction" mode="execlast">
				<![CDATA[
				begin
					D_PKG_HPK_PLAN_JOURNALS.SET_RECORD_STATUS(:HPK_ID, :LPU, 0);
				end;
				]]>
				<component cmptype="SubActionVar" name="HPK_ID" get="g3" src="HPK_ID" srctype="parent"/>
				<component cmptype="SubActionVar" name="LPU"    get="g4" src="LPU"    srctype="parent"/>
			</component>
		</component>
		<component cmptype="Action" name="getDefDepFromOption">
			<![CDATA[
			begin
				:DP_NAME := d_pkg_option_specs.get('SchRegDepDefault', :LPU);
			end;
			]]>
			<component cmptype="ActionVar" name="LPU"     src="LPU"                   srctype="var" get="v0"/>
			<component cmptype="ActionVar" name="DP_NAME" src="DP_NAME_FOR_REG_SHORT" srctype="var" put="DPN" len="1000"/>
		</component>
		<component cmptype="Action" name="A_hosp_ready_rights">
			<![CDATA[
				BEGIN
					:RIGHTS := D_PKG_CSE_ACCESSES.check_employer_right(:pnlpu,d_pkg_employers.get_id(:pnlpu),'HOSP_PLAN_KINDS',:unit_id,8);
				END;
			]]>
			<component cmptype="ActionVar" name="pnlpu"   src="LPU"               srctype="var" get="lpu" />
			<component cmptype="ActionVar" name="unit_id" src="HOSP_PLAN_KIND"    srctype="var" get="unit_id" />
			<component cmptype="ActionVar" name="RIGHTS"  src="hosp_ready_rights" srctype="var" put="hosp_ready_rights" len="1" />
		</component>
		<component cmptype="Action" name="setIsReady">
			<![CDATA[
			BEGIN
				D_PKG_HPK_PLAN_JOURNALS.SET_IS_READY(pnID => :ID,
				                                    pnLPU => :LPU,
				                               pnIS_READY => :IS_READY);
			END;
			]]>
			<component cmptype="ActionVar" name="ID"       src="HPK_PLAN_DAY_ID" srctype="var" get="id" />
			<component cmptype="ActionVar" name="LPU"      src="LPU"             srctype="var" get="lpu" />
			<component cmptype="ActionVar" name="IS_READY" src="IS_READY"        srctype="var" get="is_ready" />
		</component>
  		<component cmptype="Popup" name="P_HPK_PLAN" popupobject="GR_HPK_PLAN_DAY" onpopup="base().onPopupFunc();">
			<!--component cmptype="PopupItem" name="pINTO_PLAN" caption="Занести в план" onclick=""/-->
			<component cmptype="PopupItem" name="pCH_PLAN" caption="Перенести на другую дату" onclick="base().ChangeDate();" cssimg="move"/>
			<component cmptype="PopupItem" name="pCH_PLAN_RAZD" caption="-"/>
			<component cmptype="PopupItem" name="pREF"  caption="Обновить"   onclick="base().onJournalChange();" cssimg="refresh"/>
			<component cmptype="PopupItem" name="pRAZDELITEL" caption="-"/>
			<component cmptype="PopupItem" name="pADD"  caption="Добавить"   onclick="base().AddPat();" cssimg="insert"/>
			<component cmptype="PopupItem" name="pEDIT" caption="Изменить"   onclick="base().EditPat();" cssimg="edit"/>
			<component cmptype="PopupItem" name="pDEL"  caption="Удалить" onclick="base().DelPat();" cssimg="delete"/>
			<component cmptype="PopupItem" name="pCancelHosp" caption="Оформить отказ от госпитализации" onclick="base().cancelHosp()" cssimg="ok"/>
			<component cmptype="PopupItem" name="pReverseCancelHosp" caption="Отменить отказ от госпитализации" onclick="base().reverseCancelHosp()" image="Images/img2/ok-confirm.png"/>
			<component cmptype="PopupItem" name="RAZD2" caption="-"/>
    		<!-- @gen_reg начало -->
   			<!--component cmptype="PopupItem" name="pRECORD"  caption="Записать"   onclick="base().RecordPat();" cssimg="insert"/-->
    		<component cmptype="PopupItem" name="pRECORD"  caption="Записать"   onclick="base().genRegPat();" cssimg="insert"/>
    		<!-- @gen_reg конец -->
    		<component cmptype="PopupItem" name="pMOVE_HISTORY"  caption="История перемещений"   onclick="base().MoveHistory();"/>
			<!-- Госпитализировать -->
			<component cmptype="PopupItem" name="pHOSPIT" caption="Госпитализировать" onclick="base().checkIfHHIsSingle();" image="Images/img2/ok-confirm.png"/>
			<component cmptype="PopupItem" name="pHOSPIT_S" caption="Госпитализировать повторно" onclick="base().checkIfHHIsSingle();" image="Images/img2/ok-confirm.png"/>
			<component cmptype="PopupItem" name="pHOSPIT_CANC" caption="Отменить госпитализацию" onclick="base().CancelHosp();" image="Images/img2/cancel.png"/>
			<component cmptype="PopupItem" name="pOPENIB" caption="Открыть ИБ" onclick="base().toHosp();" image="Images/img2/rights.gif"/>
      		<component cmptype="PopupItem" name="pCREATEIB_true" caption="Отправлен на создание ИБ" onclick="base().createIb(0);" image="Images/img2/ok.gif" />
      		<component cmptype="PopupItem" name="pCREATEIB_false" caption="Отправлен на создание ИБ" onclick="base().createIb(1);" />
      		<!-- Анн ИБ-->
			<component cmptype="PopupItem" name="pANN"	caption="Аннулировать ИБ" onclick="base().annulmentHH();" cssimg="delete" unitbp="HOSP_HISTORIES_SET_DISCART_STATUS"/>
			<component cmptype="PopupItem" name="pCANC_ANN" caption="Отменить аннулирование ИБ" onclick="base().rollbackIB();" image="Images/img2/cancel.png" unitbp="HOSP_HISTORIES_SET_DISCART_STATUS"/>
			<component cmptype="PopupItem" name="pANN_DO" caption="Подтвердить аннулирование ИБ" onclick="base().annulmentHH();" cssimg="delete" unitbp="HOSP_HISTORIES_SET_DISCART_STATUS"/>
			<!-- -->
			<component cmptype="PopupItem" name="pSHOW_VMP" caption="ВМП" image="Forms/HospPlan/img/vmp.png" onclick="base().setVMP();"/>
			<component cmptype="PopupItem" name="RAZD3" caption="-"/>
			<component cmptype="PopupItem" name="pHIST_HOSP"  caption="Хронология госпитализаций" onclick="base().HistHosp();" image="Forms/HospPlan/img/list.gif"/>
			<component cmptype="PopupItem" name="pSHOW_OPERS"  caption="Операции" onclick="base().showHHOperations();" image="Images/img2/docum.png"/>
			<component cmptype="PopupItem" name="pDIR_SERVICES" caption="Направления на услуги" onclick="base().showDirectionServiceControl();" image="Images/img2/docum.png"/>
			<component cmptype="PopupItem" name="pDIR_SERVICES2" caption="Направления на услуги" image="Images/img2/docum.png">
            	<component cmptype="PopupItem" caption="Пациент" onclick="base().showDirectionServiceControl();"/>
            	<component cmptype="PopupItem" caption="Сопровождающее лицо" onclick="base().showDirectionServiceControl('RELATIVE');"/>
        	</component>
			<component cmptype="PopupItem" name="pANALYZE" caption="Анализы" onclick="base().showAnalyze();" image="Images/img2/docum.png"/>
			<component cmptype="PopupItem" name="pFAC_ACC" caption="Лицевой счет" onclick="base().showPayAcc();" cssimg="pay"/>
			<component cmptype="PopupItem" name="RAZD4" caption="-"/>
			<component cmptype="PopupItem" name="pREPS" caption="Отчеты" cssimg="print">
				<component cmptype="PopupItem" name="pFIRST_LIST_HH" caption="Первый лист ИБ" cssimg="print" onclick="base().PrintFirstList();" />
                <component cmptype="PopupItem" name="pSTOP_PREG_CARD" caption="Карта прерывания беременности" cssimg="print" onclick="base().PrintStopCard();" />
				<component cmptype="PopupItem" name="pPRINTSTATCARD" caption="Статистическая карта" cssimg="print" onclick="base().PrintStatCard();"/>
				<component cmptype="PopupItem" name="pAMB" caption="-"/>
				<component cmptype="PopupItem" name="pACT_STAC_HELP" caption="Акт на стационарную помощь" cssimg="print"  onclick="base().PrintStacionaryAct();"/>
				<component cmptype="PopupItem" name="pREP_AGREEGroup" caption="Информационное согласие" cssimg="print">
            		<component cmptype="PopupItem" name="pREP_AGREE" caption="Информационное согласие" cssimg="print" onclick="base().PrintPatientAgreement();"/>
            		<component cmptype="PopupItem" name="pREP_AGREE_PERS" caption="Инф. согл. на обработку перс. данных" cssimg="print" onclick="base().PrintPatientAgreePers();"/>
            		<component cmptype="PopupItem" name="pREP_AGREE_SIF" caption="Инф. Согласие на лечение и обследование на сифилис" cssimg="print" onclick="base().PrintPatientAgreeSif();"/>
            		<component cmptype="PopupItem" name="pREP_AGREE_SIF_DOP" caption="Вкладыш Обследование больного на сифилис" cssimg="print" onclick="base().PrintPatientAgreeSifDop();"/>
            	</component>
        		<component cmptype="PopupItem" caption="Массовая печать" cssimg="print">
	        		<component cmptype="PopupItem" caption="Форма № 2 - Адресный листок прибытия" cssimg="print" onclick="base().massPrintAdrList(1);"/>
	        		<component cmptype="PopupItem" caption="Форма № 7 - Адресный листок убытия" cssimg="print" onclick="base().massPrintAdrList(2);"/>
	    		</component>
				<component cmptype="PopupItem" name="RAZD5" caption="-"/>
        		<component cmptype="PopupItem" name="pREP_VMP" caption="Протокол заседания врачебной комиссии для оказания ВМП" cssimg="print" onclick="base().PrintComissionVMP();"/>
				<component cmptype="PopupItem" name="pREP_DP" caption="План госпитализации на день" cssimg="print" onclick="base().PrintPlanOnDate();"/>


				<component cmptype="PopupItem" name="pREP_PSD" caption="Поступившие в стационар за день" cssimg="print" onclick="base().PrintReportPlanDir();"/>
				<component cmptype="PopupItem" name="pREP_PSD" caption="Анализы" cssimg="print" onclick="base().PrintReportPlanAnDir();"/>  <!-- отчет по  анализам-->



				<component cmptype="PopupItem" name="pINCOMING" caption="Список поступивших в стационар" cssimg="print" onclick="base().PrintReportListPat();"/>


					

                <component cmptype="PopupItem" name="pFORM_2" caption="Форма № 2 - Адресный листок прибытия" cssimg="print" onclick="setVar('HH_ID',getControlProperty('GR_HPK_PLAN_DAY','data')['HOSP_HISTORY']); printReportByCode('list_prib');"/>
                <component cmptype="PopupItem" name="pFORM_7" caption="Форма № 7 - Адресный листок убытия" cssimg="print" onclick="setVar('HH_ID',getControlProperty('GR_HPK_PLAN_DAY','data')['HOSP_HISTORY']); printReportByCode('list_ubyt');"/>
				<component cmptype="PopupItem" name="pILL" caption="Список больных стационара" cssimg="print" onclick="base().PrintPatientsIndept();"/>
				<component cmptype="PopupItem" name="pJOURNAL" caption="Журнал учета приема больных и отказов" cssimg="print" onclick="base().PrintReportJournalPatient();"/>
				<component cmptype="PopupItem" name="pDAILY_LIST" caption="Алфавитный журнал" cssimg="print" onclick="openWindow('Reports/HospPlan/patient_leave_date_call', true);"/>
        		<component cmptype="PopupItem" name="pPAT_LIST" caption="Листок ежедневного учета движения больных и коечного фонда стационара" cssimg="print" onclick="openWindow('Reports/Statistic/movement_daily_beds_patients_call', true);"/>
        		<component cmptype="PopupItem" name="pPAT_LIST_DAY" caption="Листок ежедневного учета движения больных и коечного фонда дневного стационара" cssimg="print" onclick="openWindow('Reports/Statistic/movement_daily_beds_patients_day_call', true);"/>
        		<component cmptype="PopupItem" name="pREP_OPG" caption="Очередь пациентов на госпитализацию" cssimg="print" onclick="openWindow('Reports/HospPlan/turn_on_hospitalization_call', true);"/>
        		<component cmptype="PopupItem" name="pREP_BEREM" caption="Журнал учета приема беременных, рожениц и родильниц" cssimg="print" onclick="printReportByCode('journal_childbirth');"/>
        		<component cmptype="PopupItem" name="pWORK_FRONT_DESK_CALL" caption="Работа приемного отделения" cssimg="print" onclick="printReportByCode('work_front_desk')"/>
        		<component cmptype="PopupItem" name="pACCOMPANYING_SHEET" caption="114/у «Сопроводительный лист»" cssimg="print" onclick="setVar('HPK_ID', getControlProperty('GR_HPK_PLAN_DAY','data')['ID']);printReportByCode('114y_accompanying_sheet');"/>
			</component>
 		</component>
 		<component cmptype="AutoPopupMenu" unit="HPK_PLAN_JOURNALS" all="true" join_menu="P_HPK_PLAN" popupobject="GR_HPK_PLAN_DAY">
     		<component cmptype="PopupItem" name="SummaryInformation" caption="Сводная заявка на питание (№22-МЗ)" cssimg="print" onclick="openWindow({name:'Reports/InformationConsistingNutrition/SummaryInformation_call',vars:{'param':'summary'}},true)"/>
 		</component>
    	<table style="width:100%;height:100%;">
        	<tr>
  		  		<td style="padding:3pt;border-left:1px solid #DDE2DA; border-right:1px solid #DDE2DA;border-top:1px solid #DDE2DA;text-align:center;">
	  				<component cmptype="Label" caption="Журнал: " />
	  				<component cmptype="ComboBox" name="C_DS_HOSP_PLAN_KINDS" onchange="base().onJournalChange();">
						<component cmptype="ComboItem" caption="Все" value="-1" activ="true"/>
						<!--component cmptype="ComboItem" caption="ОЧЕРЕДЬ" value=""/-->
						<component cmptype="ComboItem" datafield="ID" captionfield="HP_NAME" dataset="DS_HOSP_PLAN_KINDS" repeate="0"/>
  	  				</component>
  	  				<br/>
  	  				<component cmptype="CheckBox" name="CH_HH_ANNUL" caption="Скрывать аннулированные записи" valuechecked="1" valueunchecked="0" activ="0" onchange="refreshDataSet('DS_HPK_PLAN_DAY');"/>
	  	  		</td>
          	 	<td style="padding:3pt;border-left:1px solid #DDE2DA; border-right:1px solid #DDE2DA;border-top:1px solid #DDE2DA;text-align:center;" cmptype="tmp" name="TD_DDATE">
	  				<component cmptype="Label" caption="Дата: " />
	  				<component cmptype="DateEdit" name="DDATE" width="145pt" typeMask="date" onkeypress="onEnter(function(){base().OtobrDay();});" onchange="base().setBedLoadKF();" onblur="base().setBedLoadKF();"/>
  		  		</td>
  		  		<td style="padding:3pt;border-left:1px solid #DDE2DA; border-right:1px solid #DDE2DA;border-top:1px solid #DDE2DA;text-align:center;">
					<component cmptype="Label" caption="Поиск пациентов: " />
					<nobr>
						<component cmptype="UnitEdit" name="PERSMEDCARD" unit="PERSMEDCARD" composition="PMC_WITH_REG" width="185px" addListener="base().afterSelPMC">
							<!-- BUTTON_EDIT_DEFAULT -->
							<component cmptype="Button" type="micro" background="Icons/btn_erase" onclick="setValue('PERSMEDCARD',null,null);setCaption('PERSMEDCARD',null);setControlProperty('patpre','enabled',false); setControlProperty('patnex','enabled',false);"/>
						</component>
					</nobr>
  		  		</td>
  		  		<td style="padding-left:3pt;padding-top:3pt;padding-bottom:3pt;border-left:1px solid #DDE2DA; border-right:0px solid #DDE2DA;border-top:1px solid #DDE2DA;text-align:right;">
					<component cmptype="Label" caption="Префикс напр-я:"/><br/><component cmptype="Label" caption="Номер:"/>
  		  		</td>
		 		<td style="padding-left:3pt;padding-top:3pt;padding-bottom:3pt;border-right:1px solid #DDE2DA;border-top:1px solid #DDE2DA;text-align:left;">
  		  			<img name="pict" cmptype="pict" src="Forms/Reg/img/hlp.png" title="Показать легенду" style="cursor:pointer;float:right;" onclick="base().openWindowHint();" ondragstart="return false;"></img>
				  	<component cmptype="Edit" name="DIR_PREF" width="100"/>
					<br/>
					<component cmptype="Edit" name="DIR_NUMB" width="100"/>
  		  		</td>
			</tr>
  			<tr>
  		  		<td style="padding:3pt;border-left:1px solid #DDE2DA;border-right:1px solid #DDE2DA;border-bottom:1px solid #DDE2DA;text-align:center;">
					<component cmptype="Button" caption="Посмотреть квоты" onclick="base().ViewQuotes();" width="150"/>
	  	  		</td>
          	  	<td style="white-space: nowrap;padding:3pt;border-left:1px solid #DDE2DA;border-right:1px solid #DDE2DA;border-bottom:1px solid #DDE2DA;text-align:center;" cmptype="tmp" name="TD_BUT_DDATE">
	  				<component cmptype="Button" caption="&lt;&lt;&lt;" onclick="base().BackDay();"/>
	  				<component cmptype="Button" name="selected" caption="Отобрать" onclick="base().OtobrDay();" style="width:76px"/>
	  				<component cmptype="Button" caption="&gt;&gt;&gt;" onclick="base().ForwDay();"/>
					<component cmptype="MaskInspector" controls="DDATE" effectControls="selected"/>

  		  		</td>
  		  		<td style="white-space: nowrap;padding:3pt;border-left:1px solid #DDE2DA;border-right:1px solid #DDE2DA;border-bottom:1px solid #DDE2DA;text-align:center;">
	  				<component cmptype="Button" name="patpre" caption="&lt;&lt;&lt;" enabled="false" onclick="base().PatPrev();"/>
	  				<component cmptype="Button" caption="Поиск" onclick="base().PatSearch();" style="width:76px"/>
	  				<component cmptype="Button" name="patnex" caption="&gt;&gt;&gt;" enabled="false" onclick="base().PatNext();"/>
  		  		</td>
  		  		<td colspan="2" style="white-space: nowrap;padding-left:3pt;padding-top:3pt;padding-bottom:3pt;border-left:1px solid #DDE2DA;border-right:1px solid #DDE2DA;border-bottom:1px solid #DDE2DA;text-align:center;">
  	  				<component cmptype="Button" name="dirpre" caption="&lt;&lt;&lt;" enabled="false" onclick="base().DirPrev();"/>
	  				<component cmptype="Button" caption="Поиск" onclick="base().DirSearch();" style="width:76px"/>
	  				<component cmptype="Button" name="dirnex" caption="&gt;&gt;&gt;" enabled="false" onclick="base().DirNext();"/>
  		  		</td>
  			</tr>
  			<tr>
  				<td style="padding-top:3pt;">
  				</td>
  			</tr>
			<tr cmptype="bogus" name="trBedQuant">
				<td style="padding-left:3pt;border:1px solid #DDE2DA;" colspan="3">
					<div>
						<component cmptype="Label" name="Place_all"/>
						<component cmptype="Label" name="Place_oper"/>
						<component cmptype="Label" name="Place_cons"/>
						<component cmptype="Label" name="Place_male"/>
						<component cmptype="Label" name="Place_female"/>
					</div>
					<div>
						<component cmptype="Label" name="max_reg_date"/>
						<component cmptype="Label" name="min_reg_age"/>
						<component cmptype="Label" name="max_reg_age"/>
						<component cmptype="Label" name="has_mkb_ogr"/>
					</div>
					<div>
						<component cmptype="Label" name="pay_reg_kind"/>
						<component cmptype="Label" name="has_reg_lim"/>
					</div>
					<component cmptype="Label" name="quant_beds" style="float:left;"/>
				</td>
				<td style="padding-left:3pt;border:1px solid #DDE2DA;text-align:center;" colspan="2">
					<div style="width: 100%">
						<component cmptype="Button" caption="Загруженность к/ф" onclick="base().showLoadKF();" name="BedLoadKF" title="Этот текст будет показан при наведении"/>
					</div>
					<div style="width: 100%;padding-top: 10px">
						<component cmptype="Button" style="width: 134px" caption="Планирование к/ф" onclick="base().showPlaning();" name="BedFondPlan"/>
					</div>

				</td>
	    	</tr>
			<tr>
				<td colspan="5" cmptype="tmp" name="TD_EXPANDER">
					<component cmptype="Expander" control="trBedQuant" name="trBedQuantExpand" caption="Параметры направления"/>
				</td>
			</tr>
			<tr>
				<td style="padding-top:3pt;height:80%" colspan="5" cmptype="tmp" name="TD_GRID">
					<component cmptype="Grid" grid_caption="Журнал госпитализации" name="GR_HPK_PLAN_DAY" dataset="DS_HPK_PLAN_DAY" excel="true" field="UNIQ_N"
							   style="width: 100%;" height="100%"
							   onclone="base().onPaint(_dataArray);" selectlist="ID"
							   onchange="base().prepareVariables();">
						<component cmptype="Column" caption="№ ИБ" field="DEPBED" sort="DEPBED" filter="DEPBED" excelfield="DEPBED"/>
						<component cmptype="Column" caption="№" field="ROW_NUM" sort="ROW_NUM" filter="ROW_NUM" excelfield="ROW_NUM"/>
						<component cmptype="Column" caption="№ записи" field="RECORD_PREF_NUMB" sort="RECORD_PREF_NUMB" filter="RECORD_PREF_NUMB" excelfield="RECORD_PREF_NUMB"/>
						<component cmptype="Column" caption="Пациент"               field="PATIENT_ACTUAL" name ="PAT_STATUS" sort="PATIENT_ACTUAL" filter="PATIENT_ACTUAL" excelfield="PATIENT_ACTUAL">
							<div class="column_btn">
								<img name="pat_img" ondragstart="return false;" cmptype="img" src="Icons/result" title="История заболеваний и результаты исследований" onclick="base().SHOWHIST();"/>
							</div>
							<component cmptype="HyperLink" captionfield="PATIENT_ACTUAL" width="100px" datafield="PATIENT_ID" onclick="base().ADD_PERSMEDCARD(this);"/>
							<component cmptype="Image" name="pat_warn_FLG" src="Images/warning/warning_flg.png" style="display:none;vertical-align:middle;" title="Обратите внимание на просроченную ФЛГ!"/>
							<component cmptype="Image" name="patalogy_flg" src="Images/warning/exclamation.png" style="display:none;vertical-align:middle;" title="Наличие патологии при флюорографии"/>
						</component>
						<component cmptype="Column" caption="Сопровождающее лицо"   field="RELATIVE_PATIENT" name ="RELATIVE_PATIENT" sort="RELATIVE_PATIENT" filter="RELATIVE_PATIENT" profile_hidden="true" excelfield="RELATIVE_PATIENT">
							<component cmptype="HyperLink" captionfield="RELATIVE_PATIENT" width="100px" datafield="RELATIVE_PATIENT_ID" onclick="base().ADD_PERSMEDCARD(this);"/>
						</component>
						<component cmptype="Column" caption="Дата рожд." field="PATIENT_BIRTHDATE" sort="PATIENT_BIRTHDATE" filter="PATIENT_BIRTHDATE" filterkind="date" condition="eq" excelfield="PATIENT_BIRTHDATE"/>
						<component cmptype="Column" caption="Адрес" field="PATIENT_ADDRESS" sort="PATIENT_ADDRESS" filter="PATIENT_ADDRESS" excelfield="PATIENT_ADDRESS"/>
						<component cmptype="Column" caption="СНИЛС" field="PATIENT_SNILS" sort="PATIENT_SNILS" filter="PATIENT_SNILS" excelfield="PATIENT_SNILS"/>
						<component cmptype="Column" caption="Статус" field="RECORD_STATUS_MNEMO" sort="RECORD_STATUS" filter="RECORD_STATUS" filterkind="combo" fcontent="1|Отработана;0|Не отработана" condition="eq"/>
						<component cmptype="Column" caption="Диагноз при поступлении" field="DIAGNOSIS_FROM" sort="DIAGNOSIS_FROM" filter="DIAGNOSIS_FROM" excelfield="DIAGNOSIS_FROM"/>
						<component cmptype="Column" caption="Комментарий направления" field="DIR_COMMENTS" sort="DIR_COMMENTS" profile_hidden="true" excelfield="DIR_COMMENTS"/>
						<component cmptype="Column" caption="Вид оплаты" field="PAYMENT_KIND_NAME" sort="PAYMENT_KIND_NAME" filter="PAYMENT_KIND_NAME" excelfield="PAYMENT_KIND_NAME"/>
						<component cmptype="Column" caption="Журнал" field="DEP" sort="DEP" filter="DEP" excelfield="DEP"/>
						<component cmptype="Column" caption="Записал"               field="REGISTERED_BY" sort="REGISTERED_BY" filter="REGISTERED_BY" excelfield="REGISTERED_BY"/>
						<component cmptype="Column" caption="Комментарий" 	field="COMMENTS" sort="COMMENTS" excelfield="COMMENTS"/>
						<component cmptype="Column" caption="Полис"	field="PATIENT_POLIS" sort="PATIENT_POLIS" filter="PATIENT_POLIS" excelfield="PATIENT_POLIS"/>
						<component cmptype="Column" caption="Контакты" field="PATIENT_CONTACTS" sort="PATIENT_CONTACTS" name="COLUMN_PATIENT_CONTACTS" excelfield="PATIENT_CONTACTS"/>
						<component cmptype="Column" caption="№ карты" field="CARD_NUMB" sort="CARD_NUMB" filter="CARD_NUMB" excelfield="CARD_NUMB"/>
						<component cmptype="Column" caption="Направление" field="DIR_PREF_NUMB" sort="DIR_PREF_NUMB" filter="DIR_PREF_NUMB" excelfield="DIR_PREF_NUMB"/>
						<component cmptype="Column" caption="Готов" field="IS_READY_MNEMO" sort="IS_READY_MNEMO" excelfield="IS_READY_MNEMO"/>
						<component cmptype="Column" caption="Операция" field="OPERATION" sort="OPERATION" filter="OPERATION" excelfield="OPERATION"/>
						<component cmptype="Column" caption="Направлен к" field="DIRECTED_TO" sort="DIRECTED_TO" filter="DIRECTED_TO" excelfield="DIRECTED_TO"/>
						<component cmptype="Column" caption="Кабинет" field="CABLAB_NAME" sort="CABLAB_NAME" filter="CABLAB_NAME" excelfield="CABLAB_NAME"/>
						<component cmptype="Column" caption="Госпитализировал" field="DIRECTED_BY" sort="DIRECTED_BY" filter="DIRECTED_BY" excelfield="DIRECTED_BY"/>
						<component cmptype="Column" caption="Дата и время госпитализации" field="DATE_IN" sort="DATE_IN" filter="DATE_IN_TRUNC" filterkind="date" condition="eq" excelfield="DATE_IN"/>
						<component cmptype="Column" caption="Госпитализирован в отделение" field="HOSP_IN_DEP" sort="HOSP_IN_DEP" filter="HOSP_IN_DEP" excelfield="HOSP_IN_DEP"/>
						<component cmptype="Column" caption="Дата и время записи" field="REGISTER_DATE" sort="REGISTER_DATE" filter="REGISTER_DATE_TRUNC" filterkind="date" condition="eq" excelfield="REGISTER_DATE"/>
						<component cmptype="Column" caption="Вид направления" field="DIRECTION_KIND_NAME" sort="DIRECTION_KIND_NAME" filter="DIRECTION_KIND_ID" filterkind="cmb_unit" funit="DIRECTION_KINDS" fmethod="LIST" condition="eq" excelfield="DIRECTION_KIND_NAME"/>
						<component cmptype="Column" caption="Внешнее направление" field="OD_NUMB" sort="OD_NUMB" filter="OD_NUMB" profile_hidden="true" excelfield="OD_NUMB"/>
						<component cmptype="Column" caption="Причина отказа" field="CANC_REASON_NAME" sort="CANC_REASON_NAME" filter="CANC_REASON_NAME" profile_hidden="true" excelfield="CANC_REASON_NAME"/>
						<component cmptype="GridFooter" separate="true">
								<component insteadrefresh="InsteadRefresh(this);" count="10" cmptype="Range" varstart="ds1start" varcount="ds1count" valuecount="10" valuestart="1"/>
						</component>
						<component cmptype="Column" caption="Тип госпитализации" field="HOSPITALIZATION_TYPE_NAME" sort="HOSPITALIZATION_TYPE_NAME" filter="HOSPITALIZATION_TYPE_NAME"/>
					</component>
				</td>
			</tr>
    	</table>
	</component>
</div>
