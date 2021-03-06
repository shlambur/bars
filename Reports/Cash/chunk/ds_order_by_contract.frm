<div cmtype="ds">
<component cmptype="DataSet" name="DS_CASH">
<![CDATA[select t.PAY_DATE,
               t.SURNAME || ' ' || t.FIRSTNAME || ' ' || t.LASTNAME FIO,
                t.BIRTHDATE,
               t.SERVICE_NAME,
               t.SERVICE_CODE,
               (select v.EMPLOYER_FIO_TO
                  from d_v_direction_services v
                 where v.ID = t.DIR_SERV_ID) EMPLOYER_FIO_TO,
               t.CONTRACT_FULL_NUMB,
               t.SUMM SUMM,
               t.CASH_DEP_ID
          from d_v_rep_sys_cash t
         where (trunc(t.PAY_DATE)>=to_date(:DATE_B,'dd.mm.yyyy') and trunc(t.PAY_DATE)<=to_date(:DATE_E,'dd.mm.yyyy'))
           and (t.CASH_SECTION_ID = :CASH_SECTION or :CASH_SECTION = to_number(-1))
           and t.LPU = :LPU
         order by t.CONTRACT_PREF,
                  t.CONTRACT_NUMB,
                  t.SURNAME,
                  t.FIRSTNAME,
                  t.LASTNAME,
                  t.PAY_DATE,
                  t.SERVICE_NAME,
                  t.BIRTHDATE]]>
	<component cmptype="Variable" name="CASH_SECTION"  get="cash_sect" src="CASH_SECTION" srctype="var"/>
	<component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
	<component cmptype="Variable" name="DATE_B" get="date_b" src="DATE_B" srctype="var"/>
	<component cmptype="Variable" name="DATE_E" get="date_e" src="DATE_E" srctype="var"/>
</component>
</div>