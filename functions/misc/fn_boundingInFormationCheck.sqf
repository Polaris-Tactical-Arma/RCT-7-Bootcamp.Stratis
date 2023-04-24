_isInLineFormation = {
	private _unit = _this;
	_angle = 60;
	_dir = getDir _unit;
	_pos = getPosWorld _unit;
	_posPlayer = getPosWorld player;

	_left = [_pos, _dir - 90, _angle, _posPlayer ] call BIS_fnc_inAngleSector;
	if (_left) exitWith {
		_left;
	};
	_right = [_pos, _dir + 90, _angle, _posPlayer ] call BIS_fnc_inAngleSector;

	_right;
};

private _triggerWarning = {
	_message = param[0, "", [""]];
	titleText [["<t color='#ff0000' size='1'>", _message, "</t>"] joinString "", "PLAIN DOWN", 0.1, true, true];
};

while { leader player isNotEqualTo player } do {
	sleep 0.5;
	private _unit = leader player;

	if (player distance _unit > 15) then {
		"Move up, you are too far away!" spawn _triggerWarning;
		continue;
	};

	if (speed (leader player) isEqualTo 0) then {
		continue;
	};

	if (!(_unit call _isInLineFormation)) then {
		"Stay in line with your buddy!" spawn _triggerWarning;
		continue;
	};

	hintSilent "";
};