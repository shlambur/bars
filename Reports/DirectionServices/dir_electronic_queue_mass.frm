<div cmptype="Form" class="d3form formBackground dir_electronic_queue">
	<!--
		args
			 PATIENT_ID
			 THIS_SERV
			 NOT_DONE
			 DATE_BEGIN
			 DATE_END
			 TIME_BEGIN
			 TIME_END
			 IS_FROM_PRINT_TALON
	-->
<span style="display:none" id="PrintSetup" ps_paperData="9" ps_marginBottom="10" ps_marginRight="10" ps_marginTop="10" ps_marginLeft="10" ></span>
<component cmptype="SubForm" path="Reports/DirectionServices/subforms/dir_electronic_queue_scripts"/>
<cmpDataSet name="DsPatientInfo" compile="true" activateoncreate="false">
	<![CDATA[
		select
		    f.FULL_FIO PATIENT_FIO,
			D_PKG_STR_TOOLS.CONC_LIST_EX(
				fsDELIM => ', ',
				fsPREFDELIM => '',
				fsPREF1 => ', ',
				fsSTR1 => to_char(BIRTHDATE, 'dd.mm.yyyy'),
				fsSTR2 => D_PKG_AGENT_ADDRS.GET_ACTUAL_ON_DATE(AGENT, sysdate, 1, 'SHORT')
			 ) PATIENT_ADD_INFO
          from D_V_PERSMEDCARD_FIO f
         where f.ID = :PATIENT_ID
    ]]>
	<cmpDataSetVar  name="PATIENT_ID"   src="PATIENT_ID"          srctype="var"  get="vPAT"/>
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
             and ds.PATIENT = :PATIENT_ID
             and ds.SERV_STATUS <> 2
	        @ if (:DATE_BEGIN) {
             and ds.REC_DATE >= to_date(:DATE_BEGIN || ' ' || :TIME_BEGIN, 'dd.mm.yyyy hh24:mi')
            @ }
            @ if (:DATE_END) {
             and ds.REC_DATE <= to_date(:DATE_END || ' ' ||:TIME_END, 'dd.mm.yyyy hh24:mi')
            @ }
            @ if(:NOT_DONE == 1) {
             and ds.SERV_STATUS<>1
            @ }
            @ if(:THIS_SERV == 1) {
             and ds.ID = :DIR_SERV_ID
            @ }
            @ if(:IS_FROM_PRINT_TALON == 1) {
             and ds.SERVICE_TYPE <> 8
            @ }
			order by ds.REC_DATE asc
      ]]>
	<cmpDataSetVar name="LPU"    src="LPU" srctype="session"/>
	<cmpDataSetVar name="PATIENT_ID"   src="PATIENT_ID"      srctype="var" get="vPAT"/>
	<cmpDataSetVar name="THIS_SERV"    src="THIS_SERV"       srctype="var" get="vTS"/>
	<cmpDataSetVar name="NOT_DONE"     src="NOT_DONE"        srctype="var" get="vND"/>
	<cmpDataSetVar name="DATE_BEGIN"   src="DATE_BEGIN"      srctype="var" get="vDB"/>
	<cmpDataSetVar name="DATE_END"     src="DATE_END"        srctype="var" get="vDE"/>
	<cmpDataSetVar name="TIME_BEGIN"   src="TIME_BEGIN"      srctype="var" get="vTB"/>
	<cmpDataSetVar name="TIME_END"     src="TIME_END"        srctype="var" get="vTE"/>
	<cmpDataSetVar name="IS_FROM_PRINT_TALON"     src="IS_FROM_PRINT_TALON" srctype="var" get="vIS_FROM_PRINT_TALON"/>
</cmpDataSet>
<component cmptype="SubForm" path="Reports/DirectionServices/subforms/dir_electronic_queue_actions"/>
<component cmptype="SubForm" path="Reports/DirectionServices/subforms/dir_electronic_queue_html"/>
</div>