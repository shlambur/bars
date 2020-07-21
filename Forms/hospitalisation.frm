<div cmptype="tmp" onshow="base().OnShow();" oncreate="base().OnCreate();" window_size="750x650">
  	<div cmptype="title">Госпитализация</div>
	<component cmptype="Script" name="MainScript">
		<![CDATA[
		Form.OnCreate = function () {
			setVar('PMC_ID', getVar('PMC_ID', 1));
			setVar('PMC_FIO', getVar('PMC_FIO', 1));
			setVar('DIRECTION_ID', getVar('DIRECTION_ID', 1));
			setVar('HPK_PLAN_JOURNAL_ID', getVar('HPK_PLAN_JOURNAL_ID', 1));
			setVar('HOSP_PLAN_KIND', getVar('HOSP_PLAN_KIND', 1));
			setValue('HP_KIND_ID', getVar('HOSP_PLAN_KIND', 1));
			setVar('ModalResult', 0, 1);
		};
		Form.OnShow = function () {
            if (typeof(base().UF_onShow) == 'function') {
                base().UF_onShow();
            }

			setCaption('PERSMEDCARD', getVar('PMC_FIO'));
			setValue('PERSMEDCARD', getVar('PMC_ID'));
			executeAction('initAction', base().afterIniAction);
		};
		Form.afterIniAction = function () {
			if (empty(getCaption('HOSP_PLAN_DEPS'))) {
				/**
				 Если пациент госпитализирован но не направлен в отделение,
				 то получить список отделении.
				 Если список один то проставляю в значение код отделения,
				 иначе поле код отделения должно остаться пустым
				 **/
				var obj = {
					'-': 'UniversalComposition/UniversalComposition',
					'unit': 'HOSP_PLAN_DEPS',
					'composition': 'KIND',
					'parent_ctrl': 'HP_KIND_ID',
					'filter[0][unit]': 'HOSP_PLAN_DEPS',
					'filter[0][method]': 'KIND',
					'filter[0][filter]': 'd_pkg_dep_requisites.get_actual(:LPU, v.DEP_ID, to_date(\'' + getValue('HOSPIT_DATE') + '\')) is not null'
				}
				/**Формирую URL адрес**/
				var str = '';
				for (var i in obj) {
					if (str !== '') {
						str += '&';
					}
					if (i == '-') {
						str += obj[i];
					} else {
						str += i + '=' + obj[i];
					}
				}
				/***************************/
				requestServerDataSet(str, {
					'mode': 'Field',
					'Field': 'ID,DEP',
					'DataSet': 'DS_HOSP_PLAN_DEPS_KIND',
					'HP_KIND_ID': getValue('HP_KIND_ID')
				}, function (_xml) {
					try {
						var rowcount = parseInt(_xml.querySelector('DataSet[name="DS_HOSP_PLAN_DEPS_KIND"] > info > rowcount').innerHTML);
						if (rowcount === 1) {
							setValue('HOSP_PLAN_DEPS', _xml.querySelector('DataSet[name="DS_HOSP_PLAN_DEPS_KIND"] > row > ID').innerHTML);
							setCaption('HOSP_PLAN_DEPS', _xml.querySelector('DataSet[name="DS_HOSP_PLAN_DEPS_KIND"] > row > DEP').innerHTML);
						}
					}
					catch (e) {
					}
				}, null, getPage());
			} else {
				/** выделять крысным если пришло caption но нет value **/
				edit_getInput(getControlByName('HOSP_PLAN_DEPS')).onblur();
			}
			/********************************************************/


			refreshDataSet('DS_DEP_PARS');

			if (!empty(getVar('HHNumerationMask')) || !empty(getVar('HH_NUMB_MASK'))) {
				Form.mask = empty(getVar('HPK_PLAN_JOURNAL_ID')) ? getVar('HHNumerationMask').toLowerCase() : getVar('HH_NUMB_MASK').toLowerCase();

				if (empty(Form.mask))
					Form.mask = getVar('HHNumerationMask').toLowerCase();

				if (Form.mask.indexOf('numb') != -1) {
					getControlByName('HHnumber').style.display = 'inline-table';
					getControlByName('ImgHHnumber').style.display = '';
					setControlProperty('DepControlsNextButton', 'add_req', 'HHnumber');
				}
				else {
					getControlByName('HHnumber').style.display = 'none';
					getControlByName('ImgHHnumber').style.display = 'none';
					setControlProperty('DepControlsNextButton', 'del_req', 'HHnumber');
				}

				if (Form.mask.indexOf('altern') != -1) {
					getControlByName('FullNumber').style.display = 'inline-table';
					getControlByName('ImgFullNumber').style.display = '';
					getControlByName('LabelFullNumber').style.display = '';
					setControlProperty('DepControlsNextButton', 'add_req', 'FullNumber');
				}
				else {
					getControlByName('FullNumber').style.display = 'none';
					getControlByName('ImgFullNumber').style.display = 'none';
					getControlByName('LabelFullNumber').style.display = 'none';
					setControlProperty('DepControlsNextButton', 'del_req', 'FullNumber');
				}

				if (Form.mask.indexOf('numb') == -1 && Form.mask.indexOf('altern') == -1) {
					getControlByName('hh_numb_row').style.display = 'none';
				}
			}

			if (empty(getVar('DISABLE_ALL'))) {
				if (!empty(getVar('HH_ID'))) {
					setTabSheetVisibleByName('HospControl2', true);
					base().setSecondTabSheetBlock(1);
				}
				else {
					if (!empty(getVar('DEF_HOSP_REASON_ID'))) {
						setValue('HOSP_REASONS', getVar('DEF_HOSP_REASON_ID'));
					}
					else {
						setValue('HOSP_REASONS', getVar('HOSP_REASON_ID'));
					}
					if (empty(getValue('HOSP_TYPE'))) {
						setValue('HOSP_TYPE', getVar('DEF_HOSP_TYPE_ID'));
					}
					setValue('TRANSP', getVar('DEF_TRANSP_TYPE_ID'));
				}
			}
			else {
				setTabSheetVisibleByName('HospControl2', true);
				getControlByName('NextButton').style.display = 'none';
				getControlByName('BackButton').style.display = 'none';
				base().setFirstTabSheetBlock(1);
				base().setSecondTabSheetBlock(1);
			}
			base().showHideWarnPmc();
			setControlProperty('OkButton', 'enabled', false);
			refreshDataSet('DS_HOSP_REASONS');
			Form.checkRelatives();
			if (!empty(getVar('RELATIVE_HH_ID'))) {
				setValue('IS_RELATIVE_HOSP', 1);
			}

			if (getVar('SPEC_LPU_TYPE') != 1) {
				removeDomObject(getControlByName('CI_INSANE'));
				base().checkMentalItems(0);
			} else {
                ComboBox_SetEnabled(getControlByName('HH_TYPE'), false);
				base().checkMentalItems(1);
			}

			if (getVar('PMC_TYPE') != 2) getControlByName("ROW_NOVOR_NUM").style.display = 'none';
			if (getVar('PMC_TYPE') == 2 || getVar('NSEX') == 1 || getValue('HH_TYPE') == 4) getControlByName("ROW_GEST_PERIOD").style.display = 'none';

			if (getVar('HospDateRestriction') == 1) {
				setControlProperty('HOSPIT_DATE', 'enabled', false);
				setControlProperty('HOSPIT_HOURS', 'enabled', false);
				setControlProperty('DATE_DEPARTURE', 'enabled', false);
				setControlProperty('TIME_DEPARTURE', 'enabled', false);
			}
		};

		Form.checkRelatives = function () {
			if (empty(getValue('AGENT_RELATIVES')) &amp;&amp; !empty(getVar('CHILD_AGE')) &amp;&amp; parseInt(getVar('PAT_YEAR')) < parseInt(getVar('CHILD_AGE'))) {
				ButtonEdit_SetColor(getControlByName('AGENT_RELATIVES'), 'yellow');
			}

			if (!empty(getVar('DISABLE_ALL')) && getVar('IS_HH_UPD_HOSP') == 1) {
				if (!empty(getVar('HHNumerationMask')) || !empty(getVar('HH_NUMB_MASK'))) {
					if (Form.mask.indexOf('pref') != -1) {
						setControlProperty('HOSP_PLAN_DEPS', 'enabled', true);
					}
					if (Form.mask.indexOf('numb') != -1) {
						getControlByName('HHnumber').style.display = 'inline-table';
						getControlByName('ImgHHnumber').style.display = '';
						setControlProperty('DepControlsNextButton', 'add_req', 'HHnumber');
						setControlProperty('HHnumber', 'enabled', true);
					}
					if (Form.mask.indexOf('altern') != -1) {
						getControlByName('FullNumber').style.display = 'inline-table';
						getControlByName('ImgFullNumber').style.display = '';
						getControlByName('LabelFullNumber').style.display = '';
						setControlProperty('DepControlsNextButton', 'add_req', 'FullNumber');
						setControlProperty('FullNumber', 'enabled', true);
					}
				}
				setControlProperty('OkButton', 'enabled', true);
			}
		};
		Form.showHideWarnPmc = function () {
			if (getVar('CHECK_FOR_OMS') == 0)
				return;

			if (empty(getVar('ERRORS_PMC')))
				getControlByName('WARN_PMC').style.display = 'none';
			else
				getControlByName('WARN_PMC').style.display = '';
		}
		Form.reDoPmc = function () {
			executeAction('PatientCheck', base().showHideWarnPmc);
		}
		Form.setFirstTabSheetBlock = function (_param) // _param: 1-контролы неактивны на первой вкладке, 0-активны
		{
			var _bool;
			if (_param == 1) _bool = false; else _bool = true;
			setControlProperty('HOSP_PLAN_DEPS', 'enabled', _bool);
			setControlProperty('HHnumber', 'enabled', _bool);
			setControlProperty('FullNumber', 'enabled', _bool);
			setControlProperty('HOSP_REASONS', 'enabled', _bool);
			setControlProperty('PLAN_DATE_OUT', 'enabled', _bool);
			setControlProperty('HOSP_TYPE', 'enabled', _bool);
			setControlProperty('HH_TYPE', 'enabled', (_bool || getVar('IS_HH_UPD_HOSP') == '1'));
			setControlProperty('TRANSP', 'enabled', _bool);
			setControlProperty('LPUDICT', 'enabled', _bool);
			setControlProperty('AGENT_RELATIVES', 'enabled', _bool);
			setControlProperty('HOSP_TIMES', 'enabled', _bool);
			setControlProperty('MKB_SEND', 'enabled', _bool);
			setControlProperty('MKB_SEND_HANDLE', 'enabled', _bool);
			setControlProperty('MKB10', 'enabled', _bool);
			setControlProperty('MKB10_HANDLE', 'enabled', _bool);
			setControlProperty('HOSPIT_DATE', 'enabled', _bool);
			setControlProperty('HOSPIT_HOURS', 'enabled', _bool);
			setControlProperty('TERM', 'enabled', _bool);
			setControlProperty('HOSP_IS_FIRST', 'enabled', _bool);
			setControlProperty('ARRIVE_ORDER', 'enabled', _bool);
			setControlProperty('JUDGE_DECISION', 'enabled', _bool);
			setControlProperty('HOSP_INCOME', 'enabled', _bool);
			setControlProperty('HOSP_HOUR', 'enabled', _bool);
			setControlProperty('NOVOR_NUM', 'enabled', _bool);
		};
		Form.setSecondTabSheetBlock = function (_param) // _param: 1-контролы неактивны на второй вкладке, 0-активны
		{
			var _bool;
			if (_param == 1) _bool = false; else _bool = true;
			setControlProperty('DEPS_PAR', 'enabled', _bool);
			setControlProperty('DEP_BED', 'enabled', _bool);
			setControlProperty('PAYMENT_KIND', 'enabled', _bool);
			setControlProperty('FAC_ACC', 'enabled', _bool);
			//setControlProperty('COMMIT_COMMENT', 'enabled', _bool);
		}
		//выбор родителя
		Form.relatives = function () {
			setVar('ModalResult', 'cancel');
			setVar('LOCATE_ID', getValue('AGENT_RELATIVES'));
			openWindow({name: 'HospPlan/hp_relativechoise'}, true, 500, 400)
					.addListener('onafterclose',
							function (result) {
								if (result.ModalResult == 'ok') {
									setValue('AGENT_RELATIVES', result.agent_relative);
									setCaption('AGENT_RELATIVES', result.agent_relative_fio);
									setVar('RELATIVE_AGENT_ID', result.relative_agent_id);
									ButtonEdit_SetColor(getControlByName('AGENT_RELATIVES'), '#eeeeee');
								}
							},
							null,
							false);
		}

		//редактировать карту пациента
		Form.openPersMedCard = function () {
			setVar('PERSMEDCARD', getValue('PERSMEDCARD'));
			openWindow('Persmedcard/persmedcard_edit', true, 800, 580)
					.addListener('onafterclose', base().reDoPmc);
		}

		//действия кнопок
		Form.onCancelButtonClick = function () {
			if (getVar('ModalResult', 1) != 1) {
				setVar('ModalResult', 'cancel', 1);
			}
			closeWindow();
		}

		Form.onNextButtonClick = function () {
			if (!empty(getVar('ERRORS_PMC')) && getVar('CHECK_FOR_OMS') == 1
					&& (getVar('PKOMS_OPT') == getVar('PK_CODE'))) {
				showAlert('Госпитализация невозможна. Исправьте ошибки в карте пациента.', 'Ошибка', 450, 150);
				return;
			}
			if (typeof(Form.onNextButtonClickEditUserForm) == 'function')
				Form.onNextButtonClickEditUserForm();
			if (empty(getVar('HH_ID')))
				executeAction('hospHistoryAdd', base().afterNextBut);
			else {
				executeAction('hospHistoryEdit', base().afterNextBut);
			}
		}
		Form.afterNextBut = function () {
			if (empty(getValue('DEPS_PAR')) || getVar('HOSP_PLAN_DEPS') != getCaption('HOSP_PLAN_DEPS'))
				executeAction('trySetDefDep');
			setTabSheetVisibleByName('HospControl2', true);
			base().setSecondTabSheetBlock(0);
			base().setFirstTabSheetBlock(1);
			getControlByName('NextButton').style.display = 'none';
			getControlByName('BackButton').style.display = '';
			setControlProperty('OkButton', 'enabled', true);
			tabSheetActivate('HospControl2');
			setVar('ModalResult', 1, 1);
		}
		Form.onBackButtonClick = function () {
			base().setSecondTabSheetBlock(1);
			base().setFirstTabSheetBlock(0);
			getControlByName('NextButton').style.display = '';
			getControlByName('BackButton').style.display = 'none';
			setControlProperty('OkButton', 'enabled', false);
			tabSheetActivate('HospControl1');
		}
		Form.onOkButtonClick = function () {
			setVar('ModalResult', 1, 1);
			setVar('HH_ID', getVar('HH_ID'), 1);
		    if(empty(getVar('DISABLE_ALL'))){
				executeAction('dirToDep', function () {
					Form.updHHNumb(getVar('HH_ID'),
							getCaption('HOSP_PLAN_DEPS'),
							getValue('HHnumber'),
							getValue('FullNumber'),
							base().afterOkButtonCl);
				});
			}else{
				Form.updHHNumb(getVar('HH_ID'),
						getCaption('HOSP_PLAN_DEPS'),
						getValue('HHnumber'),
						getValue('FullNumber'),
						base().afterOkButtonCl);
			}
		}
		Form.afterOkButtonCl = function () {
			//printReportByCode() //отчет по HH_ID
			closeWindow();
		}
		Form.updHHNumb = function (hh_id, hh_pref, hh_numb, hh_numb_altern, callback) {
			setVar('_HH_ID', hh_id);
			setVar('_HH_PREF', hh_pref);
			setVar('_HH_NUMB', hh_numb);
			setVar('_HH_NUMB_ALTERN', hh_numb_altern);
			executeAction('updHHNumb', function () {
				callback && callback.call(this);
			});
		};
		Form.onCOMMIT_COMMENTButtonClick = function () {
			executeAction('saveComment');
		}
		Form.reCheckFaccAcc = function () {
			executeAction('recheckFaccAcc', function () {
				if (getVar('ENABLE_FA') == 1)
					setControlProperty('FAC_ACC', 'enabled', true);
				else
					setControlProperty('FAC_ACC', 'enabled', false);
			});
		}
		Form.selectMkbExact = function (_dom) {
			setVar('MkbExactValue', getControlValue(buttonEdit_getControl(_dom)));
			openWindow('ArmPatientsInDep/SubForms/select_mkb_exact', true)
					.addListener('onafterclose', function () {
						if (getVar('ModalResult') == 1)
							setControlValue(buttonEdit_getControl(_dom), getVar('return_value'));
					});
		}
		Form.selDepBed = function () {
			setVar('DEP', getValue('DEPS_PAR'));
			setVar('DDATE', getValue('HOSPIT_DATE'));
			if (empty(getVar('DDATE'))) {
				alert('Не выбрана дата!');
				return;
			}
			openWindow('ArmPatientsInDep/SubForms/select_dep_bed', true)
					.addListener('onafterclose', function () {
						if (getVar('ModalResult') == 1) {
							setValue('DEP_BED', getVar('return_id'));
							setCaption('DEP_BED', getVar('return'));
						}
					});
		}
		Form.checkHR = function () {
			if (empty(getVar('DISABLE_ALL'))) {
				if (!empty(getVar('HOSP_REASONS')) && empty(getValue('HOSP_REASONS')))
					setValue('HOSP_REASONS', getVar('HOSP_REASONS'))
				if (empty(getValue('HOSP_REASONS'))) {
					if (!empty(getVar('HOSP_REASONS'))) {
						setValue('HOSP_REASONS', null);
						MaskInspector_addControl('REASON_MASK', 'HOSP_REASONS');
						ComboBox_SetColor(getControlByName('HOSP_REASONS'), 'red');
						ComboBox_SetCaption(getControlByName('HOSP_REASONS'), getVar('REASON_NAME'), true, true);
					}
				} else {
					ComboBox_SetColor(getControlByName('HOSP_REASONS'), 'white');
				}
			}
		}
		Form.onChangeDate = function () {
			if (getVar('HOSPIT_DATE') != getValue('HOSPIT_DATE')) {
				if (empty(getValue('HOSP_REASONS'))) {
					if (empty(getCaption('HOSP_REASONS'))) {
						setVar('HOSP_REASONS', null);
						setVar('REASON_NAME', null);
					} else {
						setValue('HOSP_REASONS', getVar('HOSP_REASONS'));
					}
				} else {
					setVar('HOSP_REASONS', getValue('HOSP_REASONS'));
					setVar('REASON_NAME', getCaption('HOSP_REASONS'));
				}
				refreshDataSet('DS_HOSP_REASONS');
				refreshDataSet('DS_DEP_PARS');
			}
			setVar('HOSPIT_DATE', getValue('HOSPIT_DATE'));
            Form.executeGetHospTimes();
		}
		Form.checkAndSave = function (type) {
			var callback = type === 1 ? Form.onOkButtonClick : Form.onNextButtonClick,
					message = '';
			executeAction('ACT_CHECK_DEATHDATE', function () {
				if (getVar('IS_DEAD') == 1) {
					if (getVar('SO_DEATH_CHECK') == 1) {
						showAlert('Нельзя госпитализировать пациента с датой смерти (' + getVar('DEATH_DATE') + ') ' +
								'меньше даты записи.', null, 545, 115);
					} else if (getVar('SO_DEATH_CHECK') == 2) {
						showConfirm('Дата смерти госпитализируемого пациента (' + getVar('DEATH_DATE') + ') меньше даты ' +
								'записи. Выбрать другого пациента или сменить дату записи?', null, 475, 135,
								emptyFunction, callback);
					} else {
						callback();
					}
				} else if (getVar('IS_DEAD_RLTV') == 1) {
					if (getVar('SO_DEATH_CHECK') == 1) {
						showAlert('Нельзя указывать сопровождающее лицо с датой смерти (' + getVar('DEATH_DATE_RLTV') +
								' ) меньше даты записи.', null, 570, 115);
					} else if (getVar('SO_DEATH_CHECK') == 2) {
						showConfirm('Дата смерти сопровождающего лица (' + getVar('DEATH_DATE_RLTV') + ') ' +
								'меньше даты записи. Выбрать другое сопровождающее лицо или сменить дату записи?',
								null, 475, 135, emptyFunction, callback);
					} else {
						callback();
					}
				} else {
					callback();
				}
			});
		};
		Form.onChangeHHType = function () {
			if (getValue('HH_TYPE') == 1) {
				AddReqControl(getControlByName('DepControlsNextButton'), 'TERM');
				AddReqControl(getControlByName('DepControlsOkButton'), 'TERM');
			}
			else {
				DelReqControl(getControlByName('DepControlsNextButton'), 'TERM');
				DelReqControl(getControlByName('DepControlsOkButton'), 'TERM');
			}

			if (getValue('HH_TYPE') == 4) {
				base().checkMentalItems(1);
			} else {
				base().checkMentalItems(0);
			}
		}

		Form.countHospTimes = function () {
            Form.executeGetHospTimes();
		}

		Form.executeGetHospTimes = function () {
            if(!getValue('HOSP_TIMES')) {
                executeAction('getHospTimes');
            }
        }

		Form.checkMentalItems = function (type) {
			var list = document.querySelectorAll('.TR_MENTAL_INFO');
			for (var i = 0; i < list.length; i++) {
				if (type == 1) {
					list[i].style.display = "";
				} else {
					list[i].style.display = "none";
				}
			}
		}

		Form.checkHHNumberValidness = function (event, target_ctrl_name) {
			if (event && (event.key == ',' || event.key == '.' || event.key == ';')) {
				event.preventDefault();
			}
			else {
				var invalid_symbols = [',', '.', ';'],
						err = 0;

				invalid_symbols.forEach(function (s) {
					if (getValue(target_ctrl_name).indexOf(s) != -1) {
						err = 1;
					}
				});

				if (err == 1)
					addClass(getControlByName(target_ctrl_name), 'invalid_hh_number');
				else
					removeClass(getControlByName(target_ctrl_name), 'invalid_hh_number');
			}
		}
		]]>
	</component>
	<component cmptype="Action" name="getHospTimes">
		<![CDATA[
			declare
			  nSOHospQuant    NUMBER(1);
			begin
			  nSOHospQuant := D_PKG_OPTIONS.get('HospTimesQuant',:LPU);
			  if nSOHospQuant = 1 then
				select count(1)
				  into :HOSP_TIMES
				  from D_V_HOSP_HISTORIES_BASE hh
				 where hh.LPU = :LPU
				   and hh.PATIENT = :PATIENT_ID
				   and hh.MKB_RECEIVE = :MKB10
				   and hh.DATE_OUT >= ADD_MONTHS(:HOSP_DATE,-12);
			  elsif nSOHospQuant = 2 then
				select count(distinct hh.ID)
				  into :HOSP_TIMES
				  from D_V_HOSP_HISTORIES_BASE hh
					   join D_V_PERSMEDCARD_BASE pmc on hh.PATIENT = pmc.ID
					   join D_V_PERSMEDCARD_BASE pmc1 on pmc1.AGENT = pmc.AGENT
				 where pmc1.ID = :PATIENT_ID
				   and hh.MKB_RECEIVE = :MKB10
				   and hh.DATE_OUT >= ADD_MONTHS(:HOSP_DATE,-12);
			  end if;
			end;
		]]>
		<component cmptype="ActionVar" name="LPU"            src="LPU"            srctype="session"/>
		<component cmptype="ActionVar" name="PATIENT_ID"     src="PMC_ID"         srctype="var"         get="v1"/>
		<component cmptype="ActionVar" name="MKB10"     	 src="MKB10"       	  srctype="ctrl" 		get="v2"/>
		<component cmptype="ActionVar" name="HOSP_DATE"      src="HOSPIT_DATE"    srctype="ctrl" 		get="v3"/>
		<component cmptype="ActionVar" name="HOSP_TIMES" 	 src="HOSP_TIMES"     srctype="ctrl"        put="v1" len="3"/>
	</component>
	<component cmptype="Action" name="trySetDefDep">
		begin
			select t.ID
			  into :DEPS_PAR
			  from D_V_DEPS t
			 where t.LPU = :LPU
			   and t.DP_CODE = :DEPS;
			exception when NO_DATA_FOUND then :DEPS_PAR := null;
			          when TOO_MANY_ROWS then :DEPS_PAR := null;
		end;
		<component cmptype="ActionVar" name="LPU"      src="LPU"            srctype="session"/>
		<component cmptype="ActionVar" name="DEPS"     src="HOSP_PLAN_DEPS" srctype="ctrlcaption" get="v1"/>
		<component cmptype="ActionVar" name="DEPS_PAR" src="DEPS_PAR"       srctype="ctrl"        put="v2" len="17"/>
	</component>
	<component cmptype="Action" name="PatientCheck">
		<![CDATA[
			begin
				select decode(d_pkg_persmedcard.check_for_oms(pnID => :PAT_ID,
				                                            pnTYPE => 1), null, null,
					  			'Не заполнены или заполнены некорректно следующие данные: '||d_pkg_persmedcard.check_for_oms(pnID => :PAT_ID,
					  			                                                                                           pnTYPE => 1))
				  into :ERRORS_PMC
				from dual;
			end;
		]]>
		<component cmptype="ActionVar" name="PAT_ID"     src="PMC_ID"     srctype="var" get="v1"/>
		<component cmptype="ActionVar" name="ERRORS_PMC" src="ERRORS_PMC" srctype="var" put="v2" len="4000"/>
	</component>
	<component cmptype="Action" name="saveComment">
		<![CDATA[
			begin
				for cur in (select *
				              from d_v_hpk_plan_journals
				             where id = :HPKJ_ID) loop
			 		d_pkg_hpk_plan_journals.UPD(cur.id,
								                :LPU,
								                cur.HPK_PLAN,
								                cur.PATIENT_ID,
								                cur.DIRECTED_BY_ID,
								                cur.DIRECTED_TO_ID,
								                cur.REGISTERED_BY_ID,
								                cur.REGISTER_DATE,
								                cur.HAS_PRIVILEGES,
								                cur.OPERATION_ID,
								                cur.PAYMENT_KIND_ID,
								                cur.DIRECTION,
								                cur.IS_OPER,
								                cur.IS_READY,
								                cur.HH_DIRECTION_DATE,
								                :COMM,
								                cur.HPK,
												cur.RECORD_NUMB,
												cur.RECORD_PREF);
				end loop;
			end;
		]]>
		<component cmptype="ActionVar" name="LPU"     src="LPU"                 srctype="session"/>
		<component cmptype="ActionVar" name="HPKJ_ID" src="HPK_PLAN_JOURNAL_ID" srctype="var"  get="v1"/>
		<component cmptype="ActionVar" name="COMM"    src="COMMENT"             srctype="ctrl" get="v1"/>
	</component>
	<component cmptype="Action" name="dirToDep" mode="post">
		<![CDATA[
			declare nQUIT NUMBER(1);
					nDEP  NUMBER(17);
					nBED  NUMBER(17);
					nOLDDEP NUMBER(17);
					nTMP_HH_DEP NUMBER(17);
					nEMP	    NUMBER(17);
					nHOURS	    VARCHAR2(10);
					nNEW_ID	    NUMBER(17);
					nERROR		NUMBER(1);
					nDIR_ID     NUMBER(17);
					dDATE_IN    DATE;
					sDEP_HOURS	VARCHAR2(10);
					nMKB        NUMBER(17);
                    dDATE_OUT   DATE;
                    nHOSP_RESULT  NUMBER(17);
                    sMKB_EXACT  VARCHAR2(4000);
                    nKSG        NUMBER(17);
                    nVMP        NUMBER(17);
                    nHOSP_BED_TYPE_ID NUMBER(17);
                    nHOSP_OUTCOME NUMBER(17);
			begin
				if :DEP_ID is not null and :PAYMENT is not null then
					nQUIT := 0;
				else
					nQUIT := 1;
				end if;

				if :HOURS is null then
					nHOURS := '00:00';
				else
					nHOURS := :HOURS;
				end if;

				if :TIME_DEPARTURE is null then
					sDEP_HOURS := '00:00';
				else
					sDEP_HOURS := :TIME_DEPARTURE;
				end if;

				if :DATE_DEPARTURE is not null then
					dDATE_IN := to_date(:DATE_DEPARTURE||' '||sDEP_HOURS, 'dd.mm.yyyy hh24:mi');
				else
					dDATE_IN := to_date(:DATE_IN||' '||nHOURS, 'dd.mm.yyyy hh24:mi');
				end if;

				if nQUIT = 0 then
					select count(t1.id)
					  into nERROR
					  from d_v_hosp_history_deps t1
					 where t1.pid = :HH_ID;
					if nERROR > 1 then
						D_P_EXC('У пациента уже есть перемещения по отделениям, направление в отделение невозможно!');
					end if;
					if nERROR = 1 then
						--Ищем отделения и койки.
						  select DEP_ID
							into nDEP
							from d_v_hosp_history_deps
						   where pid = :HH_ID;
						if nDEP = :DEP_ID
						then
							nBED := nvl(:BED,0);
							nOLDDEP := 1;
						else
							select count(t.id), 0
							  into nBED, nOLDDEP
							  from d_v_hosp_history_deps t1,
								d_v_hh_dep_beds       t
							 where t1.pid = :HH_ID
								   and t.pid = t1.id;
						end if;
						if nBED > 0 then
							--здесь бы confirm 'Это действие удалит существующие перемещения по койкам. Продолжить?';
							for cur in (select t.ID
									     from d_v_hosp_history_deps t1
									          join d_v_hh_dep_beds t on t.pid = t1.id
									    where t1.pid = :HH_ID) loop
								d_pkg_hh_dep_beds.del(cur.ID, :LPU);
							end loop;
						end if;
					end if;
					begin
					  	select ID,
						       decode(HEALING_EMP,null,null,decode(D_PKG_CSE_ACCESSES.check_employer_right(:LPU,HEALING_EMP,'DEPS',:DEP_ID,5,NULL,null,0),1,HEALING_EMP,null)),
                               MKB_ID,
                               DATE_OUT,
                               MKB_EXACT,
                               HOSP_RESULT_ID,
                               KSG_ID,
                               VMP_ID,
                               HOSP_OUTCOME_ID,
                               BED_TYPE_ID
					      into nTMP_HH_DEP,
					           nEMP,
					           nMKB,
                               dDATE_OUT,
                               sMKB_EXACT,
                               nHOSP_RESULT,
                               nKSG,
                               nVMP,
                               nHOSP_OUTCOME,
                               nHOSP_BED_TYPE_ID
						  from d_v_hosp_history_deps
						 where pid = :HH_ID;
					  	d_pkg_hosp_history_deps.upd(pnid => nTMP_HH_DEP,
										           pnlpu => :LPU,
										       pddate_in => dDATE_IN,
										      pddate_out => dDATE_OUT,
										           pndep => :DEP_ID,
										           pnmkb => nMKB,
										     pSmkb_exact => sMKB_EXACT,
										   pnhealing_emp => nEMP,
										  pnpayment_kind => :PAYMENT,
										   pnhosp_result => nHOSP_RESULT,
										           pnksg => nKSG,
                                              pnbed_type => coalesce(nHOSP_BED_TYPE_ID,:HOSP_BED_TYPE_ID),
                                        pnFacial_account => :FA,
                                                   pnVMP => nVMP,
                                          pnhosp_outcome => nHOSP_OUTCOME);
						exception when TOO_MANY_ROWS then D_P_EXC('У пациента были перемещения по отделениям!');
							      when NO_DATA_FOUND then D_PKG_HOSP_HISTORY_DEPS.ADD(pnd_insert_id => nTMP_HH_DEP,
																                              pnlpu => :LPU,
																                              pnpid => :HH_ID,
																                          pddate_in => dDATE_IN,
																                         pddate_out => null,
																                              pndep => :DEP_ID,
																                              pnmkb => null,
																                        pSmkb_exact => null,
																                      pnhealing_emp => null,
																                     pnpayment_kind => :PAYMENT,
																                      pnhosp_result => null,
																                              pnksg => null,
																                         pnbed_type => :HOSP_BED_TYPE_ID,
																                   pnFacial_account => :FA,
																                              pnVMP => null,
																                     pnhosp_outcome => null);
					end;
					if :BED is not null and nTMP_HH_DEP  is not null then
					  	d_pkg_hh_dep_beds.add(pnd_insert_id => nNEW_ID,
								                      pnlpu => :LPU,
								                      pnpid => nTMP_HH_DEP,
								                  pddate_in => dDATE_IN,
								                 pddate_out => null,
								                  pndep_bed => :BED);
					end if;
				end if;
				begin
					for cur in (select *
					              from d_v_hpk_plan_journals
					             where id = :HPKJ_ID) loop
				 		d_pkg_hpk_plan_journals.UPD(cur.id,
								                    :LPU,
								                    cur.HPK_PLAN,
								                    cur.PATIENT_ID,
								                    cur.DIRECTED_BY_ID,
								                    cur.DIRECTED_TO_ID,
								                    cur.REGISTERED_BY_ID,
								                    cur.REGISTER_DATE,
								                    cur.HAS_PRIVILEGES,
								                    cur.OPERATION_ID,
								                    cur.PAYMENT_KIND_ID,
								                    cur.DIRECTION,
								                    cur.IS_OPER,
								                    cur.IS_READY,
								                    cur.HH_DIRECTION_DATE,
								                    :COMM,
								                    cur.HPK,
												    cur.RECORD_NUMB,
												    cur.RECORD_PREF);
						nDIR_ID := cur.DIRECTION;
					end loop;
					exception when OTHERS then null;
				end;

				for cr in (select t.*
				             from D_V_DIRECTIONS t
				            where t.ID = nDIR_ID) loop
					d_pkg_directions.upd(pnid => cr.ID,
				                        pnlpu => cr.LPU,
				            pnouter_direction => cr.OUTER_DIRECTION_ID,
				                     pnlpu_to => cr.LPU_TO_ID,
				              pslpu_to_handle => cr.LPU_TO_HANDLE,
				                psdir_comment => cr.DIR_COMMENT,
				                   pnreg_type => cr.REG_TYPE,
				                   pndir_type => cr.DIR_TYPE,
				                   pnhosp_mkb => cr.HOSP_MKB_ID,
				                  pnhosp_kind => cr.HOSP_KIND_ID,
				                   psdir_numb => cr.DIR_NUMB,
				                   psdir_pref => cr.DIR_PREF,
				                 pnspeciality => cr.SPECIALITY_ID,
				               pnex_cause_mkb => cr.EX_CAUSE_MKB_ID,
				                pninjure_kind => cr.INJURE_KIND_ID,
				                pninjure_time => cr.INJURE_TIME,
				             pndirection_kind => cr.DIRECTION_KIND_ID,
				                   pnhosp_dep => :DEP_ID,
				              pnhosp_bed_type => cr.HOSP_BED_TYPE_ID,
				                        pnmes => cr.MES_ID,
				                  pnREG_HPKPJ => cr.REG_HPKPJ,
				                pnHOSP_REASON => cr.HOSP_REASON_ID,
				                   pdREG_DATE => cr.REG_DATE,
				             pdHOSP_PLAN_DATE => cr.HOSP_PLAN_DATE,
				                    pddate_tr => cr.DATE_TR,
				               pnHOSP_DEPDICT => cr.HOSP_DEPDICT_ID,
				                psDOC_COMMENT => cr.DOC_COMMENT,
				            pnHOSP_PALAN_KIND => null,
				                  pnHOSP_TYPE => :HOSP_TYPE,
                             pdTALON_VMP_DATE => cr.TALON_VMP_DATE,
								 vAPI_VERSION => 6,
							 psHOSP_MKB_EXACT => :MKB10_HANDLE
									);
				end loop;
			end;
		]]>
		<component cmptype="ActionVar" name="LPU"               src="LPU"                 srctype="session"/>
		<component cmptype="ActionVar" name="DEP_ID"            src="DEPS_PAR"            srctype="ctrl"    get="v1"/>
		<component cmptype="ActionVar" name="PAYMENT"           src="PAYMENT_KIND"        srctype="ctrl"    get="v2"/>
		<component cmptype="ActionVar" name="HOURS"             src="HOSPIT_HOURS"        srctype="ctrl"    get="v3"/>
		<component cmptype="ActionVar" name="HH_ID"             src="HH_ID"               srctype="var"	    get="v4"/>
		<component cmptype="ActionVar" name="BED"               src="DEP_BED"             srctype="ctrl"    get="v5"/>
		<component cmptype="ActionVar" name="FA"                src="FAC_ACC"             srctype="ctrl"    get="v6"/>
		<component cmptype="ActionVar" name="DATE_IN"           src="HOSPIT_DATE"         srctype="ctrl"    get="v7"/>
		<component cmptype="ActionVar" name="DATE_IN"           src="HOSPIT_DATE"         srctype="var"	    put="v7_1"/>
		<component cmptype="ActionVar" name="HPKJ_ID"           src="HPK_PLAN_JOURNAL_ID" srctype="var"     get="v8"/>
		<component cmptype="ActionVar" name="COMM"              src="COMMENT"             srctype="ctrl"    get="v9"/>
		<component cmptype="ActionVar" name="HOSP_BED_TYPE_ID"	src="HOSP_BED_TYPE_ID"    srctype="var"     get="v10"/>
		<component cmptype="ActionVar" name="DATE_DEPARTURE"    src="DATE_DEPARTURE"      srctype="ctrl"    get="v11"/>
		<component cmptype="ActionVar" name="TIME_DEPARTURE"    src="TIME_DEPARTURE"      srctype="ctrl"    get="v12"/>
		<component cmptype="ActionVar" name="HOSP_TYPE"         src="HOSP_TYPE"           srctype="ctrl"    get="v13"/>
		<component cmptype="ActionVar" name="DISABLE_ALL"       src="DISABLE_ALL"         srctype="var"     get="v14"/>
		<component cmptype="ActionVar" name="MKB10_HANDLE"      src="MKB10_HANDLE"        srctype="ctrl"    get="v15"/>
	</component>
  	<component cmptype="Action" name="updHHNumb" mode="post">
    	<![CDATA[
      		declare
        		nCOUNT NUMBER(17);
        		sHH_PREF VARCHAR2(100);
      		begin
                sHH_PREF := D_PKG_HOSP_HISTORIES.GET_HH_PREF(pnLPU     => :pnLPU,
                                                             psDP_CODE => :psHH_PREF,
                                                             pdDATE    => sysdate);

        		for rHH in (select t.*
        		              from D_V_HOSP_HISTORIES t
        		             where t.ID = :pnID) loop
            		D_PKG_HOSP_HISTORIES.UPD(pnID                   => rHH.ID,
                                             pnLPU                  => :pnLPU,
                                             pnHPK_PLAN_JOURNAL     => rHH.HPK_PLAN_JOURNAL,
                                             pnPATIENT              => rHH.PATIENT_ID,
                                             psHH_PREF              => sHH_PREF,
                                             psHH_NUMB              => :psHH_NUMB,
                                             psHH_NUMB_ALTERN       => :psHH_NUMB_ALTERN,
                                             pnHOSP_REASON          => rHH.HOSP_REASON_ID,
                                             pnRECEPTION_EMP        => rHH.RECEPTION_EMP,
                                             pdDATE_IN              => rHH.DATE_IN,
                                             pdPLAN_DATE_OUT        => rHH.PLAN_DATE_OUT,
                                             pdDATE_OUT             => rHH.DATE_OUT,
                                             pnHOSPITALIZATION_TYPE => rHH.HOSPITALIZATION_TYPE_ID,
                                             pntRANSPORTATION_KIND  => rHH.TRANSPORTATION_KIND_ID,
                                             pnLPU_FROM             => rHH.LPU_FROM_ID,
                                             pnMKB_SEND             => rHH.MKB_SEND_ID,
                                             psMKB_SEND_EXACT       => rHH.MKB_SEND_EXACT,
                                             pnMKB_CLINIC           => rHH.MKB_CLINIC_ID,
                                             psMKB_CLINIC_EXACT     => rHH.MKB_CLINIC_EXACT,
                                             pdMKB_CLINIC_DATE      => rHH.MKB_CLINIC_DATE,
                                             pnMKB_FINAL            => rHH.MKB_FINAL_ID,
                                             psMKB_FINAL_EXACT      => rHH.MKB_FINAL_EXACT,
                                             pnMKB_FIN_COMP         => rHH.MKB_FIN_COMP_ID,
                                             psMKB_FIN_COMP_EXACT   => rHH.MKB_FIN_COMP_EXACT,
                                             pnMKB_FIN_ADD          => rHH.MKB_FIN_ADD_ID,
                                             psMKB_FIN_ADD_EXACT    => rHH.MKB_FIN_ADD_EXACT,
                                             pnHOSP_TIMES           => rHH.HOSP_TIMES,
                                             pnHOSP_RESULT          => rHH.HOSP_RESULT_ID,
                                             pnMKB_RECEIVE          => rHH.MKB_RECEIVE_ID,
                                             psMKB_RECEIVE_EXACT    => rHH.MKB_RECEIVE_EXACT,
                                             pnRELATIVE             => rHH.RELATIVE_ID,
                                             pnDISCARD_STATUS       => rHH.DISCARD_STATUS,
                                             pnIS_WELL_TIMED_HOSP   => rHH.IS_WELL_TIMED_HOSP,
                                             pnIS_ENOUGH_VOLUME     => rHH.IS_ENOUGH_VOLUME,
                                             pnIS_CORRECT_HEALING   => rHH.IS_CORRECT_HEALING,
                                             pnIS_SAME_DIAGN        => rHH.IS_SAME_DIAGN,
                                             pnHOSP_HOUR            => rHH.HOSP_HOUR_ID,
                                             pnHOSP_OUTCOME         => rHH.HOSP_OUTCOME_ID,
                                             psOTHER_THERAPY        => rHH.OTHER_THERAPY,
                                             pnABILITY_STATUS       => rHH.ABILITY_STATUS_ID,
                                             psFEATURES             => rHH.FEATURES,
                                             pdDATE_DEPARTURE       => to_date(:DATE_DEPARTURE||:TIME_DEPARTURE, D_PKG_STD.FRM_DT),
                                             pnRELATIVE_HH          => rHH.RELATIVE_HH,
                                             pnABANDONMENT          => rHH.ABANDONMENT,
                                             pnDEATH_CAME           => rHH.DEATH_CAME_ID,
									         pnNOVOR_NUM			=> rHH.NOVOR_NUM);
					if nvl(:HH_TYPE,-1) != nvl(rHH.HH_TYPE,-1) then
	    				if D_PKG_URPRIVS.CHECK_BPPRIV(:pnLPU, 'HOSP_HISTORIES_UPD_HOSP', null, 0) = 0 then
							select count(1)
							  into nCOUNT
							  from D_V_HOSP_HISTORY_DEPS t
							 where t.PID = rHH.ID;
							if nCOUNT > 1 then
		    					D_P_EXC('Нет прав на изменение типа истории болезни, если у пациента были перемещения по отделениям.');
							end if;
	    				end if;
	    				d_pkg_hosp_histories.set_hh_type(rHH.ID,:pnLPU,:HH_TYPE);
					end if;
        		end loop;
      		end;
    	]]>
      	<component cmptype="ActionVar" name="pnLPU"             src="LPU"              srctype="session"/>
      	<component cmptype="ActionVar" name="pnID"              src="_HH_ID"           srctype="var"    get="vHH_ID"/>
      	<component cmptype="ActionVar" name="psHH_PREF"         src="_HH_PREF"         srctype="var"    get="vHH_PREF"/>
      	<component cmptype="ActionVar" name="psHH_NUMB"         src="_HH_NUMB"         srctype="var"    get="vHH_NUMB"/>
      	<component cmptype="ActionVar" name="psHH_NUMB_ALTERN"  src="_HH_NUMB_ALTERN"  srctype="var"    get="vHH_NUMB_ALTERN"/>
      	<component cmptype="ActionVar" name="HH_TYPE"           src="HH_TYPE"          srctype="ctrl"   get="HH_TYPE"/>
      	<component cmptype="ActionVar" name="DATE_DEPARTURE"    src="DATE_DEPARTURE"   srctype="ctrl"   get="DATE_DEPARTURE"/>
      	<component cmptype="ActionVar" name="TIME_DEPARTURE"    src="TIME_DEPARTURE"   srctype="ctrl"   get="TIME_DEPARTURE"/>
  	</component>
	<component cmptype="Action" name="initAction" mode="post">
		<![CDATA[
		declare nlast_dis       NUMBER(17);
				nlast_dis_type  NUMBER(1);
				nlast_visit     NUMBER(17);
				nlast_mkb_id    NUMBER(17);
				nHH_DEP         NUMBER(17);
				nlast_mkb       VARCHAR2(40);
				nPATIENT_AGENT  NUMBER(17);
				nOPT_LPU_HID 	NUMBER(17);
				nCNT_MENTAL 	NUMBER(17);
				nNOVOR_NUM		NUMBER(1);
				nDIRECTION_TRANSPORTATION_KIND		NUMBER(17);
				nDIRECTION_HOSP_HOUR		NUMBER(17);
				dBIRTHDATE 		DATE;
		begin
			begin
				select to_char(sysdate,'dd.mm.yyyy'),
					   to_char(sysdate,'HH24:MI')
				  into :DATE,
					   :HOURS
				  from dual;
			end;
			:HH_TYPE := d_pkg_option_specs.get('HH_PREGNANCY', :LPU);
			:SPEC_LPU_TYPE := d_pkg_option_specs.get('SpecLpuType', :LPU);

			if :SPEC_LPU_TYPE = 1 then
				:HH_TYPE := 4;
			else
				if (:HH_TYPE =0) then
					:HH_TYPE := null;
				end if;
			end if;
			begin
			  select e.id,
					 d_pkg_str_tools.fio(e.SURNAME, e.FIRSTNAME, e.LASTNAME) RECEPTION_EMP_FIO
				into :RECEPTION_EMP,
					 :RECEPTION_EMP_FIO
				from d_v_employers e
			   where e.id = :EMPLOYER
				 and e.STAFF_LEVEL in (1, 2);
			exception when no_data_found then null;
			end;
			select t.hpk_plan,
				   t.directed_by_id,
				   t.directed_to_id,
				   t.registered_by_id,
				   to_char(t.register_date,'dd.mm.yyyy hh24:mi') register_date,
				   t.has_privileges,
				   t.operation_id,
				   t.PAYMENT_KIND_ID,
				   t.DIRECTION,
				   t.IS_READY,
				   t.HH_DIRECTION_DATE,
				   t.IS_OPER,
				   t.Comments,
				   t2.PLAN_DATE,
				   nvl(odir.DIAGNOSIS_ID,dir.HOSP_MKB_ID),
				   nvl(odir.DIAGNOSIS,dir.HOSP_MKB),
				   dir.HOSP_MKB_ID,
				   dir.HOSP_MKB,
				   dir.HOSP_BED_TYPE_ID,
				   t.DISEASECASE,
				   (select tt.ID from D_V_HOSP_HISTORIES tt where tt.HPK_PLAN_JOURNAL = t.ID),
				   t.HPK,
				   t.RECORD_NUMB,
				   t.RECORD_PREF,
				   dir.HOSP_REASON_ID,
				   dir.HOSP_REASON||' '||dir.HOSP_REASON_NAME,
				   t.PATIENT_AGENT,
				   coalesce(t.HOSP_HISTORY_HOSP_TYPE,dir.HOSP_TYPE_ID),
				   dir.TRANSPORTATION_KIND_ID,
				   dir.HOSP_HOUR,
				   coalesce(dir.HOSP_MKB_EXACT,'')
			  into :J_HPK_PLAN,
				   :J_DIRECTED_BY,
				   :J_DIRECTED_TO,
				   :J_REGISTERED_BY,
				   :J_REGISTER_DATE,
				   :J_HAS_PRIVILEGES,
				   :J_OPERATION,
				   :J_PAYMENT_KIND,
				   :J_DIRECTION,
				   :J_IS_READY,
				   :HH_DIRECTION_DATE,
				   :J_IS_OPER,
				   :COMMENTS,
				   :PLAN_DATE,
				   :MKB_SEND_ID,
				   :MKB_SEND,
				   :MKB_RECEIVE_ID,
				   :MKB_RECEIVE,
				   :HOSP_BED_TYPE_ID,
				   :DISEASECASE,
				   :HH_ID,
				   :J_HPK,
				   :J_RECORD_NUMB,
				   :J_RECORD_PREF,
				   :HOSP_REASON_ID,
				   :REASON_NAME,
				   nPATIENT_AGENT,
				   :HOSPITALIZATION_TYPE,
				   nDIRECTION_TRANSPORTATION_KIND,
				   nDIRECTION_HOSP_HOUR,
				   :HOSP_MKB_EXACT
			  from d_v_hpk_plan_journals t
				   left join D_V_HPK_PLANS t2 on t2.ID = t.HPK_PLAN
				   join D_V_DIRECTIONS dir on dir.ID = t.DIRECTION
				   left join D_V_OUTER_DIRECTIONS odir on odir.ID = dir.OUTER_DIRECTION_ID
			 where t.id = :HPKJ_ID;

			begin
				if :MKB_RECEIVE_ID is null then
					case d_pkg_options.get('HHDiagnInheritType',:LPU)
						when 0 then null;
						when 1 then
							select nvl(t.MKB_FINAL_ID,nvl(t.MKB_CLINIC_ID,t.MKB_RECEIVE_ID)),
								   nvl(t.MKB_FINAL,nvl(t.MKB_CLINIC,t.MKB_RECEIVE))
							  into :MKB_RECEIVE_ID,
								   :MKB_RECEIVE
							  from D_V_HOSP_HISTORIES t
							 where t.LPU = :LPU
							   and t.PATIENT_ID = :PATIENT_ID
							   and t.DATE_IN = (select max(DATE_IN)
												  from D_V_HOSP_HISTORIES
												 where LPU = :LPU
												   and PATIENT_ID = :PATIENT_ID);
						when 2 then
							select ID,
								   DC_TYPE,
								   VISIT,
								   MKB_ID,
								   MKB_CODE
							  into nlast_dis,
								   nlast_dis_type,
								   nlast_visit,
								   nlast_mkb_id,
								   nlast_mkb
							  from D_V_DISEASECASES
							 where LPU = :LPU
							   and PATIENT_ID = :PATIENT_ID
							   and DC_OPENDATE = (select max(DC_OPENDATE)
													from D_V_DISEASECASES
												   where LPU = :LPU
													 and PATIENT_ID = :PATIENT_ID
												  )
							   and rownum = 1
							   and MKB_ID is not null;

							if nlast_dis_type = 3 then

								select nvl(t.MKB_FINAL_ID,nvl(t.MKB_CLINIC_ID,t.MKB_RECEIVE_ID)),
									   nvl(t.MKB_FINAL,nvl(t.MKB_CLINIC,t.MKB_RECEIVE))
								  into :MKB_RECEIVE_ID,
									   :MKB_RECEIVE
								  from D_V_HOSP_HISTORIES t
								 where t.LPU = :LPU
								   and t.PATIENT_ID = :PATIENT_ID
								   and t.DISEASECASE = nlast_dis;

							elsif nlast_visit is not null then

								select t.MKB_ID,
									   t.MKB_CODE
								  into :MKB_RECEIVE_ID,
									   :MKB_RECEIVE
								  from d_v_vis_diagnosises_main t
								 where t.PID = nlast_visit;
							else
								:MKB_RECEIVE_ID := nlast_mkb_id;
								:MKB_RECEIVE := nlast_mkb;
							end if;
						else null;
					end case;
				end if;
				exception when others then null;
			end;

			select case when :COUNT_CUR_HOSP = 1 then count(id) + 1
                        else count(id)
                   end
			  into :HOSP_TIMES
			  from d_v_hosp_histories
			 where MKB_SEND_ID = :MKB_SEND_ID
				   and PATIENT_ID = :PATIENT_ID
				   and LPU = :LPU;

			:RELATIVE_HH_ID:=null;
			:RELATIVE_AGENT_ID:=null;

			if :HH_ID is not null then
				begin
					select to_char(t.DATE_IN, 'dd.mm.yyyy'),
						   to_char(t.DATE_IN,'hh24:mi'),
						   case when D_PKG_OPTIONS.GET('HHNumerationPrefDefault', :LPU) = 'dep' then t.HH_PREF end HH_PREF,
						   t.HH_NUMB,
						   t.HH_NUMB_ALTERN,
						   t.PLAN_DATE_OUT,
						   t.TRANSPORTATION_KIND_ID,
						   t.LPU_FROM_ID,
						   t.LPU_FROM,
						   t.HOSP_TIMES,
						   t.RELATIVE_ID,
						   t.RELATIVE,
						   t.MKB_SEND_ID,
						   t.MKB_SEND,
						   t.MKB_CLINIC_ID,
						   t.MKB_CLINIC,
						   t.MKB_CLINIC_EXACT,
						   t.MKB_CLINIC_DATE,
						   t.MKB_FINAL_ID,
						   t.MKB_FINAL,
						   t.MKB_FINAL_EXACT,
						   t.MKB_FIN_COMP_ID,
						   t.MKB_FIN_COMP,
						   t.MKB_FIN_COMP_EXACT,
						   t.MKB_FIN_ADD_ID,
						   t.MKB_FIN_ADD,
						   t.MKB_FIN_ADD_EXACT,
						   t.MKB_RECEIVE_ID,
						   t.MKB_RECEIVE,
						   t.HH_TYPE,
						   t.HOSP_HOUR_ID,
						   t.HOSP_REASON_ID,
						   t.HOSP_REASON||' '||t.HOSP_REASON_NAME,
						   t.RECEPTION_EMP,
						   d_pkg_str_tools.fio(t1.SURNAME, t1.FIRSTNAME, t1.LASTNAME) RECEPTION_EMP_FIO,
						   t.HH_NUMB_MASK,
						   coalesce(to_char(t.DATE_DEPARTURE, D_PKG_STD.FRM_D), to_char(t.DATE_IN, D_PKG_STD.FRM_D)),
						   coalesce(to_char(t.DATE_DEPARTURE, D_PKG_STD.FRM_T), to_char(sysdate, D_PKG_STD.FRM_T)),
						   t.ARRIVE_ORDER,
						   t.JUDGE_DECISION,
						   t.HOSP_INCOME_ID,
						   t.INCOME_NAME,
						   t.HOSP_IS_FIRST,
						   t.NOVOR_NUM
					  into :DATE,
						   :HOURS,
						   :HH_PREF,
						   :HH_NUMB,
						   :ALT_NUMB, --общебольничный номер
						   :PLAN_DATE_OUT,
						   :TRANSPORTATION_KIND,
						   :LPU_FROM_ID,
						   :LPU_FROM,
						   :HOSP_TIMES,
						   :RELATIVE_ID,
						   :RELATIVE,
						   :MKB_SEND_ID,
						   :MKB_SEND,
						   :MKB_CLINIC_ID,
						   :MKB_CLINIC,
						   :MKB_CLINIC_EXACT,
						   :MKB_CLINIC_DATE,
						   :MKB_FINAL_ID,
						   :MKB_FINAL,
						   :MKB_FINAL_EXACT,
						   :MKB_FIN_COMP_ID,
						   :MKB_FIN_COMP,
						   :MKB_FIN_COMP_EXACT,
						   :MKB_FIN_ADD_ID,
						   :MKB_FIN_ADD,
						   :MKB_FIN_ADD_EXACT,
						   :MKB_RECEIVE_ID,
						   :MKB_RECEIVE,
						   :HH_TYPE,
						   :HOSP_HOUR_ID,
						   :HOSP_REASON_ID,
						   :REASON_NAME,
						   :RECEPTION_EMP,
						   :RECEPTION_EMP_FIO,
						   :HH_NUMB_MASK,
						   :DATE_DEPARTURE,
						   :TIME_DEPARTURE,
						   :ARRIVE_ORDER,
						   :JUDGE_DECISION,
						   :HOSP_INCOME_ID,
						   :HOSP_INCOME,
						   :HOSP_IS_FIRST,
						   :NOVOR_NUM
					  from D_V_HOSP_HISTORIES t
						   left join D_V_EMPLOYERS t1 on t1.ID = t.RECEPTION_EMP
					 where t.HPK_PLAN_JOURNAL = :HPKJ_ID;
				end;

				begin
				  select t.DEP_ID,
						 t.PAYMENT_KIND_ID,
						 t.ID
					into :DEP_ID,
						 :PAYMENT,
						 nHH_DEP
					from D_V_HOSP_HISTORY_DEPS t
				   where t.pid = :HH_ID
					 and t.PRVSID is null;
					exception when others then null;
				end;
				if nHH_DEP is not null then
					begin
						select t.CHAMBER_ID,
							   t.CHAMBER_CODE
						  into :DEP_BED_ID,
							   :DEP_BED
						  from D_V_HH_DEP_BEDS t
						 where pid = nHH_DEP;
						exception when others then null;
					end;
				end if;

				select decode(count(hhd.id),1,0,count(hhd.id))
				  into :DISABLE_ALL
				  from d_v_hosp_history_deps hhd
				 where hhd.pid = :HH_ID;

				if :DISABLE_ALL = 0 then
					begin
						select date_out
						  into :DISABLE_ALL
						  from d_v_hosp_histories
						 where id = :HH_ID;
						exception when others then null;
					end;
				end if;

				BEGIN
					select trunc((to_date(:DATE,'dd.mm.yyyy') - t.BEGIN_DATE)/7)
					  into :TERM
					  from d_v_agent_pregnancy t
						   join d_v_diseasecases t2 on t2.AGENT_PREGNANCY = t.ID
				 	 where t2.ID = :DISEASECASE;
					EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
				END;

				:HH_PREF_VAR:=:HH_PREF;
				if :DEP_ID is not null then
					begin
						select t.ID,
							   t.DEP
						  into :HH_PREF_ID,
							   :HH_PREF
						  from D_V_HOSP_PLAN_DEPS t
						 where t.DEP_ID=:DEP_ID
						   and t.HP_KIND_ID = :HOSP_PLAN_KIND;
						EXCEPTION when NO_DATA_FOUND then null;
							      when TOO_MANY_ROWS then null;
					end;
				end if;

				if :RELATIVE_ID is not null then
					begin
						select h.ID,
						       h.PATIENT_AGENT
						  into :RELATIVE_HH_ID,
						       :RELATIVE_AGENT_ID
						  from D_V_HOSP_HISTORIES_RELATIVE h
							   join D_V_AGENT_RELATIVES ar on ar.AGENT_ID = h.PATIENT_AGENT
						 where h.RELATIVE_HH=:HH_ID
						   and ar.id=:RELATIVE_ID
						   and (h.DATE_OUT is null or h.DATE_OUT=(select max(h1.DATE_OUT)
																	from D_V_HOSP_HISTORIES_RELATIVE h1
																   where h1.RELATIVE_HH=:HH_ID ));
						exception when NO_DATA_FOUND then
						 	:RELATIVE_HH_ID:=null;
							select ar.AGENT_ID
							  into :RELATIVE_AGENT_ID
							  from D_V_AGENT_RELATIVES ar
							 where ar.id= :RELATIVE_ID;
					end;
				end if;
			else
				:PAYMENT := :J_PAYMENT_KIND;
				DECLARE MAXDATE   D_V_OUTER_DIRECTIONS.D_DATE%TYPE;
						CURDATE   D_V_OUTER_DIRECTIONS.D_DATE%TYPE;
						RVISIT    NUMBER(17);
						nRVISIT   NUMBER(17);
						LPUAGENT  NUMBER(17);
						DIRKIND   NUMBER(17);
						nLPUAGENT NUMBER(17);
						nDIRKIND  NUMBER(17);
				BEGIN
				  	RVISIT := NULL;

				  	select t.REG_VISIT_ID,
						   t2.REPRESENT_ID,
						   t.DIRECTION_KIND_ID,
						   t2.D_DATE,
						   t.HOSP_DEP
				  	  INTO RVISIT,
						   LPUAGENT,
						   DIRKIND,
						   MAXDATE,
						   :HH_PREF
					  FROM D_V_DIRECTIONS t
						   left join D_V_OUTER_DIRECTIONS t2 on t2.ID = t.OUTER_DIRECTION_ID
						   join D_V_HPK_PLAN_JOURNALS t3
							 on t3.DIRECTION = t.ID
						        and t3.ID = :HPKJ_ID;
				  	WHILE RVISIT IS NOT NULL LOOP
					   	SELECT t.REG_VISIT_ID,
							   t2.REPRESENT_ID,
							   t.DIRECTION_KIND_ID,
							   t2.D_DATE
						  INTO nRVISIT,
							   nLPUAGENT,
							   nDIRKIND,
							   CURDATE
						  FROM D_V_DIRECTIONS t
							   left join D_V_OUTER_DIRECTIONS t2 on t2.ID = t.OUTER_DIRECTION_ID
							   join D_V_DIRECTION_SERVICES ds on ds.PID  =t.ID
							   join D_V_VISITS v
							  	 on v.PID = ds.ID
								    and v.ID = RVISIT;
					   	IF CURDATE >= MAXDATE OR MAXDATE IS NULL THEN
							LPUAGENT := nvl(nLPUAGENT,LPUAGENT);
							DIRKIND  := nvl(nDIRKIND,DIRKIND);
							MAXDATE := CURDATE;
					   	END IF;
					   	RVISIT := nRVISIT;
				   	END LOOP;

				   	IF LPUAGENT IS NOT NULL THEN
						begin
						   SELECT t.ID,
								  t.LPU_CODE
							 INTO :LPU_FROM_ID,
								  :LPU_FROM
							 FROM D_V_LPUDICT t
							WHERE t.AGENT = LPUAGENT
							  AND t.VERSION = d_pkg_versions.get_version_by_lpu(0,:LPU,'LPUDICT');
				   			exception when NO_DATA_FOUND then null;
						end;
				   	END IF;
				   	:DIRKIND := DIRKIND;
				END;
				if :LPU_FROM_ID is null then
					begin
						select t.HID,
							   t.ID,
							   t.LPU_CODE
						  into nOPT_LPU_HID,
							   :LPU_FROM_ID,
							   :LPU_FROM
						  from D_V_LPUDICT t
						 where t.LPU_CODE = D_PKG_OPTIONS.GET('HHLPUDICT', :LPU)
						   and t.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'LPUDICT');
						exception when others then null;
					end;

					if nOPT_LPU_HID is not null then
						begin
							select t.ID,
								   t.LPU_CODE
							  into :LPU_FROM_ID,
								   :LPU_FROM
							  from D_V_LPUDICT t
							 where t.ID = nOPT_LPU_HID;
							exception when others then null;
						end;
					end if;
				end if;
				if :HH_PREF is not null then
					:HH_NUMB := d_pkg_hosp_histories.get_new_numb(:LPU,:HH_PREF,0,:HOSP_PLAN_KIND);
					:ALT_NUMB := d_pkg_hosp_histories.get_new_numb(:LPU,:HH_PREF,1,:HOSP_PLAN_KIND);
					if length(:ALT_NUMB) < 5 then
						:ALT_NUMB := lpad(:ALT_NUMB,5,'0');
					end if;
				else
					begin
					  	select hpd.DEP,
							   hpd.ID
					  	  into :HH_PREF,
							   :HH_PREF_ID
						  from d_v_hosp_plan_deps  hpd
							   join d_v_hosp_plan_kinds hpk on hpk.ID = hpd.HP_KIND_ID
							   join d_v_hpk_plans hpk_p on hpk_p.PID = hpk.ID
					     where hpk_p.id  =  :J_HPK_PLAN;
						exception when others then null;
					end;
					if :HH_PREF is not null then
						:HH_NUMB := d_pkg_hosp_histories.get_new_numb(:LPU,:HH_PREF,0,:HOSP_PLAN_KIND);
						:ALT_NUMB := d_pkg_hosp_histories.get_new_numb(:LPU,:HH_PREF,1,:HOSP_PLAN_KIND);
						if length(:ALT_NUMB) < 5 then
							:ALT_NUMB := lpad(:ALT_NUMB,5,'0');
						end if;
					end if;
				end if;
				:HH_PREF_VAR:=:HH_PREF;
			end if;
			--170316
			select p.PMC_TYPE,
				   p.nSEX
		  	  into :PMC_TYPE,
				   :NSEX
			  from d_v_persmedcard p
			 where p.ID = :PATIENT_ID;
			if :PMC_TYPE = 2 then
				if :NOVOR_NUM is null then
					:NOVOR_NUM := 1;
					select trunc(pmc.BIRTHDATE)
					  into dBIRTHDATE
				  	  from d_v_persmedcard pmc
					 where pmc.ID = :PATIENT_ID;

					for parID in (select ar.agent_id,
					                     ar.relation
									from d_v_agent_relatives ar
									     join d_v_persmedcard pmc on ar.PID = pmc.AGENT
									where pmc.id=:PATIENT_ID
								  ) loop
						select count(hh.ID)+1
						  into nNOVOR_NUM
					  	  from d_v_hosp_histories hh
							   join d_v_persmedcard pmc on hh.PATIENT_ID = pmc.ID
							   join d_v_agent_relatives ar on ar.PID = pmc.AGENT
						 where ar.AGENT_ID = parID.agent_id
					  	   and ar.relation = parID.relation
						   and hh.PATIENT_ID <> :PATIENT_ID
					  	   and trunc(pmc.BIRTHDATE) = dBIRTHDATE
						   and hh.LPU = :LPU
						   and trunc(hh.DATE_IN) = trunc(SYSDATE);

						if nNOVOR_NUM > :NOVOR_NUM then
							:NOVOR_NUM := nNOVOR_NUM;
						end if;
					end loop;
			 	end if;
			end if;

			if :TERM is null then
				begin
					select trunc((to_date(:DATE,'dd.mm.yyyy') - t.BEGIN_DATE)/7)
					  into :TERM
					  from D_V_AGENT_PREGNANCY t
					 where t.PID = nPATIENT_AGENT
					   and t.END_DATE is null;
					exception when no_data_found then null;
				end;
			end if;

			if :HH_PREF_ID is null then
		 		begin
					select t.ID
					  into :HH_PREF_ID
					  from D_V_HOSP_PLAN_DEPS t
					 where t.LPU=:LPU
					   and t.DEP=:HH_PREF
					   and t.HP_KIND_ID = :HOSP_PLAN_KIND;
					exception when others then null;
			 	end;
			end if;
			begin
				select IS_COMMERC
				  into :J_PAYMENT_KIND_IS_COMMERC
				  from D_V_PAYMENT_KIND
				 where id=:PAYMENT;
				exception when no_data_found then
					:J_PAYMENT_KIND_IS_COMMERC := null;
			end;
			select decode(d_pkg_persmedcard.check_for_oms(pnID => :PATIENT_ID,
			                                            pnTYPE => 1),null,null,
				  			'Не заполнены или заполнены некорректно следующие данные :'||d_pkg_persmedcard.check_for_oms(pnID => :PATIENT_ID,
				  			                                                                                           pnTYPE => 1))
			  into :ERRORS_PMC
			  from dual;
			--берем из опций дефолтные значения
			if :HOSP_REASON_ID is null then
				begin
					select t.ID
					  into :DEF_HOSP_REASON_ID
					  from D_V_HOSP_REASONS t
					 where t.HR_CODE = D_PKG_OPTIONS.GET('HH_HOSP_REASON_DEFAULT',:LPU)
					   and t.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(1,:LPU,'HOSP_REASONS');
					exception when NO_DATA_FOUND then
						:DEF_HOSP_REASON_ID := null;
				end;
			end if;
			begin
				select t.ID
				  into :DEF_HOSP_TYPE_ID
				  from D_V_HOSPITALIZATION_TYPES t
				 where t.HK_CODE = D_PKG_OPTIONS.GET('HH_HOSP_TYPE_DEFAULT',:LPU)
				   and t.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(1,:LPU,'HOSPITALIZATION_TYPES');
				exception when NO_DATA_FOUND then
					:DEF_HOSP_TYPE_ID := null;
			end;

			if nDIRECTION_TRANSPORTATION_KIND is not NULL then
				:DEF_TRANSP_TYPE_ID := nDIRECTION_TRANSPORTATION_KIND;
			else
			  	begin
					select t.ID
				  	  into :DEF_TRANSP_TYPE_ID
				      from D_V_TRANSPORTATION_KINDS t
				     where t.TK_CODE = D_PKG_OPTIONS.GET('HH_TRANSP_TYPE_DEFAULT',:LPU)
				       and t.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0,:LPU,'TRANSPORTATION_KINDS');
				  	exception when NO_DATA_FOUND then
						:DEF_TRANSP_TYPE_ID := null;
			  	end;
			end if;

			if nDIRECTION_HOSP_HOUR is not NULL then
				:HOSP_HOUR_ID := nDIRECTION_HOSP_HOUR;
			end if;

			:HHNumerationMask := D_PKG_OPTIONS.GET('HHNumerationMask', :LPU);

			begin
				:CHILD_AGE := D_PKG_OPTIONS.GET('HpkAgeChildForReq', :LPU);
				select D_PKG_DAT_TOOLS.FULL_YEARS(fdDATE_TO => sysdate,
				                                fdDATE_FROM => p.BIRTHDATE)
				  into :PAT_YEAR
				  from D_V_PERSMEDCARD p
				 where p.ID = :PATIENT_ID;
			end;

			-- Проверка прав на редактирование номера ИБ
			:IS_HH_UPD_HOSP := D_PKG_URPRIVS.CHECK_BPPRIV(:LPU,'HOSP_HISTORIES_UPD_HOSP',null,0);
			:CHECK_FOR_OMS := D_PKG_OPTION_SPECS.GET('CheckForOMS', :LPU);
			:PKOMS_OPT := D_PKG_OPTION_SPECS.GET('PKOMS', :LPU);

			begin
				select t.PK_CODE
				  into :PK_CODE
				  from D_V_PAYMENT_KIND t
				 where t.ID = :PAYMENT;
				exception when no_data_found then
					:PK_CODE := null;
			end;

			if :HH_ID is null then
				if :HH_TYPE = 4 and :ARRIVE_ORDER is null then
					select count(1)
					  into nCNT_MENTAL
					  from D_V_HOSP_HISTORIES hh
					 where hh.PATIENT_AGENT = nPATIENT_AGENT
					   and extract (year from hh.DATE_IN) = extract (year from sysdate)
					   and hh.HH_TYPE = 4
					   and rownum = 1;

					if nCNT_MENTAL = 0 then
						select count(1)
						  into nCNT_MENTAL
						  from D_V_HOSP_HISTORIES hh
						 where hh.PATIENT_AGENT = nPATIENT_AGENT
						   and extract (year from hh.DATE_IN) != extract (year from sysdate)
						   and hh.HH_TYPE = 4
						   and rownum = 1;

						   if nCNT_MENTAL = 0 then
								:HOSP_IS_FIRST := 0;
						   else
								:HOSP_IS_FIRST := 1;
						   end if;
					else
						:HOSP_IS_FIRST := 2;
					end if;
				end if;
			end if;

			:HospDateRestriction := D_PKG_OPTION_SPECS.GET('HospDateRestriction', :LPU);
		end;
		]]>
		<component cmptype="ActionVar" name="LPU"                       src="LPU"                       srctype="session"/>
		<component cmptype="ActionVar" name="HPKJ_ID"                   src="HPK_PLAN_JOURNAL_ID"       srctype="var"         get="v1"/>
		<component cmptype="ActionVar" name="PATIENT_ID"                src="PMC_ID"                    srctype="var"         get="v2"/>
		<component cmptype="ActionVar" name="DATE"                      src="HOSPIT_DATE"               srctype="ctrl"        put="t1"               len="10"/>
		<component cmptype="ActionVar" name="HOURS"                     src="HOSPIT_HOURS"              srctype="ctrl"        put="t2"               len="10"/>
		<component cmptype="ActionVar" name="J_HPK_PLAN"                src="J_HPK_PLAN"                srctype="var"         put="v3"               len="17"/>
		<component cmptype="ActionVar" name="J_DIRECTED_BY"             src="J_DIRECTED_BY"             srctype="var"         put="v4"               len="17"/>
		<component cmptype="ActionVar" name="J_DIRECTED_TO"             src="J_DIRECTED_TO"             srctype="var"         put="v5"               len="17"/>
		<component cmptype="ActionVar" name="J_REGISTERED_BY"           src="J_REGISTERED_BY"           srctype="var"         put="v6"               len="17"/>
		<component cmptype="ActionVar" name="J_REGISTER_DATE"           src="J_REGISTER_DATE"           srctype="var"         put="v7"               len="25"/>
		<component cmptype="ActionVar" name="J_HAS_PRIVILEGES"          src="J_HAS_PRIVILEGES"          srctype="var"         put="v8"               len="1"/>
		<component cmptype="ActionVar" name="J_OPERATION"               src="J_OPERATION"               srctype="var"         put="v9"               len="17"/>
		<component cmptype="ActionVar" name="J_PAYMENT_KIND"            src="J_PAYMENT_KIND"            srctype="var"         put="v10"              len="17"/>
		<component cmptype="ActionVar" name="J_DIRECTION"               src="J_DIRECTION"               srctype="var"         put="v11"              len="17"/>
		<component cmptype="ActionVar" name="J_IS_READY"                src="J_IS_READY"                srctype="var"         put="v12"              len="1"/>
		<component cmptype="ActionVar" name="HH_DIRECTION_DATE"	        src="HH_DIRECTION_DATE"         srctype="var"         put="v13"              len="25"/>
		<component cmptype="ActionVar" name="J_IS_OPER"                 src="J_IS_OPER"                 srctype="var"         put="v14"              len="1"/>
		<component cmptype="ActionVar" name="J_RECORD_NUMB"             src="J_RECORD_NUMB"             srctype="var"         put="j15"              len="6"/>
		<component cmptype="ActionVar" name="J_RECORD_PREF"             src="J_RECORD_PREF"             srctype="var"         put="j16"              len="6"/>
		<component cmptype="ActionVar" name="COMMENTS"                  src="COMMENT"                   srctype="ctrl"        put="v15"              len="4000"/>
		<component cmptype="ActionVar" name="PLAN_DATE"                 src="PLAN_DATE"                 srctype="var"         put="v16"              len="25"/>
		<component cmptype="ActionVar" name="MKB_SEND_ID"               src="MKB_SEND"                  srctype="ctrl"        put="v17"              len="17"/>
		<component cmptype="ActionVar" name="MKB_SEND"                  src="MKB_SEND"                  srctype="ctrlcaption" put="v18"              len="40"/>
		<component cmptype="ActionVar" name="MKB_RECEIVE_ID"            src="MKB10"                     srctype="ctrl"        put="v19"              len="17"/>
		<component cmptype="ActionVar" name="MKB_RECEIVE"               src="MKB10"                     srctype="ctrlcaption" put="v20"              len="40"/>
		<component cmptype="ActionVar" name="DISEASECASE"               src="DISEASECASE"               srctype="var"         put="v22"              len="17"/>
		<component cmptype="ActionVar" name="HOSP_TIMES"                src="HOSP_TIMES"                srctype="ctrl"        put="v23"              len="5"/>
		<component cmptype="ActionVar" name="HH_ID"                     src="HH_ID"                     srctype="var"         put="v24"              len="17"/>
		<component cmptype="ActionVar" name="HH_PREF_ID"                src="HOSP_PLAN_DEPS"            srctype="ctrl"        put="v25"              len="30"/>
		<component cmptype="ActionVar" name="HH_PREF_VAR"               src="HOSP_PLAN_DEPS"            srctype="var"         put="v25v"             len="30"/>
		<component cmptype="ActionVar" name="HH_PREF"                   src="HOSP_PLAN_DEPS"            srctype="ctrlcaption" put="v26"              len="30"/>
		<component cmptype="ActionVar" name="HH_NUMB"                   src="HHnumber"                  srctype="ctrl"        put="v27"              len="30"/>
		<component cmptype="ActionVar" name="ALT_NUMB"                  src="FullNumber"                srctype="ctrl"        put="v28"              len="30"/>
		<component cmptype="ActionVar" name="HOSP_REASON_ID"            src="HOSP_REASONS"              srctype="ctrl"        put="v29"              len="17"/>
		<component cmptype="ActionVar" name="HOSP_REASON_ID"            src="HOSP_REASONS"              srctype="var"         put="v29_1"            len="17"/>
		<component cmptype="ActionVar" name="REASON_NAME"               src="REASON_NAME"               srctype="var"         put="v29_2"            len="100"/>
		<component cmptype="ActionVar" name="PLAN_DATE_OUT"	            src="PLAN_DATE_OUT"             srctype="ctrl"        put="v30"              len="25"/>
		<component cmptype="ActionVar" name="HOSPITALIZATION_TYPE"      src="HOSP_TYPE"                 srctype="ctrl"        put="v31"              len="17"/>
		<component cmptype="ActionVar" name="TRANSPORTATION_KIND"       src="TRANSP"                    srctype="ctrl"        put="v32"              len="17"/>
		<component cmptype="ActionVar" name="LPU_FROM_ID"               src="LPUDICT"                   srctype="ctrl"        put="v33"              len="17"/>
		<component cmptype="ActionVar" name="LPU_FROM"                  src="LPUDICT"                   srctype="ctrlcaption" put="v34"              len="20"/>
		<component cmptype="ActionVar" name="RELATIVE_ID"               src="AGENT_RELATIVES"           srctype="ctrl"        put="v35"              len="17"/>
		<component cmptype="ActionVar" name="RELATIVE"                  src="AGENT_RELATIVES"           srctype="ctrlcaption" put="v36"              len="150"/>
		<component cmptype="ActionVar" name="MKB_CLINIC_ID"             src="MKB_CLINIC_ID"             srctype="var"         put="v38"              len="17"/>
		<component cmptype="ActionVar" name="MKB_CLINIC"                src="MKB_CLINIC"                srctype="var"         put="v39"              len="40"/>
		<component cmptype="Actionvar" name="MKB_CLINIC_EXACT"          src="MKB_CLINIC_EXACT"          srctype="var"         put="v40"              len="4000"/>
		<component cmptype="ActionVar" name="MKB_CLINIC_DATE"           src="MKB_CLINIC_DATE"           srctype="var"         put="v41"              len="25"/>
		<component cmptype="ActionVar" name="MKB_FINAL_ID"              src="MKB_FINAL_ID"              srctype="var"         put="v42"              len="17"/>
		<component cmptype="ActionVar" name="MKB_FINAL"                 src="MKB_FINAL"                 srctype="var"         put="v43"              len="40"/>
		<component cmptype="ActionVar" name="MKB_FINAL_EXACT"           src="MKB_FINAL_EXACT"           srctype="var"         put="v44"              len="4000"/>
		<component cmptype="ActionVar" name="MKB_FIN_ADD_ID"            src="MKB_FIN_ADD_ID"            srctype="var"         put="v45"              len="17"/>
		<component cmptype="ActionVar" name="MKB_FIN_ADD"               src="MKB_FIN_ADD"               srctype="var"         put="v46"              len="40"/>
		<component cmptype="ActionVar" name="MKB_FIN_ADD_EXACT"         src="MKB_FIN_ADD_EXACT"         srctype="var"         put="v47"              len="4000"/>
		<component cmptype="ActionVar" name="MKB_FIN_COMP_ID"	        src="MKB_FIN_COMP_ID"           srctype="var"         put="v48"              len="17"/>
		<component cmptype="ActionVar" name="MKB_FIN_COMP"	            src="MKB_FIN_COMP"              srctype="var"         put="v49"              len="40"/>
		<component cmptype="ActionVar" name="MKB_FIN_COMP_EXACT"        src="MKB_FIN_COMP_EXACT"        srctype="var"         put="v50"              len="4000"/>
		<component cmptype="ActionVar" name="DEP_ID"		            src="DEPS_PAR"                  srctype="ctrl"        put="v51"              len="17"/>
		<component cmptype="ActionVar" name="PAYMENT"		            src="PAYMENT_KIND"              srctype="ctrl"        put="v52"              len="17"/>
		<component cmptype="ActionVar" name="DISABLE_ALL"	            src="DISABLE_ALL"               srctype="var"         put="v53"              len="50"/>
		<component cmptype="ActionVar" name="TERM"		                src="TERM"                      srctype="ctrl"        put="v54"              len="10"/>
		<component cmptype="ActionVar" name="DIRKIND"		            src="DIR_KIND"                  srctype="var"         put="v55"              len="17"/>
		<component cmptype="ActionVar" name="HOSP_PLAN_KIND"	        src="HOSP_PLAN_KIND"            srctype="var"         get="v56"/>
		<component cmptype="ActionVar" name="ERRORS_PMC"	            src="ERRORS_PMC"                srctype="var"         put="v57"              len="4000"/>
		<component cmptype="ActionVar" name="DEF_HOSP_REASON_ID"        src="DEF_HOSP_REASON_ID"        srctype="var"         put="v58"              len="17"/>
		<component cmptype="ActionVar" name="DEF_HOSP_TYPE_ID"	        src="DEF_HOSP_TYPE_ID"          srctype="var"         put="v59"              len="17"/>
		<component cmptype="ActionVar" name="DEF_TRANSP_TYPE_ID"        src="DEF_TRANSP_TYPE_ID"        srctype="var"         put="v60"              len="17"/>
		<component cmptype="ActionVar" name="HH_TYPE"                   src="HH_TYPE"                   srctype="ctrl"        put="v61"              len="1" />
		<component cmptype="ActionVar" name="HOSP_BED_TYPE_ID"          src="HOSP_BED_TYPE_ID"          srctype="var"         put="v62"              len="17"/>
		<component cmptype="ActionVar" name="J_HPK"                     src="J_HPK"                     srctype="var"         put="v63"              len="17"/>
		<component cmptype="ActionVar" name="HOSP_HOUR_ID"              src="HOSP_HOUR"                 srctype="ctrl"        put="v64"              len="30"/>
		<component cmptype="ActionVar" name="RECEPTION_EMP"             src="RECEPTION_EMP"             srctype="ctrl"        put="v65"              len="30"/>
		<component cmptype="ActionVar" name="RECEPTION_EMP_FIO"         src="RECEPTION_EMP"             srctype="ctrlcaption" put="v66"              len="100"/>
		<component cmptype="ActionVar" name="DEP_BED_ID"                src="DEP_BED"                   srctype="ctrl"        put="v67"              len="100"/>
		<component cmptype="ActionVar" name="DEP_BED"                   src="DEP_BED"                   srctype="ctrlcaption" put="v68"              len="100"/>
		<component cmptype="ActionVar" name="J_PAYMENT_KIND_IS_COMMERC" src="J_PAYMENT_KIND_IS_COMMERC" srctype="var"	      put="v69"              len="1"/>
		<component cmptype="ActionVar" name="EMPLOYER"                  src="EMPLOYER"                  srctype="session"/>
		<component cmptype="ActionVar" name="HHNumerationMask"          src="HHNumerationMask"          srctype="var"         put="HHNumerationMask" len="100"/>
		<component cmptype="ActionVar" name="HH_NUMB_MASK"              src="HH_NUMB_MASK"              srctype="var"         put="HH_NUMB_MASK"     len="100"/>
		<component cmptype="ActionVar" name="CHILD_AGE"                 src="CHILD_AGE"                 srctype="var"         put="v70"              len="2"/>
		<component cmptype="ActionVar" name="PAT_YEAR"                  src="PAT_YEAR"                  srctype="var"         put="v71"              len="3"/>
		<component cmptype="ActionVar" name="IS_HH_UPD_HOSP"            src="IS_HH_UPD_HOSP"            srctype="var"         put="v72"              len="1"/>
		<component cmptype="ActionVar" name="DATE_DEPARTURE"            src="DATE_DEPARTURE"            srctype="ctrl"        put="v73"              len="10"/>
		<component cmptype="ActionVar" name="TIME_DEPARTURE"            src="TIME_DEPARTURE"            srctype="ctrl"        put="v74"              len="5"/>
		<component cmptype="ActionVar" name="CHECK_FOR_OMS" 	        src="CHECK_FOR_OMS"             srctype="var"         put="v75"              len="1"/>
		<component cmptype="ActionVar" name="RELATIVE_HH_ID"            src="RELATIVE_HH_ID"            srctype="var"         put="v76"              len="17"/>
		<component cmptype="ActionVar" name="RELATIVE_AGENT_ID"         src="RELATIVE_AGENT_ID"         srctype="var"         put="v77"              len="17"/>
		<component cmptype="ActionVar" name="NOVOR_NUM"                 src="NOVOR_NUM"                 srctype="ctrl"        put="v78"              len="5"/>
		<component cmptype="ActionVar" name="PMC_TYPE"                  src="PMC_TYPE"                  srctype="var"         put="v79"              len="5"/>
		<component cmptype="ActionVar" name="PK_CODE" 			        src="PK_CODE"                   srctype="var"         put="pPK_CODE"         len="20"/>
		<component cmptype="ActionVar" name="PKOMS_OPT"			        src="PKOMS_OPT"                 srctype="var"         put="pPKOMS_OPT"       len="2"/>
		<component cmptype="ActionVar" name="SPEC_LPU_TYPE"	            src="SPEC_LPU_TYPE"             srctype="var"         put="pSPEC_LPU_TYPE"   len="1"/>
		<component cmptype="ActionVar" name="HOSP_IS_FIRST"	            src="HOSP_IS_FIRST"             srctype="ctrl"        put="pHOSP_IS_FIRST"   len="1"/>
		<component cmptype="ActionVar" name="ARRIVE_ORDER"	            src="ARRIVE_ORDER"              srctype="ctrl"        put="pARRIVE_ORDER"    len="1"/>
		<component cmptype="ActionVar" name="JUDGE_DECISION"	        src="JUDGE_DECISION"            srctype="ctrl"        put="pJUDGE_DECISION"  len="1"/>
		<component cmptype="ActionVar" name="HOSP_INCOME_ID"	        src="HOSP_INCOME"               srctype="ctrl"        put="pHOSP_INCOME_ID"  len="17"/>
		<component cmptype="ActionVar" name="HOSP_INCOME"	            src="HOSP_INCOME"               srctype="ctrlcaption" put="pHOSP_INCOME"     len="100"/>
		<component cmptype="ActionVar" name="NSEX"	                    src="NSEX"                      srctype="var"         put="pNSEX"            len="1"/>
		<component cmptype="ActionVar" name="HospDateRestriction"       src="HospDateRestriction"       srctype="var"         put="pDATE_RESTRICT"   len="1"/>
		<component cmptype="ActionVar" name="HOSP_MKB_EXACT"            src="MKB_SEND_HANDLE"           srctype="ctrl"        put="HOSP_MKB_EXACT_S" len="4000"/>
		<component cmptype="ActionVar" name="HOSP_MKB_EXACT"            src="MKB10_HANDLE"              srctype="ctrl"        put="HOSP_MKB_EXACT_R" len="4000"/>
        <component cmptype="ActionVar" name="COUNT_CUR_HOSP"            src="COUNT_CUR_HOSP"            srctype="var"         get="gCOUNT_CUR_HOSP"/>
	</component>
	<component cmptype="Action" name="hospHistoryAdd" mode="post">
		<![CDATA[
		declare nHOURS VARCHAR2(10);
				nMKB_CL_DATE DATE;
				nJREGDATE DATE;
				sHH_PREF VARCHAR2(100);
        		nNEW_DIAG_ID    NUMBER;
        		dDIR_REG_DATE   DATE;
		begin
			if :MKB_CLINIC_DATE is not null then
				nMKB_CL_DATE := to_date(:MKB_CLINIC_DATE, 'dd.mm.yyyy');
			end if;
			if :J_REGISTER_DATE is not null then
				nJREGDATE := to_date(:J_REGISTER_DATE, 'dd.mm.yyyy hh24:mi');
			end if;
			if :HOURS is null then
				nHOURS := '00:00';
			else
				nHOURS := :HOURS;
			end if;
			IF :TERM IS NOT NULL THEN
			  	D_PKG_AGENT_PREGNANCY.CALC_AND_ADD(pnLPU => :LPU,
        	                                       pnPID => :PATIENT_ID,
        	                                      pnTERM => :TERM,
        	                                      pdDATE => to_date(:DATE_IN, 'dd.mm.yyyy'),
        	                               pnDISEASECASE => :DISEASECASE,
        	                                  pdREG_DATE => null,
        	                              pnPREG_OUTCOME => null,
        	                              pnABORT_REASON => null,
        	                                pnVIRTO_FERT => null,
        	                                pnMULTI_PREG => null);
			END IF;

            sHH_PREF := D_PKG_HOSP_HISTORIES.GET_HH_PREF(pnLPU     => :LPU,
                                                         psDP_CODE => :HH_PREF,
                                                         pdDATE    => sysdate);

        	begin
        	    select t.REG_DATE
        	      into dDIR_REG_DATE
        	      from D_V_DIRECTIONS t
        	     where t.ID = :DIRECTION_ID;
        	exception when NO_DATA_FOUND then
        	    null;
        	end;

			d_pkg_hosp_histories.add(pnd_insert_id => :HH_ID,
				                             pnlpu => :LPU,
				                pnhpk_plan_journal => :HPKJ_ID,
				                         pnpatient => :PATIENT_ID,
				                         pshh_pref => sHH_PREF,
				                         pshh_numb => :HH_NUMB,
				                  psHH_NUMB_ALTERN => :ALT_NUMB,
				                     pnhosp_reason => :HOSP_REASON,
				                   pnreception_emp => :RECEPTION_EMP,
				                         pddate_in => to_date(:DATE_IN||' '||nHOURS, 'dd.mm.yyyy hh24:mi'),
				                   pdplan_date_out => :PLAN_DATE_OUT,
				                        pddate_out => null,
				            pnhospitalization_type => :HOSP_TYPE,
				             pntransportation_kind => :TRANSP,
				                        pnlpu_from => :LPU_FROM,
				                        pnmkb_send => :MKB_SEND,
				                  psmkb_send_exact => :MKB_SEND_EXACT,
				                      pnmkb_clinic => :MKB_CLINIC_ID,
				                pSmkb_clinic_exact => :MKB_CLINIC_EXACT,
				                 pdmkb_clinic_date => nMKB_CL_DATE,
				                       pnmkb_final => :MKB_FINAL_ID,
				                 psmkb_final_exact => :MKB_FINAL_EXACT,
				                    pnmkb_fin_comp => :MKB_FIN_COMP_ID,
				              psmkb_fin_comp_exact => :MKB_FIN_COMP_EXACT,
				                     pnmkb_fin_add => :MKB_FIN_ADD_ID,
				               psmkb_fin_add_exact => :MKB_FIN_ADD_EXACT,
				                      pnhosp_times => :HOSP_TIMES,
				                     pnhosp_result => null,
				                     pnmkb_receive => :MKB_RECEIVE,
				               psmkb_receive_exact => :MKB_RECEIVE_EXACT,
				                        pnrelative => :RELATIVE_ID,
                                         pnHH_TYPE => :HH_TYPE,
                                       pnHOSP_HOUR => :HOSP_HOUR,
                                    pnHOSP_OUTCOME => null,
                                   psOTHER_THERAPY => null,
                                  pnABILITY_STATUS => null,
                                        psFEATURES => null,
                                    psHH_NUMB_MASK => null,
                                  pdDATE_DEPARTURE => to_date(:DATE_DEPARTURE||:TIME_DEPARTURE, D_PKG_STD.FRM_DT),
                                    pnARRIVE_ORDER => :ARRIVE_ORDER,
                                  pnJUDGE_DECISION => :JUDGE_DECISION,
                                     pnHOSP_INCOME => :HOSP_INCOME,
                                   pnHOSP_IS_FIRST => :HOSP_IS_FIRST,
						  	           pnNOVOR_NUM => :NOVOR_NUM,
                                pdDATE_MKB_RECEIVE => to_date(:DATE_IN||' '||nHOURS, 'dd.mm.yyyy hh24:mi'),
                                   pdDATE_MKB_SEND => dDIR_REG_DATE);

			d_pkg_hpk_plan_journals.upd(pnid => :HPKJ_ID,
				                       pnlpu => :LPU,
				                  pnhpk_plan => :J_HPK_PLAN,
				                   pnpatient => :PATIENT_ID,
				               pndirected_by => D_PKG_EMPLOYERS.GET_ID(:LPU),
				               pndirected_to => :J_DIRECTED_TO,
				             pnregistered_by => :J_REGISTERED_BY,
				             pdregister_date => nJREGDATE,
				            pnhas_privileges => :J_HAS_PRIVILEGES,
				                 pnoperation => :J_OPERATION,
				              pnpayment_kind => :J_PAYMENT_KIND,
				                 pndirection => :J_DIRECTION,
				                   pnis_oper => :J_IS_OPER,
				                  pnis_ready => :J_IS_READY,
				         pdhh_direction_date => :HH_DIRECTION_DATE,
				                  psComments => :COMMENT,
				                       pnhpk => :J_HPK,
                               pnrecord_numb => :J_RECORD_NUMB,
                               psrecord_pref => :J_RECORD_PREF);
			:D_DEPARTURE := :DATE_IN;
			:T_DEPARTURE := to_char(sysdate, D_PKG_STD.FRM_T);
			if :IS_RELATIVE_HOSP=1 and :RELATIVE_AGENT_ID is not null then
				d_pkg_hosp_histories.CREATE_HH_FOR_RELATIVE(pnLPU => :LPU,
                                                    pnRELATIVE_HH => :HH_ID,
                                                          pnAGENT => :RELATIVE_AGENT_ID,
                                                        pdDATE_IN => to_date(:DATE_IN||' '||nHOURS, 'dd.mm.yyyy hh24:mi'),
                                                            pnDEP => null,
                                                   pnPAYMENT_KIND => :J_PAYMENT_KIND,
                                                   pnRELATIONSHIP => null,
                                                        psAR_CODE => null,
                                                      pnREPRESENT => null,
                                                         pnHH_REL => :HH_REL,
                                                pnPERSMEDCARD_REL => :PMC_REL);
			end if;
		end;
		]]>
		<component cmptype="ActionVar" name="LPU"                src="LPU"                 srctype="session"/>
		<component cmptype="ActionVar" name="TERM"               src="TERM"                srctype="ctrl"        get="v1"/>
		<component cmptype="ActionVar" name="PATIENT_ID"         src="PMC_ID"              srctype="var"         get="v2"/>
		<component cmptype="ActionVar" name="DATE_IN"            src="HOSPIT_DATE"         srctype="ctrl"        get="v3"/>
		<component cmptype="ActionVar" name="DISEASECASE"        src="DISEASECASE"         srctype="var"         get="v4"/>
    	<component cmptype="ActionVar" name="DIRECTION_ID"       src="DIRECTION_ID"        srctype="var"         get="gDIRECTION_ID"/>
		<component cmptype="ActionVar" name="HH_ID"              src="HH_ID"               srctype="var"         put="v5" len="17"/>
		<component cmptype="ActionVar" name="HPKJ_ID"            src="HPK_PLAN_JOURNAL_ID" srctype="var"         get="v6"/>
		<component cmptype="ActionVar" name="PATIENT_ID"         src="PMC_ID"              srctype="var"         get="v7"/>
		<component cmptype="ActionVar" name="HH_PREF"            src="HOSP_PLAN_DEPS"      srctype="ctrlcaption" get="v8"/>
		<component cmptype="ActionVar" name="HH_NUMB"            src="HHnumber"            srctype="ctrl"        get="v9"/>
		<component cmptype="ActionVar" name="ALT_NUMB"           src="FullNumber"          srctype="ctrl"        get="v10"/>
		<component cmptype="ActionVar" name="HOSP_REASON"        src="HOSP_REASONS"        srctype="ctrl"        get="v11"/>
		<component cmptype="ActionVar" name="HOURS"              src="HOSPIT_HOURS"        srctype="ctrl"        get="v12"/>
		<component cmptype="ActionVar" name="PLAN_DATE_OUT"      src="PLAN_DATE_OUT"       srctype="ctrl"        get="v13"/>
		<component cmptype="ActionVar" name="HOSP_TYPE"          src="HOSP_TYPE"           srctype="ctrl"        get="v14"/>
		<component cmptype="ActionVar" name="TRANSP"             src="TRANSP"              srctype="ctrl"        get="v15"/>
		<component cmptype="ActionVar" name="LPU_FROM"           src="LPUDICT"             srctype="ctrl"        get="v16"/>
		<component cmptype="ActionVar" name="MKB_SEND"           src="MKB_SEND"            srctype="ctrl"        get="v17"/>
		<component cmptype="ActionVar" name="MKB_SEND_EXACT"     src="MKB_SEND_HANDLE"     srctype="ctrl"        get="v18"/>
		<component cmptype="ActionVar" name="MKB_RECEIVE"        src="MKB10"               srctype="ctrl"        get="v19"/>
		<component cmptype="ActionVar" name="MKB_RECEIVE_EXACT"  src="MKB10_HANDLE"        srctype="ctrl"        get="v20"/>
		<component cmptype="ActionVar" name="MKB_CLINIC_ID"      src="MKB_CLINIC_ID"       srctype="var"         get="v21"/>
		<component cmptype="ActionVar" name="MKB_CLINIC_EXACT"   src="MKB_CLINIC_EXACT"    srctype="var"         get="v22"/>
		<component cmptype="ActionVar" name="MKB_CLINIC_DATE"    src="MKB_CLINIC_DATE"     srctype="var"         get="v23"/>
		<component cmptype="ActionVar" name="MKB_FINAL_ID"       src="MKB_FINAL_ID"        srctype="var"         get="v24"/>
		<component cmptype="ActionVar" name="MKB_FINAL_EXACT"    src="MKB_FINAL_EXACT"     srctype="var"         get="v25"/>
		<component cmptype="ActionVar" name="MKB_FIN_COMP_ID"    src="MKB_FIN_COMP_ID"     srctype="var"         get="v26"/>
		<component cmptype="ActionVar" name="MKB_FIN_COMP_EXACT" src="MKB_FIN_COMP_EXACT"  srctype="var"         get="v27"/>
		<component cmptype="ActionVar" name="MKB_FIN_ADD_ID"     src="MKB_FIN_ADD_ID"      srctype="var"         get="v28"/>
		<component cmptype="ActionVar" name="MKB_FIN_ADD_EXACT"  src="MKB_FIN_ADD_EXACT"   srctype="var"         get="v29"/>
		<component cmptype="ActionVar" name="HOSP_TIMES"         src="HOSP_TIMES"          srctype="ctrl"        get="v30"/>
		<component cmptype="ActionVar" name="RELATIVE_ID"        src="AGENT_RELATIVES"     srctype="ctrl"        get="v31"/>
		<component cmptype="ActionVar" name="RELATIVE_AGENT_ID"  src="RELATIVE_AGENT_ID"   srctype="var"         get="v311"/>
		<component cmptype="ActionVar" name="J_HPK_PLAN"         src="J_HPK_PLAN"          srctype="var"         get="v32"/>
		<component cmptype="ActionVar" name="J_DIRECTED_BY"      src="J_DIRECTED_BY"       srctype="var"         get="v33"/>
		<component cmptype="ActionVar" name="J_DIRECTED_TO"      src="J_DIRECTED_TO"       srctype="var"         get="v34"/>
		<component cmptype="ActionVar" name="J_REGISTERED_BY"    src="J_REGISTERED_BY"     srctype="var"         get="v35"/>
		<component cmptype="ActionVar" name="J_REGISTER_DATE"    src="J_REGISTER_DATE"     srctype="var"         get="v36"/>
		<component cmptype="ActionVar" name="J_HAS_PRIVILEGES"   src="J_HAS_PRIVILEGES"    srctype="var"         get="v37"/>
		<component cmptype="ActionVar" name="J_OPERATION"        src="J_OPERATION"         srctype="var"         get="v38"/>
		<component cmptype="ActionVar" name="J_PAYMENT_KIND"     src="J_PAYMENT_KIND"      srctype="var"         get="v39"/>
		<component cmptype="ActionVar" name="J_DIRECTION"        src="J_DIRECTION"         srctype="var"         get="v40"/>
		<component cmptype="ActionVar" name="J_IS_READY"         src="J_IS_READY"          srctype="var"         get="v41"/>
		<component cmptype="ActionVar" name="HH_DIRECTION_DATE"  src="HH_DIRECTION_DATE"   srctype="var"         get="v42"/>
		<component cmptype="ActionVar" name="J_IS_OPER"          src="J_IS_OPER"           srctype="var"         get="v43"/>
		<component cmptype="ActionVar" name="COMMENT"            src="COMMENT"             srctype="ctrl"        get="v44"/>
        <component cmptype="ActionVar" name="HH_TYPE"            src="HH_TYPE"             srctype="ctrl"        get="v45"/>
        <component cmptype="ActionVar" name="J_HPK"              src="J_HPK"               srctype="var"         get="v46"/>
        <component cmptype="ActionVar" name="HOSP_HOUR"          src="HOSP_HOUR"           srctype="ctrl"        get="v47"/>
        <component cmptype="ActionVar" name="RECEPTION_EMP"      src="RECEPTION_EMP"       srctype="ctrl"        get="v48"/>
        <component cmptype="ActionVar" name="J_RECORD_NUMB"      src="J_RECORD_NUMB"       srctype="var"         get="v49"/>
        <component cmptype="ActionVar" name="J_RECORD_PREF"      src="J_RECORD_PREF"       srctype="var"         get="v50"/>
        <component cmptype="ActionVar" name="DATE_DEPARTURE"     src="DATE_DEPARTURE"      srctype="ctrl"        get="v51"/>
        <component cmptype="ActionVar" name="TIME_DEPARTURE"     src="TIME_DEPARTURE"      srctype="ctrl"        get="v52"/>
        <component cmptype="ActionVar" name="D_DEPARTURE"        src="DATE_DEPARTURE"      srctype="ctrl"        put="v53" len="10"/>
        <component cmptype="ActionVar" name="T_DEPARTURE"        src="TIME_DEPARTURE"      srctype="ctrl"        put="v54" len="5"/>
        <component cmptype="ActionVar" name="IS_RELATIVE_HOSP"   src="IS_RELATIVE_HOSP"    srctype="ctrl"        get="v55"/>
        <component cmptype="ActionVar" name="HH_REL"             src="HH_REL"              srctype="var"         put="v56" len="17"/>
        <component cmptype="ActionVar" name="PMC_REL"            src="PMC_REL"             srctype="var"         put="v57" len="17"/>
		<component cmptype="ActionVar" name="NOVOR_NUM"          src="NOVOR_NUM"           srctype="ctrl"        get="v58"/>
        <component cmptype="ActionVar" name="HOSP_IS_FIRST"      src="HOSP_IS_FIRST"       srctype="ctrl"        get="pHOSP_IS_FIRST"   />
        <component cmptype="ActionVar" name="ARRIVE_ORDER"       src="ARRIVE_ORDER"        srctype="ctrl"        get="pARRIVE_ORDER"    />
        <component cmptype="ActionVar" name="JUDGE_DECISION"     src="JUDGE_DECISION"      srctype="ctrl"        get="pJUDGE_DECISION"  />
        <component cmptype="ActionVar" name="HOSP_INCOME"        src="HOSP_INCOME"         srctype="ctrl"        get="pHOSP_INCOME"     />
	</component>
	<component cmptype="Action" name="hospHistoryEdit" mode="post">
		<![CDATA[
		declare nHOURS VARCHAR2(10);
			    nIS_WELL_TIMED_HOSP NUMBER(1);
			    nIS_ENOUGH_VOLUME NUMBER(1);
			    nIS_CORRECT_HEALING NUMBER(1);
			    nIS_SAME_DIAGN NUMBER(1);
			    nHH_TYPE NUMBER(1);
			    nCOUNT NUMBER(17);
			    nIS_PREG_UPD NUMBER(1);
			    sHH_PREF VARCHAR2(100);
				sOTHER_THERAPY VARCHAR2(2000);
				nABILITY_STATUS NUMBER(17);
				nRELATIVE_HH NUMBER(17);
				sFEATURES VARCHAR2(2000);
				IS_SAME_AGENT NUMBER(1);
				pnABANDONMENT NUMBER(1);
		begin
			IF :TERM IS NOT NULL THEN
			  	for cr in (select t.*
						     from D_V_AGENT_PREGNANCY t
							      join D_V_DISEASECASES t2 on t2.AGENT_PREGNANCY = t.ID
						    where t.PID = :PATIENT_ID
						      and t.VERSION = d_pkg_versions.get_version_by_lpu(0, :LPU, 'AGENT_PREGNANCY')
						      and D_PKG_CMP.NUM(t2.ID, :DISEASECASE) = 1) loop
					D_PKG_AGENT_PREGNANCY.CALC_AND_ADD(pnLPU => :LPU,
												       pnPID => :PATIENT_ID,
												      pnTERM => :TERM,
												      pdDATE => to_date(:DATE_IN, 'dd.mm.yyyy'),
											   pnDISEASECASE => :DISEASECASE,
												  pdREG_DATE => cr.REG_DATE,
										      pnPREG_OUTCOME => cr.PREG_OUTCOME_ID,
											  pnABORT_REASON => cr.ABORT_REASON_ID,
											    pnVIRTO_FERT => cr.VIRTO_FERT,
										    	pnMULTI_PREG => cr.MULTI_PREG);
					nIS_PREG_UPD := 1;
			  	end loop;
			  	if nIS_PREG_UPD is null then
					D_PKG_AGENT_PREGNANCY.CALC_AND_ADD(pnLPU => :LPU,
												       pnPID => :PATIENT_ID,
												      pnTERM => :TERM,
												      pdDATE => to_date(:DATE_IN, 'dd.mm.yyyy'),
											   pnDISEASECASE => :DISEASECASE,
												  pdREG_DATE => null,
											  pnPREG_OUTCOME => null,
										      pnABORT_REASON => null,
										     	pnVIRTO_FERT => null,
											    pnMULTI_PREG => null);
			  	end if;
			END IF;
			if :HOURS is null then
				nHOURS := '00:00';
			else
				nHOURS := :HOURS;
			end if;
			select t.IS_WELL_TIMED_HOSP,
				   t.IS_ENOUGH_VOLUME,
				   t.IS_CORRECT_HEALING,
				   t.IS_SAME_DIAGN,
				   t.HH_TYPE,
				   t.OTHER_THERAPY,
				   t.ABILITY_STATUS_ID,
				   t.FEATURES,
				   t.RELATIVE_HH,
				   t.ABANDONMENT
			  into nIS_WELL_TIMED_HOSP,
				   nIS_ENOUGH_VOLUME,
				   nIS_CORRECT_HEALING,
				   nIS_SAME_DIAGN,
				   nHH_TYPE,
				   sOTHER_THERAPY,
				   nABILITY_STATUS,
				   sFEATURES,
				   nRELATIVE_HH,
				   pnABANDONMENT
			  from D_V_HOSP_HISTORIES t
			 where t.ID = :HH_ID
			   and t.LPU = :LPU;

            sHH_PREF := D_PKG_HOSP_HISTORIES.GET_HH_PREF(pnLPU     => :LPU,
                                                         psDP_CODE => :HH_PREF,
                                                         pdDATE    => sysdate);

			d_pkg_hosp_histories.upd(pnid => :HH_ID,
							        pnlpu => :LPU,
					   pnhpk_plan_journal => :HPKJ_ID,
							    pnpatient => :PATIENT_ID,
							    pshh_pref => sHH_PREF,
							    pshh_numb => :HH_NUMB,
					     psHH_NUMB_ALTERN => :ALT_NUMB,
							pnhosp_reason => :HOSP_REASON,
					      pnreception_emp => :RECEPTION_EMP,
							    pddate_in => to_date(:DATE_IN||' '||nHOURS, 'dd.mm.yyyy hh24:mi'),
						  pdplan_date_out => :PLAN_DATE_OUT,
							   pddate_out => null,
				   pnhospitalization_type => :HOSP_TYPE,
					pntransportation_kind => :TRANSP,
							   pnlpu_from => :LPU_FROM,
							   pnmkb_send => :MKB_SEND,
						 psmkb_send_exact => :MKB_SEND_EXACT,
						     pnmkb_clinic => :MKB_CLINIC_ID,
					   psmkb_clinic_exact => :MKB_CLINIC_EXACT,
					    pdmkb_clinic_date => :MKB_CLINIC_DATE,
						      pnmkb_final => :MKB_FINAL_ID,
					    psmkb_final_exact => :MKB_FINAL_EXACT,
						   pnmkb_fin_comp => :MKB_FIN_COMP_ID,
					 psmkb_fin_comp_exact => :MKB_FIN_COMP_EXACT,
						    pnmkb_fin_add => :MKB_FIN_ADD_ID,
					  psmkb_fin_add_exact => :MKB_FIN_ADD_EXACT,
							 pnhosp_times => :HOSP_TIMES,
						    pnhosp_result => null,
						    pnmkb_receive => :MKB_RECEIVE,
					  psmkb_receive_exact => :MKB_RECEIVE_EXACT,
							   pnrelative => :RELATIVE_ID,
					     pndiscard_status => 0,
				     pnis_well_timed_hosp => nIS_WELL_TIMED_HOSP,
					   pnis_enough_volume => nIS_ENOUGH_VOLUME,
					 pnis_correct_healing => nIS_CORRECT_HEALING,
						  pnis_same_diagn => nIS_SAME_DIAGN,
							  pnhosp_hour => :HOSP_HOUR,
						   pnhosp_outcome => null,
						  psOTHER_THERAPY => sOTHER_THERAPY,
						 pnABILITY_STATUS => nABILITY_STATUS,
						       psFEATURES => sFEATURES,
					     pdDATE_DEPARTURE => to_date(:DATE_DEPARTURE||:TIME_DEPARTURE, D_PKG_STD.FRM_DT),
						    pnRELATIVE_HH => nRELATIVE_HH,
						    pnABANDONMENT => pnABANDONMENT,
							 pnDEATH_CAME => null,
						   pnARRIVE_ORDER => :ARRIVE_ORDER,
						 pnJUDGE_DECISION => :JUDGE_DECISION,
						    pnHOSP_INCOME => :HOSP_INCOME,
						  pnHOSP_IS_FIRST => :HOSP_IS_FIRST,
							 pnNOVOR_NUM  => :NOVOR_NUM);
			if nvl(:HH_TYPE,-1) != nvl(nHH_TYPE,-1) then
				if D_PKG_URPRIVS.CHECK_BPPRIV(:LPU, 'HOSP_HISTORIES_UPD_HOSP', null, 0) = 0 then
					select count(1)
					  into nCOUNT
					  from D_V_HOSP_HISTORY_DEPS t
					 where t.PID = :HH_ID;
					if nCOUNT > 1 then
						D_P_EXC('Нет прав на изменение типа истории болезни, если у пациента были перемещения по отделениям.');
					end if;
				end if;
				d_pkg_hosp_histories.set_hh_type(:HH_ID,:LPU,:HH_TYPE);
			end if;

			if :RELATIVE_HH_ID is not null then
				select case when h.PATIENT_AGENT = :RELATIVE_AGENT_ID then 1 else 0 end
				  into IS_SAME_AGENT
				  from  D_V_HOSP_HISTORIES_RELATIVE h
				 where h.id=:RELATIVE_HH_ID;
			else
				IS_SAME_AGENT:=1;
			end if;

			if :RELATIVE_HH_ID is not null and (:IS_RELATIVE_HOSP=0 or IS_SAME_AGENT=0) then
				/*если сняли галочку госпитализация с сопровождающим и иб на сопровождающего уже создана, или изменили контрагента, то ИБ нужно аннулировать*/
				d_pkg_hosp_histories.del(:RELATIVE_HH_ID,:LPU);
			end if;

			if (:RELATIVE_HH_ID is null and :IS_RELATIVE_HOSP=1) or IS_SAME_AGENT=0 then
			   	/*Если впервые заполнили госпитализацию сопровождающего или сменили его, то сохраняем ИБ*/
				d_pkg_hosp_histories.CREATE_HH_FOR_RELATIVE(pnLPU => :LPU,
											        pnRELATIVE_HH => :HH_ID,
											              pnAGENT => :RELATIVE_AGENT_ID,
											            pdDATE_IN => to_date(:DATE_IN||' '||nHOURS, 'dd.mm.yyyy hh24:mi'),
											                pnDEP => null,
											       pnPAYMENT_KIND => null,
											       pnRELATIONSHIP => null,
											           psAR_CODE  => null,
											          pnREPRESENT => null,
											             pnHH_REL => :RELATIVE_HH_ID,
											    pnPERSMEDCARD_REL => :PMC_REL);
			else
				:RELATIVE_HH_ID:=:RELATIVE_HH_ID;/*так как есть это и get и put переменная.put заполняется только при создании новой, при старой  не должна измениться*/
			end if;
		end;
		]]>
		<component cmptype="ActionVar" name="LPU"                src="LPU"                 srctype="session"/>
		<component cmptype="ActionVar" name="HH_ID"              src="HH_ID"               srctype="var"         get="v1"/>
		<component cmptype="ActionVar" name="HPKJ_ID"            src="HPK_PLAN_JOURNAL_ID" srctype="var"         get="v2"/>
		<component cmptype="ActionVar" name="PATIENT_ID"         src="PMC_ID"              srctype="var"         get="v3"/>
		<component cmptype="ActionVar" name="HH_PREF"            src="HOSP_PLAN_DEPS"      srctype="ctrlcaption" get="v4"/>
		<component cmptype="ActionVar" name="HH_NUMB"            src="HHnumber"            srctype="ctrl"        get="v5"/>
		<component cmptype="ActionVar" name="ALT_NUMB"           src="FullNumber"          srctype="ctrl"        get="v6"/>
		<component cmptype="ActionVar" name="HOSP_REASON"        src="HOSP_REASONS"        srctype="ctrl"        get="v7"/>
		<component cmptype="ActionVar" name="DATE_IN"            src="HOSPIT_DATE"         srctype="ctrl"        get="v8"/>
		<component cmptype="ActionVar" name="HOURS"              src="HOSPIT_HOURS"        srctype="ctrl"        get="v9"/>
		<component cmptype="ActionVar" name="PLAN_DATE_OUT"      src="PLAN_DATE_OUT"       srctype="ctrl"        get="v10"/>
		<component cmptype="ActionVar" name="HOSP_TYPE"          src="HOSP_TYPE"           srctype="ctrl"        get="v11"/>
		<component cmptype="ActionVar" name="TRANSP"             src="TRANSP"              srctype="ctrl"        get="v12"/>
		<component cmptype="ActionVar" name="LPU_FROM"           src="LPUDICT"             srctype="ctrl"        get="v13"/>
		<component cmptype="ActionVar" name="MKB_SEND"           src="MKB_SEND"            srctype="ctrl"        get="v14"/>
		<component cmptype="ActionVar" name="MKB_SEND_EXACT"     src="MKB_SEND_HANDLE"     srctype="ctrl"        get="v15"/>
		<component cmptype="ActionVar" name="MKB_CLINIC_ID"      src="MKB_CLINIC_ID"       srctype="var"         get="v16"/>
		<component cmptype="ActionVar" name="MKB_CLINIC_EXACT"   src="MKB_CLINIC_EXACT"    srctype="var"         get="v17"/>
		<component cmptype="ActionVar" name="MKB_CLINIC_DATE"    src="MKB_CLINIC_DATE"     srctype="var"         get="v18"/>
		<component cmptype="ActionVar" name="MKB_FINAL_ID"       src="MKB_FINAL_ID"        srctype="var"         get="v19"/>
		<component cmptype="ActionVar" name="MKB_FINAL_EXACT"    src="MKB_FINAL_EXACT"     srctype="var"         get="v20"/>
		<component cmptype="ActionVar" name="MKB_FIN_COMP_ID"    src="MKB_FIN_COMP_ID"     srctype="var"         get="v21"/>
		<component cmptype="ActionVar" name="MKB_FIN_COMP_EXACT" src="MKB_FIN_COMP_EXACT"  srctype="var"         get="v22"/>
		<component cmptype="ActionVar" name="MKB_FIN_ADD_ID"     src="MKB_FIN_ADD_ID"      srctype="var"         get="v23"/>
		<component cmptype="ActionVar" name="MKB_FIN_ADD_EXACT"  src="MKB_FIN_ADD_EXACT"   srctype="var"         get="v24"/>
		<component cmptype="ActionVar" name="HOSP_TIMES"         src="HOSP_TIMES"          srctype="ctrl"        get="v25"/>
		<component cmptype="ActionVar" name="MKB_RECEIVE"        src="MKB10"               srctype="ctrl"        get="v26"/>
		<component cmptype="ActionVar" name="MKB_RECEIVE_EXACT"  src="MKB10_HANDLE"        srctype="ctrl"        get="v27"/>
		<component cmptype="ActionVar" name="RELATIVE_ID"        src="AGENT_RELATIVES"     srctype="ctrl"        get="v28"/>
		<component cmptype="ActionVar" name="DISEASECASE"        src="DISEASECASE"         srctype="var"         get="v29"/>
		<component cmptype="ActionVar" name="TERM"               src="TERM"                srctype="ctrl"        get="v30"/>
		<component cmptype="ActionVar" name="HH_TYPE"            src="HH_TYPE"             srctype="ctrl"        get="v31"/>
		<component cmptype="ActionVar" name="HOSP_HOUR"          src="HOSP_HOUR"           srctype="ctrl"        get="v32"/>
		<component cmptype="ActionVar" name="RECEPTION_EMP"      src="RECEPTION_EMP"       srctype="ctrl"        get="v33"/>
		<component cmptype="ActionVar" name="DATE_DEPARTURE"     src="DATE_DEPARTURE"      srctype="ctrl"        get="v34"/>
		<component cmptype="ActionVar" name="TIME_DEPARTURE"     src="TIME_DEPARTURE"      srctype="ctrl"        get="v35"/>
		<component cmptype="ActionVar" name="IS_RELATIVE_HOSP"   src="IS_RELATIVE_HOSP"    srctype="ctrl"        get="v55"/>
		<component cmptype="ActionVar" name="RELATIVE_HH_ID"     src="RELATIVE_HH_ID"      srctype="var"         get="v56"/>
		<component cmptype="ActionVar" name="RELATIVE_AGENT_ID"  src="RELATIVE_AGENT_ID"   srctype="var"         get="v57"/>
		<component cmptype="ActionVar" name="RELATIVE_HH_ID"     src="RELATIVE_HH_ID"      srctype="var"         put="v58" len="17"/>
		<component cmptype="ActionVar" name="PMC_REL"            src="PMC_REL"             srctype="var"         put="v59" len="17"/>
		<component cmptype="ActionVar" name="NOVOR_NUM"  		 src="NOVOR_NUM"           srctype="ctrl"        get="v60"/>
		<component cmptype="ActionVar" name="HOSP_IS_FIRST"	     src="HOSP_IS_FIRST"       srctype="ctrl"        get="pHOSP_IS_FIRST"   />
		<component cmptype="ActionVar" name="ARRIVE_ORDER"	     src="ARRIVE_ORDER"        srctype="ctrl"        get="pARRIVE_ORDER"    />
		<component cmptype="ActionVar" name="JUDGE_DECISION"	 src="JUDGE_DECISION"      srctype="ctrl"        get="pJUDGE_DECISION"  />
		<component cmptype="ActionVar" name="HOSP_INCOME"	     src="HOSP_INCOME"         srctype="ctrl"        get="pHOSP_INCOME"     />
	</component>
	<component cmptype="Action" name="GenerateNumber" mode="post">
		<![CDATA[
		begin
			begin
				:result1 := d_pkg_hosp_histories.get_new_numb(pnlpu => :pnlpu,
				                                             pspref => :pspref,
				                                   pnhosp_plan_kind => :pnhosp_plan_kind);
			end;

			begin
				:result2 := d_pkg_hosp_histories.get_new_numb(pnlpu => :pnlpu,
										                     pspref => :pspref,
										           pnis_alternative => 1,
										           pnhosp_plan_kind => :pnhosp_plan_kind);
				if length(:result2) < 5 then
					:result2 := lpad(:result2,5,'0');
				end if;
			end;
		end;
		]]>
		<component cmptype="ActionVar" name="pnlpu"            src="LPU"            srctype="session"/>
		<component cmptype="ActionVar" name="pspref"           src="HOSP_PLAN_DEPS" srctype="ctrlcaption" get="v1"/>
		<component cmptype="ActionVar" name="result1"          src="HHnumber"       srctype="ctrl"        put="v2" len="4000"/>
		<component cmptype="ActionVar" name="result2"          src="FullNumber"     srctype="ctrl"        put="v3" len="4000"/>
		<component cmptype="ActionVar" name="pnhosp_plan_kind" src="HOSP_PLAN_KIND" srctype="var"         get="v3"/>
	</component>
	<component cmptype="Action" name="ACT_CHECK_DEATHDATE">
		<![CDATA[
			declare dHOSP_DATE DATE;
			begin
				if :HOSPIT_DATE is not null then
					dHOSP_DATE := to_date(:HOSPIT_DATE||' '||coalesce(:HOSPIT_HOURS, '00:00'), D_PKG_STD.FRM_DT);
				else
					dHOSP_DATE := sysdate;
				end if;
				:SO_DEATH_CHECK := D_PKG_OPTIONS.GET('DSDeathDateCheck', :LPU);
				begin
					select case when dHOSP_DATE >= trunc(pmc.DEATHDATE)
								then 1
								else 0
						   end,
						   to_char(pmc.DEATHDATE, D_PKG_STD.FRM_D)
					  into :IS_DEAD,
						   :DEATH_DATE
					  from D_V_PERSMEDCARD pmc
					 where pmc.ID = :PATIENT_ID
					   and pmc.LPU = :LPU;
					exception when NO_DATA_FOUND then :IS_DEAD := 0;
							                          :DEATH_DATE := null;
				end;
				begin
					if :RELATIVE is not null then
						select case when dHOSP_DATE >= trunc(a.DEATHDATE)
									then 1
									else 0
							   end,
							   to_char(a.DEATHDATE, D_PKG_STD.FRM_D)
						  into :IS_DEAD_RLTV,
							   :DEATH_DATE_RLTV
						  from D_V_AGENTS a
						 where a.ID = :RELATIVE
						   and a.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0, :LPU, 'AGENTS');
					end if;
					exception when NO_DATA_FOUND then :IS_DEAD_RLTV := 0;
							                          :DEATH_DATE_RLTV := null;
				end;
			end;
		]]>
		<component cmptype="ActionVar" name="LPU"             src="LPU"               srctype="session"/>
		<component cmptype="ActionVar" name="HOSPIT_DATE"     src="HOSPIT_DATE"       srctype="ctrl" get="gHOSPIT_DATE"/>
		<component cmptype="ActionVar" name="HOSPIT_HOURS"    src="HOSPIT_HOURS"      srctype="ctrl" get="gHOSPIT_HOURS"/>
		<component cmptype="ActionVar" name="PATIENT_ID"      src="PERSMEDCARD"       srctype="ctrl" get="gPATIENT_ID"/>
		<component cmptype="ActionVar" name="RELATIVE"        src="RELATIVE_AGENT_ID" srctype="var"  get="gRELATIVE"/>
		<component cmptype="ActionVar" name="SO_DEATH_CHECK"  src="SO_DEATH_CHECK"    srctype="var"  put="pSO_DC"    len="1"/>
		<component cmptype="ActionVar" name="IS_DEAD"         src="IS_DEAD"           srctype="var"  put="pIS_DEAD"  len="1"/>
		<component cmptype="ActionVar" name="IS_DEAD_RLTV"    src="IS_DEAD_RLTV"      srctype="var"  put="pIS_DEADR" len="1"/>
		<component cmptype="ActionVar" name="DEATH_DATE"      src="DEATH_DATE"        srctype="var"  put="pD_DATE"   len="10"/>
		<component cmptype="ActionVar" name="DEATH_DATE_RLTV" src="DEATH_DATE_RLTV"   srctype="var"  put="pD_DATER"  len="10"/>
	</component>
	<component cmptype="DataSet" name="DS_HOSP_REASONS" activateoncreate="false" compile="true">
		<![CDATA[
			select t.ID,
				   t.HR_CODE||' '||t.HR_NAME HR_NAME
			  from D_V_HOSP_REASONS t
			 where t.VERSION = d_pkg_versions.get_version_by_lpu(0,:pnLPU,'HOSP_REASONS')
			  @if(empty(:DISABLE_ALL)) {
			   @if (:HOSPIT_DATE) {
			   and :HOSPIT_DATE >= t.BEGIN_DATE
			   and (t.END_DATE is null or :HOSPIT_DATE <= t.END_DATE)
			   @} else {
			   and t.IS_ACTIVE = 1
			   @}
			  @}
		   ]]>
		   <component cmptype="Variable" name="PNLPU"       src="LPU"         srctype="session"/>
		   <component cmptype="Variable" name="HOSPIT_DATE" src="HOSPIT_DATE" srctype="ctrl" get="v1" len="25"/>
		   <component cmptype="Variable" name="DISABLE_ALL" src="DISABLE_ALL" srctype="var"  get="v2"/>
	</component>
	<component cmptype="DataSet" name="DS_HOSP_TYPE">
		select t.ID,
			   t.HK_CODE||' - '||t.HK_NAME  FULL_NAME
		  from D_V_HOSPITALIZATION_TYPES t
	</component>
	<component cmptype="DataSet" name="DS_TRANSP">
		select t.ID,
			   t.TK_CODE||' - '||t.TK_NAME  FULL_NAME
		  from D_V_TRANSPORTATION_KINDS t
	</component>
	<component cmptype="DataSet" name="DS_DEP_PARS" activateoncreate="false">
		select t.ID,
		       t.DP_NAME NAME
		  from d_v_deps t
		 where t.LPU = :LPU
		   and (t.DIVISION is null or D_PKG_CSE_ACCESSES.CHECK_RIGHT(pnLPU => :LPU,
		                                                        psUNITCODE => 'DIVISIONS',
		                                                         pnUNIT_ID => t.DIVISION,
		                                                           psRIGHT => 3,
	                                                              pnCABLAB => :CABLAB,
		                                                         pnSERVICE => null) = 1)
		   and t.id in (select hpd.DEP_ID
						  from d_v_hosp_plan_deps  hpd
							   join d_v_hosp_plan_kinds hpk on hpk.id = hpd.HP_KIND_ID
						 where hpk.id = :HPK)
		   and d_pkg_dep_requisites.get_actual(:LPU, t.ID, to_date(:HOSPIT_DATE)) is not null
		<component cmptype="Variable" name="LPU"         src="LPU"            srctype="session"/>
		<component cmptype="Variable" name="CABLAB"      src="CABLAB"         srctype="session"/>
		<component cmptype="Variable" name="HPK"         src="HOSP_PLAN_KIND" srctype="var"  get="v1"/>
		<component cmptype="Variable" name="HOSPIT_DATE" src="HOSPIT_DATE"    srctype="ctrl" get="v2"/>
	</component>
	<component cmptype="DataSet" name="DS_FAC_ACC">
		<![CDATA[
		   select f.ID,
			      a.AGN_NAME,
			      rownum
			 from D_V_FACIAL_ACCOUNTS f
				  join D_V_AGENTS a on a.ID = f.AGENT_ID
				  join D_V_CONTRACTS c
					on c.FACIAL_ACCOUNT = f.ID
					   and (c.DATE_BEGIN <= sysdate or c.DATE_BEGIN is null)
					   and (c.DATE_END >= sysdate or c.DATE_END is null)
				  join D_V_CONTR_AMI_DIRECTS ca
					on ca.PID = c.ID
					   and ca.IS_ACTIVE = 1
					   and ca.PATIENT_ID  = :PATIENT
			where f.PAYMENT_KIND_ID = :PK
		 ORDER BY 3 DESC
		]]>
		<component cmptype="Variable" name="PK"      src="PAYMENT_KIND" srctype="ctrl" get="v1"/>
		<component cmptype="Variable" name="PATIENT" src="PMC_ID"       srctype="var" get="v2"/>
	</component>
	<component cmptype="DataSet" name="DS_PKS">
		<![CDATA[
			select t.*
			  from d_v_payment_kind t,
				  (select hpk.HAS_PAYMENT_CONSTRAINTS as nFLAG
					 from d_v_hosp_plan_kinds hpk
					where hpk.id = :HPK
				  ) t1
			where t1.nFLAG = 0
			   or t.id in (select hpk_pk.PAYMENT_KIND_ID as ID
						     from D_V_HPK_PAYMENT_KINDS  hpk_pk
						    where hpk_pk.pid = :HPK)
			order by t.pk_code
		]]>
		<component cmptype="Variable" name="HPK" src="HOSP_PLAN_KIND" srctype="var" get="v1"/>
	</component>
	<component cmptype="DataSet" name="DS_HOSP_HOURS">
		select t.HOUR_CODE,
			   t.HOUR_NAME
		  from D_V_HOSP_HOURS t
	</component>
	<component cmptype="Action" name="recheckFaccAcc">
		<![CDATA[
			begin
				select 1
				  into :ENABLE_FA
				  from D_V_PAYMENT_KIND t
				 WHERE t.CONTRACT_TYPE in (2,3)
				   and t.ID = :PK;
				exception when NO_DATA_FOUND then :ENABLE_FA := 0;
			end;
		]]>
		<component cmptype="ActionVar" name="PK"        src="PAYMENT_KIND" srctype="ctrl" get="v1"/>
		<component cmptype="ActionVar" name="ENABLE_FA" src="ENABLE_FA"    srctype="var"  put="v4" len="1"/>
	</component>
	<component cmptype="DepControls" name="DepControlsNextButton" requireds="PERSMEDCARD;HOSP_PLAN_DEPS;HHnumber;HOSP_REASONS;HOSP_TYPE;TRANSP" dependents="NextButton"/>
	<component cmptype="DepControls" name="DepControlsOkButton" requireds="DEPS_PAR;PAYMENT_KIND" dependents="OkButton"/>
	<component cmptype="MaskInspector" controls="HOSPIT_DATE;HOSPIT_HOURS"/>
	<component cmptype="PageControl" name="HospControl" mode="gorizontal">
		<component cmptype="TabSheet" caption="История болезни" activ="true">
			<table width="98%">
				<tr>
					<td style="padding:3pt">
						<component cmptype="label" caption="Пациент:"/>
					</td>
					<td style="padding:3pt;">
						<component cmptype="UnitEdit" name="PERSMEDCARD" unit="PERSMEDCARD" composition="BUTTON_EDIT_DEFAULT" width="100%" enabled="false">
							<component cmptype="Button" type="micro" title="Редактировать карту" background="Icons/person_edit" onclick="base().openPersMedCard();"/>
						</component>
					</td>
					<td style="width:1px;" colspan="2">
						<img src="Images/img2/warning.png" name="WARN_PMC" cmptype="imgg" style="cursor:pointer;vertical-align:middle;display:none;" onclick="alert(getVar('ERRORS_PMC'));" title="Имеются ошибки"/>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
						<component cmptype="label" caption="Код отделения:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<component cmptype="Edit" name="HP_KIND_ID" style="display: none;"/>
						<component cmptype="UnitEdit" name="HOSP_PLAN_DEPS" unit="HOSP_PLAN_DEPS" composition="KIND" parent_ctrl="HP_KIND_ID" width="100%"
									custom_filter="{0:{'unit':'HOSP_PLAN_DEPS', 'method': 'KIND', 'filter': 'd_pkg_dep_requisites.get_actual(:LPU, v.DEP_ID, to_date(\''+getValue('HOSPIT_DATE')+'\')) is not null'}}">
							<component cmptype="Button" type="micro" background="Icons/btn_erase" onclick="setValue('HOSP_PLAN_DEPS',null);setCaption('HOSP_PLAN_DEPS',null);"/>
						</component>
					</td>
				</tr>
				<tr cmptype="tmp" name="hh_numb_row">
					<td style="padding:3pt">
						<component cmptype="label" caption="Номер истории болезни:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<component cmptype="Edit" name="HHnumber" width="60" onchange="base().checkHHNumberValidness(null, 'HHnumber');" onkeydown="base().checkHHNumberValidness(event, 'HHnumber');"/>
						<img src="Images/ok.gif" style="cursor:pointer;vertical-align:middle;" cmptype="tmp" name="ImgHHnumber" onclick="executeAction('GenerateNumber');"/>
						<component cmptype="label" name="LabelFullNumber" caption=" Общебольничный номер: "/>
						<component cmptype="Edit" name="FullNumber" width="60" onchange="base().checkHHNumberValidness(null, 'FullNumber');" onkeydown="base().checkHHNumberValidness(event, 'FullNumber');"/>
						<img src="Images/ok.gif" cmptype="tmp" name="ImgFullNumber" style="cursor:pointer;vertical-align:middle;" onclick="executeAction('GenerateNumber');"/>
					</td>
				</tr>
				<tr cmptype="tmp"  name="ROW_NOVOR_NUM">
					<td style="padding:3pt">
						<component cmptype="Label" caption="Порядковый № новорожденного:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<component cmptype="Edit" name="NOVOR_NUM" width="60"/>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
						<component cmptype="label" caption="Тип:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<component cmptype="ComboBox" name="HH_TYPE" width="100%" onchange="base().onChangeHHType();">
							<component cmptype="ComboItem" value="" caption="История болезни" activ="true"/>
							<component cmptype="ComboItem" value="1" caption="История родов"  />
							<component cmptype="ComboItem" name="CI_INSANE" value="4" caption="История болезни псих./нарк. больного"  />
						</component>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
						<component cmptype="label" caption="Причина госпитализации:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<component cmptype="ComboBox" name="HOSP_REASONS" width="100%" emptymask="true">
							<component cmptype="ComboItem" value="" caption="" activ="true"/>
							<component cmptype="ComboItem" datafield="ID" captionfield="HR_NAME" DataSet="DS_HOSP_REASONS" afterrefresh="base().checkHR();" repeate="0"/>
						</component>
					</td>
					<component cmptype="MaskInspector" name="REASON_MASK"/>
				</tr>
				<tr>
					<td style="padding:3pt">
						<component cmptype="label" caption="Предположительная дата выписки по МЭС:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<component cmptype="DateEdit" name="PLAN_DATE_OUT"/>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
					<component cmptype="label" caption="Тип госпитализации:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<component cmptype="ComboBox" name="HOSP_TYPE" width="100%" >
							<component cmptype="ComboItem" value="" caption="" activ="true"/>
							<component cmptype="ComboItem" datafield="ID" captionfield="FULL_NAME" DataSet="DS_HOSP_TYPE" repeate="0"/>
						</component>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
						<component cmptype="label" caption="Тип транспортировки:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<component cmptype="ComboBox" name="TRANSP" width="100%">
							<component cmptype="ComboItem" value="" caption="" activ="true"/>
							<component cmptype="ComboItem" datafield="ID" captionfield="FULL_NAME" DataSet="DS_TRANSP" repeate="0"/>
						</component>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
					<component cmptype="label" caption="ЛПУ направления:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<component cmptype="UnitEdit" name="LPUDICT" unit="LPUDICT" composition="LD_GRID" width="100%"/>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
						<component cmptype="label" caption="Сопровождающее лицо:"/>
					</td>
					<td style="padding:3pt" colspan="2">
						<component cmptype="ButtonEdit"	name="AGENT_RELATIVES" unit="hz" width="100%" readonly="true" buttononclick="base().relatives();">
							<component cmptype="Button" type="micro" background="Icons/btn_erase" onclick="setValue('AGENT_RELATIVES',null);setCaption('AGENT_RELATIVES',null); base().checkRelatives();"/>
						</component>
					</td>
					<td style="padding:3pt">
						<component cmptype="CheckBox" name="IS_RELATIVE_HOSP" caption="Госпитализация" valuechecked="1" valueunchecked="0" style="width:115px"/>
					</td>
				</tr>
				<tr class="TR_MENTAL_INFO">
					<td style="padding:3pt">
						<component cmptype="Label" caption="Госпитализация:"/>
					</td>
					<td colspan="3" style="padding:3pt">
						<component cmptype="ComboBox" name="HOSP_IS_FIRST" width="100%">
							<component cmptype="ComboItem" caption="" value=""/>
							<component cmptype="ComboItem" caption="впервые в жизни" value="0"/>
							<component cmptype="ComboItem" caption="повторно" value="1"/>
							<component cmptype="ComboItem" caption="повторно в данном году" value="2"/>
						</component>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
						<component cmptype="label" caption="Госпитализирован в этом году по этому заболеванию (раз):"/>
					</td>
					<td style="padding:3pt" name="HospTimes">
						<component cmptype="Edit" name="HOSP_TIMES" width="80"/>
					</td>
					<td style="padding:3pt">
						<component cmptype="Label" caption="Количество часов с начала заболевания:"/>
					</td>
					<td style="padding:3pt">
						<component cmptype="ComboBox" name="HOSP_HOUR" width="115px">
							<component cmptype="ComboItem" value="" caption="" activ="true"/>
							<component cmptype="ComboItem" datafield="HOUR_CODE" captionfield="HOUR_NAME" DataSet="DS_HOSP_HOURS" repeate="0"/>
						</component>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
						<component cmptype="label" caption="Диагноз направившего ЛПУ:"/>
					</td>
					<td style="padding:3pt" colspan="3" name="MkbSend">
						<component cmptype="UnitEdit" name="MKB_SEND" unit="MKB10" oncreate="MKB10Input(this);" composition="DEFAULT" width="80"/>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
						<component cmptype="label" caption="Уточненный диагноз направившего ЛПУ:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<!--component cmptype="Edit"	  name="MKB_SEND_HANDLE" width="100%"/-->
						<component cmptype="ButtonEdit" name="MKB_SEND_HANDLE" width="100%" buttononclick="base().selectMkbExact(this);"/>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
						<component cmptype="label" caption="Диагноз при поступлении:"/>
					</td>
					<td style="padding:3pt" colspan="3" name="Mkb10">
						<component cmptype="UnitEdit" name="MKB10" unit="MKB10" oncreate="MKB10Input(this);" composition="DEFAULT" width="80" addListener="base().countHospTimes"/>
						<img src="Images/img/move.gif" style="cursor:pointer;vertical-align:middle;" onclick="setValue('MKB10',getValue('MKB_SEND'));setCaption('MKB10',getCaption('MKB_SEND'));setValue('MKB10_HANDLE', getValue('MKB_SEND_HANDLE'));"/>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
						<component cmptype="label" caption="Уточненный диагноз при поступлении:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<!--component cmptype="Edit"	  name="MKB10_HANDLE" width="100%"/-->
						<component cmptype="ButtonEdit" name="MKB10_HANDLE" width="100%" buttononclick="base().selectMkbExact(this);"/>
					</td>
				</tr>
				<tr class="TR_MENTAL_INFO">
					<td style="padding:3pt">
						<component cmptype="Label" caption="Порядок поступления:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<component cmptype="ComboBox" name="ARRIVE_ORDER" width="100%">
							<component cmptype="ComboItem" caption="" value=""/>
							<component cmptype="ComboItem" caption="добровольное поступление" value="0"/>
							<component cmptype="ComboItem" caption="недобровольное поступление" value="1"/>
							<component cmptype="ComboItem" caption="согласия не требуется" value="2"/>
						</component>
					</td>
				</tr>
				<tr class="TR_MENTAL_INFO">
					<td style="padding:3pt">
						<component cmptype="Label" caption="Решение судьи:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<component cmptype="ComboBox" name="JUDGE_DECISION" width="100%">
							<component cmptype="ComboItem" caption="" value=""/>
							<component cmptype="ComboItem" caption="получено" value="0"/>
							<component cmptype="ComboItem" caption="отказано" value="1"/>
							<component cmptype="ComboItem" caption="не требуется" value="2"/>
							<component cmptype="ComboItem" caption="прочее" value="3"/>
						</component>
					</td>
				</tr>
				<tr class="TR_MENTAL_INFO">
					<td style="padding:3pt">
						<component cmptype="Label" caption="Откуда поступил:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<component cmptype="UnitEdit" name="HOSP_INCOME" unit="HOSP_INCOMES" composition="DEFAULT" width="100%"/>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
						<component cmptype="label" caption="Дата и время госпитализации:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<component cmptype="DateEdit" name="HOSPIT_DATE" typeMask="date" onchange="base().onChangeDate();" onblur="base().onChangeDate();" emptyMask="false" />
						<component cmptype="Edit" name="HOSPIT_HOURS" width="50" typeMask="time" emptyMask="false" readonly="true"/>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
					<component cmptype="label" caption="Врач приемного покоя:"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<component cmptype="UnitEdit" name="RECEPTION_EMP" unit="EMPLOYERS" composition="EMP_ID_FILTER_DEP" width="100%"/>
					</td>
				</tr>
				<tr cmptype="tmp"  name="ROW_GEST_PERIOD">
					<td style="padding:3pt">
						<component cmptype="Label" caption="Срок беременности (недели):"/>
					</td>
					<td style="padding:3pt" colspan="3">
						<component cmptype="Edit" name="TERM" width="80"/>
					</td>
				</tr>
			</table>
		</component>

		<component cmptype="TabSheet" caption="Направить в отделение" hide="true">
			<table width="98%">
				<tr>
					<td style="padding:3pt">
						<component cmptype="Label" caption="Отделение:"/>
					</td>
					<td style="padding:3pt">
						<component cmptype="ComboBox" name="DEPS_PAR" width="100%">
							<component cmptype="ComboItem" caption="" value=""/>
							<component cmptype="ComboItem" repeate="0" dataset="DS_DEP_PARS" captionfield="NAME" datafield="ID"/>
						</component>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt;">
						<component cmptype="Label" caption="Палата:"/>
					</td>
					<td style="padding:3pt;">
						<!--component cmptype="UnitEdit" name="DEP_BED" unit="DEP_BEDS" parent_ctrl="DEPS_PAR" composition="TREE" width="100%"/-->
						<component cmptype="ButtonEdit" width="100%" name="DEP_BED" unit="DEP_BEDS" buttononclick="base().selDepBed();" readonly="true" emptyMask="true"/>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
						<component cmptype="label" caption="Вид оплаты:"/>
					</td>
					<td style="padding:3pt">
						<component cmptype="ComboBox" name="PAYMENT_KIND" width="100%" onchange="refreshDataSet('DS_FAC_ACC');">
							<component cmptype="ComboItem" caption="" value=""/>
							<component cmptype="ComboItem" repeate="0" dataset="DS_PKS" captionfield="PK_NAME" datafield="ID"/>
						</component>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
						<component cmptype="Label" caption="Лицевой счет:"/>
					</td>
					<td style="padding:3pt">
						<component cmptype="ComboBox" name="FAC_ACC" width="100%">
							<component cmptype="ComboItem" caption="" value=""/>
							<component cmptype="ComboItem" repeate="0" dataset="DS_FAC_ACC" captionfield="AGN_NAME" datafield="ID" afterrefresh="base().reCheckFaccAcc();"/>
						</component>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt">
						<component cmptype="Label" caption="Время отправки в отделение:"/>
					</td>
					<td style="padding:3pt">
						<component cmptype="DateEdit" name="DATE_DEPARTURE" typeMask="date" emptyMask="false"/>
						<component cmptype="Edit"     name="TIME_DEPARTURE" typeMask="time" emptyMask="false" width="50"/>
						<component cmptype="MaskInspector" controls="DATE_DEPARTURE;TIME_DEPARTURE"/>
					</td>
				</tr>
				<tr>
					<td style="padding:3pt" colspan="2">
						<!--component cols="50" rows="5" style="width:98%;height:84px;" cmptype="TextArea" name="COMMENT"/-->
						<component cmptype="UnitEdit" type="FillingTextArea" style="width:100%;height:100px;" caption="Комментарий" dirdict="HOSP_COMMENTS" name="COMMENT"/><!-- size="{$field['SIZE_HEIGHT']}" unit="{$field['UNITCODE']}\"":"").(($field['SHOW_METHOD'])?" method="{$field['SHOW_METHOD']}\"":"").(($field['ADD_DIR_CODE'])?" -->
					</td>
				</tr>

			</table>
		</component>
	</component>

	<component cmptype="DataSet" name="dsLPUDICT" activateoncreate="false">
	    <![CDATA[
		select tt.*
		  from (select v.ID,
				       v.LPU_CODE||' '||v.LPU_FULLNAME ||' (' || v.LPU_NAME || ')' NAME,
					   v.LPU_CODE
				  from D_V_LPUDICT v
				 where v.VERSION = D_PKG_VERSIONS.GET_VERSION_BY_LPU(0,:pnLPU,'LPUDICT')) tt
		where lower(tt.NAME) like lower(:psCOMPLETER)
		  and ROWNUM <= 10
	    ]]>
		<component cmptype="Variable"   name="pnLPU"         src="LPU"           srctype="session"/>
		<component cmptype="Variable"   name="psCOMPLETER"   src="cmplLPU"       srctype="var" get="v1" len="100"/>
	</component>
	<component cmptype="Completer" name="cmplLPU" controls="LPUDICT" dataset="dsLPUDICT" showfield="NAME" setdata="value:id;caption:LPU_CODE" maxitems="10" minlength="2"/>

	<div style="height: 40px;">
        <div class="formBackground form_footer">
			<component cmptype="Button" name="NextButton" caption="Далее" onclick="base().checkAndSave(0);"/>
			<component cmptype="Button" name="BackButton" caption="Назад" style="display:none;" onclick="base().onBackButtonClick();"/>
			<component cmptype="Button" name="OkButton" caption="ОК" onclick="base().checkAndSave(1);"/>
			<component cmptype="Button" name="CancelButton" caption="Отмена" onclick="base().onCancelButtonClick();"/>
			<component cmptype="SubForm" path="footerStyle"/>
        </div>
    </div>

	<style>
		.invalid_hh_number input {
			background-color: red !important;
		}
	</style>
</div>
