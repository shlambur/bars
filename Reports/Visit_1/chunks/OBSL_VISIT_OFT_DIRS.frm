<div>
	<style>
	.report_data tr td{
		font-weight: bold;
		text-align: left;
		padding: 1px 4px;
	}
	.report_data tr.report_data_header td{
		text-align: center;
	}
	.report_data{
		margin-top: 10px;
		width: 100%;
	}
	</style>
	<component cmptype="Script">
		Form.oCloneAll = function(_dom,_dataArray)
		{
			$$(_dom);
			if(_dataArray['SHOW_SIGN'] == 1)
			{
				getControlByName('ALL_SERV_CH').style.display = 'none';
			}
			else
			{
				getControlByName('ALL_SERV_CH').style.display = '';
			}
			_$$();
		}
	</component>
	<component cmptype="DataSet" name="FIND_VISITS">
		<![CDATA[
		select ds_all.SERVICE_NAME as HELP_SERV_NAME,
			   vf_all.STR_VALUE as HELP_STR_VALUE,
			   decode(vf_all.STR_VALUE,null,null,'Описание: ') as FIELD_CAPTION,
				decode(vz_all.STR_VALUE,null,null,'Заключение: ') as FZ_CAPTION,
				vz_all.STR_VALUE as HZ_STR_VALUE,
				case when vz_all.STR_VALUE is null and vf_all.STR_VALUE is null then 1 else 0 end SHOW_SIGN
		from d_v_visits vis,
			 d_v_direction_services ds_m,
			 d_v_direction_services ds_all,
			 d_v_visits v_all,
			 d_v_visit_fields vf_all,
			 d_v_visit_fields vz_all
		where vis.ID = :VISIT
			 and ds_m.ID = vis.PID
			 and ds_all.IRID = ds_m.ID
			 and v_all.PID = ds_all.ID
			 and vf_all.PID(+) = v_all.ID
			 and vf_all.TEMPLATE_FIELD(+) = 'PROTOCOL'
			 and vz_all.TEMPLATE_FIELD(+) = 'ZAKL'
			 and vz_all.PID(+) = v_all.ID
			 and ds_all.SERVICE_TYPE not in ( 6,7 )
		]]>
		<component cmptype="Variable" name="VISIT" src="VISIT" srctype="var" get="v1"/>
	</component>
	<component cmptype="DataSet" name="n9003ds11">
		select s.SE_NAME SERVICE_NAME,
		       to_char(ds.REC_DATE, 'dd.mm.yyyy hh24:mi') VDATE,
		       ds.CABLAB_TO
		  from d_v_directions t,
			   d_v_direction_services ds,
			   d_v_services s,
			   d_v_visits v
		 where v.ID = :VISIT
		   and t.REG_VISIT_ID = v.ID
		   and t.ID = ds.PID
		   and ds.SERV_STATUS = 0
		   and ds.SERVICE_ID = s.ID
		   and (s.SE_TYPE = 0 or s.SE_TYPE = 8) /*0 - исследование, 1 - процедура, 2 - операция, 3 - посещение, 8 - анализ*/
		   and ds.SERV_STATUS = 0
		<component cmptype="Variable" name="VISIT" src="VISIT" srctype="var" get="v0"/>
	</component>

	<component cmptype="DataSet" name="n9003ds12">
		select t.SERVICE_NAME,
		       to_char(v.VISIT_DATE, 'dd.mm.yyyy') VDATE,
		       to_char(v.VISIT_DATE, 'hh24:mi')VTIME
		  from d_v_direction_services t,
			   d_v_services s,
			   d_v_visits v
		 where t.HID = :DIRECTION_SERVISES
		   and t.SERVICE_ID = s.ID
		   and (s.SE_TYPE = 0 or s.SE_TYPE = 8) /*0 - исследование, 1 - процедура, 2 - операция, 3 - посещение, 8 - анализ*/
		   and v.PID = t.ID
		<component cmptype="Variable" name="DIRECTION_SERVISES" src="DIRECTION_SERVISES" srctype="var" get="v0"/>
	</component>

	<component cmptype="DataSet" name="n9003ds13">
		select s.SE_NAME SERVICE_NAME,
		       to_char(ds.REC_DATE, 'dd.mm.yyyy hh24:mi') VDATE,
		       ds.CABLAB_TO
		  from d_v_directions t,
			   d_v_direction_services ds,
			   d_v_services s,
			   d_v_visits v
		 where v.ID = :VISIT
		   and t.REG_VISIT_ID = v.ID
		   and t.ID = ds.PID
		   and ds.SERVICE_ID = s.ID
		   and s.SE_TYPE = 2 /*0 - исследование, 1 - процедура, 2 - операция, 3 - посещение*/
		   and ds.SERV_STATUS = 0
		<component cmptype="Variable" name="VISIT" src="VISIT" srctype="var" get="v0"/>
	</component>

	<component cmptype="DataSet" name="n9003ds14">
		select t.SERVICE_NAME,
		       ( select t.STR_VALUE
		           from d_v_visit_fields t
		          where template_field = 'TOTAL_OFT'
		            and t.PID = v.ID) TOTAL_OFT ,
		       to_char(t.REC_DATE, 'dd.mm.yyyy') VDATE,
		       to_char(t.REC_DATE, 'hh24:mi')VTIME
		  from d_v_direction_services t,
			   d_v_services s,
			   d_v_visits v
		 where t.HID = :DIRECTION_SERVISES
		   and t.SERVICE_ID = s.ID
		   and s.SE_TYPE = 2 /*0 - исследование, 1 - процедура, 2 - операция, 3 - посещение*/
		   and v.PID = t.ID
		<component cmptype="Variable" name="DIRECTION_SERVISES" src="DIRECTION_SERVISES" srctype="var" get="v0"/>
	</component>


	<component cmptype="DataSet" name="n9003ds15">
		select s.SE_NAME SERVICE_NAME,
		       to_char(ds.REC_DATE, 'dd.mm.yyyy hh24:mi') VDATE,
		       ds.CABLAB_TO
		  from d_v_directions t,
			   d_v_direction_services ds,
			   d_v_services s,
			   d_v_visits v
		 where v.ID = :VISIT
		   and t.REG_VISIT_ID = v.ID
		   and t.ID = ds.PID
		   and ds.SERVICE_ID = s.ID
		   and s.SE_TYPE = 1 /*0 - исследование, 1 - процедура, 2 - операция, 3 - посещение*/
		   and ds.SERV_STATUS = 0
		<component cmptype="Variable" name="VISIT" src="VISIT" srctype="var" get="v0"/>
	</component>

	<component cmptype="DataSet" name="n9003ds16">
		select t.SERVICE_NAME,
		       to_char(v.VISIT_DATE, 'dd.mm.yyyy') VDATE,
		       to_char(v.VISIT_DATE, 'hh24:mi')VTIME
		  from d_v_direction_services t,
			   d_v_services s,
			   d_v_visits v
		 where t.HID = :DIRECTION_SERVISES
		   and t.SERVICE_ID = s.ID
		   and s.SE_TYPE = 1 /*0 - исследование, 1 - процедура, 2 - операция, 3 - посещение*/
		   and v.PID = t.ID
		<component cmptype="Variable" name="DIRECTION_SERVISES" src="DIRECTION_SERVISES" srctype="var" get="v0"/>
	</component>



	<component cmptype="DataSet" name="n9003ds18">
		select s.SE_NAME SERVICE_NAME,
		       to_char(ds.REC_DATE, 'dd.mm.yyyy hh24:mi') VDATE,
		       ds.CABLAB_TO
		  from d_v_directions t,
			   d_v_direction_services ds,
			   d_v_services s,
			   d_v_visits v
		 where v.ID = :VISIT
		   and t.REG_VISIT_ID = v.ID
		   and t.ID = ds.PID
		   and ds.SERVICE_ID = s.ID
		   and s.SE_TYPE = 3 /*0 - исследование, 1 - процедура, 2 - операция, 3 - посещение*/
		<component cmptype="Variable" name="VISIT" src="VISIT" srctype="var" get="v0"/>
	</component>
	<div cmptype="form" name="Form_NAZNACH_VIS" style="display:none;" onshow="if (getControlProperty('NAZNACH_VIS', 'caption')!='') {getControlByName('Form_NAZNACH_VIS').style.display='';}">
		<table class="report_data" cellspacing="0">
			<colgroup>
				<col width="60%"/>
				<col width="20%"/>
				<col width="20%"/>
			</colgroup>
			<tbody>
				<tr class="report_data_header">
					<td>
						<component cmptype="Label" caption="Назначенные посещения:"/>
					</td>
					<td>
						<component cmptype="Label" caption="Дата"/>
					</td>
					<td>
						<component cmptype="Label" caption="Кабинет"/>
					</td>
				</tr>
				<tr cmptype="GridRow" dataset="n9003ds18" repeate="0">
					<td>
						<component cmptype="Label" captionfield="SERVICE_NAME" name="NAZNACH_VIS"/>
					</td>
					<td>
						<component cmptype="Label" captionfield="VDATE"/>
					</td>
					<td>
						<component cmptype="Label" captionfield="CABLAB_TO"/>
					</td>
				</tr>
			</tbody>
		</table>
	</div>
	
	<div cmptype="form" name="Form_NAZNACH_ISLED" style="display:none;" onshow="if (getControlProperty('NAZNACH_ISLED', 'caption')!='') {getControlByName('Form_NAZNACH_ISLED').style.display='';}">
		<table class="report_data" cellspacing="0">
			<colgroup>
				<col width="60%"/>
				<col width="20%"/>
				<col width="20%"/>
			</colgroup>
			<tbody>
				<tr class="report_data_header">
					<td>
						<component cmptype="Label" caption="Назначенные исследования"/>
					</td>
					<td>
						<component cmptype="Label" caption="Дата"/>
					</td>
					<td>
						<component cmptype="Label" caption="Кабинет"/>
					</td>
				</tr>
				<tr cmptype="GridRow" dataset="n9003ds11" repeate="0">
					<td>
						<component cmptype="Label" captionfield="SERVICE_NAME" name="NAZNACH_ISLED"/>
					</td>
					<td>
						<component cmptype="Label" captionfield="VDATE"/>
					</td>
					<td>
						<component cmptype="Label" captionfield="CABLAB_TO"/>
					</td>
				</tr>
			</tbody>
		</table>
	</div>
		
	<div cmptype="form" name="Form_VIPOL_ISLED" style="display:none;" onshow="if (getControlProperty('VIPOL_ISLED', 'caption')!='') {getControlByName('Form_VIPOL_ISLED').style.display='';}">
		<table class="report_data" cellspacing="0">
			<colgroup>
				<col width="70%"/>
				<col width="30%"/>
			</colgroup>
			<tbody>
				<tr class="report_data_header">
					<td>
						<component cmptype="Label" caption="Выполненные исследования:"/>
					</td>
					<td>
						<component cmptype="Label" caption="Дата"/>
					</td>
				</tr>
				<tr cmptype="GridRow" dataset="n9003ds12" repeate="0">
					<td>
						<component cmptype="Label" captionfield="SERVICE_NAME" name="VIPOL_ISLED"/>
					</td>
					<td>
						<component cmptype="Label" captionfield="VDATE"/>
					</td>
				</tr>
			</tbody>
		</table>
	</div>
	
	<div cmptype="form" name="Form_NAZNACH_OPER" style="display:none;" onshow="if (getControlProperty('NAZNACH_OPER', 'caption')!='') {getControlByName('Form_NAZNACH_OPER').style.display='';}">
		<table class="report_data" cellspacing="0">
			<colgroup>
				<col width="70%"/>
				<col width="30%"/>
				<col width="20%"/>
			</colgroup>
			<tbody>
				<tr class="report_data_header">
					<td>
						<component cmptype="Label" caption="Назначенные операции"/>
					</td>
					<td>
						<component cmptype="Label" caption="Дата"/>
					</td>
					<td>
						<component cmptype="Label" caption="Кабинет"/>
					</td>
				</tr>
				<tr cmptype="GridRow" dataset="n9003ds13" repeate="0">
					<td>
						<component cmptype="Label" captionfield="SERVICE_NAME" name="NAZNACH_OPER"/>
					</td>
					<td>
						<component cmptype="Label" captionfield="VDATE"/>
					</td>
					<td>
						<component cmptype="Label" captionfield="CABLAB_TO"/>
					</td>
				</tr>
			</tbody>
		</table>
	</div>
	
	<div cmptype="form" name="Form_VIPOL_OPER" style="display:none;" onshow="if (getControlProperty('VIPOL_OPER', 'caption')!='') {getControlByName('Form_VIPOL_OPER').style.display='';}">
		<table class="report_data" cellspacing="0">
			<colgroup>
				<col width="40%"/>
				<col width="60%"/>
			</colgroup>
			<tbody>
				<tr class="report_data_header">
					<td>
						<component cmptype="Label" caption="Выполненные операции"/>
					</td>
					<td>
						<component cmptype="Label" caption="Результат выполненной операции"/>
					</td>
				</tr>
				<tr cmptype="GridRow" dataset="n9003ds14" repeate="0">
					<td>
						<component cmptype="Label" captionfield="SERVICE_NAME" name="VIPOL_OPER"/>
					</td>
					<td>
						<component cmptype="Label" captionfield="TOTAL_OFT"/>
					</td>
				</tr>
			</tbody>
		</table>
	</div>
	
	<div cmptype="form" name="Form_NAZNACH_PROC" style="display:none;" onshow="if (getControlProperty('NAZNACH_PROC', 'caption')!='') {getControlByName('Form_NAZNACH_PROC').style.display='';}">
		<table class="report_data" cellspacing="0">
			<colgroup>
				<col width="60%"/>
				<col width="20%"/>
				<col width="20%"/>
			</colgroup>
			<tbody>
				<tr class="report_data_header">
					<td>
						<component cmptype="Label" caption="Назначенные процедуры"/>
					</td>
					<td>
						<component cmptype="Label" caption="Дата"/>
					</td>
					<td>
						<component cmptype="Label" caption="Кабинет"/>
					</td>
				</tr>
				<tr cmptype="GridRow" dataset="n9003ds15" repeate="0">
					<td>
						<component cmptype="Label" captionfield="SERVICE_NAME" name="NAZNACH_PROC"/>
					</td>
					<td>
						<component cmptype="Label" captionfield="VDATE"/>
					</td>
					<td>
						<component cmptype="Label" captionfield="CABLAB_TO"/>
					</td>
				</tr>
			</tbody>
		</table>
	</div>
	
	<div cmptype="form" name="Form_VIPOL_PROC" style="display:none;" onshow="if (getControlProperty('VIPOL_PROC', 'caption')!='') {getControlByName('Form_VIPOL_PROC').style.display='';}">
		<table class="report_data" cellspacing="0">
			<colgroup>
				<col width="70%"/>
				<col width="30%"/>
			</colgroup>
			<tbody>
				<tr class="report_data_header">
					<td>
						<component cmptype="Label" caption="Выполненные процедуры:"/>
					</td>
					<td>
						<component cmptype="Label" caption="Дата"/>
					</td>
				</tr>
				<tr cmptype="GridRow" dataset="n9003ds16" repeate="0">
					<td>
						<component cmptype="Label" captionfield="SERVICE_NAME"/>
					</td>
					<td>
						<component cmptype="Label" captionfield="VDATE" name="VIPOL_PROC"/>
					</td>
				</tr>
			</tbody>
		</table>
	</div>
	<div cmptype="hz" dataset="FIND_VISITS" repeate="0" name="ALL_SERVICES" onclone="base().oCloneAll(this, _dataArray);">
		<div name="ALL_SERV_CH" cmptype="div_all">
			<div style="text-align: center;">
				<b>
					<component cmptype="Label" captionfield="HELP_SERV_NAME"/>
				</b>
			</div>
			<br/>
			<b>
				<component cmptype="Label" captionfield="FIELD_CAPTION"/>
			</b>
		  	<component cmptype="Label" name="HELP_STR_VALUE" formated="true" captionfield="HELP_STR_VALUE" after_caption="&lt;br/&gt;"/>
			<br/>
			<b>
				<component cmptype="Label" captionfield="FZ_CAPTION"/>
			</b>
		  	<component cmptype="Label" name="HZ_STR_VALUE" formated="true" captionfield="HZ_STR_VALUE" after_caption="&lt;br/&gt;"/>
			<br/>
			<br/>
		</div>
	</div>
</div>
