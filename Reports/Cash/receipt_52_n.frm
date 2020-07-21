<div cmptype="rep" style="min-width: 1180px;">
	<span style="display:none" id="PrintSetup" ps_marginBottom="4" ps_marginRight="4" ps_marginTop="4" ps_marginLeft="4" ps_orientation="landscape" ps_paperData="9" ps_shrinkToFit="0" ps_scaling="90"></span>
	<component cmptype="IncludeFile" type="js" src="System/js/number_to_string"/>
	<component cmptype="Script">
		<![CDATA[
		Form.months = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];
		Form.getMonth = function(n)
		{
			n = parseInt(n);
			if (n >= 1 && n <= 12)
				return Form.months[n-1];
			return;
		}
		/**
		 * Подготовка строки для вывода в многостроковом поле
		 * @param {String} str - строка данных
		 * @param {Number} firstLineLength - максимальная длина в символах первой строки
		 * @param {Number} otherLinesLength - максимальная длина в символах любой строки, кроме первой
		 * @param {Number} needLinesCount - можно задать общее количество строк для вывода (вместе с пустыми)
		 * @param {String} wordsDelimiter - можно задать свой разделитель слов в строке
		 * @return {object} - массив строк для вывода
		*/
		Form.makeMultiLines = function (str, firstLineLength, otherLinesLength, needLinesCount = null, wordsDelimiter = ' ') {
			var resultLines = [],
				emptyLineContent = '&#160;&#160;&#160;&#160;',
				words = str.split(wordsDelimiter),
			maxLineLength = firstLineLength,
			currentString = '';

			for (var i = 0; i < words.length; i++)
			{
				var currentLineLength = currentString.length + wordsDelimiter.length + words[i].length;
				if (currentLineLength <= maxLineLength) 
				{
					currentString += (currentString.length ? wordsDelimiter : '') + words[i];
				} 
				else 
				{
					resultLines.push(currentString + wordsDelimiter);
					maxLineLength = otherLinesLength;
					currentString = words[i];
				}
			}

			//чтобы последняя строка не растягивалась
			var additionalStr = '';
			for (var i = 0; i < maxLineLength - currentString.length; i++) 
			{
				additionalStr += '&#160;';
			}
			resultLines.push(currentString + additionalStr);

			if (+needLinesCount > 0 && resultLines.length < needLinesCount) 
			{
				var needEmptyLinesCount = needLinesCount - resultLines.length;

				for (var i = 0; i < needEmptyLinesCount; i++) 
				{
					resultLines.push(emptyLineContent);
				}
			}

			return resultLines;
		};

		/**
		 * Подготовка HTML для вывода мультистрокового поля
		 * @param {object} linesArray - массив строк
		 * @param {Number} mmWidthFirst - можно задать длину поля для первой строки, в мм, если она отличается от остальных
		 * @param {String} cssStyle - можно задать дополнительные CSS стили для элементов div, в которых выводятся строки
		 * @return {String} - HTML мультистрокового поля
		*/
		Form.generateHtmlByLines = function(linesArray, mmWidthFirst = null, cssStyle = '') {
			var resultHtml = '';
			for (var i = 0; i < linesArray.length; i ++) 
			{
				var currentCSSStyle = 'border-bottom: 1px solid black; text-align: justify; text-align-last: justify; ' + cssStyle + ';';
				if (i == 0 && mmWidthFirst) 
				{
					currentCSSStyle += 'display: inline-block; min-width:' + mmWidthFirst + 'mm;'
				}
				resultHtml += '<div style="' + currentCSSStyle + '">' + linesArray[i] +'</div>';
			}
			return resultHtml;
		};

		/**
		 * Вывод мультистрокового поля
		 * @param {String} controlName - имя контрола (cmpLabel), который нужно преобразовать в мультистроковое поле
		 * @param {Number} firstLineLength - максимальная длина в символах первой строки
		 * @param {Number} otherLinesLength - максимальная длина в символах любой строки, кроме первой
		 * @param {Number} mmWidthFirst - можно задать длину поля для первой строки, в мм, если она отличается от остальных
		 * @param {String} cssStyle - можно задать дополнительные CSS стили для элементов div, в которых выводятся строки
		 * @param {Number} needLinesCount - можно задать общее количество строк для вывода (вместе с пустыми)
		 * @param {String} wordsDelimiter - можно задать свой разделитель слов в строке
		*/
		Form.addMultilinedControl = function(control, firstLineLength, otherLinesLength,
											 mmWidthFirst = null, cssStyle = '', needLinesCount = null, wordsDelimiter = ' ') {
			text = control.innerText;

			var htmlForBox = base().generateHtmlByLines(
				base().makeMultiLines(
					text,
					firstLineLength,
					otherLinesLength,
					needLinesCount,
					wordsDelimiter
				),
				mmWidthFirst,
				cssStyle
			);

			var resultContainer = document.createElement("span");
			resultContainer.innerHTML = htmlForBox;
			control.innerHTML = htmlForBox;
		}

		Form.summLines = function(controlName, value, needLength){
			for (var i = value.length; i < needLength; i++)
			{
				value += '=';
			}
			getControlByName(controlName).innerHTML = value;
			getControlByName(controlName).style.wordBreak = 'break-all';
			getControlByName(controlName).style.borderBottom  = '1px solid black';
		}
		Form.onClone = function(_dataArray, obj){
			base().addMultilinedControl(getControlByName('LPU'), 40, 50, 68, null, 3);
			base().addMultilinedControl(getControlByName('ADDRESS'), 65, 75, 110, null, 2);
			base().addMultilinedControl(getControlByName('PAYMENT_FIO'), 62, 72, 117, 'margin-bottom:3mm;', 2);
			base().addMultilinedControl(getControlByName('REASON'), 62, 72, 126, 'margin-bottom:3mm;', 2);

			var value;
			if (!empty(_dataArray['SUMM_TOTAL']))
				value = number_to_string(_dataArray['SUMM_TOTAL']);
			else
				value = '';
			if (value.indexOf('рубля') > -1)
				value = value.substr(0, value.indexOf('рубля'));
			else
				value = value.substr(0, value.indexOf('рублей'));
			if(!empty(value)){
				value = value[0].toUpperCase() + value.slice(1)
			}
			base().summLines('SUMM_TOTAL', ' Сумма, всего '+value, 90);

			if (!empty(_dataArray['SUMM_CASH']))
				value = number_to_string(_dataArray['SUMM_CASH']);
			else
				value = '';
			if (value.indexOf('рубля') > -1)
				value = value.substr(0, value.indexOf('рубля'));
			else
				value = value.substr(0, value.indexOf('рублей'));
			base().summLines('SUMM_CASH', value, 38);

			if (!empty(_dataArray['SUMM_CARD']))
				value = number_to_string(_dataArray['SUMM_CARD']);
			else
				value = '';
			if (value.indexOf('рубля') > -1)
				value = value.substr(0, value.indexOf('рубля'));
			else
				value = value.substr(0, value.indexOf('рублей'));
			base().summLines('SUMM_CARD', value, 85);

			if (empty(_dataArray['SUMM_TOTAL_KOP']))
			{
				setCaption('SUMM_TOTAL_KOP', '00');
			}
			else if (_dataArray['SUMM_TOTAL_KOP'].length == 1)
			{
				setCaption('SUMM_TOTAL_KOP', '0' + _dataArray['SUMM_TOTAL_KOP']);
			}

			if (empty(_dataArray['SUMM_CASH_KOP']))
			{
				setCaption('SUMM_CASH_KOP', '00');
			}
			else if (_dataArray['SUMM_CASH_KOP'].length == 1)
			{
				setCaption('SUMM_CASH_KOP', '0' + _dataArray['SUMM_CASH_KOP']);
			}

			if (empty(_dataArray['SUMM_CARD_KOP']))
			{
				setCaption('SUMM_CARD_KOP', '00');
			}
			else if (_dataArray['SUMM_CARD_KOP'].length == 1)
			{
				setCaption('SUMM_CARD_KOP', '0' + _dataArray['SUMM_CARD_KOP']);
			}

			setCaption('PAY_MONTH', base().getMonth(getCaption('PAY_MONTH')));
			setCaption('PAY_MONTH_D', base().getMonth(getCaption('PAY_MONTH_D')));
		}
		Form.onPostClone = function(_clone, _dataArray){
			var secondClone = _clone.cloneNode(true);
			secondClone.className = secondClone.className.replace('main', 'copy');
			_clone.parentNode.insertBefore(secondClone, _clone.nextSibling);
		}
		]]>
	</component>
	<component cmptype="DataSet" name="DS_DATA" compile="true">
		<![CDATA[
         with empl as (
                    select e.ID,
                           e.FIO,
                           e.JOBTITLE
                      from D_V_EMPLOYERS e
                     where e.ID = :KASSIR
                      )
		 select t.PAY_DATE,
				to_char(t.PAY_DATE, 'DD') PAY_DAY,
				to_char(t.PAY_DATE, 'MM') PAY_MONTH,
				to_char(t.PAY_DATE, 'YY') PAY_YEAR,
				t.OKPO,
				t.INN,
				t.KPP,
				t.OKVED,
				t.DOC_NUMB,
				t.LPU,
				t.ADDRESS,
				t.PAYMENT_FIO,
				t.PD_TYPE,
				t.PD_NUMB,
				t.REASON,
				trunc(t.SUMM_TOTAL) SUMM_TOTAL,
				mod(t.SUMM_TOTAL, 1) * 100  SUMM_TOTAL_KOP,
				trunc(sum(t.SUMM_CASH)) SUMM_CASH,
				mod(sum(t.SUMM_CASH), 1) * 100  SUMM_CASH_KOP,
				trunc(sum(t.SUMM_CARD)) SUMM_CARD,
				mod(sum(t.SUMM_CARD), 1) * 100  SUMM_CARD_KOP,
			  @if(:KASSIR){
				(
				    select empl.JOBTITLE
				      from empl
				) JOBTITLE,
				(
				    select empl.FIO
				      from empl
				) EMPLOYER_FIO,
			  @}else if(:KASSIR_EDIT){
			    'Кассир' JOBTITLE,
			    :KASSIR_EDIT EMPLOYER_FIO,
			  @}else{
			    t.JOBTITLE,
			    t.EMPLOYER_FIO,
			  @}
				0 UIN,
				'0504510' OKUD,
				:SERIA DOC_SERIA
		   from (
			select
				trunc(pj.PAY_DATE) PAY_DATE,
				la.AGN_OKPO OKPO,
				la.AGN_INN INN,
				la.AGN_KPP KPP,
				la.OKVED OKVED,
				ctr.DOC_NUMB,
				lpu.LPUDICT_FULLNAME LPU,
				lpu.FULLADDRESS ADDRESS,
				coalesce((
				            select t.SURNAME_FR||' '||t.FIRSTNAME_FR||' '||t.LASTNAME_FR
							  from D_V_AGENT_NAMES t
							 where t.pid = ag.ID
							   and t.begin_date <= pj.PAY_DATE
							   and (t.end_date >= pj.PAY_DATE or t.end_date is null)
				         ),
                            ag.SURNAME ||' '||ag.FIRSTNAME||' '||ag.LASTNAME) PAYMENT_FIO,
				D_PKG_UNITPROPS.GET_SVAL('PERSDOCTYPES', ap.PD_TYPE_ID, 'PAY_PERSDOCTYPES') PD_TYPE,
				ap.PD_SER || ' ' || ap.PD_NUMB PD_NUMB,
				'платных медицинских услуг по договору № '|| ctr.DOC_PREF || '/' || ctr.DOC_NUMB || ' от ' || ctr.DOC_DATE REASON,
				ctr.CONTRACT_SUMM SUMM_TOTAL,
				case when pm.PM_TYPE = 0 and pj.OPER_TYPE = 0 then pjcp.PAY_SUMM end SUMM_CASH,
				case when pm.PM_TYPE = 1 and pj.OPER_TYPE = 0 then pjcp.PAY_SUMM end SUMM_CARD,
				emp.JOBTITLE,
				pj.EMPLOYER_FIO
			from D_V_CONTRACTS ctr
				join D_V_CONTRACT_PAYMENTS cp on cp.PID = ctr.ID
					join D_V_PJ_CON_PAYMENTS pjcp on pjcp.CONTRACT_PAYMENT = cp.ID
						join D_V_PAYMENT_JOURNAL pj on pj.ID = pjcp.PID
							join D_V_EMPLOYERS emp on emp.ID = pj.EMPLOYER_ID
						join D_V_PAYMENT_METHODS pm on pm.ID = pj.PAYMENT_METHOD_ID
				join D_V_AGENTS ag on ag.ID = ctr.AGENT_ID
					left join D_V_AGENT_PERSDOCS ap on ap.ID = D_PKG_AGENT_PERSDOCS.GET_ACTUAL_ON_DATE(ag.ID, trunc(pj.PAY_DATE))
			join D_V_LPU lpu on lpu.ID = :LPU
				join D_V_AGENTS la on la.ID = lpu.AGENT_ID
			where ctr.ID = :CONTRACT_ID
		) t
		group by t.PAY_DATE,
			t.OKPO,
			t.INN,
			t.KPP,
			t.OKVED,
			t.DOC_NUMB,
			t.LPU,
			t.ADDRESS,
			t.PAYMENT_FIO,
			t.PD_TYPE,
			t.PD_NUMB,
			t.REASON,
			t.JOBTITLE,
			t.EMPLOYER_FIO,
			t.SUMM_TOTAL
		order by t.PAY_DATE desc
		]]>
		<component cmptype="Variable" name="CONTRACT_ID" 	src="CONTRACT_ID"		srctype="var" 		get="CONTRACT_ID"		/>
		<component cmptype="Variable" name="SERIA" 			src="SERIA"				srctype="var" 		get="SERIA"				/>
		<component cmptype="Variable" name="KASSIR"    	    src="KASSIR"			srctype="var" 		get="KASSIR"			/>
		<component cmptype="Variable" name="KASSIR_EDIT"    src="KASSIR_EDIT"		srctype="var" 		get="KASSIR_EDIT"		/>
		<component cmptype="Variable" name="LPU" 			src="LPU"				srctype="session"							/>
	</component>
	<div class='group-pay font-setup'>
		<div class='receipt main' dataset="DS_DATA"  onclone='base().onClone(_dataArray, this);' onpostclone='base().onPostClone(_clone, _dataArray);' repeate="0">
			<table>
				<tbody>
					<tr>
						<td style="vertical-align: top">
							<table>
								<colgroup>
									<col width="56%" />
									<col width="6%" />
									<col width="2%" />
									<col width="12%" />
									<col width="24%" />
								</colgroup>
								<tr>
									<td colspan='5' style="text-align: right;font-size:70%;vertical-align: top">
										<div style="height: 30px" class="top">
											<component cmptype="Label" caption="Утв. приказом Минфина России"/>
											<br/>
											<component cmptype="Label" caption="от 30 марта 2015 г. № 52н"/>
										</div>
									</td>
								</tr>
								<tr>
									<td colspan='4'>
										<table class='kv'>
											<tr>
												<td class='tbg'>
													<b class='m'>
														<component cmptype="Label" caption="Квитанция №"/>
													</b>
													<b class='c'>
														<component cmptype="Label" caption="Копия квитанции №"/>
													</b>
												</td>
												<td class='undrl sn tbg'>
													<component cmptype="Label" name="DOC_NUMB" captionfield="DOC_NUMB" />
												</td>
												<td class='tbg'>
													<b>
														<component cmptype="Label" caption="Серия"/>
													</b>
												</td>
												<td class='undrl sn tbg'>
													<component cmptype="Label" name="DOC_SERIA" captionfield="DOC_SERIA" />
												</td>
											</tr>
										</table>
									</td>
									<td class='border center'>
										<component cmptype="Label" caption="КОДЫ"/>
									</td>
								</tr>
								<tr>
									<td></td>
									<td class='right' colspan='3'>
										<component cmptype="Label" caption="Форма по ОКУД"/>
									</td>
									<td class='border center'>
										<component cmptype="Label" name="OKUD" captionfield="OKUD" />
									</td>
								</tr>
								<tr>
									<td colspan='3'>
										<table class='center date'>
											<tr>
												<td>«</td>
												<td class='day undrl'>
													<component cmptype="Label" name="PAY_DAY" captionfield="PAY_DAY" />
												</td>
												<td>»</td>
												<td class='month undrl'>
													<component cmptype="Label" name="PAY_MONTH" captionfield="PAY_MONTH" />
												</td>
												<td>
													<component cmptype="Label" caption="20"/>
												</td>
												<td class='year undrl'>
													<component cmptype="Label" name="PAY_YEAR" captionfield="PAY_YEAR" />
												</td>
												<td>
													<component cmptype="Label" caption="г."/>
												</td>
											</tr>
										</table>
									</td>
									<td class='right'>
										<component cmptype="Label" caption="Дата"/>
									</td>
									<td class='border center'>
										<component cmptype="Label" name="PAY_DATE" captionfield="PAY_DATE" />
									</td>
								</tr>
								<tr>
									<td colspan='3' rowspan='3'>
										<component cmptype="Label" caption="Учреждение"/>
										<component cmptype="Label" name="LPU" captionfield="LPU" />
									</td>
									<td class='right'>
										<component cmptype="Label" caption="по ОКПО"/>
									</td>
									<td class='border center'>
										<component cmptype="Label" name="OKPO" captionfield="OKPO" />
									</td>
								</tr>
								<tr>
									<td class='right'>
										<component cmptype="Label" caption="ИНН"/>
									</td>
									<td class='border center'>
										<component cmptype="Label" name="INN" captionfield="INN" />
									</td>
								</tr>
								<tr>
									<td class='right'>
										<component cmptype="Label" caption="KПП"/>
									</td>
									<td class='border center'>
										<component cmptype="Label" name="KPP" captionfield="KPP" />
									</td>
								</tr>
								<tr>
									<td colspan='2'>
										<table width="100%">
											<tr>
												<td width="10%">
													<component cmptype="Label" caption="УИН"/>
												</td>
												<td class='relat'>
													<component cmptype="Label" name="UIN" captionfield="UIN" class='border-bold center' style='height:17px;' />
												</td>
											</tr>
										</table>
									</td>
									<td class='right' colspan='2'>
										<component cmptype="Label" caption="по ОКВЭД"/>
									</td>
									<td class='border center'>
										<component cmptype="Label" name="OKVED" captionfield="OKVED" />
									</td>
								</tr>
							</table>
							<br/>
							<component cmptype="Label" caption="Местонахождение"/>
							<component cmptype='Label' name='ADDRESS' captionfield="ADDRESS"/>
							<br/>
							<table class='identifier'>
								<colgroup>
									<col width="16%" />
									<col width="19%" />
									<col width="24%" />
									<col width="41%" />
								</colgroup>
								<tr>
									<td colspan='4' class='center tmd'>
										<i>
											<b>
												<component cmptype="Label" caption="Идентификация плательщика"/>
											</b>
										</i>
									</td>
								</tr>
								<tr>
									<td colspan='4' class='relat'>
										<component cmptype="Label" caption="Принято от"/>
										<component cmptype='Label' name='PAYMENT_FIO' captionfield="PAYMENT_FIO" />
										<span class='tsm payment-fio'>
											<component cmptype="Label" caption="(фамилия, имя отчество)"/>
										</span>
									</td>
								</tr>
								<tr>
									<td>
										<component cmptype="Label" caption="Код вида документа"/>
									</td>
									<td class='relat'>
										<component cmptype="Label" name="PD_TYPE" captionfield="PD_TYPE" class='border-bold' />
									</td>
									<td>
										<component cmptype="Label" caption="Серия и"/>
										<br/>
										<component cmptype="Label" caption="номер документа"/>
									</td>
									<td class='relat'>
										<component cmptype="Label" name="PD_NUMB" captionfield="PD_NUMB" class='border-bold' />
									</td>
								</tr>
							</table>
							<br/>
							<div class='relat'>
								<component cmptype="Label" caption="В уплату "/>
								<component cmptype="Label" name="REASON" captionfield="REASON" />
								<span class='tsm reason'>
									<component cmptype="Label" caption="(вид продукции, услуги, работы)"/>
								</span>
							</div>
							<div class='relat summ'>
								<span class='tsm st'>
									<component cmptype="Label" caption="(прописью)"/>
								</span>
								<!--<component cmptype="Label" caption="Сумма, всего"/>-->
								<span  style="display: inline-block">
									<component cmptype="Label" before_caption="Сумма, всего" name="SUMM_TOTAL" captionfield="SUMM_TOTAL" class="lh" />
								</span>

								<component cmptype="Label" caption=" руб."/>
								<component cmptype="Label" name="SUMM_TOTAL_KOP" class='undrl' captionfield="SUMM_TOTAL_KOP" />
								<component cmptype="Label" caption=" коп."/>
							</div>
							<table class='money'>
								<colgroup>
									<col width="20%;" />
								</colgroup>
								<tr>
									<td>
										<component cmptype="Label" caption="в том числе:"/>
										<br/>
										<component cmptype="Label" caption="наличными"/>
										<br/>
										<component cmptype="Label" caption="деньгами"/>
									</td>
									<td class='relat summ'>
										<span class='tsm ssh'>
											<component cmptype="Label" caption="(прописью)"/>
										</span>
										<span style="display: inline-block" letter="true">
											<component cmptype="Label" name="SUMM_CASH" captionfield="SUMM_CASH"/>
											<component cmptype="Label" caption=" руб."/>
											<component cmptype="Label" name="SUMM_CASH_KOP" class='undrl' captionfield="SUMM_CASH_KOP"/>
											<component cmptype="Label" caption=" коп."/>
										</span>
									</td>
								</tr>
							</table>
							<div class='relat summ'>
								<component cmptype="Label" caption="с использованием"/>
								<br/>
								<component cmptype="Label" caption="платёжной карты"/>
								<span class='tsm ssd'>
									<component cmptype="Label" caption="(прописью)"/>
								</span>
								<component cmptype="Label" name="SUMM_CARD" class='lh' captionfield="SUMM_CARD"/>
								<component cmptype="Label" caption=" руб."/>
								<component cmptype="Label" name="SUMM_CARD_KOP" class='undrl' captionfield="SUMM_CARD_KOP"/>
								<component cmptype="Label" caption=" коп."/>
							</div>
							<table width="100%" class='bot'>
								<tr>
									<td>
										<component cmptype="Label" caption="Получил"/>
									</td>
									<td class='undrl'>
										<component cmptype="Label" name="JOBTITLE" captionfield="JOBTITLE"/>
									</td>
									<td class='undrl relat'>
										<div class='emp-line'></div>
									</td>
									<td class='undrl'>
										<component cmptype="Label" name="EMPLOYER_FIO" captionfield="EMPLOYER_FIO"/>
									</td>
								</tr>
								<tr>
									<td></td>
									<td class='tsm center'>
										<component cmptype="Label" caption="(должность)"/>
									</td>
									<td class='tsm center'>
										<component cmptype="Label" caption="(подпись)"/>
									</td>
									<td class='tsm center'>
										<component cmptype="Label" caption="(расшифровка подписи)"/>
									</td>
								</tr>
								<tr>
									<td>
										<component cmptype="Label" caption="Уплатил"/>
									</td>
									<td class='relat undrl'>
										<div class='emp-line' style='width:80%;'></div>
									</td>
									<td colspan='2'>
										<table class='center date'>
											<tr>
												<td>
													<component cmptype="Label" caption="«"/>
												</td>
												<td class='day undrl'>
													<component cmptype="Label" name="PAY_DAY_D" captionfield="PAY_DAY" />
												</td>
												<td>
													<component cmptype="Label" caption="»"/>
												</td>
												<td class='month undrl'>
													<component cmptype="Label" name="PAY_MONTH_D" captionfield="PAY_MONTH" />
												</td>
												<td>
													<component cmptype="Label" caption="20"/>
												</td>
												<td class='year undrl'>
													<component cmptype="Label" name="PAY_YEAR_D" captionfield="PAY_YEAR" />
												</td>
												<td>
													<component cmptype="Label" caption="г."/>
												</td>
											</tr>
										</table>
									</td>
								</tr>
								<tr>
									<td></td>
									<td class='tsm center'>
										<component cmptype="Label" caption="(подпись)"/>
									</td>
									<td colspan='2'></td>
								</tr>
							</table>
							<div class='mp'>
								<component cmptype="Label" caption="М.П."/>
							</div>
						</td>
						<td style="width: 14px;position: relative;">
							<div />

						</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
	<style>
		.mp{
			margin-top:5px;
			margin-left:30%;
		}
		.font-setup{
			font-size:13px;
		}
		.tmd{
			font-size:80%;
		}
		.tbg{
			font-size:120%;
		}
		.tsm{
			font-size:50%
		}
		.kv{
			width: 88%;
			margin: 0 auto;
			text-align:right;
		}
		.sn{
			width:14mm;
			text-align:center;
		}
		.receipt td{
			padding:2px;
		}
		.undrl{
			border-bottom:1px solid black;
		}
		.receipt > table{
			width:100%;
		}
		.receipt{
			width:49%;
			margin:0 2px;
			display:inline-block;
			position:relative;
		}
		.border{
			border:1px solid black;
		}
		.center{
			text-align:center;
		}
		.right{
			text-align:right;
		}
		.relat{
			position:relative;
		}
		.border-bold{
			width:97%;
			border:2px solid black;
			display:block;
			position:absolute;
			top:0;
			left:0;
		}
		.day{
			width:9mm;
		}
		.month{
			width:43mm;
		}
		.year{
			width:6mm;
		}
		.date{
			width:83%;
			margin:0 auto;
		}
		.identifier{
			padding:3mm;
			border:1px dashed black;
		}
		.identifier td{
			padding:2mm;
		}
		.identifier .border-bold{
			top:2mm;
			height:24px;
			padding-top:6px;
			text-align:center;
		}
		.emp-line{
			position:absolute;
			bottom:0;
			width:100%;
		}
		.payment-fio{
			position:absolute;
			left:70mm;
			top:7mm;
		}
		.reason{
			position:absolute;
			left:70mm;
			top:5mm;
		}
		.receipt.main .kv .c{
			display:none;
		}
		.receipt.copy .kv .m{
			display:none;
		}
		.receipt.copy .top{
			display:none;
		}
		.bot td{
			border-left:3px solid white;
			border-right:3px solid white;
		}
		.lh{
			line-height:200%;
		}
		.st{
			position:absolute;
			top:6mm;
			left:70mm;
		}
		.ssd{
			position:absolute;
			top:11mm;
			left:75mm;
		}
		.ssh{
			position:absolute;
			top:10mm;
			left:46mm;
		}
		.summ{
			word-break:break-all;
		}
		.receipt.main > table > tbody > tr > td:nth-child(2){
			vertical-align: top;
		}
		.receipt.main > table > tbody > tr > td:nth-child(2) > div{
			position: absolute;
			height: 100%;
			border-right: 1px dashed black;
			width: 1px;
			left: 10px;

		}
		*[letter="true"]:first-letter{
			text-transform: uppercase;
		}

	</style>
</div>