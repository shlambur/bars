<div cmptype="bogus" oncreate="base().onCreate();" onshow="base().onShow();" >
    <span style="display:none" id="PrintSetup" ps_paperData="9" ps_marginBottom="15" ps_marginRight="8" ps_marginTop="15" ps_marginLeft="15"/>
    <component cmptype="Script">
	<![CDATA[
        Form.onCreate = function () {
            if ($_GET['HH_ID'])
                setVar('ID', $_GET['HH_ID']);
            else
                setVar('ID', $_GET['ID']);
        }
        Form.refreshDSs = function () {
            if (!empty(getCaption('HOSP_RESULT'))) {
                getControlByName('text2').style.display = 'none';
            }
            if (!empty(getCaption('HOSP_OUTCOME'))) {
                getControlByName('text').style.display = 'none';
            }
            /*Обработка п17 и 18*/
            if (!empty(getVar('PNPERIODICITY'))) {
                setAttribute(getControlByName('PERIODICITY_' + getVar('PNPERIODICITY')), 'class', 'text_underline');
            } else {
                setAttribute(getControlByName('PERIODICITY_1'), 'class', 'text_underline');
            }
            if (!empty(getVar('PNHOSP_TYPE'))) {
                setAttribute(getControlByName('HOSP_TYPE_' + getVar('PNHOSP_TYPE')), 'class', 'text_underline');
            }
            if (!empty(getVar('PNINJURE_TYPE'))) {
                setAttribute(getControlByName('INJURE_TYPE_' + getVar('PNINJURE_TYPE')), 'class', 'text_underline');
            }
            if (!empty(getVar('PNINJURE_TIME'))) {
                setAttribute(getControlByName('INJURE_TIME_' + getVar('PNINJURE_TIME')), 'class', 'text_underline');
            }
            /*___________________*/
            startMultiDataSetsGroup();
                refreshDataSet('DS_HOSP_STAT_CARDS_DEPS');
                refreshDataSet('DS_HOSP_STAT_CARDS_OPERS');
                refreshDataSet('DS_VISIT_FIELDS');
            endMultiDataSetsGroup();
            setTimeout(function () {
                window.status = "PRINT";
            }, 400); // for wkhtmltopdf
        }
        ]]>
    </component>
    <component cmptype="Script" name="SCR_SHOW">
        Form.onShow = function(){
                executeAction('AC_OUTHOST',function(){
                    base().refreshDSs();
                    base().setFieldLength();
                });  
        }
        Form.setFieldLength = function(){
            //в px -> переводим в пробелы которые добъем делив на 4
            var field_len = {
                'LPU_FROM_CODE_AND_NAME': 200,
                'ADDR': 270,
                'SEND_DIAG_NAME': 300,
                'REC_DIAG_NAME': 300
                };
            for (var el in field_len){
                if (isExistsControlByName(el)){
                    setCaption(el, Form.rpad(getCaption(el), field_len[el]/4));
                }
            }
        }
        Form.rpad = function(str, len){
            for (var i=str.length;i&lt;len;i++){
                str = str + '&amp;nbsp; ';
            }
            return str;
        }
    </component>    
    <style>
        .text_underline{
            text-decoration:underline;
        }
    </style>
    <component cmptype="Action" name="AC_OUTHOST">
    <![CDATA[
        declare RELATIVE Number(17);
                HIS_ID Number(17);
                HOSP_TYPE Varchar2(100);
                HOSP_TYPE_CODE Varchar2(1);
                HL_NUMB Varchar2(20);
                CARE_HL_FIO Varchar2(200);
                DEATHDOCDATE Date;
                LPU_FROM_NAME Varchar2(250);
                HOSP_REASON Varchar2(120);
                INABILITY Varchar2(20);
                HH_NUMB_ALTERN Varchar2(50);
                HH_PREF Varchar2(10);
                MKB_MAIN_NAME_EXACT Varchar2(4000);
                MKB_MAIN_ADD1_NAME_EXACT Varchar2(4000);
                MKB_MAIN_ADD2_NAME_EXACT Varchar2(4000);
                DISEASECASE Number(17);
                PAR_FIO Varchar2(200);
                PAR_RELATIVE Varchar2(60);
                MKB_MAIN_COMP Varchar2(500);
                MKB_MAIN_COMP_CODE Varchar2(10);
                DEATHDOCTYPE_NAME Varchar2(300);
                DEATHCERTIFY_EMP_FIO Varchar2(250);
                ADDR_RAION Varchar2(100);
                WORK_RAION Varchar2(3);
                WORK_OKVED Varchar2(8);
                WORK_NAME_JOB Varchar2(1000);
                REG_LPU_NAME Varchar2(3000);
                PATIENT Number(17);
                HIS_DATE_IN Date;
                HIS_DATE_OUT Date;
                VISIT_EPIC Number(17);
                DIR_NUMB Varchar2(4000);
                AGENT Number(17);
                SSEX Varchar2(10); 
                PAY_IS_COMMERC Number(17);
                DIRECTION Number(17);
                OSOB_SL Varchar2(1000);
                HH_TYPE Number(17);
                PAR_POLIS Varchar2(1000);
                PAR_PERSDOC Varchar2(1000);
                SEND_DIAG_CODE Varchar2(10); 
                REC_DIAG_CODE Varchar2(10);
                RECEIVE_EMPLOYER_FULLNAME Varchar(200);
                HEALING_EMP Varchar2(150);
                RW_DATE Date;
                AIDS_DATE Date;
                DEATHDOCNUM Varchar2(10);
                SPECIAL_CASE Varchar2(250);
                SNILS Varchar(11);
                NHOSP_RESULT Number(17);
                CARD_NUMB Varchar2(26);
                dDATE_BEGIN Date;
                dDATE_IN Date;
                dDATE_OUT Date;  
                sSERV_EX Varchar(20); 
                IS_DEAD NUMBER(1);
       begin
            begin
                select hst.ID,
                        case when
                          hst.EX_CAUSE_MKB is not null
                          and hst.INJURE_KIND is not null
                          and hst.INJURE_TIME is not null
                          then 2 else 1
                        end,
                        case when hst.EX_CAUSE_MKB is not null 
                                  and hst.INJURE_KIND is not null 
                                  and hst.INJURE_TIME is not null 
                             then -- с начала травмы
                            case when hst.INJURE_TIME < 7 then 1
                                 when hst.INJURE_TIME < 25 then 2
                                 when hst.INJURE_TIME > 24 then 3
                                 else null 
                             end
                        else      -- с начала заболевания
                            case when hst.HOSP_HOUR_ID in (0,1,2) then 1
                                 when hst.HOSP_HOUR_ID in (3,4,5) then 2
                                 when hst.HOSP_HOUR_ID in (6) then 3
                                 else null 
                            end
                        end
                  into :HST_ID,
                       :PNINJURE_TYPE,
                       :PNHOSP_HOUR
                  from D_V_HOSP_STAT_CARDS      hst
                 where hst.HOSP_HISTORY=:ID;
                 exception when NO_DATA_FOUND then d_P_EXC('Стат.карта не найдена.');
            end;
            begin
             D_P_REP_OUTHOSP_STAT_CARD(
                pnID                                 =>:HST_ID,       
                pnLPU                                =>:LPU ,
                pnHOSP_RESULT                        =>NHOSP_RESULT,
                pnRELATIVE                           =>RELATIVE,
                pnHIS_ID                             =>HIS_ID,      
                psHISTORY_NUMB                       =>:HISTORY_NUMB,
                pnFACT_COUNT                         =>:FACT_COUNT,
                pnINJURE_TIME                        =>:INJURE_TIME,
                psHOSP_TYPE                          =>HOSP_TYPE,
                psHOSP_TYPE_CODE                     =>HOSP_TYPE_CODE,
                pdHL_DATE_OPEN                       =>:HL_DATE_OPEN,
                pdHL_DATE_CLOSE                      =>:HL_DATE_CLOSE,
                pdDATE_OUT                           =>dDATE_OUT,
                psHL_NUMB                            =>HL_NUMB,
                pdRW_DATE                            =>RW_DATE,
                pdAIDS_DATE                          =>AIDS_DATE,
                psCARE_HL_FIO                        =>CARE_HL_FIO,
                pnCARE_HL_AGE                        =>:CARE_HL_AGE,
                psCARE_HL_SEX                        =>:CARE_HL_SEX,
                psIS_WELL_TIMED_HOSP                 =>:IS_WELL_TIMED_HOSP,
                psIS_ENOUGH_VOLUME                   =>:IS_ENOUGH_VOLUME,
                psIS_CORRECT_HEALING                 =>:IS_CORRECT_HEALING,
                psIS_SAME_DIAGN                      =>:IS_SAME_DIAGN,
                pdDEATHDOCDATE                       =>DEATHDOCDATE,
                psDEATHDOCNUM                        =>DEATHDOCNUM,
                psPERIODICITY                        =>:PERIODICITY,
                psLPU_FROM_NAME                      =>LPU_FROM_NAME,
                psLPU_FROM_CODE_AND_NAME             =>:LPU_FROM_CODE_AND_NAME,
                psHOSP_REASON                        =>HOSP_REASON, 
                psINJURE_KIND                        =>:INJURE_KIND, 
                pnAGENT                              =>AGENT,
                psCARD_NUMB                          =>CARD_NUMB,
                psSPECIAL_CASE                       =>SPECIAL_CASE,
                psPERS_CATEGORY                      =>:PERS_CATEGORY,
                psINABILITY                          =>INABILITY, 
                psLPU                                =>:SLPU, 
                psHH_NUMB_ALTERN                     =>HH_NUMB_ALTERN,
                psHH_PREF                            =>HH_PREF,
                psMKB_MAIN_NAME_EXACT                =>MKB_MAIN_NAME_EXACT,
                psMKB_MAIN_ADD1_NAME_EXACT           =>MKB_MAIN_ADD1_NAME_EXACT,
                psMKB_MAIN_ADD2_NAME_EXACT           =>MKB_MAIN_ADD2_NAME_EXACT,
                pnDISEASECASE                        =>DISEASECASE,
                psSNILS                              =>SNILS,
                psFIO                                =>:FIO,
                psSEX                                =>SSEX,
                pnSEX                                =>:NSEX,
                pdBIRTHDATE                          =>:BIRTHDATE,
                psPAR_FIO                            =>PAR_FIO, 
                psPAR_RELATIVE                       =>PAR_RELATIVE,
                psSEND_DIAG_NAME                     =>:SEND_DIAG_NAME,
                psSEND_DIAG_CODE                     =>SEND_DIAG_CODE ,
                psREC_DIAG_NAME                      =>:REC_DIAG_NAME,
                psREC_DIAG_CODE                      =>REC_DIAG_CODE,
                psRECEIVE_EMPLOYER                   =>:RECEIVE_EMPLOYER,
                psRECEIVE_EMPLOYER_FULLNAME          =>RECEIVE_EMPLOYER_FULLNAME,
                psMKB_MAIN_NAME                      =>:MKB_MAIN_NAME,
                psMKB_MAIN_CODE                      =>:MKB_MAIN_CODE,
                psMKB_MAIN_COMP                      =>MKB_MAIN_COMP,
                psMKB_MAIN_COMP_CODE                 =>MKB_MAIN_COMP_CODE, 
                psMKB_MAIN_ADD1_NAME                 =>:MKB_MAIN_ADD1_NAME,
                psMKB_MAIN_ADD1_CODE                 =>:MKB_MAIN_ADD1_CODE,
                psMKB_MAIN_ADD2_NAME                 =>:MKB_MAIN_ADD2_NAME,
                psMKB_MAIN_ADD2_CODE                 =>:MKB_MAIN_ADD2_CODE,
                psMKB_PAT_NAME                       =>:MKB_PAT_NAME,
                psMKB_PAT_CODE                       =>:MKB_PAT_CODE,
                psMKB_PAT_ADD1_NAME                  =>:MKB_PAT_ADD1_NAME,
                psMKB_PAT_ADD1_CODE                  =>:MKB_PAT_ADD1_CODE,
                psMKB_PAT_ADD2_NAME                  =>:MKB_PAT_ADD2_NAME,
                psMKB_PAT_ADD2_CODE                  =>:MKB_PAT_ADD2_CODE,
                psDEATHDOCTYPE_NAME                  =>DEATHDOCTYPE_NAME,
                psDEATHCERTIFY_EMP_FIO               =>DEATHCERTIFY_EMP_FIO,
                psDOC_SER                            =>:DOC_SER,
                psDOC_NUMB                           =>:DOC_NUMB,
                psDOC_TYPE                           =>:DOC_TYPE,
                psPOLIS_SER                          =>:POLIS_SER,
                psPOLIS_NUMB                         =>:POLIS_NUMB,
                psPOLIS_WHO                          =>:POLIS_WHO,
                psSITIZEN                            =>:SITIZEN,
                psADDR                               =>:ADDR,
                psADDR_RAION                         =>ADDR_RAION,
                psWORK_RAION                         =>WORK_RAION,
                psWORK_OKVED                         =>WORK_OKVED,
                psWORK_NAME_JOB                      =>WORK_NAME_JOB,
                psREG_LPU_NAME                       =>REG_LPU_NAME, 
                psSOC_NAME_CODE                      =>:SOC_NAME_CODE,
                psDEP_IN                             =>:DEP_IN,
                psHEALING_EMP                        =>HEALING_EMP,
                psPAY_NAME_CODE                      =>:PAY_NAME_CODE,
                psHOSP_RESULT                        =>:HOSP_RESULT,
                pnPATIENT                            =>PATIENT,
                pdHIS_DATE_IN                        =>HIS_DATE_IN,
                pdHIS_DATE_OUT                       =>HIS_DATE_OUT,
                pdDATE_IN                            =>dDATE_IN,
                pnVISIT_EPIC                         =>VISIT_EPIC,
                psHOSP_OUTCOME_NAME                  =>:HOSP_OUTCOME, 
                psDIR_NUMB                           =>DIR_NUMB,
                pdDATE_BEGIN                         =>dDATE_BEGIN,
                psPOLIS_KLADR                        =>:POLIS_KLADR,
                pnPAY_IS_COMMERC                     =>PAY_IS_COMMERC,
                pnDIRECTION                          =>DIRECTION,
                psOSOB_SL                            =>OSOB_SL,
                pnHH_TYPE                            =>HH_TYPE,
                psPAR_POLIS                          =>PAR_POLIS, 
                psPAR_PERSDOC                        =>PAR_PERSDOC
             );
             :MKB_MAIN_ADD2_CODE := REPLACE(:MKB_MAIN_ADD2_CODE,',',', ');
             :MKB_MAIN_ADD2_NAME := REPLACE(:MKB_MAIN_ADD2_NAME,',',', ');
             :MKB_MAIN_ADD1_CODE := REPLACE(:MKB_MAIN_ADD1_CODE,',',', ');
            if trim(:LPU_FROM_CODE_AND_NAME) is null
            then :LPU_FROM_CODE_AND_NAME := :sLPU;
            end if;
            if :NSEX is not null then 
               select decode(:NSEX, 0, 'Ж', 1, 'М') into :NSEX from dual;
            end if;
            :TIME_OUT:=TO_CHAR(dDATE_OUT,'hh24:mi');
            :DATE_OUT:=TO_CHAR(dDATE_OUT,'dd.mm.yyyy');
            :TIME_IN:=TO_CHAR(dDATE_IN,'hh24:mi');
            :DATE_IN:=TO_CHAR(dDATE_IN,'dd.mm.yyyy');
            :TIME_BEGIN:=TO_CHAR(dDATE_BEGIN,'hh24:mi');
            :DATE_BEGIN:=TO_CHAR(dDATE_BEGIN,'dd.mm.yyyy');
            select decode(:SITIZEN,'Да','город','Нет','село','') into :SITIZEN from dual;
            select D_PKG_AGENT_ADDRS.GET_ACTUAL_ON_DATE(AGENT,dDATE_OUT,1,'CITY_KLADR') into :CITY_KLADR from dual;
            :PAY_NAME_CODE:=SUBSTR(:PAY_NAME_CODE,0,instr(:PAY_NAME_CODE,' ',-1));
            select D_PKG_AGENT_ADDRS.GET_ACTUAL_ON_DATE(AGENT,sysdate,0,'FULL') into :ADDR from dual;
            
            /*Достанем данные по регистрации*/
            sSERV_EX := D_PKG_OPTIONS.GET('EmergencyService', :LPU);
            :REP_VISIT_ID := null;
              if sSERV_EX is not null then
                  begin
                    select t3.ID into :REP_VISIT_ID
                      from D_V_HPK_PLAN_JOURNALS  t1,
                           D_V_DIRECTIONS         t2,
                           D_V_VISITS             t3,
                           D_V_DIRECTION_SERVICES t4,
                           D_V_VISIT_FIELDS       t5
                     where t1.HOSP_HISTORY= :ID
                       and t2.ID          = t1.DIRECTION
                       and t3.ID          = t2.REG_VISIT_ID
                       and t4.ID          = t3.PID
                       and t4.SERVICE     = sSERV_EX
                       and t3.ID          = t5.PID
                       and rownum = 1;
                  exception when no_data_found then null;
                  end;
              end if;
            end;--Достанем данные по регистрации
            begin
                /*Выводим состояние опьянение*/
                :HOSP_TYPE_CODE := '';
                if HOSP_TYPE_CODE = '3' then
                    :HOSP_TYPE_CODE := '1';
                end if;
                if HOSP_TYPE_CODE = '4' then
                    :HOSP_TYPE_CODE := '2';
                end if;    
            end;
            begin
                :pnPERIODICITY:='';
                if lower(:PERIODICITY) like '%первично%' then :pnPERIODICITY:=1; end if;
                if lower(:PERIODICITY) like '%повторно%' then :pnPERIODICITY:=2; end if;
            end;
            begin
                :pnHOSP_TYPE:='';
                if HOSP_TYPE_CODE in (2,3,4) then
                    :pnHOSP_TYPE:='1';
                end if;
                if HOSP_TYPE_CODE ='1' then
                    :pnHOSP_TYPE:='2';
                end if;
            end;
            begin
                select
                    case when sf1.VISIT_ID is null then
                        case when sf2.VISIT_ID is not null then
                            D_PKG_VISIT_FIELDS.GET_VALUE(sf2.VISIT_ID,:LPU, 'DATE_HIV')
                        end
                    else D_PKG_VISIT_FIELD_CONTS.GET_VALUES(sf1.VISIT_ID, :LPU, 'RW','RW_DATE')
                    end RW_DATE,
                    case when sf1.VISIT_ID is null then
                        case when sf2.VISIT_ID is not null then
                            D_PKG_VISIT_FIELDS.GET_VALUE(sf2.VISIT_ID,:LPU, 'DATE_HBS')
                        end
                    else D_PKG_VISIT_FIELD_CONTS.GET_VALUES(sf1.VISIT_ID, :LPU, 'HBS_BER','HBS_DATE')
                    end AIDS_DATE
                into
                    :RW_DATE,
                    :AIDS_DATE
                from 
                    D_V_HOSP_HISTORIES t,
                    (
                        select 
                            dsm.DISEASECASE  DISC,
                            vm.ID VISIT_ID,
                            row_number() over( partition by dsm.DISEASECASE order by vm.VISIT_DATE desc) RN
                        from D_V_DIRECTION_SERVICES dsm,
                            D_V_VISITS vm,
                            D_V_VISIT_TEMPLATES vtm
                        where vm.PID = dsm.ID
                        and vtm.ID = vm.VISIT_TEMPLATE_ID
                        and vtm.VT_CODE = 'STAC_PREG_FIRST'
                    ) sf1,
                    (
                        select 
                            dsm.DISEASECASE  DISC,
                            vm.ID VISIT_ID,
                            row_number() over( partition by dsm.DISEASECASE order by vm.VISIT_DATE desc) RN
                        from 
                            D_V_DIRECTION_SERVICES dsm,
                            D_V_VISITS vm,
                            D_V_VISIT_TEMPLATES vtm
                        where vm.PID = dsm.ID
                        and vtm.ID = vm.VISIT_TEMPLATE_ID
                        and vtm.VT_CODE = 'STAC_FIRST'
                     ) sf2
                where t.ID = :ID
                  and sf1.DISC(+) = t.DISEASECASE
                  and sf2.DISC(+) = t.DISEASECASE
                  and sf1.rn(+)=1
                  and sf2.rn(+)=1;
            end;
            begin
              select case when d.OUTER_DIRECTION_ID is not null 
                          then od.D_PREF||' '||od.D_NUMB
                          else d.DIR_PREF||' '||d.DIR_NUMB
                      end,
                     case when d.OUTER_DIRECTION_ID is not null 
                          then to_char(od.D_DATE, D_PKG_STD.FRM_D)
                          else to_char(d.REG_DATE, D_PKG_STD.FRM_D)
                      end
                into :DIRECTION_NUMBER,
                     :DIRECTION_DATE
                from D_V_HPK_PLAN_JOURNALS  hpj,
                     D_V_DIRECTIONS         d,
                     D_V_OUTER_DIRECTIONS od
               where hpj.HOSP_HISTORY = :ID
                 and d.ID = hpj.DIRECTION
                 and od.ID(+) = d.OUTER_DIRECTION_ID;
            exception when OTHERS then
              null;
            end;
            :MKB_PAT_NAME1:=:MKB_PAT_NAME;
            :MKB_PAT_CODE1:=:MKB_PAT_CODE;
            if (:MKB_PAT_CODE is null) then
                select count(1)
                into IS_DEAD
                from D_V_HOSP_RESULTS t
               where instr(';'||D_PKG_OPTIONS.GET('HHRESULT_DEAD',:LPU)||';',';'||t.R_CODE||';') > 0
               and t.id=NHOSP_RESULT;
                if (IS_DEAD>0)then
                    :MKB_PAT_NAME1:=:MKB_MAIN_NAME;
                    :MKB_PAT_CODE1:=:MKB_MAIN_CODE;
                end if;
            end if;
        end;
    ]]>  
      <component cmptype="ActionVar" name="HST_ID"                 put="hst_id" src="HST_ID"                 srctype="var"         len="17"/>  
      <component cmptype="ActionVar" name="LPU"                                 src="LPU"                    srctype="session"/>
      <component cmptype="ActionVar" name="ID"                     get="v2"     src="ID"                     srctype="var"         len="17"/>
      <component cmptype="ActionVar" name="POLIS_SER"              put="v4"     src="POLIS_SER"              srctype="ctrlcaption" len="30"/>
      <component cmptype="ActionVar" name="POLIS_NUMB"             put="v5"     src="POLIS_NUMB"             srctype="ctrlcaption" len="40"/>
      <component cmptype="ActionVar" name="POLIS_WHO"              put="v6"     src="POLIS_WHO"              srctype="ctrlcaption" len="260"/>
      <component cmptype="ActionVar" name="FIO"                    put="v7"     src="FIO"                    srctype="ctrlcaption" len="500"/>
      <component cmptype="ActionVar" name="BIRTHDATE"              put="v8"     src="BIRTHDATE"              srctype="ctrlcaption" len="100"/>
      <component cmptype="ActionVar" name="ADDR"                   put="v9"     src="ADDR"                   srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="SOC_NAME_CODE"          put="v10"    src="SOC_NAME_CODE"          srctype="ctrlcaption" len="260"/>
      <component cmptype="ActionVar" name="PERS_CATEGORY"          put="v11"    src="PERS_CATEGORY"          srctype="ctrlcaption" len="460"/>
      <component cmptype="ActionVar" name="PERIODICITY"            put="v12"    src="PERIODICITY"            srctype="var" len="50"/>
      <component cmptype="ActionVar" name="LPU_FROM_CODE_AND_NAME" put="v13"    src="LPU_FROM_CODE_AND_NAME" srctype="ctrlcaption" len="310"/>
      <component cmptype="ActionVar" name="SEND_DIAG_NAME"         put="v14"    src="SEND_DIAG_NAME"         srctype="ctrlcaption" len="500"/>  
      <component cmptype="ActionVar" name="REC_DIAG_NAME"          put="v16"    src="REC_DIAG_NAME"          srctype="ctrlcaption" len="500"/>
      <component cmptype="ActionVar" name="DATE_IN"                put="v17"    src="DATE_IN"                srctype="ctrlcaption" len="50"/>
      <component cmptype="ActionVar" name="FACT_COUNT"             put="v18"    src="FACT_COUNT"             srctype="ctrlcaption" len="500"/>
      <component cmptype="ActionVar" name="DEP_IN"                 put="v19"    src="DEP_IN"                 srctype="ctrlcaption" len="200"/>
      <component cmptype="ActionVar" name="INJURE_TIME"            put="v20"    src="INJURE_TIME"            srctype="var" len="50"/>
      <component cmptype="ActionVar" name="RECEIVE_EMPLOYER"       put="v21"    src="RECEIVE_EMPLOYER"       srctype="ctrlcaption" len="200"/>
      <component cmptype="ActionVar" name="DATE_OUT"               put="v23"    src="DATE_OUT"               srctype="ctrlcaption" len="50"/>
      <component cmptype="ActionVar" name="HISTORY_NUMB"           put="v24"    src="HISTORY_NUMB"           srctype="ctrlcaption" len="60"/>  
      <component cmptype="ActionVar" name="HOSP_RESULT"            put="v22"    src="HOSP_RESULT"            srctype="ctrlcaption" len="560"/>
      <component cmptype="ActionVar" name="HL_DATE_OPEN"           put="v25"    src="HL_DATE_OPEN"           srctype="ctrlcaption" len="50"/>
      <component cmptype="ActionVar" name="HL_DATE_CLOSE"          put="v26"    src="HL_DATE_CLOSE"          srctype="ctrlcaption" len="50"/>
      <component cmptype="ActionVar" name="CARE_HL_AGE"            put="v27"    src="CARE_HL_AGE"            srctype="ctrlcaption" len="17"/>
      <component cmptype="ActionVar" name="CARE_HL_SEX"            put="v28"    src="CARE_HL_SEX"            srctype="ctrlcaption" len="1"/>
      <component cmptype="ActionVar" name="IS_WELL_TIMED_HOSP"     put="v29"    src="IS_WELL_TIMED_HOSP"     srctype="ctrlcaption" len="100"/>
      <component cmptype="ActionVar" name="IS_ENOUGH_VOLUME"       put="v30"    src="IS_ENOUGH_VOLUME"       srctype="ctrlcaption" len="100"/>       
      <component cmptype="ActionVar" name="IS_SAME_DIAGN"          put="v31"    src="IS_SAME_DIAGN"          srctype="ctrlcaption" len="100"/>
      <component cmptype="ActionVar" name="IS_CORRECT_HEALING"     put="v32"    src="IS_CORRECT_HEALING"     srctype="ctrlcaption" len="100"/>
      <component cmptype="ActionVar" name="INJURE_KIND"            put="v33"    src="INJURE_KIND"            srctype="ctrlcaption" len="100"/>
      <component cmptype="ActionVar" name="MKB_MAIN_NAME"          put="v34"    src="MKB_MAIN_NAME"          srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="MKB_MAIN_CODE"          put="v35"    src="MKB_MAIN_CODE"          srctype="ctrlcaption" len="100"/>
      <component cmptype="ActionVar" name="MKB_MAIN_ADD1_NAME"     put="v36"    src="MKB_MAIN_ADD1_NAME"     srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="MKB_MAIN_ADD1_CODE"     put="v37"    src="MKB_MAIN_ADD1_CODE"     srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="MKB_MAIN_ADD2_NAME"     put="v38"    src="MKB_MAIN_ADD2_NAME"     srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="MKB_MAIN_ADD2_CODE"     put="v39"    src="MKB_MAIN_ADD2_CODE"     srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="MKB_PAT_NAME"           put="v40"    src="MKB_PAT_NAME"           srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="MKB_PAT_CODE"           put="v41"    src="MKB_PAT_CODE"           srctype="ctrlcaption" len="100"/>
      <component cmptype="ActionVar" name="MKB_PAT_ADD1_NAME"      put="v42"    src="MKB_PAT_ADD1_NAME"      srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="MKB_PAT_ADD1_CODE"      put="v43"    src="MKB_PAT_ADD1_CODE"      srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="MKB_PAT_ADD2_NAME"      put="v44"    src="MKB_PAT_ADD2_NAME"      srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="MKB_PAT_ADD2_CODE"      put="v45"    src="MKB_PAT_ADD2_CODE"      srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="DOC_SER"                put="v46"    src="DOC_SER"                srctype="ctrlcaption" len="20"/>
      <component cmptype="ActionVar" name="DOC_NUMB"               put="v47"    src="DOC_NUMB"               srctype="ctrlcaption" len="20"/>
      <component cmptype="ActionVar" name="DOC_TYPE"               put="v48"    src="DOC_TYPE"               srctype="ctrlcaption" len="150"/>
      <component cmptype="ActionVar" name="SITIZEN"                put="v49"    src="SITIZEN"                srctype="ctrlcaption" len="10"/>
      <component cmptype="ActionVar" name="PAY_NAME_CODE"          put="v50"    src="PAY_NAME_CODE"          srctype="ctrlcaption" len="200"/>
      <component cmptype="ActionVar" name="TIME_IN"                put="v51"    src="TIME_IN"                srctype="ctrlcaption" len="500"/>
      <component cmptype="ActionVar" name="TIME_OUT"               put="v52"    src="TIME_OUT"               srctype="ctrlcaption" len="500"/>
      <component cmptype="ActionVar" name="TIME_BEGIN"             put="v53"    src="TIME_BEGIN"             srctype="ctrlcaption" len="500"/>
      <component cmptype="ActionVar" name="HOSP_OUTCOME"           put="v54"    src="HOSP_OUTCOME"           srctype="ctrlcaption" len="600"/>
      <component cmptype="ActionVar" name="DATE_BEGIN"             put="v55"    src="DATE_BEGIN"             srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="POLIS_KLADR"            put="v56"    src="POLIS_KLADR"            srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="NSEX"                   put="v57"    src="NSEX"                   srctype="ctrlcaption" len="4000"/> 
      <component cmptype="ActionVar" name="CITY_KLADR"             put="v58"    src="CITY_KLADR"             srctype="ctrlcaption" len="50"/>
      <component cmptype="ActionVar" name="sLPU"                   put="v59"    src="LPU"                    srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="REP_VISIT_ID"           put="v60"    src="REP_VISIT_ID"           srctype="var"         len="17"/>
      <component cmptype="ActionVar" name="HOSP_TYPE_CODE"         put="v61"    src="HOSP_TYPE_CODE"         srctype="ctrlcaption" len="20"/>
      <component cmptype="ActionVar" name="RW_DATE"                put="v62"    src="RW_DATE"                srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="AIDS_DATE"              put="v63"    src="AIDS_DATE"              srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="DIRECTION_NUMBER"       put="v64"    src="DIRECTION_NUMBER"       srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="DIRECTION_DATE"         put="v65"    src="DIRECTION_DATE"         srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="MKB_PAT_NAME1"          put="v66"    src="MKB_PAT_NAME1"          srctype="ctrlcaption" len="4000"/>
      <component cmptype="ActionVar" name="MKB_PAT_CODE1"          put="v67"    src="MKB_PAT_CODE1"          srctype="ctrlcaption" len="100"/>
      
      <component cmptype="ActionVar" name="PNPERIODICITY" src="PNPERIODICITY" srctype="var" put="v68" len="2"/>
      <component cmptype="ActionVar" name="PNHOSP_TYPE"   src="PNHOSP_TYPE"   srctype="var" put="v69" len="2"/>
      <component cmptype="ActionVar" name="PNINJURE_TYPE" src="PNINJURE_TYPE" srctype="var" put="v70" len="2"/>
      <component cmptype="ActionVar" name="PNHOSP_HOUR"   src="PNINJURE_TIME" srctype="var" put="v71" len="3"/>
      
   </component>
   
<component cmptype="DataSet" name="DS_VISIT_FIELDS" columns_field="F_CODE" values_field="F_VALUE" activateoncreate="false">
    <![CDATA[
         select t.F_CODE,
                t.F_VALUE
           from D_V_VISIT_FIELDS_REP       t
          where t.PID = :REP_VISIT_ID
            and t.LPU = :LPU
    ]]>
    <component cmptype="Variable" name="REP_VISIT_ID" get="v0" src="REP_VISIT_ID" srctype="var"/>
    <component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
</component>
<component cmptype="DataSet" name="DS_HOSP_STAT_CARDS_DEPS" activateoncreate="false">
    <![CDATA[
	 select hscd.DEP,
            hscd.BED_TYPE,
            hscd.EMPLOYER,
            hscd.DATE_BEGIN,
            hscd.DATE_END,
            hscd.MKB,
            (
            select d.MES
              from D_V_HOSP_STAT_CARDS hsc
                   join D_V_HOSP_HISTORIES hh on hh.ID = hsc.HOSP_HISTORY
                   join D_V_DISEASECASES d on hh.DISEASECASE = d.ID
            where hscd.PID = hsc.ID
            ) MESES,
            hscd.PAYMENT_KIND_NAME
       from D_V_HOSP_STAT_CARDS_DEPS hscd
      where hscd.PID = :HST_ID
      order by hscd.DATE_BEGIN
    ]]>
	<component cmptype="Variable" name="HST_ID" src="HST_ID" srctype="var" get="HST_ID"/>
</component>
<component cmptype="DataSet" name="DS_HOSP_STAT_CARDS_OPERS" activateoncreate="false">
	<![CDATA[ 
		select oso.OPER_DATE,
			   to_char(oso.OPER_DATE, 'HH24:MI') OPER_TIME,
			   oso.SURGEON,
			   oso.HSTD_DEP,
			   oso.SERVICE,
			   oso.SERVICE_CODE,
			   oso.COMPLICATION,
			   oso.COMPLICATION_CODE,
			   decode(oso.ANAESTHETIZATION, 0, 'Местная', 1, 'Общая') ANAESTHETIZATION,
			   oso.PAYMENT_KIND
		  from D_V_REP_OUTHOSP_STAT_OPERS oso
		 where oso.HSTD_PID = :HST_ID
		 order by oso.OPER_DATE
	]]>
    <component cmptype="Variable" name="HST_ID" src="HST_ID" srctype="var" get="HST_ID"/>
</component>
    <table width="680px" cmptype="tmp" name="table_for_dfrm">
        <tr cmptype="tmp"  name="first_tr">
                <td width="50%" valign="top" style="text-align: center;font-size: 10px">
                    Министерство здравоохранения <br/>
                    Российской Федерации<br/>
                    <component cmptype="Label" name="LPU"/>
                    <p align="center" style="border-top: 1px solid black; margin: 0 auto; width: 270px;">
                        <font size="1"  style="font-weight:normal; ">(наименование  учреждения)</font>
                    </p>                    
                </td>
                <td width="25%" valign="top" cmptype="tmp" name="center_tr"/>
                <td width="35%" valign="top" style="font-size: 9px">
                    Приложение № 5 <br/>
                    к Приказу Минздрава России от 30.12.2002 № 413<br/>
                    Медицинская документация<br/>
                    Форма № 066/у-02<br/>
                    Утверждена Приказом Минздрава РФ<br/>
                    от 30.12.2002 № 413<br/>
                </td>
            </tr>
       </table>
       <table width="680px">
        <tr>
            <td colspan="3">
                    <component cmptype="Label"  name="HST_ID" style="display:none;"/>
                    <p style="font-size: 14px; text-align: center; font-weight: bold;" cmptype="tmp" name="REPORT_TITLE">СТАТИСТИЧЕСКАЯ КАРТА ВЫБЫВШЕГО ИЗ СТАЦИОНАРА<br/>
                    круглосуточного пребывания, дневного стационара при больничном учреждении,
                    дневного стационара при амбулаторно-поликлиническом учреждении, стационара на дому<br/>                    
                       № медицинской карты <component cmptype="Label" class="field2"  name="HISTORY_NUMB" />
                    </p>   
                       <div style="margin-top:10px;">
                            <div style="vertical-align:top; width: 300px; float: left">
                                1. Код пациента :
                                <div align="center"  style="display:inline-block; vertical-align:top;width:140px ">
                                    <component cmptype="Label" name="CARD_NUMB"  class="field"/>
                                </div>
                            </div>
                            <div name="block2" style="display:inline-block; vertical-align:top; width: 380px">
                                2. Ф.И.О.:
                                <div align="center"  style="display:inline-block; vertical-align:top;width:310px ">
                                    <component cmptype="Label"  class="field"  style="font-weight: bold;font-size: 13px" name="FIO"/>
                                </div>
                            </div>
                       </div>
                       <div style="margin-top:10px;">
                            <div style="vertical-align:top; width: 300px; float: left">
                                3. Пол: <component cmptype="Label"  class="field2"  name="NSEX" />            
                            </div>
                            <div style="display:inline-block; vertical-align:top; width: 380px">
                                4. Дата рождения                                
                                    <component cmptype="Label"  class="field2"  name="BIRTHDATE" />                                
                            </div>
                       </div>
                       <div style="margin-top:10px;">
                            <div style="vertical-align:top; width: 680px;">
                               5. Документ, удостов. личность:            
                                <component cmptype="Label" name="DOC_TYPE" class="field2" style="min-width:25mm;"/>
                                    серия <component cmptype="Label" name="DOC_SER" class="field2" style="min-width:14mm;"/>
                                    номер <component cmptype="Label" name="DOC_NUMB" class="field2" style="min-width:20mm;"/>
                            </div>
                       </div>
                       <div style="margin-top:10px;">
                            <div style="vertical-align:top; width: 680px;">
                               6. Адрес: регистрация по месту жительства <component cmptype="Label"  class="field_l"  style="min-height: 10px " name="ADDR"/>
                            </div>
                       </div>
                       <div style="margin-top:10px;">
                            <div style="vertical-align:top; min-width: 330px;float:left">
                               7. Код территории проживания: <component cmptype="Label"  class="field2" name="CITY_KLADR" />                                
                            </div>
                           <div style="display:inline-block;vertical-align:top; width: 200px">
                               Житель: <component cmptype="Label"  class="field2"  name="SITIZEN" /> 	                               
                            </div>
                       </div> 
                       <div style="margin-top:10px;">
                            <div style="vertical-align:top; width: 680px;">
                               8. Страховой полис (серия, номер):  
                                    <component cmptype="Label"  class="field2"  name="POLIS_SER" />
                                    <component cmptype="Label"  class="field2"  name="POLIS_NUMB" />
                            </div>
                            <div name="block8_2" style="vertical-align:top; width: 680px;">
                               Выдан: кем
                               <div align="center"  style="display:inline-block; vertical-align:top;min-width:300px;">
                                    <component cmptype="Label"  class="field" name="POLIS_WHO" />
                                </div>
                               Код терр.:
                               <div align="center"  style="display:inline-block; vertical-align:top;min-width:50px;">
                                    <component cmptype="Label"  class="field" name="POLIS_KLADR" />
                                </div> 
                            </div>
                       </div>
                       <div style="margin-top:10px;">
                               9. Вид оплаты: <component cmptype="Label"  class="field2" name="PAY_NAME_CODE" />                          
                      </div> 
                       <div style="margin-top:10px;">
                              10. Социальный статус: 	<component cmptype="Label" name="SOC_NAME_CODE" class="field2"/>                   
                       </div>
                       <div style="margin-top:10px;">
                            <div style="vertical-align:top;">
                              11. Категория льготности: <component cmptype="Label" name="PERS_CATEGORY" class="field2"/>                       
                            </div>
                       </div>
                        <div cmptype="tmp" name="block12" style="margin-top:10px;">
                            <div style="vertical-align:top;">
                                12. Кем направлен <component cmptype="Label" class="field_l" name="LPU_FROM_CODE_AND_NAME"/>
                                <span>
                                    <p style="display:inline;">№ напр.: </p>
                                    <u>
                                        <component cmptype="Label"  class="field2"  name="DIRECTION_NUMBER"/>
                                    </u>
                                    <p style="display:inline;">Дата: </p>
                                    <u>
                                        <component cmptype="Label"  class="field2"  name="DIRECTION_DATE"/>
                                    </u>
                                </span>
                            </div>
                       </div>
                        <div cmptype="tmp" name="block13" style="margin-top:10px;">
                               13. Кем доставлен <component cmptype="Label" class="field_l" dataset="DS_VISIT_FIELDS" name="WHOM_BROUGHT" captionfield="WHOM_BROUGHT" afterrefresh="setCaption('WHOM_BROUGHT', base().rpad(getCaption('WHOM_BROUGHT'), 30));"/> Код<component cmptype="Label" class="field_l" dataset="DS_VISIT_FIELDS" captionfield="ORDER_CODE" name="ORDER_CODE" afterrefresh="setCaption('ORDER_CODE', base().rpad(getCaption('ORDER_CODE'), 10));"/>Номер наряда<component cmptype="Label" class="field_l" dataset="DS_VISIT_FIELDS" captionfield="ORDER_NUM" name="ORDER_NUM"  afterrefresh="setCaption('ORDER_NUM', base().rpad(getCaption('ORDER_NUM'), 10));"/>
                        </div>       
                        <div style="margin-top:10px;">
                               14. Диагноз направившего учреждения <component cmptype="Label"  class="field_l"  name="SEND_DIAG_NAME" />
                       </div>
                        <div style="margin-top:10px;">
                               15. Диагноз приемного отделения <component cmptype="Label"  class="field_l"  name="REC_DIAG_NAME" />
                       </div>
                        <div style="margin-top:10px;">
                               16. Доставлен в состоянии опьянения :<component cmptype="Label" name="HOSP_TYPE_CODE" style="min-width:5mm;border-bottom:1px solid black;"/>   Алкогольного – 1;	Наркотического – 2.
                        </div>
                       <div cmptype="tmp"  name="block17" style="margin-top:10px;">
                               17. Госпитализирован по поводу данного заболевания в текущем году:
                               <component cmptype="Label" caption="первично – 1; " name="PERIODICITY_1"/>
                                <component cmptype="Label" caption="повторно – 2; " name="PERIODICITY_2"/>
                                <component cmptype="Label" caption="по экстренным показаниям – 3; " name="HOSP_TYPE_1"/>
                                <component cmptype="Label" caption="в плановом порядке – 4." name="HOSP_TYPE_2"/>                         
                       </div>
                       <div style="margin-top:10px;">
                               18. Доставлен в стационар от
                               <component cmptype="Label" caption=" начала заболевания " name="INJURE_TYPE_1"/>
                                (<component cmptype="Label" caption="получения травмы" name="INJURE_TYPE_2"/>): 
                                <component cmptype="Label" caption="в первые 6 часов – 1; " name="INJURE_TIME_1"/>
                                <component cmptype="Label" caption="в теч. 7 – 24 часов – 2;" name="INJURE_TIME_2"/>
                                <component cmptype="Label" caption="позднее 24-х часов – 3." name="INJURE_TIME_3"/>    
                       </div>
                        <div style="margin-top:10px;">
                               19. Травма:
                            <div align="center"  style="display:inline-block; vertical-align:top;min-width:50px;">
                                    <component cmptype="Label"  class="field"   name="INJURE_KIND" />
                            </div>
                       </div>
                        <div style="margin-top:10px;">
                               20. Дата поступления в приемное отделение:
                                <component cmptype="Label"  class="field2"  name="DATE_IN" />      
                                Время 
                                <component cmptype="Label"  class="field2"  name="TIME_IN" />        
                       </div>
                        <div style="margin-top:10px;" name="block21">
                               21. Название отделения
                               <component cmptype="Label"  class="field2"  name="DEP_IN" /> 
                               Дата поступления
                               <component cmptype="Label"  class="field2" name="DATE_BEGIN" />      
                               Время
                               <component cmptype="Label"  class="field2"  name="TIME_BEGIN" /> <br/>  <br/>
                               Подпись врача приемного отделения___________                               
                               Код
                               <component cmptype="Label"  class="field2"  name="RECEIVE_EMPLOYER" /> 
                       </div>
                        <div style="margin-top:10px;">
                               22. Дата выписки (смерти):
                                <component cmptype="Label"  name="DATE_OUT" class="field2"  />        
                                Время
                                <component cmptype="Label"  name="TIME_OUT" class="field2" />        
                       </div>
                        <div style="margin-top:10px;" cmptype="tmp" name="P23">
                               23. Продолжительность госпитализации (койко-дней):
                                <component cmptype="Label"  class="field2"   name="FACT_COUNT" />  
                       </div>
                        <div style="margin-top:10px;" name="block24">
                               24. Исход госпитализации:
                                <component cmptype="Label" class="field2" name="HOSP_OUTCOME"/>
                            <span name="text" cmptype="tmp" >выписан – 1; в т.ч. в дневной стационар – 2; в круглосуточный стационар – 3; переведен в другой стационар – 4;
                            </span>
                       </div>
                        <div style="margin-top:10px;" name="block24_1">
                               24.1. Результат госпитализации: 
                                <component cmptype="Label" class="field2" name="HOSP_RESULT"/>
                            <span name="text2" cmptype="tmp" >выздоровление – 1; улучшение – 2;	без перемен – 3; ухудшение – 4;	здоров – 5;	умер – 6.                               
                            </span>
                       </div>
                        <div name="block25" style="margin-top:10px;">
                               25. Листок нетрудоспособности: открыт
                               <div align="center"  style="display:inline-block; vertical-align:top;min-width:50px;">
                                    <component cmptype="Label"  class="field"   name="HL_DATE_OPEN" />
                               </div>                               
                               закрыт:
                               <div align="center"  style="display:inline-block; vertical-align:top;min-width:50px;">
                                    <component cmptype="Label"  class="field"   name="HL_DATE_CLOSE" />
                               </div>
                       </div>
                        <div style="margin-top:10px;">
                              25.1. По уходу за больным      Полных лет:
                              <div align="center"  style="display:inline-block; vertical-align:top;min-width:20px;">
                                    <component cmptype="Label"  class="field"   name="CARE_HL_AGE" />
                               </div>
                               Пол
                               <div align="center"  style="display:inline-block; vertical-align:top;min-width:20px;">
                                    <component cmptype="Label"  class="field"   name="CARE_HL_SEX" />
                               </div>
                       </div>
                        <div style="margin-top:10px; page-break-inside: avoid;">
                              26. Движение пациента по отделениям:
                               <table class="outhost" style="width:100%">
		<tr>
			<td>№</td>
			<td>Код отделения</td>
			<td>Профиль коек</td>			
			<td>Код врача</td>
            <td>Дата поступ­ления</td>
			<td>Дата выписки, перевода</td>
			<td>Код диагноза по МКБ</td>
			<td>Код медицин ского стандарта </td>
			<td>Код прерванного случая</td>
            <td>Вид оплаты</td>
		</tr>
		<tr cmptype="tr" dataset="DS_HOSP_STAT_CARDS_DEPS" repeate="0" class="outhost">
            <td><component cmptype="Label" name="Number"/></td>
			<td><component cmptype="Label" captionfield="DEP"/></td>
			<td><component cmptype="Label" captionfield="BED_TYPE"/></td>
			<td><component cmptype="Label" captionfield="EMPLOYER"/></td>
			<td><component cmptype="Label" captionfield="DATE_BEGIN"/></td>
			<td><component cmptype="Label" captionfield="DATE_END"/></td>
			<td><component cmptype="Label" captionfield="MKB"/></td>
			<td><component cmptype="Label" captionfield="MESES"/></td>
            <td width="70px"/>
			<td><component cmptype="Label" captionfield="PAYMENT_KIND_NAME"/></td>
		</tr>
                </table>
       </div>
        <div style="margin-top:10px; page-break-inside: avoid;">
              27. Хирургические операции (обозначить: основную операцию, использование спец. аппаратуры):
                <table class="outhost">
                    <tr>
                        <td rowspan="2">Дата, Час</td>
                        <td rowspan="2">Код хирурга</td>
                        <td rowspan="2">Код отделения</td>
                        <td colspan="2">Операция</td>
                        <td colspan="2">Осложнение</td>
                        <td rowspan="2">Анестезия</td>
                        <td colspan="3">Использ. спец. аппаратуры</td>
                        <td rowspan="2">Вид оплаты</td>
                    </tr>
                    <tr>
                        <td>наименование</td>
                        <td>код </td>
                        <td>наименование</td>
                        <td>код </td>
                        <td>энд.</td>
                        <td>лазер </td>
                        <td>криог. </td>
                    </tr>
                    <tr cmptype="tmp" dataset="DS_HOSP_STAT_CARDS_OPERS" repeate="0">
                        <td>
                            <component cmptype="Label" captionfield="OPER_DATE"/><br/>
                            <component cmptype="Label" captionfield="OPER_TIME"/>
                        </td>
                        <td><component cmptype="Label" captionfield="SURGEON"/></td>
                        <td><component cmptype="Label" captionfield="HSTD_DEP"/></td>
                        <td><component cmptype="Label" captionfield="SERVICE"/></td>
                        <td><component cmptype="Label" captionfield="SERVICE_CODE"/></td>
                        <td><component cmptype="Label" captionfield="COMPLICATION"/></td>
                        <td><component cmptype="Label" captionfield="COMPLICATION_CODE"/></td>
                        <td><component cmptype="Label" captionfield="ANAESTHETIZATION"/></td>
                        <td/>
                        <td/>
                        <td/>
                        <td><component cmptype="Label" captionfield="PAYMENT_KIND"/></td>
                    </tr>
                    <tr style="height: 25px;">
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                    </tr>
                    <tr style="height: 25px;">
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                    </tr>
                    <tr style="height: 25px;">
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                        <td> </td>
                    </tr>
                </table>
       </div>
        <div style="margin-top:10px;">
                <table>
                    <tr>
                        <td style="padding-right:10px">
                            28. Обследован: RW 1
                        </td>
                        <td style="width: 30px;height:12px; border:1px solid black">
                            <component cmptype="Label" name="RW_DATE"/>
                        </td>
                        <td style="padding-left:10px;padding-right:10px">
                            AIDS 2
                        </td>
                        <td style="width: 30px;height:12px; border:1px solid black;">
                            <component cmptype="Label" name="AIDS_DATE"/>
                        </td>
                    </tr>
                </table>
       </div>
        <div style="margin-top:10px;">
              29. Диагноз стационара (при выписке):
        <table class="outhost">
        <colgroup>
            <col width="50px"/>
            <col width="150px"/>
            <col width="50px"/>
            <col width="150px"/>
            <col width="50px"/>
            <col width="150px"/>
            <col width="50px"/>
        </colgroup>
		<tr >
            <td rowspan="2" height="150px" class="verticalText">Клинический заключительный</td>
            <td height ="50px">Основное заболевание</td>
			<td height ="50px">Код МКБ</td>
			<td height ="50px">Осложнение</td>			
			<td height ="50px">Код МКБ</td>
            <td height ="50px">Сопутствующее заболевание</td>
            <td height ="50px">Код МКБ</td>
		</tr>
		<tr>
			<td height ="100px"><component cmptype="Label" name="MKB_MAIN_NAME" /></td>
			<td height ="100px"><component cmptype="Label" name="MKB_MAIN_CODE" /></td>
			<td height ="100px"><component cmptype="Label" name="MKB_MAIN_ADD1_NAME" /></td>
			<td height ="100px"><component cmptype="Label" name="MKB_MAIN_ADD1_CODE" /></td>
            <td height ="100px"><component cmptype="Label" name="MKB_MAIN_ADD2_NAME" /></td>
            <td height ="100px"><component cmptype="Label" name="MKB_MAIN_ADD2_CODE" /></td>
		</tr>
        <tr>
            <td height="150px" class="verticalText">Патолого-анатомический</td>
			<td><component cmptype="Label" name="MKB_PAT_NAME" /></td>
			<td><component cmptype="Label" name="MKB_PAT_CODE" /></td>
            <td><component cmptype="Label" name="MKB_PAT_ADD2_NAME" /></td>
            <td><component cmptype="Label" name="MKB_PAT_ADD2_CODE" /></td>
			<td><component cmptype="Label" name="MKB_PAT_ADD1_NAME" /></td>
			<td><component cmptype="Label" name="MKB_PAT_ADD1_CODE" /></td>
		</tr>
        </table>
        </div>
        <div style="margin-top:10px;">
               <div style="display:inline-block; vertical-align:top; width: 680px">
                30. В случае смерти указать основную причину
                <div align="center"  style="display:inline-block; vertical-align:top;min-width:200px ">
                    <component cmptype="Label"  class="field"  name="MKB_PAT_NAME1"/>
                </div>
                код по МКБ
                <div align="center"  style="display:inline-block; vertical-align:top;min-width:50px ">
                    <component cmptype="Label"  class="field"  name="MKB_PAT_CODE1"/>
                </div>
            </div>
        </div>
        <div style="margin-top:10px;">
               31. Дефекты догоспитального этапа: <component cmptype="Label" name="IS_WELL_TIMED_HOSP"/>
               <component cmptype="Label" name="IS_ENOUGH_VOLUME"/>
               <component cmptype="Label" name="IS_CORRECT_HEALING"/>
               <component cmptype="Label" name="IS_SAME_DIAGN"/>
        </div>
        <div style="margin-top:20px;">
               Подпись лечащего врача  _____________________________________<br/><br/>
               Подпись заведующего отделением   ___________________________
        </div>

        </td>
        </tr>
    </table> 
     <style>
    table.table_head td{
		
		padding: 1mm;
		font-size: x-small;
	}
    span.field_l, span.field {
         line-height: 100%;
         margin: 0;
         padding: 0;
         text-align: center;
         text-indent:0;
         font-weight: bold;
    }
    span.field_l{
         text-decoration:underline;
    }
	span.field {
         display: inline-block;
         min-height: 12px;
         width: 100%;
         border-bottom: 1px solid black;
	}
    span.field2 {
		line-height: 100%;
        width: 100%;
		margin: 0;
		padding: 0px 5px;
		text-decoration:underline;
		text-align: center;
		text-indent:0;
	}
    table.outhost td {
		border: 1px solid black;
		padding: 1mm;
		text-align:center;
	} 
    .verticalText {
        -moz-transform: rotate(-90deg);
        -webkit-transform: rotate(-90deg);
        -o-transform: rotate(-90deg);
        transform: rotate(-90deg);
        margin: -50px 0 -50px 50px;
    }
  </style>
</div>