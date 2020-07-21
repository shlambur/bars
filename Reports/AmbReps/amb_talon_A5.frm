<div cmptype="Form" class="report_form d3form" onshow="Form.OnCreate();" style="width:210mm;">
<span style="display:none" id="PrintSetup" ps_paperData="8" ps_orientation="portrait" ps_marginBottom="0" ps_marginTop="0" ps_marginLeft="15" ps_marginRight="10" ps_shrinkToFit="1"></span>
<component cmptype="SubForm" path="Reports/AmbReps/amb_talon_subform"/>

<div style="width:210mm;">
<table class="info_table">
    <tr>
        <td>
            <table class="info_table_left">
                <tr>
                    <td>Наименование медицинской организации</td>
                </tr>
                <tr>
                    <td class="info_table_field"><component cmptype="Label" name="FULLNAME"/></td>
                </tr>
                <tr>
                    <td style="padding-top: 4mm;">Адрес медицинской организации</td>
                </tr>
                <tr>
                    <td class="info_table_field"><component cmptype="Label" name="FULLADDRESS"/></td>
                </tr>
            </table>
        </td>
        <td style="width:20%">&amp;nbsp;</td>
        <td style="vertical-align: top;">
            <table class="info_table_right">
                <tr>
                    <td>Приложение № 3</td>
                </tr>
                <tr>
                    <td>к приказу Министерства здравоохранения</td>
                </tr>
                <tr>
                    <td>Российской Федерации</td>
                </tr>
                <tr>
                    <td>от 15 декабря 2014 г. № 834н</td>
                </tr>

                <tr>
                    <td style="padding-top: 5mm;">Медицинская документация</td>
                </tr>
                <tr>
                    <td>Учетная форма № 025-1/у</td>
                </tr>
                <tr>
                    <td>Утверждена приказом Минздрава России</td>
                </tr>
                <tr>
                    <td>от 15 декабря 2014 г. № 834н</td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<div  style="text-align: center; padding-top: 5mm; font-weight: bold; ">
    ТАЛОН ПАЦИЕНТА, ПОЛУЧАЮЩЕГО МЕДИЦИНСКУЮ ПОМОЩЬ<br/>
    В АМБУЛАТОРНЫХ УСЛОВИЯХ, № <component cmptype="Label" class="field" name="CARD_NUMB"/> 
</div>



<table class="data_table" style="margin-top:2mm; ">
    <tr>
        <td style="padding-bottom: 5mm;">
            1. Дата открытия талона: число <component cmptype="Label" class="field" style="min-width: 15mm;" name="REG_DATE_DAY"/>
            месяц <component cmptype="Label" class="field" style="min-width: 15mm;" name="REG_DATE_MONTH"/>
            год <component cmptype="Label" class="field" style="min-width: 15mm;" name="REG_DATE_YEAR"/>

            <div cmptype="tmp" name="DS_PMC_FEDERAL_PRIVS_DUMMY" style="display:none;">
                2. Код категории льготы <component cmptype="Label" class="field" style="min-width: 15mm;" caption=""/>
                3. Действует до <component cmptype="Label" class="field" style="min-width: 15mm;" caption=""/>
                <br/>
            </div>
            
            <div dataset="DS_PMC_FEDERAL_PRIVS" repeat="0" onafter_refresh="Form.afterRefreshDataset('DS_PMC_FEDERAL_PRIVS', 'inline');" style="display:inline;">
                <component cmptype="Label" captionfield="R_NUM" before_caption="2."/> Код категории льготы <component cmptype="Label" class="field" style="min-width: 15mm;" data="caption:PRIV"/>
                <component cmptype="Label" captionfield="R_NUM" before_caption="3."/> Действует до <component cmptype="Label" class="field" style="min-width: 15mm;" data="caption:PRIV_END"/>
            </div>

            4. Страховой полис ОМС: серия <component cmptype="Label" class="field" style="min-width: 15mm;font-size:15px" name="P_SER"/>
            № <component cmptype="Label" class="field" style="min-width: 15mm;font-size:15px" name="P_NUM"/>
            5. СМО <component cmptype="Label" class="field" style="min-width: 70mm;" name="P_WHO"/>
            6. СНИЛС <component cmptype="Label" class="field" style="min-width: 30mm;" name="SNILS"/>
            <br/>

            7. Фамилия <component cmptype="Label" class="field" style="min-width: 30mm; text-transform:uppercase; font-size:15px" name="SURNAME"/>
            8. Имя <component cmptype="Label" class="field" style="min-width: 30mm; text-transform:uppercase;font-size:15px" name="FIRSTNAME"/>
            9. Отчество <component cmptype="Label" class="field" style="min-width: 30mm; text-transform:uppercase;font-size:15px" name="LASTNAME"/>
            10. Пол <component cmptype="Label" class="field" style="min-width: 15mm;" name="SEX"/>
            <br/>

            11. Дата рождения: число <component cmptype="Label" class="field" style="min-width: 15mm;" name="BIRTHDATE_DAY"/>
            месяц <component cmptype="Label" class="field" style="min-width: 15mm;" name="BIRTHDATE_MONTH"/>
            год <component cmptype="Label" class="field" style="min-width: 15mm;" name="BIRTHDATE_YEAR"/>
            9. Документ, удостоверяющий личность: <component cmptype="Label" class="field" style="min-width: 40mm;" name="PD_TYPE_NAME"/>
            серия <component cmptype="Label" class="field" style="min-width: 15mm;" name="PD_SER"/>
            № <component cmptype="Label" class="field" style="min-width: 15mm;" name="PD_NUMB"/>
            <br/>

            12. Место регистрации: <component cmptype="Label" class="field" style="min-width: 120mm; text-align: left;" name="PMC_FULL_ADDR"/>
            <component cmptype="Label" class="field" name="PMC_PHONES" before_caption="тел. "/>
            <br/>

            13. Местность: <component cmptype="Label" class="field" style="min-width: 15mm;" name="IS_CITIZEN"/>
            <br/>

            14. Занятость: <component cmptype="Label" class="field" style="min-width: 100mm;" name="SOC_STATES"/>
            <br/>

            15. Место работы, должность (для детей: дошкольник: организован, неорганизован; школьник) 
            <component cmptype="Label" class="field" style="min-width: 50mm;" name="WORK_PLACE"/>
            <br/>

            16. Инвалидность: <component cmptype="Label" class="field" style="min-width: 20mm;" name="INABILITY_STATUS"/>
            17. Группа инвалидности: <component cmptype="Label" class="field" style="min-width: 20mm;" name="INABILITY_GROUP"/>
            18. Инвалид с детства: <component cmptype="Label" class="field" style="min-width: 20mm;" name="INABILITY_TYPE"/>
        </td>
    </tr>
    <tr cmptype="tmp" dataset="DS_REZ">
        <td style="border-top: 1px solid black; padding-top: 2mm;">
            19. Оказываемая медицинская помощь: <component cmptype="Label" class="field" style="min-width: 125mm; text-align: left;" name="MED_CARE_KINDS"/>
            <br/>

            20. Место обращения (посещения): <component cmptype="Label" class="field" style="min-width: 20mm;" name="VIS_PLACE"/>
            <br/>

            21. Посещения: <component cmptype="Label" class="field" style="min-width: 95mm;" name="VIS_PURPOSE" after_caption=";"/>
            <component cmptype="Label" class="field" name="VIS_PURPOSE_DETAIL" before_caption="из них: "/>
            <br/>

            22. Обращение (цель): <component cmptype="Label" class="field" style="min-width: 95mm;" name="VIS_PURPOSE_2"/>
            <br/>

            23. Обращение (законченный случай лечения): <component cmptype="Label" class="field" style="min-width: 15mm;" name="DC_IS_CLOSE"/>
            24. Обращение: <component cmptype="Label" class="field" style="min-width: 15mm;" name="VIS_IS_PRIMARY"/>
            <br/>

            25. Результат обращения: <b><component cmptype="Label" class="field" data="caption:VR_NAME" /></b> <component cmptype="Label" class="field" style="min-width: 30mm;" name="VIS_RESULTS"/> 
            <component cmptype="Label" class="field" name="VIS_REF_RESULTS" before_caption=", дано направление: "/>
           
            <br/> 
            

                

            26. Оплата за счет: <component cmptype="Label" class="field" style="min-width: 30mm;" name="VIS_PAYMENT_KINDS"/>
            <br/>

            <table cmptype="tmp" name="DS_AMB_TALON_VISITS_DUMMY" style="width:99%; margin-top:2mm; margin-bottom:1mm; display:none;" border="1">
                <colgroup>
                    <col style="width:40mm;" />
                </colgroup>
                <tr>
                    <td rowspan="2">
                        27. Даты посещений (число, месяц, год):
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
            </table>

            <table id="amb_talon_visits_table" style="width:99%; margin-top:2mm; margin-bottom:1mm;" border="1">
                <colgroup>
                    <col style="width:40mm;" />
                </colgroup>
                <tr dataset="DS_AMB_TALON_VISITS" repeatername="group_talon_visits" keyfield="PAGE"  onafter_refresh="Form.afterRefreshAmbTalonVisits();">
                    <td cmptype="tmp" name="AMB_VIS_HEADER">
                        27. Даты посещений (число, месяц, год):
                    </td>
                    <td dataset="DS_AMB_TALON_VISITS" repeat="0" keyfield="PAGE" onbefore_clone="Form.onCloneAmbTalonVisits(data);">
                        <component cmptype="Label" data="caption:VIS_DATE"/>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<div style="font-size: 9pt;">оборотная сторона формы №025-1/у</div>
<table class="data_table">
    <tr>
        <td style="padding: 0;">
            <table style="width:100%">
                <tr>
                    <td>
                        28. Диагноз предварительный <component cmptype="Label" class="field" style="min-width:95mm;" name="PRE_MKB_NAME"/>
                    </td>
                    <td>
                        код по МКБ-10 <component cmptype="Label" class="field" style="min-width:20mm;" name="PRE_MKB"/>
                    </td>
                </tr>
                <tr>
                    <td>
                        29. Внешняя причина <component cmptype="Label" class="field" style="min-width:112mm;" name="PRE_EX_CAUSE_MKB_NAME"/>
                    </td>
                    <td>
                        код по МКБ-10 <component cmptype="Label" class="field" style="min-width:20mm;" name="PRE_EX_CAUSE_MKB"/>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td style="padding: 0;">
            <table style="width:100%">
                <tr cmptype="tmp" name="DS_VIS_EMPLOYERS_DUMMY" style="display:none;">
                    <td>
                        <component cmptype="Label" name="VIS_EMP_NUMERATION" style="display:inline;" caption="30."/>
                    </td>
                    <td>
                        Врач: специальность <component cmptype="Label" class="field" style="min-width:60mm;"/>
                    </td>
                    <td>
                        ФИО <component cmptype="Label" class="field" style="min-width:75mm;"/>
                    </td>
                    <td>
                        код <component cmptype="Label" class="field" style="min-width:10mm;"/>
                    </td>
                </tr>
                <tr dataset="DS_VIS_EMPLOYERS" repeat="0" onbefore_clone="Form.onCloneDatasetRow(data, 'VIS_EMP_NUMERATION');" onafter_refresh="Form.afterRefreshDataset('DS_VIS_EMPLOYERS');">
                    <td>
                        <component cmptype="Label" name="VIS_EMP_NUMERATION" style="display:inline;" caption="30."/>
                    </td>
                    <td style="padding-left: 0;">
                        Врач: специальность <component cmptype="Label" class="field" style="min-width:50mm;" data="caption:VIS_EMPLOYER_SPEC_NAME"/>
                    </td>
                    <td>
                        ФИО <component cmptype="Label" class="field" style="min-width:75mm;" data="caption:VIS_EMPLOYER_NAME"/>
                    </td>
                    <td>
                        код <component cmptype="Label" class="field" style="min-width:10mm;" data="caption:VIS_EMPLOYER"/>
                    </td>
                </tr>
            </table>
        </td>
    </tr>

    <tr>
        <td style="padding: 0 0 3mm; ">
            <table style="width:100%">
                <tr cmptype="tmp" name="DS_VIS_SERVICES_DUMMY" style="display:none;">
                    <td>
                        <component cmptype="Label" name="VIS_SERV_NUMERATION" style="display:inline;" caption="31."/>
                    </td>
                    <td>
                        Медицинская услуга <component cmptype="Label" class="field" style="min-width:127mm;"/>
                    </td>
                    <td>
                        код <component cmptype="Label" class="field" style="min-width:10mm;"/>
                    </td>
                </tr>
                <tr dataset="DS_VIS_SERVICES" repeat="0" onbefore_clone="Form.onCloneDatasetRow(data, 'VIS_SERV_NUMERATION');" onafter_refresh="Form.afterRefreshDataset('DS_VIS_SERVICES');">
                    <td>
                        <component cmptype="Label" name="VIS_SERV_NUMERATION" style="display:inline;" caption="31."/>
                    </td>
                    <td style="padding-left: 0;">
                        Медицинская услуга <component cmptype="Label" class="field" style="min-width:127mm;" data="caption:SERVICE_NAME"/>
                    </td>
                    <td>
                        код <component cmptype="Label" class="field" style="min-width:10mm;font-size:15px" data="caption:SERVICE"/>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<table class="data_table" style="margin-top: 2mm;">
    <tr>
        <td>
            32. Диагноз заключительный <component cmptype="Label" class="field" style="min-width:100mm;" name="FIN_DIAG_NAME"/>
        </td>
        <td>
            код по МКБ-10 <component cmptype="Label" class="field" style="min-width:10mm;" name="FIN_DIAG"/>
        </td>
    </tr>
    <tr>
        <td>
            33. Внешняя причина <component cmptype="Label" class="field" style="min-width:110mm;" name="FIN_EX_CAUSE_MKB_NAME"/>
        </td>
        <td>
            код по МКБ-10 <component cmptype="Label" class="field" style="min-width:10mm;" name="FIN_EX_CAUSE_MKB"/>
        </td>
    </tr>
    <tr>
        <td colspan="2" style="padding: 0;">
            <table style="width:100%">
                <tr cmptype="tmp" name="DS_AMB_SOP_MKBS_DUMMY" style="display:none;">
                    <td>
                        <component cmptype="Label" name="AMB_SOP_NUMERATION" style="display:inline;" caption="34. Сопутствующие заболевания:"/>
                        <component cmptype="Label" class="field" style="min-width:92mm;"/>
                    </td>
                    <td>
                        код по МКБ-10 <component cmptype="Label" class="field" style="min-width:10mm;"/>
                    </td>
                </tr>
                <tr dataset="DS_AMB_SOP_MKBS" repeat="0" onbefore_clone="Form.onCloneDatasetRow(data, 'AMB_SOP_NUMERATION');" onafter_refresh="Form.afterRefreshDataset('DS_AMB_SOP_MKBS');">
                    <td>
                        <component cmptype="Label" name="AMB_SOP_NUMERATION" style="display:inline;" caption="34. Сопутствующие заболевания:"/>
                        <component cmptype="Label" class="field" style="min-width:92mm;" data="caption:SOP_MKB_NAME"/>
                    </td>
                    <td>
                        код по МКБ-10 <component cmptype="Label" class="field" style="min-width:10mm;" data="caption:SOP_MKB"/>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td colspan="2">
            35. Заболевание:<component cmptype="Label" class="field" style="min-width:117mm;" name="FIN_DT_NAME"/>
        </td>
    </tr>
    <tr>
        <td colspan="2">
            36. Диспансерное наблюдение: <component cmptype="Label" class="field" style="min-width:30mm;" name="COC_TYPE" after_caption=";"/>
            <component cmptype="Label" class="field" name="COC_TYPE_DATA" before_caption="из них: "/>
        </td>
    </tr>
    <tr>
        <td colspan="2" style="padding-bottom: 3mm;">
            37. Травма: <component cmptype="Label" class="field" style="min-width:60mm;" name="INJURE_KIND_DATA"/>
        </td>
    </tr>
</table>

<table class="data_table" style="margin-top: 2mm;">
    <tbody cmptype="tmp" name="DS_AMB_OPERATIONS_DUMMY" style="display:none;">
        <tr>
            <td style="padding:0;" colspan="3">
                <table style="width:100%">
                    <tr>
                        <td>
                            <component cmptype="Label" name="AMB_OPERATIONS_NUMERATION" style="display:inline;" caption="38."/>
                        </td>
                        <td>
                            Операция <component cmptype="Label" class="field" style="min-width:135mm;"/>
                        </td>
                        <td>
                            код <component cmptype="Label" class="field" style="min-width:10mm;"/>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="3">
                <component cmptype="Label" style="display:inline;" caption="39."/>
                Анестезия: <component cmptype="Label" class="field" style="min-width:30mm;"/>

                <component cmptype="Label" style="display:inline;" caption="40."/>
                Операция проведена с использованием аппаратуры: <component cmptype="Label" class="field" style="min-width:50mm;"/>

                <component cmptype="Label" style="display:inline;" caption="41."/>
                Врач: специальность <component cmptype="Label" class="field" style="min-width:45mm;"/>
                ФИО <component cmptype="Label" class="field" style="min-width:45mm;"/>
                код <component cmptype="Label" class="field" style="min-width:30mm;"/>
            </td>
        </tr>
    </tbody>
    <tbody dataset="DS_AMB_OPERATIONS" repeat="0" onafter_refresh="Form.afterRefreshDataset('DS_AMB_OPERATIONS');">
        <tr>
            <td style="padding: 0;" colspan="3">
                <table style="width:100%">
                    <tr>
                        <td>
                            <component cmptype="Label" before_caption="38." data="caption:R_NUM"/>
                        </td>
                        <td style="padding-left: 0;">
                            Операция <component cmptype="Label" class="field" style="min-width:135mm;" data=":OPERATION_NAME"/>
                        </td>
                        <td>
                            код <component cmptype="Label" class="field" style="min-width:10mm;" data="caption:OPERATION"/>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="3">
                <component cmptype="Label" style="display:inline;" before_caption="39." data="caption:R_NUM"/>
                Анестезия: <component cmptype="Label" class="field" style="min-width:30mm;" data="caption:ANEST_TYPE"/>

                <component cmptype="Label" style="display:inline;" before_caption="40." data="caption:R_NUM"/>
                Операция проведена с использованием аппаратуры: <component cmptype="Label" class="field" style="min-width:30mm;" data="caption:APP_KIND"/>

                <component cmptype="Label" style="display:inline;" before_caption="41." data="caption:R_NUM"/>
                Врач: специальность <component cmptype="Label" class="field" style="min-width:45mm;" data="caption:VIS_EMPLOYER_SPEC_NAME"/>
                ФИО <component cmptype="Label" class="field" style="min-width:45mm;" data="caption:VIS_EMPLOYER_NAME"/>
                код <component cmptype="Label" class="field" style="min-width:30mm;" data="caption:VIS_EMPLOYER"/>
            </td>
        </tr>
    </tbody>
    <tbody cmptype="tmp" name="DS_AMB_MANIPULATIONS_DUMMY" style="display:none;">
        <tr>
            <td style="min-width:70mm;">
                <component cmptype="Label" name="AMB_MANIPULATIONS_NUMERATION" style="display:inline;" caption="42. Манипуляции, исследования:"/>
                <component cmptype="Label" class="field" style="min-width:70mm;"/>
            </td>
            <td style="vertical-align:bottom;">
                кол-во <component cmptype="Label" class="field" style="min-width:20mm;"/>
            </td>
            <td style="vertical-align:bottom;">
                код <component cmptype="Label" class="field" style="min-width:20mm;"/>
            </td>
        </tr>
        <tr>
            <td colspan="3" style="padding-bottom:3mm;">
                <component cmptype="Label" style="display:inline;" caption="43."/>
                Врач: специальность <component cmptype="Label" class="field" style="min-width:45mm;"/>
                ФИО <component cmptype="Label" class="field" style="min-width:45mm;"/>
                код <component cmptype="Label" class="field" style="min-width:30mm;"/>
            </td>
        </tr>
    </tbody>
    <tbody dataset="DS_AMB_MANIPULATIONS" repeat="0" onafter_refresh="Form.afterRefreshDataset('DS_AMB_MANIPULATIONS');">
        <tr>
            <td style="min-width:70mm;">
                <component cmptype="Label" name="AMB_MANIPULATIONS_NUMERATION" style="display:inline;" caption="42. Манипуляции, исследования:"/>
                <component cmptype="Label" class="field" style="min-width:100%;" data="caption:SERVICE_NAME"/>
            </td>
            <td style="vertical-align:bottom;">
                кол-во <component cmptype="Label" class="field" style="min-width:20mm;" data="caption:SER_COUNT"/>
            </td>
            <td style="vertical-align:bottom;">
                код <component cmptype="Label" class="field" style="min-width:20mm;" data="caption:SERVICE"/>
            </td>
        </tr>
        <tr>
            <td colspan="3" style="padding-bottom:3mm;">
                <component cmptype="Label" name="AMB_MANIPULATIONS_NUMERATION" style="display:inline;" caption="43."/>
                Врач: специальность <component cmptype="Label" class="field" style="min-width:45mm;" data="caption:VIS_EMPLOYER_SPEC_NAME"/>
                ФИО <component cmptype="Label" class="field" style="min-width:45mm;" data="caption:VIS_EMPLOYER_NAME"/>
                код <component cmptype="Label" class="field" style="min-width:30mm;" data="caption:VIS_EMPLOYER"/>
            </td>
        </tr>
    </tbody>
</table>

<div style="margin-top: 1mm; margin-left: 2mm; font-size: 9pt;">44. Рецепты на лекарственные препараты:</div>

<table class="recipes_table">
    <thead>
        <tr>
            <td rowspan="2">Дата</td>
            <td colspan="2">Рецепт</td>
            <td rowspan="2">Лекарствен&amp;shy;ный препарат</td>
            <td rowspan="2">Льгота (%)</td>
            <td rowspan="2">Лек. форма</td>
            <td rowspan="2">Доза</td>
            <td rowspan="2">Кол-во</td>
            <td rowspan="2">Код МКБ-10</td>
            <td rowspan="2">Код врача</td>
        </tr>
        <tr>
            <td>серия</td>
            <td>номер</td>
        </tr>
    </thead>
    <tbody cmptype="tmp" name="DS_AMB_RECIPES_DUMMY" style="display: none;">
        <tr>
            <td>&amp;nbsp;</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td>&amp;nbsp;</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td>&amp;nbsp;</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
        </tr>
    </tbody>
    <tbody>
        <tr dataset="DS_AMB_RECIPES" repeat="0" onafter_refresh="Form.afterRefreshDataset('DS_AMB_RECIPES');">
            <td><component cmptype="Label" data="caption:REC_DATE"/></td>
            <td><component cmptype="Label" data="caption:REC_SERNUMB"/></td>
            <td><component cmptype="Label" data="caption:REC_NUMB"/></td>
            <td><component cmptype="Label" data="caption:MNN_FED_PRIV_RUS"/></td>
            <td><component cmptype="Label" data="caption:PRIVPERCENT"/></td>
            <td><component cmptype="Label" data="caption:MEDFORM"/></td>
            <td><component cmptype="Label" data="caption:DOSE"/></td>
            <td><component cmptype="Label" data="caption:PACK_COUNT"/></td>
            <td><component cmptype="Label" data="caption:DISEASE"/></td>
            <td><component cmptype="Label" data="caption:EMPLOYER"/></td>
        </tr>
    </tbody>
</table>

<table class="data_table" style="margin-top: 2mm;">
    <tbody cmptype="tmp" name="DS_AMB_BULLETINS_DUMMY" style="display:none;">
        <tr>
            <td>
                <component cmptype="Label" caption="45."/>
                Документ о временной нетрудоспособности: 
                <component cmptype="Label" class="field" style="min-width:25mm;"/>

                <component cmptype="Label" caption="46."/>
                Повод выдачи:
                <component cmptype="Label" class="field" style="min-width:20mm;"/><br/>

                <component cmptype="Label" caption="47."/>
                Дата выдачи:
                число <component cmptype="Label" class="field" style="min-width: 15mm;"/>
                месяц <component cmptype="Label" class="field" style="min-width: 15mm;"/>
                год <component cmptype="Label" class="field" style="min-width: 15mm;"/>
            </td>
        </tr>
        <tr>
            <td>
                <component cmptype="Label" caption="48."/>
                Даты продления:
                <div class="bull_cont_date_field" style="display:inline-block; width:22mm;">&amp;nbsp;</div>
                <div class="bull_cont_date_field" style="display:inline-block; width:22mm;">&amp;nbsp;</div>
                <div class="bull_cont_date_field" style="display:inline-block; width:22mm;">&amp;nbsp;</div>
                <div class="bull_cont_date_field" style="display:inline-block; width:22mm;">&amp;nbsp;</div>
                <div class="bull_cont_date_field" style="display:inline-block; width:22mm;">&amp;nbsp;</div>
                <div class="bull_cont_date_field" style="display:inline-block; width:22mm;">&amp;nbsp;</div>
            </td>
        </tr>
        <tr>
            <td>
                <component cmptype="Label" caption="49."/>
                Дата закрытия документа о временной нетрудоспособности:
                число <component cmptype="Label" class="field" style="min-width: 15mm;"/>
                месяц <component cmptype="Label" class="field" style="min-width: 15mm;"/>
                год <component cmptype="Label" class="field" style="min-width: 15mm;"/>
            </td>
        </tr>
    </tbody>
    <tbody cmptype="Base" dataset="DS_AMB_BULLETINS" repeat="0" repeatername="AMB_BULLETINS_ID" keyfield="ID" onafter_refresh="Form.afterRefreshDataset('DS_AMB_BULLETINS');">
        <tr>
            <td>
                <component cmptype="Label" before_caption="45." data="caption:R_NUM"/>
                Документ о временной нетрудоспособности: 
                <component cmptype="Label" class="field" caption="листок нетрудоспособности – 1"/>

                <component cmptype="Label" before_caption="46." data="caption:R_NUM"/>
                Повод выдачи:
                <component cmptype="Label" class="field" style="min-width:20mm;" data="caption:DIS_TYPES"/>

                <component cmptype="Label" before_caption="47." data="caption:R_NUM"/>
                Дата выдачи:
                число <component cmptype="Label" class="field" style="min-width: 15mm;" data="caption:DATE_BEGIN_DAY"/>
                месяц <component cmptype="Label" class="field" style="min-width: 15mm;" data="caption:DATE_BEGIN_MONTH"/>
                год <component cmptype="Label" class="field" style="min-width: 15mm;" data="caption:DATE_BEGIN_YEAR"/>
            </td>
        </tr>
        <tr>
            <td>
                <component cmptype="Label" before_caption="48." data="caption:R_NUM"/>
                Даты продления:
                <div class="bull_cont_date_field" dataset="DS_AMB_BULL_CONTS" keyfield="ID" repeat="0" detail="true" parent="AMB_BULLETINS_ID:ID">
                    <component cmptype="Label" data="caption:CONT_DATE"/>
                </div>
            </td>
        </tr>
        <tr>
            <td>
                <component cmptype="Label" before_caption="49." data="caption:R_NUM"/>
                Дата закрытия документа о временной нетрудоспособности:
                число <component cmptype="Label" class="field" style="min-width: 15mm;" data="caption:DATE_END_DAY"/>
                месяц <component cmptype="Label" class="field" style="min-width: 15mm;" data="caption:DATE_END_MONTH"/>
                год <component cmptype="Label" class="field" style="min-width: 15mm;" data="caption:DATE_END_YEAR"/>
            </td>
        </tr>
    </tbody>
    <tbody>
        <tr>
            <td style="padding-bottom:3mm;">
                50. Дата закрытия талона
                число <component cmptype="Label" class="field" style="min-width: 15mm;" name="AMB_DATE_END_DAY"/>
                месяц <component cmptype="Label" class="field" style="min-width: 15mm;" name="AMB_DATE_END_MONTH"/>
                год <component cmptype="Label" class="field" style="min-width: 15mm;" name="AMB_DATE_END_YEAR"/>

                51. Врач (ФИО, подпись)
                <component cmptype="Label" class="field" style="min-width: 15mm;" name="AMB_TALON_EMPLOYER"/>
            </td>
        </tr>
        
    </tbody>
</table>


<style>
    .report_form
    {
        font-size: 9pt;
    }
    .report_form > span
    {
        font-size: 9pt;
    }
    .info_table
    {
        width: 100%;
        font-size: 8pt;
        margin-bottom: 4mm;
    }
    .info_table_left
    {
        width: 100%;
        text-align: center;
        font-size: 8pt;
    }
    .info_table_right
    {
        width: 80mm;
        text-align: center;
        font-size: 8pt;
    }
    .info_table_field
    {
        font-size: 8pt;
        text-align: center;
        display: inline;
    }
    span.field
    {
        font-weight: bold;
        border-bottom: 1px solid black;
        display: inline-block;
        text-align: center;
        vertical-align: bottom;
    }
    .data_table
    {
        border: 1px solid black;
        width: 100%;
    }
    .data_table td
    {
        height: 4mm;
        padding-left: 5px;
        padding-top: 2px;
        padding-bottom: 2px;
        font-size: 9pt;
        line-height: 4mm;
    }
    .recipes_table
    {
        width: 100%;
        table-layout: fixed;
        word-wrap: break-word;
        margin-top: 1mm;
    }
    .recipes_table td
    {
        text-align: center;
        border: 1px solid black;
        font-size: 9pt;
        padding: 0mm;
    }
    .bull_cont_date_field
    {
        display: inline;
        border-left: 1px solid black;
        border-right: 1px solid black;
        border-bottom: 1px solid black;
        padding: 1mm;
        margin-right: 1mm;
        font-size: 8pt;
    }
    #amb_talon_visits_table td
    {
        min-width: 15mm;
    }
</style>
</div>
</div>