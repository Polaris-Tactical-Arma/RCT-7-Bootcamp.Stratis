
Leader1 lookAt Leader2; // makes unit look at that, duh

Leader1 spawn {
	shiny = true;
	_unit = _this;

	_isInLineFormation = {
		_angle = 60;
		_dir = getDir _unit;
		_pos = getPosWorld _unit;
		_posPlayer = getPosWorld player;

		_left = [_pos, _dir - 90 , _angle, _posPlayer ] call BIS_fnc_inAngleSector;
		if (_left) exitWith{ _left; };
		_right = [_pos, _dir + 90 , _angle, _posPlayer ] call BIS_fnc_inAngleSector;

		_right;
	};

	while { shiny } do {
		sleep 0.5;

		if(player distance _unit > 5)  then {
			hintSilent "you are to far away from your buddy";
			continue;
		};

		if (!(call _isInLineFormation)) then {
			hintSilent "Stay in formation retard!";
			continue;
		};

		hintSilent "";

	};
}

