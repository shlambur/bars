<div cmptype="Form"  oncreate="base().onCreate();" window_size="210mmx297mm" >

   <component cmptype="Script">
        <![CDATA[
           
            
                
                Form.onCreate = function(){
		        setCaption('PD_DATE', $_GET['DATE']);
                setVar('PD_DATE', $_GET['DATE']);
   	               };
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
                      };
             ]]>

</component>

<component cmptype="DataSet" name="DS_STAC_ANALIZ">
    <![CDATA[
            select   
    lr_j.research_date RESEARCH_REG ,
    lp.pick_date RESEARCH_DATE,
    lr_j.research_name,
    lr_sp.str_value,
    lp.patient,
    
    (select count(*) 
    from(select lr_sp.str_value 
      from D_V_LABMED_RSRCH_JOUR lr_j
 join D_V_LABMED_RSRCH_JOURSP lr_sp on lr_j.ID = lr_sp.PID
 join D_V_LABMED_PATJOUR lp on lp.ID = lr_j.PATJOUR
 join D_V_DIRECTION_SERVICES ds on ds.ID = lp.DIRECTION_SERVICE

    where lr_j.research in ('14660','14780','14800')
    and ds.serv_status ='1'
  
    and lr_sp.val_result = '1'
    and lr_j.research_date >= :PD_DATE
     and lr_sp.str_value like 'Положительный')) as POL,
    
    
     ( select count(*)  as Total
             from (
    select   
    lr_j.research_date RESEARCH_REG ,
    lp.pick_date RESEARCH_DATE,
    lr_j.research_name,
    lr_sp.str_value,
    lp.patient


 from D_V_LABMED_RSRCH_JOUR lr_j
 join D_V_LABMED_RSRCH_JOURSP lr_sp on lr_j.ID = lr_sp.PID
 join D_V_LABMED_PATJOUR lp on lp.ID = lr_j.PATJOUR
 join D_V_DIRECTION_SERVICES ds on ds.ID = lp.DIRECTION_SERVICE

    where lr_j.research in ('14660','14780','14800')
    and ds.serv_status ='1'
   
    and lr_sp.val_result = '1'
    and lr_j.research_date >= :PD_DATE  )) as total


 from D_V_LABMED_RSRCH_JOUR lr_j
 join D_V_LABMED_RSRCH_JOURSP lr_sp on lr_j.ID = lr_sp.PID
 join D_V_LABMED_PATJOUR lp on lp.ID = lr_j.PATJOUR
 join D_V_DIRECTION_SERVICES ds on ds.ID = lp.DIRECTION_SERVICE

    where lr_j.research in ('14660','14780','14800')
    and ds.serv_status ='1'
    
    and lr_sp.val_result = '1'
    and lr_j.research_date >= :PD_DATE
              
        ]]>
        
        <component cmptype="Variable" name="PD_DATE" src="PD_DATE" srctype="var" get="pd_date"/>
       
</component>


<div DataSet="DS_STAC_ANALIZ" class="div" >
    <component cmptype="Label" caption="Отчёт сформирован  c "/>  <component cmptype="Label" name="PD_DATE"/><br/><component cmptype="Label" caption="  по текущую дату  "/>
</div>

<div DataSet="DS_STAC_ANALIZ" onclone="base().setCountAll()">
<table   class="TCOV"  style="width: 100%;" > 
    <tr>
<td class="tdn" ><component cmptype="Label" caption="№ П/П"/></td> 
<td class="tdsh" ><component cmptype="Label" caption="Дата забора   "/></td> 
<td class="tdsh" ><component cmptype="Label" caption="Дата проведения исследования "/></td> 
<td  class="tdsh"><component cmptype="Label" caption="Наименование исследования"/></td>
<td  class="tdsh"><component cmptype="Label" caption="Пациент"/></td> 
<td  class="tdsh"><component cmptype="Label" caption="Результат исследования"/></td>
    </tr >
        <tr dataset="DS_STAC_ANALIZ" repeate="0" onclone="base().setCount()" >
        <td class="tdn"><component cmptype="Label" name="COUNTi" captionfield="COUNTi" /></td>
        <td class="td"><component cmptype="Label" name="RESEARCH_DATE" captionfield="RESEARCH_REG" /></td>
        <td class="td"><component cmptype="Label" name="RESEARCH_DATE" captionfield="RESEARCH_DATE" /></td>
        <td class="td"><component cmptype="Label" name="RESEARCH_NAME" captionfield="RESEARCH_NAME" /></td>
        <td class="td"><component cmptype="Label" name="PATIENT" captionfield="PATIENT" /></td>
        <td class="td"><component cmptype="Label" name="STR_VALUE" captionfield="STR_VALUE" /></td>

        </tr>
</table>
<div  class="div">  <component cmptype="Label" caption=" Проведено тестов с подозрением  на  CoV2 :"/>
<component cmptype="Label" name="TOTAL" captionfield="TOTAL" />
&#160; &#160; &#160;
<component cmptype="Label" caption=" Положительных тестов:"/>
<component cmptype="Label" name="POL" captionfield="POL" />
</div>


<style>
    .TCOV {
    border: 1px solid black;
    font-family: 'Times New Roman', Times, serif;
    margin-top: 10px;
    margin-bottom: 20px;
    }
    .td  {
        border: 1px solid black;
        padding: 8px;  
        width: 18%;

    }
    .tdsh  {
        border: 1px solid black;
        font-weight: 600;
        padding: 8px;  
        width: 18%;
        

    }
    .tdn  {
        border: 1px solid black;
        font-weight: 500;
        padding: 8px;  
        width: 8%;
        text-align: center;
        
    }
    .div {
        font-family: 'Times New Roman', Times, serif;
        font-size: 20px;
        font-weight: 600;

    }  

    
    </style>

</div>





 

</div>