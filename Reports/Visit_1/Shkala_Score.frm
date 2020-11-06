<div cmptype="bogus" oncreate="base().OnMedUziCreate();" class="report_main_div">
<component cmptype="Script">
	Form.OnMedUziCreate = function() 
	{
	  setVar('VISIT', $_GET['REP_VISIT_ID']);
	}
</component>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Shkala_SCORE_HeaderMED"/>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Shkala_SCORE_PROTOCOL"/>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Shkala_SCORE_ZAKL"/>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Shkala_SCORE_FooterMED"/>

</div>