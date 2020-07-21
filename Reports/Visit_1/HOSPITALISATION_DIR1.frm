<div cmptype="bogus" oncreate="base().OnCreate();" style="margin-left: 10px;font-family:Times New Roman;">
  <component cmptype="Script">
    <![CDATA[
    Form.OnCreate = function() {
      setVar('DIRECTION_ID', $_GET['DIRECTION_ID']);
    }
    ]]>
  </component>
  
  <component cmptype="SubForm" path="Reports/Visit_1/chunks/HeaderHosp"/>
  <component cmptype="SubForm" path="Reports/Visit_1/chunks/BODY_HOSPITALISATION_DIR"/>
  <component cmptype="SubForm" path="Reports/Visit_1/chunks/FooterHosp"/>
  
  


</div>
