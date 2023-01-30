params ["_message", "_seconds"];
_delimeter = param [2," ",[""]];


_i = 0;

while {_seconds > _i } do {
	_i = _i + 1;
	playSound3D ["a3\missions_f_beta\data\sounds\firing_drills\checkpoint_not_clear.wss", player];
	hint ([_message, _i] joinString _delimeter);
	sleep 1;
};