<div cmptype="Form" class="d3form formBackground patient_wristband">
<span style="display: none;" cmptype="tmp" name="PRINT_SETUP" id="PrintSetup" ps_paperData="9" ps_marginTop="0" ps_marginBottom="0" ps_marginRight="0" ps_marginLeft="0"></span>
<component cmptype="SubForm" path="Reports/HospPlan/subforms/patient_talon_scripts"/>

<cmpDataSet name="DS_HOSPHISTORY_HEAD" activateoncreate="false">
        <![CDATA[
    select 	
			upper(ag.SURNAME) SURNAME,
			ag.FIRSTNAME,
			ag.LASTNAME,
			j.PATIENT_ID PATIENT_ID,
            ag.BIRTHDATE ||' ('||D_PKG_DAT_TOOLS.FULL_YEARS(sysdate,ag.BIRTHDATE)||')' BIRTHDATE,
			j.HP_NAME,
			j.PAYMENT_KIND PAYMENT_KIND_NAME,
			to_char(j.REGISTER_DATE, D_PKG_STD.FRM_DT) REGISTER_DATE --вывод даты и времени регистрации
            from D_V_HPK_PLAN_JOURNALS_ADD j join D_V_AGENTS ag on j.patient_agent = ag.ID
            where j.PATIENT_ID = :PATIENT_ID
            and j.REGISTER_DATE >= trunc(sysdate-1)
			
			
        ]]>

		<cmpDataSetVar  name="PATIENT_ID"  src="PATIENT_ID"         srctype="var"  get="v2"/>
		<cmpDataSetVar  name="HH_ID"  src="HH_ID"         srctype="var"  get="v3"/>
</cmpDataSet>
<component cmptype="SubForm" path="Reports/HospPlan/subforms/patient_talon_actions_p"/>	
<component cmptype="SubForm" path="Reports/HospPlan/subforms/patient_talon2_html_p"/>	

</div>