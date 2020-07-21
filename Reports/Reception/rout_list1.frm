<div cmptype="div" oncreate="base().OnCreate();" style="font-family:Verdana,Arial,Helvetica,sans-serif; padding: 5mm;">
	<component cmptype="Script">
	<![CDATA[
		Form.OnCreate = function()
		{
            setVar('DS_ID', $_GET['DS_ID']);
            setVar('PATIENT_ID', $_GET['PATIENT_ID']);
            setVar('THIS_SERV', $_GET['THIS_SERV']);
            setVar('NOT_DONE', $_GET['NOT_DONE']);
            executeAction('GetPatientName', function() {
                setVar('DATE_BEGIN', !empty($_GET['DATE_BEGIN']) ? $_GET['DATE_BEGIN'] : getVar('vDATE_BEGIN')); //
                setVar('DATE_END',   !empty($_GET['DATE_END'])   ? $_GET['DATE_END']   : getVar('vDATE_END'));
                setVar('TIME_BEGIN', !empty($_GET['TIME_BEGIN']) ? $_GET['TIME_BEGIN'] : getVar('vTIME_BEGIN'));
                setVar('TIME_END',   !empty($_GET['TIME_END'])   ? $_GET['TIME_END']   : getVar('vTIME_END'));
                refreshDataSet('DS_DIR_SERV');
            });

            if(typeof(base().UserFormOnCreate) == 'function')
                base().UserFormOnCreate();
		}
	]]>
	</component>
	
	<component cmptype="Action" name="GetPatientName">
        <![CDATA[
            begin
                select t.SURNAME||' '|| t.FIRSTNAME ||' '||t.LASTNAME
                  into :PATIENT_FIO
                  from d_v_Persmedcard t
                 where t.id = :PATIENT_ID;
                :DATE_BEGIN := trunc(sysdate);
                :DATE_END := trunc(sysdate);
                :TIME_BEGIN := '00:00';
                :TIME_END := '23:54';
            end;
        ]]>
        <component cmptype="ActionVar" name="PATIENT_ID"  get="PATIENT_ID"  src="PATIENT_ID"  srctype="var" />
        <component cmptype="ActionVar" name="PATIENT_FIO" put="PATIENT_FIO" src="PATIENT_FIO" srctype="ctrlcaption" len="2000" />
        <component cmptype="ActionVar" name="DATE_BEGIN"  put="DATE_BEGIN"  src="vDATE_BEGIN" srctype="var" len="30"/>
        <component cmptype="ActionVar" name="DATE_END"    put="DATE_END"    src="vDATE_END"   srctype="var" len="30"/>
        <component cmptype="ActionVar" name="TIME_BEGIN"  put="TIME_BEGIN"  src="vTIME_BEGIN" srctype="var" len="30"/>
        <component cmptype="ActionVar" name="TIME_END"    put="TIME_END"    src="vTIME_END"   srctype="var" len="30"/>
    </component>

        <component cmptype="DataSet" name="DS_DIR_SERV" compile="true" activateoncreate="false">
                    <![CDATA[
                         select ds.ID DIR_SERV_ID,
                                ds.SERVICE_ID,
                                ds.SERVICE_NAME,
                                ds.PATIENT,
                                ds.EMPLOYER_TO,
                                ds.EMPLOYER_FIO_TO, 
                                ds.CABLAB_TO_ID,
                                ds.CABLAB_TO_NAME,
								ds.TIME_TYPE_NAME,
                                to_char(ds.REC_DATE,'dd.mm.yyyy') REC_DATE,
                                to_char(ds.REC_DATE,'hh24:mi') REC_TIME,
                                ds.PAYMENT_KIND_NAME
                            from D_V_DIRECTION_SERVICES ds
                            where ds.PATIENT=:PATIENT_ID
                                and ds.SERV_STATUS <> 2
                                  @ if (:THIS_SERV==1){
                                    and  ds.ID= :DS_ID
                                  @}
                                  @ if (:NOT_DONE==1){
                                    and  ds.SERV_STATUS<>1
                                  @}
                            and ds.REC_DATE >= to_date(:DATE_BEGIN||' '||:TIME_BEGIN, 'dd.mm.yyyy hh24:mi')
                            and ds.REC_DATE <= to_date(:DATE_END||' '||:TIME_END, 'dd.mm.yyyy hh24:mi')
                        ]]>
                <component cmptype="Variable" name="PATIENT_ID" get="PATIENT_ID" src="PATIENT_ID" srctype="var" />
                <component cmptype="Variable" name="THIS_SERV" get="THIS_SERV" src="THIS_SERV" srctype="var" />
                <component cmptype="Variable" name="DS_ID" get="DS_ID" src="DS_ID" srctype="var" />
                <component cmptype="Variable" name="DATE_BEGIN" get="DATE_BEGIN" src="DATE_BEGIN" srctype="var" />
                <component cmptype="Variable" name="DATE_END" get="DATE_END" src="DATE_END" srctype="var" />
                <component cmptype="Variable" name="TIME_BEGIN" get="TIME_BEGIN" src="TIME_BEGIN" srctype="var" />
                <component cmptype="Variable" name="TIME_END" get="TIME_END" src="TIME_END" srctype="var" />
                <component cmptype="Variable" name="NOT_DONE" get="NOT_DONE" src="NOT_DONE" srctype="var" />
        </component>
	
        <style>
		div.rep_div{
			border-top: 1px solid #aaaaaa; 
			margin-top: 10px; 
			padding-top: 5px; 
			font-weight: bold;
		}
		td.caption{
			font-size: 12px;						
		}
		td.field{
			padding: 3px 10px 0;			
		}
                div.title{
                margin-bottom: 10px;
                font-weight: bold;
       }
        div.doc{
                font-size: 16px;
                text-align: center;
                padding: 10px;
                font-family: initial;
                font-weight:bold;
                text-decoration:underline;
       }

   

	</style>
	<div align="center" class="title" cmptype="tmp" name="titleDiv">
		<component cmptype="Label" name="TITLE" caption="Талон КТ,МРТ"/>
	</div>
        <component cmptype="Label" name="PAT_LABEL" style="font-size: 14px;" caption="Пациент:"/> 
        <component cmptype="Label" name="PATIENT_FIO" />
        <div cmptype="tr" name="DIV_REPEATER" dataset="DS_DIR_SERV" keyfield="DIR_SERV_ID" repeate="0" class="rep_div">
		<table width="100%">
                        <colgroup>
                            <col width="20%"/>
                            <col/>
                        </colgroup>
                        <tr cmptype="tmp" name="REC_DATE_ROW">
				<td class="caption">Дата:</td>
				<td class="field" style="font-size: 16px;"><b><component cmptype="Label" captionfield="REC_DATE" /></b></td>
			</tr>
			<tr>
				<td class="caption">Время:</td>
				<td class="field" style="font-size: 16px;"><b><component cmptype="Label" captionfield="REC_TIME" /></b></td>
			</tr>
			<tr>
				<td class="caption">Кабинет:</td> 
				<td class="field"><component cmptype="Label" captionfield="CABLAB_TO_NAME" /></td>
				
			</tr>
			
			<tr>
				<td class="caption">Услуга:</td> 
				<td class="field"><component cmptype="Label" captionfield="SERVICE_NAME" /></td>
			</tr>
			<tr>
				<td class="caption">Вид оплаты:</td> 
				<td class="field"><component cmptype="Label" captionfield="TIME_TYPE_NAME" /></td>
				
			</tr>
			
			<tr cmptype="tmp" name="REC_DATE_ROW_LAST">
				<td class="caption">Врач:</td> 
				<td class="field"><component cmptype="Label" captionfield="EMPLOYER_FIO_TO" /></td>
			</tr>
		</table>
        <div class="doc"> Необходимые документы при прохождении исследования:</div>

                    <ul class="spisok">
                            <li> Направление из поликлиники с номером, подписью заведующего и печатью;</li>
                            <li> Выписку о заболевании и выполненных исследованиях;</li>
                            <li>согласие на проведение исследования (можно заполнить в кабинете перед исследованием);</li>
                            <li>ксерокопия паспорта (страницы с ФИО и датой рождения и места регистрации-прописки);</li>
                            <li>ксерокопия полиса (обе стороны).</li>
                    </ul>
                    
        
                  <div class="doc"> Если Вы не сможете прийти в назначенный день, то сообщите в регистратуру по телефону, будет приглашен другой пациент из очереди. Спасибо!
                  Тел.: 8-495-593-22-22 или 8-495-593-12-66.</div>
                  </div>
        
</div>