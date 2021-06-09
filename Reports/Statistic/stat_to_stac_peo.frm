<div cmptype="Form"  oncreate="base().onCreate();"  window_size="210mmx297mm" >

    <component cmptype="Script">
        <![CDATA[
        Form.onCreate = function() {
            setCaption('PD_DATE', $_GET['SDATE']);
            setVar('PD_DATE', $_GET['SDATE']);
            setCaption('PD_DDATE', $_GET['TODATE']);
            setVar('PD_DDATE',$_GET['TODATE']);
           /*  setCaption('DEPSS', $_GET['DEPSS']);
            setVar('DEPSS', $_GET['DEPSS']); */
            console.log('Посмотреть данные ',$_GET);

            executeAction('AddOneAction', function() {
            refreshDataSet('DS_STAC');
            refreshDataSet('DS_DEPS');
            refreshDataSet('DS_PROC');
            refreshDataSet('DS_USLUGI');
            }, 
            function() {alert('Error');
            });
        };

            Form.count = 0;
            Form.countAll = 0;
            Form.setCount = function(row, data) {
         
            
            Form.count++;
            $$(row); 
            setCaption('COUNTi', Form.count);
            _$$();
      
        };
        ]]>
    </component>
    <component cmptype="Action" name="AddOneAction">
        <![CDATA[
        begin
            select sum(price)
            into :SUM_TOTAL
            from D_V_REP_RENDERING_JOURNAL_PAY$
            where PAY_DATE >= :PD_DATE
            and PAY_DATE <= :PD_DDATE;
        end;
      ]]>
        <component cmptype="ActionVar" name="SUM_TOTAL" src="SUM_TOTAL" srctype="ctrlcaption" put="SUM_TOTAL" len="17"/>
        <component cmptype="ActionVar" name="PD_DATE" src="PD_DATE" srctype="var" get="PD_DATE" />
        <component cmptype="ActionVar" name="PD_DDATE" src="PD_DDATE" srctype="var" get="PD_DATE2" />
    </component>


    <component cmptype="DataSet" name="DS_DEPS" activateoncreate="false">
        <![CDATA[
            select 
            to_char(DEP)||': '||to_char(sum(price)) as SUMDEPS
            from D_V_REP_RENDERING_JOURNAL_PAY$
            where PAY_DATE >= :PD_DATE
            and PAY_DATE <= :PD_DDATE
            group by  dep
      ]]>
        <component cmptype="Variable" name="PD_DATE" src="PD_DATE" srctype="var" get="PD_DATE" />
        <component cmptype="Variable" name="PD_DDATE" src="PD_DDATE" srctype="var" get="PD_DATE2" />
    </component>
<!-- Первый запрос по услугам -->
<component cmptype="DataSet" name="DS_PROC" activateoncreate="false">
        <![CDATA[
SELECT
    level,
    id,
    pid,
    title,
    kol,
    summa
        FROM
            ( select
            case when  dep_id  is null then 10531 else dep_id end as id,
            null as pid,
            case when  dep  is null then 'Касса' else dep end as Title,
            count(*) as kol,
            sum(price) as summa
                    FROM D_V_REP_RENDERING_JOURNAL_PAY$
            where service_code in
            ('1.039','1.039.1','1.041','1.033','1.035','В008','3025','1.044','1.045','A14.30.019','A14.30.019.02',
            'A14.30.019.03','A14.30.019.04','A14.30.019.05','A14.30.019.06','A14.30.019.07','A14.30.019.08','A14.30.019.09','A14.30.019.10','A14.30.019.11','A14.30.019.12','A14.30.019.13')
            and PAY_DATE >= :PD_DATE  and PAY_DATE <= :PD_DDATE
            group by case when  dep  is null then 'Касса' else dep end,case when  dep_id  is null then 10531 else dep_id end,null
        union all
            select null,
            case when  dep_id  is null then 10531 else dep_id end,
            service_name,
            count(*),
            sum(price)
            FROM D_V_REP_RENDERING_JOURNAL_PAY$
            where service_code in
            ('1.039','1.039.1','1.041','1.033','1.035','В008','3025','1.044','1.045','A14.30.019','A14.30.019.02',
            'A14.30.019.03','A14.30.019.04','A14.30.019.05','A14.30.019.06','A14.30.019.07','A14.30.019.08','A14.30.019.09','A14.30.019.10','A14.30.019.11','A14.30.019.12','A14.30.019.13')
            and PAY_DATE >= :PD_DATE  and PAY_DATE <= :PD_DDATE
            group by service_name,case when  dep_id  is null then 10531 else dep_id end
            ) s
            START WITH pid is null
            CONNECT BY PRIOR id = pid

            
           
      ]]>
        <component cmptype="Variable" name="PD_DATE" src="PD_DATE" srctype="var" get="PD_DATE" />
        <component cmptype="Variable" name="PD_DDATE" src="PD_DDATE" srctype="var" get="PD_DATE2" />
    </component>
<!-- Второй запрос по услугам  -->
    <component cmptype="DataSet" name="DS_USLUGI" activateoncreate="false">
        <![CDATA[
SELECT
    level,
    id,
    pid,
    title as USLUGI,
    kol as KOLUS,
    summa SUMMAUS
        FROM
            ( select
            case when  dep_id  is null then 10531 else dep_id end as id,
            null as pid,
            case when  dep  is null then 'Касса' else dep end as Title,
            count(*) as kol,
            sum(price) as summa
                    FROM D_V_REP_RENDERING_JOURNAL_PAY$
            where service_code  not in
            ('1.039','1.039.1','1.041','1.033','1.035','В008','3025','1.044','1.045','A14.30.019','A14.30.019.02',
            'A14.30.019.03','A14.30.019.04','A14.30.019.05','A14.30.019.06','A14.30.019.07','A14.30.019.08','A14.30.019.09','A14.30.019.10','A14.30.019.11','A14.30.019.12','A14.30.019.13')
            and PAY_DATE >= :PD_DATE  and PAY_DATE <= :PD_DDATE
            group by case when  dep  is null then 'Касса' else dep end,case when  dep_id  is null then 10531 else dep_id end,null
        union all
            select null,
            case when  dep_id  is null then 10531 else dep_id end,
            service_name,
            count(*),
            sum(price)
            FROM D_V_REP_RENDERING_JOURNAL_PAY$
            where service_code not in
            ('1.039','1.039.1','1.041','1.033','1.035','В008','3025','1.044','1.045','A14.30.019','A14.30.019.02',
            'A14.30.019.03','A14.30.019.04','A14.30.019.05','A14.30.019.06','A14.30.019.07','A14.30.019.08','A14.30.019.09','A14.30.019.10','A14.30.019.11','A14.30.019.12','A14.30.019.13')
            and PAY_DATE >= :PD_DATE  and PAY_DATE <= :PD_DDATE
            group by service_name,case when  dep_id  is null then 10531 else dep_id end
            ) s
            START WITH pid is null
            CONNECT BY PRIOR id = pid

            
           
      ]]>
        <component cmptype="Variable" name="PD_DATE" src="PD_DATE" srctype="var" get="PD_DATE" />
        <component cmptype="Variable" name="PD_DDATE" src="PD_DDATE" srctype="var" get="PD_DATE2" />
    </component>


    <component cmptype="DataSet" name="DS_STAC" activateoncreate="false">
        <![CDATA[
               select t.PAY_DATE PAY_DATE,
                    t.STATUS_MNEMO STATUS,
                    t.PATIENT PATIENT,
                    t.JOURNAL_EMPLOYER EMPLOYER,
                    t.SERVICE_CODE,
                    t.SERVICE_NAME SERVICE_NAME,
                    t.PRICE,
                    t.DEP
               from D_V_REP_RENDERING_JOURNAL_PAY$ t
               where PAY_DATE >= :PD_DATE
                and PAY_DATE <= :PD_DDATE
            -- and dep = :DEPSS
        ]]>
        <component cmptype="Variable" name="PD_DATE" src="PD_DATE" srctype="var" get="pd_date"/>
        <component cmptype="Variable" name="PD_DDATE" src="PD_DDATE" srctype="var" get="pd_ddate"/>
       -- <component cmptype="Variable" name="DEPSS" src="DEPSS" srctype="var" get="DEPSS"/>
    </component>


    <div class="div" >
        <component cmptype="Label" caption="Отчёт сформирован  c "/> <component cmptype="Label" name="PD_DATE"/>
        <component cmptype="Label" caption=" по "/>  <component cmptype="Label" name="PD_DDATE"/>
<component cmptype="Label" caption=" по "/>  <component cmptype="Label" name="DEPSS"/>
    </div>

    <div  >
        <table   style="width: 100%;" >
            <tr>
                <td class="tdn" ><component cmptype="Label" caption="№ П/П"/></td>
                <td class="tdn" ><component cmptype="Label" caption="Дата оплаты"/></td>
                <td class="tdn" ><component cmptype="Label" caption="Статус оказания"/></td>
                <td class="tdn" ><component cmptype="Label" caption="Пациент"/></td>
                <td class="tdn" ><component cmptype="Label" caption="Врач"/></td>
                <td class="tdn" ><component cmptype="Label" caption="Код услуги"/></td>
                <td class="tdn" ><component cmptype="Label" caption="Услуги"/></td>
                <td class="tdn" ><component cmptype="Label" caption="Сумма "/></td>
                <td class="tdn" ><component cmptype="Label" caption="Отделение "/></td>
            </tr>
            <tr dataset="DS_STAC" repeate="0" onclone="base().setCount(this, _dataArray)" afterrefresh="base().setCountAll();">
                <td class="tdn"><component cmptype="Label" name="COUNTi" captionfield="COUNTi" /></td>
                <td class="td"><component cmptype="Label" name="PAY_DATE" captionfield="PAY_DATE" /></td>
                <td class="td"><component cmptype="Label" name="STATUS" captionfield="STATUS" /></td>
                <td class="td"><component cmptype="Label" name="PATIENT" captionfield="PATIENT" /></td>
                <td class="td"><component cmptype="Label" name="EMPLOYER" captionfield="EMPLOYER" /></td>
                <td class="td"><component cmptype="Label" name="SERVICE_CODE" captionfield="SERVICE_CODE" /></td>
                <td class="td"><component cmptype="Label" name="SERVICE_NAME" captionfield="SERVICE_NAME" /></td>
                <td class="td"><component cmptype="Label" name="PRICE" captionfield="PRICE" /></td>
                <td class="td"><component cmptype="Label" name="DEP" captionfield="DEP" /></td>
            </tr>
        
        </table>
    </div>
<div class="div">
    <p>Общая сумма: <component cmptype="Label" name="SUM_TOTAL" /></p>
</div>
    <Table dataset="DS_DEPS" repeate="0"  style="width: 100%;" > 
 <tr>
     <td  class="tdn" style="width: 20%;"><component cmptype="Label" caption="Сумма по отделению "/></td> 
      <td class="tdn" style="width: 40%;"><component cmptype="Label"  name="SUMDEPS" captionfield="SUMDEPS"  /></td>
 </tr>
    </Table>

    <div class="div">

         Отделения  по которым назначены и оплачены процедуры.
    </div>

<Table dataset="DS_PROC"   style="width: 100%;" > 
<tr>
        <td  class="tdsh" style="width: 60%;"><component cmptype="Label" caption=" Отделение\процедцра"/></td>
        <td  class="tdsh" style="width: 20%;"><component cmptype="Label" caption="Количество "/></td> 
        <td  class="tdsh" style="width: 20%;"><component cmptype="Label" caption="Сумма "/></td> 
    </tr>
</Table>


    <Table dataset="DS_PROC" repeate="0"  style="width: 100%;" > 
 <tr>
     
      <td class="tdn" style="width: 60%;"><component cmptype="Label"  name="TITLE" captionfield="TITLE"  /></td>
      <td class="tdn" style="width: 20%;"><component cmptype="Label"  name="KOL" captionfield="KOL"  /></td>
      <td class="tdn" style="width: 20%;"><component cmptype="Label"  name="SUMMA" captionfield="SUMMA"  /></td>
 </tr>
    </Table>

    <div class="div">

        Услуги по отделениям
    </div>

<Table dataset="DS_USLUGI"   style="width: 100%;" > 
<tr>
        <td  class="tdsh" style="width: 60%;"><component cmptype="Label" caption=" Отделение\процедцра"/></td>
        <td  class="tdsh" style="width: 20%;"><component cmptype="Label" caption="Количество "/></td> 
        <td  class="tdsh" style="width: 20%;"><component cmptype="Label" caption="Сумма "/></td> 
    </tr>
</Table>


    <Table dataset="DS_USLUGI" repeate="0"  style="width: 100%;" > 
 <tr>
     
      <td class="tdn" style="width: 60%;"><component cmptype="Label"  name="USLUGI" captionfield="USLUGI"  /></td>
      <td class="tdn" style="width: 20%;"><component cmptype="Label"  name="KOLUS" captionfield="KOLUS"  /></td>
      <td class="tdn" style="width: 20%;"><component cmptype="Label"  name="SUMMAUS" captionfield="SUMMAUS"  /></td>
 </tr>
    </Table>
    



    <style>
        .tcov {
            border: 1px solid black;
            font-family: 'Times New Roman', Times, serif;
            margin-top: 10px;
            margin-bottom: 20px;
        }
        .td {
            border: 1px solid black;
            padding: 8px;
            width: 18%;

        }
        .tdsh {
            border: 1px solid black;
            font-weight: 600;
            padding: 8px;
            text-align: center;
        }
        .tdn {
            border: 1px solid black;
            font-weight: 500;
            padding: 8px;
            width: 8%;
            text-align: center;
        }
        .div {
            padding: 20px;
            font-family: 'Times New Roman', Times, serif;
            font-size: 20px;
            font-weight: 600;

        }

    </style>

</div>







