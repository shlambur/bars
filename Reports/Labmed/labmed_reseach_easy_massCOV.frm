<div cmptype="Form" oncreate="base().OnCreate();">
<component cmptype="Script"><![CDATA[
	Form.OnCreate = function()
	{
            setVar('DIRS_ID', $_GET['DIRS_ID']);
	}
    
	Form.ReportsArray = new Array();
	Form.num = 0;

	Form.onPCLone = function(clone,dataArray){
            Form.ReportsArray[Form.num] = {code: 'labmed_reseach_easy_19PCR', DIR_SERV_ID: dataArray['DIRSERV_ID'], dom:clone};
            Form.num++;
	}

	Form.printMultiReportGroup = function(){
            if(Form.num != 0){
                    for(var i=0;i<Form.num;i++){
                            setVar('rep_paramDIRSERV_ID',Form.ReportsArray[i].DIR_SERV_ID);
                            if (i == 0){
                                printSubReportByCode(Form.ReportsArray[i].dom,Form.ReportsArray[i].code,null,null,null,null,{onreportshow: Form.hideBR});
                            } else {
                                printSubReportByCode(Form.ReportsArray[i].dom,Form.ReportsArray[i].code,null,null,null,null,{onreportshow: Form.hiddenMassBR});
                            }
                    }
            } 
	}

        Form.hiddenMassBR=function(ReportForm)
        {
            var query = ReportForm.querySelectorAll('.page_break');
            var len = query.length;
            for (var i = 0; i < len; i++){
               query[i].style.display = "";
           }
        }
        Form.hideBR = function(ReportForm){
            var query = ReportForm.querySelectorAll('.page_break');
            var len = query.length;
           for (var i = 0; i < len; i++){
               removeDomObject(query[i]);
           }
        }
	]]>
</component>
<component cmptype="DataSet" name="DS_LM" >
    <![CDATA[
         SELECT SUBSTR(txt,
              instr(';' || txt || ';', ';', 1, level),
              instr(';' || txt || ';', ';', 2, level) -
              instr(';' || txt || ';', ';', 1, level) - 1) DIRSERV_ID
              FROM (SELECT :DIRS_ID txt  from dual)
              CONNECT BY level <= LENGTH(regexp_replace(';' || txt, '[^;]', ''))
    ]]>
    <component cmptype="Variable" name="DIRS_ID" src="DIRS_ID" srctype="var" get="v1"/>
</component>
	<div cmptype="tmp" style="display:none;" dataset="DS_LM" repeate="0" onpostclone="base().onPCLone(_clone,_dataArray);" afterrefresh="base().printMultiReportGroup();"></div>
</div>