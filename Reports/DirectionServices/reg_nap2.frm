<div cmptype="Form"  oncreate="base().onCreate();" style="width:400mm"> 
<span style="display:none" id="PrintSetup" ps_paperData="9" ps_orientation="landscape"></span>
<component cmptype="Script">
	<![CDATA[
	Form.onCreate = function(){
        setCaption('DEPS', $_GET['DEPS']);
                                        setVar('DEPS', $_GET['DEPS']);
        setCaption('DATE_BEGIN', $_GET['DATE_BEGIN']);
		                        setVar('DATE_BEGIN', $_GET['DATE_BEGIN']);
        setCaption('DATE_END',$_GET['DATE_END']);
                                        setVar('DATE_END', $_GET['DATE_END']);
               
     
	}
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
        }
	]]>
</component>

<component cmptype="DataSet" name="DS_DATA" compile="true">
	<![CDATA[
  select
  t.LPU LPU,
  t.REG_TIME ,
  t.REG_DATE,
  t.SE_NAME,
  t.PATIENT_FIO,
  t.PAYMENT_KIND,
  t2.FIO  Vrach,
  t2.SPECIALITY,
  t2.DEPARTMENT ,
  t2.DP_KIND_NAME
  from   d_v_dir_serv_prescriptions t
  left join D_V_EMPLOYERS t2 on t2.ID = t.REG_EMPLOYER
  where t.reg_type ='2'
  and t.se_type= '0'
  and t.payment_kind  like 'Средства граждан%'
  and t.REG_DATE  >=: DATE_BEGIN
  and t.REG_DATE  <= :DATE_END
  and t2.DEPARTMENT_ID= :DEPS

	]]>
        <component cmptype="Variable" name="LPU"        src="LPU"        srctype="session"/>
        <component cmptype="Variable" name="DEPS"       src="DEPS"       srctype="var" get="v2"/>
	<component cmptype="Variable" name="DATE_BEGIN" src="DATE_BEGIN" srctype="var" get="v0"/>
        <component cmptype="Variable" name="DATE_END" src="DATE_END" srctype="var" get="v1"/>
        <component cmptype="Variable" name="DEPS" src="DEPS" srctype="var" get="v3"/>
</component>

<div style="width:100%;text-align:left;">
    <component cmptype="Label" dataset="DS_DATA" repeate="0" />
    <br/>
     <component cmptype="Label" caption='Периуд запроса   с' name="DATE_BEGIN" />  по  <component cmptype="Label" caption='по' name="DATE_END" /> <br/>
<component cmptype="Label" caption='Отдление ' name="DEPS" />
 </div>





<div DataSet="DS_data" onclone="base().setCountAll()">
<div><component caption=' отделение'  captionfield='DEPARTMENT' /></div>


<table   class="t"  style="width: 100%;">

        <tr>
                <td class="tds">№ п/п</td>
                <td class="tds">Дата и назначения</td>
                <td class="tds">Время</td>
                <td class="tds">ФИО</td>
                <td class="tds">Направивший врач</td>
                <td class="tds"> Должность</td>
                <td class="tds">Подразделение</td>
                <td class="tds">Вид оплаты</td>
                <td class="tds"> Дта презаписи</td>
                <td class="tds">Услуга</td>
                <td class="tds"> Направившее отделения</td>
                
        </tr>
        <tr dataset="DS_DATA" repeate="0" onclone="base().setCount()">
                <td class="td"><component cmptype="Label" name='COUNTi' captionfield="COUNTi"/></td>
                <td class="td"><component cmptype="Label" captionfield="REG_DATE"/></td>
                <td class="td"><component cmptype="Label" captionfield="REG_TIME"/></td>
                <td class="td"><component cmptype="Label" captionfield="PATIENT_FIO"/></td>
                <td class="td"><component cmptype="Label" captionfield="VRACH"/></td>
                <td class="td"><component cmptype="Label" captionfield="SPECIALITY"/></td>
                <td class="td"><component cmptype="Label" captionfield="DP_KIND_NAME"/></td>
                <td class="td"><component cmptype="Label" captionfield="PAYMENT_KIND"/></td>
                <td class="td"><component cmptype="Label" captionfield="REC_DATE"/></td>
                <td class="td"><component cmptype="Label" captionfield="SE_NAME"/></td>
                <td class="td"><component cmptype="Label" captionfield="DEPARTMENT"/></td>
                
        </tr>



</table>






</div>

 
<style>
	table.data tr td {
		padding: 2mm;
		border: 1pt solid black;
		text-align: center;
	}
        .t{
                border: 1pt solid black;
		text-align: center;
               
        }
        .td{
                
                padding: 2mm;
                border: 1pt solid black;
		text-align: center; 
        }
        .tds{
                width: 10%;
                padding: 2mm;
                border: 1pt solid black;
		text-align: center; 
                font-weight: 600;
        }
</style>
</div>