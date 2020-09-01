<div cmptype="bogus" oncreate="base().OnMedUziCreate();" class="report_main_div">
<component cmptype="Script">
	Form.OnMedUziCreate = function() 
	{
	  setVar('VISIT', $_GET['REP_VISIT_ID']);
	}
</component>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Semestr_HeaderMED"/>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Semestr_PROTOCOL"/>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Semestr_ZAKL"/>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Semestr_VISIT_OFT_DIRS"/>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Semestr_FooterMED"/>
<component cmptype="SubForm" path="Reports/Visit_1/chunks/Semestr_CAMI"/>
</div>