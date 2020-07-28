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
                    t.PATIENT PATIENT_ID,
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
       
        <component cmptype="Label" caption=" Электронный талон на лечебную (диагностическую) манипуляцию (процедуру) "/>
        <br/>
        <br/>
    </div>
    <table style="width: 100%;" class="form-table">
        <tr style="height: 8mm;">
            <td>
                я
            </td>
            <td style="border-bottom: 1px solid black; font-weight: bold; width:95%; text-align: center;">
                <component cmptype="Label" name="PATIENT"  captionfield="PATIENT"/>
                <component cmptype="Label" name="PATIENT"  captionfield="PATIENT_ID"/>
            </td>
            
        </tr>
    </table>
</div>