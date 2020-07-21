<div style="font-size:12pt; font-family:'Times New Roman'; text-align:justify;">

<component cmptype="Script">
Form.onrefreshmicro=function(args)
	{
		var _data=args[0];
		var _params={F_NAME:'',STR_VALUE:''};
		for(var i=_data.length; i&lt;2; i++)
		{
			_data.push(_params);
		}
	}
Form.onrefreshDir=function(args)
	{
		var _data=args[0];
		var _params={T:'',N:'',M:'',STAGE:'',MET_PODTV:'',ISSL_ID:'',CANC_SIZE:'',FIRST_M_CAN:'',KAK_NASHLI:'',COM_RD:''};
		for(var i=_data.length; i&lt;0; i++)
		{
			_data.push(_params);
		}
	}
</component>


</div>