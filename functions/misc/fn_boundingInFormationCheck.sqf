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

while { leader player isNotEqualTo player } do {
	sleep 0.5;
	private _unit = leader player;

	if (speed (leader player) isEqualTo 0) then {
		hintSilent "";
		continue;
	};

	if (player distance _unit > 5) then {
		hintSilent "Move up, you are too far away!";
		continue;
	};

	if (!(_unit call _isInLineFormation)) then {
		hintSilent "Stay in line with your buddy!";
		continue;
	};

	hintSilent "";
};