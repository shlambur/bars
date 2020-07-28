<div cmptype="Form" onshow="base().onshow()" window_size="1024x768">
    <component cmptype="Script">
        <![CDATA[
        Form.onshow = function () {
            setValue('CANC_DATE', dateFormat(new Date(), 'dd.mm.yyyy'));
            setWindowCaption('Отмена очереди');
        }
        Form.onButtonOk = function () {
            if (getVar('ONLY_ASK') == 1) {
                closeWindow(null, null, {
                    ModalResult: 1,
                    CANC_DATE: getValue('CANC_DATE'),
                    CANC_REASON: getValue('CANC_REASON')
                })
            } else {
                executeAction('ACT_SEL', function () {
                    closeWindow(null, null, {
                        ModalResult: 1
                    })
                })
            }
        }
        ]]>
    </component>
    <component cmptype="Action" mode="post" name="ACT_SEL">
        <![CDATA[
            declare nLPU NUMBER(17) := :pnLPU;
            begin
                if :psSUFF = 'EXT' then
                    begin
                        select wr.LPU
                          into nLPU
                          from D_V_WL_RECORDS wr
                         where wr.ID = :pnID;
                    exception when NO_DATA_FOUND then null;
                    end;
                end if;
                D_PKG_WL_RECORDS.SET_CANCEL(pnID          => :pnID,
                                            pnLPU         => nLPU,
                                            pdCANC_DATE   => to_date(:pdCANC_DATE,'dd.mm.yyyy'),
                                            psCANC_REASON => :psCANC_REASON);
            end;
        ]]>
        <component cmptype="ActionVar" name="pnID"                  src="ID"                   srctype="var"  get="g1"/>
        <component cmptype="ActionVar" name="pnLPU"                 src="LPU"                  srctype="session" />
        <component cmptype="ActionVar" name="pdCANC_DATE"           src="CANC_DATE"            srctype="ctrl" get="g2"/>
        <component cmptype="ActionVar" name="psCANC_REASON"         src="CANC_REASON"          srctype="ctrl" get="g3"/>
        <component cmptype="ActionVar" name="psCANC_REASON"         src="CANC_REASON"          srctype="ctrl" get="g3"/>
        <component cmptype="ActionVar" name="psSUFF"                src="SUFF"                 srctype="var"  get="g4"/>
    </component>
    <div>
        <table style="width: 100%">
            <tr>
                <td>
                    <component cmptype="Label" caption="Дата отмены" />
                </td>
                <td>
                    <component cmptype="DateEdit" name="CANC_DATE" emptyMask="true" maskType="date"/>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <component cmptype="UnitEdit" name="CANC_REASON" dirdict="WL_QUEUE_CANC_REAS" caption="Причины отмены"  type="FillingTextArea"  height="270"  width="100%" emptyMask="true" max_length="1000"/>
                </td>
            </tr>
        </table>
    </div>
    <div style="height: 60px;">
        <div class="formBackground form_footer" >
            <component cmptype="Button" name="BUTTON_OK" onclick="base().onButtonOk();" caption="ОК"/>
            <component cmptype="Button" onclick="closeWindow();" caption="Отмена"/>
            <component cmptype="MaskInspector" controls="CANC_DATE;CANC_REASON" effectControls="BUTTON_OK" name="MaskInsp"/>
        </div>
    </div>
    <component cmptype="SubForm" path="footerStyle"/>
</div>