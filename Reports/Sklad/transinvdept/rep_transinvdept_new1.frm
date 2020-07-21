<div cmptype="Form" oncreate="base().onCreate();" class="report_main_div"  window_size="297mmx210mm" dataset="DS_TRANS_DEP">
    <style>
            div.report_main_div {
                padding: 2mm;
                padding-left: 5mm;
                padding-right: 5mm;
            }
            div.report_main_div table.table1 {
                width:100%;
            }
            div.report_main_div table.table1 td{
                border: 1px solid black;
                font-size: 10px;
                padding: 2px;
            }
            div.report_main_div table.table1 td.td1{
                text-align:center;
                border: 1px solid white;
                font-size: 10px;
            }
    </style>
    <span style="display:none" id="PrintSetup" ps_orientation="portrait"></span>
    <component cmptype="Script">
    <![CDATA[
        executeAction('SelectUser', function () {
					setCaption('EMPLOYER_FIO_SES', getVar('FIO_SES'));
                    setCaption('EMPLOYER_JOB_SES', getVar('JOB_SES'));
				});
        
    	Form.onCreate = function()
    	{
			setVar('SES',   $_GET['SES']);
            setVar('ID',   $_GET['TRANS_ID']);
            setVar('LANG', $_GET['LANG']);
            setVar('SPP',  $_GET['SHOW_PARTY_PACK']);
        };
        Form.COUNT=0;
        Form.COUNT_QUANT_IN_MAIN1 = 0;
        Form.COUNT_SUMM = 0;
        Form.aFlag = 0;
        Form.setCount = function(_da)
        {
            Form.COUNT++;
            setCaption('QUANT_IN_MAIN_SUMM', parseToRussianFormat(parseToJSFloat(_da['QUANT_IN_MAIN_SUMM']), 2));
            setCaption('SUMM', parseToRussianFormat(parseToJSFloat(_da['SUMM']), 2));
            Form.COUNT_SUMM = Form.COUNT_SUMM + parseToJSFloat(_da['SUMM']);

            var a = String(parseToJSFloat(_da['QUANT_IN_MAIN1']));
            var pos=a.indexOf(".", 0);
            var flag = 0;
            if(pos>-1)
            {
                flag = a.length - (pos+1)
                if(flag>=3)
                {
                    flag = 3;
                }else flag = 2;
            }
            if(flag>Form.aFlag)Form.aFlag = flag;

            setCaption('QUANT_IN_MAIN1', parseToRussianFormat(parseToJSFloat(_da['QUANT_IN_MAIN1']), flag));
            setCaption('QUANT_IN_MAIN2', parseToRussianFormat(parseToJSFloat(_da['QUANT_IN_MAIN1']), flag));
            Form.COUNT_QUANT_IN_MAIN1 = Form.COUNT_QUANT_IN_MAIN1 + parseToJSFloat(_da['QUANT_IN_MAIN1']);
            setCaption('COUNTi', Form.COUNT);
        };
        ]]>
    </component>
    <component cmptype="Action" name="SelectUser">
			begin
				select D_PKG_STR_TOOLS.FIO(t.SURNAME,t.FIRSTNAME,t.LASTNAME),
                    t.jobtitle 
				  into  :FIO_SES,
                        :JOB_SES
				  from d_v_employers t
				 where t.ID = :EMPLOYER;
			end;
		<component cmptype="ActionVar" name="PNLPU"     src="LPU"           srctype="session"/>
		<component cmptype="ActionVar" name="EMPLOYER"  src="EMPLOYER"      srctype="session"/>
		<component cmptype="ActionVar" name="FIO_SES"   src="FIO_SES"       srctype="var"     put="var1" len="100"/>
        <component cmptype="ActionVar" name="JOB_SES"   src="JOB_SES"       srctype="var"     put="var2" len="101"/>
    </component>
     
	
	
	
    <component cmptype="DataSet" name="DS_TRANS_DEP" compile="true">
        <![CDATA[
        select t.*,
               ts.*,
            @if (:OEI) {
               ts.NOMMODIF_MAIN_MEASURE as MAIN_MEAS,
               ts.QUANT_IN_MAIN as QUANT_IN_MAIN1,
               nvl(ts.PRISE / np.PACK_COUNT, ts.PRISE) as QUANT_IN_MAIN_SUMM,
            @} else {
               ts.PRICEMEAS_MNEMO as MAIN_MEAS,
               case
                 when ts.QUANT - trunc(ts.QUANT) <> 0
                 then trunc(ts.QUANT, 3)
                 else trunc(ts.QUANT, 0)
               end QUANT_IN_MAIN1,
               case
                 when ts.QUANT <> 0
                 then ts.SUMM/ts.QUANT
                 else 0
               end QUANT_IN_MAIN_SUMM,
            @}
               decode(:SPP, 1, ts.GOODPARTY_SER, null) PARTY_SER,
               case
                 when t.ATTORNEY_NUMB is not null and t.ATTORNEY_DATE is not null
                 then ' по доверенности № '||t.ATTORNEY_NUMB||' от '||t.ATTORNEY_DATE
                 else ''
               end DOV,
				
			  
			  
			  
               (select s.AGN_NAME_SHORT
                  from d_v_store_person s
                 where t.IN_STORE_ID = s.PID
                   and s.DATE_BEGIN <= t.DOC_DATE
                   and (s.DATE_END >= t.DOC_DATE or s.DATE_END is null)) person,
				   
				   (select s.POST
                  from d_v_store_person s
                 where t.IN_STORE_ID = s.PID
                   and s.DATE_BEGIN <= t.DOC_DATE
                   and (s.DATE_END >= t.DOC_DATE or s.DATE_END is null)) JOB_PERSON,

				   
				   
				   
				
			   
			   
			   ( select  e.FIO 
			   from D_V_EMPLOYERS e,d_v_store_person s			           -- ответственный исполнитель --
			   where t.IN_STORE_ID = s.PID 
			   and e. id=119565556
			   and s.DATE_BEGIN <= t.DOC_DATE
               and (s.DATE_END >= t.DOC_DATE or s.DATE_END is null)) EMPLOYER_FIO,



                (select DISTINCT s.AGN_NAME_SHORT  
                 from  D_V_EMPLOYERS e ,d_v_store_person s    --                                 Вытаскиваю   данные с входящего параметра по SES   который добавлен в сам отчет .
                Where  e.Agent = s.Agent_id
                and  e.SYSUSER_ID =:SES) SES,

                (select DISTINCT e.jobtitle
                 from  D_V_EMPLOYERS e ,d_v_store_person s    --                                 Вытаскиваю   данные с входящего параметра по SES   который добавлен в сам отчет .
                 Where  e.Agent = s.Agent_id
                and  e.SYSUSER_ID =:SES) JOB,


			   (select s.POST
                  from d_v_store_person s
                 where t.IN_STORE_ID = s.PID
                   and s.DATE_BEGIN <= t.DOC_DATE
                   and (s.DATE_END >= t.DOC_DATE or s.DATE_END is null)) post,

               (select s.DOC_NUMB
                  from d_v_store_person s
                 where t.IN_STORE_ID = s.PID
                   and s.DATE_BEGIN <= t.DOC_DATE
                   and (s.DATE_END >= t.DOC_DATE or s.DATE_END is null)) dov_num,

               (select s.DOC_DATE
                  from d_v_store_person s
                 where t.IN_STORE_ID = s.PID
                   and s.DATE_BEGIN <= t.DOC_DATE
                   and (s.DATE_END >= t.DOC_DATE or s.DATE_END is null)) dov_date,

                    (select
                        to_char(t.WORK_DATE, 'DD')                                                              --день отработки
                  from d_v_store_person s
                 where t.IN_STORE_ID = s.PID
                   and s.DATE_BEGIN <= t.DOC_DATE
                   and (s.DATE_END >= t.DOC_DATE or s.DATE_END is null))  DAY,

                   (select
                        to_char(t.WORK_DATE, 'MM')                                                              --Месяц отработки
                  from d_v_store_person s
                 where t.IN_STORE_ID = s.PID
                   and s.DATE_BEGIN <= t.DOC_DATE
                   and (s.DATE_END >= t.DOC_DATE or s.DATE_END is null))  MONTH,

                   (select
                        to_char(t.WORK_DATE, 'YYYY')                                                              --год отработки
                  from d_v_store_person s
                 where t.IN_STORE_ID = s.PID
                   and s.DATE_BEGIN <= t.DOC_DATE
                   and (s.DATE_END >= t.DOC_DATE or s.DATE_END is null))  YEAR,


               l.FULLNAME,
               gp.EXPIRATION_DATE,
               (select n.NOM_NUMBER
                  from d_v_nombase n, d_v_nommodif m
                 where n.ID = m.PID
                   and m.ID = ts.NOMMODIF_ID) NOM_NUMBER,
               decode(:LANG, 1, nvl(ts.NOMMODIF_LAT_NAME, ts.NOMMODIF_NAME), ts.NOMMODIF_NAME)
               @if (:SPP) {
               ||case when ts.PACK_CODE is not null then ', '||ts.PACK_CODE end
               @} else {
               ||case when ts.NOMMODIF_LAT_NAME is null then ', '||ts.PACK_CODE end
               @}
               LAT_NAME,
               d_pkg_constants.SEARCH_STR(
                    psCONST_CODE => 'STORE_ACCOUNT_NAME',
                    pnLPU => :LPU,
                    pdDATE =>t.WORK_DATE
                 ) BUH
               ,d_pkg_constants.SEARCH_STR(
                    psCONST_CODE => 'STORE_MAIN_NAME',
                    pnLPU => :LPU,
                    pdDATE => t.WORK_DATE
                  ) ZAV,
               ''||l.HEADDOCTOR_FULLNAME||'' HEADDOCTOR_FULLNAME
          from D_V_TRANSINVDEPT t
               join D_V_TRANSINVDEPT_SPECS ts on t.ID = ts.PID
               @if (:OEI) {
                    left join D_V_NOMMODIF_PACKING np on np.PID = ts.NOMMODIF_ID
               @}
               join D_V_GOODPARTY gp on gp.ID = ts.GOODPARTY_ID
               join D_V_LPU l on l.ID = t.LPU
         where (instr(';'||:ID||';',';'||t.ID||';') > 0)
              --and ts.STATUS = 1
           order by LAT_NAME
		   
        ]]>
        <component cmptype="Variable" name="LPU"  src="LPU"  srctype="session"/>
        <component cmptype="Variable" name="ID"   src="ID"   srctype="var" get="g0"/>
        <component cmptype="Variable" name="LANG" src="LANG" srctype="var" get="g1"/>
        <component cmptype="Variable" name="SPP"  src="SPP"  srctype="var" get="g2"/>
        <component cmptype="Variable" name="OEI"  src="OEI"  srctype="var" get="g3"/>
        <component cmptype="Variable" name="SES"  src="SES"   srctype="var" get="g4"/>
		
    </component>
	
	
	<component cmptype="DataSet" name="DS_AGENTS" activateoncreate="false">
        <![CDATA[
		
        select d_stragg_ex(d_tp_stragg_rec(a.fullname,', ','ASC',null,null)) SESION
        from d_v_users a 
        where instr (';'||:SES||';',';'||a.ID||';') != 0
        ]]>
        <component cmptype="Variable" name="SES" get="v3" src="SES" srctype="var" />
		</component>
	
    <table class="form-table" style="width:100%;">
       
        <tr>
            <td cmptype="tmp" name="VALID" style="width: 75%; text-align: center;">
                <component cmptype="Label" caption="ТРЕБОВАНИЕ № " style="font-weight: bold;"/> <component cmptype="Label" captionfield="VALID_NUMB" style="font-weight: bold;"/> <component cmptype="Label" caption=" от " style="font-weight: bold;"/><component cmptype="Label" captionfield="VALID_DATE"  style="font-weight: bold;" />
            </td>
            <td style="width: 25%;">
                <component cmptype="Label" style="font-size: 8pt; text-align: left;" caption=""/>
            </td>
        </tr>
        <tr>
            <td style="width: 75%; text-align: center;">
                <component cmptype="Label" caption="НАКЛАДНАЯ № " style="font-weight: bold;" name="REP_TITLE"/><component cmptype="Label" captionfield="NUMB" style="font-weight: bold;"/> <span name="DOC_DATE"><component cmptype="Label" caption=" от " style="font-weight: bold;"/><component cmptype="Label" captionfield="DOC_DATE" style="font-weight: bold;"/></span>
            </td>
            <td style="width: 25%;"></td>
        </tr>
    </table>

    <table class="form-table" style="width:100%;">
        <tr>
            <td colspan="3" style="width:90%;"><br/> </td>
            <td style="border: 1px solid black; text-align: center;width:10%;"> </td>
        </tr>
        <tr>
            <td style="width:30%; text-align: left;">Учреждение:</td>
            <td style="width:45%;border-bottom: 1px solid black;"> <component cmptype="Label" captionfield="FULLNAME"/> </td>
            <td style="width:15%; text-align: right;">Форма по ОКУД</td>
            <td style="border: 3px solid black; border-bottom: 1px solid black; text-align: center;"> 0504204 </td>
			
        </tr>
		<tr>
            <td style="width:30%; text-align: left;">Структурное подразделение отправитель :</td>
            <td style="width:45%;border-bottom: 1px solid black;"> <component cmptype="Label" captionfield="STORE_NAME"/> </td>
            <td style="width:15%; text-align: right;"></td>
            <td style="border: 3px solid black; border-bottom: 1px solid black; text-align: center;"> </td>
			
        </tr>
		<tr>
            <td style="width:30%; text-align: left;">Структурное подразделение получатель :</td>
            <td style="width:45%;border-bottom: 1px solid black;"> <component cmptype="Label" captionfield="IN_STORE_NAME"/> </td>
            <td style="width:15%; text-align: right;">Форма по ОКЕИ</td>
            <td style="border: 3px solid black; border-bottom: 1px solid black; text-align: center;">383 </td>
			
        </tr>
       
    </table>
    <br/>
    
    <table>
	<tr>
            <td style="width:12%;text-align:right;font-size:8pt;">
                <b> Затребовал: </b> 
            </td>
            <td style="border-bottom: 1px solid black;text-align: left;">
			<component cmptype="Label" captionfield="POST" /> <component cmptype="Label" captionfield="PERSON"/> <component cmptype="Label" captionfield="DOV"/></td>
            <td></td>
            <td style="border-bottom: 1px solid black;"></td>
            <td></td>
            <td style="border-bottom: 1px solid black;"></td>
            <td></td>
            <td style="text-align:right;font-size:8pt;">
			    <b> Разрешил: </b></td>
            <td style="border-bottom: 1px solid black;"><component cmptype="Label" captionfield="HEADDOCTOR_FULLNAME"/></td>
            <td></td>
            <td style="border-bottom: 1px solid black;"></td>
            <td></td>
            <td style="border-bottom: 1px solid black;"></td>
        </tr>
        <tr style="height: 3mm;">
            <td></td>
            <td style="font-size:6pt;text-align:center;">(должность)</td>
            <td></td>
            <td style="font-size:6pt;text-align:center;"></td>
            <td></td>
            <td style="font-size:6pt;text-align:center;">(Фамилия, инициалы)</td>
            <td></td>
            <td></td>
            <td style="font-size:6pt;text-align:center;">(должность)</td>
            <td></td>
            <td style="font-size:6pt;text-align:center;"></td>
            <td></td>
            <td style="font-size:6pt;text-align:center;">(Фамилия, инициалы)</td>
        </tr>
       
    </table>
    
    <br/>
    <table class="table1">
        <tr style="text-align:center;">
            <td colspan="2">
                Корреспонди- <br/> рующий счёт
            </td>
            <td colspan="2">
                Материальные ценности
            </td>
            <td name="MEAS_UNIT" rowspan="2">
                Еди- <br/> ница <br/> изме- <br/>рения
            </td>
            <td colspan="2">
                Количество
            </td>
            <td  rowspan="2">
                Цена, <br/> руб.коп.
            </td>
            <td  rowspan="2">
                Сумма, <br/> руб. коп.
            </td>
            <td  rowspan="2">
                <component cmptype="Label" caption="Срок годности" name="EXP_DATE"/>
            </td>
        </tr>
        <tr style="text-align:center;">
            <td>
                счёт, <br/> субсчёт
            </td>
            <td>
                код <br/> аналит. <br/> учёта
            </td>
            <td>
                наименование
            </td>
            <td name="PARTY_SER">
                серия партии
            </td>
            <td>
                затребовано
            </td>
            <td>
                отпущено
            </td>
        </tr>
        <tr name="NUMB_COLUMNS" style="text-align:center;">
            <td>
                1
            </td>
            <td>
                2
            </td>
            <td>
                3
            </td>
            <td>
                4
            </td>
            <td>
                5
            </td>
            <td>
                6
            </td>
            <td>
                7
            </td>
            <td>
                8
            </td>
            <td>
                9
            </td>
            <td>
                10
            </td>
        </tr>
        <tr dataset="DS_TRANS_DEP" repeate="0" keyfield="NOMMODIF_ID" onclone="base().setCount(_dataArray);" onshow="setCaption('COUNT_QUANT_IN_MAIN_P',parseToRussianFormat(Form.COUNT_QUANT_IN_MAIN1,Form.aFlag));setCaption('COUNT_QUANT_IN_MAIN_P2',parseToRussianFormat(Form.COUNT_QUANT_IN_MAIN1,Form.aFlag));setCaption('COUNT_SUMM',parseToRussianFormat(Form.COUNT_SUMM,2));">
            <td>
            </td>
            <td style="text-align: right;">
                <component style="font-size: 8pt; " cmptype="Label" name="COUNTi" captionfield="COUNTi"/>
            </td>
            <td style="text-align: left;">
                <component style="font-size: 8pt;  text-align: left;" cmptype="Label" captionfield="LAT_NAME"/>
            </td>
            <td style="text-align: center;">
                <component style="font-size: 8pt; " cmptype="Label" captionfield="PARTY_SER"/>
            </td>
            <td name="MAIN_MEAS" style="text-align: center;">
                <component style="font-size: 8pt; " cmptype="Label" captionfield="MAIN_MEAS"/>
            </td>
            <td style="text-align: right;">
                <component style="font-size: 8pt;  " cmptype="Label" captionfield="QUANT_IN_MAIN1" name="QUANT_IN_MAIN1"/>
            </td>
            <td style="text-align: right;">
                <component style="font-size: 8pt; " cmptype="Label" captionfield="QUANT_IN_MAIN1" name="QUANT_IN_MAIN2"/>
            </td>
            <td style=" text-align: right;width:65px;">
                <component style="font-size: 8pt;" cmptype="Label" captionfield="QUANT_IN_MAIN_SUMM" name="QUANT_IN_MAIN_SUMM"/>
            </td>
            <td style=" text-align: right;width:65px;">
                <component style="font-size: 8pt;" cmptype="Label" captionfield="SUMM" name="SUMM"/>
            </td>
            <td style="text-align: right;">
                <component style="font-size: 8pt; " cmptype="Label" captionfield="EXPIRATION_DATE" name="EXPIRATION_DATE"/>
            </td>
        </tr>
        <tr  style="font-weight: bold;">
            <td colspan="3" class="td1"></td>
            <td colspan="2" class="td1">Итого:</td>
            <td class="td1">
                <component style="font-size: 7pt;text-align: right;" cmptype="Label" name="COUNT_QUANT_IN_MAIN_P"/>
            </td>
            <td class="td1">
                <component style="font-size: 7pt;text-align: right;" cmptype="Label" name="COUNT_QUANT_IN_MAIN_P2"/>
            </td>
            <td class="td1"  colspan="2" style="text-align: right;">
                <component style="font-size: 7pt;" cmptype="Label" name="COUNT_SUMM"/>
            </td>
            <td class="td1"></td>
        </tr>
    </table>

   <br/><br/>
    <table class="form-table" style="width:100%; padding:2px;">
        <colgroup>
            <col/>
            <col width="17%"/>
            <col />
            <col width="15%"/>
            <col/>
            <col width="12%"/>
            <col/>
            <col/>
            <col width="17%"/>
            <col/>
            <col width="15%"/>
            <col/>
            <col width="12%"/>
        </colgroup>
        <tr>
            <td style="width:12%;text-align:right;font-size:8pt;">
                <b> Отпустил: </b>
            </td>
            <td style="border-bottom: 1px solid black;"><component cmptype="Label" name="JOB" captionfield="JOB"/></td>
            <td></td>
            <td style="border-bottom: 1px solid black;"></td>
            <td></td>
            <td style="border-bottom: 1px solid black;"><component cmptype="Label" name="SES" captionfield="SES"/></td>
            <td></td>
            <td style="text-align:right;font-size:8pt;">
			     <b> Ответственный исполнитель : </b></td>
            <td style="border-bottom: 1px solid black;"><component cmptype="Label" name="JOB" captionfield="JOB"/></td>
            <td></td>
            <td style="border-bottom: 1px solid black;"></td>
            <td></td>
            <td style="border-bottom: 1px solid black;"><component cmptype="Label" name="SES" captionfield="SES"/></td>
           
        </tr>
        <tr style="height: 3mm;">
            <td></td>
            <td style="font-size:6pt;text-align:center;">должность</td>
            <td></td>
            <td style="font-size:6pt;text-align:center;">подпись</td>
            <td></td>
            <td style="font-size:6pt;text-align:center;">расшифровка подписи</td> 
            <td></td>
            <td></td>
            <td style="font-size:6pt;text-align:center;">должность</td>
            <td></td>
            <td style="font-size:6pt;text-align:center;">подпись</td>
            <td></td>
            <td style="font-size:6pt;text-align:center;">расшифровка подписи</td> 
        </tr>
		<tr>
            <td style="width:12%;text-align:right;font-size:8pt;">
                <b> Получил: </b>
            </td>
            <td style="border-bottom: 1px solid black;"><component cmptype="Label" name="JOB_PERSON" captionfield="JOB_PERSON"/></td>
            <td></td>
            <td style="border-bottom: 1px solid black;"></td>
            <td></td>
            <td style="border-bottom: 1px solid black;"><component cmptype="Label" captionfield="PERSON"/> <component cmptype="Label" captionfield="DOV"/></td>
            <td><component cmptype="Label" class="botdiv" captionfield="SESION" dataset="DS_AGENTS" /></td>
		
        
            
            
        </tr>
        <tr style="height: 3mm;">
            <td></td>
            <td style="font-size:6pt;text-align:center;">должность</td>
            <td></td>
            <td style="font-size:6pt;text-align:center;">подпись</td>
            <td></td>
            <td style="font-size:6pt;text-align:center;">расшифровка подписи</td>
            <td></td>
            
        </tr>



		
<!--         <tr cmptype="tmp" name="PHARMACY">
            <td style="text-align:right;font-size:8pt;"><b> Зав. аптекой: </b></td>
            <td style="border-bottom: 1px solid black;"></td>
            <td></td>
            <td style="border-bottom: 1px solid black;"></td>

            <td></td>
            <td style="border-bottom: 1px solid black;text-align:center;">
                <component cmptype="Label" captionfield="ZAV" before_caption="/" after_caption="/" style="font-weight: bold; font-size:8pt;"/>
            </td>
            <td></td>
            <td style="text-align:right;font-size:8pt;"><b> Бухгалтер аптеки: </b></td>
            <td style="border-bottom: 1px solid black;"></td>
            <td></td>
            <td style="border-bottom: 1px solid black;"></td>
            <td></td>
            <td style="border-bottom: 1px solid black;text-align:center;">
                <component cmptype="Label" captionfield="BUH" before_caption="/" after_caption="/" style="font-weight: bold; font-size:8pt;"/>
            </td>
        </tr>
        <tr cmptype="tmp" name="PHARMACY_SIGN" style="height: 3mm;">
            <td></td>
            <td style="font-size:6pt;text-align:center;">должность</td>
            <td></td>
            <td style="font-size:6pt;text-align:center;">подпись</td>
            <td></td>
            <td style="font-size:6pt;text-align:center;">расшифровка подписи</td>
            <td></td>
            <td></td>
            <td style="font-size:6pt;text-align:center;">должность</td>
            <td></td>
            <td style="font-size:6pt;text-align:center;">подпись</td>
            <td></td>
            <td style="font-size:6pt;text-align:center;">расшифровка подписи</td>
        </tr> --> 
		<!-- SD#982 -->
    </table>

    <table class="t" >
    <tr>
    <td colspan="2" style="text-align:right;font-size:11pt;" >  Отметка бухгалтерии </td>
    </tr>
    <tr >
    <td colspan="2" style="text-align:right;font-size:10pt;">  в журнале  операций за </td>
    <td class="spase"> </td>
    <td class="ramkatd"><component cmptype="Label" captionfield="DAY"/>.<component cmptype="Label" captionfield="MONTH"/>  </td>
    <td class="spase"> </td>
    <td class="ramkatd"> <component cmptype="Label" captionfield="YEAR"/> год. </td>
    
    </tr>
    <tr >
    <td> Исполнитель </td ><td class="ramkatd"> <component cmptype="Label" name="EMPLOYER_FIO_SES"/></td>
    <td class="spase"> </td>
    <td class="ramkatd">  <component cmptype="Label" name="EMPLOYER_JOB_SES"/> </td>
    <td class="spase"> </td>
    <td class="ramkatd">  </td>
    </tr>


    <tr >
    
    <td class="spase">" </td>
    <td class="ramkatd"><component cmptype="Label" captionfield="DAY"/></td>
    <td class="spase">" </td>
    <td class="ramkatd"><component cmptype="Label" captionfield="MONTH"/>  </td>
    <td class="spase"> </td>
    <td class="ramkatd"><component cmptype="Label" captionfield="YEAR"/> год. </td>
    </tr>

    </table>


    <style>
    
    .ramkatd
    {
    border-bottom: 1px solid black;
    width: 100px;
    text-align:center;
    }

    .spase {
        width: 10px;
        text-align:right;
    }

    .t
    {
       
        position: relative;
        top: -30px; z-index: 1; 
        left: 1000px; z-index:1;
         border: 4px solid black; 
        border-collapse: separate;
        border-spacing: 5px;
        border-style: dashed;
}
        
       
        
   
    </style>
</div>