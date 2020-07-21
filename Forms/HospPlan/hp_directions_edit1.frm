<div cmptype="tmp" onshow="base().OnShow();" oncreate="base().OnCreate();" onclose="base().OnClose();" window_size="450x690">
    <component cmptype="Action" name="InsertAction" compile="true">
        <![CDATA[
        declare nLPUDICT                NUMBER(17);
                nREMOTE_LPU             NUMBER(17);
                nPATIENT_ID             NUMBER(17);
                nOUTER_DIRECTION        NUMBER(17);
                nCURRENT_LPU_AG         NUMBER(17);
                nNEW_DIRECTION          NUMBER(17);
                nPREF                   VARCHAR2(4);
                nNUMB                   VARCHAR2(10);
                sDIR_NUMB		        VARCHAR2(20);
                sDIR_PREF		        VARCHAR2(20);
                sDATE_TIME              date;
                nREG_EMPLOYER_AGENT     NUMBER(17);
                nREG_EMPLOYER_SPEC_ID   NUMBER(17);
                dDATE_TR                date;
                nAllowSelectAllLpu      NUMBER(1);
        begin
            begin
                sDATE_TIME := to_date(:pdreg_date,'dd.mm.yyyy hh24:mi');
                nAllowSelectAllLpu  := D_PKG_OPTIONS.GET('AllowSelectAllLpu',:pnlpu);
            end;
            if :LPUDICT is null and :LPUDICT_HANDLE is null then
                select t.LPUDICT_ID
                  into nLPUDICT
                  from d_v_lpu t
                 where t.ID = :pnlpu;
            else
                nLPUDICT := :LPUDICT;
            end if;

            if :pddate_tr_date is not null then
              dDATE_TR := to_date(:pddate_tr_date||' '||:pddate_tr_time, 'dd.mm.yyyy hh24:mi');
            end if;

            if :IS_OUR_LPU = 1 then
                -- в нашем ЛПУ
                d_pkg_directions.add(pnd_insert_id => :pnd_insert_id,
                                             pnlpu => :pnlpu,
                                 pnouter_direction => :pnouter_direction,
                                          pnlpu_to => nLPUDICT,
                                   pslpu_to_handle => :LPUDICT_HANDLE,
                                         pnpatient => :pnpatient,
                                       pnreg_visit => :pnreg_visit,
                                     psdir_comment => :psdir_comment,
                                        pnreg_type => :pnreg_type,
                                        pndir_type => 1,
                                        pnhosp_mkb => :pnhosp_mkb,
                                       pnhosp_kind => :pnhosp_kind,
                                        psdir_numb => :psdir_numb,
                                      pnspeciality => null,
                                    pnex_cause_mkb => :pnex_cause_mkb,
                                     pninjure_kind => :pninjure_kind,
                                     pninjure_time => :pninjure_time,
                                  pndirection_kind => :pndirection_kind,
                                        pnhosp_dep => :pnhosp_dep,
                                        psdir_pref => :psdir_pref,
                                   pnhosp_bed_type => :pnhosp_bed_type,
                                             pnmes => :pnmes,
                                     pnhosp_reason => :pnhosp_reason,
                                        pdreg_date => sDATE_TIME,
                                  pdHOSP_PLAN_DATE => :HOSP_PLAN_DATE,
                                         pddate_tr => dDATE_TR,
                                       pnHOSP_TYPE => :pnHOSP_TYPE
                            @if(:pnHOSP_DIRECT_TYPES){
                               ,pnHOSP_DIRECT_TYPE => :pnHOSP_DIRECT_TYPES
                            @}
						 ,pnHOSP_REASON_STREETKIDS => :pnHOMELESS_REASON,
						          psHOSP_MKB_EXACT => :psHOSP_MKB_EXACT,
									pnREG_EMPLOYER => :pnREG_EMPLOYER
                                       );
            else

                select t1.AGENT
                  into nCURRENT_LPU_AG
                  from d_v_lpu t
                       join D_V_LPUDICT t1 on t1.ID = t.LPUDICT_ID
                 where t.ID  = :pnlpu
                   and t1.ID = t.LPUDICT_ID;

                if :LPUDICT is not null and nAllowSelectAllLpu != 1 then
                    --другое ЛПУ
                    begin
						SELECT t.id
						  into nREMOTE_LPU
						  FROM d_v_lpudict ld
							   left join d_v_lpudict ld2 on ld2.id = ld.hid
							   join d_v_lpu t on t.lpudict_id = ld.id or t.lpudict_id = ld2.id
						 WHERE ld.id = :LPUDICT;
			    exception when NO_DATA_FOUND then
						nREMOTE_LPU := null;
						nPATIENT_ID := :pnpatient;
                    end;
                    if nREMOTE_LPU is not null then
                        d_pkg_persmedcard.create_remote_card(pnid => :pnpatient,
                                                            pnlpu => :pnlpu,
                                                     pnremote_lpu => nREMOTE_LPU,
                                                      pnremote_id => nPATIENT_ID);
                    end if;
                else
                    nREMOTE_LPU := null;
                    nPATIENT_ID := :pnpatient;
                end if;

            	-- DIRECTION в нашем ЛПУ
				d_pkg_directions.add(pnd_insert_id => :pnd_insert_id,
						                     pnlpu => :pnlpu,
						         pnouter_direction => null,
						                  pnlpu_to => :LPUDICT,
						           pslpu_to_handle => :LPUDICT_HANDLE,
						                 pnpatient => :pnpatient,
						               pnreg_visit => :pnreg_visit,
						             psdir_comment => :psdir_comment,
						                pnreg_type => :pnreg_type,
						                pndir_type => 1,
						                pnhosp_mkb => :pnhosp_mkb,
						               pnhosp_kind => :pnhosp_kind,
						                psdir_numb => :psdir_numb,
						                psdir_pref => :psdir_pref,
						           pnhosp_bed_type => :pnhosp_bed_type,
						              pnspeciality => null,
						            pnex_cause_mkb => :pnex_cause_mkb,
						             pninjure_kind => :pninjure_kind,
						             pninjure_time => :pninjure_time,
						          pndirection_kind => :pndirection_kind,
						                pnhosp_dep => null,
						             pnhosp_reason => :pnhosp_reason,
						                pdreg_date => sDATE_TIME,
				                  pdHOSP_PLAN_DATE => :HOSP_PLAN_DATE,
						                 pddate_tr => dDATE_TR,
						            pnHOSP_DEPDICT => :pnhosp_dep,
						               pnHOSP_TYPE => :pnHOSP_TYPE
						    @if(:pnHOSP_DIRECT_TYPES){
                               ,pnHOSP_DIRECT_TYPE => :pnHOSP_DIRECT_TYPES
                            @}
						 ,pnHOSP_REASON_STREETKIDS => :pnHOMELESS_REASON,
						          psHOSP_MKB_EXACT => :psHOSP_MKB_EXACT,
								    pnREG_EMPLOYER => :pnREG_EMPLOYER
						               );

                select t.DIR_NUMB,
                       t.DIR_PREF,
                       t.REG_EMPLOYER_AGENT,
                       t.REG_EMPLOYER_SPEC_ID
                  into sDIR_NUMB,
                       sDIR_PREF,
                       nREG_EMPLOYER_AGENT,
                       nREG_EMPLOYER_SPEC_ID
                  from D_V_DIRECTIONS t
                 where t.ID = :pnd_insert_id;
            -- OUTER_DIRECTION в другом ЛПУ
           		d_pkg_outer_directions.add(pnd_insert_id => nOUTER_DIRECTION,
                                                   pnlpu => nvl(nREMOTE_LPU,:pnlpu),
                                               pnpatient => nPATIENT_ID,
                                                pdd_date => trunc(sysdate),
                                                psd_numb => sDIR_NUMB,
                                             pnrepresent => nCURRENT_LPU_AG,
                                      psrepresent_handle => null,
                                             pndiagnosis => null,
                                      psdiagnosis_handle => null,
                                                pndoctor => nREG_EMPLOYER_AGENT,
                                         psdoctor_handle => null,
                                                psd_pref => sDIR_PREF,
                                   pnrepresent_direction => :pnd_insert_id,
                                        pdHOSP_PLAN_DATE => :HOSP_PLAN_DATE,
                                        pnDOC_SPECIALITY => nREG_EMPLOYER_SPEC_ID);

                if nREMOTE_LPU is not null then
                	-- DIRECTION в другом ЛПУ создается только если ЛПУ в облаке.
                    nPREF := to_char(sysdate,'yyyy');
                    nNUMB := d_pkg_directions.gen_dir_numb(nREMOTE_LPU, nPREF);
                    d_pkg_directions.add(pnd_insert_id => nNEW_DIRECTION,
                                                 pnlpu => nREMOTE_LPU,
                                     pnouter_direction => nOUTER_DIRECTION,
                                              pnlpu_to => :LPUDICT,
                                       pslpu_to_handle => :LPUDICT_HANDLE,
                                             pnpatient => nPATIENT_ID,
                                           pnreg_visit => null,
                                         psdir_comment => :psdir_comment,
                                            pnreg_type => :pnreg_type,
                                            pndir_type => 1,
                                            pnhosp_mkb => :pnhosp_mkb,
                                           pnhosp_kind => :pnhosp_kind,
                                            psdir_numb => nNUMB,
                                            psdir_pref => nPREF,
                                       pnhosp_bed_type => :pnhosp_bed_type,
                                          pnspeciality => null,
                                        pnex_cause_mkb => :pnex_cause_mkb,
                                         pninjure_kind => :pninjure_kind,
                                         pninjure_time => :pninjure_time,
                                      pndirection_kind => :pndirection_kind,
                                            pnhosp_dep => null,
                                         pnhosp_reason => :pnhosp_reason,
                                            pdreg_date => sDATE_TIME,
                                      pdHOSP_PLAN_DATE => :HOSP_PLAN_DATE,
                                             pddate_tr => dDATE_TR,
                                        pnHOSP_DEPDICT => :pnhosp_dep,
                                           pnHOSP_TYPE => :pnHOSP_TYPE
                                 @if(:pnHOSP_DIRECT_TYPES){
                                   ,pnHOSP_DIRECT_TYPE => :pnHOSP_DIRECT_TYPES
                                 @}
							 ,pnHOSP_REASON_STREETKIDS => :pnHOMELESS_REASON,
							 psHOSP_MKB_EXACT => :psHOSP_MKB_EXACT
                                        );
                end if;
            end if;
            :DIR_LPUDICT_ID:=nLPUDICT;
        end;
        ]]>
        <component cmptype="ActionVar" name="pnd_insert_id"        put="var0"           src="NewID"              srctype="var" len="17"/>
        <component cmptype="ActionVar" name="LPUDICT"              get="va10"           src="LPUDICT"            srctype="ctrl"/>
        <component cmptype="ActionVar" name="LPUDICT_HANDLE"	   get="v78"            src="LPUDICT_HANDLE"     srctype="ctrl"/>
        <component cmptype="ActionVar" name="pnlpu"                                     src="LPU"                srctype="session"/>
        <component cmptype="ActionVar" name="pnouter_direction"    get="var1"           src="OUTERDIRECTIONS"    srctype="ctrl"/>
        <component cmptype="ActionVar" name="pnpatient"            get="var4"           src="PERSMEDCARD"        srctype="ctrl"/>
        <component cmptype="ActionVar" name="pnreg_visit"          get="var5"           src="VISIT_ID"           srctype="var"/>
        <component cmptype="ActionVar" name="psdir_comment"        get="var6"           src="DIR_COMMENT"        srctype="ctrl"/>
        <component cmptype="ActionVar" name="pnreg_type"           get="var7"           src="C_REG_TYPE"         srctype="ctrl"/>
        <component cmptype="ActionVar" name="pnhosp_mkb"           get="var9"           src="MKB10"              srctype="ctrl"/>
        <component cmptype="ActionVar" name="pnhosp_kind"          get="var10"          src="C_HOSP_KIND"        srctype="ctrl"/>
        <component cmptype="ActionVar" name="psdir_numb"           get="var11"          src="DIR_NUMB"           srctype="ctrl"/>
        <component cmptype="ActionVar" name="psdir_pref"           get="var11p"         src="DIR_PREF"           srctype="ctrl"/>
        <component cmptype="ActionVar" name="pnex_cause_mkb"       get="v1"             src="EX_CAUSE_MKB"       srctype="ctrl"/>
        <component cmptype="ActionVar" name="pninjure_kind"        get="v2"             src="INJURE_KIND"        srctype="ctrl"/>
        <component cmptype="ActionVar" name="pninjure_time"        get="v3"             src="INJURE_TIME"        srctype="var"/>
        <component cmptype="ActionVar" name="pndirection_kind"     get="v4"             src="DIR_KIND"           srctype="ctrl"/>
        <component cmptype="ActionVar" name="pnhosp_dep"           get="v5"             src="HOSP_DEP"           srctype="ctrl"/>
        <component cmptype="ActionVar" name="pnhosp_bed_type"      get="v6"             src="BED"                srctype="ctrl"/>
        <component cmptype="ActionVar" name="pnmes"                get="v7"             src="MESES"              srctype="ctrl"/>
        <component cmptype="ActionVar" name="IS_OUR_LPU"           get="v8"             src="LLPPUU"             srctype="ctrl"/>
        <component cmptype="ActionVar" name="pnhosp_reason"        get="v9"             src="C_HOSP_REASON"      srctype="ctrl" />
        <!--<component cmptype="ActionVar" name="pdreg_date" src="REG_DATE_CTRL" srctype="ctrl" get="v10"/>-->
        <component cmptype="ActionVar" name="pdreg_date"           get="v10"            src="REG_DATE_VAR"       srctype="var" />
        <component cmptype="ActionVar" name="HOSP_PLAN_DATE"       get="vPL"            src="HOSP_PLAN_DATE"     srctype="ctrl" />
        <component cmptype="ActionVar" name="pddate_tr_date"       get="vDATE_TR_DATE"  src="DATE_TR_DATE"       srctype="ctrl" />
        <component cmptype="ActionVar" name="pddate_tr_time"       get="vDATE_TR_TIME"  src="DATE_TR_TIME"       srctype="ctrl" />
        <component cmptype="ActionVar" name="DIR_LPUDICT_ID"       put="DIR_LPUDICT_ID" src="DIR_LPUDICT_ID"     srctype="var"   len="17"/>
        <component cmptype="ActionVar" name="pnHOSP_TYPE"          get="HOSP_TYPE"      src="HOSP_TYPE"          srctype="ctrl" />
        <component cmptype="ActionVar" name="remote_lpu"           put="remote_lpu"     src="remote_lpu"         srctype="var"   len="17"/>
		<component cmptype="ActionVar" name="pnHOSP_DIRECT_TYPES"  get="v11"            src="nHOSP_DIRECT_TYPES" srctype="ctrl"/>
		<component cmptype="ActionVar" name="pnHOMELESS_REASON"    get="v12"            src="HOMELESS_REASON"    srctype="ctrl"/>
		<component cmptype="ActionVar" name="psHOSP_MKB_EXACT"     get="HOSP_MKB_EXACT" src="HOSP_MKB_EXACT"     srctype="ctrl"/>
		<component cmptype="ActionVar" name="pnREG_EMPLOYER"       get="REG_EMPLOYER"   src="REG_EMPLOYER"       srctype="ctrl"/>
    </component>

	<component cmptype="Action" name="getCardNumb">
		begin
			select p.CARD_NUMB
			  into :CARDN
			  from d_v_persmedcard p
			 where p.ID = :PMC;
         exception when no_data_found then
			:CARDN := null;
		end;
		<component cmptype="ActionVar" name="PMC"    get="var0" src="PATIENT_ID"    srctype="var"/>
		<component cmptype="ActionVar" name="CARDN"  put="var1" src="PERSMEDCARD"   srctype="ctrlcaption" len="26"/>
	</component>

	<component cmptype="Action" name="freeDirNumbReserve">
		begin
			D_PKG_DIR_NUMB_RESERV.DEL_BY_NUMB(pnLPU => :LPU,
                                              psDIR_NUMB => :DIR_NUMB,
                                              psDIR_PREF => :DIR_PREF);
		end;
		<component cmptype="ActionVar" name="LPU"                        src="LPU"        srctype="session"/>
        <component cmptype="ActionVar" name="DIR_NUMB"  get="DIR_NUMB"   src="DIR_NUMB"   srctype="ctrl"/>
        <component cmptype="ActionVar" name="DIR_PREF"  get="DIR_PREF"   src="DIR_PREF"   srctype="ctrl"/>
	</component>

	<component cmptype="Action" name="GetDirNumb">
		begin
			if :INPREF is null or :PREF = '' then
				:PREF := to_char(sysdate,'yyyy');
			else
				:PREF := :INPREF;
			end if;
			:NUMB := d_pkg_directions.gen_dir_numb(:pnlpu,:PREF);
		end;
		<component cmptype="ActionVar" name="NUMB"    put="var0"   src="DIR_NUMB"   srctype="ctrl" len="20"/>
		<component cmptype="ActionVar" name="PREF"    put="var0p"  src="DIR_PREF"   srctype="ctrl" len="20"/>
		<component cmptype="ActionVar" name="INPREF"  get="var0p"  src="DIR_PREF"   srctype="ctrl"/>
		<component cmptype="ActionVar" name="pnlpu"                src="LPU"        srctype="session"/>
	</component>

	<component cmptype="Action" name="UpdateAction" compile="true">
    	<![CDATA[
	  	declare nLPUDICT NUMBER(17);
				nREMOTE_LPU NUMBER(17);
				nPATIENT_ID NUMBER(17);
				nOUTER_DIRECTION NUMBER(17);
				nCURRENT_LPU_AG NUMBER(17);
				nNEW_DIRECTION NUMBER(17);
				nPREF VARCHAR2(4);
				nNUMB VARCHAR2(10);
				sDATE_TIME date;
				nREG_EMPLOYER_AGENT     NUMBER(17);
				nREG_EMPLOYER_SPEC_ID   NUMBER(17);
				dDATE_TR date;
				nOld_lpu_to             NUMBER(17);
				nIS_LPU_CHANGE          NUMBER(1);
				nAllowSelectAllLpu      NUMBER(1);
	  	begin
			sDATE_TIME := to_date(:pdreg_date,'dd.mm.yyyy hh24:mi');
			:NEW_DIR_ID := :pnid;
			:NEW_LPU_ID := :pnlpu;
			:NEW_OUTER_DIR_ID := :pnouter_direction;
			nAllowSelectAllLpu  := D_PKG_OPTIONS.GET('AllowSelectAllLpu',:pnlpu);
			if :LPUDICT is null and :LPUDICT_HANDLE is null then
				select t.LPUDICT_ID
			      into nLPUDICT
			      from d_v_lpu t
			     where t.ID = :CURRENT_LPU;
		    else
				nLPUDICT := :LPUDICT;
			end if;

			begin
				/*проверяем было ли изменение в ЛПУ*/
				select t.LPU_TO_ID
				  into nOld_lpu_to
				  from D_V_DIRECTIONS t
				 where t.id=:pnid;
				 nIS_LPU_CHANGE:=0;
				 if :LPUDICT is not null and nOld_lpu_to<>:LPUDICT then nIS_LPU_CHANGE:=1;
				 elsif :LPUDICT_HANDLE is not null and nOld_lpu_to is not null then nIS_LPU_CHANGE:=1;
				 elsif :IS_OUR_LPU = 1 and ( nOld_lpu_to<>nLPUDICT or nOld_lpu_to is null )then nIS_LPU_CHANGE:=1;
				 end if;
			 end;

	 		/*С аналитиком не смогли понять зачем нужна была эта проверка. Она мешала корректному редактированию из дневника врача
		 	if :pnreg_visit is null then*/

		 	if nIS_LPU_CHANGE=1 then/*удаляем только если ЛПУ было изменено*/

				for x in (select t.ID,
								 l.ID DID,
								 l.LPU DIR_LPU,
								 t.LPU OD_LPU
						    from D_V_OUTER_DIRECTIONS t
							     left join D_V_DIRECTIONS l on l.OUTER_DIRECTION_ID = t.ID
						   where t.REPRESENT_DIRECTION = :pnid) loop
					if x.DID is not null then
						d_pkg_directions.del(x.DID, x.DIR_LPU);
					end if;
					d_pkg_outer_directions.del(x.ID, x.OD_LPU);
				end loop;
			end if;
	  		/*end if;*/
	  		if :pddate_tr_date is not null then
				dDATE_TR := to_date(:pddate_tr_date||' '||:pddate_tr_time, 'dd.mm.yyyy hh24:mi');
	  		end if;
	  		if :IS_OUR_LPU = 1 then
				if nIS_LPU_CHANGE = 1 then
					  /*d_pkg_directions.upd(pnid => :pnid,
										   pnlpu => :CURRENT_LPU,
										   pnouter_direction => null,
										   pnlpu_to => nLPUDICT,
										   pslpu_to_handle => :LPUDICT_HANDLE,
										   psdir_comment => :psdir_comment,
										   pnreg_type => :pnreg_type,
										   pndir_type => 1,
										   pnhosp_mkb => :pnhosp_mkb,
										   pnhosp_kind => :pnhosp_kind,
										   psdir_numb => :psdir_numb,
										   pnspeciality => null,
										   pnex_cause_mkb => :pnex_cause_mkb,
										   pninjure_kind => :pninjure_kind,
										   pninjure_time => :pninjure_time,
										   pndirection_kind => :pndirection_kind,
										   pnhosp_dep => :pnhosp_dep,
										   psdir_pref => :psdir_pref,
										   pnhosp_bed_type => :pnhosp_bed_type,
										   pnmes => :pnmes,
										   pnREG_HPKPJ =>null,
										   pnhosp_reason => :pnhosp_reason,
										   pdreg_date => sDATE_TIME,
										   pdHOSP_PLAN_DATE => :HOSP_PLAN_DATE,
										   pddate_tr => dDATE_TR,
										   pnHOSP_DEPDICT => null,
										   psDOC_COMMENT => :DOC_COMMENT);*/

			  		begin
				  		select t.OUTER_DIRECTION_ID
					      into nOUTER_DIRECTION
					      from d_v_directions t
					     where t.id = :pnid;
				  	end;

		  			if nOUTER_DIRECTION is not null then
			  			for cur in (select t2.ID OD_ID,
										   t2.LPU OD_LPU,
										   t3.ID D_ID,
										   t3.LPU D_LPU
						              from D_V_DIRECTIONS t,
							               D_V_OUTER_DIRECTIONS t2,
							               D_V_DIRECTIONS t3
						             where t.ID = :pnid
						               and t.OUTER_DIRECTION_ID = t2.ID
						               and t3.ID = t2.REPRESENT_DIRECTION) loop
						  	d_pkg_directions.del(:pnid, :pnlpu);
						  	d_pkg_directions.del(cur.D_ID, cur.D_LPU);
						  	d_pkg_outer_directions.del(cur.OD_ID, cur.OD_LPU);
			  			end loop;
		  			else
			  			d_pkg_directions.del(:pnid, :pnlpu);
		  			end if;

				  	nPREF := to_char(sysdate,'yyyy');
				  	nNUMB := d_pkg_directions.gen_dir_numb(:CURRENT_LPU, nPREF);

				  	d_pkg_persmedcard.create_remote_card(pnid => :pnpatient,
													    pnlpu => :pnlpu,
												 pnremote_lpu => :CURRENT_LPU,
												  pnremote_id => nPATIENT_ID);

					d_pkg_directions.add(pnd_insert_id => nNEW_DIRECTION,
							                     pnlpu => :CURRENT_LPU,
							         pnouter_direction => null,
							                  pnlpu_to => nLPUDICT,
							           pslpu_to_handle => :LPUDICT_HANDLE,
							                 pnpatient => nPATIENT_ID,
							               pnreg_visit => :pnreg_visit,
							             psdir_comment => :psdir_comment,
							                pnreg_type => :pnreg_type,
							                pndir_type => 1,
							                pnhosp_mkb => :pnhosp_mkb,
							               pnhosp_kind => :pnhosp_kind,
							                psdir_numb => nNUMB,
							                psdir_pref => nPREF,
							           pnhosp_bed_type => :pnhosp_bed_type,
							              pnspeciality => null,
							            pnex_cause_mkb => :pnex_cause_mkb,
							             pninjure_kind => :pninjure_kind,
							             pninjure_time => :pninjure_time,
							          pndirection_kind => :pndirection_kind,
							                pnhosp_dep => :pnhosp_dep,
							             pnhosp_reason => :pnhosp_reason,
							                pdreg_date => sDATE_TIME,
							          pdHOSP_PLAN_DATE => :HOSP_PLAN_DATE,
							                 pddate_tr => dDATE_TR,
							             psDOC_COMMENT => :DOC_COMMENT,
							               pnHOSP_TYPE => :pnHOSP_TYPE
							   @if(:pnHOSP_DIRECT_TYPES){
                                   ,pnHOSP_DIRECT_TYPE => :pnHOSP_DIRECT_TYPES
                               @}
						     ,pnHOSP_REASON_STREETKIDS => :pnHOMELESS_REASON,
						              psHOSP_MKB_EXACT => :psHOSP_MKB_EXACT,
		                                pnREG_EMPLOYER => :pnREG_EMPLOYER
							               );
					:NEW_DIR_ID := nNEW_DIRECTION;
					:NEW_LPU_ID := :CURRENT_LPU;
					:NEW_OUTER_DIR_ID := null;
				else
				  	d_pkg_directions.upd(pnid => :pnid,
										pnlpu => :pnlpu,
							pnouter_direction => :pnouter_direction,
									 pnlpu_to => nLPUDICT,
						      pslpu_to_handle => :LPUDICT_HANDLE,
							    psdir_comment => :psdir_comment,
								   pnreg_type => :pnreg_type,
								   pndir_type => 1,
								   pnhosp_mkb => :pnhosp_mkb,
								  pnhosp_kind => :pnhosp_kind,
								   psdir_numb => :psdir_numb,
								 pnspeciality => null,
							   pnex_cause_mkb => :pnex_cause_mkb,
							    pninjure_kind => :pninjure_kind,
							    pninjure_time => :pninjure_time,
						     pndirection_kind => :pndirection_kind,
								   pnhosp_dep => :pnhosp_dep,
								   psdir_pref => :psdir_pref,
							  pnhosp_bed_type => :pnhosp_bed_type,
									    pnmes => :pnmes,
								  pnREG_HPKPJ => null,
							    pnhosp_reason => :pnhosp_reason,
								   pdreg_date => sDATE_TIME,
							 pdHOSP_PLAN_DATE => :HOSP_PLAN_DATE,
								    pddate_tr => dDATE_TR,
							   pnHOSP_DEPDICT => null,
								psDOC_COMMENT => :DOC_COMMENT,
						    pnHOSP_PALAN_KIND => null,
								  pnHOSP_TYPE => :pnHOSP_TYPE
					   @if(:pnHOSP_DIRECT_TYPES){
                          ,pnHOSP_DIRECT_TYPE => :pnHOSP_DIRECT_TYPES
                       @}
					,pnHOSP_REASON_STREETKIDS => :pnHOMELESS_REASON,
					         psHOSP_MKB_EXACT => :psHOSP_MKB_EXACT,
		                       pnREG_EMPLOYER => :pnREG_EMPLOYER,
								 vAPI_VERSION => 7
								  );
				end if;
	  		else

			  	select t1.AGENT
				  into nCURRENT_LPU_AG
				  from d_v_lpu t
					   join D_V_LPUDICT t1 on t1.ID = t.LPUDICT_ID
			     where t.ID  = :pnlpu;

		  		if :LPUDICT is not null and nAllowSelectAllLpu != 1 then
			  		--другое ЛПУ
					begin
				  		SELECT t.id
						  into nREMOTE_LPU
						  FROM d_v_lpudict ld
							   left join d_v_lpudict ld2 on ld2.id = ld.hid
							   join d_v_lpu t on t.lpudict_id = ld.id or t.lpudict_id = ld2.id
						 WHERE ld.id = :LPUDICT;
				     exception when NO_DATA_FOUND then
					  nREMOTE_LPU := null;
					  nPATIENT_ID := :pnpatient;
					end;
					if nREMOTE_LPU is not null then
						d_pkg_persmedcard.create_remote_card(pnid => :pnpatient,
													        pnlpu => :pnlpu,
												     pnremote_lpu => nREMOTE_LPU,
												      pnremote_id => nPATIENT_ID);
			  		end if;
		  		else
					nREMOTE_LPU := null;
					nPATIENT_ID := :pnpatient;
		  		end if;

			  	d_pkg_directions.upd(pnid => :pnid,
					                pnlpu => :pnlpu,
					    pnouter_direction => :pnouter_direction,
					             pnlpu_to => :LPUDICT,
					      pslpu_to_handle => :LPUDICT_HANDLE,
					        psdir_comment => :psdir_comment,
					           pnreg_type => :pnreg_type,
					           pndir_type => 1,
					           pnhosp_mkb => :pnhosp_mkb,
					          pnhosp_kind => :pnhosp_kind,
					           psdir_numb => :psdir_numb,
					           psdir_pref => :psdir_pref,
					         pnspeciality => null,
					       pnex_cause_mkb => :pnex_cause_mkb,
					        pninjure_kind => :pninjure_kind,
					        pninjure_time => :pninjure_time,
					     pndirection_kind => :pndirection_kind,
					           pnhosp_dep => null,
					      pnhosp_bed_type => :pnhosp_bed_type,
					                pnmes => null,
					          pnREG_HPKPJ => null,
					        pnhosp_reason => :pnhosp_reason,
					           pdreg_date => sDATE_TIME,
					     pdHOSP_PLAN_DATE => :HOSP_PLAN_DATE,
					            pddate_tr => dDATE_TR,
					       pnHOSP_DEPDICT => :pnhosp_dep,
					        psDOC_COMMENT => :DOC_COMMENT,
					    pnHOSP_PALAN_KIND => null,
					          pnHOSP_TYPE => :pnHOSP_TYPE
				  @if(:pnHOSP_DIRECT_TYPES){
                      ,pnHOSP_DIRECT_TYPE => :pnHOSP_DIRECT_TYPES
                  @}
				,pnHOSP_REASON_STREETKIDS => :pnHOMELESS_REASON,
			             psHOSP_MKB_EXACT => :psHOSP_MKB_EXACT,
		                   pnREG_EMPLOYER => :pnREG_EMPLOYER,
							 vAPI_VERSION => 7
					          );

		  		/*if :pnreg_visit is null then*/
				select t.REG_EMPLOYER_AGENT,
				       t.REG_EMPLOYER_SPEC_ID
				  into nREG_EMPLOYER_AGENT,
				       nREG_EMPLOYER_SPEC_ID
				  from D_V_DIRECTIONS t
				 where t.ID = :pnid;
				if nIS_LPU_CHANGE=1 then /*если изменили ЛПУ, то создаем записи по новому, иначе update старых*/
					-- OUTER_DIRECTION в другом ЛПУ
					d_pkg_outer_directions.add(pnd_insert_id => nOUTER_DIRECTION,
										               pnlpu => nvl(nREMOTE_LPU,:pnlpu),
										           pnpatient => nPATIENT_ID,
										            pdd_date => trunc(sysdate),
										            psd_numb => :psdir_numb,
										         pnrepresent => nCURRENT_LPU_AG,
										  psrepresent_handle => null,
										         pndiagnosis => null,
										  psdiagnosis_handle => null,
										            pndoctor => nREG_EMPLOYER_AGENT,
										     psdoctor_handle => null,
										            psd_pref => :psdir_pref,
									   pnrepresent_direction => :pnid,
										    pdHOSP_PLAN_DATE => :HOSP_PLAN_DATE,
										    pnDOC_SPECIALITY => nREG_EMPLOYER_SPEC_ID);
				  	if nREMOTE_LPU is not null then
						-- DIRECTION в другом ЛПУ создается только если ЛПУ в облаке.
						nPREF := to_char(sysdate,'yyyy');
					  	nNUMB := d_pkg_directions.gen_dir_numb(nREMOTE_LPU, nPREF);
					  	d_pkg_directions.add(pnd_insert_id => nNEW_DIRECTION,
											         pnlpu => nREMOTE_LPU,
										 pnouter_direction => nOUTER_DIRECTION,
											      pnlpu_to => :LPUDICT,
										   pslpu_to_handle => :LPUDICT_HANDLE,
											     pnpatient => nPATIENT_ID,
											   pnreg_visit => null,
											 psdir_comment => :psdir_comment,
											    pnreg_type => :pnreg_type,
											    pndir_type => 1,
											    pnhosp_mkb => :pnhosp_mkb,
											   pnhosp_kind => :pnhosp_kind,
										   	    psdir_numb => nNUMB,
											    psdir_pref => nPREF,
											  pnspeciality => null,
											pnex_cause_mkb => :pnex_cause_mkb,
											 pninjure_kind => :pninjure_kind,
											 pninjure_time => :pninjure_time,
										  pndirection_kind => :pndirection_kind,
											    pnhosp_dep => null,
										   pnhosp_bed_type => :pnhosp_bed_type,
											 pnhosp_reason => :pnhosp_reason,
											    pdreg_date => sDATE_TIME,
										  pdHOSP_PLAN_DATE => :HOSP_PLAN_DATE,
											     pddate_tr => dDATE_TR,
											pnHOSP_DEPDICT => :pnhosp_dep,
											   pnHOSP_TYPE => :pnHOSP_TYPE
							   @if(:pnHOSP_DIRECT_TYPES){
                                       ,pnHOSP_DIRECT_TYPE => :pnHOSP_DIRECT_TYPES
                               @}
								 ,pnHOSP_REASON_STREETKIDS => :pnHOMELESS_REASON,
								 psHOSP_MKB_EXACT => :psHOSP_MKB_EXACT
											   );
				  	end if;
				else
					 for x in (select t.ID OD_ID,
								      l.ID D2_ID,
								      l.DIR_NUMB,
								      l.DIR_PREF,
								      l.DOC_COMMENT,
								      t.REASON_ID
							     from D_V_OUTER_DIRECTIONS t
								      join D_V_DIRECTIONS l on l.OUTER_DIRECTION_ID = t.ID /*левое, так как для ЛПУ не в облаке direction2 не создается*/
							      and t.REPRESENT_DIRECTION = :pnid )loop
						-- OUTER_DIRECTION в другом ЛПУ
							d_pkg_outer_directions.upd(pnid => x.OD_ID,--
											          pnlpu => nvl(nREMOTE_LPU,:pnlpu),
											      pnpatient => nPATIENT_ID,
											       pdd_date => trunc(sysdate),
											       psd_numb => :psdir_numb,
											    pnrepresent => nCURRENT_LPU_AG,
									     psrepresent_handle => null,
											    pndiagnosis => null,
										 psdiagnosis_handle => null,
											       pndoctor => nREG_EMPLOYER_AGENT,
										    psdoctor_handle => null,
											       psd_pref => :psdir_pref,
									  pnrepresent_direction => :pnid,
										   pdHOSP_PLAN_DATE => :HOSP_PLAN_DATE,
										   pnDOC_SPECIALITY => nREG_EMPLOYER_SPEC_ID,
											       pnREASON => x.REASON_ID);

						   	if nREMOTE_LPU is not null then
							  	-- DIRECTION в другом ЛПУ создается только если ЛПУ в облаке.
								 d_pkg_directions.upd(pnid => x.D2_ID,
												     pnlpu => nREMOTE_LPU,
										 pnouter_direction => x.OD_ID,
												  pnlpu_to => :LPUDICT,
										   pslpu_to_handle => :LPUDICT_HANDLE,
											 psdir_comment => :psdir_comment,
											    pnreg_type => :pnreg_type,
											    pndir_type => 1,
											    pnhosp_mkb => :pnhosp_mkb,
											   pnhosp_kind => :pnhosp_kind,
											    psdir_numb => x.DIR_NUMB,
											    psdir_pref => x.DIR_PREF,
											  pnspeciality => null,
										    pnex_cause_mkb => :pnex_cause_mkb,
											 pninjure_kind => :pninjure_kind,
											 pninjure_time => :pninjure_time,
										  pndirection_kind => :pndirection_kind,
											    pnhosp_dep => null,
										   pnhosp_bed_type => :pnhosp_bed_type,
											 pnhosp_reason => :pnhosp_reason,
											    pdreg_date => sDATE_TIME,
										  pdHOSP_PLAN_DATE => :HOSP_PLAN_DATE,
												     pnmes => null,
											   pnREG_HPKPJ => null,
											     pddate_tr => dDATE_TR,
										    pnHOSP_DEPDICT => :pnhosp_dep,
											 psDOC_COMMENT => x.DOC_COMMENT,
										 pnHOSP_PALAN_KIND => null,
											   pnHOSP_TYPE => :pnHOSP_TYPE
									@if(:pnHOSP_DIRECT_TYPES){
                                       ,pnHOSP_DIRECT_TYPE => :pnHOSP_DIRECT_TYPES
                                    @}
								 ,pnHOSP_REASON_STREETKIDS => :pnHOMELESS_REASON,
								 psHOSP_MKB_EXACT => :psHOSP_MKB_EXACT
											   );
						  end if;
					 end loop;
				end if;
			 	:DIR_LPUDICT_ID:=nLPUDICT;
				 /*     end if;*/
	  		end if;
		end;
		]]>
		<component cmptype="ActionVar" name="pnid"                 src="DIR_ID"             srctype="var"     get="var0" />
	  	<component cmptype="ActionVar" name="NEW_DIR_ID"           src="DIR_ID"             srctype="var"     put="p0" len="17"/>
	  	<component cmptype="ActionVar" name="NEW_LPU_ID"           src="LPU"                srctype="var"     put="p1" len="17"/>
	  	<component cmptype="ActionVar" name="NEW_OUTER_DIR_ID"     src="OUTERDIRECTIONS"    srctype="ctrl"    put="p2" len="17"/>
		<component cmptype="ActionVar" name="LPUDICT"              src="LPUDICT"            srctype="ctrl"    get="va10"/>
		<component cmptype="ActionVar" name="LPUDICT_HANDLE"	   src="LPUDICT_HANDLE"     srctype="ctrl"    get="v78"/>
		<component cmptype="ActionVar" name="pnlpu"                src="LPU"                srctype="var"     get="lpu" />
		<component cmptype="ActionVar" name="CURRENT_LPU"          src="LPU"                srctype="session" get="var2"/>
		<component cmptype="ActionVar" name="pnouter_direction"    src="OUTERDIRECTIONS"    srctype="ctrl"    get="var1"/>
		<component cmptype="ActionVar" name="pnpatient"            src="PERSMEDCARD"        srctype="ctrl"    get="var4"/>
		<component cmptype="ActionVar" name="pnreg_visit"          src="VISIT_ID"           srctype="var"     get="var5"/>
		<component cmptype="ActionVar" name="psdir_comment"        src="DIR_COMMENT"        srctype="ctrl"    get="var6" />
		<component cmptype="ActionVar" name="pnreg_type"           src="C_REG_TYPE"         srctype="ctrl"    get="var7"    />
		<component cmptype="ActionVar" name="pnhosp_mkb"           src="MKB10"              srctype="ctrl"    get="var9"  />
		<component cmptype="ActionVar" name="pnhosp_kind"          src="C_HOSP_KIND"        srctype="ctrl"    get="var10"/>
		<component cmptype="ActionVar" name="psdir_numb"           src="DIR_NUMB"           srctype="ctrl"    get="var11"/>
		<component cmptype="ActionVar" name="psdir_pref"           src="DIR_PREF"           srctype="ctrl"    get="var11p" />
		<component cmptype="ActionVar" name="pnex_cause_mkb"       src="EX_CAUSE_MKB"       srctype="ctrl"    get="v1"/>
		<component cmptype="ActionVar" name="pninjure_kind"        src="INJURE_KIND"        srctype="ctrl"    get="v2"/>
		<component cmptype="ActionVar" name="pninjure_time"        src="INJURE_TIME"        srctype="var"     get="v3"/>
		<component cmptype="ActionVar" name="pndirection_kind"     src="DIR_KIND"           srctype="ctrl"    get="v4" />
		<component cmptype="ActionVar" name="pnhosp_dep"           src="HOSP_DEP"           srctype="ctrl"    get="v5"  />
		<component cmptype="ActionVar" name="pnhosp_bed_type"      src="BED"                srctype="ctrl"    get="v6"/>
		<component cmptype="ActionVar" name="pnmes"   		       src="MESES"              srctype="ctrl"    get="v7" />
		<component cmptype="ActionVar" name="IS_OUR_LPU"           src="LLPPUU"             srctype="ctrl"    get="v8"/>
		<component cmptype="ActionVar" name="pnhosp_reason"        src="C_HOSP_REASON"      srctype="ctrl"    get="v9"/>
		<!--<component cmptype="ActionVar" name="pdreg_date" src="REG_DATE_CTRL" srctype="ctrl" get="v10"/>-->
		<component cmptype="ActionVar" name="pdreg_date"           src="REG_DATE_VAR"       srctype="var"     get="v10"/>
		<component cmptype="ActionVar" name="HOSP_PLAN_DATE"       src="HOSP_PLAN_DATE"     srctype="ctrl"    get="vPL"/>
		<component cmptype="ActionVar" name="pddate_tr_date"       src="DATE_TR_DATE"       srctype="ctrl"    get="vDATE_TR_DATE"/>
		<component cmptype="ActionVar" name="pddate_tr_time"       src="DATE_TR_TIME"       srctype="ctrl"    get="vDATE_TR_TIME"/>
		<component cmptype="ActionVar" name="DOC_COMMENT"          src="DOC_COMMENT"        srctype="var"     get="DOC_COMMENT"/>
		<component cmptype="ActionVar" name="DIR_LPUDICT_ID"       src="DIR_LPUDICT_ID"     srctype="var"     put="DIR_LPUDICT_ID" len="17"/>
		<component cmptype="ActionVar" name="pnHOSP_TYPE"          src="HOSP_TYPE"          srctype="ctrl"    get="HOSP_TYPE"/>
		<component cmptype="ActionVar" name="pnHOSP_DIRECT_TYPES"  src="nHOSP_DIRECT_TYPES" srctype="ctrl"    get="v27"/>
		<component cmptype="ActionVar" name="pnHOMELESS_REASON"    src="HOMELESS_REASON"    srctype="ctrl"    get="v28"/>
		<component cmptype="ActionVar" name="psHOSP_MKB_EXACT"     src="HOSP_MKB_EXACT"     srctype="ctrl"    get="HOSP_MKB_EXACT"/>
		<component cmptype="ActionVar" name="pnREG_EMPLOYER"       src="REG_EMPLOYER"       srctype="ctrl"    get="REG_EMPLOYER"/>
	</component>

	<component cmptype="Action" name="SelectAction">
		<![CDATA[]]>
		declare nLPUDICT NUMBER(17);
		begin
            if :LPU_EDIT is null then
				:LPU_EDIT := :pnlpu;
		    else
				:LPU_EDIT := :LPU_EDIT;
            end if;
		 	select h.OUTER_DIRECTION_ID,
				   h.OUTER_DIRECTION,
				   h.PATIENT_ID,
				   h.PATIENT_CARD,
		           h.REG_VISIT_ID,
				   h.DIR_COMMENT,
				   h.REG_TYPE,
				   h.HOSP_MKB_ID,
				   h.HOSP_MKB,
				   h.HOSP_KIND_ID,
				   h.DIR_NUMB,
		           h.DIR_PREF,
				   coalesce(h.HOSP_DEP_ID,h.HOSP_DEPDICT_ID),
				   coalesce(h.HOSP_DEP,h.HOSP_DEPDICT_NAME),
				   h.HOSP_DEPDICT_ID,
				   h.HOSP_BED_TYPE_ID,
				   h.DIRECTION_KIND_ID,
				   h.EX_CAUSE_MKB_ID,
		    	   h.EX_CAUSE_MKB,
		      	   h.INJURE_KIND_ID,
		      	   h.INJURE_KIND,
		      	   h.INJURE_TIME,
				   h.LPU_TO_HANDLE,
				   h.LPU_TO_ID,
		           h.LPU_TO,
		           h.MES_ID,
				   h.MES,
                   h.HOSP_REASON_ID,
                   h.HOSP_REASON_NAME,
                   nvl(h.REG_DATE, sysdate),
                   to_char(nvl(h.REG_DATE, sysdate),'hh24:mi') REG_TIME,
			       h.HOSP_PLAN_DATE,
                   to_char(h.DATE_TR,'dd.mm.yyyy'),
                   to_char(h.DATE_TR, 'hh24:mi'),
                   h.DOC_COMMENT,
                   h.LPU_TO_NAME,
                   h.LPU_TO_ID,
                   h.HOSP_TYPE_ID,
		           h.HOSP_DIRECT_TYPE_ID,
				   h.HOSP_REASON_STREETKIDS,
				   h.HOSP_MKB_EXACT,
				   h.REG_EMPLOYER_ID,
				   h.REG_EMPLOYER_FIO
		      into :OUTER_DIRECTION_ID,
				   :OUTER_DIRECTION,
				   :PATIENT_ID,
				   :PATIENT_CARD,
				   :REG_VISIT_ID,
				   :DIR_COMMENT,
				   :REG_TYPE,
				   :HOSP_MKB_ID,
				   :HOSP_MKB,
				   :HOSP_KIND_ID,
				   :DIR_NUMB,
		           :DIR_PREF,
				   :HOSP_DEP_ID,
				   :HOSP_DEP,
				   :HOSP_DEPDICT_ID,
		           :HOSP_BED_TYPE_ID,
				   :DIRECTION_KIND_ID,
				   :EX_CAUSE_MKB_ID,
		      	   :EX_CAUSE_MKB,
		      	   :INJURE_KIND_ID,
		      	   :INJURE_KIND,
		      	   :INJURE_TIME,
				   :LPUDICT_HANDLE,
				   :LPUDICT_ID,
				   :LPUDICT,
				   :MES_ID,
				   :MES,
				   :HOSP_REASON_ID,
				   :HOSP_REASON,
				   :REG_DATE,
				   :REG_TIME,
			       :HOSP_PLAN_DATE,
				   :DATE_TR_DATE,
				   :DATE_TR_TIME,
		           :DOC_COMMENT,
				   :DIR_LPUDICT_NAME,
				   :DIR_LPUDICT_ID,
				   :HOSP_TYPE,
		           :HOSP_DIRECT_TYPE_ID,
				   :HOMELESS_REASON,
				   :HOSP_MKB_EXACT,
				   :REG_EMP_ID,
				   :REG_EMP_FIO
		      from d_v_directions h
		     where h.ID = :DIRID
		       and h.LPU = :LPU_EDIT;

			select t.LPUDICT_ID
			  into nLPUDICT
			  from d_v_lpu t
			  where t.ID = :pnlpu;
			if :LPUDICT_ID = nLPUDICT then
				:LPUDICT := null;
				:LPUDICT_ID := null;
				:CB := 1;
			else
				:CB := 0;
			end if;
            select case when pmc.LPU =:pnlpu then 1
		                                     else 0
		           end
              into :IS_OUR_PAT
              from D_V_PERSMEDCARD_BASE pmc
		     where pmc.id = :PATIENT_ID;
		end;
		<component cmptype="ActionVar" name="DIRID"               get="var0"             src="DIR_ID"             srctype="var"/>
		<component cmptype="ActionVar" name="pnlpu"                                      src="LPU"                srctype="session"/>
		<component cmptype="ActionVar" name="LPU_EDIT"            get="lpu"              src="LPU"                srctype="var" />
		<component cmptype="ActionVar" name="LPU_EDIT"            put="lpu1"             src="LPU"                srctype="var"         len="17"/>
		<component cmptype="ActionVar" name="OUTER_DIRECTION_ID"  put="var1"             src="OUTERDIRECTIONS"    srctype="ctrl"        len="17"/>
		<component cmptype="ActionVar" name="OUTER_DIRECTION"     put="var2"             src="OUTERDIRECTIONS"    srctype="ctrlcaption" len="31"/>
		<component cmptype="ActionVar" name="PATIENT_ID"          put="var3"             src="PERSMEDCARD"        srctype="ctrl"        len="17"/>
		<component cmptype="ActionVar" name="PATIENT_CARD"        put="var4"             src="PERSMEDCARD"        srctype="ctrlcaption" len="26"/>
		<component cmptype="ActionVar" name="REG_VISIT_ID"        put="var5"             src="VISIT_ID"           srctype="var"         len="17"/>
		<component cmptype="ActionVar" name="DIR_COMMENT"         put="var6"             src="DIR_COMMENT"        srctype="ctrl"        len="500"/>
		<component cmptype="ActionVar" name="REG_TYPE"            put="var7"             src="C_REG_TYPE"         srctype="ctrl"        len="2"/>
		<component cmptype="ActionVar" name="HOSP_MKB_ID"         put="var8"             src="MKB10"              srctype="ctrl"        len="17"/>
		<component cmptype="ActionVar" name="HOSP_MKB"            put="var9"             src="MKB10"              srctype="ctrlcaption" len="10"/>
		<component cmptype="ActionVar" name="HOSP_KIND_ID"        put="var10"            src="C_HOSP_KIND"        srctype="ctrl"        len="17"/>
		<component cmptype="ActionVar" name="DIR_NUMB"            put="var11"            src="DIR_NUMB"           srctype="ctrl"        len="20"/>
		<component cmptype="ActionVar" name="DIR_PREF"            put="var11p"           src="DIR_PREF"           srctype="ctrl"        len="20"/>
		<component cmptype="ActionVar" name="HOSP_DEP_ID"         put="v1"               src="HOSP_DEP"           srctype="ctrl"        len="17"/>
		<component cmptype="ActionVar" name="HOSP_DEP"            put="v2"               src="HOSP_DEP"           srctype="ctrlcaption" len="300"/>
		<component cmptype="ActionVar" name="HOSP_DEPDICT_ID"     put="HOSP_DEPDICT_ID"  src="HOSP_DEPDICT_ID"    srctype="var"         len="17"/>
		<component cmptype="ActionVar" name="HOSP_BED_TYPE_ID"    put="v3"	             src="BED_TYPE"           srctype="var"         len="17"/>
		<component cmptype="ActionVar" name="DIRECTION_KIND_ID"   put="v4"               src="DIR_KIND"           srctype="ctrl"        len="17"/>
		<component cmptype="ActionVar" name="EX_CAUSE_MKB_ID"     put="v25"              src="EX_CAUSE_MKB"       srctype="ctrl"        len="17"/>
		<component cmptype="ActionVar" name="EX_CAUSE_MKB"        put="v26"              src="EX_CAUSE_MKB"       srctype="ctrlcaption" len="10"/>
		<component cmptype="ActionVar" name="INJURE_KIND_ID"      put="v27"              src="INJURE_KIND"        srctype="ctrl"        len="17"/>
		<component cmptype="ActionVar" name="INJURE_KIND"         put="v28"              src="INJURE_KIND"        srctype="ctrlcaption" len="3"/>
		<component cmptype="ActionVar" name="INJURE_TIME"         put="v29"              src="INJURE_TIME"        srctype="var"         len="8"/>
		<component cmptype="ActionVar" name="LPUDICT_HANDLE"      put="v30"              src="LPUDICT_HANDLE"     srctype="ctrl"        len="400"/>
		<component cmptype="ActionVar" name="LPUDICT"             put="v31"              src="LPUDICT"            srctype="ctrlcaption" len="30"/>
		<component cmptype="ActionVar" name="LPUDICT_ID"          put="v32"              src="LPUDICT"            srctype="ctrl"        len="17"/>
		<component cmptype="ActionVar" name="CB"                  put="v33"              src="LLPPUU"             srctype="ctrl"        len="2"/>
		<component cmptype="ActionVar" name="MES"                 put="v34"              src="MESES"              srctype="ctrlcaption" len="20"/>
		<component cmptype="ActionVar" name="MES_ID"              put="v35"              src="MESES"              srctype="ctrl"        len="17"/>
        <component cmptype="ActionVar" name="HOSP_REASON_ID"      put="v36"              src="C_HOSP_REASON"      srctype="ctrl"        len="17"/>
        <component cmptype="ActionVar" name="HOSP_REASON_ID"      put="v36_1"            src="C_HOSP_REASON"      srctype="var"         len="17"/>
        <component cmptype="ActionVar" name="HOSP_REASON"         put="v36_2"            src="HOSP_REASON_NAME"   srctype="var"         len="100"/>
        <component cmptype="ActionVar" name="REG_DATE"            put="v371"             src="REG_DATE_CTRL"      srctype="ctrl"        len="11"/>
        <component cmptype="ActionVar" name="REG_TIME"            put="v37"              src="REG_TIME"           srctype="ctrl"        len="11"/>
		<component cmptype="ActionVar" name="HOSP_PLAN_DATE"      put="vPL"              src="HOSP_PLAN_DATE"     srctype="ctrl"        len="50"/>
        <component cmptype="ActionVar" name="DATE_TR_DATE"        put="pDATE_TR_DATE"    src="DATE_TR_DATE"       srctype="var"         len="10"/>
        <component cmptype="ActionVar" name="DATE_TR_TIME"        put="pDATE_TR_TIME"    src="DATE_TR_TIME"       srctype="var"         len="5"/>
        <component cmptype="ActionVar" name="DOC_COMMENT"         put="DOC_COMMENT"      src="DOC_COMMENT"        srctype="var"         len="4000"/>
        <component cmptype="ActionVar" name="DIR_LPUDICT_NAME"    put="DIR_LPUDICT_NAME" src="DIR_LPUDICT_NAME"   srctype="var"         len="100"/>
        <component cmptype="ActionVar" name="DIR_LPUDICT_ID"      put="DIR_LPUDICT_ID"   src="DIR_LPUDICT_ID"     srctype="var"         len="17"/>
        <component cmptype="ActionVar" name="IS_OUR_PAT"          put="IS_OUR_PAT"       src="IS_OUR_PAT"         srctype="var"         len="1"/>
        <component cmptype="ActionVar" name="HOSP_TYPE"           put="HOSP_TYPE"        src="HOSP_TYPE"          srctype="ctrl"        len="17"/>
		<component cmptype="ActionVar" name="HOSP_DIRECT_TYPE_ID" put="v40"              src="nHOSP_DIRECT_TYPES" srctype="ctrl"        len="17"/>
		<component cmptype="ActionVar" name="HOMELESS_REASON"     put="v41"              src="HOMELESS_REASON"    srctype="ctrl"        len="17"/>
		<component cmptype="ActionVar" name="HOSP_MKB_EXACT"      put="v42"              src="HOSP_MKB_EXACT"     srctype="ctrl"        len="4000"/>
		<component cmptype="ActionVar" name="REG_EMP_ID"          put="REG_EMP_ID"       src="REG_EMPLOYER"       srctype="ctrl"        len="17"/>
		<component cmptype="ActionVar" name="REG_EMP_FIO"         put="REG_EMP_FIO"      src="REG_EMPLOYER"       srctype="ctrlcaption" len="400"/>
	</component>

	<component cmptype="Action" name="getOptionsData">
		begin
			:ADDDIRKINDHOSP     := D_PKG_OPTIONS.GET('ADDDIRKINDHOSP', :LPU);
			:AllowSelectAllLpu  := D_PKG_OPTIONS.GET('AllowSelectAllLpu',:LPU);
			:HHLPUDICT  := D_PKG_OPTIONS.GET('HHLPUDICT',:LPU);
			:AddDirBedProfile  := D_PKG_OPTIONS.GET('AddDirBedProfile',:LPU);
			:AddDirHospDep  := D_PKG_OPTIONS.GET('AddDirHospDep',:LPU);
			:AddDirHospDiagnosis  := D_PKG_OPTIONS.GET('AddDirHospDiagnosis',:LPU);
			:AddDirHospPlanDate  := D_PKG_OPTIONS.GET('AddDirHospPlanDate',:LPU);
			:AddDirHosptalizationKind  := D_PKG_OPTIONS.GET('AddDirHosptalizationKind',:LPU);
		end;
		<component cmptype="ActionVar" name="LPU"                      src="LPU"                      srctype="session" get="g0"/>
		<component cmptype="ActionVar" name="ADDDIRKINDHOSP"           src="ADDDIRKINDHOSP"           srctype="var"     put="p0" len="1"/>
		<component cmptype="ActionVar" name="AllowSelectAllLpu"        src="AllowSelectAllLpu"        srctype="var"     put="p1" len="1"/>
		<component cmptype="ActionVar" name="HHLPUDICT"                src="HHLPUDICT"                srctype="var"     put="p7" len="20"/>
		<component cmptype="ActionVar" name="AddDirBedProfile"         src="AddDirBedProfile"         srctype="var"     put="p2" len="1"/>
		<component cmptype="ActionVar" name="AddDirHospDiagnosis"      src="AddDirHospDiagnosis"      srctype="var"     put="p3" len="1"/>
		<component cmptype="ActionVar" name="AddDirHospPlanDate"       src="AddDirHospPlanDate"       srctype="var"     put="p4" len="1"/>
		<component cmptype="ActionVar" name="AddDirHosptalizationKind" src="AddDirHosptalizationKind" srctype="var"     put="p5" len="1"/>
		<component cmptype="ActionVar" name="AddDirHospDep"            src="AddDirHospDep"            srctype="var"     put="p6" len="1"/>
	</component>

	<component cmptype="Action" name="CheckRightsREC">
		begin
			select  count(*)
			  into :checkREC
			  from table(cast(D_PKG_CSE_ACCESSES.GET_ID_WITH_RIGHTS(:pnlpu,'HOSP_PLAN_KINDS','6', :CABLAB) AS d_c_id )) t1;
		end;
		<component cmptype="ActionVar" name="PNLPU"    src="LPU"    srctype="session"/>
		<component cmptype="ActionVar" name="CABLAB"   src="CABLAB" srctype="session"/>
		<component cmptype="ActionVar" name="checkREC" src="CHREC"  srctype="var" put="var2" len="2"/>
	</component>
	<component cmptype="Action" name="getMKB">
		begin
			select p.ID,
				   p.MKB_CODE
			  into :MKB_ID,
		           :MKB_CODE
			  from d_v_mkb10 p
			 where p.ID = :MKB
			   and p.VERSION = d_pkg_versions.get_version_by_lpu(0,:pnlpu,'MKB10');
		end;
		<component cmptype="ActionVar" name="MKB"       get="var0" src="MKB_ID" srctype="var"/>
		<component cmptype="ActionVar" name="MKB_CODE"  put="var1" src="MKB10"  srctype="ctrlcaption" len="10"/>
		<component cmptype="ActionVar" name="MKB_ID"    put="var2" src="MKB10"  srctype="ctrl"        len="17"/>
		<component cmptype="ActionVar" name="pnlpu"                src="LPU"    srctype="session"/>
	</component>
	<component cmptype="Action" name="GET_DEFAULT_LPU" compile="true">
		<![CDATA[
		begin
			select t2.ID,
                   t2.lpu_code
                   into :DEFAULT_LPU_ID,
                        :DEFAULT_LPU_CODE
              from D_V_LPUDICT t2
             where t2.LPU_CODE = :HHLPUDICT
	        @if (:AllowSelectAllLpu == "0") {
                   and exists(select null from D_V_LPU t where (t.LPUDICT_ID = t2.ID or t.LPUDICT_ID = t2.HID)
				   and D_PKG_CSE_ACCESSES.CHECK_EMPLOYER_RIGHT(:LPU,:EMPLOYER,'LPU',t.ID,7,:CABLAB,0) > 0)
	        @}
			;
			exception when no_data_found then null;
	    end;
	    ]]>
    <component cmptype="ActionVar" name="AllowSelectAllLpu"  src="AllowSelectAllLpu"  srctype="var" get="g0"/>
    <component cmptype="ActionVar" name="LPU" src="LPU" srctype="session" get="g1"/>
    <component cmptype="ActionVar" name="CABLAB" src="CABLAB" srctype="session" get="g2"/>
    <component cmptype="ActionVar" name="EMPLOYER" src="EMPLOYER" srctype="session" get="g3"/>
    <component cmptype="ActionVar" name="HHLPUDICT" src="HHLPUDICT" srctype="var" get="g4"/>
    <component cmptype="ActionVar" name="DEFAULT_LPU_ID" src="DEFAULT_LPU_ID" srctype="var" put="p1" len="17"/>
    <component cmptype="ActionVar" name="DEFAULT_LPU_CODE" src="DEFAULT_LPU_CODE" srctype="var" put="p2" len="20"/>
</component>
	<component cmptype="DataSet" name="DS_HOSP_REASONS" activateoncreate="false" compile="true">
		<![CDATA[
			select t.ID,
				   t.HR_NAME
			  from D_V_HOSP_REASONS t
			 where t.VERSION = d_pkg_versions.get_version_by_lpu(0,:pnLPU,'HOSP_REASONS')
			@if (:REG_DATE_CTRL) {
			   and :REG_DATE_CTRL >= t.BEGIN_DATE
			   and (t.END_DATE is null or :REG_DATE_CTRL <= t.END_DATE)
			@} else {
			   and t.IS_ACTIVE = 1
			@}
		   ]]>
		   <component cmptype="Variable" name="PNLPU"         src="LPU"           srctype="session"/>
		   <component cmptype="Variable" name="REG_DATE_CTRL" src="REG_DATE_CTRL" srctype="ctrl" get="v32" len="25"/>
	</component>
	<component cmptype="DataSet" name="DS_HK">
		select t.ID,
			   t.HK_CODE,
			   t.HK_NAME
		  from d_v_hospitalizationkinds t
		  where t.VERSION = d_pkg_versions.get_version_by_lpu(1,:pnLPU,'HOSPITALIZATIONKINDS')
		  order by HK_CODE
	  <component cmptype="Variable" name="PNLPU" src="LPU" srctype="session"/>
	</component>
	<component cmptype="DataSet" name="DS_HOMELESS_REASON">
		<![CDATA[
			select dfd.ID,
				   dfd.DD_NAME
			  from D_V_DIRECTORIES d
				   join D_V_DIRECTORIES_FN_DATA dfd
					 on dfd.DIR = d.D_CODE
			 where dfd.DATE_END is null
			   and d.D_CODE = '82'
			   and dfd.VERSION  = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'DIRECTORIES_FN_DATA')
		]]>
		<component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
	</component>
	<component cmptype="Action" name="getDefParams">
		begin
			:DIR_PREF := to_char(sysdate, 'yyyy');
			:DIR_NUMB := d_pkg_directions.gen_dir_numb(:LPU,:DIR_PREF);
					begin
						select h.id
						  into :HOSP_KIND
						  from D_V_HOSPITALIZATIONKINDS h
						 where h.HK_CODE = D_PKG_OPTIONS.GET('HH_HOSP_KIND_DEFAULT', :LPU);
					 exception when others then :HOSP_KIND := null;
					end;
					begin
						select dk.ID
						  into :DIR_KIND
						  from D_V_DIRECTION_KINDS dk
						 where dk.DK_CODE = D_PKG_OPTIONS.GET('HH_DIR_KIND_DEFAULT', :LPU);
					 exception when others then :DIR_KIND := null;
					end;

					begin
						select t.ID
						  into :REASON
						  from d_v_hosp_reasons t
						 where t.HR_CODE = D_PKG_OPTIONS.GET('HH_HOSP_REASON_DEFAULT', :LPU);
					 exception when others then :REASON := null;
					end;

          begin
              select t.ID
                into :HOSP_TYPE
                from D_V_HOSPITALIZATION_TYPES t
               where t.HK_CODE = D_PKG_OPTIONS.GET('HH_HOSP_TYPE_DEFAULT', :LPU)
                 and t.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'HOSPITALIZATION_TYPES');
          exception when OTHERS then
              :HOSP_TYPE := null;
          end;

		  if :VISIT_ID is not null then
			  begin
				  select ID,
						 FIO
					into :REG_EMP,
						 :REG_EMP_FIO
					from D_V_EMPLOYERS e
				   where e.ID = :EMPLOYER;
			   exception when NO_DATA_FOUND then null;
			  end;
	      end if;
		end;
		<component cmptype="ActionVar" name="LPU"       src="LPU"           srctype="session"/>
		<component cmptype="ActionVar" name="VISIT_ID"  src="VISIT_ID"      srctype="var" get="VISIT_ID"/>
		<component cmptype="ActionVar" name="EMPLOYER"  src="EMPLOYER"      srctype="session"/>
		<component cmptype="ActionVar" name="DIR_PREF"  src="DIR_PREF"      srctype="ctrl" put="v1"    len="20"/>
		<component cmptype="ActionVar" name="DIR_NUMB"  src="DIR_NUMB"      srctype="ctrl" put="v2"    len="30"/>
		<component cmptype="ActionVar" name="HOSP_KIND" src="C_HOSP_KIND"   srctype="ctrl" put="pvar1" len="17"/>
		<component cmptype="ActionVar" name="DIR_KIND"  src="DIR_KIND"      srctype="ctrl" put="pvar2" len="17"/>
		<component cmptype="ActionVar" name="REASON"    src="C_HOSP_REASON" srctype="ctrl" put="pvar3" len="17"/>
        <component cmptype="ActionVar" name="HOSP_TYPE" src="HOSP_TYPE"     srctype="ctrl" put="pHOSP_TYPE" len="17"/>
        <component cmptype="ActionVar" name="REG_EMP"     src="REG_EMPLOYER" srctype="ctrl" put="p0" len="17"/>
		<component cmptype="ActionVar" name="REG_EMP_FIO" src="REG_EMPLOYER" srctype="ctrlcaption" put="p1" len="400"/>
	</component>
	<component cmptype="DataSet" name="DS_BEDS" compile="true" activateoncreate="false">
		<![CDATA[
			select t.id,
		       	   t.bt_name
		      from d_v_bed_types t
		     where t.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0,:LPU,'BED_TYPES')
			@if (:DEP && :LLPPUU=='1' && !:HOSP_DEPDICT_ID){
			  and t.ID in (select t1.BED_TYPE_ID
						     from D_V_BEDS_FUND t1
						    where t1.PID = :DEP
							  and trunc(sysdate) >= t1.BEGIN_DATE
							  and (t1.END_DATE is null or trunc(sysdate) <= t1.END_DATE))
			@}else{
			  and t.IS_ACTIVE = 1
			@}
		order by t.bt_name
		]]>
		<component cmptype="Variable" name="LPU"    src="LPU"      srctype="session"/>
		<component cmptype="Variable" name="DEP"    src="HOSP_DEP" srctype="ctrl" get="v1"/>
		<component cmptype="Variable" name="LLPPUU" src="LLPPUU"   srctype="ctrl" get="v2"/>
		<component cmptype="Variable" name="HOSP_DEPDICT_ID" src="HOSP_DEPDICT_ID"   srctype="var" get="HOSP_DEPDICT_ID"/>
	</component>
	<component cmptype="DataSet" name="DS_DIR_KIND">
		select *
		  from D_V_DIRECTION_KINDS t
		 where t.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(1, :LPU, 'DIRECTION_KINDS')
		  and t.IS_ACTIVE = 1
		<component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
	</component>
	<component cmptype="Action" name="checkHospDirections">
		begin
			select s.ID
		      into :ID
		     from (
				select t.ID
			      from d_v_directions t
			     where t.REG_VISIT_ID = :VISIT_ID
		           and t.DIR_TYPE = 1
			  order by t.REG_DATE desc
		          ) s
		    where rownum = 1;
		exception when no_data_found then
				:ID := null;
				select to_char(sysdate, 'dd.mm.yyyy')
				  into :REG_DATE
				  from dual;
		end;
		<component cmptype="ActionVar" name="VISIT_ID" 	src="VISIT_ID"      srctype="var"  get="v1"/>
		<component cmptype="ActionVar" name="ID" 	    src="DIR_ID"        srctype="var"  put="v2" len="17"/>
		<component cmptype="ActionVar" name="REG_DATE"  src="REG_DATE_CTRL" srctype="ctrl" put="v3" len="11"/>
	</component>
	<component cmptype="Action" name="getCurrentLPU">
		<component cmptype="ActionVar" name="LPU" src="LPU" srctype="session"/>
		<component cmptype="ActionVar" name="LPU" src="LPU" srctype="var" put="p0" len="17"/>
	</component>
	<component cmptype="Action" name="getCurrentLPUName">
		begin
			if :LLPPUU = 1 then
				begin
					select t.LPUDICT_NAME,
						   t.LPUDICT_ID
				  	  into :CUR_LPU_NAME,
						   :CUR_LPU_DICT_ID
					  from d_v_lpu t
					 where t.id = :LPU;
				exception when no_data_found then
					  :CUR_LPU_NAME := null;
					  :CUR_LPU_DICT_ID := null;
				end;
			else
				begin
					select t.LPU_NAME
					  into :CUR_LPU_NAME
					  from d_v_lpudict t
					 where t.id = :LPUDICT;
				exception when no_data_found then
					  :CUR_LPU_NAME := null;
				end;
			end if;
		end;
		<component cmptype="ActionVar" name="LPU"             src="LPU"             srctype="session" get="g0"/>
		<component cmptype="ActionVar" name="LLPPUU"          src="LLPPUU"          srctype="ctrl"    get="g1"/>
		<component cmptype="ActionVar" name="LPUDICT"         src="LPUDICT"         srctype="ctrl"    get="g2"/>
		<component cmptype="ActionVar" name="CUR_LPU_NAME"    src="CUR_LPU_NAME"    srctype="var"     put="p1" len="100"/>
		<component cmptype="ActionVar" name="CUR_LPU_DICT_ID" src="CUR_LPU_DICT_ID" srctype="var"     put="p2" len="17"/>
	</component>
	<component cmptype="Script">
			<![CDATA[
		Form.OnCreate = function () {
			if (empty(getVar('PATIENT_ID'))) setVar('PATIENT_ID', getVar('PATIENT_ID', 1));
			setVar('DIR_ID', getVar('DIR_ID'));
			if (empty(getVar('VISIT_ID'))) setVar('VISIT_ID', getVar('VISIT_ID', 1));
			if (!empty(getVar('VISIT_ID'))) {
				setValue('OUTERDIRECTIONS', null);
				setControlProperty('OUTERDIRECTIONS', 'enabled', false);
			}
			if (empty(getVar('DIR_ID'))) executeAction('checkHospDirections', null, null, null, 0, 0);
			if (!empty(getVar('DIR_ID')))
				setVar('mode', 'edit');
			else
				setVar('mode', 'add');
		}
		Form.OnClose = function () {
			if (getValue('DIR_NUMB')) executeAction('freeDirNumbReserve');
		}
		Form.OnShow = function () {
			if (!empty(getVar('PATIENT_ID'))) {
				setValue('PERSMEDCARD', getVar('PATIENT_ID'));
				if (getVar('PAT_CARD') || getVar('PAT_CARD', 1)) {
					setCaption('PERSMEDCARD', getVar('PAT_CARD') || getVar('PAT_CARD', 1))
				} else {
					executeAction('getCardNumb');
				}
				setControlProperty('PERSMEDCARD', 'enabled', false);
			}
			else {
				setControlProperty('PERSMEDCARD', 'enabled', true);
			}
			var wincap = null;
			executeAction('getOptionsData', function () {
				if (getVar('ADDDIRKINDHOSP') == 1) {
					setControlProperty('DPC', 'add_req', 'DIR_KIND');
					setControlProperty('DPC2', 'add_req', 'DIR_KIND');
				} else {
					setControlProperty('DPC', 'del_req', 'DIR_KIND');
					setControlProperty('DPC2', 'del_req', 'DIR_KIND');
				}

				if (getVar('AddDirBedProfile') == 1) {
					setControlProperty('DPC', 'add_req', 'BED');
					setControlProperty('DPC2', 'add_req', 'BED');
				}
				else {
					setControlProperty('DPC', 'del_req', 'BED');
					setControlProperty('DPC2', 'del_req', 'BED');
				}

				if (getVar('AddDirHospDiagnosis') == 1) {
					setControlProperty('DPC', 'add_req', 'MKB10');
					setControlProperty('DPC2', 'add_req', 'MKB10');
				}
				else {
					setControlProperty('DPC', 'del_req', 'MKB10');
					setControlProperty('DPC2', 'del_req', 'MKB10');
				}

				if (getVar('AddDirHospPlanDate') == 1) {
					setControlProperty('DPC', 'add_req', 'HOSP_PLAN_DATE');
					setControlProperty('DPC2', 'add_req', 'HOSP_PLAN_DATE');
				}
				else {
					setControlProperty('DPC', 'del_req', 'HOSP_PLAN_DATE');
					setControlProperty('DPC2', 'del_req', 'HOSP_PLAN_DATE');
				}

				if (getVar('AddDirHosptalizationKind') == 1) {
					setControlProperty('DPC', 'add_req', 'C_HOSP_KIND');
					setControlProperty('DPC2', 'add_req', 'C_HOSP_KIND');
				}
				else {
					setControlProperty('DPC', 'del_req', 'C_HOSP_KIND');
					setControlProperty('DPC2', 'del_req', 'C_HOSP_KIND');
				}

				if (getVar('AddDirHospDep') == 1) {
					setControlProperty('DPC', 'add_req', 'HOSP_DEP');
					setControlProperty('DPC2', 'add_req', 'HOSP_DEP');
				}
				else {
					setControlProperty('DPC', 'del_req', 'HOSP_DEP');
					setControlProperty('DPC2', 'del_req', 'HOSP_DEP');
				}
			});
			if (getVar('mode') == 'edit') {
				executeAction('SelectAction', base().afterSelectAction);
			} else {
				refreshDataSet('DS_BEDS');
				var date = new Date();
				setCaption('REG_TIME', date.getHours() + ':' + (date.getMinutes() < 10 ? '0' : '') + date.getMinutes());
				executeAction('getDefParams');
				setWindowCaption('Добавление направления');
				if (!empty(getVar('MKB_ID'))) {
					executeAction('getMKB');
				}
				if (!empty(getVar('DIR_COMMENT')))
					setValue('DIR_COMMENT', getVar('DIR_COMMENT').substr(0, 500));
				refreshDataSet('DS_HOSP_REASONS');
				Form.PatientSelect();
			}

            getDataSet('DS_BEDS').addEventListener('afterrefresh', "base().refreshDepControls();");
			getPage(0).addListener('onchangepropertyLPUDICT', function (_dom, _cn, _pn, _pv) {
				if (_pn === 'value' && _cn === 'LPUDICT') {
					Form.setLpuReqs();
				}
			}, base(), false);
		}

		Form.SetEditMode = function () {
			setWindowCaption('Исправление направления');
			getControlByName('ButtonPrint').style.display = '';
			if (getValue('C_REG_TYPE') == 0) {
				executeAction('CheckRightsREC', function () {
					if (getVar('CHREC') > 0) {
						setControlProperty('ButtonNext', 'enabled', true);
						setControlProperty('ButtonNextByDay', 'enabled', true);
					}
				}, null, null);
			} else {
				setControlProperty('ButtonNext', 'enabled', false);
				setControlProperty('ButtonNextByDay', 'enabled', false);
			}
		}
		Form.afterSelectAction = function () {
			setValue('DATE_TR_DATE', getVar('DATE_TR_DATE'));
			setValue('DATE_TR_TIME', getVar('DATE_TR_TIME'));
			setValue('INJURE_TIME', parseToOracleFloat(getVar('INJURE_TIME')));
			if (getValue('INJURE_TIME') == 0) setValue('INJURE_TIME', null);
			refreshDataSet('DS_BEDS');
			if (!empty(getValue('EX_CAUSE_MKB')) || !empty(getValue('INJURE_KIND')) || !empty(getValue('INJURE_TIME')))
				Form.showhideInjure();
            base().setVisLpu(null, true);
			base().setLpuReqs();
			Form.PatientSelect();
			refreshDataSet('DS_HOSP_REASONS');
			base().SetEditMode();
		}
		Form.OUTDIRS = function () {
			setVar('LOCATE_ID', getValue('OUTERDIRECTIONS'));
			setVar('RecordID', getValue('PERSMEDCARD'));
			openWindow('OuterDirections/outerdirections_view', true, 850, 550)
					.addListener('onclose', function () {
						if (getVar('ModalResult', 1) == 'ok') {
							setValue('OUTERDIRECTIONS', getValue('grOuterDirs'), 1);
							setCaption('OUTERDIRECTIONS', getControlProperty('grOuterDirs', 'data')['D_DATE'], 1);
						}
					});
		}
		Form.OnButtonOKClick = function (type) {
			setVar('REG_DATE_VAR', getCaption('REG_DATE_CTRL') + ' ' + getCaption('REG_TIME'));
			setVar('INJURE_TIME', getValue('INJURE_TIME'));
			if (empty(getVar('LPU'))) {
				executeAction('getCurrentLPU', null, null, 0, 0);
			}

			if (getVar('mode') == 'edit') {
				var call_confirm = 0;

				executeAction('getCurrentLPUName', null, null, 0, 0);

				if (getValue('LLPPUU') == '1') {
					if (getVar('DIR_LPUDICT_ID') != getVar('CUR_LPU_DICT_ID') && !empty(getVar('DIR_LPUDICT_ID'))) {
						call_confirm = 1;
					}
				}
				else {
					if (getVar('DIR_LPUDICT_ID') != getValue('LPUDICT')) {
						call_confirm = 1;
					}
				}

				if (call_confirm == 1) {
					if (confirm('С данной услуги уже было создано направление в ЛПУ ' + getVar('DIR_LPUDICT_NAME') + '. Вы действительно хотите направить пациента в ЛПУ ' + getVar('CUR_LPU_NAME') + ' и удалить направление в ЛПУ ' + getVar('DIR_LPUDICT_NAME') + '?')) {
						if (getValue('LLPPUU') == '1') {
							setVar('DIR_LPUDICT_ID', getVar('CUR_LPU_DICT_ID'));
						}
						else {
							setVar('DIR_LPUDICT_ID', getValue('LPUDICT'));
						}

						executeAction('UpdateAction', function () {
							base().AfterExecuteActionSuccess(type)
						});
					}
					else {
						closeWindow();
					}
				}
				else {
					executeAction('UpdateAction', function () {
						base().AfterExecuteActionSuccess(type)
					});
				}
			}
			else
				executeAction('InsertAction', function () {
					base().AfterExecuteActionSuccess(type)
				});
		}

		Form.AfterExecuteActionSuccess = function (type) {
			if (getVar('mode') != 'edit')
				setVar('newid', getVar('NewID'), 1);
			setVar('ModalResult', 'ok', 1);
			if (type == 1) closeWindow(this);
			else {
				setVar('mode', 'edit');
				if (empty(getVar('DIR_ID'))) setVar('DIR_ID', getVar('NewID'));
				executeAction('SelectAction', null, null, 0, 0);
				setValue('DATE_TR_DATE', getVar('DATE_TR_DATE'));
				setValue('DATE_TR_TIME', getVar('DATE_TR_TIME'));
				setValue('INJURE_TIME', parseToOracleFloat(getVar('INJURE_TIME')));
				if (getValue('INJURE_TIME') == 0) setValue('INJURE_TIME', null);
				base().SetEditMode();
			}
		}
		Form.trySetBedType = function () {
			if (!empty(getVar('BED_TYPE'))) {
				setValue('BED', getVar('BED_TYPE'));
				setVar('BED_TYPE', null);
			} else if (!empty(getValue('HOSP_DEP'))) {
				executeAction('getOnlyOneBed', function () {
					if (!empty(getVar('TEMP_BED_ID')))
						setValue('BED', getVar('TEMP_BED_ID'));
				});
			}
		}
		Form.openMesByMkb = function (_dom) {
			if (empty(getValue('MKB10'))) {
				alert('Не выбран диагноз!');
				return;
			}
			if (empty(getValue('PERSMEDCARD'))) {
				alert('Не выбран пациент!');
				return;
			}
			setVar('HOSP_MKB', getValue('MKB10'));
			setVar('PATIENT_ID', getValue('PERSMEDCARD'));
			openWindow('HospPlan/select_mes_by_mkb', true)
					.addListener('onclose', function () {
						if (getVar('ModalResult', 1) == 1)
							getValueAfterSelect(_dom);
					});
		}
		Form.showhideInjure = function () {
			var elem1 = getControlByName('INJURES');
			if (elem1.style.display == "none") {
				elem1.style.display = "block";
				setCaption('INJShowHide', 'Скрыть');
			}
			else {
				elem1.style.display = "none";
				setCaption('INJShowHide', 'Показать');
			}
		}
		Form.setVisLpu = function (clear, only_checks) {
			if (clear == 1) {
				clearControl('HOSP_DEP');
				clearControl('LPUDICT');
				clearControl('LPUDICT_HANDLE');
			}
			var enab = (getValue('LLPPUU') != 1);
			if (enab) {
				Form.switchReqs('LPUDICT', 1);
				Form.switchReqs('LPUDICT_HANDLE', 1);
			} else {
				Form.switchReqs('LPUDICT', 0);
				Form.switchReqs('LPUDICT_HANDLE', 0);
			}
			setControlProperty('LPUDICT', 'enabled', enab);

			if (getVar('AllowSelectAllLpu') == '0') setControlProperty('LPUDICT_HANDLE', 'enabled', enab);
            if(!only_checks) {
			if (!empty(getVar('HHLPUDICT')) && empty(getVar('DEFAULT_LPU_ID')) && getValue('LLPPUU') == 0) {
				executeAction('GET_DEFAULT_LPU', function () {
					if (!empty(getVar('DEFAULT_LPU_ID'))) {
						setValue('LPUDICT', getVar('DEFAULT_LPU_ID'));
						setCaption('LPUDICT', getVar('DEFAULT_LPU_CODE'));
					}
				});
			} else if (!empty(getVar('DEFAULT_LPU_ID')) && enab) {
				setValue('LPUDICT', getVar('DEFAULT_LPU_ID'));
				setCaption('LPUDICT', getVar('DEFAULT_LPU_CODE'));
			}
            }
		}
		Form.setLpuReqs = function () {
			var ld = getValue('LPUDICT');
			var ldh = getValue('LPUDICT_HANDLE');
			if (empty(ld) && empty(ldh)) {
				Form.switchReqs('LPUDICT', 1);
				Form.switchReqs('LPUDICT_HANDLE', 1);
			} else if (empty(ldh)) {
				Form.switchReqs('LPUDICT', 1);
				Form.switchReqs('LPUDICT_HANDLE', 0);
			} else if (empty(ld)) {
				Form.switchReqs('LPUDICT', 0);
				Form.switchReqs('LPUDICT_HANDLE', 1);
			} else {
				Form.switchReqs('LPUDICT', 0);
				Form.switchReqs('LPUDICT_HANDLE', 1);
			}
		}
		Form.switchReqs = function (ctrl, add) {
			var func = add ? AddReqControl : DelReqControl;
			['DPC', 'DPC2'].forEach(function (depCtrl) {
				func(getControlByName(depCtrl), ctrl);
			});
		}
		Form.openDeps = function (_dom) {
			var _form = {}, _filter;
			_form.name = 'UniversalComposition/UniversalComposition';
			if (getValue('LLPPUU') == 1) {
				_form.unit = 'DEPS';
				_form.composition = 'GRID';
				_filter = 'd_pkg_dep_requisites.get_actual(:LPU, v.ID, to_date(\'' + getValue('REG_DATE_CTRL') + '\')) is not null';
				_form.filter = {0: {'unit': 'DEPS', 'method': 'GRID', 'filter': _filter}};

        openWindow(_form, true).addListener('onclose', function () {
          getValueAfterSelect(_dom);
          if (getVar('ModalResult', 1) == 1)
            refreshDataSet('DS_BEDS', true, 1);
        });
			} else {
          openD3Form('Compositions/depdict_grid', true, {
                      width: 800,
                      height: 600,
                      vars: {
                          NULL_LPUDICT_FILTER: empty(getValue('LPUDICT')) ? true : false,
                          LPUDICT_FILTER: getValue('LPUDICT')
                      },
                      onclose: function(mod) {
                          if(mod) {
                              setValue('HOSP_DEP', mod.return_id);
                              setCaption('HOSP_DEP', mod.return);

                              refreshDataSet('DS_BEDS');
                          }
                      }
                  });
			}
		};
		Form.PrintDirectionToHosp = function () {
			if (getVar('mode') == 'edit') {
				setVar('DIRECTION_ID', getVar('DIR_ID'));
			}
			else {
				setVar('DIRECTION_ID', getVar('NewID'));
			}
			printReportByCode('HOSPITALISATION_DIR1');
		}
		Form.OnButtonNextClick = function () {
			if (getControlProperty('ButtonNext', 'enabled') == 'false') return;
			if (getVar('mode') == 'edit') {
				setVar('DIRECTION', getVar('DIR_ID'));
			}
			else {
				setVar('DIRECTION', getVar('NewID'));
			}

			if (getValue('LLPPUU') == 0 &amp;&amp; !empty(getValue('LPUDICT'))) {
				setVar('OUTER_LPUDICT', getValue('LPUDICT'));
			}

			openWindow({name: 'HospPlan/hospplanperiod', vars: {VIS_ID: getVar('VISIT_ID')}}, true, 1000, 540);
		}
		Form.OnButtonNextByDayClick = function () {
			if (getControlProperty('ButtonNextByDay', 'enabled') == 'false') return;
			if (getVar('mode') == 'edit') {
				setVar('DIRECTION', getVar('DIR_ID'));
			}
			else {
				setVar('DIRECTION', getVar('NewID'));
			}

			if (getValue('LLPPUU') == 0 &amp;&amp; !empty(getValue('LPUDICT'))) {
				setVar('OUTER_LPUDICT', getValue('LPUDICT'));
			}

			openWindow({
				name: 'HospPlan/hospplan',
				vars: {VIS_ID: getVar('VISIT_ID'), PMC_ID: getVar('PATIENT_ID'), DDIR_ID: getVar('DIRECTION')}
			}, true, 1200, 540);
		}
		Form.setOuterLpu = function () {
		    var input = getControlProperty('LPUDICT','input')
			input.style = "background-color:white";
			if (getCaption('LPUDICT')== ''){
			    setValue('LPUDICT','');
			} else {
			    executeAction('setOuterLpu',function () {
					var lpudict = getVar('LPUDICT_ID')
			        if (lpudict == ''){
						input.style = "background-color:red";
						setValue('LPUDICT','')
					} else {
					    setValue('LPUDICT',lpudict)
					}
				})
			}
			Form.setLpuReqs();
		}
		Form.selectOuterHospLPU = function () {
			openWindow({
				name: 'HospPlan/select_lpu_outer_hosp',
				vars: {
					lpudict_id: getVar('LPUDICT_ID')
				}
			}, true)
					.addListener('onafterclose', function () {
						if (getVar('ModalResult') == 1)
							base().afterSelectOuterHospLPU();
					});
		}
		Form.selectMkbExact = function (_dom) {
			setVar('MkbExactValue', getControlValue(buttonEdit_getControl(_dom)));
			openWindow('ArmPatientsInDep/SubForms/select_mkb_exact', true)
					.addListener('onafterclose', function () {
						if (getVar('ModalResult') == 1)
							setControlValue(buttonEdit_getControl(_dom), getVar('return_value'));
					});
		}
		Form.afterSelectOuterHospLPU = function () {
			setValue('LPUDICT', getVar('return_id'));
			setCaption('LPUDICT', getVar('return'));
		}
		Form.checkHR = function () {
			if (empty(getValue('C_HOSP_REASON')) && !empty(getVar('C_HOSP_REASON'))) {
				setValue('C_HOSP_REASON_ACTIVE', null);
				ComboBox_SetColor(getControlByName('C_HOSP_REASON'), 'red');
				ComboBox_SetCaption(getControlByName('C_HOSP_REASON'), getVar('HOSP_REASON_NAME'), false, true);
			} else {
				setValue('C_HOSP_REASON_ACTIVE', 'active');
			}
			;
		};
		Form.openPersMedCard = function () {
			if (empty(getValue('PERSMEDCARD'))) {
				alert('Не выбран пациент.');
				return;
			}
			if (getVar('IS_OUR_PAT') == 0) {
				alert('Пациент не относится к текущему ЛПУ. Редактирование карты невозможно.');
				return;
			}

			setVar('PERSMEDCARD', getValue('PERSMEDCARD'));
			openWindow('Persmedcard/persmedcard_edit', true, 800, 580).addListener('onclose',
                 function () {
                     if (getVar('ModalResult', 1) == 1) {
                         Form.PatientSelect();
                     }
                 });
		}
		Form.onChangeHospPlanDate = function () {
			if (getVar('AddDirHospPlanDate') == 1) {
				if (empty(getValue('HOSP_PLAN_DATE'))) {
					setControlProperty('DPC', 'add_req', 'HOSP_PLAN_DATE');
					setControlProperty('DPC2', 'add_req', 'HOSP_PLAN_DATE');
				}
				else {
					setControlProperty('DPC', 'del_req', 'HOSP_PLAN_DATE');
					setControlProperty('DPC2', 'del_req', 'HOSP_PLAN_DATE');
				}
			}
		}
		Form.CountHours = function () {
			if (getValue('DATE_TR_TIME') == getVar('DATE_TR_TIME')) {
				return;
			}
			setVar('DATE_TR_TIME', null);
			if (!empty(getValue('DATE_TR_DATE'))) {
				var today = new Date();
				var text = getValue('DATE_TR_DATE') + ' ' + (!empty(getValue('DATE_TR_TIME')) ? getValue('DATE_TR_TIME') : '00:00')
				var date = new Date(text.replace(/(\d+).(\d+).(\d+)/, '$3/$2/$1'));
				setValue('INJURE_TIME', parseToOracleFloat(((today - date) / (1000 * 60 * 60)).toFixed(2)));
			} else         setValue('INJURE_TIME', '');
		}
		Form.CountTrDate = function () {
			if (getValue('INJURE_TIME') == getVar('INJURE_TIME')) {
				return;
			}
			setVar('INJURE_TIME', null);
			if (!empty(getValue('INJURE_TIME'))) {
				var today = new Date();
				var hour_in_ms = parseToJSFloat(getValue('INJURE_TIME')) * 1000 * 60 * 60;
				var tr_date = new Date(today - hour_in_ms);
				var day = tr_date.getDate();
				var month = tr_date.getMonth() + 1;
				setValue('DATE_TR_DATE', ((day < 10) ? "0" : '') + day + '.' + ((month < 10) ? "0" : '') + month + '.' + tr_date.getFullYear());
				var hh = tr_date.getHours();
				var min = tr_date.getMinutes();
				setValue('DATE_TR_TIME', ((hh < 10) ? "0" : '') + hh + ':' + ((min < 10) ? "0" : '') + min);
			} else {
				setValue('DATE_TR_DATE', '');
				setValue('DATE_TR_TIME', '');
			}
		}
		Form.PatientSelect = function() {
    		var el = document.getElementsByClassName('hidden_tr');
    		executeAction('GetAgentId', function(){
        		setVar('AGENT', getVar('AGENT'));
				executeAction('CheckHomeLess', function() {
					if(getVar('IS_HOMELESS') == 1) {
						el[0].style.display = '';
					} else {
						el[0].style.display = 'none';
					}
				});
			});
		}
        Form.refreshDepControls = function() {
            DepControls_Refresh('DPC');
            DepControls_Refresh('DPC2');
        };
		]]>
	</component>

	<component cmptype="Action" name="setOuterLpu">
		<![CDATA[
		begin
			select t.ID
              into :LPUDICT_ID
          	  from d_v_lpudict t
			 where t.LPU_CODE = :LPU_CODE;
		 exception when no_data_found then
		 		   :LPUDICT_ID := null;
        end;
		]]>
		<component cmptype="ActionVar" name="LPU_CODE"    src="LPUDICT"    srctype="ctrlcaption" get="v0" />
		<component cmptype="ActionVar" name="LPUDICT_ID"  src="LPUDICT_ID" srctype="var" 	   put="v1" len="20" />
	</component>

	<component cmptype="Action" name="getOnlyOneBed">
	  <![CDATA[
		  begin
			select t.ID
			  into :TEMP_BED_ID
			  from d_v_bed_types t
			 where t.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0,:LPU,'BED_TYPES')
			   and (t.id in (select bed_type_id
				               from d_v_beds_fund
				              where pid = :DEP_ID
					            and TRUNC(sysdate) >= begin_date
					            and (end_date is null or TRUNC(sysdate) <= end_date)));
		 exception when NO_DATA_FOUND then :TEMP_BED_ID := null;
			       when TOO_MANY_ROWS then :TEMP_BED_ID := null;
		  end;
	  ]]>
	  <component cmptype="ActionVar" name="LPU"         src="LPU"         srctype="session"/>
	  <component cmptype="ActionVar" name="DEP_ID"      src="HOSP_DEP"    srctype="ctrl" get="v2"/>
	  <component cmptype="ActionVar" name="TEMP_BED_ID" src="TEMP_BED_ID" srctype="var"  put="v3" len="17"/>
	</component>
	<component cmptype="Action" name="CheckHomeLess">
	   <![CDATA[
		   begin
				select case when aoc.CATEGORY in (5,6) then 1 else 0 end
				  into :IS_HOMELESS
				  from D_V_AGENTS a
					   left join D_V_AGENT_ORPH_CATEGORIES aoc
						 on aoc.PID = a.ID
				 where a.id = :ID
				   and (aoc.END_DATE is null
					or aoc.END_DATE >= case when :REG_DATE is not null then  to_date(:REG_DATE, 'dd.mm.yyyy hh24:mi') else trunc(sysdate) end);
			 exception when NO_DATA_FOUND then
					   :IS_HOMELESS := 0;
		   end;
	   ]]>
	   <component cmptype="ActionVar" name="ID"          src="AGENT"         srctype="var"  get="g0"/>
	   <component cmptype="ActionVar" name="REG_DATE"    src="REG_DATE_CTRL" srctype="ctrl" get="g1"/>
	   <component cmptype="ActionVar" name="IS_HOMELESS" src="IS_HOMELESS"   srctype="var"  put="p0" len="1"/>
	</component>
	<component cmptype="Action" name="GetAgentId">
	   <![CDATA[
		   begin
			   select AGENT
				 into :AGENT
				 from D_V_PERSMEDCARD_BASE
				where ID = :PMC
		          and LPU = :LPU;
			exception when NO_DATA_FOUND then
					  :AGENT := null;
		   end;
	   ]]>
	   <component cmptype="ActionVar" name="LPU"   src="LPU" 		 srctype="session"/>
	   <component cmptype="ActionVar" name="PMC"   src="PERSMEDCARD" srctype="ctrl" get="g0"/>
	   <component cmptype="ActionVar" name="AGENT" src="AGENT"       srctype="var"  put="p0" len="17"/>
	</component>
	<table width="100%">
		<component cmptype="DepControls" name="DPC" requireds="PERSMEDCARD;DIR_NUMB;DIR_KIND;C_HOSP_REASON_ACTIVE;BED;MKB10;HOSP_PLAN_DATE;C_HOSP_KIND;HOSP_DEP" dependents="ButtonOk"/>
		<component cmptype="DepControls" name="DPC2" requireds="DIR_KIND;BED;MKB10;HOSP_PLAN_DATE;C_HOSP_KIND;HOSP_DEP" dependents="ButtonOkSave"/>
		<tr>
			<td style="padding-top:3pt">
				<component cmptype="label" caption="Пациент:"/>
			</td>
			<td style="padding-top:3pt" colspan="3">
            	<component cmptype="UnitEdit" name="PERSMEDCARD" unit="PERSMEDCARD" composition="BUTTON_EDIT_DEFAULT" width="100%" enabled="false" emptyMask="true">
              		<component cmptype="Button" type="micro" title="Редактировать карту" background="Icons/person_edit" onclick="base().openPersMedCard();"/>
            	</component>
			</td>
		</tr>
		<tr>
			<td style="padding-top:3pt">
				<component cmptype="label" caption="Номер:"/>
			</td>
			<td style="padding-top:3pt; width:80px;">
				<component cmptype="Edit" name="DIR_PREF" width="100%"/>
			</td>
			<td style="padding-top:3pt">
				<div style="height:20px;display:inline-block;padding: 0 5px;">
					<component cmptype="Label" caption=" - "/>

				</div>
				<component cmptype="Edit" name="DIR_NUMB" width="84%" emptyMask="true"/>
			</td>
			<td style="padding-top:3pt">
				<img src="Images/ok.gif" style="cursor:pointer" onclick="executeAction('GetDirNumb');"/>
			</td>
		</tr>
		<tr>
	 		<td style="padding-top:3pt">
				<component cmptype="label" caption="Дата создания:"/>
			</td>
			<td style="padding-top:3pt; width:80px;">
				<component cmptype="DateEdit" name="REG_DATE_CTRL" width="100%"/>
			</td>
			<td style="padding-top:3pt">
				<component cmptype="Edit" name="REG_TIME" regularMask="^[0-9]{2}:[0-9]{2}$" originalMask="00:00" templateMask="99:99"/>
				<component cmptype="MaskInspector" name="MainMaskInspector" effectControls="ButtonOkSave" controls="REG_TIME" />
			</td>
		</tr>
		<tr>
			<td style="padding-top:3pt">
				<component cmptype="label" caption="ЛПУ:"/>
			</td>
			<td style="padding-top:3pt">
				<component cmptype="CheckBox" name="LLPPUU" caption="Текущее" valuechecked="1" valueunchecked="0" activ="1" onclick="base().setVisLpu(1);"/>
			</td>
			<td style="padding-top:3pt;text-align:right;" colspan="2">
				<!--<component cmptype="UnitEdit" name="LPUDICT" unit="LPUDICT" composition="LD_GRID" enabled="false"/>-->
				<component cmptype="ButtonEdit" name="LPUDICT" unit="LPUDICT" buttononclick="base().selectOuterHospLPU();" onchange="base().setOuterLpu();" enabled="false" />
			</td>
		</tr>
		<tr>
			<td style="padding-top:3pt">
				<component cmptype="label" caption="Ручной ввод:"/>
			</td>
			<td style="padding-top:3pt" colspan="3">
				<component cmptype="Edit" name="LPUDICT_HANDLE" width="100%" enabled="false" onchange="base().setLpuReqs();"/>
			</td>
		</tr>
		<tr>
			<td style="padding-top:3pt;">
				<component cmptype="Label" caption="Отделение госпитализации:"/>
			</td>
			<td style="padding-top:3pt;" colspan="3">
				<component cmptype="ButtonEdit" name="HOSP_DEP" unit="DEPS" onshow="setVar('FILTER_CONNECT','HOSPITAL');" buttononclick="base().openDeps(buttonEdit_getControl(this));" readonly="true" width="100%" emptyMask="true">
					<component cmptype="Button" type="micro" background="Icons/btn_erase" onclick="clearControl('HOSP_DEP');refreshDataSet('DS_BEDS');" title="Очистить отделение"/>
				</component>
			</td>
		</tr>
		<tr>
			<td style="padding-top:3pt;">
				<component cmptype="Label" caption="Профиль койки:"/>
			</td>
			<td style="padding-top:3pt;" colspan="3">
				<component cmptype="ComboBox" name="BED" width="100%" emptymask="true">
					<component cmptype="ComboItem" caption="" value=""/>
					<component cmptype="ComboItem" repeate="0" dataset="DS_BEDS" captionfield="BT_NAME" datafield="ID" afterrefresh="base().trySetBedType();"/>
				</component>
			</td>
		</tr>
		<tr>
			<td style="padding-top:3pt;">
			</td>
			<td style="padding-top:3pt;">
			</td>
		</tr>
		<tr>
			<td style="padding-top:3pt">
				<component cmptype="label" caption="Внешнее направление:"/>
			</td>
			<td style="padding-top:3pt" colspan="3">
				<component cmptype="ButtonEdit" name="OUTERDIRECTIONS" unit="hz" buttononclick="base().OUTDIRS()" readonly ="true" width="100%">
					<component cmptype="Button" type="micro" background="Icons/btn_erase" onclick="setValue('OUTERDIRECTIONS','');setCaption('OUTERDIRECTIONS','');" title="Очистить направление"/>
				</component>
			</td>
		</tr>
		<tr>
			<td style="padding-top:3pt">
				<component cmptype="label" caption="Вид госпитализации:"/>
			</td>
			<td style="padding-top:3pt" colspan="3">
				<component cmptype="ComboBox" name="C_HOSP_KIND" width="100%" emptyMask="true">
					<component cmptype="ComboItem" caption=" " value="" activ="true"/>
					<component cmptype="ComboItem" datafield="ID" captionfield="HK_NAME" dataset="DS_HK" repeate="0"/>
				</component>
			</td>
		</tr>
		<tr>
		  	<td style="padding-top:3pt">
				<component cmptype="label" caption="Причина госпитализации:"/>
		  	</td>
		  	<td style="padding-top:3pt" colspan="3">
				<component cmptype="ComboBox" name="C_HOSP_REASON" width="100%" emptymask="false" onclick="setValue('C_HOSP_REASON_ACTIVE', 'active');">
					<component cmptype="ComboItem" caption="" value="" activ="true"/>
					<component cmptype="ComboItem" datafield="ID" captionfield="HR_NAME" dataset="DS_HOSP_REASONS" afterrefresh="base().checkHR();" repeate="0"/>
				</component>
				<component cmptype="MaskInspector" name="MaskInspector" controls="C_HOSP_REASON" />
				<component cmptype="Edit" name="C_HOSP_REASON_ACTIVE" value="active" style="display: none;" emptyMask="true"/>
		  	</td>
		</tr>
		<tr cmptype="tmp" name="trHospType">
			<td style="padding-top: 3pt;">
				<component cmptype="Label" caption="Тип госпитализации:"/>
			</td>
			<td style="padding-top: 3pt;" colspan="3">
				<component cmptype="UnitEdit" name="HOSP_TYPE" unit="HOSPITALIZATION_TYPES" method="LIST" type="ComboBox" emptyMask="true" width="100%"/>
			</td>
		</tr>
		<component cmptype="SubForm" path="HospPlanJournal/DirectionHospDirectTypes"/>
		<tr>
			<td style="padding-top:3pt">
				<component cmptype="label" caption="Тип регистрации:"/>
			</td>
			<td style="padding-top:3pt" colspan="3">
				<component cmptype="ComboBox" name="C_REG_TYPE" width="100%">
					<component cmptype="ComboItem" caption="Обычная" value="0" activ="true"/>
					<component cmptype="ComboItem" caption="Квоты" value="2"/>
					<component cmptype="ComboItem" caption="Удаленно" value="3"/>
				</component>
			</td>
		</tr>

		<tr>
			<td style="padding-top:3pt">
				<component cmptype="label" caption="Диагноз госпитализации:"/>
			</td>
			<td style="padding-top:3pt" colspan="3">
				<component cmptype="UnitEdit" name="MKB10" unit="MKB10" composition="MKB_SHORT" width="100%" oncreate="MKB10Input(this);" emptyMask="true"/>
			</td>
		</tr>
		<tr>
			<td style="padding-top:3pt;">
				<component cmptype="label" caption="МЭС:"/>
			</td>
			<td style="padding-top:3pt" colspan="3">
				<component cmptype="ButtonEdit" name="MESES" unit="hz" buttononclick="base().openMesByMkb(buttonEdit_getControl(this));" readonly="true" width="100%">
					<component cmptype="Button" type="micro" background="Icons/btn_erase" onclick="setValue('MESES','');setCaption('MESES','');" title="Очистить направление"/>
				</component>
			</td>
		</tr>
		<tr>
			<td style="padding-top:3pt;">
				<component cmptype="Label" caption="Вид направления:"/>
			</td>
			<td style="padding-top:3pt;" colspan="3">
				<component cmptype="ComboBox" name="DIR_KIND" width="100%" emptymask="true">
					<component cmptype="ComboItem" caption="" value=""/>
					<component cmptype="ComboItem" repeate="0" dataset="DS_DIR_KIND" captionfield="DK_NAME" datafield="ID"/>
				</component>
			</td>
		</tr>

		<tr class="hidden_tr">
			<td style="padding-top:3pt;">
				<component cmptype="Label" caption="Причина помещени в МО (беспризорные):"/>
			</td>
			<td style="padding-top:3pt;" colspan="3">
				<component cmptype="ComboBox" name="HOMELESS_REASON" width="100%">
					<component cmptype="ComboItem" value="" caption="" activ="true"/>
					<component cmptype="ComboItem" dataset="DS_HOMELESS_REASON" repeate="0" captionfield="DD_NAME" datafield="ID"/>
				</component>
			</td>
		</tr>

		<tr>
			<td style="padding-top:3pt;">
				<component cmptype="Label" caption="Диагноз уточненный:" style="line-height: 1.3"/>
			</td>
			<td style="padding-top:3pt;">
				<component cmptype="ButtonEdit" name="HOSP_MKB_EXACT" width="100%" multisel="true" buttononclick="base().selectMkbExact(this);">
					<component cmptype="Button" type="micro" background="Icons/btn_erase" onclick="setCaption('HOSP_MKB_EXACT', ''),setValue('HOSP_MKB_EXACT', null),setVar('HOSP_MKB_EXACT', null)"/>
				</component>
			</td>
		</tr>

		<tr>
			<td style="padding-top:3pt;vertical-align:top;">
			<component cmptype="label" caption="Обоснование направления:"/>
			</td>
			<td style="padding-top:3pt" colspan="3">
				<component cmptype="TextArea" name="DIR_COMMENT" style="width:100%;height:30px;" />
			</td>
		</tr>
		<tr>
			<td style="padding-top:3pt;vertical-align:top;">
			<component cmptype="label" caption="Плановая дата госпитализации:"/>
			</td>
			<td style="padding-top:3pt" colspan="3">
				<component cmptype="DateEdit" name="HOSP_PLAN_DATE" onchange="base().onChangeHospPlanDate();" emptyMask="true"/>
			</td>
		</tr>
		<tr>
			<td style="padding-top:3pt;vertical-align:top;">
				<component cmptype="label" caption="Врач,выписавший направление:"/>
			</td>
			<td style="padding-top:3pt;" colspan="3">
				<component cmptype="ButtonEdit" name="REG_EMPLOYER" unit="EMPLOYERS" buttononclick=" openWindow({name:'UniversalComposition/UniversalComposition', unit:'EMPLOYERS', composition:'EMP_MEDIC2'}, true)
						.addListener('onafterclose', function() {
							if(getVar('ModalResult') == 1) {
								setValue('REG_EMPLOYER', getVar('return_id'));
								setCaption('REG_EMPLOYER', getVar('return'));
							}
						}, null, false);" readonly="true" width="100%">
					<component cmptype="Button" type="micro" background="Icons/btn_erase" onclick="setValue('REG_EMPLOYER','');setCaption('REG_EMPLOYER','');" title="Очистить"/>
				</component>
			</td>
		</tr>
		<tr>
			<td colspan="4">
				<component cmptype="Label" caption="Госпитализирован после травмы "/>
				<component cmptype="HyperLink" name="INJShowHide" caption="Показать" onclick="base().showhideInjure();"/>
			</td>
		</tr>
	</table>
	<fieldset  cmptype="hz" name="INJURES" style="display:none">
		<legend>
			<i>
				<component cmptype="Label" caption="Травма"/>
			</i>
		</legend>
		<table width="100%" class="form-table">
			<colgroup>
				<col width="180px"/>
			</colgroup>
			<tr>
				<td>
					<b>
						<component cmptype="label" caption="Вид травмы:"/>
					</b>
				</td>
				<td>
					<component cmptype="UnitEdit" name="INJURE_KIND" unit="INJURE_KINDS" composition="DEFAULT" width="100%"/>
				</td>
			</tr>
			<tr>
				<td>
					<component cmptype="label" caption="Код внешней причины:"/>
				</td>
				<td>
					<component cmptype="UnitEdit" name="EX_CAUSE_MKB" unit="MKB10" composition="MKB10_INJURY" width="100%" oncreate="MKB10Input(this);"/>
				</td>
			</tr>
			<tr>
				<td>
					<component cmptype="label" caption="Время(часов) после травмы:"/>
				</td>
				<td>
					<component cmptype="Edit" name="INJURE_TIME" width="100%"  onblur="base().CountTrDate()" typeMask="float" emptyMask="false"/>
				</td>
			</tr>
			<tr name="TR_DATE_TR">
				<td>
					<component cmptype="label" caption="Дата травмы:"/>
				</td>
				<td>
					<component cmptype="DateEdit" name="DATE_TR_DATE" width="100%" emptyMask="true" onchange="base().CountHours()"/>
					<component cmptype="Edit" width="60" name="DATE_TR_TIME" typeMask="time" emptyMask="false" onblur="base().CountHours()"/>
					<component cmptype="MaskInspector" controls="DATE_TR_TIME;INJURE_TIME"/>
				</td>
			</tr>
		</table>
	</fieldset>
	<div style="text-align:right;text-align: -moz-right;">
		<table>
			<tr>
			  	<td style="text-align:right;">
					<component cmptype="Button" name="ButtonPrint"  onclick="base().PrintDirectionToHosp();" caption="Печать" style="width:89px;display:none;" />
				</td>
			  	<td style="text-align:right;">
					<component cmptype="Button" name="ButtonOk"     onclick="base().OnButtonOKClick(0);" caption="Применить" style="width:89px"/>
				</td>
			  	<td style="text-align:right;">
					<component cmptype="Button" name="ButtonOkSave" onclick="base().OnButtonOKClick(1);" caption="Сохранить" style="width:89px;"/>
				</td>
			  	<td style="text-align:right;">
					<component cmptype="Button" name="ButtonCancel" onclick="closeWindow(this);" caption="Закрыть" style="width:89px"/>
				</td>
			</tr>
			<tr>
			  	<td style="text-align:right;" colspan="2">
			   		<component cmptype="Button" name="ButtonNext" onclick="base().OnButtonNextClick();" enabled="false" caption="Выбор даты в журнале" style="width:180px"/>
				</td>
			  	<td style="text-align:right;" colspan="2">
					<component cmptype="Button" name="ButtonNextByDay" onclick="base().OnButtonNextByDayClick();" enabled="false" caption="Журнал госпитализации" style="width:180px"/>
			  	</td>
			</tr>
		</table>
	</div>
</div>
