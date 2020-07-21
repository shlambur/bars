<div cmptype="rep" style="min-width: 1180px;">
	<span style="display:none" id="PrintSetup" ps_marginBottom="4" ps_marginRight="4" ps_marginTop="4" ps_marginLeft="4" ps_orientation="landscape" ps_paperData="9" ps_shrinkToFit="0" ps_scaling="90"></span>
	
<component cmptype="DataSet" name="DS_DATA" compile="true">
      <![CDATA[
		  SELECT 
				
            	to_char(pj.PAY_DATE, 'DD') PAY_DAY,
				to_char(pj.PAY_DATE, 'MM') PAY_MONTH,
				to_char(pj.PAY_DATE, 'YY') PAY_YEAR
			
                     from D_V_CONTRACTS ctr
				join D_V_CONTRACT_PAYMENTS cp on cp.PID = ctr.ID
					join D_V_PJ_CON_PAYMENTS pjcp on pjcp.CONTRACT_PAYMENT = cp.ID
						join D_V_PAYMENT_JOURNAL pj on pj.ID = pjcp.PID
                        where ctr.ID = :CONTRACT_ID
        
      ]]>
        
        <component  cmptype="Variable" name="CONTRACT_ID" src="CONTRACT_ID" srctype="var" get="v0" />
    </component>
	

	<table>
		<tr dataset="DS_DATA" >
	 		 <td><component cmptype="Label"  captionfield="PAY_DAY" /> </td> <td>день </td> 
			 <td><component cmptype="Label"  captionfield="PAY_MONTH" /></td>
			 <td><component cmptype="Label"  captionfield="PAY_YEAR" /></td>

		</tr>
	</table>
</div> 