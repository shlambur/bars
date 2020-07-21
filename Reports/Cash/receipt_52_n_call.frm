<div cmptype="Form" onshow="executeAction('EXT_SEL')">
    <component cmptype="Script">
        <![CDATA[
            Form.onPrint = function () {
                setVar('KASSIR',getValue('EMPLOYERS'));
                setVar('CONTRACT_ID',getVar('CONTRACT_ID'));
                setVar('KASSIR_EDIT',getValue('KASSIR_EDIT'));
                printReportByCode('receipt_52_n', 1250, 700);
            }
        ]]>
    </component>
    <component cmptype="Action" name="EXT_SEL">
        <![CDATA[
            begin
                select e.ID,
                       e.FIO
                  into :ID,
                       :FIO
                  from D_V_EMPLOYERS e
                 where e.ID = :EMPLOYER;
            end;
        ]]>
        <component cmptype="ActionVar" name="EMPLOYER" src="EMPLOYER"  srctype="session"/>
        <component cmptype="ActionVar" name="ID"       src="EMPLOYERS" srctype="ctrl" len="17" put="p1"/>
        <component cmptype="ActionVar" name="FIO"      src="EMPLOYERS" srctype="ctrlcaption" len="4000" put="p2"/>
    </component>
    <table style="width: 100%">
        <tr>
            <td>
                <component cmptype="Label" caption="Кассир"/>
            </td>
            <td>
                <component cmptype="UnitEdit" unit="EMPLOYERS" composition="DEFAULT_NAME" name="EMPLOYERS" width="100%"/>
            </td>
        </tr>
        <tr>
            <td>
                <component cmptype="Label" caption="Ручной ввод"/>
            </td>
            <td>
                <component cmptype="Edit" name="KASSIR_EDIT" width="100%"/>
            </td>
        </tr>
    </table>
    <div style="height: 40px;">
        <div class="formBackground form_footer">
            <component cmptype="Button" caption="Ок" name="ButtonOk" onclick="base().onPrint();"/>
            <component cmptype="Button" caption="Закрыть" onclick="closeWindow();"/>
            <component cmptype="SubForm" path="footerStyle"/>
        </div>
    </div>
</div>