<div>
	<div cmptype="tr" name="DIV_REPEATER" dataset="DsReport" keyfield="DIR_SERV_ID" repeat="0" class="rep_div"
	     onafter_clone="Form.prepareBarcodeData(clone, data);" onafter_refresh="Form.getBarcodes();">
		<div class="patient-data">
			<cmpLabel name="PAT_LABEL" style="font-size: 14px;" caption="Пациент:"/>
			<cmpLabel  dataset="DsPatientInfo" data="caption:PATIENT_FIO" class="patient-data__fio"/>
			<cmpLabel dataset="DsPatientInfo" data="caption:PATIENT_ADD_INFO" />
		</div>
		<table class="report-table">
			<col/>
			<col width="20%"/>
			<col width="10%"/>
			<col width="20%"/>
			<thead>
			<tr>
				<th colspan="4" class="header">
					<span clas="header__talon">Талон на прием <cmpLabel class='header__talon-number' data="caption:TALON_NUM"/></span>
					<div class="barcode">
						<cmpImage name="Barcode" src="" visible="false"/>
					</div>
				</th>
			</tr>
			</thead>
			<tbody>
			<tr class="align-center">
				<td>Услуга</td>
				<td>Время</td>
				<td>Кабинет</td>
				<td>Врач</td>
			</tr>
			<tr class="align-center">
				<td><cmpLabel data="caption:SERVICE_NAME" /></td>
				<td><cmpLabel data="caption:REC_DATE" /></td>
				<td><cmpLabel data="caption:CABLAB_TO_NAME" /></td>
				<td><cmpLabel data="caption:EMPLOYER_FIO_TO" /></td>
			</tr>
			</tbody>
		</table>
	</div>
	<div class="report-warning">
		<span class="report-warning__alert">Внимание!</span> При двух и более назначениях в течение одного дня регистрируйтесь в электронной очереди
		только после прохождения более ранней консультации или исследования
	</div>
	<style>
		.dir_electronic_queue {
			font-family: "Times New Roman", "Times", "sans-serif";
		}
		.dir_electronic_queue .report-table {
			width: calc(100% - 1px);
			margin-left: 1px;
			margin-bottom: 3px;
		}
		.dir_electronic_queue .report-table >  thead > tr > td {
			font-size: 14px;
			padding:5px;
		}
		.dir_electronic_queue .report-table > tbody > tr > td {
			border: 1px solid black;
			padding:4px;
		}
		.dir_electronic_queue .header {
			border: 1px black solid;
			text-align: center;
			font-weight: bold;
			font-size: 16px;
			text-transform: uppercase;
			padding: 8px;
		}

		.header__talon {
			line-height: 50px;
			text-transform: uppercase;
		}

		.header__talon-number {
			font-size: 24px !important;
		}

		.dir_electronic_queue .barcode {
			float: right;
		}

		.patient-data {
			margin-bottom: 8px;
		}

		.patient-data__fio {
			font-weight: bold;
		}

		.align-center {
			text-align: center;
		}

		.report-warning {
			font-size: 16px;
			text-align: center;
		}

		.report-warning__alert {
			font-weight: bold;
		}

		.rep_div {
			page-break-inside: avoid;
			margin-bottom: 32px;
		}

		@page {
			margin: 1.0cm 1.0cm 1.0cm 1.0cm;
		}
	</style>
</div>
