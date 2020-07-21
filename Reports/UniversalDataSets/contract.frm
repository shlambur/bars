<div cmptype="Form">
    <component cmptype="IncludeFile" type="js" src="System/js/number_to_string"/>
    <component cmptype="Script" name="Script">
        <![CDATA[
            Form.ContrPaySetTextSumm = function(ds_name) {
                var ds = getDataSet(ds_name, false),
                    servise_name = '';
                if (typeof(ds) != 'undefined' && typeof(ds.data) != 'undefined') {
                    for (var i = 0; i < ds.data.length; i++) {
                        for (var k in ds.data[i]) {
                            var io = k.indexOf('_TEXT');
                            if (io == (k.length - 5) && (k.substr(0, io) in ds.data[i])) {
                                var num_str = ds.data[i][k.substr(0, io)];
                                ds.data[i][k] = number_to_string(num_str);
                            }
                        }
                        servise_name += ((servise_name != '') ? ', ' : '') + ds.data[i]['SERVICE_NAME'];
                    };
                    setVar('servise_name', servise_name);
                    refreshDataSet('TEMP_PAYMENT');
                }
            };
        ]]>
    </component>
    <component cmptype="DataSet" name="TEMP_PAYMENT" compile="true">
        <![CDATA[
            select :servise_name SERVICE_NAME,
                   to_char(sysdate,'dd.mm.yyyy') CURR_DATE
            from dual 
        ]]>
        <component cmptype="Variable" name="servise_name" src="servise_name" srctype="var" get="v1"/>
    </component>
    <component cmptype="DataSet" name="payments" compile="true">
        <![CDATA[
        select *
          from (
         select ROW_NUMBER() over(order by c.DOC_NUMB, c.DOC_PREF) RN,
                c.DOC_NUMB,
                c.DOC_PREF,
                c.CONTRACT_SUMM,
                t.SERVICE_NAME,
                t.SERVICE,
                t.ID,
                t.QUANT,
                t.PRICE,
                c.DOC_DATE,
                c.DATE_BEGIN,
                c.DATE_END,
                c.PERSON,
                trunc(t.PRICE) PRICE_INT,
                (t.PRICE - trunc(t.PRICE))*100 PRICE_FLOAT,
                t.DIR_SUMM,
                '' DIR_SUMM_TEXT,
                sum(t.DIR_SUMM) over(partition by t.PID) DIR_SUMM_ALL,
                t.DISCOUNT_SUMM,
                '' DISCOUNT_SUMM_TEXT,
                sum(t.DISCOUNT_SUMM) over(partition by t.PID) DISCOUNT_SUMM_ALL,
                '' DISCOUNT_SUMM_ALL_TEXT,
                round(case when t.DISCOUNT_SUMM is not null  and t.DISCOUNT_SUMM!=0 then
                  t.DISCOUNT_SUMM/t.DIR_SUMM*100
                else 0
                end,2) DISCOUNT_PROCENT,
                t.DIR_SUMM - t.DISCOUNT_SUMM SUMM,
                '' SUMM_TEXT,
                sum(t.DIR_SUMM - t.DISCOUNT_SUMM) over(partition by t.PID) SUMM_ALL,
                '' SUMM_ALL_TEXT
           from D_V_CONTRACT_PAYMENTS t
                join D_V_CONTRACTS c on c.ID  = t.PID
          where t.PID = :CONTRACT_ID
          @if (:CONTR_PAY_ID) {
            and instr(';'||:CONTR_PAY_ID||';',';'||t.ID ||';') != 0
           @}
         order by c.DOC_NUMB, c.DOC_PREF
         ) t
         ]]>
        <component cmptype="Variable" name="CONTRACT_ID" src="CONTRACT_ID" srctype="var" get="v1"/>
        <component cmptype="Variable" name="CONTR_PAY_ID" src="CONTR_PAY_ID" srctype="var" get="v2"/>
    </component>
    <component cmptype="DataSet" name="contract_payments" compile="true">
        select case when t.SUMM_SERV    is null then 0 else t.SUMM_SERV    end SUMM_SERV,
               case when t.SUMM_SERV_NO is null then 0 else t.SUMM_SERV_NO end SUMM_SERV_NO,
               case when t.PAYMENT      is null then 0 else t.PAYMENT     end PAYMENT,
               case when t.REFUND       is null then 0 else t.REFUND       end REFUND,
               t.SUMM_SERV_TEXT,
               t.SUMM_SERV_NO_TEXT,
               t.PAYMENT_TEXT,
               t.REFUND_TEXT
               
          from (select sum(case when rj.STATUS = 1 and pj.OPER_TYPE = 0 then pjcp.PAY_SUMM end)  SUMM_SERV,
                       ''                                                                        SUMM_SERV_TEXT,
                       sum(case when rj.STATUS != 1 and pj.OPER_TYPE = 0 then pjcp.PAY_SUMM end) SUMM_SERV_NO,
                       ''                                                                        SUMM_SERV_NO_TEXT,
                       sum(case when pj.OPER_TYPE = 0 then pjcp.PAY_SUMM end)                    PAYMENT,
                       ''                                                                        PAYMENT_TEXT,
                       sum(case when pj.OPER_TYPE != 0 then pjcp.PAY_SUMM end)                   REFUND,
                       ''                                                                        REFUND_TEXT
                  from D_V_CONTRACT_PAYMENTS t
                       join D_V_RJ_FACC_PAYMENTS rfp on rfp.CONTRACT_PAYMENT = t.ID
                            join D_V_RJ_FAC_ACCOUNTS rfa on rfa.ID = rfp.PID
                                 join D_V_RENDERING_JOURNAL rj on rj.ID  = rfa.PID
                       join D_V_PJ_CON_PAYMENTS pjcp on pjcp.CONTRACT_PAYMENT = t.ID
                            join D_V_PAYMENT_JOURNAL pj on pj.ID = pjcp.PID
                 where t.PID = :CONTRACT_ID
                @if (:CONTR_PAY_ID) {
                   and instr(';'||:CONTR_PAY_ID||';', ';'||t.ID||';') != 0
                @}
               ) t
        <component cmptype="Variable" name="CONTRACT_ID"  src="CONTRACT_ID"  srctype="var" get="CONTRACT_ID"/>
        <component cmptype="Variable" name="CONTR_PAY_ID" src="CONTR_PAY_ID" srctype="var" get="CONTR_PAY_ID"/>
    </component>
    <component cmptype="DataSet" name="payments_cons" compile="true">
        <![CDATA[
         select ROW_NUMBER() over(order by sc.ID) RN,
                sc.SERVICE_CODE,
                sc.SERVICE_NAME,
                sc.QUANT as CONS_QUANT,
                sc.PRICE as CONS_PRICE,
                sc.SUMM as CONS_SUMM,
                round(case when sc.SUMM is not null and sc.QUANT != 0 then
                                sc.SUMM / sc.QUANT
                           else 0
                      end, 2) as CONS_SERV_PRICE,
                round(case when sum(sc.SUMM) over (partition by sc.PID) is not null and sc.QUANT != 0 then
                                sum(sc.SUMM) over (partition by sc.PID) / sc.QUANT
                           else 0
                      end, 2) as SERV_COST
           from D_V_CONTRACT_SERVICE_CONS sc
          where sc.PID = :CONTRACT_ID
        @if(:CONTR_PAY_ID) {
            and exists (select null
                          from D_V_CONTRACT_PAYMENTS v
                         where v.ID = :CONTR_PAY_ID
                           and v.PID = sc.PID)
        @}
        ]]>
        <component cmptype="Variable" name="CONTRACT_ID" src="CONTRACT_ID" srctype="var" get="v1"/>
        <component cmptype="Variable" name="CONTR_PAY_ID" src="CONTR_PAY_ID" srctype="var" get="v2"/>
    </component>
    <component cmptype="DataSet" name="payments_by_all">
        <![CDATA[
            select ROW_NUMBER() over(order by c.DOC_NUMB, c.DOC_PREF) RN,
                   c.DOC_NUMB,
                   c.DOC_PREF,
                   c.CONTRACT_SUMM,
                   t.SERVICE_NAME,
                   t.SERVICE,
                   t.ID,
                   t.QUANT,
                   t.PRICE,
                   c.DOC_DATE,
                   c.DATE_BEGIN,
                   c.DATE_END,
                   pj.PAY_DATE,
                   trunc(PJ.PAY_DATE) PAY_DATE,
                   trunc(t.PRICE) PRICE_INT,
                   (t.PRICE - trunc(t.PRICE))*100 PRICE_FLOAT,
                   t.DIR_SUMM,
                   '' DIR_SUMM_TEXT,
                   sum(t.DIR_SUMM) over(partition by t.PID) DIR_SUMM_ALL,
                   t.DISCOUNT_SUMM,
                   '' DISCOUNT_SUMM_TEXT,
                   sum(t.DISCOUNT_SUMM) over(partition by t.PID) DISCOUNT_SUMM_ALL,
                   '' DISCOUNT_SUMM_ALL_TEXT,
                   round(case when t.DISCOUNT_SUMM is not null  and t.DISCOUNT_SUMM!=0 then
                     t.DISCOUNT_SUMM/t.DIR_SUMM*100
                   else 0
                   end,2) DISCOUNT_PROCENT,
                   t.DIR_SUMM - t.DISCOUNT_SUMM SUMM,
                   '' SUMM_TEXT,
                   sum(t.DIR_SUMM - t.DISCOUNT_SUMM) over(partition by t.PID) SUMM_ALL,
                   '' SUMM_ALL_TEXT
              from D_V_CONTRACT_PAYMENTS t
                   join D_V_CONTRACTS c on c.ID  = t.PID
                   join D_V_RJ_FACC_PAYMENTS rfp on rfp.CONTRACT_PAYMENT = t.ID
                            join D_V_RJ_FAC_ACCOUNTS rfa on rfa.ID = rfp.PID
                                 join D_V_RENDERING_JOURNAL rj on rj.ID  = rfa.PID
                       join D_V_PJ_CON_PAYMENTS pjcp on pjcp.CONTRACT_PAYMENT = t.ID
                            join D_V_PAYMENT_JOURNAL pj on pj.ID = pjcp.PID
             where t.PID = :CONTRACT_ID
            order by c.DOC_NUMB, c.DOC_PREF
        ]]>
        <component cmptype="Variable" name="CONTRACT_ID" src="CONTRACT_ID" srctype="var" get="v0"/>
    </component>
    <component cmptype="DataSet" name="payments_by_ami" compile="true">
        <![CDATA[
            select ROW_NUMBER() over(order by c.DOC_NUMB, c.DOC_PREF) RN,
                   cad.DIR_FULL_NAME,
                   cad.CARD_NUMB,
                   cad.PATIENT_SURNAME,
                   cad.PATIENT_FIRSTNAME,
                   cad.PATIENT_LASTNAME,
                   cad.PATIENT_FIO,
                   cad.POLIS,
                   cad.D_NUMB,
                   cad.REG_DATE,
                   cad.EMPLOYER,
                   cad.EMPLOYER_FIO,
                   cad.BEGIN_DATE,
                   cad.END_DATE,
                   cad.SUMM,
                   cad.IS_ACTIVE,
                   cad.CONTRACT_AGENT_NAME,
                   cad.CONTRACT_AGENT_CODE,
                   cp.SERVICE_NAME,
                   cp.SERVICE,
                   cp.ID,
                   cp.QUANT,
                   cp.PRICE,
                   trunc(cp.PRICE) PRICE_INT,
                   (cp.PRICE - trunc(cp.PRICE))*100 PRICE_FLOAT,
                   cp.DIR_SUMM,
                   '' DIR_SUMM_TEXT,
                   sum(cp.DIR_SUMM) over(partition by cp.PID) DIR_SUMM_ALL,
                   cp.DISCOUNT_SUMM,
                   '' DISCOUNT_SUMM_TEXT,
                   sum(cp.DISCOUNT_SUMM) over(partition by cp.PID) DISCOUNT_SUMM_ALL,
                   '' DISCOUNT_SUMM_ALL_TEXT,
                   round(case when cp.DISCOUNT_SUMM is not null  and cp.DISCOUNT_SUMM!=0 then
                     cp.DISCOUNT_SUMM/cp.DIR_SUMM*100
                   else 0
                   end,2) DISCOUNT_PROCENT,
                   cp.DIR_SUMM - cp.DISCOUNT_SUMM SUMM,
                   '' SUMM_TEXT,
                   sum(cp.DIR_SUMM - cp.DISCOUNT_SUMM) over(partition by cp.PID) SUMM_ALL,
                   '' SUMM_ALL_TEXT
              from D_V_CONTRACTS c
                   join D_V_CONTR_AMI_DIRECTS cad
                     on cad.PID = c.ID
                        join D_V_CONTRACT_PAYMENTS cp
                          on cp.AMI_DIRECTION = cad.ID
             where c.CONTRACT_TYPE_CODE != 1
               and exists (select null from D_V_URPRIVS ur where ur.CATALOG = c.CID and ur.UNITCODE = 'CONTRACTS')
               and c.ID = :CONTRACT_ID
               and cad.PATIENT_ID = :PATIENT_ID
           @if (:CONTR_PAY_ID) {
               and cp.ID = :CONTR_PAY_ID
           @}
        ]]>
        <component cmptype="Variable" name="CONTRACT_ID"  src="CONTRACT_ID"  srctype="var" get="v1"/>
        <component cmptype="Variable" name="CONTR_PAY_ID" src="CONTR_PAY_ID" srctype="var" get="v2"/>
        <component cmptype="Variable" name="PATIENT_ID"   src="PATIENT_ID"   srctype="var" get="v3"/>
    </component>
    <div cmptype="tmp" dataset="payments" onrefresh="base().ContrPaySetTextSumm('payments');"/>
    <div cmptype="tmp" dataset="contract_payments" onrefresh="base().ContrPaySetTextSumm('contract_payments');"/>
    <div cmptype="tmp" dataset="TEMP_PAYMENT" repeate="1"/>
</div>