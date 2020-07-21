<div cmptype="Form" oncreate="base().OnCreate();" onshow="base().OnShow();" style="font-family:Tahoma;width:100%
background: none repeat scroll 0% 0% white; position: relative; top: 0mm; left: 0mm; padding-top:0mm;font-size: 8pt;">
<span style="display:none" id="PrintSetup" ps_paperData="9" ps_marginTop="4" ps_marginRight="4" ps_marginBottom="4" ps_marginLeft="4"></span>
<component cmptype="Script">
	Form.OnCreate=function()
	{
		setVar('DATE_B',$_GET['DATE_B']);
		setVar('DATE_E',$_GET['DATE_E']);
		setVar('CASH_SECTION',$_GET['CASH_SECTION']);
		setVar('CASH_DEP',$_GET['DEP']);

                if(!empty(getVar('CASH_DEP')))
                {
                    setVar('sCASH_DEP', '='+getVar('CASH_DEP'));
                    addSystemInfo('DS_CASH',{get:'_f[CASH_DEP_ID]',srctype:'var',src:'sCASH_DEP',ignorenull:false});
					addSystemInfo('DS_BEZNAL',{get:'_f[CASH_DEP_ID]',srctype:'var',src:'sCASH_DEP',ignorenull:false});
                }
		executeAction('getUser');
	}
	Form.counter = 1;
	Form.TotalSum = 0;	
	Form.oncloneSetFormat=function(_domObject, _dataArray)
    {
		setCaption('SUMM',parseToRussianFormat(parseToJSFloat(_dataArray['SUMM']),2));
		Form.TotalSum += parseToJSFloat(_dataArray['SUMM']);
		setCaption('Number',Form.counter);
		Form.counter++;
	}
	Form.afterClone = function()
        {
		setCaption('FULL_SUM', parseToRussianFormat(parseToJSFloat(Form.TotalSum),2));
		setCaption('FULL_SUM_WORD', toUpperFirstCase(number_to_string(Form.TotalSum)));
	}


	
	
</component>
<table width="100%">
	<tr>
		<td style="width:150px" class="print p2">
			<component cmptype="Label" dataset="DS_CASH_SECTION" repeate="0" captionfield="CS_NAME"/><br/>
			<component cmptype="Label" dataset="DS_CASH_DEP" repeate="0" captionfield="CD_NAME"/>
		</td>
		<td style="padding-left:50px;text-align:center;" class="print p3">
				Кассовый отчет за период<br />
				с <component cmptype="Label" name="DATE_B"/>
				по <component cmptype="Label" name="DATE_E"/>
		</td>
		<td style="width:200px" class="print p2">
			<component cmptype="Label" dataset="DS_LPU" repeate="0" captionfield="FULLNAME" />
		</td>
	</tr>
</table>
    <table border="1" cellpadding="1"  cellspacing="1" width="99%">
	  <colgroup>
		<col width="15px"/>
		<col width="70px"/>
	  	<col/>
        <col width="50px"/>
		<col name="service_name_col_desc"/>
		<col width="100px"/>
		<col width="100px"/>
		<col width="100px"/>
	  </colgroup>	
	  <tr name="header_tr">
            <td class="print p">№ п/п</td>
            <td class="print p">Дата</td>
            <td class="print p">Фамилия, имя, отчество</td>
		  	<td class="print p">Дата рождения</td>
		  	<td class="print p">Услуга</td>
            <td class="print p">Врач</td>
            <td class="print p">Префикс-№ договора</td>
            <td class="print p">Сумма</td>
			<td class="print p">Оплата</td>
			
	  </tr>
	  <tr dataset="DS_CASH" repeate="0" onclone="base().oncloneSetFormat(this,_dataArray);" afterrefresh="base().afterClone();">
	    <td class="print p2" style="text-align:center;">
			<component cmptype="Label" name="Number" />
	    </td>
            <td class="print p2">
			<component cmptype="Label" captionfield="PAY_DATE" />
	    </td>
		  <td class="print p2">
			  <component cmptype="Label" captionfield="FIO" />
		  </td>
		  <td class="print p2">
			  <component cmptype="Label" captionfield="BIRTHDATE" />
		  </td>
	    <td class="print p2" name="service_name_td">
			<component cmptype="Label" captionfield="SERVICE_NAME" /> 
	    </td>
	    <td class="print p2">
			<component cmptype="Label" captionfield="EMPLOYER_FIO_TO" /> 
	    </td>
	    <td class="print p2" align="right">
			<component cmptype="Label" captionfield="CONTRACT_FULL_NUMB" /> 
	    </td>
	    <td class="print p2" align="right">
			<component cmptype="Label" name="SUMM" /> 
	    </td>
		<td class="print p2" align="right">
			<component cmptype="Label" name="SP" captionfield="SP" /> 
	    </td>
	</tr>
	
	
	<tr>
	  <td class="print p3" align="right" colspan="7" name="result_col_title_td">ИТОГО: </td>
	  <td class="print p3" align="right">
	  
	 	<component cmptype="Label" name="FULL_SUM" />
	  </td>
	  <td class="print p3" align="right">
	  
	 	
	  </td>
	</tr>
    </table>


    <component cmptype="SubForm" path="Reports/Cash/chunk/sys_cash_footer"/>


			

</div>
