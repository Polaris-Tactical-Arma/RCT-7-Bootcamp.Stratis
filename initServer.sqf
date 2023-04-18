RCT7playerData = [];

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
	params["_player", "_section", "_key", "_value", ["_additional_pairs", []]];

	if !(isServer) exitWith {};

	RCT7playerData = ["bootcamp.get_data", [getPlayerUID player]] call py3_fnc_callExtension;
};