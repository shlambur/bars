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
<component cmptype="DataSet" name="DS_STAC_JOURNAL_PATIENTS">
    <![CDATA[
            
            SELECT 
PJ.PAYMENT_KIND_NAME,
H.HOSPITAL_TYPE,
			PJ.HOSP_PLAN_KIND,
                   PJ.PLAN_DATE,
                   PJ.HOSP_PLAN_KIND_NAME,
                   P.BIRTHDATE,
                   PJ.PATIENT,
                     to_char(pj.REGISTER_DATE, D_PKG_STD.FRM_DT) REG_TIME,
      to_char(h.date_in, D_PKG_STD.FRM_DT) HOSP_TIME,

            case 
            when trunc(((86400*(h.date_in-PJ.REGISTER_DATE))/60)/60)-24*(trunc((((86400*(h.date_in - PJ.REGISTER_DATE))/60)/60)/24)) = 0 then ''
            else to_char( trunc(((86400*(h.date_in-PJ.REGISTER_DATE))/60)/60)-24*(trunc((((86400*(h.date_in - PJ.REGISTER_DATE))/60)/60)/24))|| ' ч ' )
                
         end
         
         ||
          to_char(trunc((86400*(h.date_in-PJ.REGISTER_DATE))/60)-60*(trunc(((86400*(h.date_in - PJ.REGISTER_DATE))/60)/60))) || ' мин' "WAITING_TIME" ,	  
                  
                  
                  
                  
                   (D_PKG_AGENT_POLIS.GET_ACTUAL_ON_DATE(PJ.PATIENT_AGENT,
                                             PJ.PLAN_DATE,
                                             0,
                                             'P_SER P_NUM')) POLIS
            FROM D_V_HPK_PLAN_JOURNALS PJ 
			join D_V_REP_HOSPHISTORY_HEAD h on h.hosp_history_id = pj.id,
                 D_V_PERSMEDCARD       P
            WHERE (PJ.PATIENT_ID = P.ID)
                AND PJ.PLAN_DATE IS NOT NULL
                AND (PJ.PLAN_DATE >= to_date(:PD_DATE||' 00:00:00', 'DD.MM.YYYY HH24:MI:SS') AND
                PJ.PLAN_DATE <
                to_date(:PD_DATE||' 00:00:00', 'DD.MM.YYYY HH24:MI:SS') + INTERVAL '1' DAY) 
                AND (PJ.HOSP_HISTORY_DS = 0)
          
            ORDER BY PJ.HOSP_PLAN_KIND_NAME
        ]]>
        <component cmptype="Variable" name="LPU" src="LPU" srctype="session" />
        <component cmptype="Variable" name="PD_DATE" src="PD_DATE" srctype="var" get="pd_date"/>
</component>


<div style="font-weight:bold; text-align: center; width:100%;"><component cmptype="Label" caption="СПИСОК ПОСТУПАЮЩИХ ПАЦИЕНТОВ" /> <br/>
<component cmptype="Label" caption="на " /><component cmptype="Label" name="PD_DATE"/></div>
<br/>
<br/>
<div dataset="DS_STAC_JOURNAL_PATIENTS" repeate="0" keyfield="HOSP_PLAN_KIND" distinct="HOSP_PLAN_KIND" onclone="base().setCountAll()">
     <div style="font-weight:normal; text-align:center;width:100%;">
                         <component cmptype="Label" caption="Наименование журнала: " /> <component cmptype="Label" style="font-weight:bold;font-size:9pt;" captionfield="HOSP_PLAN_KIND_NAME" />
                    </div>
    <br/>
    <table class="table1" style="width:100%;">
    
    <tr style="text-align:center;">
          <td style="width:5%;"> <component cmptype="Label" caption="№ п/п" />
          </td>
          
		  <td style="width:40%;"> <component cmptype="Label" caption="ФИО пациента" />
          </td>
		  <td style="width:10%;"> <component cmptype="Label" caption="Источник" />
          </td>
		  <td style="width:10%;"> <component cmptype="Label" caption="Тип" />
          </td>
          <td style="width:25%;"> <component cmptype="Label" caption="Серия и номер полиса" />
          </td>
          <td style="width:10%;"> <component cmptype="Label" caption="Дата рождения" />
          </td>
		   <td style="width:10%;"> <component cmptype="Label" caption="Время регистрации" />
          </td>
		   <td style="width:10%;"> <component cmptype="Label" caption="Время госпитализации" />
          </td>
		  <td style="width:10%;"> <component cmptype="Label" caption="Время ожидания" />
          </td>
    </tr>
    <tbody>
           <tr dataset="DS_STAC_JOURNAL_PATIENTS" repeate="0" keyfield="PATIENT" detail="true" parentfield="HOSP_PLAN_KIND" onclone="base().setCount()">
                  <td style="width:5%; text-align: right;font-size:9pt;"> 
                      <component cmptype="Label" name="COUNTi" captionfield="COUNTi"/>
                  </td>
			
				  
                  <td style="width:40%; text-align: left"> 
                      <component cmptype="Label"  captionfield="PATIENT" />
					  	  <td style="width:10%; text-align: left"> 
                      <component cmptype="Label"  captionfield="PAYMENT_KIND_NAME" />
                  </td>
					  
					  	  <td style="width:10%; text-align: left"> 
                      <component cmptype="Label"  captionfield="HOSPITAL_TYPE" />
                  </td>
                  </td>
                  <td sdnum="1049;0;@" style="width:25%; text-align: left;mso-number-format:'@'" >
                      <component cmptype="Label" captionfield="POLIS"/>
                  </td>
                  <td style="width:10%; text-align: right"> 
                      <component cmptype="Label" captionfield="BIRTHDATE" />
                  </td>
				    <td style="width:10%; text-align: right"> 
				     <component cmptype="Label"  captionfield="REG_TIME" />
                  </td>
				    <td style="width:10%; text-align: right"> 
				     <component cmptype="Label"  captionfield="HOSP_TIME" />
                  </td>
				   <td style="width:10%; text-align: right"> 
				     <component cmptype="Label"  captionfield="WAITING_TIME" />
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