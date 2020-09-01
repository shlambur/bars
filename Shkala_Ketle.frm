<div cmptype="bogus" oncreate="base().OnMedUziCreate();" class="report_main_div">
<component cmptype="Script">
	Form.OnMedUziCreate = function() 
	{
	  setVar('VISIT', $_GET['REP_VISIT_ID']);
	}
</component>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Shkala_HeaderMED"/>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Shkala_PROTOCOL"/>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Shkala_ZAKL"/>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Shkala_VISIT_OFT_DIRS"/>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Shkala_FooterMED"/>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Shkala_CAMI"/>
</div>