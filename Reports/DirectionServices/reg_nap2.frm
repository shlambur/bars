<div cmptype="Form" class="report_main_div" oncreate="base().onCreate();" style="width:400mm"> 
<span style="display:none" id="PrintSetup" ps_paperData="9" ps_orientation="landscape"></span>
<component cmptype="Script">
	<![CDATA[
	Form.onCreate = function(){
                setVar('DEPS', $_GET['DEPS']);
		setVar('DATE_BEGIN', $_GET['DATE_BEGIN']);
                setVar('DATE_END', $_GET['DATE_END']);
                setCaption('DATE_BEGIN', getVar('DATE_BEGIN'));
		setCaption('DATE_END', getVar('DATE_END'));
	}
	]]>
</component>
<style>
	table.data tr td {
		padding: 2mm;
		border: 1pt solid black;
		text-align: center;
	}
</style>
<component cmptype="DataSet" name="DS_DATA" compile="true">
	<![CDATA[
           select 
    t.LPU LPU,
    t.REG_DATE,
    t.REG_TIME,
    t.REC_DATE,
    t.SE_NAME,
    t.PATIENT_FIO,
    t.PAYMENT_KIND,
    t2.FIO,
    t2.SPECIALITY,
    t2.DEPARTMENT ,
    t2.DP_KIND_NAME
        from   d_v_dir_serv_prescriptions t   
        left join D_V_EMPLOYERS t2 on t2.ID = t.REG_EMPLOYER
    where t.reg_type ='2'
    and t.se_type= '0'
    and t.REG_DATE   >= to_date(:DATE_BEGIN,'dd.mm.yyyy')
    and t.REG_DATE   <= to_date(:DATE_END,'dd.mm.yyyy')
    order by t2.DEPARTMENT
    
 
               
	]]>
        <component cmptype="Variable" name="LPU"        src="LPU"        srctype="session"/>
        <component cmptype="Variable" name="DEPS"       src="DEPS"       srctype="var" get="v2"/>
	<component cmptype="Variable" name="DATE_BEGIN" src="DATE_BEGIN" srctype="var" get="date_begin"/>
        <component cmptype="Variable" name="DATE_END"   src="DATE_END"   srctype="var" get="date_end"/>
</component>
<component cmptype="DataSet" name="DS_DEPS">
        <![CDATA[
            select DP_NAME
              from D_V_DEPS
             where  ID= :DEPS
        ]]>
        <component cmptype="Variable" name="DEPS" src="DEPS" srctype="var" get="deps"/>
</component>
<div style="width:100%;text-align:left;">
    Название отделения: <component cmptype="Label" dataset="DS_DEPS" repeate="0" captionfield="DP_NAME" />
    <br/>
    Отчетный период  с <component cmptype="Label" name="DATE_BEGIN"/> по <component cmptype="Label" name="DATE_END"/>
</div>
<br/>
<table class="data" style="page-break-after:always;width:100%;table-layout:fixed;">
	<tbody>
		<colgroup>
			<col style="width:20mm;"/>
                        <col style="width:25mm;"/>
                        <col style="width:25mm;"/>
                        <col style="width:30mm;"/>
                        <col style="width:25mm;"/>
                        <col style="width:30mm;"/>
                        <col style="width:20mm;"/>
                        <col style="width:30mm;"/>
                        <col style="width:50mm;"/>
                        <col style="width:30mm;"/>
                        <col style="width:25mm;"/>
                        
		</colgroup>
                <tr>
                    <td colspan="10">
                        <i>Назначения на услуги</i>
                    </td>
                   
                </tr>
		<tr>
			<td>Дата и назначения</td>
			<td>Время</td>
			<td>ФИО</td>
			<td>Направивший врач</td>
                        <td>Должность</td>
			<td>Подразделение</td>
                        <td>Вид оплаты</td>
			<td>Дта презаписи</td>
                        <td>Услуга</td>
                        <td> Направившее  из отделения</td>
                        
		</tr>
		<tr cmptype="tmp" repeate="0" dataset="DS_DATA">
			<td><component cmptype="Label" captionfield="REG_DATE"/></td>
			<td><component cmptype="Label" captionfield="REG_TIME"/></td>
			<td><component cmptype="Label" captionfield="PATIENT_FIO"/></td>
                        <td><component cmptype="Label" captionfield="FIO"/></td>
			<td><component cmptype="Label" captionfield="SPECIALITY"/></td>
			<td><component cmptype="Label" captionfield="DP_KIND_NAME"/></td>
                        <td><component cmptype="Label" captionfield="PAYMENT_KIND"/></td>
                        <td><component cmptype="Label" captionfield="REC_DATE"/></td>
                        <td><component cmptype="Label" captionfield="SE_NAME"/></td>
                        <td><component cmptype="Label" captionfield="DEPARTMENT"/></td>
                        
		</tr>
	</tbody>
</table>
</div>