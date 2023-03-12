if (player getVariable ["ACE_hasEarPlugsIn", false]) exitWith {};

_taskId = "earplugs";
_desc = [call RCT7Bootcamp_fnc_getACESelfInfo, " and under Equipment, put your earplugs in."] joinString "";
[_taskId, "Use your Earplugs", "Follow the instructions", "listen"] call RCT7Bootcamp_fnc_taskCreate;

waitUntil {
	sleep 1;
	player getVariable ["ACE_hasEarPlugsIn", false];
};

[_taskId, "SUCCEEDED", true, true] call RCT7Bootcamp_fnc_taskSetState;

true;