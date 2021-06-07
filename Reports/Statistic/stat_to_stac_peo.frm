<div cmptype="Form"  oncreate="base().onCreate();"  window_size="210mmx297mm" >

    <component cmptype="Script">
        <![CDATA[
        Form.onCreate = function() {
            setCaption('PD_DATE', $_GET['SDATE']);
            setVar('PD_DATE', $_GET['SDATE']);
            setCaption('PD_DDATE', $_GET['TODATE']);
            setVar('PD_DDATE',$_GET['TODATE']);
         /*   setCaption('PRICE_ALL', 0); /* задать начальные значения итоговой строки */
           /* setCaption('COUNT_ALL', 0);*/
            executeAction('AddOneAction', function() {
                refreshDataSet('DS_STAC');
                 refreshDataSet('DS_DEPS');
            }, function() {
                alert('Error');
            });
        };

        Form.count = 0;
        Form.countAll = 0;
        Form.setCount = function(row, data) {
            /* вызывается для каждой строки */
            console.log('просто посмотреть данные ', Form.count, ' строки: ', row, data);
            Form.count++;
            $$(row); /* замыкание области видимости метода setCaption на текущей строке */
            setCaption('COUNTi', Form.count);
            _$$();
          /*  var priceNumeric = data['PRICE'].replace(',', '.'); /* у JS дробный делитель точка, у Oracle запятая 
            setCaption('PRICE_ALL', +getCaption('PRICE_ALL') + +priceNumeric);*/
        };

     /*   Form.setCountAll = function() {
            /* вызывается один раз после отработки всего датасета 

            setCaption('COUNT_ALL', Form.count);
        };*/
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
      select   to_char(DEP)||': '||to_char(sum(price)) as SUMDEPS
            
            from D_V_REP_RENDERING_JOURNAL_PAY$
           where PAY_DATE >= :PD_DATE
             and PAY_DATE <= :PD_DDATE
              group by   dep
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
        ]]>
        <component cmptype="Variable" name="PD_DATE" src="PD_DATE" srctype="var" get="pd_date"/>
        <component cmptype="Variable" name="PD_DDATE" src="PD_DDATE" srctype="var" get="pd_ddate"/>
    </component>


    <div class="div" >
        <component cmptype="Label" caption="Отчёт сформирован  c "/> <component cmptype="Label" name="PD_DATE"/>
        <component cmptype="Label" caption=" по "/>  <component cmptype="Label" name="PD_DDATE"/>

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
           <!-- <tr>
                <td class="tdn"><component cmptype="Label" name="COUNT_ALL" /></td>
                <td class="td"><component cmptype="Label" name="PAY_DATE_ALL" /></td>
                <td class="td"><component cmptype="Label" name="STATUS_ALL"  /></td>
                <td class="td"><component cmptype="Label" name="PATIENT_ALL"  /></td>
                <td class="td"><component cmptype="Label" name="EMPLOYER_ALL"  /></td>
                <td class="td"><component cmptype="Label" name="SERVICE_CODE_ALL"  /></td>
                <td class="td"><component cmptype="Label" name="SERVICE_NAME_ALL"  /></td>
                <td class="td"><component cmptype="Label" name="PRICE_ALL"  /></td>
                <td class="td"><component cmptype="Label" name="DEP_ALL"  /></td>
            </tr> -->
        </table>
    </div>
<div class="div" >
    <p>Общая сумма: <component cmptype="Label" name="SUM_TOTAL" /></p>
</div>
    <Table dataset="DS_DEPS" repeate="0"  style="width: 100%;" > 
 <tr>
     <td  class="tdn" style="width: 20%;" ><component cmptype="Label" caption="Сумма по отделению "/></td> 
      <td class="tdn" style="width: 80%;"> <component cmptype="Label"  name="SUMDEPS" captionfield="SUMDEPS"  /></td>
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
            width: 18%;
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







