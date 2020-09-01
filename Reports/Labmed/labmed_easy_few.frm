<?xml version="1.0"
encoding="windows-1251"
?>
<REPORTS>
  <STRC>
    <FK_CATALOGS>
      <SQLADDTXT/>
      <SQLUPDTXT/>
      <SQLDELTXT/>
      <SQLFINTXT>begin select t.ID into :SPK from D_CATALOGS t where t.C_NAME = :C_NAME and t.C_UNITCODE = :C_UNITCODE and t.LPU = :LPU and t.LPU = :LPU; end;</SQLFINTXT>
      <SQLCHKTXT>begin select t.ID into :SPK from D_CATALOGS t where t.C_NAME = :C_NAME and t.C_UNITCODE = :C_UNITCODE and t.LPU = :LPU and t.LPU = :LPU; end;</SQLCHKTXT>
      <SQLADDBT/>
      <SQLUPDBT/>
      <SQLDELBT/>
      <UNITCODE>CATALOGS</UNITCODE>
      <VER_LPU>2</VER_LPU>
      <ROWALIAS>FK_CATALOGS</ROWALIAS>
      <SPKEY>ID</SPKEY>
      <SPIDKEY/>
      <IMETHOD>0</IMETHOD>
      <MAINTABALIAS>REPORTS</MAINTABALIAS>
      <EL_TYPE>2</EL_TYPE>
      <SHIDKEY/>
      <SHIDPID/>
      <SHIDPIDKEY/>
      <COLS>
        <C_NAME IN_ADD="" IN_UPD="" IN_DEL="" IN_FIN="1" COL_TYPE="0">
          <COL_CODE>C_NAME</COL_CODE>
          <FOREIGN/>
        </C_NAME>
        <C_UNITCODE IN_ADD="" IN_UPD="" IN_DEL="" IN_FIN="1" COL_TYPE="0">
          <COL_CODE>C_UNITCODE</COL_CODE>
          <FOREIGN/>
        </C_UNITCODE>
        <ID IN_ADD="" IN_UPD="" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>ID</COL_CODE>
          <FOREIGN/>
        </ID>
      </COLS>
    </FK_CATALOGS>
    <FK_COMPOSITION>
      <SQLADDTXT/>
      <SQLUPDTXT/>
      <SQLDELTXT/>
      <SQLFINTXT>begin select t.ID into :SPK from D_COMPOSITION t where t.CODE = :CODE and t.UNITLIST = :UNITLIST; end;</SQLFINTXT>
      <SQLCHKTXT>begin select t.ID into :SPK from D_COMPOSITION t where t.CODE = :CODE and t.UNITLIST = :UNITLIST; end;</SQLCHKTXT>
      <SQLADDBT/>
      <SQLUPDBT/>
      <SQLDELBT/>
      <UNITCODE>COMPOSITION</UNITCODE>
      <VER_LPU>2</VER_LPU>
      <ROWALIAS>FK_COMPOSITION_ROW</ROWALIAS>
      <SPKEY>ID</SPKEY>
      <SPIDKEY/>
      <IMETHOD>0</IMETHOD>
      <MAINTABALIAS/>
      <EL_TYPE>1</EL_TYPE>
      <SHIDKEY/>
      <SHIDPID/>
      <SHIDPIDKEY/>
      <COLS>
        <CODE IN_ADD="" IN_UPD="" IN_DEL="" IN_FIN="1" COL_TYPE="0">
          <COL_CODE>CODE</COL_CODE>
          <FOREIGN/>
        </CODE>
        <ID IN_ADD="" IN_UPD="" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>ID</COL_CODE>
          <FOREIGN/>
        </ID>
        <UNITLIST IN_ADD="" IN_UPD="" IN_DEL="" IN_FIN="1" COL_TYPE="0">
          <COL_CODE>UNITLIST</COL_CODE>
          <FOREIGN/>
        </UNITLIST>
      </COLS>
    </FK_COMPOSITION>
    <FK_EXTRA_DICTS>
      <SQLADDTXT/>
      <SQLUPDTXT/>
      <SQLDELTXT/>
      <SQLFINTXT>begin select t.ID into :SPK from D_EXTRA_DICTS t where t.EX_CODE = :EX_CODE and t.VERSION = :VERSION; end;</SQLFINTXT>
      <SQLCHKTXT>begin select t.ID into :SPK from D_EXTRA_DICTS t where t.EX_CODE = :EX_CODE and t.VERSION = :VERSION; end;</SQLCHKTXT>
      <SQLADDBT/>
      <SQLUPDBT/>
      <SQLDELBT/>
      <UNITCODE>EXTRA_DICTS</UNITCODE>
      <VER_LPU>0</VER_LPU>
      <ROWALIAS>FK_EXTRA_DICTS_ROW</ROWALIAS>
      <SPKEY>ID</SPKEY>
      <SPIDKEY/>
      <IMETHOD>0</IMETHOD>
      <MAINTABALIAS/>
      <EL_TYPE>1</EL_TYPE>
      <SHIDKEY/>
      <SHIDPID/>
      <SHIDPIDKEY/>
      <COLS>
        <EX_CODE IN_ADD="" IN_UPD="" IN_DEL="" IN_FIN="1" COL_TYPE="0">
          <COL_CODE>EX_CODE</COL_CODE>
          <FOREIGN/>
        </EX_CODE>
        <ID IN_ADD="" IN_UPD="" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>ID</COL_CODE>
          <FOREIGN/>
        </ID>
      </COLS>
    </FK_EXTRA_DICTS>
    <FK_SHOW_METHOD>
      <SQLADDTXT/>
      <SQLUPDTXT/>
      <SQLDELTXT/>
      <SQLFINTXT>begin select t.ID into :SPK from D_SHOW_METHOD t where t.CODE = :CODE and t.UNITCODE = :UNITCODE; end;</SQLFINTXT>
      <SQLCHKTXT>begin select t.ID into :SPK from D_SHOW_METHOD t where t.CODE = :CODE and t.UNITCODE = :UNITCODE; end;</SQLCHKTXT>
      <SQLADDBT/>
      <SQLUPDBT/>
      <SQLDELBT/>
      <UNITCODE>SHOW_METHOD</UNITCODE>
      <VER_LPU>2</VER_LPU>
      <ROWALIAS>FK_SHOW_METHOD_ROW</ROWALIAS>
      <SPKEY>ID</SPKEY>
      <SPIDKEY/>
      <IMETHOD>0</IMETHOD>
      <MAINTABALIAS/>
      <EL_TYPE>1</EL_TYPE>
      <SHIDKEY/>
      <SHIDPID/>
      <SHIDPIDKEY/>
      <COLS>
        <CODE IN_ADD="" IN_UPD="" IN_DEL="" IN_FIN="1" COL_TYPE="0">
          <COL_CODE>CODE</COL_CODE>
          <FOREIGN/>
        </CODE>
        <ID IN_ADD="" IN_UPD="" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>ID</COL_CODE>
          <FOREIGN/>
        </ID>
        <UNITCODE IN_ADD="" IN_UPD="" IN_DEL="" IN_FIN="1" COL_TYPE="0">
          <COL_CODE>UNITCODE</COL_CODE>
          <FOREIGN/>
        </UNITCODE>
      </COLS>
    </FK_SHOW_METHOD>
    <REPORTS>
      <SQLADDTXT>begin D_PKG_REPORTS.ADD(PNLPU =&gt; :LPU, PND_INSERT_ID=&gt;:ID,PSREP_CODE=&gt;:REP_CODE,PSREP_NAME=&gt;:REP_NAME,PSNOTE=&gt;:NOTE,PSSTOREDPROC=&gt;:STOREDPROC,PNOVERLOADNUMB=&gt;:OVERLOADNUMB,PNCID=&gt;:FN_CID,PNREP_TYPE=&gt;:REP_TYPE,PNREP_CREATIONTYPE=&gt;:REP_CREATIONTYPE,PNIS_SHARE=&gt;:IS_SHARE,PSREP_FILENAME=&gt;:REP_FILENAME,PNREP_DATA=&gt;:REP_DATA); end;</SQLADDTXT>
      <SQLUPDTXT>begin D_PKG_REPORTS.UPD(PNLPU =&gt; :LPU, PNID=&gt;:ID,PSREP_CODE=&gt;:REP_CODE,PSREP_NAME=&gt;:REP_NAME,PSNOTE=&gt;:NOTE,PSSTOREDPROC=&gt;:STOREDPROC,PNOVERLOADNUMB=&gt;:OVERLOADNUMB,PNREP_TYPE=&gt;:REP_TYPE,PNREP_CREATIONTYPE=&gt;:REP_CREATIONTYPE,PNIS_SHARE=&gt;:IS_SHARE,PSREP_FILENAME=&gt;:REP_FILENAME,PNREP_DATA=&gt;:REP_DATA); end;</SQLUPDTXT>
      <SQLDELTXT>begin D_PKG_REPORTS.DEL(PNLPU =&gt; :LPU, PNID=&gt;:ID); end;</SQLDELTXT>
      <SQLFINTXT>begin select t.ID into :SPK from D_REPORTS t where t.REP_CODE = :REP_CODE and t.LPU = :LPU; end;</SQLFINTXT>
      <SQLCHKTXT>begin select t.ID into :SPK from D_REPORTS t where t.REP_CODE = :REP_CODE and t.LPU = :LPU; end;</SQLCHKTXT>
      <SQLADDBT>0</SQLADDBT>
      <SQLUPDBT>0</SQLUPDBT>
      <SQLDELBT>0</SQLDELBT>
      <UNITCODE>REPORTS</UNITCODE>
      <VER_LPU>1</VER_LPU>
      <ROWALIAS>REPORTS_ROW</ROWALIAS>
      <SPKEY>ID</SPKEY>
      <SPIDKEY/>
      <IMETHOD>3</IMETHOD>
      <MAINTABALIAS/>
      <EL_TYPE>0</EL_TYPE>
      <SHIDKEY/>
      <SHIDPID/>
      <SHIDPIDKEY/>
      <COLS>
        <FN_CID IN_ADD="1" IN_UPD="" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>CID</COL_CODE>
          <FOREIGN>FK_CATALOGS</FOREIGN>
        </FN_CID>
        <ID IN_ADD="" IN_UPD="1" IN_DEL="1" IN_FIN="" COL_TYPE="1">
          <COL_CODE>ID</COL_CODE>
          <FOREIGN/>
        </ID>
        <IS_SHARE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>IS_SHARE</COL_CODE>
          <FOREIGN/>
        </IS_SHARE>
        <NOTE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="0">
          <COL_CODE>NOTE</COL_CODE>
          <FOREIGN/>
        </NOTE>
        <OVERLOADNUMB IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>OVERLOADNUMB</COL_CODE>
          <FOREIGN/>
        </OVERLOADNUMB>
        <REP_CODE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="1" COL_TYPE="0">
          <COL_CODE>REP_CODE</COL_CODE>
          <FOREIGN/>
        </REP_CODE>
        <REP_CREATIONTYPE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>REP_CREATIONTYPE</COL_CODE>
          <FOREIGN/>
        </REP_CREATIONTYPE>
        <REP_DATA IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>REP_DATA</COL_CODE>
          <FOREIGN/>
        </REP_DATA>
        <REP_FILENAME IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="0">
          <COL_CODE>REP_FILENAME</COL_CODE>
          <FOREIGN/>
        </REP_FILENAME>
        <REP_NAME IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="0">
          <COL_CODE>REP_NAME</COL_CODE>
          <FOREIGN/>
        </REP_NAME>
        <REP_TYPE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>REP_TYPE</COL_CODE>
          <FOREIGN/>
        </REP_TYPE>
        <STOREDPROC IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="0">
          <COL_CODE>STOREDPROC</COL_CODE>
          <FOREIGN/>
        </STOREDPROC>
      </COLS>
    </REPORTS>
    <REPORTS_LINKS>
      <SQLADDTXT>begin D_PKG_REPORTS_LINKS.ADD(PNLPU =&gt; :LPU, PND_INSERT_ID=&gt;:ID,PNPID=&gt;:FK_PID,PSUNITCODE=&gt;:UNITCODE,PSPRIV_NAME=&gt;:PRIV_NAME); end;</SQLADDTXT>
      <SQLUPDTXT>begin D_PKG_REPORTS_LINKS.UPD(PNLPU =&gt; :LPU, PNID=&gt;:ID,PSUNITCODE=&gt;:UNITCODE,PSPRIV_NAME=&gt;:PRIV_NAME); end;</SQLUPDTXT>
      <SQLDELTXT>begin D_PKG_REPORTS_LINKS.DEL(PNLPU =&gt; :LPU, PNID=&gt;:ID); end;</SQLDELTXT>
      <SQLFINTXT>begin select t.ID into :SPK from D_REPORTS_LINKS t where t.UNITCODE = :UNITCODE and t.PID = :FK_PID and t.LPU = :LPU; end;</SQLFINTXT>
      <SQLCHKTXT>begin select t.ID into :SPK from D_REPORTS_LINKS t where t.UNITCODE = :UNITCODE and t.PID = :FK_PID and t.LPU = :LPU; end;</SQLCHKTXT>
      <SQLADDBT>0</SQLADDBT>
      <SQLUPDBT>0</SQLUPDBT>
      <SQLDELBT>0</SQLDELBT>
      <UNITCODE>REPORTS_LINKS</UNITCODE>
      <VER_LPU>1</VER_LPU>
      <ROWALIAS>REPORTS_LINKS_ROW</ROWALIAS>
      <SPKEY>ID</SPKEY>
      <SPIDKEY>FK_PID</SPIDKEY>
      <IMETHOD>3</IMETHOD>
      <MAINTABALIAS>REPORTS</MAINTABALIAS>
      <EL_TYPE>3</EL_TYPE>
      <SHIDKEY/>
      <SHIDPID/>
      <SHIDPIDKEY/>
      <COLS>
        <FK_PID IN_ADD="1" IN_UPD="" IN_DEL="" IN_FIN="1" COL_TYPE="1">
          <COL_CODE>PID</COL_CODE>
          <FOREIGN>REPORTS</FOREIGN>
        </FK_PID>
        <ID IN_ADD="" IN_UPD="1" IN_DEL="1" IN_FIN="" COL_TYPE="1">
          <COL_CODE>ID</COL_CODE>
          <FOREIGN/>
        </ID>
        <PRIV_NAME IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="0">
          <COL_CODE>PRIV_NAME</COL_CODE>
          <FOREIGN/>
        </PRIV_NAME>
        <UNITCODE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="1" COL_TYPE="0">
          <COL_CODE>UNITCODE</COL_CODE>
          <FOREIGN/>
        </UNITCODE>
      </COLS>
    </REPORTS_LINKS>
    <REPORT_PARAMS>
      <SQLADDTXT>begin D_PKG_REPORT_PARAMS.ADD(PNLPU =&gt; :LPU, PND_INSERT_ID=&gt;:ID,PNPID=&gt;:FK_PID,PSPAR_CODE=&gt;:PAR_CODE,PNPAR_TYPE=&gt;:PAR_TYPE,PSPAR_NOTE=&gt;:PAR_NOTE,PSPAR_PROMPT=&gt;:PAR_PROMPT,PNSEQ_NUMB=&gt;:SEQ_NUMB,PNNULLABLE=&gt;:NULLABLE,PNLINK_TYPE=&gt;:LINK_TYPE,PNEXTRA_DICT=&gt;:FK_EXTRA_DICT,PSDEF_STR_VALUE=&gt;:DEF_STR_VALUE,PNDEF_NUM_VALUE=&gt;:DEF_NUM_VALUE,PDDEF_DAT_VALUE=&gt;:DEF_DAT_VALUE,PSSTOREDPROC_PAR=&gt;:STOREDPROC_PAR,PSUNITCODE=&gt;:UNITCODE,PSUNITFIELD=&gt;:UNITFIELD,PNDEF_LOG_VALUE=&gt;:DEF_LOG_VALUE,PNCOMPOSITION=&gt;:FK_COMPOSITION,PNSHOW_METHOD=&gt;:FK_SHOW_METHOD,PNEDIT_METHOD=&gt;:EDIT_METHOD,PNPAR_KIND=&gt;:PAR_KIND,PSCB_VAL=&gt;:CB_VAL); end;</SQLADDTXT>
      <SQLUPDTXT>begin D_PKG_REPORT_PARAMS.UPD(PNLPU =&gt; :LPU, PNID=&gt;:ID,PSPAR_CODE=&gt;:PAR_CODE,PNPAR_TYPE=&gt;:PAR_TYPE,PSPAR_NOTE=&gt;:PAR_NOTE,PSPAR_PROMPT=&gt;:PAR_PROMPT,PNSEQ_NUMB=&gt;:SEQ_NUMB,PNNULLABLE=&gt;:NULLABLE,PNLINK_TYPE=&gt;:LINK_TYPE,PNEXTRA_DICT=&gt;:FK_EXTRA_DICT,PSDEF_STR_VALUE=&gt;:DEF_STR_VALUE,PNDEF_NUM_VALUE=&gt;:DEF_NUM_VALUE,PDDEF_DAT_VALUE=&gt;:DEF_DAT_VALUE,PSSTOREDPROC_PAR=&gt;:STOREDPROC_PAR,PSUNITCODE=&gt;:UNITCODE,PSUNITFIELD=&gt;:UNITFIELD,PNDEF_LOG_VALUE=&gt;:DEF_LOG_VALUE,PNCOMPOSITION=&gt;:FK_COMPOSITION,PNSHOW_METHOD=&gt;:FK_SHOW_METHOD,PNEDIT_METHOD=&gt;:EDIT_METHOD,PNPAR_KIND=&gt;:PAR_KIND,PSCB_VAL=&gt;:CB_VAL); end;</SQLUPDTXT>
      <SQLDELTXT>begin D_PKG_REPORT_PARAMS.DEL(PNLPU =&gt; :LPU, PNID=&gt;:ID); end;</SQLDELTXT>
      <SQLFINTXT>begin select t.ID into :SPK from D_REPORT_PARAMS t where t.PAR_CODE = :PAR_CODE and t.PID = :FK_PID and t.LPU = :LPU; end;</SQLFINTXT>
      <SQLCHKTXT>begin select t.ID into :SPK from D_REPORT_PARAMS t where t.PAR_CODE = :PAR_CODE and t.PID = :FK_PID and t.LPU = :LPU; end;</SQLCHKTXT>
      <SQLADDBT>0</SQLADDBT>
      <SQLUPDBT>0</SQLUPDBT>
      <SQLDELBT>0</SQLDELBT>
      <UNITCODE>REPORT_PARAMS</UNITCODE>
      <VER_LPU>1</VER_LPU>
      <ROWALIAS>REPORT_PARAMS_ROW</ROWALIAS>
      <SPKEY>ID</SPKEY>
      <SPIDKEY>FK_PID</SPIDKEY>
      <IMETHOD>3</IMETHOD>
      <MAINTABALIAS>REPORTS</MAINTABALIAS>
      <EL_TYPE>3</EL_TYPE>
      <SHIDKEY/>
      <SHIDPID/>
      <SHIDPIDKEY/>
      <COLS>
        <CB_VAL IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="0">
          <COL_CODE>CB_VAL</COL_CODE>
          <FOREIGN/>
        </CB_VAL>
        <DEF_DAT_VALUE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="2">
          <COL_CODE>DEF_DAT_VALUE</COL_CODE>
          <FOREIGN/>
        </DEF_DAT_VALUE>
        <DEF_LOG_VALUE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>DEF_LOG_VALUE</COL_CODE>
          <FOREIGN/>
        </DEF_LOG_VALUE>
        <DEF_NUM_VALUE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>DEF_NUM_VALUE</COL_CODE>
          <FOREIGN/>
        </DEF_NUM_VALUE>
        <DEF_STR_VALUE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="0">
          <COL_CODE>DEF_STR_VALUE</COL_CODE>
          <FOREIGN/>
        </DEF_STR_VALUE>
        <EDIT_METHOD IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>EDIT_METHOD</COL_CODE>
          <FOREIGN/>
        </EDIT_METHOD>
        <FK_COMPOSITION IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>COMPOSITION</COL_CODE>
          <FOREIGN>FK_COMPOSITION</FOREIGN>
        </FK_COMPOSITION>
        <FK_EXTRA_DICT IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>EXTRA_DICT</COL_CODE>
          <FOREIGN>FK_EXTRA_DICTS</FOREIGN>
        </FK_EXTRA_DICT>
        <FK_PID IN_ADD="1" IN_UPD="" IN_DEL="" IN_FIN="1" COL_TYPE="1">
          <COL_CODE>PID</COL_CODE>
          <FOREIGN>REPORTS</FOREIGN>
        </FK_PID>
        <FK_SHOW_METHOD IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>SHOW_METHOD</COL_CODE>
          <FOREIGN>FK_SHOW_METHOD</FOREIGN>
        </FK_SHOW_METHOD>
        <ID IN_ADD="" IN_UPD="1" IN_DEL="1" IN_FIN="" COL_TYPE="1">
          <COL_CODE>ID</COL_CODE>
          <FOREIGN/>
        </ID>
        <LINK_TYPE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>LINK_TYPE</COL_CODE>
          <FOREIGN/>
        </LINK_TYPE>
        <NULLABLE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>NULLABLE</COL_CODE>
          <FOREIGN/>
        </NULLABLE>
        <PAR_CODE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="1" COL_TYPE="0">
          <COL_CODE>PAR_CODE</COL_CODE>
          <FOREIGN/>
        </PAR_CODE>
        <PAR_KIND IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>PAR_KIND</COL_CODE>
          <FOREIGN/>
        </PAR_KIND>
        <PAR_NOTE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="0">
          <COL_CODE>PAR_NOTE</COL_CODE>
          <FOREIGN/>
        </PAR_NOTE>
        <PAR_PROMPT IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="0">
          <COL_CODE>PAR_PROMPT</COL_CODE>
          <FOREIGN/>
        </PAR_PROMPT>
        <PAR_TYPE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>PAR_TYPE</COL_CODE>
          <FOREIGN/>
        </PAR_TYPE>
        <SEQ_NUMB IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="1">
          <COL_CODE>SEQ_NUMB</COL_CODE>
          <FOREIGN/>
        </SEQ_NUMB>
        <STOREDPROC_PAR IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="0">
          <COL_CODE>STOREDPROC_PAR</COL_CODE>
          <FOREIGN/>
        </STOREDPROC_PAR>
        <UNITCODE IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="0">
          <COL_CODE>UNITCODE</COL_CODE>
          <FOREIGN/>
        </UNITCODE>
        <UNITFIELD IN_ADD="1" IN_UPD="1" IN_DEL="" IN_FIN="" COL_TYPE="0">
          <COL_CODE>UNITFIELD</COL_CODE>
          <FOREIGN/>
        </UNITFIELD>
      </COLS>
    </REPORT_PARAMS>
  </STRC>
  <DATA>
    <REPORTS>
      <REPORTS_ROW>
        <ID/>
        <REP_CODE>labmed_easy_few</REP_CODE>
        <REP_NAME>�������� ������ �������� </REP_NAME>
        <NOTE/>
        <STOREDPROC/>
        <OVERLOADNUMB/>
        <FN_CID NT="F">
          <C_NAME>���</C_NAME>
          <C_UNITCODE>REPORTS</C_UNITCODE>
        </FN_CID>
        <REP_TYPE>1</REP_TYPE>
        <REP_CREATIONTYPE>1</REP_CREATIONTYPE>
        <IS_SHARE>1</IS_SHARE>
        <REP_FILENAME>Reports/Labmed/labmed_reseach_easy_mass</REP_FILENAME>
        <REP_DATA/>
        <REPORTS_LINKS NT="D"/>
        <REPORT_PARAMS NT="D">
          <REPORT_PARAMS_ROW>
            <ID/>
            <PAR_CODE>DIRS_ID</PAR_CODE>
            <PAR_TYPE>0</PAR_TYPE>
            <PAR_NOTE/>
            <PAR_PROMPT/>
            <SEQ_NUMB>1</SEQ_NUMB>
            <NULLABLE>1</NULLABLE>
            <LINK_TYPE>8</LINK_TYPE>
            <FK_EXTRA_DICT FKN="T" NT="F"/>
            <DEF_STR_VALUE/>
            <DEF_NUM_VALUE/>
            <DEF_DAT_VALUE/>
            <STOREDPROC_PAR/>
            <UNITCODE/>
            <UNITFIELD/>
            <DEF_LOG_VALUE/>
            <FK_COMPOSITION FKN="T" NT="F"/>
            <FK_SHOW_METHOD FKN="T" NT="F"/>
            <EDIT_METHOD/>
            <PAR_KIND>0</PAR_KIND>
            <CB_VAL/>
          </REPORT_PARAMS_ROW>
        </REPORT_PARAMS>
      </REPORTS_ROW>
    </REPORTS>
  </DATA>
</REPORTS>
