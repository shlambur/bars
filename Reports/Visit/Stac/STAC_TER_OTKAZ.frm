<div cmptype="Form" class="report_main_div" oncreate="base().onCreate();" dataset="DS_TER_INSP">
    <style>
        div.report_main_div {
            margin: 10mm;
            margin-left: 10mm;
        }
    </style>
    <span style="display:none" id="PrintSetup" ps_paperData="9" ></span>
    <component cmptype="Script">
    <![CDATA[
        executeAction('SelectUser', function () {
					setCaption('EMPLOYER_FIO_SES', getVar('FIO_SES'));
                    setCaption('EMPLOYER_JOB_SES', getVar('JOB_SES'));
				});
       ]]>        
       
    </component>
    <component cmptype="Action" name="SelectUser">    --  достаем сесию пользователя 
			begin
				select D_PKG_STR_TOOLS.FIO(t.SURNAME,t.FIRSTNAME,t.LASTNAME),
                    t.jobtitle 
				  into  :FIO_SES,
                        :JOB_SES
				  from d_v_employers t
				 where t.ID = :EMPLOYER;
			end;
		<component cmptype="ActionVar" name="PNLPU"     src="LPU"           srctype="session"/>
		<component cmptype="ActionVar" name="EMPLOYER"  src="EMPLOYER"      srctype="session"/>
		<component cmptype="ActionVar" name="FIO_SES"   src="FIO_SES"       srctype="var"     put="var1" len="100"/>
        <component cmptype="ActionVar" name="JOB_SES"   src="JOB_SES"       srctype="var"     put="var2" len="101"/>
    </component>





    <component cmptype="Script">
         Form.onCreate = function(){
             setVar('VISIT', $_GET['REP_VISIT_ID']);
             setVar('PATIENT_ID', $_GET['PATIENT_ID']);
         }
     </component>
    <component cmptype="DataSet" name="DS_TER_INSP" >    
        <![CDATA[
            SELECT 
            t.lpu,
            t.PATIENT_SURNAME,
            t.PATIENT_LASTNAME,
            t.PD_SER,
            t.PD_NUMB,
            t.PD_WHO,
            t.DATE_IN,
            pj.PLAN_DATE

            
               
              FROM  D_V_REP_HOSPHISTORY_HEAD t
              Join D_V_HPK_PLAN_JOURNALS pj on pj.PATIENT_ID = t.PATIENT 
             WHERE t.PATIENT = :PATIENT_ID
             order by pj.PLAN_DATE  desc
        ]]>
        <component cmptype="Variable" name="VISIT_ID" src="VISIT" get="v0" srctype="var" />
        <component cmptype="Variable" name="PATIENT_ID" get="v1"  src="PATIENT_ID" srctype="var" />
    </component>
    

    




    
    <div style="font-weight: bold; text-align: center;">
        <component cmptype="Label" captionfield="FULLNAME"/> <br/>
        <component cmptype="Label" caption="Отказ от госпитализации" />
    </div> <br/>
    <table class="form-table" style="width: 100%;">
        <tr>
            <td style="width: 5%;">
                Я, 
            </td>
            <td style="border-bottom: 1px solid black; text-align: center; width: 95%">
               <b> 
                    <component cmptype="Label" captionfield="PATIENT_SURNAME"/>
                    <component cmptype="Label" captionfield="PATIENT_LASTNAME"/>
              </b>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="font-size: 7pt; text-align: center;">
                (фамилия, имя, отчество)
            </td>
        </tr>
        <tr>
            <td style="border-bottom: 1px solid black; text-align: center;" colspan="2">
               <b>  
                    <component cmptype="Label" captionfield="PD_SER"/>
                    <component cmptype="Label" captionfield="PD_NUMB"/>
                    <component cmptype="Label" captionfield="PD_WHO"/>
                </b>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="font-size: 7pt; text-align: center;">
                (паспортные данные, кем и когда выдан)
            </td>
        </tr>
    </table>
    <table class="form-table" style="width: 100%;">
        <tr>
            
            <td style="border-bottom: 1px solid black;text-align: center; width: 100%">
               <b> <component cmptype="Label" captionfield="LPU"/></b>
            </td>
        </tr>
        <tr>
            
            <td style="font-size: 7pt; text-align: center; width: 100%">
                (наименование ЛПУ)
            </td>
        </tr>
    </table>
    <table class="form-table" style="width: 100%;">
        <tr>
            <td style="width: 35%;">
                Или законный представитель пациента
            </td>
            <td style="border-bottom: 1px solid black; width: 65%">
            </td>
        </tr>
        <tr>
            <td style="width: 35%;">
            </td>
            <td style="font-size: 7pt; text-align: center; width: 65%">
                (фамилия, имя, отчество)
            </td>
        </tr>
        <tr>
            <td style="border-bottom: 1px solid black;" colspan="2"> <br/></td>
        </tr>
        <tr>
            <td colspan="2" style="font-size: 7pt; text-align: center;">
                (реквизиты документа, подтверждающего право представить интересы больного)
            </td>
        </tr>
    </table>
    <br/>
    <div style="text-align: justify;">
        Отказываюсь от предложенной мне (пациенту) госпитализации. <br/>
        О своём (пациента) заболевании и возможных осложнениях его течения информирован(а), рекомендации по лечению получил(а). <br/>
        Я (пациент или его законны представитель) не буду иметь каких-либо претензий к лечебно-профилактическому учреждению в случае развития негативных последствий вследствие моего решения.
    </div>
    <br/>
    <br/>
    
    <table class="form-table" style="width: 100%;">
        <tr>
            <td style="width: 35%;">Пациент (законный представитель)</td>
            <td style="width: 65%; border-bottom: 1px solid black; text-align: right;">
               <b> <component cmptype="Label" captionfield="PATIENT_SURNAME" /></b>\
                 <component cmptype="Label"  captionfield="PLAN_DATE"/>
            </td>
        </tr>
        <tr>
            <td style="width: 35%;"></td>
            <td style="width: 65%; font-size: 7pt; text-align: center;">
                (подпись, фамилия, дата)
            </td>
        </tr>
        <tr>
        <td  >  Оформил и распечатал откказ от госпитализации
        </td>


        <td>
        <component cmptype="Label" name="EMPLOYER_FIO_SES"/>
        <component cmptype="Label" name="EMPLOYER_JOB_SES"/> 
        </td>
        </tr>
    </table>
</div>