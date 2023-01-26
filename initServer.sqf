"initDb" addPublicVariableEventHandler
{
	private ["_data"];
	_data= _this select 1;
	_clientID = _data select 0;
	_UID = _data select 1;
	_playerName = _data select 2;
	
	_inidbi = ["new", _UID] call OO_INIDBI;
	_fileExist = "exists" call _inidbi;
	
	if (_fileExist) then
	{
		hint "FILE DOES EXIST, GETTING DATA";
	}
	else
	{
		hint "FILE DOES NOT EXIST, CREATING DATABASE";
	};
};