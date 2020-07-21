<div class="report_main_div" cmptype="from" name="form1" oncreate="base().onCreateCAMI();">
<component cmptype="Script">
    Form.onCreateCAMI = function () {
        getControlByName('CAMI_LINK').style.display = "none";
        if (!empty(getVar('VISIT'))) {
            executeAction('GET_CAMI_PARAMS', function () {
                if (!empty(getVar('CAMI_URL'))) {
                    if (!empty(getVar('UID_CAMI'))) {
                        getControlByName('CAMI_LINK').style.display = "";
                    }
                    else {
                        if (!empty(getVar('UID_APP'))) {
                            executeModule('GET_STUDY_UID', function () {
                                if (!empty(getVar('UID_CAMI'))) {
                                    getControlByName('CAMI_LINK').style.display = "";
                                }
                            });
                        }
                    }
                }
            });
        }
    }
    <![CDATA[
    Form.openCAMI = function(){
        var url = getVar('CAMI_URL');
        if (getVar('CAMI_VER') == 1) {
            url += '?studyInstanceUid=';
            url += getVar('UID_CAMI');
            executeModule('GET_AUTH_TICKET', null,null,null,false);
            if(!empty(getVar('AUTH_TICKET')))
            {
                url += '&ticket='+getVar('AUTH_TICKET');
            }
        }
        else {
            url += '?accessionNumber=';
            url += getVar('UID_CAMI');
            url += '&patient_uid=';
            url += getVar('UID_PAT');
        }
        var window_wdsl = window.open(url, 'wdsl', 'width=600,height=600,toolbar=no,status=no,scrollbars=no,menubar=no,resizable=yes');
        window_wdsl.resizeTo(600, 600);
        window_wdsl.focus();
    }
    ]]>
</component>
    <component name="GET_STUDY_UID" cmptype="Module" module="Int/IEMK/getStudyUid">
        <component cmptype="ModuleVar" name="UNIT_ID" get="unit_id" src="DIRECTION_SERVICES_ID" srctype="var"/>
        <component cmptype="ModuleVar" name="LPU" get="LPU" src="LPU" srctype="session"/>
        <component cmptype="ModuleVar" name="UNIT" get="unit" src="DIRECTION_SERVICES" srctype="const"/>
        <component cmptype="ModuleVar" name="STUDY_ID" put="STUDY_ID" src="UID_CAMI" srctype="var" len="40"/>
    </component>
    <component name="GET_AUTH_TICKET" cmptype="Module" module="Int/IEMK/getAuthTicket">
        <component cmptype="ModuleVar" name="url" get="url" src="CAMI_URL" srctype="var"/>
        <component cmptype="ModuleVar" name="ticket" put="ticket" src="AUTH_TICKET" srctype="var" len="4000"/>
    </component>
<component cmptype="Action" name="GET_CAMI_PARAMS">
    declare
      nPAT D_PKG_STD.tREF;
      nEX_SYSTEM D_PKG_STD.tREF;
    begin
      nPAT := nvl(:PATIENT_ID,:PAT_ID);
      select t.PID into :DIR_ID from d_v_visits t where t.ID = :VISIT;
      begin
        :CAMI_VER := D_PKG_OPTIONS.GET('CAMI_version', :LPU);
      exception when others then :CAMI_VER := null;
      end;
      if :CAMI_VER = 1 then
        begin
          select t1.URL_SERVICE, t.ID
            into :CAMI_URL, nEX_SYSTEM
            from D_V_EX_SYSTEMS t,
                 D_V_EX_SYSTEM_SERVICES t1
           where t.S_CODE = 'iemk/patient'
             and t.ID = t1.PID
             and t1.SS_CODE = 'URL_STUDY_ID';
          :UID_APP := D_PKG_EX_SYSTEM_VALUES.GET_VAL(nEX_SYSTEM,'iemk/patient','IEMK_ID','DIRECTION_SERVICES',:DIR_ID);
          :UID_CAMI := D_PKG_EX_SYSTEM_VALUES.GET_VAL(nEX_SYSTEM,'iemk/patient','IEMK_ID_STUDY','DIRECTION_SERVICES',:DIR_ID);
        exception when NO_DATA_FOUND then :CAMI_URL := null; :UID_CAMI := null;
        end;
        :UID_PAT := null;
      else
        :CAMI_URL := 'https://cdma.tatar.ru/pacs/viewStudy.xhtml';
        :UID_CAMI := d_pkg_unitprops.GET_SVAL('DIRECTION_SERVICES', :DIR_ID , 'UID_KIR');
        :UID_PAT := d_pkg_unitprops.GET_SVAL('PERSMEDCARD', nPAT, 'UID_KIR');
        :UID_APP := null;
      end if;
    end;
	<component cmptype="ActionVar" name="VISIT" src="VISIT" srctype="var" get="v0"/>
	<component cmptype="ActionVar" name="DIR_ID" src="DIRECTION_SERVICES_ID" srctype="var" put="v1" len="17"/>
	<component cmptype="ActionVar" name="PAT_ID" src="PatientID" srctype="var" get="v2"/>
    <component cmptype="ActionVar" name="LPU" src="LPU" srctype="session" get="LPU"/>
	<component cmptype="ActionVar" name="PATIENT_ID" src="PATIENT_ID" srctype="var" get="v3"/>
	<component cmptype="ActionVar" name="UID_CAMI" src="UID_CAMI" srctype="var" put="v4" len="40"/>
	<component cmptype="ActionVar" name="UID_PAT" src="UID_PAT" srctype="var" put="v5" len="40"/>
    <component cmptype="ActionVar" name="UID_APP" src="UID_APP" srctype="var" put="UID_APP" len="40"/>
    <component cmptype="ActionVar" name="CAMI_VER" src="CAMI_VER" srctype="var" put="CAMI_VER" len="1"/>
    <component cmptype="ActionVar" name="CAMI_URL" src="CAMI_URL" srctype="var" put="CAMI_URL" len="250"/>
</component>

<component cmptype="HyperLink" name="CAMI_LINK" onclick="base().openCAMI();" caption="Ссылка на изображение в ЦАМИ "/>

</div>