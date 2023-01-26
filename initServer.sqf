"initDb" addPublicVariableEventHandler
{
	private ["_data"];
			
	_data= _this select 1;
	
	_UID = _data select 0;
	_playerName = _data select 1;
	
	_filter = "0123456789AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZzÜüÖöÄä";
	_playerName = [_playerName, _filter] call BIS_fnc_filterString;


	_dbName = ["rct7Bootcamp", _UID] joinString "_";
	_db = ["new", _dbName] call OO_INIDBI;

	_recruitName = ["read", [_UID, "name"]] call _db;

	if (_recruitName isEqualTo  false) then {
		// New player joined
		_time = "getTimeStamp" call _db;
		["write", [_UID, "created_at", _time]] call _db;
	};

	["write", [_UID, "name", _playerName]] call _db;

	_credits = ["read", [_UID, "credits"]] call _db;

	if (_credits isEqualTo false) then {
		_maxCredits = 3;
		["write", [_UID, "credits", _maxCredits]] call _db;
	};

	if (_credits isEqualTo 0) then {
		// out of credits
	};

};