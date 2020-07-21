<div cmptype="bogus" oncreate="base().OnCreate();" dataset="DS" repeate="1" style="font-weight:bold;">
    <span style="display:none" id="PrintSetup" ps_marginLeft="15"></span>
    <component cmptype="Script">
        <![CDATA[
        Form.OnCreate = function() {
          setVar('ID', function(){
              if(!empty(getVar('ID')) && getVar('ID') != '0'){
                  return getVar('ID');
              }
              if(!empty(getVar('DIR_SERVICE')) && getVar('DIR_SERVICE') != '0'){
                  return getVar('DIR_SERVICE');
              }
          }());
            refreshDataSet('DS');
        }
        ]]>
    </component>
    <!--<component cmptype="IncludeFile" type="css" src="Forms/Reports/Reception/agreement"/>-->
    <component cmptype="IncludeFile" type="css" src="Forms/Reports/Reception/style"/>
    <component cmptype="DataSet" name="DS" activateoncreate="false">
        <![CDATA[
            select d.PATIENT as PATIENT,
                   a.BIRTHDATE as BIRTHDATE,
                   D_PKG_AGENT_PERSDOCS.GET_ACTUAL_ON_DATE(p.AGENT, sysdate, 'PD_TYPE_NAME') as DOC_TYPE,
                   D_PKG_AGENT_PERSDOCS.GET_ACTUAL_ON_DATE(p.AGENT, sysdate, 'PD_SER') as DOC_SER,
                   D_PKG_AGENT_PERSDOCS.GET_ACTUAL_ON_DATE(p.AGENT, sysdate, 'PD_NUMB') as DOC_NUMB,
                   D_PKG_AGENT_PERSDOCS.GET_ACTUAL_ON_DATE(p.AGENT, sysdate, 'PD_WHO PD_WHEN') as DOC_WHO,
                   t.SERVICE_NAME as SERVICE,
                   D_PKG_DAT_TOOLS.DATE_TO_CHAR(sysdate, 'DD MONTH YYYY') DDATE,
                   t.EMPLOYER_FIO_TO as DOCTOR
              from d_v_direction_services t
                   join d_v_directions d on d.ID = t.PID
                   join d_v_persmedcard p on p.ID = d.PATIENT_ID
                   join d_v_agents a on a.ID = p.AGENT
             where t.ID = :ID
        ]]>
        <component cmptype="Variable" name="ID" get="v0" src="ID" srctype="var"/>
    </component>

    <style>
        span.field {
          border-bottom:1px solid black;
          padding:0px 10px;
        }
        td.field {
          border-bottom:1px solid black;
          text-align:center;
        }
        div.field {
          font-weight:bold;
          border-bottom:1px solid black;
          text-align:center;
          width:100%;
        }
        p {
          font-weight:bold;
          text-indent:18.0pt;
          width: 100%;
          text-align:left;
        }
        h3 {
          text-align: center;
          margin-bottom:10px;
        }
    </style>
    <h3>
        <component cmptype="Label" caption="Информированное добровольное согласие пациента на медицинское вмешательство (исследование)"/>
    </h3>
    <table style="width:100%;">
        <tr>
            <td style="width:260px">
                <p>
                  <component cmptype="Label" caption="Я, пациент (законный представитель)"/>
                </p>
            </td>
            <td class="field">
                <component cmptype="Label" captionfield="PATIENT"/>
            </td>
        </tr>
    </table>
    <p style="text-indent:0px;">
        <component cmptype="Label" caption="(__________________________________________)"/>
        <component cmptype="Label" captionfield="BIRTHDATE" class="field"/>
        <component cmptype="Label" caption="&#160;года рождения,"/>
        <nobr>
          <component cmptype="Label" captionfield="DOC_TYPE" class="field"/>
        </nobr>
        <component cmptype="Label" caption="серия&#160;"/>
        <component cmptype="Label" captionfield="DOC_SER" class="field"/>
        <component cmptype="Label" caption="№&#160;"/>
        <component cmptype="Label" captionfield="DOC_NUMB" class="field"/>
        <component cmptype="Label" caption="выдан&#160;"/>
        <component cmptype="Label" captionfield="DOC_WHO" class="field"/>
        <component cmptype="Label" caption="
            в  соответствии  со  ст.30-33   Основ  законодательства  РФ  об  охране  здоровья  граждан
            №5487-1   от 22.07.1993г. проинформирован(а) о том, что мне (пациенту) необходимо выполнить"/>
    </p>
    <div class="field">
        <component cmptype="Label" captionfield="SERVICE"/>
    </div>

    <p>
        <component cmptype="Label" caption="
            Я уведомлен(а) о цели в ходе проведения исследования и не имею по этому поводу вопросов к медперсоналу.
            Согласен на проведение исследования в предложенных объемах. Я сообщил(а) сведения о наличии у меня
            (у пациента) сопутствующих и перенесенных ранее заболеваний."/>

    </p>
    <p>
        <component cmptype="Label" caption="
            Я уведомлен(а), что в процессе медицинского вмешательства и после него могут возникнуть осложнения,
            связанные с биологическими особенностями моего (пациента) организма."/>
    </p>
    <p>
        <component cmptype="Label" caption="
            Я уведомлен(а), о возможных осложнениях исследования, а также о том, что будут приняты все необходимые
            меры предосторожности до, во время и после исследования. Исследование будут проводить специально
            подготовленные врач и медсестра."/>

    </p>
    <p>
        <component cmptype="Label" caption="
            Я подтверждаю, что мне (пациенту) разъяснены права пациента при обращении за медицинской помощью и ее
            получении, на:"/>

    </p>
    <p>
        <component cmptype="Label" caption="
            1)	уважительное и гуманное отношение со стороны медицинского и обслуживающего персонала;"/>
    </p>
    <p>
        <component cmptype="Label" caption="
            2)	выбор врача, в том числе врача общей практики и лечащего врача, а также выбор
            лечебно-профилактического учреждения в соответствии с договорами обязательного и добровольного
            медицинского страхования;"/>

    </p>
    <p>
        <component cmptype="Label" caption="
            3)	обследование, лечение и содержание в условиях, соответствующих санитарно-гигиеническим требованиям;"/>
    </p>
    <p>
        <component cmptype="Label" caption="
            4)	проведение по просьбе пациента консилиума и консультаций других специалистов;"/>
    </p>
    <p>
        <component cmptype="Label" caption="
            5)	облегчение боли, связанной с заболеванием и (или) медицинским вмешательством, доступными способами
            и средствами;"/>
    </p>
    <p>
        <component cmptype="Label" caption="
            6)	сохранение в тайне информации пациента о факте обращения за медицинской помощью, о состоянии здоровья,
            диагнозе и иных сведений, полученных при его обследовании и лечении;"/>
    </p>
    <p>
        <component cmptype="Label" caption="
            7)	информированное добровольное согласие на медицинское вмешательство;"/>
    </p>
    <p>
        <component cmptype="Label" caption="
            8)	отказ от медицинского вмешательства;"/>
    </p>
    <p>
        <component cmptype="Label" caption="
            9)	получение информации о своих правах и обязанностях и состоянии своего здоровья, включая сведения
            о результатах обследования, наличии заболевания, его диагнозе и прогнозе, методах лечения, связанном
            с ними риске, возможных вариантах медицинского вмешательства, их последствиях и результатах проведенного
            лечения;"/>
    </p>
    <p>
        <component cmptype="Label" caption="
            10)	право на выбор лиц, которым в интересах пациента может быть передана информация о состоянии его здоровья;"/>
    </p>
    <p>
        <component cmptype="Label" caption="
            11)	право непосредственно знакомиться с медицинской документацией, отражающей состояние его здоровья,
            и получать консультации по ней у других специалистов, а также право получать копии медицинских документов,
            отражающих состояние здоровья пациента, если в них не затрагиваются интересы третьей стороны;"/>
    </p>
    <p>
        <component cmptype="Label" caption="
            12)	получение медицинских и иных услуг в рамках программ добровольного медицинского страхования;"/>
    </p>
    <p>
        <component cmptype="Label" caption="
            13)	возмещение ущерба в случае причинения вреда его здоровью при оказании медицинской помощи;"/>
    </p>
    <p>
        <component cmptype="Label" caption="
            14)	допуск к пациенту адвоката или иного законного представителя для защиты его прав;"/>
    </p>
    <p>
        <component cmptype="Label" caption="
            15)	допуск к пациенту священнослужителя, а в больничном учреждении - предоставление условий для отправления
            религиозных обрядов, в том числе на предоставление отдельного помещения, если это не нарушает внутренний
            распорядок больничного учреждения."/>
    </p>
    <p>
        <component cmptype="Label" caption="
            В случае нарушений моих прав (прав пациента) я могу обратиться с жалобой непосредственно к руководителю
            или любому должностному лицу лечебно-профилактического учреждения, в котором мне (пациенту) оказывается
            медицинская помощь, а также в соответствующие профессиональные медицинские ассоциации либо в суд."/>
    </p>
    <p>
        <component cmptype="Label" caption="
            Подписанием данного документа, я подтверждаю, что информирован(а) о цели, характере, ходе и объеме
            предстоящего МНЕ (пациенту) исследования, возможных неблагоприятных эффектах, а также о том, что предстоит
            мне делать во время его проведения."/>
    </p>
    <p>
        <component cmptype="Label" caption='
            Я согласен(сна) с тем, что при проведении исследования нельзя полностью исключить вероятность возникновения
            побочных эффектов и осложнений, обусловленных биологическими особенностями организма, и в случае, когда
            услуга оказана с соблюдением всех необходимых требований, Федеральное государственное  бюджетное учреждение
             «Федеральный научно – клинический центр физико- химической медицины Федерального медико-  биологического 
             агентства» (ФГБУ ФНКЦ ФХМ ФМБА России)
            " не несет ответственности за их возникновение.'/>
    </p>
    <p>
      <component cmptype="Label" caption="Я получил(а) информацию об альтернативных методах исследования."/>
    </p>
    <p>
        <component cmptype="Label" caption='
            Я обязуюсь (пациент обязуется) исполнять все назначения, рекомендации и советы врачей
             (ФГБУ ФНКЦ ФХМ ФМБА России)
 
            соблюдать режим в ходе исследования, немедленно сообщать врачу о любом ухудшении самочувствия.'/>
    </p>
    <p>
        <component cmptype="Label" caption="
            Я имел(а) возможность задать любые интересующие меня вопросы касательно состояния моего здоровья
            (здоровья пациентов), получил(а) на них надлежащие ответы и имел(а) достаточно времени на
            обдумывание решения о согласии на предложенное мне (пациенту) исследование."/>
    </p>
    <p>
        <component cmptype="Label" caption='
            Я проинформирован(а), что исследование возможно провести в других лечебных учреждениях,
            и подтверждаю свое согласие на проведение данного исследования в Федеральном государственном 
             бюджетном учреждение «Федеральный научно – клинический центр физико- химической медицины Федерального медико-  биологического агентства» 
             (ФГБУ ФНКЦ ФХМ ФМБА России)
 
      '/>
    </p>
    <p>
        <component cmptype="Label" caption="
            При этом врачи могут быть поставлены перед необходимостью значительно изменить доведенный до моего
            (сведения пациента) ход исследования. Может потребоваться дополнительное исследование."/>
    </p>
    <p>
        <component cmptype="Label" caption="
            Я извещен(а) о наличии у меня как у пациента (у законного представителя пациента) права
            отказаться от медицинского вмешательства или потребовать его прекращения."/>
    </p>
    <p>
        <component cmptype="Label" caption="
            Я как пациент (законный представитель пациента) извещен(а) также о возможных негативных последствиях
            отказа от медицинского вмешательства или его прекращения."/>
    </p>
    <p>
        <component cmptype="Label" caption='
            Я извещен(а) о наличии у специалистов Федерального государственного  бюджетного учреждение
             «Федеральный научно – клинический центр физико- химической медицины Федерального медико-  биологического агентства» 
             (ФГБУ ФНКЦ ФХМ ФМБА России) права не приступать к оказанию услуг, приостановить оказание услуг, отказаться от оказания
            услуг в случаях, когда имеет место нарушение мной (пациентом) своих обязанностей.'/>
    </p>
    <p>
        <component cmptype="Label" caption='
            Я извещен(а) о том, что Федеральное государственное  бюджетное учреждение «Федеральный научно – клинический центр физико- химической медицины Федерального медико-  биологического агентства»
             (ФГБУ ФНКЦ ФХМ ФМБА России) не несет ответственности за вред, причиненный моему здоровью
            (здоровью пациента) при оказании медицинского вмешательства, при условии, что вышеуказанное
            медицинское вмешательство произведено с соблюдением всех необходимых требований, а размер вреда
            соразмерен потребностям моего здоровья (здоровья пациента).'/>
    </p>
    <p>
        <component cmptype="Label" caption="Я понимаю, что услуги, оплаченные мной, не финансируются страховой кампанией (территориальным фондом)."/>
    </p>
    <p>
        <component cmptype="Label" caption="
            Я делаю добровольный выбор о предоставлении мне платных услуг и согласен(а) произвести оплату
            за них из своих собственных средств."/>
    </p>
    <p>
      <component cmptype="Label" caption="Информация о состоянии моего здоровья может быть предоставлена моему(ей)"/>
    </p>
    <div class="field">
      <p>&#160;</p>
    </div>
    <p>
        <component cmptype="Label" caption="Настоящее соглашение мной прочитано, врач ответил на все мои вопросы."/>
    </p>
    <p>
        <component cmptype="Label" caption="
            Я, подписывая данный документ, даю информированное добровольное согласие на предложенные условия
          проведения вышеуказанного медицинского вмешательства (исследования)."/>

    </p>
    <br/>
    <table style="width:100%; font-weight:bold;">
        <tr>
            <td align="left" class="field">
		        <component cmptype="Label" captionfield="DDATE" class="field"/>
            </td>
            <td style="text-align:right;">
                <component cmptype="Label" caption="подпись_________________"/>
            </td>
        </tr>
    </table>
    <br/>
    <br/>
    <p>
        <component cmptype="Label" caption="
            Я _____________________________________________________________
            законный представитель пациента"/>

    </p>
    <table style="width:100%;">
        <tr>
            <td class="field">
                <component cmptype="Label" captionfield="PATIENT"/>
            </td>
            <td style="width:250px; padding-left:10px;">
                  <component cmptype="Label" caption="даю согласие на предложенные условия "/>
            </td>
        </tr>
    </table>
    <component cmptype="Label" caption="проведения вышеуказанного вмешательства (исследования)."/>
    <br/>
    <table style="width:100%; font-weight:bold;">
        <tr>
            <td align="left" class="field">
                <component cmptype="Label" captionfield="DDATE" class="field"/>
            </td>
            <td style="text-align:right;">
                <component cmptype="Label" caption="подпись_________________"/>
            </td>
        </tr>
    </table>
    <br/>
    <br/>
    <p>
        <component cmptype="Label" caption="Настоящее соглашение подписано пациентом (законным представителем пациента) после проведения врачом разъяснительной беседы."/>
        <br/>
    </p>
    <table style="width:100%;">
        <tr>
            <td style="width:150px;">
                <component cmptype="Label" caption="&#160; &#160; &#160; &#160; &#160;Беседу провел врач"/>
            </td>
            <td class="field">
                <component cmptype="Label" captionfield="DOCTOR"/>
            </td>
            <td style="width:10px;"/>
            <td class="field" style="width:130px;">
                <component cmptype="Label" captionfield="DDATE"/>
            </td>
        </tr>
    </table>
    <table valign="top"  width="610" border="0" BGCOLOR="white">
        <tr>
            <td align="left">
                <b/>
            </td>
        </tr>
    </table>
</div>