<div cmptype="bogus" name="Form_ZAKL" dataset="dsVisitZAKL" repeate="0" style="display:none;"
onshow="onShowBlockInVisit('Form_ZAKL','Label_ZAKL_SIGN')" onclone="base().onShowLabelZakl(this);">
   <component cmptype="Script">
		Form.onShowLabelZakl = function(_domObject){
			$$(_domObject);			
			if(getCaption('ZAKL')!=''){
				setCaption('Label_ZAKL','Заключение: ');
			}
			else
				setCaption('Label_ZAKL', '');
			_$$();
		}
   </component>  
   <component cmptype="DataSet" name="dsVisitZAKL">
    select max(case when f.TEMPLATE_FIELD = 'ZAKL' then f.STR_VALUE else null end) ZAKL,
    decode(max(case when f.TEMPLATE_FIELD in ('ZAKL') then trim(f.STR_VALUE) else null end), null, 0, 1) SIGN
      from d_v_visit_fields f
     where f.PID = :VISIT
    <component cmptype="Variable" name="VISIT" src="VISIT" srctype="var" get="v0"/>
  </component>

  <div style="display:none;">
    <component cmptype="Label" name="Label_ZAKL_SIGN" captionfield="SIGN"/>
  </div >
  <div class="Z1"><b><component cmptype="Label" name="Label_ZAKL" before_caption="&lt;br/&gt;"/></b><br/></div>
  <div class="Z"><component cmptype="Label" name="ZAKL" formated="true" captionfield="ZAKL"/></div><br/><br/>
  <style>
   .Z
    {
    width:600px;
    margin-left:80px;
    margin-top:0px;
    border: 0px double black; /* Параметры границы */
    --background: #fc3; /* Цвет фона */
    padding: 0px; /* Поля вокруг текста */
   }
   .Z1
    {
    width:100px;
    margin-left:80px;
    margin-top:0px;
    border: 0px double black; /* Параметры границы */
    --background: #fc3; /* Цвет фона */
    padding: 0px; /* Поля вокруг текста */
   }
  </style>
</div>
