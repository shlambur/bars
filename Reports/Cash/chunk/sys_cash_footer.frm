<div width="100%">
<component cmptype="IncludeFile" type="js" src="System/js/number_to_string"/>
<component cmptype="Script">
	Form.OnShow=function()
	{
		setCaption('DATE_B', getVar('DATE_B'));
		setCaption('DATE_E', getVar('DATE_E'));
	}
</component>
<component cmptype="Action" name="getUser">
	declare
		USER_ID               NUMBER(17);
	begin
		USER_ID := d_pkg_employers.get_id(pnlpu => :LPU);			
		select t.FIO
		into :USER_NAME
		from d_v_employers t
		where t.ID = USER_ID;	
	end;
	<component cmptype="ActionVar" name="LPU" get="v1" src="LPU" srctype="session" />
	<component cmptype="ActionVar" name="USER_NAME" put="p0" src="USER_NAME" srctype="ctrlcaption" len="50"/>	
</component>
<component cmptype="DataSet" name="DS_CASH_SECTION">
	select t.CS_NAME 
	from d_v_cash_sections t
	where t.ID = :CASH_SECTION
	<component cmptype="Variable" name="CASH_SECTION" get="v1" src="CASH_SECTION" srctype="var"/>
</component>
<component cmptype="DataSet" name="DS_CASH_DEP">
	select t.CD_NAME
	from d_v_cash_deps t
	where t.ID = :CASH_DEP
	<component cmptype="Variable" name="CASH_DEP" get="v1" src="CASH_DEP" srctype="var"/>
</component>
<component cmptype="DataSet" name="DS_LPU">
	select t.FULLNAME
	from d_v_lpu t	
	where t.ID=:LPU
	<component cmptype="Variable" name="LPU" src="LPU" srctype="session"/>
</component>
<style>
TD.print
{
    font-family:Tahoma;
    background-color:white;
    vertical-align:top;
    padding:2px;
    font-size: 9pt;
}
TD.p
{
	text-align:center;
}
TD.p2
{
	font-size: 8pt;
}
TD.p3
{
	font-size: 9pt;
	font-weight:bold;
}
div.p4
{
	
	display:inline-block;
	width:200px;
	border-bottom:1px solid #000000;
}
div.p5
{
	display:inline-block;
	width:200px;
}
</style>
<div style="min-width: 500px; float: left; padding-top: 15px;">
	<component cmptype="Label" name="FULL_SUM_WORD"/>
</div>	
<div style="min-width: 350px; float: left; padding-top: 15px;">
	Сдал: <div class="p4"></div> / <component cmptype="Label" name="USER_NAME" /> /
</div>
<div style="min-width: 300px; float: left; padding-top: 15px;">
	Принял:<div class="p4"></div> / <div class="p5"></div> /
</div>
</div>