<div cmptype="form" style="height:100%;width:100%;" oncreate="base().onCreate();" onshow="base().onShow();" window_size="100%x100%">
	<component cmptype="ProtectedBlock" alert="true" modcode="Store">
		<component cmptype="Script">
			<![CDATA[
			Form.docsCache = [0];
			Form.docSpecsCache = [0];

			Form.onCreate = function () {
			};

			Form.onShow = function () {
				this.showFilter();
			};

			Form.showFilter = function () {
				openWindow('Sklad/transinvdept/filter', true)
						.addListener('onafterclose', function () {
							if (getVar('ModalResult') == 1) {
								refreshDataSet('DS_TRANSINVDEPT');

							}
						});
			};

			Form.onTransinvdeptClone = function (_dom, _dataArray) {
				this.docsCache[_dataArray['ID']] = _dataArray['STATUS'];

				var cell = getControlByName('DocCol');

				if (_dataArray['STATUS'] == 0 || _dataArray['STATUS'] == 2) cell.parentNode.style.color = 'blue';
				else cell.parentNode.style.color = '';

				if (_dataArray['IN_STATUS'] == 0) cell.style.backgroundColor = '#D0FF84';
				else cell.style.backgroundColor = '';
			};
			Form.refreshDetail = function () {
				setControlProperty('TransinvdeptSpecs', 'locate', getValue('TransinvdeptSpecs'));
				refreshDataSet('DS_TRANSINVDEPT_SPECS');
			};
			Form.refreshHead = function () {
				if (empty(getVar('HeadLocate')))
					setVar('HeadLocate', getValue('Transinvdept'))
				if (empty(getVar('ChildLocate')))
					setVar('ChildLocate', getValue('TransinvdeptSpecs'))
				setControlProperty('Transinvdept', 'locate', getVar('HeadLocate'));
				setControlProperty('TransinvdeptSpecs', 'locate', getVar('ChildLocate'));
				refreshDataSet('DS_TRANSINVDEPT');
			}
			Form.onTransinvdeptSpecClone = function (_dom, _dataArray) {
				this.docSpecsCache[_dataArray['ID']] = _dataArray['STATUS'];

				var cell = getControlByName('DocSpecCol');

				if (_dataArray['STATUS'] == 1) cell.parentNode.style.color = '';
				else cell.parentNode.style.color = 'blue';
			};

			Form.onTransinvdeptPopupShow = function () {
				var docState = this.docsCache[getValue('Transinvdept') || 0];

				if (docState == 1) // отработан
				{
					setControlProperty('TransinvdeptPopup', 'hideitem', 'PopDocUpd');
					setControlProperty('TransinvdeptPopup', 'hideitem', 'PopDocDel');
					setControlProperty('TransinvdeptPopup', 'showitem', 'PopDocView');
					setControlProperty('TransinvdeptPopup', 'showitem', 'PopReceive');
					setControlProperty('TransinvdeptPopup', 'hideitem', 'PopWorking');
				}
				else {
					setControlProperty('TransinvdeptPopup', 'showitem', 'PopDocUpd');
					setControlProperty('TransinvdeptPopup', 'showitem', 'PopDocDel');
					setControlProperty('TransinvdeptPopup', 'hideitem', 'PopDocView');
					setControlProperty('TransinvdeptPopup', 'hideitem', 'PopReceive');
					setControlProperty('TransinvdeptPopup', 'showitem', 'PopWorking');
				}

				if (docState == 0) // не отработан
				{
					setControlProperty('TransinvdeptPopup', 'hideitem', 'PopCancelWorking');
				}
				else // отработан или частично отработан
				{
					setControlProperty('TransinvdeptPopup', 'showitem', 'PopCancelWorking');
				}
			};

			Form.editAddTransinvdept = function (type) {
				console.log(type);
				setVar('TYPE', type);
				if (type == 'ADD') {
					setVar('DISCARDACTS', '');
					setVar('TRANSINVDEPT', '');
					setVar('CID', getValue('CATALOGS_DEFAULT'));
				} else
					setVar('TRANSINVDEPT', getValue('Transinvdept'));
				setVar('READ_ONLY', 0);
				openWindow('Sklad/transinvdept/add_upd_transinvdept', true).addListener('onafterclose',
						function () {
							if (getVar('ModalResult') == 1) {
								if (!empty(getVar('newid')))
									setVar('HeadLocate', getVar('newid'));
								else
									setVar('HeadLocate', getValue('Transinvdept'));
								if (type == 'COPY_WITH_SP') {
									executeAction('COPY_DETAILS', function () {
										setControlProperty('Transinvdept', 'locate', getVar('TRANSINVDEPT'));
										refreshDataSet('DS_TRANSINVDEPT');
										if (getVar('SERROR'))
											showAlert(getVar('SERROR'), 'Недостаточно остатка', 530, 200);
									});
								} else {
									setVar('ChildLocate', null);
									base().refreshHead();
								}
							}
						});
			};

			Form.viewTransinvdept = function () {
				setVar('TRANSINVDEPT', getValue('Transinvdept'));
				setVar('READ_ONLY', 1);
				openWindow('Sklad/transinvdept/add_upd_transinvdept', true);
			};

			Form.moveTransinvdept = function () {
				setVar('ModalResult', 0);
				setVar('CID', getValue('CATALOGS_DEFAULT'));
				setVar('TRANSINVDEPT', getValue('Transinvdept_SelectList') || getValue('Transinvdept'));
				openWindow({
					name: 'UniversalComposition/UniversalComposition',
					unit: 'CATALOGS',
					composition: 'DEFAULT',
					catalog_unitcode: 'TRANSINVDEPT'
				}, true, 350, 500).addListener('onclose',
						function () {
							if (getVar('ModalResult', 1) == 1) {
								setVar('MOVE_CID', getVar('return_id', 1), 1);

								executeAction('ATransinvdeptMove',
										function () {
											setControlProperty('CATALOGS_DEFAULT', 'locate', getVar('MOVE_CID'));
											setControlProperty('Transinvdept', 'locate', getValue('Transinvdept'));
											refreshDataSet('DS_CATALOGS_DEFAULT');
										}
										, null, null, true, 1);
							}
						});
			};

			Form.deleteTransinvdept = function () {
				if (!empty(getValue('Transinvdept_SelectList')))
					setVar('Transinvdept_var', getValue('Transinvdept_SelectList'));
				else
					setVar('Transinvdept_var', getValue('Transinvdept'));
				if (confirm('Вы действительно хотите удалить запись(и)?')) {
					//setVar('TRANSINVDEPT',  getValue('Transinvdept'));
					executeAction('ADelTransinvdept',
							function () {
								setVar('HeadLocate', null);
								setVar('ChildLocate', null);
								base().refreshHead();
							});

				}
			};

			Form.workingTransinvdept = function () {
				if (!empty(getValue('Transinvdept_SelectList')))
					setVar('Transinvdept_var', getValue('Transinvdept_SelectList'));
				else
					setVar('Transinvdept_var', getValue('Transinvdept'));
				openWindow('Sklad/transinvdept/select_date', true)
						.addListener('onafterclose', function () {
							if (getVar('ModalResult') == 1) {
								setVar('HeadLocate', null);
								setVar('ChildLocate', null);
								setVar('TRANSINVDEPT_SPEC_ACT', null);
								setVar('OPER_TYPE', 0);
								executeAction('recycleTransinvdept', base().refreshHead);
							}
						});
			};

			Form.cancelWorkingTransinvdept = function () {
				if (!empty(getValue('Transinvdept_SelectList')))
					setVar('Transinvdept_var', getValue('Transinvdept_SelectList'));
				else
					setVar('Transinvdept_var', getValue('Transinvdept'));
				setVar('HeadLocate', null);
				setVar('ChildLocate', null);
				executeAction('cancelWorkingTransinvdept', base().refreshHead);
			};

			Form.receiveTransinvdept = function () {
				if (!empty(getValue('Transinvdept_SelectList')))
					setVar('Transinvdept_var', getValue('Transinvdept_SelectList'));
				else
					setVar('Transinvdept_var', getValue('Transinvdept'));
				openWindow('Sklad/transinvdept/select_date', true)
						.addListener('onafterclose', function () {
							if (getVar('ModalResult') == 1) {
								setVar('HeadLocate', null);
								setVar('ChildLocate', null);
								setVar('TRANSINVDEPT_SPEC_ACT', null);
								setVar('OPER_TYPE', 1);
								executeAction('recycleTransinvdept', base().refreshHead);
							}
						});
			};

			Form.onTransinvdeptSpecsPopupShow = function () {
				var docState = this.docsCache[getValue('Transinvdept') || 0];
				var docSpecState = this.docSpecsCache[getValue('TransinvdeptSpecs') || 0];

				if (docSpecState == 1) //отработана
				{
					setControlProperty('TransinvdeptSpecsPopup', 'hideitem', 'PopSpecWorking');
					setControlProperty('TransinvdeptSpecsPopup', 'showitem', 'PopCancelSpecWorking');
					setControlProperty('TransinvdeptSpecsPopup', 'hideitem', 'PopDocSpecUpd');
					setControlProperty('TransinvdeptSpecsPopup', 'hideitem', 'PopDocSpecDel');
					setControlProperty('TransinvdeptSpecsPopup', 'showitem', 'PopDocSpecView');
					setControlProperty('TransinvdeptSpecsPopup', 'showitem', 'PopReceiveSpec');

				}
				else {
					setControlProperty('TransinvdeptSpecsPopup', 'showitem', 'PopSpecWorking');
					setControlProperty('TransinvdeptSpecsPopup', 'hideitem', 'PopCancelSpecWorking');
					setControlProperty('TransinvdeptSpecsPopup', 'showitem', 'PopDocSpecUpd');
					setControlProperty('TransinvdeptSpecsPopup', 'showitem', 'PopDocSpecDel');
					setControlProperty('TransinvdeptSpecsPopup', 'hideitem', 'PopDocSpecView');
					setControlProperty('TransinvdeptSpecsPopup', 'hideitem', 'PopReceiveSpec');
				}

				if (docState == 1) {
					setControlProperty('TransinvdeptSpecsPopup', 'hideitem', 'PopAddSpec');
					setControlProperty('TransinvdeptSpecsPopup', 'hideitem', 'PopAddFromAppl');
					setControlProperty('TransinvdeptSpecsPopup', 'hideitem', 'pLinkAppl');
				}
				else {
					setControlProperty('TransinvdeptSpecsPopup', 'showitem', 'PopAddSpec');
					setControlProperty('TransinvdeptSpecsPopup', 'showitem', 'PopAddFromAppl');
					setControlProperty('TransinvdeptSpecsPopup', 'showitem', 'pLinkAppl');
				}
			};

			Form.insertTransinvdeptSpecs = function () {
				setVar('TRANSINVDEPT', getValue('Transinvdept'));
				openWindow('Sklad/transinvdept/transinvdept_spec_fill', true)
						.addListener('onafterclose', function () {
							if (getVar('ModalResult') == 1) {
								setVar('HeadLocate', null);
								setVar('ChildLocate', getVar('newid'));
								base().refreshHead();
							}
						});
			};

			Form.editTransinvdeptSpecs = function () {
				setVar('TRANSINVDEPT', getValue('Transinvdept'));
				setVar('TRANSINVDEPT_SPECS', getValue('TransinvdeptSpecs'));
				setVar('STORE_ID', getControlProperty('Transinvdept', 'data')['STORE_ID']);
				setVar('PRICE', getControlProperty('TransinvdeptSpecs', 'data')['PRISE']);
				setVar('PRICE_MEAS', getControlProperty('TransinvdeptSpecs', 'data')['PRICEMEAS']);
				openWindow('Sklad/transinvdept/add_upd_transinvdept_spec', true)
						.addListener('onafterclose', function () {
							setVar('HeadLocate', null);
							setVar('ChildLocate', null);
							if (getVar('ModalResult') == 1)
								base().refreshHead();
						});
			};

			Form.viewTransinvdeptSpecs = function () {
				setVar('TRANSINVDEPT', getValue('Transinvdept'));
				setVar('TRANSINVDEPT_SPECS', getValue('TransinvdeptSpecs'));
				setVar('STORE_ID', getControlProperty('Transinvdept', 'data')['STORE_ID']);
				setVar('VIEW_MODE', 'look');
				openWindow('Sklad/transinvdept/add_upd_transinvdept_spec', true)
						.addListener('onafterclose', function () {
							setVar('VIEW_MODE', null);
						});
			};

			Form.workingTransinvdeptSpecs = function () {
				if (!empty(getValue('TransinvdeptSpecs_SelectList')))
					setVar('TransinvdeptSpecs_var', getValue('TransinvdeptSpecs_SelectList'));
				else
					setVar('TransinvdeptSpecs_var', getValue('TransinvdeptSpecs'));
				openWindow('Sklad/transinvdept/select_date', true)
						.addListener('onafterclose', function () {
							if (getVar('ModalResult') == 1) {
								setVar('OPER_TYPE', 0);
								setVar('HeadLocate', null);
								setVar('ChildLocate', null);
								executeAction('recycleGoodsTransinvdept', base().refreshHead);
							}
						});
			};

			Form.cancelWorkingTransinvdeptSpecs = function () {
				if (!empty(getValue('TransinvdeptSpecs_SelectList')))
					setVar('TransinvdeptSpecs_var', getValue('TransinvdeptSpecs_SelectList'));
				else
					setVar('TransinvdeptSpecs_var', getValue('TransinvdeptSpecs'));
				setVar('HeadLocate', null);
				setVar('ChildLocate', null);
				executeAction('cancelWorkingTransInDeptSpec', base().refreshHead);
			};

			Form.receiveTransinvdeptSpecs = function () {
				if (!empty(getValue('TransinvdeptSpecs_SelectList')))
					setVar('TransinvdeptSpecs_var', getValue('TransinvdeptSpecs_SelectList'));
				else
					setVar('TransinvdeptSpecs_var', getValue('TransinvdeptSpecs'));
				openWindow('Sklad/transinvdept/select_date', true)
						.addListener('onafterclose', function () {
							if (getVar('ModalResult') == 1) {
								setVar('HeadLocate', null);
								setVar('ChildLocate', null);
								setVar('OPER_TYPE', 1);
								executeAction('recycleGoodsTransinvdept', base().refreshHead);
							}
						});
			};
			Form.PrintTransinvdept = function () {
				setVar('TRANS_ID', getValue('Transinvdept'));
				printReportByCode('rep_transinvdept_new', 830, 768);
			};
			<!--добавление Popup   меню  формы м 11--!>
			Form.PrintTransinvdept1 = function () {
				setVar('TRANS_ID', getValue('Transinvdept'));
				printReportByCode('rep_transinvdept_new1', 830, 768);
			};

			Form.PrintDepNeeds = function () {
				setVar('TRANS_ID', getValue('Transinvdept'));
				printReportByCode('dep_needs_ved', 830, 768);
			};
			Form.PrintTransinvdeptNoOpt = function () {
				setVar('TRANS_ID', getValue('Transinvdept'));
				printReportByCode('rep_transinvdept_no_opt', 830, 768);
			};
			Form.PrintSvodTransinvdept = function () {
				openWindow({
					name: 'Reports/Sklad/transinvdept/svod_transinvdept_call',
					vars: {
						DATE_FROM: getControlProperty('Transinvdept', 'data')['DOC_DATE'],
						DATE_TO: getControlProperty('Transinvdept', 'data')['WORK_DATE'],
						IN_STORE_ID: getControlProperty('Transinvdept', 'data')['IN_STORE_ID']
					}
				}, true);
			};
			Form.deleteTransinvdeptSpecs = function () {
				if (!empty(getValue('TransinvdeptSpecs_SelectList')))
					setVar('TransinvdeptSpecs_var', getValue('TransinvdeptSpecs_SelectList'));
				else
					setVar('TransinvdeptSpecs_var', getValue('TransinvdeptSpecs'));
				setVar('HeadLocate', null);
				setVar('ChildLocate', null);
				if (confirm('Вы действительно хотите удалить запись(и)?'))
					executeAction('deleteTransinvdeptSpec', base().refreshHead);
			};

			Form.PrintVozvratTransinvdept = function () {
				setVar('TRANS_ID', getValue('Transinvdept'));
				printReportByCode('vozvrat_transinvdept', 830, 768);
			};
			Form.selectApplication = function (_str, _with_td) //_str = 'full' or 'short'
			{
			    if(_with_td) {
					setVar('TRANSINVDEPT', '');
				}
				setVar('ModalResult', 0);
				setVar('ApplMode', 'get');
				setVar('ApplStore', getControlProperty('Transinvdept', 'data')['IN_STORE_ID']);
				setVar('varMode', _str);
				setVar('newTransinvdept', _with_td);
				openWindow('Sklad/application/applicationes', true)
						.addListener('onafterclose', function(){
							if (!empty(getVar('TRANSINVDEPT')))
							   setControlProperty('Transinvdept', 'locate', getVar('TRANSINVDEPT'));
							base().insertInDocSpWithAppl();
						});
			};
			Form.insertInDocSpWithAppl = function () {
				setVar('ApplMode', null);
				if (getVar('newTransinvdept')){
					executeAction('ADD_BY_APPLICATION',base().addSpecByAapp);
				}
				else{
					setVar('TRANSINVDEPT', getValue('Transinvdept'));
					base().addSpecByAapp();
				}
					//var APPLICATION

			};
			Form.addSpecByAapp = function () {
				if (getVar('ModalResult') == 1) {
					setVar('ModalResult', 0);
					openWindow('Sklad/transinvdept/transinvdept_appl_fill', true)
							.addListener('onafterclose', function () {
								refreshDataSet('DS_TRANSINVDEPT_SPECS');
								base().refreshHead();
							});
				}
			}
			Form.printReport = function (_reportCode) {
				if (!empty(getValue('Transinvdept_SelectList')))
					setVar('ID', getValue('Transinvdept_SelectList'));
				else
					setVar('ID', getValue('Transinvdept'));

				printReportByCode(_reportCode);
			};
			]]>
		</component>

		<!-- =============================================================================================================== -->
		<component cmptype="Action" name="COPY_DETAILS">
			<![CDATA[
				declare
					nTEMP   NUMBER(17);
					sNOM    VARCHAR2(500);
					sERROR  VARCHAR2(4000);
				begin
					for cur in (select ts.*,
									   gs.ID GOODSSUPPLY_ID,
								       (round(D_PKG_NOMMODIF.RECOUNT_FROM_MAIN(ts.NOMMODIF_ID,ts.PRICEMEAS,D_PKG_JURSTORE.GET_RESTS_FOR_DATE(gs.ID,ts.LPU,'RESTFACT',sysdate,0,1)),3) - ts.QUANT) DIFFREST
								  from D_V_TRANSINVDEPT t,
									   D_V_TRANSINVDEPT_SPECS ts,
									   D_V_GOODSSUPPLY gs,
			 						   D_V_REGPRICE     rp
							     where t.ID = :PRIMARY
								   and ts.PID = t.ID
								   and gs.PID = ts.GOODPARTY_ID
								   and gs.STORE_ID = t.STORE_ID
								   and gs.LPU = ts.LPU
								   and rp.PID = gs.ID
							       and ts.PRISE = rp.PRICE
							       and ts.PRICEMEAS = rp.PRICE_MEAS
								   and gs.FINANSOURCE_ID = ts.FINANSOURCE_ID
							  order by DIFFREST
							   )
					loop
						if cur.DIFFREST < 0 then
							sNOM := sNOM || '</br>' || cur.NOMMODIF_NAME || ';';
						else
							d_pkg_transinvdept_specs.add(pnd_INSERT_ID  => nTEMP,
														 pnLPU			=> :LPU,
														 pnPID			=> :NEWID,
														 pnGOODPARTY	=> cur.GOODPARTY_ID,
														 pnFINANSOURCE	=> cur.FINANSOURCE_ID,
														 pnQUANT		=> cur.QUANT,
														 pnGOODSSUPPLY  => cur.GOODSSUPPLY_ID
														);
						end if;
					end loop;
					if sNOM is not null then
						:sERROR := 'Для копирования спецификации недостаточно остатка: ' || sNOM;
					end if;
				end;
			]]>
			<component cmptype="ActionVar" name="LPU"     src="LPU"          srctype="session"/>
			<component cmptype="ActionVar" name="PRIMARY" src="TRANSINVDEPT" srctype="var" get="v1"/>
			<component cmptype="ActionVar" name="NEWID"   src="newid"        srctype="var" get="v2"/>
			<component cmptype="ActionVar" name="SERROR"  src="SERROR"       srctype="var" put="SERROR" len="4000"/>
		</component>
		<component cmptype="Action" name="cancelWorkingTransinvdept" unit="TRANSINVDEPT" action="CANCEL_RECYCLE">
			<component cmptype="ActionVar" name="pnLPU"   src="LPU"              srctype="session"/>
			<component cmptype="ActionVar" name="~pnID"   src="Transinvdept_var" srctype="var"	get="v1"/>
		</component>
		<component cmptype="Action" name="recycleTransinvdept" unit="TRANSINVDEPT" action="RECYCLE">
			<component cmptype="ActionVar" name="pnLPU"         src="LPU"                    srctype="session"/>
			<component cmptype="ActionVar" name="~pnID"         src="Transinvdept_var"       srctype="var"  get="v1"/>
			<component cmptype="ActionVar" name="pnSPEC_ID"     src="TRANSINVDEPT_SPEC_ACT"  srctype="var"  get="v2"/>
			<component cmptype="ActionVar" name="pnOPER_TYPE"   src="OPER_TYPE"              srctype="var"  get="v3"/>
			<component cmptype="ActionVar" name="pdOUT_DATE"    src="PD_DATE"                srctype="var"  get="v4"/>
			<component cmptype="ActionVar" name="pdIN_DATE"     src="PD_DATE"                srctype="var"  get="v5"/>
		</component>
		<component cmptype="Action" name="deleteTransinvdeptSpec" unit="TRANSINVDEPT_SPECS" action="DELETE">
			<component cmptype="ActionVar" name="pnLPU"  src="LPU"                   srctype="session"/>
			<component cmptype="ActionVar" name="~pnID"  src="TransinvdeptSpecs_var" srctype="var" get="v1"/>
		</component>
		<component cmptype="Action" name="recycleGoodsTransinvdept" unit="TRANSINVDEPT_SPECS" action="RECYCLE">
			<component cmptype="ActionVar" name="pnLPU"         src="LPU"                    srctype="session"/>
			<component cmptype="ActionVar" name="pnID"          src="Transinvdept"           srctype="ctrl" get="v1"/>
			<component cmptype="ActionVar" name="~pnSPEC_ID"    src="TransinvdeptSpecs_var"  srctype="var"  get="v2"/>
			<component cmptype="ActionVar" name="pdOUT_DATE"    src="PD_DATE"                srctype="var"  get="v3"/>
			<component cmptype="ActionVar" name="pdIN_DATE"     src="PD_DATE"                srctype="var"  get="v4"/>
			<component cmptype="ActionVar" name="pnOPER_TYPE"   src="OPER_TYPE"              srctype="var"  get="v5"/>
		</component>
		<component cmptype="Action" name="cancelWorkingTransInDeptSpec" unit="TRANSINVDEPT_SPECS" action="CANCEL_RECYCLE">
			<component cmptype="ActionVar" name="pnLPU"     src="LPU"                srctype="session"/>
			<component cmptype="ActionVar" name="pnID"      src="Transinvdept"       srctype="ctrl"  get="v1"/>
			<component cmptype="ActionVar" name="pnSPECID"  src="TransinvdeptSpecs"  srctype="ctrl"  get="v2"/>
		</component>
		<component cmptype="Action" name="ATransinvdeptMove" unit="TRANSINVDEPT" action="MOVE_OUT">
			<component cmptype="ActionVar" name="PNLPU"       src="LPU"               srctype="session"/>
			<component cmptype="ActionVar" name="~pnID"       src="TRANSINVDEPT"      srctype="var"  get="v1"/>
			<component cmptype="ActionVar" name="psUNITCODE"  src="UNIT_TRANSINVDEPT" srctype="var"  get="v2" default="TRANSINVDEPT"/>
			<component cmptype="ActionVar" name="pnTARGET"    src="MOVE_CID"          srctype="var"  get="v3"/>
		</component>
		<component cmptype="Action" name="ADelTransinvdept" unit="TRANSINVDEPT" action="DELETE">
			<component cmptype="ActionVar" name="~pnid"  get="pnid" src="Transinvdept_var"  srctype="var"/>
			<component cmptype="ActionVar" name="pnlpu"             src="LPU"               srctype="session"/>
		</component>
		<!-- =============================================================================================================== -->
		<component cmptype="DataSet" name="DS_TRANSINVDEPT" activateoncreate="false" mode="Range" compile="true">
			<![CDATA[
			select t.ID,
				   t.DOCTYPE_CODE||', '||t.PREF||'-'||t.NUMB||', '||t.DOC_DATE FULLNAME,
				   to_char(d_pkg_transinvdept.get_summ(t.ID,:LPU), 'fm999999999999999990.00') DOC_SUMM,
				   t.STORE_NAME,
				   t.STORE_ID,
				   t.IN_STORE_NAME,
				   t.IN_STORE_ID,
				   t.STOPER_NAME,
				   t.STOPER_CODE,
				   t.IN_STOPER_NAME,
				   t.IN_STOPER_CODE,
				   t.WORK_DATE,
				   t.DOC_DATE,
				   t.IN_WORK_DATE,
				   t.IN_STATUS,
				   t.VALID_DOCTYPE_NAME||' '||t.VALID_NUMB||' '||t.VALID_DATE FULL_VALID,
				   t.ATT_DOCTYPE_NAME||' '||t.ATTORNEY_NUMB||' '||t.ATTORNEY_DATE FULL_ATTORNEY,
				   t.COMMENTS,
				   decode(t.STATUS,0,'не отработан',1,'отработан',2,'частично отработан') STATUS_MNEMO,
				   t.STATUS
			  from D_V_TRANSINVDEPT t,
				   (select v.ID
					  from D_V_CATALOGS v
					 where (:s_lftf = 1 or level = 1)
				connect by v.PID = prior v.ID
				start with v.ID = :CID ) c/*,
				   table (cast (D_PKG_CSE_ACCESSES.GET_ID_WITH_RIGHTS(:LPU,'STORE','12',:CABLAB) as D_C_ID)) cse*/
			 where t.LPU   = :LPU
			   and t.CID   = c.ID
				   --   and t.STORE_ID = cse.COLUMN_VALUE
		   @if (:store_id){
			   and t.STORE_ID = :store_id
		   @}
		   @if (:doc_num){
			   and t.NUMB = :doc_num
		   @}
		   @if (:date_from){
			   and t.DOC_DATE >= :date_from
		   @}
		   @if (:date_to){
			   and t.DOC_DATE <= :date_to
		   @}
		   @if (:in_store_id){
			   and t.IN_STORE_ID = :in_store_id
		   @}
		   @if (:date_mining){
			   and t.WORK_DATE = :date_mining
		   @}
			]]>
			<component cmptype="Variable" name="LPU"                           src="LPU"                    srctype="session"/>
			<component cmptype="Variable" name="CID"         get="CID"         src="DS_TRANSINVDEPT_parent" srctype="var"/>
			<component cmptype="Variable" name="s_lftf"      get="s_lftf"      src="DS_TRANSINVDEPTs_lftf"  srctype="var" default="0"/>
			<component cmptype="Variable" name="date_from"   get="date_from"   src="F_DATE_FROM"            srctype="var"/>
			<component cmptype="Variable" name="date_to"     get="date_to"     src="F_DATE_TO"              srctype="var"/>
			<component cmptype="Variable" name="doc_num"     get="doc_num"     src="F_DOC_NUM"              srctype="var"/>
			<component cmptype="Variable" name="store_id"    get="store_id"    src="F_SKLAD_ID"             srctype="var"/>
			<component cmptype="Variable" name="in_store_id" get="in_store_id" src="F_IN_SKLAD_ID"          srctype="var"/>
			<component cmptype="Variable" name="date_mining" get="date_mining" src="F_DATE_MINING"          srctype="var"/>
			<component cmptype="Variable" type="count"                         src="r1c"                    srctype="var" default="10"/>
			<component cmptype="Variable" type="start"                         src="r1s"                    srctype="var" default="1"/>
		</component>
		<component cmptype="DataSet" name="DS_TRANSINVDEPT_SPECS" activateoncreate="false" mode="Range">
			<![CDATA[
			select ts.ID,
				   ts.NOMMODIF_NAME||', '||ts.PACK_CODE FULL_NAME,
				   ts.GOODPARTY_SER,
				   d_pkg_num_tools.to_str(ROUND(ts.QUANT,3)) COUNT_DESC,
				   ts.PRICEMEAS_MNEMO COUNT_MEASURE,
				   d_pkg_num_tools.to_str(ROUND(ts.QUANT_IN_MAIN,3))||' '||ts.NOMMODIF_MAIN_MEASURE MAIN_QUANT,
				   to_char(ts.SUMM, 'fm999999999999999990.00') SUMM,
				   ts.FINANSOURCE_NAME,
				   ts.STATUS_MNEMO,
				   ts.STATUS,
				   ts.PRISE,
				   d_pkg_num_tools.to_STR(round(D_PKG_NOMMODIF.RECOUNT_FROM_MAIN(ts.NOMMODIF_ID,ts.PRICEMEAS,D_PKG_JURSTORE.GET_RESTS_FOR_DATE(gs.ID,ts.LPU,'RESTFACT',sysdate,0,1)),3)) FACTREST,
				   (select max(DATE_OPER)
					  from D_V_JURSTORE
				     where UNITLIST = 'TRANSINVDEPT_SPECS'
					   and UNITID   = ts.ID) DATE_OPER,
				   ts.GOODPARTY_BARCODE,
				   gp.EXPIRATION_DATE,
				   ts.PRICEMEAS
			 from D_V_TRANSINVDEPT_SPECS ts,
				  D_V_TRANSINVDEPT tr,
				  D_V_GOODSSUPPLY gs,
				  D_V_GOODPARTY gp,
				  D_V_REGPRICE rp
			where ts.PID  = :ID
			  and tr.ID  = ts.PID
			  and gs.LPU = ts.LPU
			  and gs.PID = ts.GOODPARTY_ID
			  and gs.STORE_ID = tr.STORE_ID
			  and ts.FINANSOURCE_ID = gs.FINANSOURCE_ID
			  and ts.GOODPARTY_ID = gp.ID
			  and rp.PID = gs.ID
        	  and rp.PRICE_MEAS = ts.PRICEMEAS
        	  and rp.PRICE = ts.PRISE
		union
			select ts.ID,
				   ts.NOMMODIF_NAME||', '||ts.PACK_CODE FULL_NAME,
				   ts.GOODPARTY_SER,
				   d_pkg_num_tools.to_str(ts.QUANT) COUNT_DESC,
				   ts.PRICEMEAS_MNEMO COUNT_MEASURE,
				   ts.QUANT_IN_MAIN||' '||ts.NOMMODIF_MAIN_MEASURE MAIN_QUANT,
				   to_char(ts.SUMM, 'fm999999999999999990.00') SUMM,
				   ts.FINANSOURCE_NAME,
				   ts.STATUS_MNEMO,
				   ts.STATUS,
				   ts.PRISE,
				   null,
				   null,
				   ts.GOODPARTY_BARCODE,
				   null,
				   ts.PRICEMEAS
			  from D_V_TRANSINVDEPT_SPECS ts,
				   D_V_TRANSINVDEPT tr
			 where ts.PID  = :ID
			   and tr.ID  = ts.PID
			   and not exists(select null
								from D_V_GOODSSUPPLY t
							   where t.PID = ts.GOODPARTY_ID
								 and t.STORE_ID = tr.STORE_ID
								 and t.LPU = ts.LPU
								 and ts.finansource_id = t.finansource_id)
			]]>
			<component cmptype="Variable" name="ID"    srctype="ctrl" src="Transinvdept" get="ID"/>
			<component cmptype="Variable" type="count" srctype="var"  src="r1c"          default="10"/>
			<component cmptype="Variable" type="start" srctype="var"  src="r1s"          default="1"/>
		</component>
		<component cmptype="Action" name="ADD_BY_APPLICATION">
			<![CDATA[
				begin
                  D_PKG_TRANSINVDEPT.ADD_BY_APPLICATION(pnD_INSERT_ID => :TRANSINVDEPT,
                                    			        pnLPU => :LPU,
                                        				pnAPPLICATION => :APPLICATION);
				end;
			]]>
			<component cmptype="ActionVar" name="LPU"          src="LPU"          srctype="session"/>
			<component cmptype="ActionVar" name="APPLICATION"  src="APPLICATION"          srctype="var" get="v1"/>
			<component cmptype="ActionVar" name="TRANSINVDEPT" src="TRANSINVDEPT" srctype="var" put="TRANSINVDEPT" len="17"/>
		</component>
		<!-- =============================================================================================================== -->
		<table style="width: 100%;height: 100%" class="form-table">
			<tbody style="width: 100%;height: 100%">
				<tr>
					<td rowspan="2" style="vertical-align: top; width: 200px; height: 100%">
						<component cmptype="UnitView"
								   unit="CATALOGS"
								   show_method="DEFAULT"
								   catalog_unitcode="TRANSINVDEPT"
								   detaildataset="DS_TRANSINVDEPT"
								   add_script="auto"
								   del_script="auto"
								   edit_script="auto"
								   move_script="auto"
								   listfortree="true"
								   cid_object="CATALOGS_DEFAULT"/>
					</td>
					<td style="height: 50%">
						<component cmptype="Popup" name="TransinvdeptPopup" popupobject="Transinvdept" onpopup="base().onTransinvdeptPopupShow();" cid_object="CATALOGS_DEFAULT">
							<component cmptype="PopupItem" caption="Обновить" onclick="setControlProperty('Transinvdept','locate',getValue('Transinvdept')); setControlProperty('TransinvdeptSpecs','locate',getValue('TransinvdeptSpecs'));refreshDataSet('DS_TRANSINVDEPT');" cssimg="refresh"/>
							<component cmptype="PopupItem" caption="Фильтр" onclick="base().showFilter()"/>
							<component cmptype="PopupItem" caption="-"/>
							<component cmptype="PopupItem" caption="Добавить" unitbp="TRANSINVDEPT_INSERT" onclick="base().editAddTransinvdept ('ADD');" cssimg="insert"/>
							<component cmptype="PopupItem" caption="Добавить из заявки" onclick="base().selectApplication('full', true);" cssimg="insert"/>
							<component cmptype="PopupItem" caption="Копировать" unitbp="TRANSINVDEPT_INSERT" onclick="base().editAddTransinvdept ('COPY');" cssimg="copy"/>
							<component cmptype="PopupItem" caption="Копировать со спецификацией" unitbp="TRANSINVDEPT_INSERT" onclick="base().editAddTransinvdept ('COPY_WITH_SP');" cssimg="copy"/>
							<component cmptype="PopupItem" caption="Изменить" unitbp="TRANSINVDEPT_UPDATE" name="PopDocUpd" onclick="base().editAddTransinvdept ('EDIT');" cssimg="edit"/>
							<component cmptype="PopupItem" caption="Просмотреть" name="PopDocView" onclick="base().viewTransinvdept();"/>
							<component cmptype="PopupItem" caption="Переместить" unitbp="TRANSINVDEPT_MOVE_OUT" onclick="base().moveTransinvdept();" cssimg="move"/>
							<component cmptype="PopupItem" caption="Удалить" unitbp="TRANSINVDEPT_DELETE" name="PopDocDel" onclick="base().deleteTransinvdept();" cssimg="delete"/>
							<component cmptype="PopupItem" caption="-"/>
							<component cmptype="PopupItem" caption="Отработать по складу" unitbp="TRANSINVDEPT_RECYCLE" name="PopWorking" onclick="base().workingTransinvdept();"/>
							<component cmptype="PopupItem" caption="Отменить отработку" unitbp="TRANSINVDEPT_CANCEL_RECYCLE" name="PopCancelWorking" onclick="base().cancelWorkingTransinvdept();"/>
							<component cmptype="PopupItem" caption="Принять на склад" unitbp="TRANSINVDEPT_RECYCLE" name="PopReceive" onclick="base().receiveTransinvdept();"/>
							<component cmptype="PopupItem" caption="-"/>
							<component cmptype="PopupItem" name="ReportsSubMenu" caption="Отчеты" cssimg="report">
								<!--component cmptype="PopupItem" caption="Акт входного контроля" name="PopCancelWorking" onclick="base().printReport('REP_INCOMINGDOC')"/>
								<component cmptype="PopupItem" caption="Приходная накладная" name="PopCancelWorking" onclick="base().printReport('REP2_INCOMINGDOC')"/>
								<component cmptype="PopupItem" caption="Возвратная накладная" name="PopCancelWorking" onclick="base().printReport('VOZVRAT_INCOMINGDOC1')"/-->
								<component cmptype="PopupItem" caption="Расходная накладная (Форма № М-11)" onclick="base().PrintTransinvdept();" cssimg="print"/>
								<component cmptype="PopupItem" caption="Расходная накладная (Форма тест № М-11)" onclick="base().PrintTransinvdept1();" cssimg="print"/>
								<component cmptype="PopupItem" caption="Расходная накладная" onclick="base().PrintTransinvdeptNoOpt();" cssimg="print"/>
								<component cmptype="PopupItem" name="userPopupItem" caption="Сводная накладная" onclick="base().PrintSvodTransinvdept();" cssimg="print"/>
								<component cmptype="PopupItem" caption="Накладная на возврат поставщику" onclick="base().PrintVozvratTransinvdept();" cssimg="print"/>
								<component cmptype="PopupItem" caption="Стеллажная карта" name="pShelfCardTransinvdept" onclick="base().printReport('shelf_card_transinvdept')" cssimg="print"/>
								<component cmptype="PopupItem" caption="Ведомость выдачи материалов на нужды учреждения" onclick="base().PrintDepNeeds();" cssimg="print"/>
							</component>
						</component>
						<component cmptype="AutoPopupMenu" unit="TRANSINVDEPT" all="true" join_menu="TransinvdeptPopup" popupobject="Transinvdept"/>
						<component grid_caption="Документы" cmptype="Grid" name="Transinvdept" selectlist="ID" dataset="DS_TRANSINVDEPT" field="ID" onclone="base().onTransinvdeptClone(this, _dataArray)" onchange="refreshDataSet('DS_TRANSINVDEPT_SPECS')">
							<component cmptype="Column" field="FULLNAME" caption="Документ" sort="FULLNAME" name="DocCol" width="200" filter="FULLNAME"/>
							<component cmptype="Column" field="DOC_SUMM" caption="Сумма" sort="DOC_SUMM" width="100" style="text-align: right;"/>
							<component cmptype="Column" field="STORE_NAME" caption="Склад отправитель" sort="STORE_NAME" width="200" filter="STORE_ID" filterkind="cmb_unit" funit="STORE" fmethod="COMBO" />
							<component cmptype="Column" field="IN_STORE_NAME" caption="Склад получатель" sort="IN_STORE_NAME" width="200" filter="IN_STORE_ID" filterkind="cmb_unit" funit="STORE" fmethod="COMBO"/>
							<component cmptype="Column" field="STOPER_CODE" caption="Операция расхода" sort="STOPER_CODE" />
							<component cmptype="Column" field="IN_STOPER_CODE" caption="Операция прихода" sort="IN_STOPER_CODE" />
							<component cmptype="Column" field="WORK_DATE" caption="Дата отработки" sort="WORK_DATE" width="150"  filter="WORK_DATE" filterkind="date" />
							<component cmptype="Column" field="IN_WORK_DATE" caption="Дата отработки прихода" sort="IN_WORK_DATE" filter="IN_WORK_DATE" filterkind="date"/>
							<component cmptype="Column" field="FULL_VALID" caption="Документ основания" sort="FULL_VALID" filter="FULL_VALID"/>
							<component cmptype="Column" field="FULL_ATTORNEY" caption="Доверенность" sort="FULL_ATTORNEY"/>
							<component cmptype="Column" field="COMMENTS" caption="Примечания" sort="COMMENTS"/>
							<component cmptype="Column" field="STATUS_MNEMO" caption="Статус" sort="STATUS_MNEMO" name="clStatMnemo" filter="STATUS" filterkind="combo" fcontent="0|не отработан;1|отработан;2|частично отработан" />
							<component cmptype="GridFooter" separate="false">
								<component count="10" cmptype="Range" varstart="r1s" varcount="r1c" valuecount="10" valuestart="1"/>
							</component>
						</component>
					</td>
				</tr>
				<tr>
					<td style="height: 50%">
						<component cmptype="Popup" name="TransinvdeptSpecsPopup" popupobject="TransinvdeptSpecs" onpopup="base().onTransinvdeptSpecsPopupShow()" cid_object="CATALOGS_DEFAULT">
							<component cmptype="PopupItem" caption="Обновить" onclick="setControlProperty('TransinvdeptSpecs','locate',getValue('TransinvdeptSpecs'));refreshDataSet('DS_TRANSINVDEPT_SPECS');" cssimg="refresh"/>
							<component cmptype="PopupItem" caption="Добавить" unitbp="TRANSINVDEPT_SPECS_INSERT" name="PopAddSpec" onclick="base().insertTransinvdeptSpecs();" cssimg="insert"/>
							<component cmptype="PopupItem" caption="Изменить" unitbp="TRANSINVDEPT_SPECS_UPDATE" name="PopDocSpecUpd" onclick="base().editTransinvdeptSpecs();" cssimg="edit"/>
							<component cmptype="PopupItem" caption="Просмотреть" name="PopDocSpecView" onclick="base().viewTransinvdeptSpecs();"/>
							<component cmptype="PopupItem" caption="Удалить" unitbp="TRANSINVDEPT_SPECS_DELETE" name="PopDocSpecDel" onclick="base().deleteTransinvdeptSpecs();" cssimg="delete"/>
							<component cmptype="PopupItem" caption="-"/>
							<component cmptype="PopupItem" caption="Добавить из заявки" name="PopAddFromAppl" onclick="base().selectApplication('full');" cssimg="insert"/>
							<component cmptype="PopupItem" caption="Связать с заявкой" name="pLinkAppl" onclick="base().selectApplication('short');" cssimg="ok"/>
							<component cmptype="PopupItem" caption="-"/>
							<component cmptype="PopupItem" caption="Отработать" unitbp="TRANSINVDEPT_SPECS_RECYCLE" name="PopSpecWorking" onclick="base().workingTransinvdeptSpecs();"/>
							<component cmptype="PopupItem" caption="Отменить отработку" unitbp="TRANSINVDEPT_SPECS_CANCEL_RECYCLE" name="PopCancelSpecWorking" onclick="base().cancelWorkingTransinvdeptSpecs();"/>
							<component cmptype="PopupItem" caption="Принять на склад" unitbp="TRANSINVDEPT_SPECS_RECYCLE" name="PopReceiveSpec" onclick="base().receiveTransinvdeptSpecs();"/>
						</component>
						<component cmptype="AutoPopupMenu" unit="TRANSINVDEPT_SPECS" all="true" join_menu="TransinvdeptSpecsPopup" popupobject="TransinvdeptSpecs"/>
						<component grid_caption="Спецификация" cmptype="Grid" dataset="DS_TRANSINVDEPT_SPECS" name="TransinvdeptSpecs" field="ID" onclone="base().onTransinvdeptSpecClone(this, _dataArray);" selectlist="ID">
							<component cmptype="Column" field="FULL_NAME" caption="Наименование модификации" sort="FULL_NAME" name="DocSpecCol" filter="FULL_NAME" sortorder="1"/>
							<component cmptype="Column" field="GOODPARTY_SER" caption="Серия партии" sort="GOODPARTY_SER" width="200" filter="GOODPARTY_SER"/>
							<component cmptype="Column" field="COUNT_DESC" caption="Количество" sort="COUNT_DESC" width="70"/>
							<component cmptype="Column" field="COUNT_MEASURE" caption="Единицы измерения" sort="COUNT_MEASURE" width="70"/>
							<component cmptype="Column" field="MAIN_QUANT" caption="Кол-во в ОЕИ" sort="MAIN_QUANT" width="70"/>
							<component cmptype="Column" field="SUMM" caption="Сумма" sort="SUMM" width="100" style="text-align:right;"/>
							<component cmptype="Column" field="FINANSOURCE_NAME" caption="Источник финансирования" sort="FINANSOURCE_NAME" width="150" filter="FINANSOURCE_NAME"/>
							<component cmptype="Column" field="STATUS_MNEMO" caption="Статус" sort="STATUS_MNEMO" width="150" filter="STATUS_MNEMO"/>
							<component cmptype="Column" field="EXPIRATION_DATE" caption="Срок годности" sort="EXPIRATION_DATE" width="150" filter="EXPIRATION_DATE"/>
							<component cmptype="Column" field="PRISE" caption="Цена" sort="PRISE"/>
							<component cmptype="Column" field="FACTREST" caption="Фактический остаток на складе" sort="FACTREST"/>
							<component cmptype="Column" field="DATE_OPER" caption="Дата отработки" sort="DATE_OPER"/>
							<component cmptype="Column" field="GOODPARTY_BARCODE" caption="Сертификат партии товара" sort="GOODPARTY_BARCODE"/>
							<component cmptype="GridFooter" separate="false">
								<component count="10" cmptype="Range" varstart="r1s" varcount="r1c" valuecount="10" valuestart="1"/>
							</component>
						</component>
					</td>
				</tr>
			</tbody>
		</table>
	</component>
</div>