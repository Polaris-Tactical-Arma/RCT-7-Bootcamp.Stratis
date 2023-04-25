if !(isMultiplayer) then
{
	["Play this in Multiplayer", true, 3] remoteExec ["BIS_fnc_endMission", 0, true];
};

waitUntil {
	!isNull findDisplay 46
};

[] execVM "scarCODE\ServerInfoMenu\sqf\initLocal.sqf";
[player] remoteExec ["RCT7_getFromDb", 2];

[] spawn {
	sleep 2;
	createDialog 'RscDisplayServerInfoMenu';

	player addAction ["Start Bootcamp",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];

			player removeAction _actionId;

			[] spawn RCT7Bootcamp_fnc_init;
		}
	];
};