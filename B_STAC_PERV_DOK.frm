<div cmptype="Form" class="report_main_div" oncreate="base().onCreate();" dataset="DS_TER_INSP">
    <style>
        div.report_main_div {
            margin: 10mm;
            margin-left: 10mm;
        }
    </style>
    <span style="display:none" id="PrintSetup" ps_paperData="9" ></span>
    <!-- Сесия пользователя , у далена на проде -->
    <component cmptype="Script">
    <![CDATA[
        executeAction('SelectUser', function () {
					setCaption('EMPLOYER_FIO_SES', getVar('FIO_SES'));
                    setCaption('EMPLOYER_JOB_SES', getVar('JOB_SES'));
				});
       ]]>        
       
    </component>

    <component cmptype="Script">
         Form.onCreate = function(){
             
             setVar('CURR_DATE', $_GET['CURR_DATE']);
         }
     </component>




    <component cmptype="DataSet" name="session_date">   --  не ясно почему не попадает в отчёт
    <![CDATA[
	select D_PKG_DAT_TOOLS.TO_STR(sysdate) sysdatetime, sysdate, to_char(decode(:CURR_DATE,null,sysdate,to_date(:CURR_DATE,D_PKG_STD.FRM_D)),'DD ')
      ||rtrim(replace(
                      translate(to_char(decode(:CURR_DATE,null,sysdate,to_date(:CURR_DATE,D_PKG_STD.FRM_D)),'month','nls_date_language = RUSSIAN'),'ьй','яя')
                     ,'т ','та')
             )
      ||to_char(decode(:CURR_DATE,null,sysdate,to_date(:CURR_DATE,D_PKG_STD.FRM_D)),' YYYY') sysdate_rus
      
      from dual
      ]]>
      <component cmptype="Variable" name="CURR_DATE" src="CURR_DATE"     srctype="var" get="v2"/>
</component>




    
    <component cmptype="Action" name="SelectUser">    --  достаем сесию пользователя 
			begin
				select D_PKG_STR_TOOLS.FIO(t.SURNAME,t.FIRSTNAME,t.LASTNAME),
                    t.jobtitle 
				  into  :FIO_SES,
                        :JOB_SES
				  from d_v_employers t
				 where t.ID = :EMPLOYER;
			end;
		<component cmptype="ActionVar" name="PNLPU"     src="LPU"           srctype="session"/>
		<component cmptype="ActionVar" name="EMPLOYER"  src="EMPLOYER"      srctype="session"/>
		<component cmptype="ActionVar" name="FIO_SES"   src="FIO_SES"       srctype="var"     put="var1" len="100"/>
        <component cmptype="ActionVar" name="JOB_SES"   src="JOB_SES"       srctype="var"     put="var2" len="101"/>
    </component>
    
    <component cmptype="Script">
         Form.onCreate = function(){
             setVar('VISIT', $_GET['REP_VISIT_ID']);
             setVar('PATIENT_ID', $_GET['PATIENT_ID']);
         }
     </component>
    <component cmptype="DataSet" name="DS_TER_INSP" >    
        <![CDATA[
            SELECT 
            h.lpu,
            h.PATIENT_SURNAME,
            h.PATIENT_LASTNAME,
            h.PD_SER,
            h.PD_NUMB,
            h.PD_WHO,
            h.DATE_IN,
            h.ADDRESS,
            h.MKB_CODE_HOSP,
            h.MKB_NAME_HOSP,
            h.HH_NUMB_FULL,
            h.BIRTHDATE,
            h.PHONES,
            
            to_char(pj.PLAN_DATE, 'DD') PLAN_DAY,
			to_char(pj.PLAN_DATE, 'MM"') PLAN_MONTH,
			to_char(pj.PLAN_DATE, 'YYYY') PLAN_YEAR,
            pj.PLAN_DATE,    
            D_PKG_AGENT_CONTACTS.GET_ACTUAL(t.ID, '3')                                          EMAIL
           -- r.SURNAME FAM,
           -- r.FIRSTNAME IMYA, пока не ястно как это работает , это данные о  предствители пациента ,  если включить , данные  в печатно отчете выходят только 
           -- r.LASTNAME OTCH   в том случаии если  есть представитль пациента , и наче данных не каких не будут  в отчёте.
               
              FROM  D_V_REP_HOSPHISTORY_HEAD h
              Join D_V_HPK_PLAN_JOURNALS pj on pj.PATIENT_ID = h.PATIENT 
              join D_V_AGENTS_WEB t on h.AGENT = t.id
           --   join D_V_AGENT_RELATIVES r on r.PID = h.AGENT
             WHERE h.PATIENT = :PATIENT_ID
             order by pj.PLAN_DATE  desc
        ]]>
        <component cmptype="Variable" name="VISIT_ID" src="VISIT" get="v0" srctype="var" />
        <component cmptype="Variable" name="PATIENT_ID" get="v1"  src="PATIENT_ID" srctype="var" />
    </component>
    

    


    
    <div style="font-weight: bold; text-align: center;">
        <component cmptype="Label" captionfield="FULLNAME"/> <br/>
        <component cmptype="Label" caption="ФГБУ ФНКЦ ФХМ ФМБА России" /> <br/>
        <component cmptype="Label" caption="СОГЛАСИЕ НА ОБРАБОТКУ ПЕРСОНАЛЬНЫХ ДАННЫХ" />
    </div> <br/>
    <table class="form-table" style="width: 100%;">
    

        <tr>
            <td style="width: 5%;">
                Я, 
            </td>
            <td style="border-bottom: 1px solid black; text-align: center; width: 95%">
               <b> 
                    <component cmptype="Label" captionfield="PATIENT_SURNAME"/>
                    <component cmptype="Label" captionfield="PATIENT_LASTNAME"/>
              </b>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="font-size: 7pt; text-align: center;">
                (фамилия, имя, отчество)
            </td>
        </tr>
        <tr>
            <td  colspan="2">
               в соответствии с требованиями статьи 9 Федерального закона от 27.07.2006 «О персональных данных» № 152-ФЗ подтверждаю свое согласие на обработку в ФГБУ ФНКЦ ФХМ ФМБА России 
               (далее именуемое «Оператор») моих персональных данных, включающих: фамилию, имя, отчество, пол, дату рождения. адрес проживания, контактный телефон, паспортные данные, реквизиты
                полиса ОМС (ДМС), страховой номер Индивидуального лицевого счета в Пенсионном фонде России (СНИЛС), данные о состоянии моего здоровья, заболеваниях, случаев обращения за 
                медицинской помощью в медико-профилактических целях, в целях установления медицинского диагноза и оказания медицинских услуг, в целях обработки информации, при условии, что 
                эта обработка осуществляется лицом, уполномоченным Оператором и обязанным сохранять профессиональную тайну.
В процессе оказания Оператором мне медицинской помощи я предоставляю право медицинским работникам передавать мои персональные данные, содержащие сведения, составляющие врачебную тайну, другим 
должностным лицам Оператора в интересах моего обследования и лечения.
Предоставляю Оператору право осуществлять все действия (операции) с моими персональными данными, включая сбор, систематизацию, накопление, хранение, обработку, обновление, изменение,
 использование, обезличивание, блокирование, уничтожение. Оператор вправе обрабатывать мои персональные данные посредством внесения их в электронную базу данных, в формы медицинской 
 документации, включая списки (реестры), отчетно-учетные формы, предусмотренные документами, регламентирующими предоставление медицинских услуг, в том числе с перенесением данных на бумажные 
 носители.Оператор имеет право во исполнение своих обязательств по работе в системе ОМС, по договору на предоставление платных медицинских услуг, по договору ДМС или иному договору на 
предоставление медицинской помощи (медицинских услуг) на обмен (прием и передачу) моими персональными данными с другим юридическим лицом с использованием бумажных носителей или по каналам,
 с соблюдением мер, обеспечивающих их защиту от несанкционированного доступа, а также передавать их в ином установленном порядке на бумажных и электронных носителях, при условии, что их прием
  и обработка будут осуществляться лицами, обязанными сохранять профессиональную тайну. Срок хранения моих персональных данных соответствуют сроку хранения первичных медицинских документов.
Передача моих персональных данных иным лицам или иное их разглашение может осуществляться только с моего письменного согласия. 

            </td>
            
        </tr>


       
     </table>


            <tr>
                <td style="width: 15%;">Настоящее согласие дано мной </td>
                <td style="border-bottom: 1px solid black; text-align: center; ">
                <b><u><component cmptype="Label"  captionfield="PLAN_DATE"/> </u></b>и действует бессрочно.
                </td>
             </tr>

    <table class="form-table" style="width: 100%;">
        <tr>
            
            <td style="width: 100%">
               Я оставляю за собой право отозвать свое согласие посредством составления соответствующего письменного документа и вручения его лично под расписку уполномоченному представителю Оператора.
В случае получения моего письменного заявления об отзыве настоящего согласия на обработку персональных данных Оператор обязан прекратить их обработку в течение периода времени, необходимого для завершения взаиморасчетов по оплате оказанной мне до этого медицинской
помощи.
            </td>
        </tr>
        
    </table>

    <table style="width: 100%;">
    <tr>
<td style="width: 20%">
  Пациент Ф.И.О.
</td>
<td style="border-bottom: 1px solid black; text-align: center; width: 80%">
                <b> 
                    <component cmptype="Label" captionfield="PATIENT_SURNAME"/>
                    <component cmptype="Label" captionfield="PATIENT_LASTNAME"/>
                </b>
</td>
</tr>

<tr>
<td style="width: 20%">
  Паспорт:
</td>
<td style="border-bottom: 1px solid black; text-align: center; width: 80%">
                <b>  
                    <component cmptype="Label" captionfield="PD_SER"/>
                    <component cmptype="Label" captionfield="PD_NUMB"/>
                    <component cmptype="Label" captionfield="PD_WHO"/>
                </b>
</td>
</tr>
<tr>
<td style="width: 20%">
  Адрес:
</td>
<td style="border-bottom: 1px solid black; text-align: center; width: 80%">
                <b>  
                   <component cmptype="Label" captionfield="ADDRESS"/>
                </b>
</td>
</tr>


<tr>
<td style="width: 20%">
  Телефон\E-mail:
</td>
<td style="border-bottom: 1px solid black; text-align: center; width: 80%">
                <b>  
                  <component cmptype="Label" captionfield="EMAIL"/>
                </b>
</td>
</tr>

<tr>
<td style="width: 20%">
  Подпись пациента
</td>
<td style="border-bottom: 1px solid black; text-align: center; width: 80%">
                
</td>
</tr>

</table>



    
    
    <table class="form-table" style="width: 100%; ">
        <tr>
            <td style="width: 20%;">(законный представитель)</td>
            <td style="width: 80%; border-bottom: 1px solid black; text-align: right;">
               <b> <component cmptype="Label" captionfield="" /></b>
                 <component cmptype="Label"  captionfield="FAM"/>
                 <component cmptype="Label"  captionfield="IMYA"/>
                 <component cmptype="Label"  captionfield="OTCH"/>
            </td>
        </tr>
        <tr>
            <td style="width: 20%;"></td>
            <td style="width: 80%; font-size: 7pt; text-align: center;">
                (Ф.И.О. полностью)
            </td>
        </tr>
        
        <td> &#160; </td>

         <tr>
            <td style="width: 20%;"></td>
            <td style="width: 80%; border-bottom: 1px solid black; text-align: right;">
               
            </td>
        </tr>
        <tr>
            <td style="width: 20%; "></td>
            <td style="width: 80%; font-size: 7pt; text-align: center;">
                (Паспортые данные законного представителя)
            </td>
        </tr>
        <td> &#160; </td>

         <tr>
            <td style="width: 20%;"></td>
            <td style="width: 80%; border-bottom: 1px solid black; text-align: right;">
               
            </td>
        </tr>
        <tr>
            <td style="width: 20%; "></td>
            <td style="width: 80%; font-size: 7pt; text-align: center;">
                (Реквизиты документы, подверждающее право представлять интересы пациента)
            </td>
        </tr>
       </table>
       <table class="form-table" style="width: 100%; ">
            <tr>
                    <td style="width: 20%; ">Подпись законного представителя 
                    </td>
                    <td style="width: 30%;  border-bottom: 1px solid black;" >
                    </td>
                    <td style="width: 20%; text-align: center;" >Дата
                    </td>
                    <td style="width: 30%;  border-bottom: 1px solid black; text-align: right;" >
                    </td>

             </tr>
       </table>       
       
       
       
      
        
    <div class="shapka">
    <pre>Приложение 3 к
    Методическим рекомендациям Министр здравоохранения
    Правительства Московской областиот 7 августа 2008 года.</pre>
     </div>
      
      <div style="font-weight: bold; text-align: center;">
       
        <component cmptype="Label" caption="ИНФОРМИРОВАННОЕ ДОБРОВОЛЬНОЕ СОГЛАСИЕ НА ГОСПИТАЛИЗАЦИЮ" />
    </div>

       <table class="form-table" style="width: 100%;">
    

        <tr>
            <td style="width: 5%;">
                Я,нижеподписавшийся(аяся)
            </td>
            <td style="border-bottom: 1px solid black; text-align: center; width: 95%">
               <b> 
                    <component cmptype="Label" captionfield="PATIENT_SURNAME"/>
                    <component cmptype="Label" captionfield="PATIENT_LASTNAME"/>
              </b>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="font-size: 7pt; text-align: center;">
                (фамилия, имя, отчество,  пациента , законного представителя)
            </td>
        </tr>
         <tr>
         <td colspan="2">настоящим подтверждаю, что в соответствии со статьей 20 Основ Законодательства Российской Федерации об охране здоровья граждан
          от 21 ноября 2011 г. № 323-ФЗ, в соответствии с моей волей, в доступной для меня форме, проинформирован(а) о состоянии 
          своего здоровья или здоровья
         </td>
         </tr><br/>
<tr>
            
            <td style="width: 20%">
 Ф.И.О.
</td>
            <td style="border-bottom: 1px solid black; text-align: center; width: 80%">
               
            </td>
        </tr>
        <tr>
            <td colspan="2" style="font-size: 7pt; text-align: center;">
                ( несовершеннолетнего до 15 лет, недееспособного) представляемого мной на основании
            </td>
        </tr>
        <tr>

        <td style="width: 20%">
 Представляемого мною на основании 
</td>
            <td style="border-bottom: 1px solid black; text-align: center; width: 80%">
               
            </td>
        </tr>


         <tr>
            <td style="border-bottom: 1px solid black;" colspan="2"> <br/></td>
        </tr>
        <tr>
            <td colspan="2" style="font-size: 7pt; text-align: center;">
                (наименование и реквизиты правоустанавливающего документа, кем, когда выдан)
            </td>
        </tr>
        <tr>
         <td colspan="2">   а именно, о нижеследующем:
            о наличии, характере, степени тяжести и возможных осложнениях заболевания
         </td>
         </tr>
         <tr>
            <td style="border-bottom: 1px solid black;" colspan="2"> <br/>
                <b>  
                  <component cmptype="Label" captionfield="MKB_CODE_HOSP"/>
                  <component cmptype="Label" captionfield="MKB_NAME_HOSP"/>
                </b>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="font-size: 7pt; text-align: center;">
                ( установленный или предварительный диагноз в соответствии с МКБ)
            </td>
            </tr>

            <tr>
         <td colspan="2">   а именно, о нижеследующем:
            о наличии, характере, степени тяжести и возможных осложнениях заболевания, необходимости госпитализации; об общем плане обследования и лечения; о цели, характере, ходе и объеме планируемого обследования, способах его проведения в ходе
госпитализации; о методах лечения, которые будут применяться в ходе госпитализации; о плане предполагаемого медикаментозного лечения и действии лекарственных средств, в том числе о возможном изменении медикаментозной терапии в случае непереносимости тех или иных лекарственных средств; о прогнозе и методах дальнейшего лечения заболевания в зависимости от изменения состояния здоровья требующего изменения тактики лечения, в том числе о необходимости и целесообразности применения в дальнейшем тех или иных лекарственных средств и других методах лечения.
Я уполномочиваю врачей выполнить любую процедуру или дополнительное вмешательство, которые могут потребоваться в целях моего (представляемого мною лица) обследования и лечения, а также в связи с возникновением непредвиденных ситуаций.
Со мной обсуждены последствия отказа от обследования и лечения. Мне разъяснено, что в случаях, когда состояние пациента не позволяет ему выразить свою волю, а необходимость проведения лечения будет неотложна, вопрос о медицинском вмешательстве, о его виде и тактике проведения, в том числе дополнительном вмешательстве, в интересах пациента решает консилиум, а при невозможности собрать консилиум — непосредственно лечащий (дежурный) врач с последующим уведомлением должностных лиц организации здравоохранения и законных представителей.  
Я осознаю, что проводимое лечение не гарантирует полного выздоровления, что для лучшего результата необходимо проходить медицинские обследования для контроля за Фим состоянием здоровья.
Я предупрежден(а), что за грубое нарушение режима организации здравоохранения могу быть досрочно выписан(а) из организации здравоохранения.
Получив полные и всесторонние разъяснения, включая исчерпывающие ответы на заданные мной вопросы, и имея достаточно времени на принятие решения о согласие на предложенное мне (представляемому мною лицу) обследование и лечение, подтверждаю, что мне понятны используемые термины, суть моего заболевания и опасности, связанные с дальнейшим развитием этого заболевания, добровольно, в соответствии со статьей 20 Основ Законодательства Российской Федерации об охране здоровья граждан от 21 ноября 2011 г.
№ 323-ФЗ, даю свое согласие на госпитализацию.
Подбор и осуществление медикаментозного и других видов лечения доверяю своему лечащему врачу

         </td>
         </tr>

         <tr>
            <td style="border-bottom: 1px solid black; text-align: center;" colspan="2"> <br/>
            <b> 
                    <component cmptype="Label" captionfield="PATIENT_SURNAME"/>
                    <component cmptype="Label" captionfield="PATIENT_LASTNAME"/>
                </b>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="font-size: 7pt; text-align: center;">
                (Фамилия,Имя, Отчество)
            </td>
        </tr>

         <tr>
         <td colspan="2">  Я удостоверяю, что текст моего информированного добровольного согласия на госпитализацию мною прочитан, 
         мне понятно назначение данного документа, полученные разъяснения понятны и меня удовлетворяют

         </td>
         </tr>
        </table>

         <table>
         <tr>
         <td>«</td><td class="day"><b><component cmptype="Label"  captionfield="PLAN_DAY"/></b></td><td>»</td>
          <td class="month"> <b><component cmptype="Label" name="PLAN_MONTH" captionfield="PLAN_MONTH"/></b></td>
          <td> &#160; </td>
          <td class="year"> <b><component cmptype="Label" name="PLAN_YEAR" captionfield="PLAN_YEAR"/></b> г. </td>
          <td> &#160; </td>
          <td style="border-bottom: 1px solid black; width: 250px"> </td>
          <td> &#160; </td>
          <td style="border-bottom: 1px solid black; width: 200px">\<component cmptype="Label" captionfield="PATIENT_SURNAME"/> </td>
         </tr>

         <tr>
         <td > </td>
        <td style=" width: 10px;  "> </td>
         <td > </td>
        <td style=" width: 100px;"> </td>
        <td> &#160; </td>
        <td style=" width: 50px;"> </td>
        <td> &#160; </td>
        <td style=" width: 250px; font-size: 7pt; text-align: center;"> (подпись пациента,законного представителя) </td>
        <td> &#160; </td>
        <td style=" width: 200px; font-size: 7pt; text-align: center;">(Расшифровка подписи)</td>
        </tr>
       </table>

<table>
<tr>
            <td style="width: 38%;">
                Настоящий документ оформил
            </td>
            <td style="border-bottom: 1px solid black; text-align: center; width: 68%">
               <b> 
                    <component cmptype="Label" name="EMPLOYER_FIO_SES"/>
                    <component cmptype="Label" name="EMPLOYER_JOB_SES"/> 
                    
              </b>
            </td>
        </tr>
        <tr>
        <td></td>
            <td  style="font-size: 7pt; text-align: center;">
                (лечащий врач, зав. отделением ЛПУ, другой специалист, принимающий непосредственное участие в обследовании и лечении)
            </td>
        </tr>
    
        <tr>
            
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center; width: 100%"> &#160; 
              
            </td>
        </tr>
        <tr>
            
            <td colspan="2" > по результатам предварительного информирования пациента (законного представителя) о состоянии его здоровья (здоровья представляемого).
              
            </td>
        </tr>
</table>

<table>
         <tr>
         <td>«</td><td class="day"><b><component cmptype="Label"  captionfield="PLAN_DAY"/></b></td><td>»</td>
          <td class="month"> <b><component cmptype="Label" name="PLAN_MONTH" captionfield="PLAN_MONTH"/></b></td>
          <td> &#160; </td>
          <td class="year"> <b><component cmptype="Label" name="PLAN_YEAR" captionfield="PLAN_YEAR"/></b> г. </td>
          <td> &#160; </td>
          <td style="border-bottom: 1px solid black; width: 250px"> </td>
          <td> &#160; </td>
          <td style="border-bottom: 1px solid black; width: 200px">\ <component cmptype="Label" captionfield="PATIENT_SURNAME"/></td>
         </tr>

         <tr>
         <td > </td>
        <td style=" width: 10px;  "> </td>
         <td > </td>
        <td style=" width: 100px;"> </td>
        <td> &#160; </td>
        <td style=" width: 50px;"> </td>
        <td> &#160; </td>
        <td style=" width: 250px; font-size: 7pt; text-align: center;"> (подпись пациента,законного представителя) </td>
        <td> &#160; </td>
        <td style=" width: 200px; font-size: 7pt; text-align: center;">(Расшифровка подписи)</td>
        </tr>
       </table>


<table style="width: 100%; ">
<tr>
<td>Если пациент по каким-либо причинам не может собственноручно подписать данный документ, настоящий документ заверяется двумя подписями сотрудников организации:
</td>
</tr>
</table>
<table>
         <tr>
         <td>«</td><td class="day"><b><component cmptype="Label"  captionfield="PLAN_DAY"/></b></td><td>»</td>
          <td class="month"> <b><component cmptype="Label" name="PLAN_MONTH" captionfield="PLAN_MONTH"/></b></td>
          <td> &#160; </td>
          <td class="year"> <b><component cmptype="Label" name="PLAN_YEAR" captionfield="PLAN_YEAR"/></b> г. </td>
          <td> &#160; </td>
          <td style="border-bottom: 1px solid black; width: 250px"> </td>
          <td> &#160; </td>
          <td style="border-bottom: 1px solid black; width: 200px">\ </td>
         </tr>

         <tr>
         <td > </td>
        <td style=" width: 10px;  "> </td>
         <td > </td>
        <td style=" width: 100px;"> </td>
        <td> &#160; </td>
        <td style=" width: 50px;"> </td>
        <td> &#160; </td>
        <td style=" width: 250px; font-size: 7pt; text-align: center;"> (подпись пациента,законного представителя) </td>
        <td> &#160; </td>
        <td style=" width: 200px; font-size: 7pt; text-align: center;">(Расшифровка подписи)</td>
        </tr>
       </table>

<table style= "page-break-after: always;">
         <tr>
         <td>«</td><td class="day"><b><component cmptype="Label"  captionfield="PLAN_DAY"/></b></td><td>»</td>
          <td class="month"> <b><component cmptype="Label" name="PLAN_MONTH" captionfield="PLAN_MONTH"/></b></td>
          <td> &#160; </td>
          <td class="year"> <b><component cmptype="Label" name="PLAN_YEAR" captionfield="PLAN_YEAR"/></b> г. </td>
          <td> &#160; </td>
          <td style="border-bottom: 1px solid black; width: 250px"> </td>
          <td> &#160; </td>
          <td style="border-bottom: 1px solid black; width: 200px">\ </td>
         </tr>

         <tr>
         <td > </td>
        <td style=" width: 10px;  "> </td>
         <td > </td>
        <td style=" width: 100px;"> </td>
        <td> &#160; </td>
        <td style=" width: 50px;"> </td>
        <td> &#160; </td>
        <td style=" width: 250px; font-size: 7pt; text-align: center;"> (подпись пациента,законного представителя) </td>
        <td> &#160; </td>
        <td style=" width: 200px; font-size: 7pt; text-align: center;">(Расшифровка подписи)</td>
        </tr>
       </table>



<div style="font-weight: bold; text-align: center;">
        
        <component cmptype="Label" caption="Федеральное государственное бюджетное учреждение " /> <br/>
        <component cmptype="Label" caption="«ФЕДЕРАЛЬНЫЙ НАУЧНО-КЛИНИЧЕСКИЙ ЦЕНТР ФИЗИКОХИМИЧЕСКОЙ МЕДИЦИНЫ Федерального медико-биологического агентства»" />
    </div> <br/>


<table >
         <tr>
         <td>Приложение к медицинской карте № </td>
        <td style="border-bottom: 1px solid black; width: 100px; text-align: center; "> <b><component cmptype="Label" captionfield="HH_NUMB_FULL"/></b> </td>
        </tr>
        <tr>
         <td>&#160; </td>
        </tr>

<tr>
<td colspan="2">Информированное добровольное согласие на виды медицинских вмешательств, включенные в Перечень определенных видов медицинских вмешательств, на которые
 граждане дают информированное добровольное согласие при выборе врача и медицинской организации для получения первичной медико-санитарной помощи
</td>
</tr>
</table>

<table  style="width: 100%;">
    

        <tr>
            <td style="width: 5%;">
                Я, 
            </td>
            <td style="border-bottom: 1px solid black; text-align: center; width: 95%">
               <b> 
                    <component cmptype="Label" captionfield="PATIENT_SURNAME"/>
                    <component cmptype="Label" captionfield="PATIENT_LASTNAME"/>
                    <component cmptype="Label" captionfield="BIRTHDATE"/> г. рождения
              </b>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="font-size: 7pt; text-align: center;">
                (Ф.И.О.гражданина)
            </td>
        </tr>
        </table>

        <table>
        <tr>
        <td style="width: 30%;">зарегистрированный по адресу:
        </td>
        <td style="border-bottom: 1px solid black; text-align: center; width: 70%">
                <b>  
                   <component cmptype="Label" captionfield="ADDRESS"/>
                </b>
        </td >
        </tr>
        <tr>
         <td>&#160; </td>
        </tr>

<tr>
<td colspan="2"> даю информированное добровольное согласие на виды медицинских вмешательств, включенные в Перечень определенных видов медицинских вмешательств, 
на которые граждане дают информированное добровольное согласие при выборе врача и медицинской организации для получения первичной медико-санитарной помощи, утвержденный
 приказом Министерства здравоохранения и социального развития Российской Федерации от 23 апреля 2012 г. 390н (зарегистрирован Министерством юстиции Российской 
 Федерации 5 мая 2012 г. N 24082) (далее - Перечень), для получения первичной медико-санитарной помощи / получения первичной медико-санитарной помощи лицом, законным 
 представителем которого я являюсь (ненужное зачеркнуть) в Федеральном государственном бюджетном учреждении «Федеральный научно-клинический центр Физико-химической 
 медицины Федерального медико-биологического агентства Медицинским работником
</td>
</tr>
        


        <tr>
            <td style="border-bottom: 1px solid black; text-align: center;" colspan="2"> <br/>
                 <b> 
                   
                </b>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="font-size: 7pt; text-align: center;">
                (должность, Ф.И.О. медицинского работника)
            </td>
        </tr>
        <tr>
         <td>&#160; </td>
        </tr>

<tr>
<td colspan="2">в доступной для меня форме мне разъяснены цели, методы оказания медицинской помощи, связанный с ними риск, 
возможные варианты медицинских вмешательств, их последствия, в том числе вероятность развития осложнений, а также предполагаемые результаты оказания
 медицинской помощи. Мне разъяснено, что я имею право отказаться от одного или нескольких видов медицинских вмешательств, включенных в Перечень, или потребовать
  его (их) прекращения, за исключением случаев, предусмотренных частью 9 статьи 20 Федерального закона от 21 ноября 2011 г. 323-ФЗ основах охраны здоровья граждан 
  в Российской Федерации“ (Собрание законодательства Российской Федерации, 2011, 48, ст. 6724; 2012, 26, ст. 3442, 3446).
</td>
</tr>
        <tr>
         <td>&#160; </td>
        </tr>

<tr>
<td colspan="2"><p style="text-indent: 25px;"> Сведения о выбранных мною лицах, которым в соответствии с пунктом 5 части 5 статьи 19 Федерального закона от 21 ноября 2011 г.
 323-ФЗ ”06 основах охраны здоровья граждан в Российской Федерации“ может быть передана информация о состоянии моего здоровья или состоянии лица,
  законным представителем которого я являюсь (ненужное зачеркнуть)</p>
</td>
</tr>
        

        <tr>
            <td style="border-bottom: 1px solid black; text-align: center;" colspan="2"> <br/>
                 <b> 
                   
                    <component cmptype="Label" captionfield="PATIENT_SURNAME"/>
                    <component cmptype="Label" captionfield="PATIENT_LASTNAME"/>  т.
                    <component cmptype="Label" captionfield="PHONES"/>
                
                </b>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="font-size: 7pt; text-align: center;">
                ( Ф.И.О. Гражданина,контактный телефон)
            </td>
        </tr>
       

        <tr>
        <td style="border-bottom: 1px solid black; text-align: center;" >
               
            </td>
            <td style="border-bottom: 1px solid black; text-align: center;" colspan="2"> <br/>
                 <b> 
                   
                    <component cmptype="Label" captionfield="PATIENT_SURNAME"/>
                    <component cmptype="Label" captionfield="PATIENT_LASTNAME"/>  
                   
                
                </b>
            </td>
        </tr>
        <tr>
        <td  style="font-size: 7pt; text-align: center;">
                (подпись)
            </td>
            <td  style="font-size: 7pt; text-align: center;">
                ( (Ф.И.О. гражданина или законного представителя гражданина)
            </td>
        </tr>


        <tr>
        <td style="border-bottom: 1px solid black; text-align: center;" >
               
            </td>
            <td style="border-bottom: 1px solid black; text-align: center;" colspan="2"> <br/>
                 <b> 
                    <component cmptype="Label" name="EMPLOYER_FIO_SES"/> 
                </b>
            </td>
        </tr>
        <tr>
        <td  style="font-size: 7pt; text-align: center;">
                (подпись)
            </td>
            <td  style="font-size: 7pt; text-align: center;">
                ( Ф.И.О. Медицинского работника)
            </td>
        </tr>
        </table>


        <table style= "page-break-after: always;" >
                <tr>
         <td>«</td><td class="day"><b><component cmptype="Label"  captionfield="PLAN_DAY"/></b></td><td>»</td>
          <td class="month"> <b><component cmptype="Label" name="PLAN_MONTH" captionfield="PLAN_MONTH"/></b></td>
          <td> &#160; </td>
          <td class="year"> <b><component cmptype="Label" name="PLAN_YEAR" captionfield="PLAN_YEAR"/></b> г. </td>
         
                </tr>
                <tr>
            <td colspan="6" style="font-size: 7pt; text-align: center;">
                ( дата оформления)
            </td>
        </tr>

        </table>


<div style="font-weight: bold; text-align: center;">
       
        <component cmptype="Label" caption="ПЕРЕЧЕНЬ" />
        <component cmptype="Label" caption="ОПРЕДЕЛЕННЫХ ВИДОВ МЕДИЦИНСКИХ ВМЕШАТЕЛЬСТВ," />
        <component cmptype="Label" caption="НА КОТОРЫЕ ГРАЖДАНЕ ДАЮТ ИНФОРМИРОВАННОЕ ДОБРОВОЛЬНОЕ" />
        <component cmptype="Label" caption="СОГЛАСИЕ ПРИ ВЫБОРЕ ВРАЧА И МЕДИЦИНСКОЙ ОРГАНИЗАЦИИ ДЛЯ " />
        <component cmptype="Label" caption="ПОЛУЧЕНИЯ ПЕРВИЧНОЙ МЕДИКО-САНИТАРНОЙ ПОМОЩИ" />
    </div> <br/>
     

<table style="width: 100%; ">
<ol>
  <li>Опрос, в том числе выявление жалоб, сбор анамнеза.</li>
  <li>Осмотр, в том числе пальпация, перкуссия, аускультация, риноскопия,
   фарингоскопия, непрямая ларингоскопия, вагинальное исследование (для женщин), ректальное исследование.</li>
  <li>Антропометрические исследования.</li>
  <li>Термометрия.</li>
  <li>Тонометрия.</li>
  <li>Неинвазивные исследования органа зрения и зрительных функций.</li>
  <li>Неинвазивные исследования органа слуха и слуховых функций.</li>
  <li>Исследование функций нервной системы (чувствительной и двигательной сферы).</li>
  <li>Лабораторные методы обследования, в том числе клинические, биохимические, бактериологические, вирусологические, иммунологические.</li>
  <li>Функциональные методы обследования, в том числе электрокардиография, суточное мониторирование артериального давления, суточное мониторирование 
  электрокардиограммы, спирография, пневмотахометрия, пикфлоуметрия, рэоэнцефалография, электроэнцефалография, , кардиотокография  (для беременных).</li>
  <li>Рентгенологические методы обследования, в том числе флюорография (для лиц старше 15 лет) и рентгенография, ультразвуковые исследования,
   доплерографические исследования.</li>
  <li>Введение лекарственных препаратов по назначению врача, в том числе внутримышечно, внутривенно, подкожно, внутрикожно.</li>
  <li>Медицинский массаж.</li>
  <li>Лечебная физкультура.</li>
</ol>
<br/>
<div style="font-weight: bold; text-align: center;">
       
        <component cmptype="Label" caption=" Информированное согласие на проведение обследования на ВИЧ-инфекцию" />
        
    </div> <br/>
</table>


<table  style="width: 100%;">
    

        <tr>
            <td style="width: 5%;">
                Я, 
            </td>
            <td style="border-bottom: 1px solid black; text-align: center; width: 95%">
               <b> 
                    <component cmptype="Label" captionfield="PATIENT_SURNAME"/>
                    <component cmptype="Label" captionfield="PATIENT_LASTNAME"/>
                    <component cmptype="Label" captionfield="BIRTHDATE"/> г. рождения
              </b>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="font-size: 7pt; text-align: center;">
                (Фамилия имя отчество)
            </td>
        </tr>
        <tr>
<td colspan="2">
настоящим подтверждаю, что на основании предоставленной мне информации, свободно и без принуждения, отдавая отчет о последствиях обследования, принял решение пройти тестирование на антитела к ВИЧ. Для этой цели я соглашаюсь сдать анализ крови. Я подтверждаю, что мне разъяснено, почему важно пройти тестирование на ВИЧ, как проводится тест и какие последствия может иметь тестирование на ВИЧ.
Я проинформирован, что:
-	тестирование на ВИЧ проводится в Центре СПИД и других медицинских учреждениях. Тестирование по моему добровольному выбору может быть добровольным анонимным (без предъявления документов и указания имени) или конфиденциальным (при предъявлении паспорта, результат будет известен обследуемому и лечащему врачу). В государственных медицинских учреждениях тестирование на ВИЧ проводится бесплатно;
-	доказательством наличия ВИЧ-инфекции является присутствие антител к ВИЧ в крови обследуемого лица. Вместе с тем, в период между заражением и появлением антител к ВИЧ (так называемое «серонегативное окно», обычно З месяца) при тестировании не обнаруживаются антитела к ВИЧ и обследуемое лицо может заразить других лиц; - ВИЧ-инфекция передается только тремя путями:
-	парентеральный — чаше всего при употреблении наркотиков, но может передаваться также при использовании нестерильного медицинского инструментария, переливании компонентов крови, нанесении татуировок, пирсинге зараженным инструментом, использовании чужих бритвенных и маникюрных принадлежностей; - при сексуальных контактах без презерватива;
-	от инфицированной ВИЧ матери к ребенку во гремя беременности, родов и при грудном вскармливании.

</td>
</tr>
        </table>


        <table  style="width: 100%; page-break-after: always;">
         <tr>
        <td style="border-bottom: 1px solid black; text-align: center; width:20%;" >
               
            </td>
            <td style=" width:60%;" >
               
            </td>

            <td style="border-bottom: 1px solid black; text-align: center;  width:10%; font-weight: bold;"> <br/>
                <component cmptype="Label"  captionfield="PLAN_DATE"/>
            </td>
        </tr>
        <tr>
        <td  style="font-size: 7pt; text-align: center; width:30%;">
                (подпись обследуемого на ВИЧ)
            </td>

            <td style=" width:60%;" >
               
            </td>

            <td  style="font-size: 7pt; text-align: center; width:10%;">
                (Дата)
            </td>
        </tr>
        </table>


<div style="font-weight: bold; text-align: center;">
       
        <component cmptype="Label" caption="Информирование о выявлении ВИЧ-инфекции " />
       <div> <component cmptype="Label" caption="ЗАПОЛНЯЕТСЯ ТОЛЬКО ПРИ ВЫЯВЛЕНИИ ВИЧ-ИНФЕКЦИИ" /></div>
    </div> <br/>


<table  style="width: 100%;">
    

        <tr>
            <td style="width: 5%;">
                Я, 
            </td>
            <td style="border-bottom: 1px solid black; text-align: center; width: 95%">
               <b> 
                    <component cmptype="Label" captionfield="PATIENT_SURNAME"/>
                    <component cmptype="Label" captionfield="PATIENT_LASTNAME"/>
                    <component cmptype="Label" captionfield="BIRTHDATE"/> года  рождения
              </b>
            </td>
        </tr>
        <tr>
            <td colspan="2" style="font-size: 7pt; text-align: center;">
                (Фамилия имя отчество)
            </td>
        </tr>
        <tr>
<td colspan="2">
настоящим подтверждаю, что получил информацию о выявлении у меня ВИЧ-инфекции, мне разъяснено, что означает этот диагноз.
Я проинформирован, что:
-	присутствие антител к ВИЧ, эпидемиологических и клинических данных является доказательством наличия ВИЧ-инфекции;
-	для диспансерного наблюдения, уточнения стадии заболевания и назначения лечения мне необходимо обратиться в Центр по профилактиже и борьбе со СПИД.
Мне разъяснено, что:
-	ВИЧ-инфицированным оказываются на общих основаниях все виды медицинской помощи по клиническим показаниям в соответствии с законодательством Российской Федерации об охране здоровья граждан;
-	ВИЧ-инфицированные граждане Российской Федерации обладают на ее территории всеми правами и свободами и Исполняют обязанности в соответствии с Конституцией российской Федерации, законодательством Российской Федерации;
-	в настоящее время в России существует бесплатное обследование и лечение (антиретровирусная терапия) для нуждающихся инфицированных ВИЧ. Для наблюдения и лечения мне рекомендовано немедленно обратиться в территориальный Центр СПИД. Антиретровирусная терапия не позволяет излечиться от ВИЧ-инфекции, но останавливает размножение вируса, существенно продлевает жизнь больному и уменьшает вероятность передачи от него заболевания. ВИЧ-инфицированным беременным женщинам важно как можно раньше обратиться в Центр СПИД и начать принимать специальные лекарства для предотвращения заражения будущего ребенка; - ВИЧ-инфекция передается только тремя путями:
1.	При сексуальных контактах без презерватива.
2.	Через кровь - чаще всего при употреблении наркотиков, но может передаваться также при использовании нестерильного медицинского инструментария, переливании компонентов крови, нанесении татуировок, пирсинге зараженным инструментом, использовании чужих бритвенных и маникюрных принадлежностей.
З . От инфицированной ВИЧ матери к ребенку во время беременности, родов и при грудном вскармливании.
-	заражение ВИЧ в быту при рукопожатиях, пользовании общей посудой, бассейном, туалетом, совместном приеме пищи, а также при укусах насекомых не происходит;
-	я должен/должна соблюдать меры предосторожности , чтобы не инфицировать ВИЧ других людей. Защитить других от заражения ВИЧ-инфекцией можно, если не иметь с ними опасных контактов (люди не должны иметь контакты с кровью, выделениями половых органов и грудным молоком инфицированного ВИЧ человека). Мне дана рекомендация информировать половых партнеров о наличии у меня ВИЧ-инфекции, всегда и правильно пользоваться презервативами. Следует оградить других людей от контактов с кровью инфицированного ВИЧ человека, пользоваться только индивидуальными предметами личной гигиены (бритвами, маникюрными принадлежностями, зубными щетками) и при необходимости стерильными медицинскими инструментами. Желательно не употреблять наркотик;
-	Инфицированные ВИЧ не могут быть донорами крови, биологических жидкостей, органов и тканей. Существует уголовная ответственность за заведомое поставление другого лица в опасность заражения ВИЧ-инфекцией либо заражение другого лица ВИЧ-инфекцией (ст. 122 Уголовного кодекса Российской Федерации, Собрание законодательства Российской Федерации).
-	с вопросами можно обратиться в территориальный Центр СПИД.
 

</td>
</tr>
        </table>


        <table  style="width: 100%; page-break-after: always; ">
         <tr>
        <td style="border-bottom: 1px solid black; text-align: center; width:20%;" >
               
            </td>
            <td style=" width:60%;" >
               
            </td>

            <td style="border-bottom: 1px solid black; text-align: center;  width:10%; font-weight: bold;"> <br/>
                <component cmptype="Label"  captionfield="PLAN_DATE"/>
            </td>
        </tr>
        <tr>
        <td  style="font-size: 7pt; text-align: center; width:30%;">
                (подпись обследуемого на ВИЧ)
            </td>

            <td style=" width:60%;" >
               
            </td>

            <td  style="font-size: 7pt; text-align: center; width:10%;">
                (Дата)
            </td>
        </tr>
        </table>

           
    <div class="shapka">
    <pre>Приложение № 1 
     к приказу №25</pre>
     </div>

<div style="font-weight: bold; text-align: center;">
        
        <component cmptype="Label" caption="Информация для пациента ФГБУ ФНКЦ ФХМ ФМБА РОССИИ" />
    </div> <br/>

        <table  style="width: 100%;  ">

    <tr>
    <td  colspan="2">
         <p  style="text-indent: 30px;">
В соответствии с Федеральным Законом Российской Федерации от 23 февраля 2013 г. N 15-ФЗ охране здоровья граждан от воздействия окружающего табачного
 дыма и последствий потребления табака“ (статья 12 п.2; статья 17 ПА) и на основании Приказов № 172 от 13.06.2013г., № 25 от 09.01.2014 Главного врача
  ФГБУ ФИКЦ ФХМ ФМБА РОССИИ , на территории клинической больницы, а также в её функциональных подразделениях и лечебных отделениях установлен строгий внутренний 
  распорядок дня и <b>КАТЕГОРИЧЕСКИ запрещается курение табака.</b>
Нарушение установленного порядка и невыполнение указанного Федерального Закона влечёт за собой немедленную выписку из стационара.
        </p>

    </td>
    </tr>

    <tr>
    <td colspan="2">
         <p  style="text-indent: 30px;">
  "С информацией ознакомлен"
        </p>
    </td>
    </tr>

    <tr>
    <td style="width: 20%;" >
        ФИО пациента 
    </td>
 <td style="border-bottom: 1px solid black; text-align: center;  width:80%; font-weight: bold;">
                    <component cmptype="Label" captionfield="PATIENT_SURNAME"/>
                    <component cmptype="Label" captionfield="PATIENT_LASTNAME"/>
    </td>

    </tr>
</table>
<table>
    <tr>
    <td style="width: 20%;" >
        Подпись пациента
    </td>

 <td style="border-bottom: 1px solid black; text-align: center;  width:30%; font-weight: bold;">
    </td><br/>
 <td> &#160; </td>
   <td style=" width:50%;"> 
   </td>

    </tr>
    <tr>
    <td style="width: 20%;" >
        Дата
    </td>

 <td style="border-bottom: 1px solid black; text-align: center;  width:30%; font-weight: bold;">
        <component cmptype="Label"  captionfield="PLAN_DATE"/>
    </td> <br/>
 <td> &#160; </td>
   <td style=" width:50%;"> 
   </td>

    </tr>

        </table>



       

<style>
.shapka {
    page-break-before:always;
    font-size: 10px;
    font-family: "Monotype Corsiva" Cursive;
    margin-left: auto;
    margin-right: 0 em;
    padding: 20px;

    border:0px solid #0000FF; 
    width:200px; 
    height:50px; 
}
.day {
    width: 10px;
    border-bottom: 1px solid black;
    text-align: center;
}
.month{
    width: 100px;
    border-bottom: 1px solid black;
    text-align: center;

}
.year { 
    width: 50px;
    border-bottom: 1px solid black;
    text-align: center;

}
</style>
     
</div>

 