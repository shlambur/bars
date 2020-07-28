<div cmptype="bogus" oncreate="base().OnCreate();" dataset="DS" repeate="1">
    <span style="display:none" id="PrintSetup" ps_marginLeft="15"></span>
    <component cmptype="Script">
        <![CDATA[
        Form.OnCreate = function() {
          setVar('ID', function(){
              if(!empty(getVar('ID')) && getVar('ID') != '0'){
                  return getVar('ID');
              }
              if(!empty(getVar('DIR_SERVICE')) && getVar('DIR_SERVICE') != '0'){
                  return getVar('DIR_SERVICE');
              }
          }());
            refreshDataSet('DS');
        }
        ]]>
    </component>
    
    
    <component cmptype="DataSet" name="DS" activateoncreate="false">
        <![CDATA[
            select  
                    
                     d.REG_EMP_DEPARTMENT,
                     d.TO_LPU_FULLNAME as TO_LPU_FULLNAME,
                     d.PATIENT as PATIENT,
                    a.BIRTHDATE as BIRTHDATE,
                   D_PKG_AGENT_PERSDOCS.GET_ACTUAL_ON_DATE(p.AGENT, sysdate, 'PD_TYPE_NAME') as DOC_TYPE,
                   D_PKG_AGENT_PERSDOCS.GET_ACTUAL_ON_DATE(p.AGENT, sysdate, 'PD_SER') as DOC_SER,
                   D_PKG_AGENT_PERSDOCS.GET_ACTUAL_ON_DATE(p.AGENT, sysdate, 'PD_NUMB') as DOC_NUMB,
                   D_PKG_AGENT_PERSDOCS.GET_ACTUAL_ON_DATE(p.AGENT, sysdate, 'PD_WHO PD_WHEN') as DOC_WHO,
                   t.SERVICE_NAME as SERVICE,
                   D_PKG_DAT_TOOLS.DATE_TO_CHAR(sysdate, 'DD MONTH YYYY') DDATE,
                   t.EMPLOYER_FIO_TO as DOCTOR
              from d_v_direction_services t
                   join d_v_directions d on d.ID = t.PID
                   join d_v_persmedcard p on p.ID = d.PATIENT_ID
                   join d_v_agents a on a.ID = p.AGENT
             where t.ID = :ID
        ]]>
        <component cmptype="Variable" name="ID" get="v0" src="ID" srctype="var"/>
    </component>

    
    
    <div style="text-align: center; ">
        <u>
            <component cmptype="Label" name="TO_LPU_FULLNAME " captionfield="TO_LPU_FULLNAME"/>
        </u>
        <br/>
        <br/>
        <component cmptype="Label" caption="Информационное согласие пациента"/>
        <br/>
        <component cmptype="Label" caption="на лечебную (диагностическую) манипуляцию (процедуру) "/>
        <br/>
        <br/>
    </div>
    <table style="width: 100%;" class="form-table">
        <tr style="height: 8mm;">
            <td>
                <component cmptype="Label" caption="Я, "/>
            </td>
            <td style="border-bottom: 1px solid black; font-weight: bold; width:78%; text-align: center;">
                <component cmptype="Label" name="PATIENT"  captionfield="PATIENT"/>
            </td>
            <td>
                <component cmptype="Label" caption="находясь на лечении"/>
            </td>
        </tr>
    </table>
    <table style="width: 100%;" class="form-table">
        <tr style="height: 8mm;">
            <td>
                <component cmptype="Label" caption="в"/>
            </td>
            <td style="border-bottom: 1px solid black; text-align: center; width:73%; font-weight:bold;">
                <component cmptype="Label" name="TO_LPU_FULLNAME" captionfield="TO_LPU_FULLNAME"/>\
                <component cmptype="Label" name="REG_EMP_DEPARTMENT" captionfield="REG_EMP_DEPARTMENT"/>
            </td>
            <td >
                <component cmptype="Label" caption="отделении, уполномочиваю"/>
            </td>
        </tr>
        <tr>
            <td>
            </td>
            <td style="text-align: center;">
                <component style="font-size: 7pt;" cmptype="Label" caption="(наименование лечебно-профилактического учреждения)"/>
            </td>
            <td>
            </td>
        </tr>
    </table>
    <table style="width: 100%;" class="form-table">
        <tr style="height: 8mm;">
            <td>
                <component cmptype="Label" caption="врачей"/>
            </td>
            <td style="border-bottom: 1px solid black; text-align: center; width: 90%; font-weight:bold;">
            <component cmptype="Label" name="DOCTOR" captionfield="DOCTOR"/>

            </td>
        </tr>
        <tr>
            <td>
            </td>
            <td style="text-align: center;">
                <component style="font-size: 7pt;"  cmptype="Label" caption="(фамилия, имя, отчество) "/>
            </td>
        </tr>
        <tr style="height: 8mm;">
            <td style="border-bottom: 1px solid black;" colspan="2">
                <br/>
            </td>
        </tr>
    </table>
    <table style="width: 100%;" class="form-table">
        <tr style="height: 8mm;">
            <td>
                <component cmptype="Label" caption="выполнить мне манипуляцию (процедуру)"/>
            </td>
            <td style="border-bottom: 1px solid black; width: 60%; text-align: center; font-weight:bold;">
            <component cmptype="Label" name="SERVICE" captionfield="SERVICE"/>

            </td>
        </tr>
        <tr>
            <td>
            </td>
            <td style="text-align: center;">
                <component style="font-size: 7pt;"  cmptype="Label" caption="(указать наименование манипуляции (процедуры)"/>
            </td>
        </tr>
    </table>
    <br/>
    
    <div style="text-align: justify;">
        <component cmptype="Label" caption="Мне разъяснены и понятны суть моего заболевания и опасности, связанные с дальнейшим развитием этого заболевания. Я понимаю необходимость проведения указанной манипуляции (процедуры). "/>
        <br/>
        <component cmptype="Label" caption="Мне полностью ясно, что во время указанной манипуляции (процедуры) или после нее могут развиться осложнения, что может потребовать дополнительных вмешательств. "/>
        <br/>
        <component cmptype="Label" caption="Я уполномочиваю врачей выполнить любую процедуру или дополнительное вмешательство, которое может потребоваться в целях лечения, а также в связи с возникновением непредвиденных ситуаций. "/>
        <br/>
        <component cmptype="Label" caption="Я удостоверяю, что текст моего информированного согласия на операцию мною прочитан, мне понятно назначение данного документа, полученные разъяснения понятны и меня удовлетворяют.  "/>
        <br/>
    </div>
    <br/>
    <table style="width: 100%;" class="form-table">
        <tr style="height: 8mm;">
            <td>
                <component cmptype="Label" caption="Пациент"/>
            </td>
            <td  style="border-bottom: 1px solid black; width: 92%; font-weight:bold;">
             <component cmptype="Label" name="PATIENT"  captionfield="PATIENT"/>
            </td>
        </tr>
        <tr>
            <td>

            </td>
            <td style="text-align: center;">
                <component style="font-size: 7pt;" cmptype="Label" caption="(подпись пациента либо его доверенного лица, фамилия, имя, отчество)"/>
            </td>
        </tr>
        <tr style="height: 8mm;">
            <td style="border-bottom: 1px solid black;" colspan="2">
                <br/>
            </td>
        </tr>
        <tr>
            <td style="text-align: center;" colspan="2">
                <component style="font-size: 7pt;" cmptype="Label" caption="(реквизиты документа, подтверждающего право представлять интересы пациента)"/>
            </td>
        </tr>
        <tr style="height: 8mm;">
            <td style="border-bottom: 1px solid black; font-weight:bold;" colspan="2">
             <component cmptype="Label" name="DOCTOR"  captionfield="DOCTOR"/>
                <br/>
            </td>
        </tr>
        <tr>
            <td style="text-align: center;" colspan="2">
                <component style="font-size: 7pt;" cmptype="Label" caption="(подписи лечащего врача, оперирующего врача, анестезиолога, фамилия, имя, отчество, дата)"/>
            </td>
        </tr>
    </table>
</div>