
RCT7_fnc_getINIDB = {
	params["_player"];
	_UID = getPlayerUID _player;

	_dbName = ["rct7Bootcamp", _UID] joinString "_";
	_db = ["new", _dbName] call OO_INIDBI;

	_db;
};

RCT7_writeToDb = {
	params["_player", "_section", "_key", "_value"];

	if (isServer) then {
		_db = _player call RCT7_fnc_getINIDB;

		["write", [_section, _key, _value]] call _db;
	};
};


"initDb" addPublicVariableEventHandler
{
	private ["_player"];
			
	_data = _this select 1;
	_player = _data select 0;
	
	_UID = getPlayerUID _player;
	_playerName = name _player;
	
	_filter = "0123456789AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZzÜüÖöÄä";
	_playerName = [_playerName, _filter] call BIS_fnc_filterString;

	_db = _player call RCT7_fnc_getINIDB;

	_recruitName = ["read", [_UID, "name"]] call _db;

	if (_recruitName isEqualTo  false) then {
		// New player joined
		
		["write", [_UID, "created_at", systemTimeUTC]] call _db;
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
