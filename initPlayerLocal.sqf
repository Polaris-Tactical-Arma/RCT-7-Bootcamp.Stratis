if !(isMultiplayer) then
{
	["Play this in Multiplayer", true, 3] remoteExec ["BIS_fnc_endMission", 0, true];
};

waitUntil {
	!isNull findDisplay 46
};

RCT7playerData = nil;

[] execVM "scarCODE\ServerInfoMenu\sqf\initLocal.sqf";
[player] remoteExec ["RCT7_getFromDb", 2];

[] spawn { while {true} do {sleep 180; systemChat "Unsure what to do? Press 'J' to open the task list.";}};

[] spawn {
	waitUntil {
		sleep 3;
		{
			publicVariable "RCT7playerData"
		} remoteExec ["call", 2];
		!(isNil "RCT7playerData");
	};
	createDialog 'RscDisplayServerInfoMenu';

	private _prefix = "Start";
	if (count RCT7playerData > 0) then {
		_prefix = "Resume";
	};
	_actionTitle = [_prefix, "Bootcamp"] joinString " ";

	player addAction [_actionTitle,

		{
			params ["_target", "_caller", "_actionId", "_arguments"];

			player removeAction _actionId;

			[] spawn RCT7Bootcamp_fnc_init;
		}
	];
};