if !(isMultiplayer) then
{
	["Play this in Multiplayer", true, 3] remoteExec ["BIS_fnc_endMission", 0, true];
}