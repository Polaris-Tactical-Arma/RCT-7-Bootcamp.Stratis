params ["_message", "_seconds"];
_delimeter = param [2, " ", [""]];

while { _seconds > 0 } do {
	playSound3D ["a3\missions_f_beta\data\sounds\firing_drills\checkpoint_not_clear.wss", player];
	hint parseText ([_message, _seconds] joinString _delimeter);
	sleep 1;
	_seconds = _seconds - 1;
};