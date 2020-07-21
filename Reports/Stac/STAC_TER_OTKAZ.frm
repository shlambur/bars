<div cmptype="Form" class="report_main_div" oncreate="base().onCreate();" dataset="DS_TER_INSP">
    <style>
        div.report_main_div {
            margin: 10mm;
            margin-left: 10mm;
        }
    </style>
    <span style="display:none" id="PrintSetup" ps_paperData="9" ></span>
    <component cmptype="Script">
         Form.onCreate = function(){
             setVar('VISIT', $_GET['REP_VISIT_ID']);
         }
     </component>
    <component cmptype="DataSet" name="DS_TER_INSP" >
        <![CDATA[
            SELECT rd.VISIT_DATE,
                   rd.PMC_SURNAME,
                   rd.PMC_FIRSTNAME,
                   rd.PMC_LASTNAME,
                   D_PKG_STR_TOOLS.FIO(rd.PMC_SURNAME,rd.PMC_FIRSTNAME,rd.PMC_LASTNAME) FIO,
                   D_PKG_AGENT_PERSDOCS.GET_ACTUAL_ON_DATE(rd.PMC_AGENT,
                                                           rd.VISIT_DATE,
                                                           'PD_SER PD_NUMB') ||
                   ' выдан ' ||
                   D_PKG_AGENT_PERSDOCS.GET_ACTUAL_ON_DATE(rd.PMC_AGENT,
                                                           rd.VISIT_DATE,
                                                           'PD_WHO PD_WHEN') PASSPORT,
                   rd.FULLNAME
              FROM D_V_REP_DIAGNOSTIC_NEW rd
             WHERE rd.VISIT_ID = :VISIT_ID
        ]]>
        <component cmptype="Variable" name="VISIT_ID" src="VISIT" get="v0" srctype="var" />
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
            <td style="border-bottom: 1px solid black; width: 95%">
                <component cmptype="Label" captionfield="PMC_SURNAME"/> <component cmptype="Label" captionfield="PMC_FIRSTNAME"/><component cmptype="Label" captionfield="PMC_LASTNAME"/>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="font-size: 7pt; text-align: center;">
                (фамилия, имя, отчество)
            </td>
        </tr>
        <tr>
            <td style="border-bottom: 1px solid black; text-align: center;" colspan="2">
                <component cmptype="Label" captionfield="PASSPORT"/>
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
            <td style="width: 10%;">
                Пациент
            </td>
            <td style="border-bottom: 1px solid black; width: 90%">
                <component cmptype="Label" captionfield="FULLNAME"/>
            </td>
        </tr>
        <tr>
            <td style="width: 10%;">

            </td>
            <td style="font-size: 7pt; text-align: center; width: 90%">
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
                <component cmptype="Label" captionfield="FIO" /> <component cmptype="Label" captionfield="VISIT_DATE"/>
            </td>
        </tr>
        <tr>
            <td style="width: 35%;"></td>
            <td style="width: 65%; font-size: 7pt; text-align: center;">
                (подпись, фамилия, дата)
            </td>
        </tr>
    </table>
</div>