<div cmptype="Form" class="d3form formBackground dir_electronic_queue">
<span style="display:none" id="PrintSetup" ps_paperData="9" ps_marginBottom="10" ps_marginRight="10" ps_marginTop="10" ps_marginLeft="10" ></span>
	<!--
		args
			DIR_SERV_ID
			REP_ID
			DIR_SERV_ID
			THIS_SERV
			NOT_DONE
			IS_FROM_PRINT_TALON
	-->
<component cmptype="SubForm" path="Reports/DirectionServices/subforms/dir_electronic_queue_scripts"/>
<cmpDataSet name="DsPatientInfo" activateoncreate="false">
	<![CDATA[
			select
				f.FULL_FIO PATIENT_FIO,
					D_PKG_STR_TOOLS.CONC_LIST_EX(
						fsDELIM => ', ',
						fsPREFDELIM => '',
						fsSTR1 => to_char(BIRTHDATE, 'dd.mm.yyyy'),
						fsSTR2 => D_PKG_AGENT_ADDRS.GET_ACTUAL_ON_DATE(AGENT, sysdate, 1, 'SHORT')
					 ) PATIENT_ADD_INFO
              from D_V_DIRECTION_SERVICES ds
                   join D_V_PERSMEDCARD_FIO f on f.ID = ds.PATIENT
             where ds.ID = :DIR_SERV_ID
        ]]>
	<cmpDataSetVar  name="DIR_SERV_ID"  src="DIR_SERV_ID"         srctype="var"  get="vDS"/>
</cmpDataSet>
<cmpDataSet name="DsReport" compile="true" activateoncreate="false">
	<![CDATA[
          select case when ds.TICKET_S is not null or ds.TICKET_N is not null
                      then '№' || ds.TICKET_S || lpad(ds.TICKET_N, 4, '0')
                 end TALON_NUM,
                 ds.SERVICE_NAME,
                 to_char(ds.REC_DATE, 'dd.mm.yyyy')||' '||case when to_char(ds.REC_DATE, 'HH24:MI') = '00:00' then null else to_char(ds.REC_DATE, 'HH24:MI') end  REC_DATE,
                 ds.CABLAB_TO_NAME,
                 ds.EMPLOYER_FIO_TO,
                 ds.ID DIR_SERV_ID
            from D_V_DIRECTION_SERVICES ds
           where ds.LPU = :LPU
             and ds.ID = :DIR_SERV_ID
            @ if(:NOT_DONE == 1) {
              and ds.SERV_STATUS<>1
            @ }
            @ if(:THIS_SERV == 1) {
              and ds.ID = :DIR_SERV_ID
            @ }
            @ if(:IS_FROM_PRINT_TALON == 1) {
              and ds.SERVICE_TYPE <> 8
            @ }
      ]]>
	<cmpDataSetVar name="LPU"    src="LPU" srctype="session"/>
	<cmpDataSetVar name="DIR_SERV_ID"  src="DIR_SERV_ID"     srctype="var" get="vDS"/>
	<cmpDataSetVar name="THIS_SERV"    src="THIS_SERV"       srctype="var" get="vTS"/>
	<cmpDataSetVar name="NOT_DONE"     src="NOT_DONE"        srctype="var" get="vND"/>
	<cmpDataSetVar name="IS_FROM_PRINT_TALON"     src="IS_FROM_PRINT_TALON" srctype="var" get="vIS_FROM_PRINT_TALON"/>
</cmpDataSet>

<component cmptype="SubForm" path="Reports/DirectionServices/subforms/dir_electronic_queue_actions"/>
<component cmptype="SubForm" path="Reports/DirectionServices/subforms/dir_electronic_queue_html"/>
</div>