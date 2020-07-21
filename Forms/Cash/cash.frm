<div cmptype="frm" version="2.5" onshow="base().onShow();">
    <div cmptype="title">Касса</div>
    <component cmptype="Script" name="Script">
		<![CDATA[
        Form.OnCreate = function () {
            addSystemInfo('DS_CASH', {get: '_f[SERVICE_ID;M]', srctype: 'ctrl', src: 'SE_CODE', ignorenull: false});
            addSystemInfo('DS_CASH', {get: '_f[SURNAME]', srctype: 'var', src: 'PAT_SURNAME', ignorenull: false});
            addSystemInfo('DS_CASH', {get: '_f[FIRSTNAME]', srctype: 'var', src: 'PAT_FIRSTNAME', ignorenull: false});
            addSystemInfo('DS_CASH', {get: '_f[LASTNAME]', srctype: 'var', src: 'PAT_LASTNAME', ignorenull: false});
            addSystemInfo('DS_CASH', {get: '_f[DOC_PREF]', srctype: 'var', src: 'DOC_PREF', ignorenull: false});
            addSystemInfo('DS_CASH', {get: '_f[DOC_NUMB]', srctype: 'var', src: 'DOC_NUMB', ignorenull: false});
            addSystemInfo('DS_CASH', {get: '_f[KOD_VRACHA]', srctype: 'var', src: 'EMP_CODE', ignorenull: false});
            addSystemInfo('DS_CASH', {get: '_f[EMP_FULL_NAME]', srctype: 'var', src: 'EMP_SURNAME', ignorenull: false});
            addSystemInfo('DS_CASH', {
                get: '_f[IS_FULLY_PAID]',
                srctype: 'var',
                src: 'sIS_FULLY_PAID',
                ignorenull: false
            });
            addSystemInfo('DS_CASH', {get: '_f[STATUS]', srctype: 'var', src: 'STAT', ignorenull: false});
            addSystemInfo('DS_CASH', {get: '_f[DC_TYPE]', srctype: 'var', src: 'DC_TYPE', ignorenull: false});
            addSystemInfo('DS_CASH', {get: '_f[LPU]', srctype: 'var', src: 'LPU', ignorenull: false});

            addSystemInfo('DS_CASH', {
                get: '_f[REC_DATE;D;REC_DATE_BEGIN]',
                srctype: 'var',
                src: 'REC_DATE',
                ignorenull: false
            });
            addSystemInfo('DS_CASH', {
                get: '_f[REC_DATE;D;REC_DATE_END]',
                srctype: 'var',
                src: 'REC_DATE_END',
                ignorenull: false
            });
            addSystemInfo('DS_CASH', {
                get: '_f[REG_DATE;D;REG_DATE_BEGIN]',
                srctype: 'var',
                src: 'REG_DATE',
                ignorenull: false
            });
            addSystemInfo('DS_CASH', {
                get: '_f[REG_DATE;D;REG_DATE_END]',
                srctype: 'var',
                src: 'REG_DATE_END',
                ignorenull: false
            });
            executeAction("SET_DIVISION", null, null, null, false);
            executeAction("INIT_ACTION", base().AfterGetSysDate);
        }
        Form.onShow = function () {
            Expander_Toggle('CashFiltExp', 'show');
        }
        Form.AfterGetSysDate = function () {
            setValue('REC_DATE', getVar('SYS_DATE'));
            setValue('REC_DATE_END', getVar('SYS_DATE'));
            setVar('DATE_CASH', getVar('SYS_DATE'));
            setVar('DATE_CASH_END', getVar('SYS_DATE'));
            base().CHANGE_DATA_TYPE();
            base().RefreshCashDataSets();
        }
        Form.ClearFilter = function () {
            clearControl('PAT_SURNAME', 'PAT_FIRSTNAME', 'PAT_LASTNAME', 'DOC_PREF', 'DOC_NUMB', 'SE_CODE', 'EMP_CODE', 'IS_FULLY_PAID', 'STAT');
        }
        Form.MOVE_DATE = function (numb) {
            var str = getValue('DATE_TYPE');
            if (!empty(getValue(str))) {
                setVar('DATE_NUM', numb);
                setVar('SYS_DATENOW', getValue(str));
                setVar('SYS_DATE_ENDNOW', getValue(str + '_END'));
                executeAction("getSYS_DATE_LAST_NEXT",
                        function () {
                            setValue(str, getVar('SYS_DATELN'));
                            setValue(str + '_END', getVar('SYS_DATE_ENDLN'))
                            base().RefreshCashDataSets();
                        },
                        null,
                        null);
            }
            else {
                alert('Дата не выбрана');
            }
        }
        Form.DateRefresh = function () {
            var date_type = getValue('DATE_TYPE');
            if (!empty(getValue(date_type))) {
                setVar('CASHDATE', getValue(date_type));
                base().RefreshCashDataSets();
            }
            else {
                alert('Дата не выбрана!');
            }
        }

        Form.DateRefreshDate = function () {
            var date_type = getValue('DATE_TYPE');
            if (!empty(getValue(date_type))) {
                setVar('CASHDATE', getValue(date_type));
                setVar('CASHDATE_END', getValue(date_type + '_END'));
                base().RefreshCashDataSets();
            }
            else {
                alert('Дата не выбрана!');
            }
        }

        Form.RefreshCashDataSets = function () {
            if (!empty(getValue('DATE_TYPE'))) {
                setVar('DATE_CASH', getValue(getValue('DATE_TYPE')));
                setVar('DATE_CASH_END', getValue(getValue('DATE_TYPE') + '_END'));
            }

            setVar('sIS_FULLY_PAID', (empty(getValue('IS_FULLY_PAID')) ? '' : '=' + getValue('IS_FULLY_PAID')));
            setVar('PAT_SURNAME', (empty(getValue('PAT_SURNAME')) ? '' : '^' + getValue('PAT_SURNAME')));
            setVar('PAT_FIRSTNAME', (empty(getValue('PAT_FIRSTNAME')) ? '' : '^' + getValue('PAT_FIRSTNAME')));
            setVar('PAT_LASTNAME', (empty(getValue('PAT_LASTNAME')) ? '' : '^' + getValue('PAT_LASTNAME')));
            setVar('DOC_PREF', (empty(getValue('DOC_PREF')) ? '' : '^' + getValue('DOC_PREF')));
            setVar('DOC_NUMB', (empty(getValue('DOC_NUMB')) ? '' : '^' + getValue('DOC_NUMB')));
            setVar('EMP_CODE', (empty(getValue('EMP_CODE')) ? '' : '^' + getValue('EMP_CODE')));
            setVar('EMP_SURNAME', (empty(getValue('EMP_SURNAME')) ? '' : '^' + getValue('EMP_SURNAME')));
            setVar('STAT', (empty(getValue('STAT')) ? '' : '=' + getValue('STAT')));
            setVar('DC_TYPE', (empty(getValue('DC_TYPE_COM')) ? '' : '=' + getValue('DC_TYPE_COM')));
            if (getValue('DATE_TYPE') == 'REC_DATE') {
                setVar('REC_DATE', getValue('REC_DATE'));
                setVar('REC_DATE_END', getValue('REC_DATE_END'));
                setVar('REG_DATE', null);
                setVar('REG_DATE_END', null);
            }
            else {
                setVar('REG_DATE', getValue('REG_DATE'));
                setVar('REG_DATE_END', getValue('REG_DATE_END'));
                setVar('REC_DATE', null);
                setVar('REC_DATE_END', null);
            }

            startMultiDataSetsGroup();
            refreshDataSet('DS_CASH', true);
            refreshDataSet('DS_FULL_SUMM', true);
            endMultiDataSetsGroup();
        }
        Form.SetEmptyDate = function () {
            var str = getValue('DATE_TYPE');
            setValue(str, null);
        }

        Form.CHANGE_DATA_TYPE = function () {
            var str = getValue('DATE_TYPE');
            if (str == "REG_DATE") {
                getControlByName("DivRecDate").style.display = "none";
                getControlByName("DivRegDate").style.display = "";
                setValue('REC_DATE', null);
                if (empty(getValue('REG_DATE'))) {
                    setValue('REG_DATE', getVar('SYS_DATE'));
                    setValue('REG_DATE_END', getVar('SYS_DATE'));
                }
            }
            else if (str == "REC_DATE") {
                getControlByName("DivRecDate").style.display = "";
                getControlByName("DivRegDate").style.display = "none";
                setValue('REG_DATE', null);
                if (empty(getValue('REC_DATE'))) {
                    setValue('REC_DATE', getVar('SYS_DATE'));
                    setValue('REC_DATE_END', getVar('SYS_DATE'));
                }
            }
        }

        Form.Pay = function (_dom) {
            setVar('PAY_STATUS', getControlValue(_dom));
            setVar('PAY_REASON', getControlProperty('CASH_GRID', 'data')['SERVICE_NAME']); //getControlProperty('CASH_GRID','data')['SE_CODE']+' '+
            if (getVar('PAY_STATUS') == 0) {
                if (confirm('Отменить последнюю операцию?')) {
                    setControlProperty('CASH_GRID', 'locate', getValue('CASH_GRID'));
                    setVar('CONTR_PAY_DELID', getValue('CASH_GRID'));
                    executeAction('cancelLastPayment', function () {
                        base().RefreshCashDataSets();
                    }, function () {
                        setControlValue(_dom, 1);
                    })
                }
            }
            else {
                setVar('CONTR_PAY_ID', getValue('CASH_GRID'));
                setVar('SUMM_TO_PAY', getControlProperty('CASH_GRID', 'data')['DEBT_SUMM']);
                executeAction('GET_DOC_TYPES', function () {
                    if (empty(getVar('DOC_TYPE_GET')) == true) {
                        executeAction('actionSetPaid', function () {
                            setControlProperty('CASH_GRID', 'locate', getValue('CASH_GRID'));
                            base().RefreshCashDataSets();
                        }, function () {
                            setControlValue(_dom, 0);
                        })
                    } else {
                        base().SetPayContrSpec();
                    }
                });
            }
        }
        Form.ReportCashPrint = function () {
            setVar('REPORT_B', getValue('REC_DATE'));
            setVar('REPORT_E', getValue('REC_DATE_END'));
            openWindow('Reports/Cash/cashselect', true);
        }
        Form.Search = function () {
            base().RefreshCashDataSets();
        }
        Form.ONPP = function () {
            if (!empty(getValue('CASH_GRID'))) {
                PopUpItem_SetHide(getControlByName('pCash'), 'pFacAcc', false);

                if (parseFloat(getControlProperty('CASH_GRID', 'data')['PAID_SUMM']) == 0) {    // отображение квитанции 
                    PopUpItem_SetDisable(getControlByName('pCash'), 'pPrintReceipt52n', true);
                }
                else {
                    PopUpItem_SetDisable(getControlByName('pCash'), 'pPrintReceipt52n', false);
                }



            if (parseFloat(getControlProperty('CASH_GRID', 'data')['PAID_SUMM']) == 0) {    // отображение квитанции  тест
                    PopUpItem_SetDisable(getControlByName('pCash'), 'pPrintReceipt52n1', true);
                }
                else {
                    PopUpItem_SetDisable(getControlByName('pCash'), 'pPrintReceipt52n1', false);
                }

            if (parseFloat(getControlProperty('CASH_GRID', 'data')['PAID_SUMM']) == 0) {    // отображение квитанции  kb123
                    PopUpItem_SetDisable(getControlByName('pCash'), 'pPrintReceipt52nkb123', true);
                }
                else {
                    PopUpItem_SetDisable(getControlByName('pCash'), 'pPrintReceipt52nkb123', false);
                }

                if (parseFloat(getControlProperty('CASH_GRID', 'data')['PAID_SUMM']) == 0) {    // отображение квитанции 1-поликлиника
                    PopUpItem_SetDisable(getControlByName('pCash'), 'pPrintReceipt52n1_pk', true);
                }
                else {
                    PopUpItem_SetDisable(getControlByName('pCash'), 'pPrintReceipt52n1_pk', false);
                }

                if (getControlProperty('CASH_GRID', 'data')['STATUS'] == 0) {
                    PopUpItem_SetHide(getControlByName('pCash'), 'pPrintContr', false);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pPrintIS', false);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pPrintListServs', false);

                    PopUpItem_SetHide(getControlByName('pCash'), 'pConnAv', false);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pSetPayContract', false);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pFixSumm', false);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pCancLastPaym', false);
                    if (getControlProperty('CASH_GRID', 'data')['SIGN_PAID'] == 0 || getControlProperty('CASH_GRID', 'data')['SIGN_PAID'] == 3) {
                        PopUpItem_SetHide(getControlByName('pCash'), 'pSetPayService', true);
                    }
                    else {
                        PopUpItem_SetHide(getControlByName('pCash'), 'pSetPayService', false);
                    }
                    if (getControlProperty('CASH_GRID', 'data')['SIGN_PAID'] == 2) {
                        PopUpItem_SetHide(getControlByName('pCash'), 'pGetMoneyBack', true);
                    }
                    else {
                        PopUpItem_SetHide(getControlByName('pCash'), 'pGetMoneyBack', false);
                    }
                    if (parseFloat(getControlProperty('CASH_GRID', 'data')['CONTRACT_SUMM'].replace(',', '.')) > parseFloat(getControlProperty('CASH_GRID', 'data')['SUMM_SERVICE'].replace(',', '.'))) {
                        PopUpItem_SetHide(getControlByName('pCash'), 'pSetPayContract', false);
                        PopUpItem_SetHide(getControlByName('pCash'), 'pServsInContr', false);
                    }
                    else {
                        PopUpItem_SetHide(getControlByName('pCash'), 'pSetPayContract', true);
                        PopUpItem_SetHide(getControlByName('pCash'), 'pServsInContr', true);
                    }
                    if (parseFloat(getControlProperty('CASH_GRID', 'data')['PAID_SUMM'].replace(',', '.')) == 0 &amp;&amp; parseFloat(getControlProperty('CASH_GRID', 'data')['SUMM_SERVICE'].replace(',', '.')) == 0) {
                        PopUpItem_SetHide(getControlByName('pCash'), 'pGetMoneyBack', true);
                    }
                    PopUpItem_SetHide(getControlByName('pCash'), 'pViewPays', false);
                    PopUpItem_SetHide(getControlByName('pCash'), 'line1', false);
                    PopUpItem_SetHide(getControlByName('pCash'), 'line2', false);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pCancAnn', true);
                    PopUpItem_SetHide(getControlByName('pCash'), 'psetNull', false);
                }
                else {

                    PopUpItem_SetHide(getControlByName('pCash'), 'pPrintContr', true);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pPrintIS', true);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pPrintListServs', true);

                    PopUpItem_SetHide(getControlByName('pCash'), 'pServsInContr', true);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pSetPayService', true);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pGetMoneyBack', true);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pSetPayContract', true);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pCancLastPaym', true);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pConnAv', true);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pFixSumm', true);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pViewPays', true);
                    PopUpItem_SetHide(getControlByName('pCash'), 'line1', true);
                    PopUpItem_SetHide(getControlByName('pCash'), 'line2', false);
                    PopUpItem_SetHide(getControlByName('pCash'), 'pCancAnn', false);
                    PopUpItem_SetHide(getControlByName('pCash'), 'psetNull', true);
                }
            }
            else {
                PopUpItem_SetHide(getControlByName('pCash'), 'pPrintContr', true);
                PopUpItem_SetHide(getControlByName('pCash'), 'pPrintIS', true);
                PopUpItem_SetHide(getControlByName('pCash'), 'pPrintListServs', true);
                PopUpItem_SetHide(getControlByName('pCash'), 'pConnAv', true);
                PopUpItem_SetHide(getControlByName('pCash'), 'pServsInContr', true);
                PopUpItem_SetHide(getControlByName('pCash'), 'pSetPayService', true);
                PopUpItem_SetHide(getControlByName('pCash'), 'pGetMoneyBack', true);
                PopUpItem_SetHide(getControlByName('pCash'), 'pSetPayContract', true);
                PopUpItem_SetHide(getControlByName('pCash'), 'pCancLastPaym', true);
                PopUpItem_SetHide(getControlByName('pCash'), 'pFixSumm', true);
                PopUpItem_SetHide(getControlByName('pCash'), 'pViewPays', true);
                PopUpItem_SetHide(getControlByName('pCash'), 'line1', true);
                PopUpItem_SetHide(getControlByName('pCash'), 'line2', true);
                PopUpItem_SetHide(getControlByName('pCash'), 'pFacAcc', true);
                PopUpItem_SetHide(getControlByName('pCash'), 'pCancAnn', true);
                PopUpItem_SetHide(getControlByName('pCash'), 'psetNull', true);
                PopUpItem_SetDisable(getControlByName('pCash'), 'pPrintReceipt52n', true);
            }
            setVar('AGENT_ID', getControlProperty('CASH_GRID', 'data')['AG_ID']);
            setVar('PATIENT_ID', getControlProperty('CASH_GRID', 'data')['PAT_ID']);
            setVar('CONTRACT_ID', getControlProperty('CASH_GRID', 'data')['CONTRACT_ID']);
            setVar('DIR_SERVICE', getControlProperty('CASH_GRID', 'data')['DIR_SERV_ID']);
            setVar('CONTR_PAY_ID', getValue('CASH_GRID'));

            // #165690: на этой форме отчёт с кодом "rec_cont" (автосгенерированный PopupItem по разделу) не должен
            // получать CONTR_PAY_ID, чтобы печататься по контракту целиком
            if (!Form.isSetContractReportFlusher) {
                var popup = getControlByName('pCash').popup.allItems;
                for (var i = 0, l = popup.length; i &lt; l; i++) {
                    if (popup[i].name == 'PI_rec_cont' || popup[i].name == 'PI_reception_contract') {
                        popup[i].action = 'setVar("CONTR_PAY_ID", null); ' + popup[i].action;
                        break;
                    }
                }
                Form.isSetContractReportFlusher = true;
            }
        }

        Form.PrintContractZakazchik = function () {
            setVar('FLAG', 'CONTR');
            setVar('REP_ID', getControlProperty('CASH_GRID', 'data')['CONTRACT_ID']);
            setVar('AGENT_ID', getControlProperty('CASH_GRID', 'data')['AG_ID']);
            printReportByCode('reception_contract_zakazchik');
        }
        Form.PrintAgreementPersInfo = function () {
            setVar('REP_ID', getControlProperty('CASH_GRID', 'data')['DIR_SERV_ID']);
            setVar('AGENT_ID', getControlProperty('CASH_GRID', 'data')['AG_ID']);
            printReportByCode('reception_agreement_personal_info');
        }
        Form.PrintAgreementNark = function () {
            setVar('PATIENT_ID', getControlProperty('CASH_GRID', 'data')['PAT_ID']);
            printReportByCode('patient_agreement_narkolog');
        }
        Form.PrintTaxNote = function () {
            setVar('CONTRACT_ID', getControlProperty('CASH_GRID', 'data')['CONTRACT_ID']);
            openWindow('Reports/Tax/tax_note_call', true);
        }
        Form.PrintAcceptionAct = function () {
            setVar('CONTRACT_ID', getControlProperty('CASH_GRID', 'data')['CONTRACT_ID']);
            printReportByCode('finished_work_acception_act');
        }
        Form.PrintReceipt52n = function () {
            openWindow({
                'name': 'Reports/Cash/receipt_52_n_call', vars: {
                    'CONTRACT_ID': getControlProperty('CASH_GRID', 'data')['CONTRACT_ID']
                }
                }, true);
        }

        Form.PrintReceipt52nkb123 = function () {                            //добавление сылки на выбор квитанции из кассы кб123
            openWindow({
                'name': 'Reports/Reception/receipt_call', vars: {
                    'CONTRACT_ID': getControlProperty('CASH_GRID', 'data')['CONTRACT_ID']
                }
                }, true);
        }
        Form.pPrintReceipt52n1_pk = function () {                            //добавление сылки на выбор квитанции из кассы 1 поликлинка
            openWindow({
                'name': 'Reports/Reception/receipt_call2', vars: {
                    'CONTRACT_ID': getControlProperty('CASH_GRID', 'data')['CONTRACT_ID']
                }
                }, true);
        }


        Form.PrintReceipt52n1 = function () {
            setVar('CONTRACT_ID', getControlProperty('CASH_GRID', 'data')['CONTRACT_ID'])
                    printReportByCode('receipt_52_n1');
        }
               

        Form.SetPayContrSpec = function () {
            executeAction('GET_DOC_TYPES', function () {
                setVar('SUMM_TO_PAY', getControlProperty('CASH_GRID', 'data')['DEBT_SUMM']);
                setVar('PAY_REASON', getControlProperty('CASH_GRID', 'data')['SERVICE_NAME']); //getControlProperty('CASH_GRID','data')['SE_CODE']+' '+
                setVar('CONTR_PAY_ID', getValue('CASH_GRID'));
                openWindow('Cash/set_pay_contract_spec', true, 840, 400)
                        .addListener('onclose',
                                function () {
                                    if (getVar('ModalResult', 1) == 1) {
                                        setControlProperty('CASH_GRID', 'locate', getVar("CONTR_PAY_ID", 1), 1);
                                        base(1).RefreshCashDataSets();
                                    }
                                },
                                null,
                                false);
            });
        }
        Form.GetMoneyBack = function () {
            setVar('PAID_SUMM', getControlProperty('CASH_GRID', 'data')['PAID_SUMM']);
            setVar('PAY_REASON', getControlProperty('CASH_GRID', 'data')['SERVICE_NAME']); //getControlProperty('CASH_GRID','data')['SE_CODE']+' '+
            setVar('CONTR_PAY_ID', getValue('CASH_GRID'));
            openWindow('Cash/get_back_pay_cs', true, 840, 400)
                    .addListener('onclose',
                            function () {
                                if (getVar('ModalResult', 1) == 1) {
                                    setControlProperty('CASH_GRID', 'locate', getVar("CONTR_PAY_ID", 1), 1);
                                    base(1).RefreshCashDataSets();
                                }
                            },
                            null,
                            false);
        }

        Form.SetPayContract = function () {
            setVar('SUMM_TO_PAY_CONTR', getControlProperty('CASH_GRID', 'data')['CONTRACT_SUMM']);
            setVar('CONTARCT_ID', getControlProperty('CASH_GRID', 'data')['CONTRACT_ID']);
            setVar('CONTR_PAY_ID', getValue('CASH_GRID'));
            openWindow('Cash/set_pay_contract', true, 840, 400)
                    .addListener('onclose',
                            function () {
                                if (getVar('ModalResult', 1) == 1) {
                                    setControlProperty('CASH_GRID', 'locate', getVar("CONTR_PAY_ID", 1), 1);
                                    base(1).RefreshCashDataSets();
                                }
                            },
                            null,
                            false);
        }
        Form.CancelLastPayment = function () {
            if (confirm('Отменить последнюю операцию?')) {
                setControlProperty('CASH_GRID', 'locate', getValue('CASH_GRID'));
                setVar('CONTR_PAY_DELID', getValue('CASH_GRID'));
                executeAction('cancelLastPayment', function () {
                    base().RefreshCashDataSets();
                })
            }
        }

        Form.FixSumm = function () {
            setVar('CONTR_PAY_ID', getValue('CASH_GRID'));
            setVar('PATIENT_ID', getControlProperty('CASH_GRID', 'data')['PAT_ID']);
            openWindow('Cash/fix_summ', true, 600, 410)
                    .addListener('onclose',
                            function () {
                                if (getVar('ModalResult', 1) == 1) {
                                    setControlProperty('CASH_GRID', 'locate', getVar("CONTR_PAY_ID", 1), 1);
                                    base(1).RefreshCashDataSets();
                                }
                            },
                            null,
                            false);
        }

        Form.onPaint = function (_dataArray, _activRow) {
            var _domObject = _activRow;
            switch (parseInt(_dataArray['SIGN_PAID'])) {
                case 0: { //оплачено полностью
                    getControlByName('SSE').style.backgroundColor = '';
                    break;
                }
                case 1: { //оплачено частично
                    getControlByName('SSE').style.backgroundColor = '#FFFF99';
                    break;
                }
                case 2: { //не оплачено
                    getControlByName('SSE').style.backgroundColor = '#FF9999';
                    break;
                }
                case 3: { //бесплатно
                    getControlByName('SSE').style.backgroundColor = '';
                    break;
                }
                default : { //иначе - не должно срабатывать!
                    getControlByName('SSE').style.backgroundColor = '';
                }
            }
            switch (parseInt(_dataArray['STATUS'])) //ан.
            {
                case 0: { //нет
                    getControlByName('PAT').style.backgroundColor = '';
                    getControlByName('DOC').style.backgroundColor = '';
                    getControlByName('SEC').style.backgroundColor = '';
                    getControlByName('SEN').style.backgroundColor = '';
                    getControlByName('EMP').style.backgroundColor = '';
                    getControlByName('REC').style.backgroundColor = '';
                    getControlByName('IFP').style.backgroundColor = '';
                    getControlByName('SCO').style.backgroundColor = '';
                    //getControlByName('REG').style.backgroundColor='';
                    //getControlByName('PAYDAT').style.backgroundColor='';
                    setControlProperty('main_cb_pay', 'enabled', true);
                    break;
                }
                case 1: { //ан.
                    getControlByName('PAT').style.backgroundColor = '#C5C5C5';
                    getControlByName('DOC').style.backgroundColor = '#C5C5C5';
                    getControlByName('SEC').style.backgroundColor = '#C5C5C5';
                    getControlByName('SEN').style.backgroundColor = '#C5C5C5';
                    getControlByName('EMP').style.backgroundColor = '#C5C5C5';
                    getControlByName('REC').style.backgroundColor = '#C5C5C5';
                    getControlByName('IFP').style.backgroundColor = '#C5C5C5';
                    getControlByName('SCO').style.backgroundColor = '#C5C5C5';
                    //getControlByName('REG').style.backgroundColor='#C5C5C5';
                    getControlByName('SSE').style.backgroundColor = '#C5C5C5';
                    //getControlByName('PAYDAT').style.backgroundColor='#C5C5C5';
                    setControlProperty('main_cb_pay', 'enabled', false);
                    break;
                }
                default : { //иначе - не должно срабатывать!
                    getControlByName('PAT').style.backgroundColor = '';
                    getControlByName('DOC').style.backgroundColor = '';
                    setControlProperty('main_cb_pay', 'enabled', true);
                }
            }
        }

        Form.ViewServsList = function () {
            setVar('CONTRACT_ID', getControlProperty('CASH_GRID', 'data')['CONTRACT_ID']);
            setVar('CONTR_PAY_ID', getValue('CASH_GRID'));
            openWindow('Cash/view_services', true, 840, 400)
                    .addListener('onclose',
                            function () {
                                setControlProperty('CASH_GRID', 'locate', getVar("CONTR_PAY_ID", 1), 1);
                                base(1).RefreshCashDataSets();
                            },
                            null,
                            false);
        }

        Form.ViewPaysAv = function () //метка
        {
            setVar('CONTRACT_ID', getControlProperty('CASH_GRID', 'data')['CONTRACT_ID']);
            setVar('CONTR_PAY_ID', getValue('CASH_GRID'));
            setVar('FAC_ACC', getControlProperty('CASH_GRID', 'data')['FACIAL_ACCOUNT']);
            setVar('SUMM_TO_PAY', getControlProperty('CASH_GRID', 'data')['SUMM_SERVICE']);
            openWindow('Cash/view_pays_av', true, 1000, 600)
                    .addListener('onclose',
                            function () {
                                setControlProperty('CASH_GRID', 'locate', getVar("CONTR_PAY_ID", 1), 1);
                                base(1).RefreshCashDataSets();
                            },
                            null,
                            false);
        }

        Form.ViewPays = function () {
            setVar('CONTR_PAY_ID', getValue('CASH_GRID'));
            setVar('FAC_ACC', getControlProperty('CASH_GRID', 'data')['FACIAL_ACCOUNT']);
            setVar('PJ_TYPE', 1);
            openWindow('Cash/view_pays', true, 1000, 600)
                    .addListener('onclose',
                            function () {
                                setControlProperty('CASH_GRID', 'locate', getVar("CONTR_PAY_ID", 1), 1);
                                base(1).RefreshCashDataSets();
                            },
                            null,
                            false);
        }
        Form.fac_acc = function () {
            var pmc_array = getControlProperty('CASH_GRID', 'data');
            setVar('PERSMEDCARD', pmc_array['PAT_ID']);
            executeAction('getAG_ID', null, null, null, 0, 0);
            openWindow('PersonalAccount/patient_contracts', true, 1114, 651);
        }

        Form.CancelAnn = function () {
            if (confirm('Отменить аннулирование?')) {
                setVar('STATUS', 0);
                executeAction('Annul', function () {
                            setControlProperty('CASH_GRID', 'locate', getValue('CASH_GRID'));
                            base().RefreshCashDataSets();
                        }
                );
            }
        }
        Form.setNull = function () {
            if (confirm('Аннулировать услугу?')) {
                setVar('STATUS', 1);
                executeAction('Annul', function () {
                            setControlProperty('CASH_GRID', 'locate', getValue('CASH_GRID'));
                            base().RefreshCashDataSets();
                        }
                );
            }
        }
        Form.ADD_PERSMEDCARD = function (_dom) {
            setVar('PERSMEDCARD', getControlValue(_dom));
            setVar('LOC', getValue('CASH_GRID'));
            openWindow('Persmedcard/persmedcard_edit', true, 800, 580)
                    .addListener('onclose',
                            function () {
                                if (getVar('ModalResult', 1) == 1) {
                                    setControlProperty('CASH_GRID', 'locate', getVar('LOC', 1), 1);
                                    refreshDataSet('DS_CASH', true, 1);
                                }
                            },
                            null,
                            false);
        }
        Form.ViewDiscount = function () {
            setVar('CONTRACT_ID', getControlProperty('CASH_GRID', 'data')['CONTRACT_ID']);
            setVar('CONTR_PAY_ID', getValue('CASH_GRID'));
            setVar('FAC_ACC', getControlProperty('CASH_GRID', 'data')['FACIAL_ACCOUNT']);
        }
        /*86449*/
        Form.zReportCreate = function () {
            executeAction('Z_ACTION', function () {
                showAlert('Z-отчет c ' + getVar('IS_TIME') + ' по ' + getVar('IS_TIME_1') + ' сформирова н успешно');
            });
        }
        ]]>
    </component>
    <component cmptype="Script" name="PrintContract">
        <![CDATA[
            Form.PrintContract=function(){
                setVar('FLAG','CONTR');
                setVar('REP_ID', getControlProperty('CASH_GRID','data')['CONTRACT_ID']);
                setVar('AGENT_ID', getControlProperty('CASH_GRID','data')['AG_ID']);
                setVar('DS_ID', '');
                setVar('CONTRACT_ID', getControlProperty('CASH_GRID','data')['CONTRACT_ID']);
                setVar('PATIENT_ID', getControlProperty('CASH_GRID', 'data')['PAT_ID']);
                printReportByCode('reception_contract');
            }
        ]]>
    </component>
    <component cmptype="Action" name="Z_ACTION">
        declare
            nNUMB                number(5);
            nID                  number(17);
            dDATE_MAX            DATE;
            IS_TIME              DATE;
            IS_TIME_1            DATE;
        begin
            nNUMB := D_PKG_Z_CASH_REPORTS.GEN_NUMB(:pnLPU);
            dDATE_MAX := D_PKG_Z_CASH_REPORTS.GEN_TIME(:pnLPU,sysdate,:pnCASH_SECTION);
            D_PKG_Z_CASH_REPORTS.ADD(nID, :pnLPU, nNUMB, sysdate, dDATE_MAX, :pnEMPLOYER, :pnCASH_SECTION);
            D_PKG_Z_CASH_REPORTS.GENERATE_REPORT(nID,:pnLPU);
            :IS_TIME := to_char(dDATE_MAX, 'dd:mm:yyyy hh24:mi:ss');
            :IS_TIME_1 := to_char(sysdate, 'dd:mm:yyyy hh24:mi:ss');
        end;
        <component cmptype="ActionVar" name="pnLPU"          src="LPU"          srctype="session"/>
        <component cmptype="ActionVar" name="pnEMPLOYER"     src="EMPLOYER"     srctype="session"/>
        <component cmptype="ActionVar" name="pnCASH_SECTION" src="CASH_SECTION" srctype="var" get="p3" len="17"/>
        <component cmptype="ActionVar" name="IS_TIME"        src="IS_TIME"      srctype="var" put="v1" len="20"/>
        <component cmptype="ActionVar" name="IS_TIME_1"      src="IS_TIME_1"    srctype="var" put="v2" len="20"/>
    </component>
    <component cmptype="Action" name="INIT_ACTION">
            begin
                :SYS_DATE := sysdate;
                :SYS_DATE_LABEL := to_char(sysdate,'dd Month YYYY','NLS_DATE_LANGUAGE=RUSSIAN');
                :LPU := '='||:pnLPU;
                :pnCASH_SECTION := d_pkg_cash_sections.get_section(pncablab => :pnCABLAB,
                                                                      pnlpu => :pnLPU);
                IF :pnCASH_SECTION is not null then
                    select ' ('||t.CS_NAME||')'
                      into :psNAME
                      from d_v_cash_sections t
                     where t.ID = :pnCASH_SECTION;
                ELSE
                    :psNAME := ' (Касса не выбрана)';
                END IF;
            end;
        <component cmptype="ActionVar" name="pnLPU"          src="LPU"            srctype="session"/>
        <component cmptype="ActionVar" name="pnCABLAB"       src="CABLAB"         srctype="session"/>
        <component cmptype="ActionVar" name="SYS_DATE"       src="SYS_DATE"       srctype="var"         put="v0" len="20"/>
        <component cmptype="ActionVar" name="SYS_DATE_LABEL" src="SYS_DATE_LABEL" srctype="var"         put="v1" len="25"/>
        <component cmptype="ActionVar" name="LPU"            src="LPU"            srctype="var"         put="v2" len="17"/>
        <component cmptype="ActionVar" name="pnCASH_SECTION" src="CASH_SECTION"   srctype="var"         put="p3" len="17"/>
        <component cmptype="ActionVar" name="psNAME"         src="cashsectname"   srctype="ctrlcaption" put="p4" len="200"/>
    </component>

     <component cmptype="Action" name="SET_DIVISION">
        declare
            div VARCHAR2(40);
        begin
            div :=d_pkg_option_specs.get('DivisionsDefault',:pnLPU);
            select dd.id
              into :DIVISION
              from d_v_divisions dd
             where dd.div_name = div;
            exception WHEN OTHERS THEN :DIVISION := null;

        end;
        <component cmptype="ActionVar" name="pnLPU"    src="LPU"       srctype="session"/>
        <component cmptype="ActionVar" name="DIVISION" src="DIVISIONS" srctype="ctrl" put="v1" len="100"/>
    </component>

    <component cmptype="Action" name="Annul">
        begin
            d_pkg_contract_payments.set_status(:pnid, :pnlpu, :pnstatus);
        end;
        <component cmptype="ActionVar" name="pnid"     src="CASH_GRID" srctype="ctrl" get="v1"/>
        <component cmptype="ActionVar" name="pnlpu"    src="LPU"       srctype="session"/>
        <component cmptype="ActionVar" name="pnstatus" src="STATUS"    srctype="var"  get="v2"/>
    </component>
    <component cmptype="Action" name="getAG_ID">
        begin
            select t.AGENT
              into :AG_ID
              from d_v_persmedcard t
             where t.ID = :PMC_ID;
        end;
        <component cmptype="ActionVar" name="LPU"    src="LPU"         srctype="session"/>
        <component cmptype="ActionVar" name="PMC_ID" src="PERSMEDCARD" srctype="var" get="v1"/>
        <component cmptype="ActionVar" name="AG_ID"  src="AGENT"       srctype="var" put="v2" len="17"/>
    </component>
    <component cmptype="Action" name="cancelLastPayment">
        begin
            d_pkg_contract_payments.cancel_last_payment(pnid => :DEL_ID,
                                                      pnlpu => :LPU);
        end;
        <component cmptype="ActionVar" name="LPU"	src="LPU"		srctype="session"/>
        <component cmptype="ActionVar" name="DEL_ID"	src="CONTR_PAY_DELID"	srctype="var" get="v1"/>
    </component>
    <component cmptype="Action" name="GET_DOC_TYPES">
        begin
            SELECT t.ID
              INTO :DOC_TYPE_GET
              FROM d_v_doc_types t, d_v_doc_accessories d
             WHERE t.VERSION = d_pkg_versions.get_version_by_lpu(0, :LPU, 'DOC_TYPES')
               AND d.DOC_TYPE = t.ID
               AND d.UNITCODE = 'PAYMENT_JOURNAL'
               AND d.DOC_KIND = 0
               AND d.LPU = :LPU
               AND t.DT_CODE = d_pkg_option_specs.get('CashDocTypes', :LPU);
               exception when no_data_found then null;
        end;
        <component cmptype="ActionVar" name="LPU"           src="LPU"          srctype="session"/>
        <component cmptype="ActionVar" name="DOC_TYPE_GET"  src="DOC_TYPE_GET" srctype="var" put="v6" len="200"/>
    </component>
    <component cmptype="Action" name="actionSetPaid">
        declare IDCURR NUMBER(17);
                PAY_METH NUMBER(17);
                CASH_DEP NUMBER(17);
        begin
            IDCURR := d_pkg_currencies.get_main(:LPU);
            IF IDCURR is null THEN
                D_P_EXC('Не задана основная валюта.');
            END IF;

            begin
                select tt.ID
                  into PAY_METH
                  from d_v_payment_methods tt
                 where tt.LPU = :LPU
                   and tt.PM_CODE =  d_pkg_option_specs.get('CashPaymentMethod',:LPU);
                exception when no_data_found then PAY_METH := null;
            end;

            begin
                select ttt.ID
                  into CASH_DEP
                  from d_v_cash_deps ttt
                 where ttt.LPU = :LPU
                   and ttt.CD_CODE =  d_pkg_option_specs.get('UserCashDep',:LPU);
                exception when no_data_found then CASH_DEP := null;
            end;

            d_pkg_contract_payments.set_paid(pnid => :pnid,
                                            pnlpu => :LPU,
                                       pnpay_summ => :pnpay_summ,
                                       pncurrency => IDCURR,
                                       pnemployer => d_pkg_employers.get_id(:LPU),
                                 pnpayment_method => PAY_METH,
                                   pnpayment_type => 0,
                                      pnoper_type => 0,
                                       pdpay_date => /*trunc(*/ sysdate /*)*/,
                                   pncash_section => :pnCASH_SECTION,
                                       pncash_dep => CASH_DEP,
                                      psagent_fio => null,
                                       pndoc_type => null,
                                       psdoc_numb => null,
                                       pddoc_date => null,
                                 pncancel_payment => 0,
                                 pspayment_reason => :PAY_REASON);
        end;
        <component cmptype="ActionVar" name="LPU"            src="LPU"           srctype="session"/>
        <component cmptype="ActionVar" name="CABLAB"         src="CABLAB"        srctype="session"/>
        <component cmptype="ActionVar" name="pnid"           src="CONTR_PAY_ID"  srctype="var" get="v1"/>
        <component cmptype="ActionVar" name="pnpay_summ"     src="SUMM_TO_PAY"   srctype="var" get="v2"/>
        <component cmptype="ActionVar" name="PAY_REASON"     src="PAY_REASON"    srctype="var" get="v3"/>
        <component cmptype="ActionVar" name="pnCASH_SECTION" src="CASH_SECTION"  srctype="var" get="v4"/>
    </component>
    <component cmptype="DataSet" activateoncreate="false" name="DS_FULL_SUMM">
            <![CDATA[
                    select D_PKG_PAYMENT_JOURNAL.GET_DAILY_PAYMENTS(:pnCASH_SECTION,:pnLPU,to_date(:pdDATE_CASH,'dd.mm.yyyy'),to_date(:pdDATE_CASH_END,'dd.mm.yyyy'))  FULL_SUMM
                    from dual
            ]]>
        <component cmptype="Variable" name="pnLPU"	         src="LPU"                    srctype="session"/>
        <component cmptype="Variable" name="pdDATE_CASH"     src="DATE_CASH"     get="v0" srctype="var"/>
        <component cmptype="Variable" name="pdDATE_CASH_END" src="DATE_CASH_END" get="v3" srctype="var"/>
        <component cmptype="Variable" name="pnCASH_SECTION"  src="CASH_SECTION"  get="v1" srctype="var"/>
    </component>
    <component cmptype="DataSet" name="DS_CASH" activateoncreate="false" mode="Range" compile="true">
    <![CDATA[
        select t.CONTR_PAY_ID CON_PAYS_ID,
               t.PAT_FULL_NAME,
               t.SREC_DATE REC_DATE,
               t.DOC_PREF||'/'||t.DOC_NUMB 	sDOC_NUMB,
               t.IS_FULLY_PAID,
               t.DEBT_SUMM,
               t.CONTR_DEBT_SUM CONTRACT_SUMM,
               t.SERVICE_CODE SE_CODE,
               t.SERVICE_NAME,
               t.REG_DATE,
               t.KOD_VRACHA||' '||t.EMP_FULL_NAME EMPLOYER,
               (select v.EMPLOYER_FIO
                  from D_V_VISITS v
                 where v.ID = t.VISIT_ID
               ) VISIT_EMPLOYER,
               t.DOC_PREF||t.DOC_NUMB 	PREF_NUM_STR,
               t.DIR_SERV_ID,
               t.SUMM PAID_SUMM,
               t.DIR_SUMM,
               t.CONTRACT_ID,
               t.DEBT_SUMM  SUMM_SERVICE,
               t.CONTR_DEBT_SUM  SUMM_CONTR,
               t.FACIAL_ACCOUNT,
               t.CONTR_AGENT_ID AG_ID,
               t.PAT_ID,
               t.PAT_AGENT_ID,
               case when t.IS_FULLY_PAID = 1 then 0
                    when t.SUMM > 0 then 1
                    when t.DIR_SUMM = 0 then 3
                    else  2
               end SIGN_PAID,
               t.STATUS,
               t.SURNAME,
               t.FIRSTNAME,
               t.LASTNAME,
               t.DOC_PREF,
               t.DOC_NUMB,
               t.KOD_VRACHA,
               t.EMP_FULL_NAME,
               t.SERVICE_ID,
               t.DC_TYPE,
               t.LPU,
               (select decode(t2.BONUS_SUMM,null,null,'Пациенту начислены бонусы в размере '||t2.BONUS_SUMM||' руб.') BONUS_SUMM
                  from D_V_PMC_DS_CARDS t1
                       join D_V_DISCOUNT_CARDS t2 on t2.ID = t1.DISCOUNT_CARD_ID
                 where (t1.END_DATE is null or t1.END_DATE > sysdate)
                   AND t2.BONUS_SUMM > 0
                   AND t.PAT_ID = t1.PID
               ) BONUS_SUMM,
               case when t.TTYPE = 1 then t.SREC_DATE
               end RREC_DATE
          from D_V_SYS_CASH t
               left join D_V_DIRECTION_SERVICES_BASE ds on ds.ID = t.DIR_SERV_ID and ds.SERV_STATUS != 2
        where (D_PKG_CSE_ACCESSES.CHECK_RIGHT(pnLPU => :LPU,
                                         psUNITCODE => 'DIVISIONS',
                                          pnUNIT_ID => t.DIVISION,
                                            psRIGHT => 3,
                                           pnCABLAB => :CABLAB,
                                          pnSERVICE => null) = 1
                or t.DIVISION is null)
          @if(:DIVISION){
           and t.DIVISION = :DIVISION
          @}
        ]]>
        <component cmptype="Variable" type="count"    srctype="var"     src="ds1count" default="10"/>
        <component cmptype="Variable" type="start"    srctype="var"     src="ds1start" default="1"/>
        <component cmptype="Variable" name="LPU"      srctype="session" src="LPU"/>
        <component cmptype="Variable" name="CABLAB"   srctype="session" src="CABLAB"/>
        <component cmptype="Variable" name="DIVISION" srctype="ctrl"    src="DIVISIONS" get="v0" />
    </component>
    <component cmptype="Action" name="getSYS_DATE_LAST_NEXT">
            begin
                :SYS_DATELN := to_char(to_date(:SYS_DATE)+:DATE_NUM,'dd.mm.yyyy');
                :SYS_DATE_ENDLN := to_char(to_date(:SYS_DATE_END)+:DATE_NUM,'dd.mm.yyyy');
            end;
        <component cmptype="ActionVar" name="SYS_DATE"       src="SYS_DATENOW"     srctype="var" get="SYS_DATELN"/>
        <component cmptype="ActionVar" name="SYS_DATE_END"   src="SYS_DATE_ENDNOW" srctype="var" get="SYS_DATE_ENDLN"/>
        <component cmptype="ActionVar" name="SYS_DATELN"     src="SYS_DATELN"      srctype="var" put="SYS_DATE2" len="50"/>
        <component cmptype="ActionVar" name="SYS_DATE_ENDLN" src="SYS_DATE_ENDLN"  srctype="var" put="SYS_DATE3" len="50"/>
        <component cmptype="ActionVar" name="DATE_NUM"       src="DATE_NUM"        srctype="var" get="var2"/>
    </component>
    <component cmptype="Action" name="ACTION_SET_PAY_STATUS" action="SET_PAY_STATUS" unit="CONTRACT_PAYMENTS">
        <component cmptype="ActionVar" name="PNLPU"        src="LPU"        srctype="session"/>
        <component cmptype="ActionVar" name="PNCONTR_PAY"  src="CONTR_PAY"  srctype="var" get="var2"/>
        <component cmptype="ActionVar" name="PNPAY_STATUS" src="PAY_STATUS" srctype="var" get="var3"/>
    </component>
    <div class="blockBackground">
        <div style="padding:15px;">
            <table cmptype="bogus" oncreate="base().OnCreate()">
                <tr style="height:0%;">
                    <td  style="padding-right:2pt;">
                        <component cmptype="Button" type="small" icon="Icons/control_l" title="Назад" onclick="base().MOVE_DATE(-1);"/>
                    </td>
                    <td cmptype="bogus" style="white-space:nowrap;padding-right:2pt;" name="DivRegDate">
                        <component cmptype="DateEdit" name="REG_DATE" onkeypress="onEnter(function(){base().DateRefreshDate();})" width="100"/>
                        <component cmptype="Label" caption=" - "/>
                        <component cmptype="DateEdit" name="REG_DATE_END" onkeypress="onEnter(function(){base().DateRefreshDate();})" width="100"/>
                    </td>
                    <td cmptype="bogus" style="white-space:nowrap;padding-right:2pt;display:none;" name="DivRecDate">
                        <component cmptype="DateEdit" name="REC_DATE" onkeypress="onEnter(function(){base().DateRefreshDate();})" width="100" typeMask="date" emptyMask="false"/>
                        <component cmptype="Label" caption=" - "/>
                        <component cmptype="DateEdit" name="REC_DATE_END" onkeypress="onEnter(function(){base().DateRefreshDate();})" width="100" typeMask="date" emptyMask="false"/>

                    </td>
                    <td style="padding-right:2pt;">
                        <component cmptype="Button" type="small" icon="Icons/control_r" title="Вперёд" onclick="base().MOVE_DATE(1);"/>
                    </td>
                    <td style="padding-right:2pt;">
                        <component cmptype="Button" name="GoToDate" caption="Перейти к дате" onclick="base().DateRefreshDate()"/>
                        <component cmptype="MaskInspector" effectControls="GoToDate" controls="REC_DATE;REC_DATE_END"/>
                    </td>
                    <td style="padding-left:15px;">
                        <component cmptype="Button" caption="Печать отчёта" onclick="base().ReportCashPrint()"/>
                    </td>
                    <td style="width:400px; padding-left:10pt; white-space:nowrap;" class="cellprint" dataset="DS_FULL_SUMM">
                        <component cmptype="Label" width="" caption="Сумма платежей за день"/><component cmptype="Label" name="cashsectname"/><component cmptype="Label" width="" caption=": "/><component cmptype="Label" captionfield="FULL_SUMM"/>
                    </td>
                    <td align="right">
                        <component cmptype="Button" name="Z_REPORT_CREATE" caption="Сформировать Z-отчет" onclick="base().zReportCreate();" />
                    </td>
                </tr>
            </table>
            <div cmptype="bogus" name="CashFilter" style="display:none;width:100%;margin-top:15px;">
                <table class="form-table" width="100%" style="table-layout:fixed;">
                    <colgroup>
                        <col width="12%"/>
                        <col width="6%"/>
                        <col widht="4%"/>
                        <col widht="6%"/>
                        <col width="8%"/>
                        <col width="12%"/>
                        <col width="16%"/>
                        <col width="8%"/>
                        <col width="12%"/>
                        <col width="16%"/>
                    </colgroup>
                    <tr>
                        <td>
                            <component cmptype="Label" caption="Отбор по:"/>
                        </td>
                        <td  colspan="3">
                            <component cmptype="ComboBox" name="DATE_TYPE" onchange="base().CHANGE_DATA_TYPE();" width="100%">
                                <component cmptype="ComboItem" value="REC_DATE" caption="дате назначения"/>
                                <component cmptype="ComboItem" value="REG_DATE" caption="дате создания"/>
                            </component>
                        </td>
                        <td/>
                        <td>
                            <component cmptype="Label" caption="Случай заболевания:"/>
                        </td>
                        <td>
                            <component cmptype="ComboBox" name="DC_TYPE_COM" width="100%">
                                <component cmptype="ComboItem" value="" caption="Все" activ="true"/>
                                <component cmptype="ComboItem" value="0" caption="Поликлиника"/>
                                <component cmptype="ComboItem" value="1" caption="Стационар"/>
                            </component>
                        </td>
                        <td/>
                        <td>
                            <component cmptype="Label" caption="Статус:"/>
                        </td>
                        <td>
                            <component cmptype="ComboBox" name="STAT" width="100%">
                                <component cmptype="ComboItem" value="" caption="Все" activ="true"/>
                                <component cmptype="ComboItem" value="0" caption="Действующий"/>
                                <component cmptype="ComboItem" value="1" caption="Аннулированный"/>
                            </component>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <component cmptype="Label" caption="Пациент: Фамилия:"/>
                        </td>
                        <td colspan="3">
                            <component cmptype="Edit" width="100%" name="PAT_SURNAME" onkeypress="onEnter(base().Search);"/>
                        </td>
                        <td/>
                        <td>
                            <component cmptype="Label" caption="Имя:"/>
                        </td>
                        <td>
                            <component cmptype="Edit" width="100%" name="PAT_FIRSTNAME" onkeypress="onEnter(base().Search);"/>
                        </td>
                        <td/>
                        <td>
                            <component cmptype="Label" caption="Отчество:"/>
                        </td>
                        <td>
                            <component cmptype="Edit" width="100%" name="PAT_LASTNAME" onkeypress="onEnter(base().Search);"/>
                        </td>
                    </tr>
                    <tr>
                        <td>
                             <component cmptype="Label" caption="Врач: Код:"/>
                        </td>
                        <td colspan="3">
                            <component cmptype="Edit" width="100%" name="EMP_CODE" onkeypress="onEnter(base().Search);"/>
                        </td>
                        <td/>
                        <td>
                            <component cmptype="Label" caption="Фамилия:"/>
                        </td>
                        <td>
                            <component cmptype="Edit" width="100%" name="EMP_SURNAME" onkeypress="onEnter(base().Search);"/>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <component cmptype="Label" caption="Договор: Префикс:"/>
                        </td>
                        <td>
                            <component cmptype="Edit" width="100%" name="DOC_PREF" onkeypress="onEnter(base().Search);"/>
                        </td>
                        <td>
                            <component cmptype="Label" caption=" № "/>
                        </td>
                        <td>
                            <component cmptype="Edit" width="100%" name="DOC_NUMB" onkeypress="onEnter(base().Search);"/>
                        </td>
                        <td/>
                        <td>
                            <component cmptype="Label" caption="Услуга:"/>
                        </td>
                        <td>
                            <component cmptype="UnitEdit" unit="LPU_SERVICES" composition="GRID" name="SE_CODE" multisel="true" width="100%"/>
                        </td>
                        <td/>
                        <td>
                            <component cmptype="Label" caption="Оплачено:"/>
                        </td>
                        <td>
                            <component cmptype="ComboBox" width="100%" name="IS_FULLY_PAID">
                                 <component cmptype="ComboItem" value="" caption="Все"/>
                                 <component cmptype="ComboItem" value="1" caption="0плачено"/>
                                 <component cmptype="ComboItem" value="0" caption="Не оплачено"/>
                            </component>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <component cmptype="Label" caption="Подразделение:"/>
                        </td>
                        <td colspan="3">
                            <component cmptype="UnitEdit" name="DIVISIONS" unit="DIVISIONS" method="DEFAULT" type="ComboBox" width="100%" onchange="base().Search();" />
                        </td>
                    </tr>
                </table>
                <div style="text-align:right;margin-top:5px;">
                    <component cmptype="Button" name="ButtonOk" onclick="base().DateRefresh();" caption="Найти" width="86"/>
                    <component cmptype="Button" name="ButtonClear" onclick="base().ClearFilter();" caption="Очистить" width="86"/>
                </div>
            </div>
        </div>
        <component cmptype="Expander" name="CashFiltExp" control="CashFilter" caption="Поиск"/>
    </div>
    <div class="blockBackground" style="margin-top:7px;padding: 5px;">
        <table width="100%">
            <tr style="">
                <td style="width:100%" align="left" colspan="6">
                    <div style="width:100%;">
                        <component cmptype="Grid" grid_caption="Касса" name="CASH_GRID" dataset="DS_CASH" field="CON_PAYS_ID" onclone="base().onPaint(_dataArray,this);">
                            <component cmptype="Column" caption = "Пациент" width="11%" sort="PAT_FULL_NAME" name="PAT" >
                                <component cmptype="HyperLink" captionfield="PAT_FULL_NAME" datafield="PAT_ID"  hintfield="BONUS_SUMM" onclick="base().ADD_PERSMEDCARD(this);"/>
                            </component>
                            <component cmptype="Column" caption="Договор" sort="PREF_NUM_STR" sortorder="-2" name="DOC">
                                <table style="width:100%;">
                                    <tr>
                                        <td style="width:70%;">
                                            <component cmptype="Label" captionfield="SDOC_NUMB"/>
                                        </td>
                                        <td style="width:30%;text-align:right;">
                                            <img width="18" height="19" border="0" title="Печать" onclick="base().PrintContract();" src="Images/img2/print.gif" style="cursor:pointer;"/>
                                        </td>
                                    </tr>
                                </table>
                            </component>
                            <component cmptype="Column" caption="Код услуги" sort="SE_CODE" field="SE_CODE" upper="true"   name="SEC"/>
                            <component cmptype="Column" caption="Название услуги" sort="SERVICE_NAME" field="SERVICE_NAME" upper="true" name="SEN"/>
                            <component cmptype="Column" caption="Врач" width="14%" sort="EMPLOYER" field="EMPLOYER" upper="true" name="EMP"/>
                            <component cmptype="Column" caption="Врач, оказавший прием" width="14%" sort="VISIT_EMPLOYER" field="VISIT_EMPLOYER" upper="true" name="VISIT_EMPLOYER"/>
                            <component cmptype="Column" caption="Дата записи" sort="RREC_DATE" field="RREC_DATE" sortorder="-1" name="RREC"/>
                            <component cmptype="Column" caption="Дата назначения" sort="REC_DATE" field="REC_DATE" sortorder="-1" name="REC"/>
                            <component cmptype="Column" caption="К оплате" sort="SUMM_SERVICE" field="SUMM_SERVICE" upper="true" name="SSE" style="text-align: right;"/>
                            <component cmptype="Column" caption="Оплачено" sort="IS_FULLY_PAID" name="IFP">
                                <table style="width:100%;">
                                    <tr>
                                        <td style="width:16px;">
                                            <component cmptype="CheckBox" name="main_cb_pay" valuechecked="1" valueunchecked="0" datafield="IS_FULLY_PAID" onclick="base().Pay(this);" style="width: auto;"/>
                                        </td>
                                        <td style="text-align: right;">
                                            <component cmptype="Label" captionfield="PAID_SUMM" style=""/>
                                        </td>
                                    </tr>
                                </table>
                            </component>
                            <component cmptype="Column" caption = "По договору к оплате" sort="SUMM_CONTR" field="SUMM_CONTR" name="SCO" style="text-align: right;"/>
                            <component cmptype="GridFooter" separate="false">
                                <component insteadrefresh="InsteadRefresh(this);" count="10" cmptype="Range" varstart="ds1start" varcount="ds1count" valuecount="20" valuestart="1"/>
                            </component>
                        </component>
                    </div>
                    <component cmptype="Popup" name="pCash" popupobject="CASH_GRID" onpopup="base().ONPP();">
                        <component cmptype="PopupItem" name="pRefreshDirect" caption="Обновить" onclick="base().Search();" cssimg="refresh"/>
                        <component cmptype="PopupItem" caption="-"/>
                        <component cmptype="PopupItem" name="pSetPayService" caption="Оплатить услугу" onclick="base().SetPayContrSpec();" cssimg="insert"/>
                        <component cmptype="PopupItem" name="pGetMoneyBack" caption="Вернуть деньги за услугу" onclick="base().GetMoneyBack();" cssimg="insert"/>
                        <component cmptype="PopupItem" name="pFixSumm" caption="Исправить сумму" onclick="base().FixSumm();" cssimg="edit"/>
                        <component cmptype="PopupItem" name="pSetPayContract" caption="Оплатить весь договор" onclick="base().SetPayContract();" cssimg="pay"/>
                        <component cmptype="PopupItem" name="pCancLastPaym" caption="Отменить последнюю операцию" onclick="base().CancelLastPayment();" cssimg="delete"/>

                        <component cmptype="PopupItem" name="pCancAnn" caption="Отменить аннулирование"	onclick="base().CancelAnn();" cssimg="off"/>
                        <component cmptype="PopupItem" name="psetNull" caption="Аннулировать" onclick="base().setNull();" cssimg="off"/>

                        <component cmptype="PopupItem" name="line2" caption="-"/>
                        <component cmptype="PopupItem" name="pServsInContr" caption="Просмотр услуг в договоре" onclick="base().ViewServsList();" cssimg="preview"/>
                        <component cmptype="PopupItem" name="pViewPays"	caption="Просмотр платежей"	onclick="base().ViewPays();" cssimg="preview"/>
                        <component cmptype="PopupItem" name="pConnAv" caption="Связать с авансом" onclick="base().ViewPaysAv();" cssimg="insert"/>
                        <component cmptype="PopupItem" name="pFacAcc" caption="Лицевой счет" onclick="base().fac_acc();" cssimg="pay"/>

                    </component>
                    <component cmptype="AutoPopupMenu" name="pREPS"  unit="CONTRACT_PAYMENTS" join_menu="pCash" popupobject="CASH_GRID" reports="true">
                        <component cmptype="PopupItem" name="pPrintContr" caption="Печать Контракта" cssimg="report">
                            <component cmptype="PopupItem" name="pPrintContr1" caption="Контракта с Пациентом" onclick="base().PrintContract();" cssimg="print"/>
                            <component cmptype="PopupItem" name="pPrintContrZakazchik" caption="Контракта с Заказчиком" onclick="base().PrintContractZakazchik();" cssimg="print"/>
                        </component>
                        <component cmptype="PopupItem" name="pPrintIS" caption="Печать Информированного согласия" cssimg="report">
                            <component cmptype="PopupItem" name="pPrintISPersInfo" caption="На обработку Персональных Данных" onclick="base().PrintAgreementPersInfo();" cssimg="print"/>
                        </component>
                        <component cmptype="PopupItem" name="pPrintListServs" caption="Другие" cssimg="report">
                            <component cmptype="PopupItem" name="pPrintTaxNote" caption="Справка в налоговую" onclick="base().PrintTaxNote();" cssimg="print"/>
                        </component>
                        <component cmptype="PopupItem" name="pPrintAcceptionAct" caption="Акт о приемке" onclick="base().PrintAcceptionAct();" cssimg="print"/>
                        <component cmptype="PopupItem" name="pPrintReceipt52n" caption="Квитанция 52н" onclick="base().PrintReceipt52n();" cssimg="print"/>
                        <component cmptype="PopupItem" name="pPrintReceipt52n1" caption="Квитанция тест" onclick="base().PrintReceipt52n1();" cssimg="print"/>
                        <component cmptype="PopupItem" name="pPrintReceipt52nkb123" caption="Квитанция КБ123" onclick="base().PrintReceipt52nkb123();" cssimg="print"/>
                        <component cmptype="PopupItem" name="pPrintReceipt52n1_pk" caption="Квитанция 1 поликлиника" onclick="base().pPrintReceipt52n1_pk();" cssimg="print"/>
                    </component>
                </td>
            </tr>
        </table>
    </div>
</div>