<div cmptype="TMP" oncreate="base().OnCreateNapr();" onshow="base().OnShowNapr();" window_size="900x550">
<!-- Окно может работать как SubForm, так и в качестве модального окна
Общие переменные:
setVar('HH_ID' 
setVar('PMC_ID'
setVar('DISEASECASE'
Модальный режим:
setVar('DIR_SERV_CONTROL_MODAL_MODE', 1);
setVar('HH_DEP'
setVar('EMPLOYER_ID' - текущий врач
TYPE-пусто или RELATIVE- ИБ или ИБ сопровождающего
Немодальный режим:
setVar('PMC_FIO'
-->
<div cmptype="title">Направления пациента</div>
<component cmptype="SubForm" path="Visit/PrintVisit"/>
<component cmptype="Script">
	Form.OnCreateNapr = function()
	{
		if(getVar('DIR_SERV_CONTROL_MODAL_MODE') != 1)
		{
		    	setVar('HH_ID', getVar('HH_ID', 1));
			setVar('PMC_ID', getVar('PMC_ID', 1));
			setVar('PMC_FIO', getVar('PMC_FIO', 1));
			setVar('DISEASECASE', getVar('DISEASECASE', 1));
			setVar('PAYMENT_KIND_ID', getVar('PAYMENT_KIND_ID', 1));
			executeAction('GET_DEF_PARAMS',null,null,null,0,0); //посчитали HH_DEP
		}
	}	
	Form.OnShowNapr = function()
	{
		if(getVar('DIR_SERV_CONTROL_MODAL_MODE') != 1)
		{
			setWindowCaption('Направления пациента: '+getVar('PMC_FIO')+((!empty(getVar('HH_NUMB')))?((getVar('HH_NUMB') == -1) ?', ИБ направлена на аннулирование' : ', номер ИБ: '+getVar('HH_NUMB')):', ИБ не создана'));
			refreshDataSet('DS_DIRECTION_SERVICE_CONTROL');
		}

		PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDUserProc',true);
		PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pUserProcSep',true);
	}
	Form.cancelVisit = function()
	{
            setVar('SYS_VISIT_ID', getControlProperty('DIRECTION_SERVICE_CONTROL_GRID','data')['VISIT_ID']);
            if(empty(getVar('SYS_VISIT_ID')))
            {
                    alert('Услуга не оказана. Отмена невозможна');
                    return;
            }
            executeAction('cancelVisit', function(){refreshDataSet('DS_DIRECTION_SERVICE_CONTROL')});
	}	
	Form.AddResult = function()
	{
		openWindow('Directions/direction_service_by_types_for_dop',true, 670, 170)
			.addListener('onclose',
    			 function (){if (getVar('ModalResult', 2) == 'ok') {
						  setVar('DIR_SERV_FOR_DEL', getVar('DIR_SERVICE', 2), 2);
						  executeAction('DEL_ALL_NAZN',null, null, null, 0, 2);
    			 		  refreshDataSet('DS_DIRECTION_SERVICE_CONTROL', true, 2);
    			 		  if(!empty(getVar('TesT',2)))
	    			 		  {
	    			 		  	refreshDataSet('DS_AMB_TAL_VIS_N_SERVS', true, 2);
	    			 		  }
    			 		  }
    			 },
    			 null,
    			 false);
	}
	Form.optionPopupDirectionDSS = function()
	{
		setVar('SERVICE_ID_FOR', getControlProperty('DIRECTION_SERVICE_CONTROL_GRID','data')['SERVICE_ID']);
		var dir_serv = getControlProperty('DIRECTION_SERVICE_CONTROL_GRID','data');
		setVar('EMPLOYER_TO',dir_serv['EMPLOYER_TO']);
		setVar('CABLAB_TO',dir_serv['CABLAB_TO']);
		setVar('SERVICE_CODE',dir_serv['SERVICE_CODE']);
		setVar('DIR_SERV_PID',dir_serv['DIRECTION']);
		setVar('DIR_SERV_ID_FOR_CHECK',dir_serv['DIRECTION_SERVICE']);
                executeAction('CheckRightsForServices',null,null,null,0,0);
		if (!empty(getVar('HID_DIR_SERV')) || (!empty(getVar('DIR_SERVICE', 1))))
		{
			PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REF',false);
			PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_INS',true);
			PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REP',true);
			PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DEL',true);
			PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DELETE',true);
			PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDIR_SERV',false);
		}
		else 
		{ 
                    if(!empty(getValue('DIRECTION_SERVICE_CONTROL_GRID')))
                    {
			if(dir_serv['SIGN_FOR_POPUP'] == '1')
			{	
				if(dir_serv['STATUS_CODE']=='N') //назначен
				{
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REF',false);
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_INS',true);
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REP',true);
									PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDIR_SERV',false);

                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DELETE',false);
                                    if (getVar('R_CANCEL') &gt; 0)
                                    {
                                        PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DEL',false);
                                    }
                                    else
                                    {
                                        PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DEL',true);
                                    }
                                    setVar('THIS_SERVICE_ID', dir_serv['SERVICE_ID']);
				}
				else if(dir_serv['STATUS_CODE']=='Z') //записан
				{
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REF',false);
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_INS',true);
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REP',true);
									PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDIR_SERV',false);
                                    if (getVar('R_CANCEL') &gt; 0)
                                    {
                                        PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DEL',false);
                                    }
                                    else
                                    {
                                        PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DEL',true);
                                    }
				}
				else if(dir_serv['STATUS_CODE']=='O') //оказана
				{
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REF',false);
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_INS',true);
                                    if (getVar('R_VIEW_RES') &gt; 0)
                                    {
                                        PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REP',false);
	                                PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDIR_SERV',false);
                                    }
                                    else
                                    {
                                        PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REP',true);
	                                PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDIR_SERV',true);
                                    }

                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DEL',true);
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DELETE',true);
				}
				else if(dir_serv['STATUS_CODE']=='C') //отменена
				{
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REF',false);
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REP',true);
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_INS',true);
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DEL',true);
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DELETE',false);
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDIR_SERV',false);
				}
			}
			else if(dir_serv['SIGN_FOR_POPUP'] == '2')				
			{	
                            if(dir_serv['STATUS_CODE']=='N')
                            {
                                PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REF',false);
                                PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REP',true);
                                PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_INS',false);
	                            PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDIR_SERV',false);
                                PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DELETE',false);

                                if (getVar('R_CANCEL') &gt; 0)
                                {
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DEL',false);
                                }
                                else
                                {
                                     PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DEL',true);
                                }
                            }
                            else if(dir_serv['STATUS_CODE']=='C')
                            {
                                PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REF',false);
                                PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_INS',true);
                                PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REP',true);
                                PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DEL',true);
                                PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DELETE',true);
	                            PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDIR_SERV',false);
                            }
                            else
                            {
                                PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REF',false);
                                PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_INS',true);
	                            PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDIR_SERV',false);
                                if (getVar('R_VIEW_RES') &gt; 0)
                                {
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REP',false);
                                }
                                else
                                {
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REP',true);
                                }
                                if (getVar('R_CANCEL') &gt; 0)
                                {
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DEL',false);
                                }
                                else
                                {
                                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DEL',true);
                                }
                                PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DELETE',true);
                            }
			}
            executeAction('isShowDirServReport',null,null,null,0,0);
                if(getVar('IS_SHOW') == 1)
                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDIR_SERV',false);		
                else
                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDIR_SERV',true);
		}	
		else
		{
                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REF',false);
                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_INS',true);
                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_REP',true);
                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DEL',true);
                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_DELETE',true);
                    PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDIR_SERV',false);
		}
            }
	}
	Form.GetCabLab = function()
	{
		if((empty(getVar('EMPLOYER_TO')) &amp;&amp; getVar('CABLAB_NUM') &gt;= 1) || (getVar('CABLAB_NUM') &gt;= 1 &amp;&amp; getVar('EMPLOYER_TO')==getVar('EMPLOYER_ID')))
		{
			PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_VIS',false);
		}
	}
	Form.AfterCheckService = function()
	{
		if(getVar('CHECK_DOC') == 1)
		{
			PopUpItem_SetHide(getControlByName('pDSS_CONTROL'),'pDSS_VIS',false);
		}
	}


	//переделка
	Form.DIRECTION_SERVICE_CONTROL_DIRECTION = function()
	{
		openWindow('HospPlan/Dirs/select_lpu_services', true,1000,520)
			.addListener('onafterclose',function ()
					{
    						if (getVar('ModalResult') == 1) 
						  	refreshDataSet('DS_DIRECTION_SERVICE_CONTROL');
    				 	});
	}	


 Form.expressRegister=function() 
        {
                openWindow('Labmed/labmed_analize_new', true,1100,768)
                .addListener('onafterclose',function()
                {
                        if (getVar('ModalResult')==1)
                        {
                                refreshDataSet('patjour');
                        }
                },
                null,
                false);
        }



	Form.DIRECTION_SERVICE_CONTROL_BY_TEMPLATE = function()
	{
		openWindow('HospPlan/Dirs/select_template', true)
		.addListener('onclose',
    				 function (){
    					if (getVar('ModalResultSelTimeMain', 3) == 1) {
						  refreshDataSet('DS_DIRECTION_SERVICE_CONTROL',true,3);
    					}
						else if(getVar('ModalResultSelTimeMain', 2) == 1)
						{
							refreshDataSet('DS_DIRECTION_SERVICE_CONTROL',true,2);
						}
						else if(getVar('ModalResultSelTimeMainNasn', 1) == 1)
						{
							refreshDataSet('DS_DIRECTION_SERVICE_CONTROL',true,1);
						}
    				 },
    				 null,
    				 false);
	}	
	Form.CreateNewDirection=function()
	{
		executeAction('CREATE_NEW_DIRECTION',function(){refreshDataSet('DS_DIRECTION_SERVICE_CONTROL');},null,null);
	}	
	Form.DSS_CANCEL=function()
	{	
		var data = getControlByName('DIRECTION_SERVICE_CONTROL_GRID').data;
		setVar('DS_ID', getValue('DIRECTION_SERVICE_CONTROL_GRID'));
		if(data['SERV_STATUS'] == 1)
		{
			 alert('Услуга оказана. Отмена невозможна.');
		}
		else if(data['SERV_STATUS'] == 2)
		{
			alert('Услуга уже отменена.');
		}
		else
		{
			openWindow('Directions/direction_cancel', true).addListener('onclose',
			           function()
			           {
				           if (getVar('ModalResult', 1))
				           {
					           refreshDataSet('DS_DIRECTION_SERVICE_CONTROL', 0, 1);
				           }
			           });
		}
	}	
	Form.DSS_DELETE=function()
	{	
		executeAction('DIR_DIR_SERV_DELETE',function(){refreshDataSet('DS_DIRECTION_SERVICE_CONTROL');},null,null);
	}	
	//обратка кнопок нового расписания GenRegistry
	<![CDATA[
		Form.genClschs = function(_mode,_set_service,_after_action) {
			//_mode - reg_full, reg_oper_room, reg_lpu_ds
			setVar('PERSMEDCARD_ID', getVar('PMC_ID'));
			setVar('PARAM_VISIT', null);
			setVar('HH_DEP_ID', getVar('HH_DEP'));
			setVar('PARAM_DISEASECASE', getVar('DISEASECASE'));
			_window = 'GenRegistry/'+_mode;
			openWindow({name: _window,
					vars: {
						MODE: 'close'
					}},true)
						.addListener('onafterclose', function(){
							//if(getVar('ModalResult') == 1) {
								refreshDataSet('DS_DIRECTION_SERVICE_CONTROL');
							//}
						});
		}
		Form.onStatusClickGenClschs = function() {
			var dir_serv = getControlProperty('DIRECTION_SERVICE_CONTROL_GRID','data');
			if(dir_serv['SIGN_FOR_POPUP'] == '1' || dir_serv['SIGN_FOR_POPUP'] == '2') {
				if(dir_serv['STATUS_CODE']=='N' || dir_serv['STATUS_CODE']=='T') { //назначен (либо не определилось время операции)
					base().genClschsPrescr();
				} else if(dir_serv['STATUS_CODE']=='Z') { //записан
					base().genClschsReselect();
				} else if(dir_serv['STATUS_CODE']=='O') { //оказана
					base().REPORT_PRINT_P();
				}
			}
		}
		Form.genClschsPrescr = function() {
			openWindow({name: 'GenRegistry/reg_full',
					vars: {
						MODE: 'close',
						SERV_ID: getControlProperty('DIRECTION_SERVICE_CONTROL_GRID','data')['SERVICE_ID'],
						EMP_ID: getControlProperty('DIRECTION_SERVICE_CONTROL_GRID','data')['EMPLOYER_TO'],
						DIRECTION_SERVICE: getValue('DIRECTION_SERVICE_CONTROL_GRID')
					}},true)
						.addListener('onafterclose', function(){
							//if(getVar('ModalResult') == 1) {
								if(!empty(getValue('DIRECTION_SERVICE_CONTROL_GRID'))) {
									setControlProperty('DIRECTION_SERVICE_CONTROL_GRID','locate',getValue('DIRECTION_SERVICE_CONTROL_GRID'));
								}
								refreshDataSet('DS_DIRECTION_SERVICE_CONTROL');
							//}
						});
		}
		Form.genClschsReselect = function() {
			setVar('DS_ID', getValue('DIRECTION_SERVICE_CONTROL_GRID'));
			var data = getControlByName('DIRECTION_SERVICE_CONTROL_GRID').data;
			if(data['SERV_STATUS'] == 1) {
				alert('Услуга оказана. Перезапись невозможна.');
				return;
			}
			executeAction('getParamsForSelectTime', function() {
				openWindow({name:'GenRegistry/reg_select_time_full',
					vars: {
						DIR_REG_TYPE:  getVar('RST_DIR_REG_TYPE'),
						TIME_TYPE:     data['TIME_TYPE'],
						SOURCE_ID:     getVar('RST_SOURCE_ID'),
						SOURCE_TYPE:   getVar('RST_SOURCE_TYPE'),
						HAS_OWN_SCHED: getVar('RST_HAS_OWN_SCHED'),
						CAB_ID:        getVar('RST_CAB_ID'),
						DS_DATE:       getVar('RST_DS_DATE'),
						MODE:          'select_time'
					}},true)
						.addListener('onafterclose', function(){
							if(getVar('ModalResult') == 1) {
								executeAction('setSelectedTimeDirServ', function() {
									setVar('RST_DIR_REG_TYPE', null);
									setVar('RST_SOURCE_ID', null);
									setVar('RST_SOURCE_TYPE', null);
									setVar('RST_CAB_ID', null);
									setVar('RST_DS_DATE', null);
									setVar('RST_HAS_OWN_SCHED', null);
									setVar('returnDS_REC_DATE', null);
									setVar('returnIS_CITO', null);
									setVar('returnDURATION', null);
									setVar('returnNORDER', null);
									setVar('returnREC_TYPE', null);
									if(!empty(getVar('DS_ID'))) {
										setControlProperty('DIRECTION_SERVICE_CONTROL_GRID','locate',getVar('DS_ID'));
									}
									refreshDataSet('DS_DIRECTION_SERVICE_CONTROL');
								});
							}
						});
			});
		}
	]]>
	//обработка кнопок нового расписания GenRegistry конец
	Form.DIR_SERV_OPEN_REG_CREATE = function()
	{
	    setVar('Modalresult',0);
            setVar('SERV_ID',null);
            setVar('PARAM_VISIT_ID', null);
            setVar('PARAM_DISEASECASE_ID', getVar('DISEASECASE'));
	    setVar('PARAM_HH_DEP', getVar('HH_DEP'));
	    setVar('PARAM_REG_TYPE', 1);
            setVar('PERSMEDCARD_ID', getVar('PMC_ID'));
            setVar('CONTRACT_CODE', null);
            setVar('CONTRACT_ID', null);
            setVar('CONTR_AMI_DIR_CODE', null);
            setVar('CONTR_AMI_DIR_ID', null);
            executeAction('getDefDepFromOption',function()
                            {
                                    openWindow('Registry/reg_short',true,1000,800)
					.addListener('onafterclose',function ()
						{
							if(getVar('ModalResult') == 1)
								refreshDataSet('DS_DIRECTION_SERVICE_CONTROL');
						});
                            });
	}	
	Form.DIRECTION_SERVICE_CONTROL_REGISTRATION = function()
	{
            setVar('DIR_SERVICE_FOR_UPDATE', getValue('DIRECTION_SERVICE_CONTROL_GRID'));
            setVar('SERV_ID', getControlProperty('DIRECTION_SERVICE_CONTROL_GRID','data')['SERVICE_ID']);
            setVar('PERSMEDCARD_ID', getVar('PATIENT'));
            setVar('PARAM_REG_TYPE',2);
	    openWindow('Registry/reg_prescr',true,1000,800)
			.addListener('onafterclose',function ()
				{
					if(getVar('ModalResult') == 1)
						refreshDataSet('DS_DIRECTION_SERVICE_CONTROL');
				});
	}
	Form.SuccessfulOpen = function(_jump)
	{
            alert('works='+getPage().form.name);
            refreshDataSet('DS_DIRECTION_SERVICE_CONTROL',true,_jump);
	}	
	Form.refreshDataAfterVisit = function()
	{
            refreshDataSet('DS_DIRECTION_SERVICE_CONTROL',true,1);
            if(!empty(getVar('TesT',1)))
	    {	    			 		  	
	    	refreshDataSet('DS_AMB_TAL_VIS_N_SERVS', true, 1);
	    } 
	}	
	Form.DIRECTION_SERVICE_CONTROL_VISIT = function(_param) 
	{
		//if(empty(getVar('VISIT'))) { alert('Сохраните посещение перед внесением результата!'); return;}
		setVar('SERVICE_ID_FOR', getControlProperty('DIRECTION_SERVICE_CONTROL_GRID','data')['SERVICE_ID']);
		var dir_serv = getControlProperty('DIRECTION_SERVICE_CONTROL_GRID','data');
		setVar('EMPLOYER_TO',dir_serv['EMPLOYER_TO']);
		setVar('CABLAB_TO',dir_serv['CABLAB_TO']);
		setVar('SERVICE_CODE',dir_serv['SERVICE_CODE']);
		setVar('DIR_SERV_PID',dir_serv['DIRECTION']);
		setVar('DIR_SERV_ID_FOR_CHECK',dir_serv['DIRECTION_SERVICE']);
		startActionsGroup();
                    executeAction('CheckRightsForServices',null,null,null,0,0);
                    executeAction('GetTemplateId',null,null,null,0,0);
		endActionsGroup();
		if (!empty(getVar('HID_DIR_SERV')) || (!empty(getVar('DIR_SERVICE', 1))))return;
		if(_param!=1 &amp;&amp;_param!=0)return;
		if(dir_serv['SIGN_FOR_POPUP'] != '1' &amp;&amp; dir_serv['SIGN_FOR_POPUP'] != '2')return;

		if(_param == 1)
		{
			if(dir_serv['SIGN_FOR_POPUP'] == '1')
			{
				if(dir_serv['STATUS_CODE']=='N') //назначен
					return;
				else if(dir_serv['STATUS_CODE']=='Z') //записан
					return;
				else if(dir_serv['STATUS_CODE']=='O') //оказана
				{
					if (dir_serv['FLAG_CHECK_ID'] == 1 &amp;&amp; getVar('R_EDIT_OWN') &gt; 0){}
					else if (dir_serv['FLAG_CHECK_ID'] == 0 &amp;&amp; getVar('R_EDIT_ANY') &gt; 0){}
					else
						return;
				}
				else
					return;
			}
			else if(dir_serv['SIGN_FOR_POPUP'] == '2')
			{
				if(dir_serv['STATUS_CODE']=='N')
					return;
				else if(dir_serv['STATUS_CODE']=='Z') //записан
					return;
				else if(dir_serv['STATUS_CODE']=='C')
					return;
				else
				{
					if (getVar('FLAG_CHECK_ID') == 1 &amp;&amp; getVar('R_EDIT_OWN') &gt; 0){}
					else if (getVar('FLAG_CHECK_ID') == 0 &amp;&amp; getVar('R_EDIT_ANY') &gt; 0){}
					else
						return;
				}
			}
		}
		else if(_param == 0)
		{
			if(dir_serv['SIGN_FOR_POPUP'] == '1')
			{	
				if(dir_serv['STATUS_CODE']!='N'&amp;&amp;dir_serv['STATUS_CODE']!='Z')return;
                                if(dir_serv['STATUS_CODE']=='N') //назначен
				{
					setVar('THIS_SERVICE_ID', dir_serv['SERVICE_ID']);
					executeAction('checkRightsDoc',null,null,null,0,0);
					if(getVar('CHECK_DOC') != 1)
					{
						alert('Нет прав для оказания данной услуги!');
						return;
					}
				}
				else if(dir_serv['STATUS_CODE']=='Z') //записан
				{
                                        if(getVar('EMPLOYER_TO')==getVar('EMPLOYER_ID') &amp;&amp; empty(getVar('CABLAB_TO')))
					{
					}
					else if(!empty(getVar('CABLAB_TO')))
					{
                                                executeAction('GET_CABLAB', null,null,null,0,0);
						if(getVar('CABLAB_NUM') &gt;= 1)
						{
                                                        if(getVar('EMPLOYER_TO')!=getVar('EMPLOYER_ID') &amp;&amp; !empty(getVar('EMPLOYER_TO')))
                                                        {
                                                            if(!confirm('Пациент записан к врачу '+dir_serv['VISIT_EMPLOYER']+' Продолжить?'))
                                                            {
                                                                return;
                                                            }
                                                        }
						}
                                                else if(!confirm('Кабинет назначения не соответствует кабинету оказания! Продолжить?'))
                                                {
                                                        return;
                                                }
					}
					else
					{
						alert('Нет прав для оказания данной услуги!');
						return;
					}
				}
			}
			else if(dir_serv['SIGN_FOR_POPUP'] == '2')
			{
				if(dir_serv['STATUS_CODE']!='N' &amp;&amp; dir_serv['STATUS_CODE']!='Z') return;

                                setVar('THIS_SERVICE_ID', dir_serv['SERVICE_ID']);
                                executeAction('checkRightsDoc',null,null,null,0,0);
                                if(getVar('CHECK_DOC') != 1)
                                {
                                        alert('Нет прав для оказания данной услуги!');
                                        return;
                                }
                                if(dir_serv['STATUS_CODE']=='Z') //записан
                                {
                                        if(getVar('EMPLOYER_TO')==getVar('EMPLOYER_ID') &amp;&amp; empty(getVar('CABLAB_TO')))
                                        {

                                        }
                                        else if(!empty(getVar('CABLAB_TO')))
                                        {
                                                executeAction('GET_CABLAB', null,null,null,0,0);
                                                if(getVar('CABLAB_NUM') &gt;= 1)
                                                {
                                                        if(getVar('EMPLOYER_TO')!=getVar('EMPLOYER_ID') &amp;&amp; !empty(getVar('EMPLOYER_TO')))
                                                        {
                                                            if(!confirm('Пациент записан к врачу '+dir_serv['VISIT_EMPLOYER']+' Продолжить?'))
                                                            {
                                                                return;
                                                            }
                                                        }
                                                }
                                                else if(!confirm('Кабинет назначения не соответствует кабинету оказания! Продолжить?'))
                                                {
                                                        return;
                                                }
                                        }
                                        else
                                        {
                                                alert('Нет прав для оказания данной услуги!');
                                                return;
                                        }
                                }
			}
		}

		setVar('SYS_DIR_SERVICE', getValue('DIRECTION_SERVICE_CONTROL_GRID'));
		setVar('SERVICE_CODE', getControlProperty('DIRECTION_SERVICE_CONTROL_GRID','data')['SERVICE_CODE']);
		openWindow({name:'UniversalTemplate/UniversalTemplate',template_id:getVar('TEMPLATE_ID'),service:getVar('SERVICE_CODE')}, true, 890,725)
			.addListener('onclose', function ()
				{
                                      refreshDataSet('DS_DIRECTION_SERVICE_CONTROL',true,1);
    			 	});
    }
    Form.REPORT_PRINT_P = function ()
    {
    	var visit_id = getControlProperty('DIRECTION_SERVICE_CONTROL_GRID','data')['VISIT_ID'];
		getPage().setVar('AGENT_ID', getControlProperty('DIRECTION_SERVICE_CONTROL_GRID', 'data')['PAT_AGENT_ID']);
        Form.PrintVisit(visit_id);
    }	
    Form.ChangeReg = function()
    {
            setVar('DS_ID', getValue('DIRECTION_SERVICE_CONTROL_GRID'));
            var data = getControlByName('DIRECTION_SERVICE_CONTROL_GRID').data;

            var params = {REG_TYPE: data['REC_TYPE']};
            params.CAB_ID = data['CABLAB_TO'];
            if(params.REG_TYPE == 0||params.REG_TYPE == 2)
              	params.EMP_ID = data['EMPLOYER_TO'];
            else if(params.REG_TYPE == 1||params.REG_TYPE == 3)
              	params.SERV_ID = data['SERVICE_ID'];
            else if(params.REG_TYPE == 4)
              	params.EMPL_ID = data['EMPLOYER_TO'];
            else if(params.REG_TYPE == 5)
              	params.SERVS_ID = data['SERVICE_ID'];
            setVar('SEL_DATA', params);
            setVar('REG_DATE', data['REC_DATE']);
            setVar('CONTRACT_CODE', null);
            setVar('CONTRACT_ID', null);
            setVar('CONTR_AMI_DIR_CODE', null);
            setVar('CONTR_AMI_DIR_ID', null);
            setValue('REG_TIME_TYPE', data['TIME_TYPE']);
            if(data['SERV_STATUS'] == 1)
                  alert('Услуга оказана. Перезапись невозможна.');
            else
            {
                 openWindow('Registry/reg_select_time_short', true, 1000, 720)
			     .addListener('onafterclose', function()
					{
						if (getVar('ModalResult') == 1)
						{
							setVar('REC_TIME_NEW', getVar('SelectedTime'));
							setVar('IS_CITO_NEW',  getVar('trRecordType'));
							executeAction('CHANGE_TIME', function(){
								refreshDataSet('DS_DIRECTION_SERVICE_CONTROL');
							      });
						}
					});
            }
    }
    Form.REG_REWRITE = function()
    {
            var dir_serv = getControlProperty('DIRECTION_SERVICE_CONTROL_GRID','data');
            if(dir_serv['SIGN_FOR_POPUP'] == '1' || dir_serv['SIGN_FOR_POPUP'] == '2')
            {
                    if(dir_serv['STATUS_CODE']=='N' || dir_serv['STATUS_CODE']=='T') //назначен (либо не определилось время операции)
                    {
                            base().DIRECTION_SERVICE_CONTROL_REGISTRATION();
                    }
                    else if(dir_serv['STATUS_CODE']=='Z') //записан
                    {
                            base().ChangeReg();
                    }
                    else if(dir_serv['STATUS_CODE']=='O') //оказана
                    {
                            base().REPORT_PRINT_P();
                    }
            }
    }
    Form.REG_REWRonFocus=function (_domObject)
    {
            $$(_domObject);
                    _setHint(_domObject, getControlValue(_domObject));
            _$$();
    }
    Form.DIR_SERV_CONTROL_OnClone = function(_dom, _dataArray)
    {
            var _domLink = getControlByName('IN_BUT');
            var _domImg  = getControlByName('vis_img');
            if(_dataArray['SIGN_FOR_POPUP'] == '1')
            {
                    if(_dataArray['STATUS_CODE']=='N') //назначен
                    {
                            _domLink.style.display='';
                            _domImg.style.display='none';
                    }
                    else if(_dataArray['STATUS_CODE']=='Z') //записан
                    {
                            _domLink.style.display='';
                            _domImg.style.display='none';
                    }
                    else if(_dataArray['STATUS_CODE']=='O') //оказана
                    {
                            _domLink.style.display='none';
                            _domImg.style.display='';
                    }
                    else
                    {
                            _domImg.style.display='none';
                            _domLink.style.display='none';
                    }
            }
            else if(_dataArray['SIGN_FOR_POPUP'] == '2')
            {
                    if(_dataArray['STATUS_CODE']=='O') //оказана
                    {
                            _domLink.style.display='none';
                            _domImg.style.display='';
                    }
                    else if(_dataArray['STATUS_CODE']=='N') //назначен
                    {
                            _domLink.style.display='';
                            _domImg.style.display='none';
                    }
                    else if(_dataArray['STATUS_CODE']=='Z') //записан
                    {
                            _domLink.style.display='';
                            _domImg.style.display='none';
                    }
                    else
                    {
                            _domImg.style.display='none';
                            _domLink.style.display='none';
                    }
            }
    }
    Form.UserProcsDSOpen=function()
    {
            setVar('UNITCODE', 'DIRECTION_SERVICES');
                                    setVar('PRIMARY',getValue('DIRECTION_SERVICE_CONTROL_GRID'));
                                    openWindow('UnitPopupItems/user_procs', true, 1000,600)
                                            .addListener('onclose',
                                                                     function (){
                                                                            setVar('PRIMARY', null, 1);
                                                                            setVar('UNITCODE', null, 1);
                                                                     },null,false);
    }
    Form.afterExecProc=function(){
            refreshDataSet('DS_DIRECTION_SERVICE_CONTROL');
    }
    Form.SHOW_EMP_SERVICES=function()
    {
            openWindow('HospPlan/Dirs/select_emp_services',true)
                    .addListener('onclose',function()
			{
				if(getVar('closekind', 2) == 1)
					refreshDataSet('DS_DIRECTION_SERVICE_CONTROL',true,2);
                           	else
                                	refreshDataSet('DS_DIRECTION_SERVICE_CONTROL',true,1);
                        });
    }
</component>
	<component cmptype="Action" name="setSelectedTimeDirServ">
		<![CDATA[
		declare
			nLPU              NUMBER(17);
			nHID              NUMBER(17);
			nIS_COMBINED      NUMBER(1);
			nIS_NECESSARY     NUMBER(1);
			nSERVICE          NUMBER(17);
			nEMPLOYER_TO      NUMBER(17);
			nCABLAB_TO        NUMBER(17);
			nVISIT_PURPOSE    NUMBER(17);
			nREF_KIND         NUMBER(17);
			nVISIT_KIND       NUMBER(17);
			nDISEASECASE      NUMBER(17);
			nSERV_STATUS      NUMBER(2);
			nIS_PRIMARY       NUMBER(2);
			sNOTE             VARCHAR2(4000);
			nHH_DEP           NUMBER(17);
			nSEANCE_NUMB      NUMBER(19,2);
			nLPU_SERVICE      NUMBER(17);
		begin
			select t.LPU,
			       t.HID,
			       t.IS_COMBINED_PAYMENT,
			       t.IS_NECESSARY,
			       t.SERVICE_ID,
			       t.EMPLOYER_TO,
			       t.CABLAB_TO_ID,
			       t.VISIT_PURPOSE_ID,
			       t.REF_KIND_ID,
			       t.VISIT_KIND_ID,
			       t.DISEASECASE,
			       t.SERV_STATUS,
			       t.IS_PRIMARY,
			       t.S_COMMNET,
			       t.HH_DEP,
			       t.SER_COUNT,
			       t.LPU_SERVICE_ID
			  into nLPU,
			       nHID,
			       nIS_COMBINED,
			       nIS_NECESSARY,
			       nSERVICE,
			       nEMPLOYER_TO,
			       nCABLAB_TO,
			       nVISIT_PURPOSE,
			       nREF_KIND,
			       nVISIT_KIND,
			       nDISEASECASE,
			       nSERV_STATUS,
			       nIS_PRIMARY,
			       sNOTE,
			       nHH_DEP,
			       nSEANCE_NUMB,
			       nLPU_SERVICE
			  from D_V_DIRECTION_SERVICES t
			 where t.ID = :DS_ID;
			D_PKG_DIRECTION_SERVICES.UPD(pnID     => :DS_ID,
					pnLPU                 => nLPU,
					pnHID                 => nHID,
					pnIS_COMBINED_PAYMENT => nIS_COMBINED,
					pnIS_NECESSARY        => nIS_NECESSARY,
					pnSERVICE             => nSERVICE,
					pnEMPLOYER_TO         => nEMPLOYER_TO,
					pnCABLAB_TO           => nCABLAB_TO,
					pdREC_DATE            => to_date(:DS_REC_DATE,'dd.mm.yyyy hh24:mi'),
					pnVISIT_PURPOSE       => nVISIT_PURPOSE,
					pnREF_KIND            => nREF_KIND,
					pnVISIT_KIND          => nVISIT_KIND,
					pnDISEASECASE         => nDISEASECASE,
					pnREG_TYPE            => 1-:IS_CITO,
					pnSERV_STATUS         => nSERV_STATUS,
					pnIS_PRIMARY          => nIS_PRIMARY,
					psS_COMMNET           => sNOTE,
					pnHH_DEP              => nHH_DEP,
					pnREC_TYPE            => :DS_REC_TYPE,
					pnSER_COUNT           => nSEANCE_NUMB,
					pnLPU_SERVICE         => nLPU_SERVICE,
					pnREC_DURATION        => :DURATION,
					pnTICKET_N            => :NORDER,
					psTICKET_S            => null);
		end;
		]]>
		<component cmptype="ActionVar" name="DS_ID"       src="DS_ID"             srctype="var"  get="v1"/>
		<component cmptype="ActionVar" name="DS_REC_DATE" src="returnDS_REC_DATE" srctype="var"  get="v2"/>
		<component cmptype="ActionVar" name="IS_CITO"     src="returnIS_CITO"     srctype="var"  get="v3"/>
		<component cmptype="ActionVar" name="DS_REC_TYPE" src="returnREC_TYPE"    srctype="var"  get="v4"/>
		<component cmptype="ActionVar" name="DURATION"    src="returnDURATION"    srctype="var"  get="v5"/>
		<component cmptype="ActionVar" name="NORDER"      src="returnNORDER"      srctype="var"  get="v6"/>
	</component>
	<component cmptype="Action" name="getParamsForSelectTime">
		<![CDATA[
		begin
			:SOURCE_ID := null;
			select decode(t.REC_TYPE,0,t.EMPLOYER_TO,1,t.SERVICE_ID,2,t.EMPLOYER_TO,3,t.SERVICE_ID,null),
			       to_char(t.REC_DATE,'dd.mm.yyyy'),
			       t.REC_TYPE,
			       t.CABLAB_TO_ID,
			       t2.REG_TYPE
			  into :SOURCE_ID,
			       :DS_DATE,
			       :SOURCE_TYPE,
			       :CAB_ID,
			       :DIR_REG_TYPE
			  from D_V_DIRECTION_SERVICES t,
			       D_V_DIRECTIONS t2
			 where t.ID  = :DS_ID
			   and t.PID = t2.ID;
			if :SOURCE_ID is not null and :SOURCE_TYPE in (0,2) then
				select t.HAS_OWN_SCH
				  into :HAS_OWN_SCHED
				  from D_V_CLEMPS t
				 where t.PID         = :CAB_ID
				   and t.EMPLOYER_ID = :SOURCE_ID
				   and (t.WORK_TO is null or t.WORK_TO > :DS_DATE);
			elsif :SOURCE_ID is not null and :SOURCE_TYPE in (1,3) then
				select t.HAS_OWN_SCH
				  into :HAS_OWN_SCHED
				  from D_V_CLSERVS t
				 where t.PID         = :CAB_ID
				   and t.SERVICE_ID  = :SOURCE_ID;
			else
				:HAS_OWN_SCHED := 1;
			end if;
		end;
		]]>
		<component cmptype="ActionVar" name="LPU"            src="LPU"               srctype="session"/>
		<component cmptype="ActionVar" name="DS_ID"          src="DS_ID"             srctype="var"  get="v1"/>
		<component cmptype="ActionVar" name="DIR_REG_TYPE"   src="RST_DIR_REG_TYPE"  srctype="var"  put="v2"  len="2"/>
		<component cmptype="ActionVar" name="SOURCE_ID"      src="RST_SOURCE_ID"     srctype="var"  put="v3"  len="17"/>
		<component cmptype="ActionVar" name="SOURCE_TYPE"    src="RST_SOURCE_TYPE"   srctype="var"  put="v4"  len="2"/>
		<component cmptype="ActionVar" name="CAB_ID"         src="RST_CAB_ID"        srctype="var"  put="v5"  len="17"/>
		<component cmptype="ActionVar" name="DS_DATE"        src="RST_DS_DATE"       srctype="var"  put="v6"  len="20"/>
		<component cmptype="ActionVar" name="HAS_OWN_SCHED"  src="RST_HAS_OWN_SCHED" srctype="var"  put="v7"  len="2"/>
	</component>
	<component cmptype="Action" name="getDefDepFromOption">
		begin
			:DP_NAME := d_pkg_option_specs.get('SchRegDepDefault', :LPU);
		end;
		<component cmptype="ActionVar" name="LPU" src="LPU" srctype="session"/>
		<component cmptype="ActionVar" name="DP_NAME" src="DP_NAME_FOR_REG_SHORT" srctype="var" put="DPN" len="1000"/>
	</component>
	<component cmptype="Action" name="getParamsForRegWrite">
		declare PK_ID NUMBER(17);
				DSP_ID NUMBER(17);
		begin
			begin
				PK_ID := d_pkg_direction_services.get_payment_kind(pnlpu => :LPU,
										   pndss => :DIR_SERVICE,
										   pssign_unpaid => 1,
										   pnres_type => 0);
				IF PK_ID is not null THEN
				begin
					select t.ID
					into DSP_ID
					from d_v_dir_serv_payments t
					where t.PID = :DIR_SERVICE
						and t.PAYMENT_KIND_ID = PK_ID;
					exception when no_data_found then
						DSP_ID := null;
				end;
				END IF;
			end;
			begin
				select c.DOC_PREF||'/'||c.DOC_NUMB,
					cad.DIR_FULL_NAME,
					cp.AMI_DIRECTION,
					cp.PID
				into  :CONTR_NAME,
					  :DIR_NAME,
					  :DIR_ID,
					  :CONTR_ID
				from
				d_v_dir_serv_payments dsp,
				d_v_contracts c,
				d_v_contract_payments cp,
				d_v_contr_ami_directs cad
				where dsp.ID = DSP_ID
					  and dsp.ID = cp.DIR_SERV_PAYMENT
					  and c.ID(+) = cp.PID
					  and cad.ID(+) = cp.AMI_DIRECTION;
				exception when no_data_found then
						:DIR_NAME := null;
						:DIR_ID   := null;
						:CONTR_ID := null;
						:CONTR_NAME := null;
			end;
		end;
		<component cmptype="ActionVar" name="DIR_SERVICE" src="DIRECTION_SERVICE_CONTROL_GRID" srctype="ctrl" get="v1"/>
		<component cmptype="ActionVar" name="LPU" src="LPU" srctype="session"/>
		<component cmptype="ActionVar" name="CONTR_NAME"		src="CONTRACT_CODE"		srctype="var" put="v3" len="40"/>
		<component cmptype="ActionVar" name="CONTR_ID"			src="CONTRACT_ID"		srctype="var" put="v4" len="17"/>
		<component cmptype="ActionVar" name="DIR_NAME"			src="CONTR_AMI_DIR_CODE" srctype="var" put="v5" len="50"/>
		<component cmptype="ActionVar" name="DIR_ID"			src="CONTR_AMI_DIR_ID"	srctype="var" put="v6" len="17"/>
	</component>
	<component cmptype="Action" name="cancelVisit">
		begin
			  d_pkg_visits.del(pnid => :pnid,
                   pnlpu => :LPU,
                   pnuse_checks => 1);
		end;
		<component cmptype="ActionVar" name="LPU" src="LPU" srctype="session"/>
		<component cmptype="ActionVar" name="pnid" src="SYS_VISIT_ID" srctype="var" get="v1"/>
	</component>
	<component cmptype="Action" name="CHANGE_TIME">
    
declare
  vLPU                  d_v_direction_services.LPU%type;
  vPID                  d_v_direction_services.PID%type;
  vHID                  d_v_direction_services.HID%type;
  vIS_COMBINED_PAYMENT  d_v_direction_services.IS_COMBINED_PAYMENT%type;
  vIS_NECESSARY         d_v_direction_services.IS_NECESSARY%type;
  vSERVICE              d_v_direction_services.SERVICE_ID%type;
  vEMPLOYER_TO          d_v_direction_services.EMPLOYER_TO%type;
  vCABLAB_TO            d_v_direction_services.CABLAB_TO_ID%type;
  vVISIT_PURPOSE        d_v_direction_services.VISIT_PURPOSE_ID%type;
  vREF_KIND             d_v_direction_services.REF_KIND_ID%type;
  vVISIT_KIND           d_v_direction_services.VISIT_KIND_ID%type;
  vDISEASECASE          d_v_direction_services.DISEASECASE%type;
  vREG_TYPE             d_v_direction_services.REG_TYPE%type;
  vSERV_STATUS          d_v_direction_services.SERV_STATUS%type;
  vIS_PRIMARY           d_v_direction_services.IS_PRIMARY%type;
  vS_COMMNET            d_v_direction_services.S_COMMNET%type;
  vHH_DEP               d_v_direction_services.HH_DEP%type;
  vREC_TYPE             d_v_direction_services.REC_TYPE%type;
  vSER_COUNT            d_v_direction_services.SER_COUNT%type;
  vLPU_SERVICE          d_v_direction_services.LPU_SERVICE_ID%type;
begin
  select t.lpu, t.pid, t.hid,
         t.is_combined_payment,
         t.is_necessary,
         t.service_id,
         t.employer_to,
         t.cablab_to_id,
         t.visit_purpose_id,
         t.ref_kind_id,
         t.visit_kind_id,
         t.diseasecase,
         t.reg_type,
         t.serv_status,
         t.is_primary,
         t.s_commnet,
         t.hh_dep,
         t.rec_type,
	 t.ser_count,
         t.lpu_service_id
    into vLPU, vPID, vHID,
         vIS_COMBINED_PAYMENT,
         vIS_NECESSARY,
         vSERVICE,
         vEMPLOYER_TO,
         vCABLAB_TO,
         vVISIT_PURPOSE,
         vREF_KIND,
         vVISIT_KIND,
         vDISEASECASE,
         vREG_TYPE,
         vSERV_STATUS,
         vIS_PRIMARY,
         vS_COMMNET,
         vHH_DEP,
         vREC_TYPE,
	 vSER_COUNT,
         vLPU_SERVICE
    from d_v_direction_services t
   where t.ID = :ID;

  d_pkg_direction_services.upd(pnid =&gt; :ID,
                        pnlpu =&gt; vLPU,
                        pnhid =&gt; vHID,
                        pnis_combined_payment =&gt; vIS_COMBINED_PAYMENT,
                        pnis_necessary =&gt; vIS_NECESSARY,
                        pnservice =&gt; vSERVICE,
                        pnemployer_to =&gt; vEMPLOYER_TO,
                        pncablab_to =&gt; vCABLAB_TO,
                        pdrec_date =&gt; to_date(:REC_TIME, 'DD.MM.YYYY HH24:MI'),
                        pnvisit_purpose =&gt; vVISIT_PURPOSE,
                        pnref_kind =&gt; vREF_KIND,
                        pnvisit_kind =&gt; vVISIT_KIND,
                        pndiseasecase =&gt; vDISEASECASE,
                        pnreg_type =&gt; :IS_CITO,
                        pnserv_status =&gt; vSERV_STATUS,
                        pnis_primary =&gt; vIS_PRIMARY,
                        pss_commnet =&gt; vS_COMMNET,
                        pnhh_dep =&gt; vHH_DEP,
                        pnrec_type =&gt; vREC_TYPE,
                        pnser_count =&gt; vSER_COUNT,
                        pnlpu_service =&gt; vLPU_SERVICE,
                        pnREC_DURATION   =&gt;null,
                        pnTICKET_N       =&gt;null,
                        psTICKET_S       =&gt;null);
end;
    
    <component cmptype="ActionVar" name="ID"       get="v0" src="DS_ID"    srctype="var"/>
    <component cmptype="ActionVar" name="REC_TIME" get="v1" src="REC_TIME_NEW" srctype="var"/>
    <component cmptype="ActionVar" name="IS_CITO"  get="v2" src="IS_CITO_NEW"  srctype="var"/>
  </component>
  
    <!-- простановка статуса отменена -->
	<component cmptype="Action" name="DIR_SER_Z_CANCEL">
		begin
			for q in (select dsp.ID
							from d_v_dir_serv_payments dsp
							where dsp.PID = :ID)
			loop
				d_pkg_dir_serv_payments.extended_del(q.ID, :LPU);
			end loop;
			d_pkg_direction_services.set_status(:ID,:LPU,0);
			d_pkg_direction_services.cancel(:LPU,:ID,sysdate);
		end;
		<component cmptype="ActionVar" name="LPU" src="LPU" srctype="session"/>
		<component cmptype="ActionVar" get="v3" name="ID" src="DIRECTION_SERVICE_CONTROL_GRID" srctype="ctrl"/>
	</component>
	<!-- получение параметров для работы формы-->
	<component cmptype="Action" name="GET_DEF_PARAMS" compile="true">
		begin
			:EMPLOYER_ID := d_pkg_employers.GET_ID(:LPU);
				if :HH_ID is not null then
					begin
						select t.HH_PREF||'/'||t.HH_NUMB
						  into :HH_NUMB
						  @if(:TYPE=='RELATIVE'){
						from  D_V_HOSP_HISTORIES_RELATIVE t
						  @}else{
							from D_V_HOSP_HISTORIES t
						  @}
						 where t.ID=:HH_ID;
					 exception when no_data_found then :HH_NUMB := -1;
					end;
					begin
							select hhd.id
							  into :HH_DEP
							  from d_v_hosp_history_deps hhd
							 where hhd.pid = :HH_ID
							   and (hhd.date_in in (select max(date_in) from d_v_hosp_history_deps where pid = :HH_ID));
					exception when no_data_found then
							:HH_DEP := null;
					end;
				else
					:HH_NUMB:=null;
					:HH_DEP:=null;
				end if;
		end;
		<component cmptype="ActionVar" name="LPU" 		src="LPU" 		srctype="session"/>
		<component cmptype="ActionVar" name="EMPLOYER_ID" 	src="EMPLOYER_ID" 	srctype="var" put="v1"  len="17"/>
		<component cmptype="ActionVar" name="HH_NUMB"		src="HH_NUMB"		srctype="var" put="v2"  len="40"/>
		<component cmptype="ActionVar" name="HH_ID"		src="HH_ID"		srctype="var" get="v3"/>
		<component cmptype="ActionVar" name="HH_DEP"		src="HH_DEP"		srctype="var" put="v4"  len="17"/> 
		<component cmptype="ActionVar" name="TYPE"		src="TYPE"		srctype="var" get="v5"/> 
	</component>
	<!-- удаление не оказанных услуг для "Внести результат" -->
	<component cmptype="Action" name="DEL_ALL_NAZN" mode="post">
		begin
			for r in (select t1.DIRECTION_SERVICE as DIRECTION_SERVICE
					  from d_v_direction_service_control t1,
						d_v_cablab t1cl
					  where t1.DIRECTION_SERVICE = :DIR_SERVICE
						and t1.STATUS_CODE = 'N'
						and t1cl.ID(+) = t1.CABLAB_TO)
			loop
				d_pkg_direction_services.del(r.DIRECTION_SERVICE, :PNLPU, 0);
			end loop;
			
		end;
		<component cmptype="ActionVar" get="v0" name="DIR_SERVICE" src="DIR_SERV_FOR_DEL_IF_NOT_VISIT" srctype="var"/>
		<component cmptype="ActionVar" name="PNLPU" src="LPU" srctype="session"/>
	</component>
	
	<!-- Action удаления направления-->
	<component cmptype="Action" name="DIR_DIR_SERV_DELETE" mode="post">
		begin
			  d_pkg_direction_services.del(pnid => :pnid,
                               pnlpu => :pnlpu,
                               pndel_dir => 0);			
		end;
		<component cmptype="ActionVar" get="v1" name="PNID" src="DIRECTION_SERVICE_CONTROL_GRID" srctype="ctrl"/>
		<component cmptype="ActionVar" name="PNLPU" src="LPU" srctype="session"/>
	</component>
	<!-- проверка возможности оказания услуги врачом d_v_emp_services-->
	<component cmptype="Action" name="checkRightsDoc" mode="post">
		begin
			select count(*)
			into :COUNT
			from d_v_emp_services t
			where t.PID = :EMPLOYER_ID
				and t.SERVICE_ID = :SERV_ID;			
		end;
		<component cmptype="ActionVar" get="v1" name="SERV_ID" src="THIS_SERVICE_ID" srctype="var"/>
		<component cmptype="ActionVar" get="EI" name="EMPLOYER_ID" src="EMPLOYER_ID" srctype="var"/>
		<component cmptype="ActionVar" name="PNLPU" src="LPU" srctype="session"/>
		<component cmptype="ActionVar" put="v2" name="COUNT" src="CHECK_DOC" srctype="var" len="2"/>
	</component>
	<component cmptype="Action" name="CheckRightsForServices" mode="post">
		begin
			:R_VIEW_RES:=D_PKG_CSE_ACCESSES.CHECK_RIGHT(pnLPU => :pnlpu, psUNITCODE => 'SERVICES', pnUNIT_ID => :SERV_ID, psRIGHT => '3', pnCABLAB => null, pnSERVICE => null, pnRAISE => 0);
			:R_EDIT_OWN:=D_PKG_CSE_ACCESSES.CHECK_RIGHT(pnLPU => :pnlpu, psUNITCODE => 'SERVICES', pnUNIT_ID => :SERV_ID, psRIGHT => '6', pnCABLAB => null, pnSERVICE => null, pnRAISE => 0);
			:R_EDIT_ANY:=D_PKG_CSE_ACCESSES.CHECK_RIGHT(pnLPU => :pnlpu, psUNITCODE => 'SERVICES', pnUNIT_ID => :SERV_ID, psRIGHT => '7', pnCABLAB => null, pnSERVICE => null, pnRAISE => 0);
			:R_CANCEL:=D_PKG_CSE_ACCESSES.CHECK_RIGHT(pnLPU => :pnlpu, psUNITCODE => 'SERVICES', pnUNIT_ID => :SERV_ID, psRIGHT => '8', pnCABLAB => null, pnSERVICE => null, pnRAISE => 0);
                        select count(*)
			into :COUNT
			from d_v_direction_service_control t
			where t.DIRECTION_SERVICE = :DIR_SERV_ID
				and t.VISIT_EMPLOYER_ID = :EMP_ID;		
		end;
		<component cmptype="ActionVar" name="PNLPU"			src="LPU"			  srctype="session"/>
		<component cmptype="ActionVar" name="SERV_ID"		src="SERVICE_ID_FOR"  srctype="var"		get="g1"/>

		<component cmptype="ActionVar" name="R_VIEW_RES"	src="R_VIEW_RES"	  srctype="var"		put="p1" len="3"/>
		<component cmptype="ActionVar" name="R_EDIT_OWN"	src="R_EDIT_OWN"	  srctype="var"		put="p2" len="3"/>
		<component cmptype="ActionVar" name="R_EDIT_ANY"	src="R_EDIT_ANY"	  srctype="var"		put="p3" len="3"/>

		<component cmptype="ActionVar" name="R_CANCEL"		src="R_CANCEL"		  srctype="var"		put="p4" len="3"/>
		<component cmptype="ActionVar" name="DIR_SERV_ID_FOR_CHECK" src="DIR_SERV_ID_FOR_CHECK" srctype="var" get="v1"/>
                <component cmptype="ActionVar" get="v1" name="DIR_SERV_ID" src="DIR_SERV_ID_FOR_CHECK" srctype="var"/>
		<component cmptype="ActionVar" get="v2" name="EMP_ID" src="EMPLOYER_ID" srctype="var"/>
		<component cmptype="ActionVar" put="v3" name="COUNT" src="FLAG_CHECK_ID" srctype="var" len="2"/>
	</component>
	<component cmptype="Action" name="GetTemplateId" mode="post">
		begin
			if :DIR_SERV_ID_FOR_CHECK is null then
				:TEMPLATE_ID := null;
			else
				:TEMPLATE_ID := d_pkg_visits.get_template_info(fnLPU => :PNLPU,
								    fnID => :DIR_SERV_ID_FOR_CHECK,
								    fsUNITCODE => 'DIRECTION_SERVICES',
								    fnWHAT => 0);
			end if;
		end;
		<component cmptype="ActionVar" name="PNLPU"                 src="LPU"			srctype="session"/>
		<component cmptype="ActionVar" name="DIR_SERV_ID_FOR_CHECK" src="DIR_SERV_ID_FOR_CHECK" srctype="var" get="v1"/>
		<component cmptype="ActionVar" name="TEMPLATE_ID" src="TEMPLATE_ID" srctype="var" put="v2" len="17"/>
	</component>
	<!-- проверка врач-кабинет для оказания услуги-->
	<component cmptype="Action" name="GET_CABLAB" mode="post">
		begin
			select count(*) into :CABLAB_NUM
			from d_v_emp_cablabs t
			where t.PID=:EMPLOYER_ID and t.CABLAB_ID = :CABLAB_TO;
		end;
		<component cmptype="ActionVar" name="pnLPU" src="LPU" srctype="session"/>
		<component cmptype="ActionVar" name="CABLAB_NUM" 	src="CABLAB_NUM" srctype="var" len="5" put="var1"/>
		<component cmptype="ActionVar" name="CABLAB_TO" 	src="CABLAB_TO" srctype="var" get="var2"/>
		<component cmptype="ActionVar" name="EMPLOYER_ID" 	src="EMPLOYER_ID" srctype="var" get="var3"/>
	</component>
	<!-- не используется -->
	<component cmptype="Action" name="CREATE_NEW_DIRECTION" mode="post">
		begin
			D_PKG_DIRECTION_SERVICES.CREATE_NEW_DIRECTION(:pnLPU,:pnDIRECTION_SERVICE,:pnSERVICE);
		end;
		<component cmptype="ActionVar" name="pnLPU" src="LPU" srctype="session"/>
		<component cmptype="ActionVar" name="pnDIRECTION_SERVICE" src="DIR_SERVICE" srctype="var" get="var0"/>
		<component cmptype="ActionVar" name="pnSERVICE" src="SERVICE_SELECT" srctype="var" get="var1"/>
	</component>
	<component cmptype="Action" name="isShowDirServReport">
	    <![CDATA[
	     begin
	        -- проверка - показывать отчет с типом "Направление" или нет
	        select 1
	          into :IS_SHOW
	          from d_v_vis_template_reports t
	         where t.PID = D_PKG_VISITS.GET_TEMPLATE_INFO(:LPU, :DIR_SERVICE, 'DIRECTION_SERVICES', 0, 1)
	           and t.REP_TYPE = 3
	           and rownum = 1;
	         exception when others then 
	            :IS_SHOW := 0;
	     end;
	    ]]>
		<component cmptype="ActionVar" name="LPU" src="LPU" srctype="session"/>
                <component cmptype="ActionVar" name="DIR_SERVICE" get="ds" src="DIR_SERV_ID_FOR_CHECK" srctype="var"/>
		<component cmptype="ActionVar" name="IS_SHOW" src="IS_SHOW" srctype="var" put="is_show" len="1"/> 
	</component>
<table  style="height:450px;width:100%; table-layout: fixed;">
<tbody  style="height:100%;">
<tr>
 <td style="padding-top:2pt;padding-bottom:3pt;text-align:center;" cmptype="tmp" name="THIS_BUTTON">
 	    	<component cmptype="Button" name="NewNazn" caption="Новое назначение" onclick="base().DIRECTION_SERVICE_CONTROL_DIRECTION();"/>
			 <component cmptype="Button" name="NewNazn" caption="Напровление на аналзы" onclick="base().expressRegister();"/>
		<!-- @gen_reg -->
	    	<!--component cmptype="Button" name="NewZap" caption="Расписание" onclick="base().DIR_SERV_OPEN_REG_CREATE();"/-->
		<component cmptype="Button" name="NewZap" caption="Расписание" onclick="base().genClschs('reg_full',0,null);"/>
		<!-- @gen_reg -->
		<component cmptype="Button" name="VisServices" caption="Внести результат" onclick="base().SHOW_EMP_SERVICES();"/>
	    	<component cmptype="Button" name="ByTemplate" caption="По шаблону" onclick="base().DIRECTION_SERVICE_CONTROL_BY_TEMPLATE();"/>
		<component cmptype="Edit" style="display:none;" name="REG_TIME_TYPE"/>
 </td>
 </tr>
 <tr style="height:100%;">
  <td style="height:100%;">
  <!-- DataSet направления привязанные к данному направлению/визиту-->
	  <component cmptype="DataSet" name="DS_DIRECTION_SERVICE_CONTROL" mode="Range" activateoncreate="false">
		select  t.DIRECTION  as DIRECTION,
				t.DIRECTION_SERVICE as DIRECTION_SERVICE,
				t.DISEASECASE as DISEASECASE,
				t.REG_DATE as REG_DATE,
				t.REG_EMPLOYER as REG_EMPLOYER,
				t.SERVICE_ID as SERVICE_ID,
				t.SERVICE as SERVICE,
				t.SERVICE_CODE as SERVICE_CODE,
				t.REG_TYPE as REG_TYPE,
				t.STATUS as STATUS,
				t.VISIT_DATE as VISIT_DATE, 
				t.VISIT_EMPLOYER as VISIT_EMPLOYER,
				case 
					when t.VISIT_EMPLOYER_ID is null then
						null
					when t.VISIT_EMPLOYER_ID = :EMPLOYER_ID then 
						1
					else
						0
				end as FLAG_CHECK_ID,
				t.EMPLOYER_TO as EMPLOYER_TO,
				t.CABLAB_TO as CABLAB_TO,
				t.STATUS_CODE as STATUS_CODE,
				t.REG_VISIT as REG_VISIT,
				t.VISIT_ID as VISIT_ID,
				'1' as SIGN_FOR_POPUP,
				tcl.CL_NAME as CL_NAME,
				tcl.CL_NAME||' '||t.VISIT_EMPLOYER CL_EMP,
			 	t.REC_TYPE,
			 	t.TIME_TYPE,
			 	t.REC_DATE,
                d.PAT_AGENT_ID
		   from D_V_DIRECTION_SERVICE_CONTROL t
		        left join D_V_CABLAB tcl on tcl.ID = t.CABLAB_TO
		        left join D_V_DIRECTIONS d on d.ID = t.DIRECTION
		  where t.DISEASECASE = :DISEASECASE_ID
		    and t.DIRECTION_SERVICE_HID is null
			 <component cmptype="Variable" get="v1" name="DISEASECASE_ID" src="DISEASECASE" srctype="var"/>
			 <component cmptype="Variable" get="EI" name="EMPLOYER_ID" src="EMPLOYER_ID" srctype="var"/>
			 <component cmptype="Variable" type="count" srctype="var" src="ds99count" default="10"/>
	  		 <component cmptype="Variable" type="start" srctype="var" src="ds99start" default="1"/>
		</component>
		<component cmptype="Grid" name="DIRECTION_SERVICE_CONTROL_GRID" dataset="DS_DIRECTION_SERVICE_CONTROL" field="DIRECTION_SERVICE" style="height:450px" vars="PAT_AGENT_ID" onclone="base().DIR_SERV_CONTROL_OnClone(this,_dataArray);"> <!--onclone=""-->
		  <component cmptype="Column" caption="Наименование" field="SERVICE" filter="SERVICE"/>
		  <component cmptype="Column" caption="Статус" field="STATUS" filter="STATUS" sort="STATUS">
			<!-- @gen_reg начало -->
			<!--component cmptype="HyperLink" datafield="CL_EMP" captionfield="STATUS" onclick="base().REG_REWRITE();" onmouseover="base().REG_REWRonFocus(this);"/-->
			<component cmptype="HyperLink" datafield="CL_EMP" captionfield="STATUS" onclick="base().onStatusClickGenClschs();" onmouseover="base().REG_REWRonFocus(this);"/>
			<!-- @gen_reg конец-->
		  </component>
		  <component cmptype="Column" caption="Принять">
			<component cmptype="HyperLink" name="IN_BUT" caption="Принять" onclick="base().DIRECTION_SERVICE_CONTROL_VISIT(0);"/>
			<img cmptype="HyperLink" src="Images/img2/edit.gif" name="vis_img" onclick="base().DIRECTION_SERVICE_CONTROL_VISIT(1);" style="cursor:pointer;"/>			
		  </component>
		  <component cmptype="GridFooter" separate="false">
		     <component insteadrefresh="InsteadRefresh(this);" count="20" cmptype="Range" varstart="ds99start" varcount="ds99count" valuecount="20" valuestart="1"/>
   	      </component>
		</component>
		<component cmptype="SortItem" refreshdataset="DS_DIRECTION_SERVICE_CONTROL" sortorder="-4" field="REC_DATE" constant="true"/>
            <component cmptype="Popup" name="pDSS_CONTROL" popupobject="DIRECTION_SERVICE_CONTROL_GRID" onpopup="base().optionPopupDirectionDSS();">
			<component cmptype="PopupItem" name="pDSS_REF" caption="Обновить" onclick="refreshDataSet('DS_DIRECTION_SERVICE_CONTROL');" cssimg="refresh"/>
			<component cmptype="PopupItem" name="pDSS_INS" caption="Внести результат" onclick="base().DIRECTION_SERVICE_CONTROL_VISIT();" cssimg="insert"/>
			<component cmptype="PopupItem" name="pDSS_REP" caption="Просмотреть отчет" onclick="base().REPORT_PRINT_P();" cssimg="report"/>
	        <component cmptype="PopupItem" name="pDIR_SERV" caption="Направление" onclick="base().PrintVisit(null, getValue('DIRECTION_SERVICE_CONTROL_GRID'), 3);" cssimg="print"/>
			<component cmptype="PopupItem" name="pDSS_DEL" caption="Отменить" onclick="base().DSS_CANCEL();" cssimg="delete"/>
			<component cmptype="PopupItem" name="pDSS_DELETE" caption="Удалить" onclick="base().DSS_DELETE();" cssimg="delete"/>
			<component cmptype="PopupItem" name="pDdelDirect"  caption="Отменить оказание" unitbp="VISITS_CANCEL" onclick="base().cancelVisit();" cssimg="delete"/>
			<component cmptype="PopupItem" name="pUserProcSep" caption="-"/>
			<component cmptype="PopupItem" name="pDUserProc" caption="Установить количество процедур" onclick="setVar('UP_ID',getValue('DIRECTION_SERVICE_CONTROL_GRID'));execProcByCode('SetProcCount');" cssimg="userprocs"/>
	    </component>
            <component cmptype="AutoPopupMenu" unit="DIRECTION_SERVICES" all="true" join_menu="pDSS_CONTROL" popupobject="DIRECTION_SERVICE_CONTROL_GRID"/>
  </td>
 </tr>
</tbody>
</table>
</div>
