<div cmptype="Form" oncreate="base().onCreate();" class="report_main_div"  window_size="210mmx297mm" >
<style>
        div.report_main_div {
            margin: 5mm;
        }
        table.table1 {
		width:100%;
	}
	table.table1 td{
		border: 1px solid black;
                padding: 3px;
	}
</style>
<component cmptype="Script">
<![CDATA[
	Form.onCreate = function()
	{
		setCaption('PD_DATE', $_GET['DATE']);
                setVar('PD_DATE', $_GET['DATE']);
   	};
        Form.COUNT=0;
        Form.COUNTall=0;
        Form.setCount = function()
        {
                  Form.COUNT++; 
                  setCaption('COUNTi', Form.COUNT);
        };
        Form.setCountAll = function()
        {
                setCaption('COUNT', Form.COUNT);
                Form.COUNTall+=Form.COUNT;
                Form.COUNT=0;         
                setCaption('COUNTall', Form.COUNTall);
        };
        ]]>
</component>
<component cmptype="DataSet" name="DS_STAC_ANALIZ">
    <![CDATA[
            
            SELECT 
            to_char(t.REG_TIME,'DD.MM.YYYY hh24:mi')REG_TIME,
            SUBSTR(t.crockery,10,11) ZABOR,  
            to_char(t.analyse_date,'DD.MM.YYYY hh24:mi') VALID,
            to_char(t.PICK_DATE,'DD.MM.YYYY hh24:mi') SEND_LIS,
                    t.direction_service,
                    t. pick_employer_fio,
                    t.PATIENT,
                    t.ANALYSE,
                    trunc(((86400*(t.PICK_DATE - t.REG_TIME))/60)/60)-24*(trunc((((86400*(t.PICK_DATE - t.REG_TIME))/60)/60)/24)) hours,
                    trunc((86400*(t.PICK_DATE - t.REG_TIME))/60)-60*(trunc(((86400*(t.PICK_DATE - t.REG_TIME))/60)/60)) min
                     FROM D_V_HPK_PLAN_JOURNALS PJ 
                     left join d_v_labmed_patjour t on t.unit_id = pj.diseasecase
                        where PJ.PLAN_DATE =:PD_DATE
                        and t.reg_time is not null
                        order by t.crockery DESC
            
        ]]>
        <component cmptype="Variable" name="LPU" src="LPU" srctype="session" />
        <component cmptype="Variable" name="PD_DATE" src="PD_DATE" srctype="var" get="pd_date"/>
</component>


<div style="font-weight:bold; text-align: center; width:100%;"><component cmptype="Label" caption="  СПИСОК АНАЛИЗОВ" /> <br/>
<component cmptype="Label" caption="на " /><component cmptype="Label" name="PD_DATE"/></div>
<br/>
<br/>
<div dataset="DS_STAC_ANALIZ" repeate="0" keyfield="HOSP_PLAN_KIND" distinct="HOSP_PLAN_KIND" onclone="base().setCountAll()">
     <div style="font-weight:normal; text-align:center;width:100%;">
                         
                    </div>
    <br/>
    <table class="table1" style="width:100%;">
    
    <tr style="text-align:center;">
          <td style="width:3%;"> <component cmptype="Label" caption="№ п/п" />
          </td>
		  <td style="width:10%;"> <component cmptype="Label" caption="ФИО пациента" />
          </td>
		  <td style="width:27%;"> <component cmptype="Label" caption="АНАЛИЗ" />
          </td>
		  <td style="width:10%;"> <component cmptype="Label" caption="Направление" />
          </td>
          <td style="width:10%;"> <component cmptype="Label" caption="Время регистрации" />
          </td>
          <td style="width:10%;"> <component cmptype="Label" caption="Дата забора" />
          </td>
		   <td style="width:10%;"> <component cmptype="Label" caption=" Результат с анализатора" />
          </td>
		   <td style="width:10%;"> <component cmptype="Label" caption="Отправлено из лис" />
          </td>
		  <td style="width:5%;"> <component cmptype="Label" caption="Часы" />
          </td>
          <td style="width:5%;"> <component cmptype="Label" caption="Минуты" />
          </td>
    </tr>
    <tbody>
           <tr dataset="DS_STAC_ANALIZ" repeate="0" keyfield="PATIENT" detail="true" parentfield="HOSP_PLAN_KIND" onclone="base().setCount()">
                  <td style="width:3%; text-align: right;font-size:9pt;"> 
                      <component cmptype="Label" name="COUNTi" captionfield="COUNTi"/>
                  </td>
			
				  
                  <td style="width:10%; text-align: left"> 
                      <component cmptype="Label"  captionfield="PATIENT" />
					  	  <td style="width:27%; text-align: left"> 
                      <component cmptype="Label"  captionfield="ANALYSE" />
                  </td>
					  
					  	  <td style="width:10%; text-align: left"> 
                      <component cmptype="Label"  captionfield="DIRECTION_SERVICE" />
                  </td>
                  </td>
                  <td sdnum="1049;0;@" style="width:10%; text-align: left;mso-number-format:'@'" >
                      <component cmptype="Label" captionfield="REG_TIME"/>
                  </td>
                  <td style="width:10%; text-align: right"> 
                      <component cmptype="Label" captionfield="ZABOR" />
                  </td>
				    <td style="width:10%; text-align: right"> 
				     <component cmptype="Label"  captionfield="VALID" />
                  </td>
				    <td style="width:10%; text-align: right"> 
				     <component cmptype="Label"  captionfield="SEND_LIS" />
                  </td>
				   <td style="width:5%; text-align: right"> 
				     <component cmptype="Label"  captionfield="HOURS" />
                  </td>
                  <td style="width:5%; text-align: right"> 
				     <component cmptype="Label"  captionfield="MIN" />
                  </td>
				  
				  
				  
				  
				  
           </tr>
    </tbody>

</table>
    <component cmptype="Label" caption="Итого по журналу: " style="font-size:8pt;font-weight:normal;" /> <component style="text-align:left;font-weight:bold;" cmptype="Label" name="COUNT" captionfield="COUNT"/>
    <br/><br/>
</div>
<div style="text-align:left;font-weight:bold;">
<component cmptype="Label" caption="ВСЕГО: " /> <component  cmptype="Label" name="COUNTall" captionfield="COUNTall"/>
</div>
</div>