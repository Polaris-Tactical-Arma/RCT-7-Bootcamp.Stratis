if (player getVariable ["ACE_hasEarPlugsIn", false]) exitWith {};

_taskId = "earplugs";
_desc = [call RCT7Bootcamp_fnc_getACESelfInfo, " hover over Equipment, put your earplugs in."] joinString "";
[_taskId, "Insert your Earplugs", "Follow the instructions provided.", "listen"] call RCT7Bootcamp_fnc_taskCreate;

waitUntil {
	sleep 1;
	player getVariable ["ACE_hasEarPlugsIn", false];
};

[_taskId, "SUCCEEDED", true, true] call RCT7Bootcamp_fnc_taskSetState;

true;