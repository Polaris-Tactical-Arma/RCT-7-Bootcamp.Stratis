RCT7_dbQueue = [];

RCT7_writeToDb = {
	params["_player", "_section", "_key", "_value", ["_additional_pairs", []]];

	if !(isServer) exitWith {};

	_section_data = [ [_key, _value] ]; // Create section data array with the given key-value pair

	// Add additional key-value pairs if any
	{
		if (typeName _x == "ARRAY" && count _x == 2) then {
			// Check if it's a valid key-value pair
			_additional_key = _x select 0;
			_additional_value = _x select 1;
			_section_data pushBack [_additional_key, _additional_value];
		};
	} forEach _additional_pairs;

	_data = [_section, _section_data];
	["bootcamp.add", [getPlayerUID _player, name _player, _data]] call py3_fnc_callExtension;
};

RCT7_getFromDb = {
	_player = param[0, objNull, [objNull]];
	if !(isServer) exitWith {};

	_data = ["bootcamp.get_data", [getPlayerUID _player]] call py3_fnc_callExtension;
	RCT7playerData = _data;

	if (_data # 0 # 0 isEqualTo "error") exitWith {
		RCT7playerData = [];
	};

	publicVariable "RCT7playerData";
};

RCT7_addToDBQueue = {
	_item = param[0, [], [[]]];

	RCT7_dbQueue pushBack _item;
};

_runQueue = {
	[] spawn {
		while { true } do {
			sleep 1;
			if (count RCT7_dbQueue isEqualTo 0) then {
				continue;
			};

			_currentItem = RCT7_dbQueue # 0;
			_currentItem call RCT7_writeToDb;
			RCT7_dbQueue deleteAt 0;
		};
	};
};

call _runQueue;